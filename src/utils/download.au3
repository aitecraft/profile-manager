#include-once
#include <InetConstants.au3>
#include <Array.au3>
#include <Math.au3>
#include "lang_manager.au3"
#include "misc.au3"
#include "../gui/extras.au3"

Func DownloadFileBulk(ByRef $url_list, ByRef $file_list, $progress_callback_func, $callback_timer = 400)
    
    ; Ensure Arrays are of same size, and also array size > 0
    $list_size = UBound($url_list)
    If ($list_size <> UBound($file_list)) Or ($list_size <= 0) Then
        UnexpectedExitErrorMsgBox()
        Exit
    EndIf

    ; Array of Download handles
    Local $dw_handles[$list_size]

    ; Start Downloading
    For $i = 0 To $list_size - 1
        CreateFolderFromFilePath($file_list[$i])

        $dw_handles[$i] = InetGet($url_list[$i], $file_list[$i], 0, $INET_DOWNLOADBACKGROUND)
    Next

    ; Progress Callbacks
    Do
        Sleep($callback_timer)
        Local $dw_bytes_raw = 0
        Local $total_bytes_raw = 0
        $done = True
        
        For $i = 0 To $list_size - 1
            $dw_bytes_raw += InetGetInfo($dw_handles[$i], $INET_DOWNLOADREAD)
            $total_bytes_raw += InetGetInfo($dw_handles[$i], $INET_DOWNLOADSIZE)
            $done = $done And InetGetInfo($dw_handles[$i], $INET_DOWNLOADCOMPLETE)
        Next

        $dw = DownloadProgress_BytesToAppropriateUnit($dw_bytes_raw)
        $total = DownloadProgress_BytesToAppropriateUnit($total_bytes_raw)
        $done_percent = Round($dw_bytes_raw / $total_bytes_raw * 100, 1)

        $progress_txt = $dw & " / " & $total & " (" & $done_percent & "%)" 

        If $total_bytes_raw > 0 Then
            $progress_callback_func($progress_txt, $dw_bytes_raw, $total_bytes_raw)
        EndIf


    Until $done

    ; Check if any file failed to download
    ; and close handles
    For $i = 0 To $list_size - 1
        Local $aData = InetGetInfo($dw_handles[$i])
        If @error Or $aData[$INET_DOWNLOADSIZE] <= 0 Then
            FileDelete($file_list[$i])
            Return False ; If an error occurred then return from the function and delete the file.
        EndIf
        
        InetClose($dw_handles[$i])
    Next

    ; If everything was downloaded, return true
    Return True
    
EndFunc

Func DownloadFile($url, $file, $progress_callback_func)

    CreateFolderFromFilePath($file)

    Local $dwHandle = InetGet($url, $file, 0, $INET_DOWNLOADBACKGROUND)

    Do
        Sleep(200)
        $dw_bytes_raw = InetGetInfo($dwHandle, $INET_DOWNLOADREAD)
        $total_bytes_raw = InetGetInfo($dwHandle, $INET_DOWNLOADSIZE)

        $dw = DownloadProgress_BytesToAppropriateUnit($dw_bytes_raw)
        $total = DownloadProgress_BytesToAppropriateUnit($total_bytes_raw)
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

Func DownloadProgress_BytesToAppropriateUnit($bytes)
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

    return Round($bytes, 2) & " " & $unit

EndFunc
