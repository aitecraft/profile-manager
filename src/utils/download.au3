#include-once
#include <InetConstants.au3>
#include <Array.au3>
#include <Math.au3>
#include "lang_manager.au3"
#include "misc.au3"
#include "../gui/extras.au3"

Func DownloadFileBulk(ByRef $url_list, ByRef $file_list, $progress_callback_func, $callback_timer = 400, $redundancy = 2)
    
    ;_ArrayDisplay($url_list)
    ;_ArrayDisplay($file_list)
    ;Exit

    ; Ensure Arrays are of same size, and also array size > 0
    $list_size = UBound($url_list)
    If ($list_size <> UBound($file_list)) Or ($list_size <= 0) Then
        UnexpectedExitErrorMsgBox("download.au3 -> DownloadFileBulk", "bulkdownload_arrays_size_mismatch", $list_size)
        Exit
    EndIf

    ; Array of Download handles
    Local $dw_handles[$list_size]

    ; Start Downloading
    For $i = 0 To $list_size - 1
        CreateFolderFromFilePath($file_list[$i])

        ;$dw_handles[$i] = InetGet($url_list[$i], $file_list[$i], $INET_LOCALCACHE, $INET_DOWNLOADBACKGROUND)
        
        ; Using force reload by default to avoid any caching issues.
        $dw_handles[$i] = InetGet($url_list[$i], $file_list[$i], $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
    Next

    ; Progress Callbacks
    Do
        Sleep($callback_timer)
        Local $total_bytes_raw = 0
        
        $total_raw_broken = False
        
        For $i = 0 To $list_size - 1            
            $current_total_bytes_raw = InetGetInfo($dw_handles[$i], $INET_DOWNLOADSIZE)
            
            ; If any of the files' total size hasn't been loaded yet, let the callback function know.
            If $current_total_bytes_raw <= 0 Then
                $total_raw_broken = True
                ExitLoop
            EndIf
            
            $total_bytes_raw += $current_total_bytes_raw
        Next
        
        
        $done = True
        $dw_files_count = 0
        Local $dw_bytes_raw = 0
        For $i = 0 To $list_size - 1
            $dw_bytes_raw += InetGetInfo($dw_handles[$i], $INET_DOWNLOADREAD)
            If InetGetInfo($dw_handles[$i], $INET_DOWNLOADCOMPLETE) Then
                If InetGetInfo($dw_handles[$i], $INET_DOWNLOADSUCCESS) Then
                    $dw_files_count = $dw_files_count + 1
                EndIf
            Else
                $done = False
            EndIf
        Next

        $progress_callback_func($dw_files_count, $list_size, BytesToAppropriateUnit($dw_bytes_raw), $total_raw_broken, BytesToAppropriateUnit($total_bytes_raw))
    Until $done

    ; Check if any file failed to download
    ; and close handles

    $download_success = True

    Local $empty_arr[0]
    $redundancy_url_list = $empty_arr
    $redundancy_file_list = $empty_arr

    For $i = 0 To $list_size - 1
        Local $aData = InetGetInfo($dw_handles[$i])
        ;ConsoleWrite("-------" & $file_list[$i] & "-------" & @CRLF)
        ;ConsoleWrite("@error: " & @error & @CRLF)
        ;ConsoleWrite("Download size: " & $aData[$INET_DOWNLOADSIZE] & @CRLF)
        ;ConsoleWrite("Download size: " & $aData[$INET_DOWNLOADERROR] & @CRLF)
        If @error Or $aData[$INET_DOWNLOADERROR] <> 0 Then
            
            FileDelete($file_list[$i])
            $download_success = False
            ;ConsoleWrite("ERROR triggered" & @CRLF)

            If $redundancy > 0 Then
                _ArrayAdd($redundancy_file_list, $file_list[$i])
                _ArrayAdd($redundancy_url_list, $url_list[$i])
            EndIf
        EndIf
        
        InetClose($dw_handles[$i])
    Next

    If $download_success Then
        ; If everything was downloaded, return true
        Return True
    ElseIf $redundancy > 0 Then
        Return DownloadFileBulk($redundancy_url_list, $redundancy_file_list, $progress_callback_func, $callback_timer, $redundancy - 1)
    EndIf
    
    Return False
EndFunc

Func DownloadFile($url, $file, $progress_callback_func)

    CreateFolderFromFilePath($file)

    Local $dwHandle = InetGet($url, $file, 0, $INET_DOWNLOADBACKGROUND)

    Do
        Sleep(200)
        $dw_bytes_raw = InetGetInfo($dwHandle, $INET_DOWNLOADREAD)
        $total_bytes_raw = InetGetInfo($dwHandle, $INET_DOWNLOADSIZE)

        $dw = BytesToAppropriateUnit($dw_bytes_raw)
        $total = BytesToAppropriateUnit($total_bytes_raw)
        $done_percent = Round($dw_bytes_raw / $total_bytes_raw * 100, 1)

        $progress_txt = $dw & " / " & $total & " (" & $done_percent & "%)" 

        If $total_bytes_raw > 0 Then
            $progress_callback_func($progress_txt, $dw_bytes_raw, $total_bytes_raw)
        EndIf
        
    Until InetGetInfo($dwHandle, $INET_DOWNLOADCOMPLETE)

    Local $aData = InetGetInfo($dwHandle)
    If @error Or $aData[$INET_DOWNLOADSIZE] <= 0 Then
        FileDelete($file)
        Return False ; If an error occurred then return from the function and delete the file.
    EndIf

    InetClose($dwHandle)

    ;Debugging
    ;_ArrayDisplay($aData)

    Return True
EndFunc

Func BytesToAppropriateUnit($bytes)
    Local $unit = ""

    If $bytes < 1024 Then
        ; Bytes
        $unit = Lang("units.b")
    ElseIf $bytes < 1048576 Then
        ; KB
        $bytes = $bytes / 1024
        $unit = Lang("units.kb")
    ElseIf $bytes < 1073741824 Then
        ; MB
        $bytes = $bytes / 1048576
        $unit = Lang("units.mb")
    Else
        ; GB
        $bytes = $bytes / 1073741824
        $unit = Lang("units.gb")
    EndIf

    $ob = ObjCreate("Scripting.Dictionary")
    $ob.Add("mem_size_amount", LangNum(Round($bytes, 2)))
    $ob.Add("mem_size_unit", $unit)
    
    return LangDynamic("labels_dynamic.mem_size", $ob)
EndFunc
