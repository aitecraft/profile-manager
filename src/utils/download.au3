#include-once
#include <InetConstants.au3>
#include <Array.au3>
#include <Math.au3>
#include "lang_manager.au3"

Func DownloadFile($url, $file, $progress_callback_func)

    $lastSlashPos = _Max(StringInStr($file, "/", 1, -1), StringInStr($file, "\", 1, -1))
    
    If $lastSlashPos > 0 Then
        $folder = StringLeft($file, $lastSlashPos)
        If Not FileExists($folder) Then
            DirCreate($folder)
        EndIf
    EndIf

    Local $dwHandle = InetGet($url, $file, 0, $INET_DOWNLOADBACKGROUND)

    Do
        Sleep(200)
        $dw_bytes_raw = InetGetInfo($dwHandle, $INET_DOWNLOADREAD)
        $total_bytes_raw = InetGetInfo($dwHandle, $INET_DOWNLOADSIZE)

        $dw = DownloadProgress_BytesToAppropriateUnit($dw_bytes_raw)
        $total = DownloadProgress_BytesToAppropriateUnit($total_bytes_raw)
        $done_percent = Round($dw_bytes_raw / $total_bytes_raw * 100, 1)

        $progress_txt = $dw & " / " & $total & " (" & $done_percent & "%)" 

        If $total > 0 Then
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
