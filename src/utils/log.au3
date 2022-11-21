#include-once
#include <FileConstants.au3>
#include <Date.au3>

Global $logfile
Const $logFileLocation = "resources/pm.log"

Func InitLog()
    $logfile = FileOpen($logFileLocation, $FO_APPEND)
    LogWriteLineRaw("---------------- START OF LOG ----------------")
    LogWriteLineRaw("Profile Manager Log - Started @ " & _Now())
EndFunc

Func EndLog()
    LogWriteLineRaw("Profile Manager Log - Stopped @ " & _Now())
    LogWriteRaw("----------------  END OF LOG  ----------------" & @CRLF & @CRLF)
    FileClose($logfile)
EndFunc

Func LogWrite($text, $end = @CRLF)
    StringReplace($text, @CRLF, " \n ")
    LogWriteRaw("[" & _Now() & "] " & $text & $end)
EndFunc

Func LogWriteRaw($text)
    FileWrite($logfile, $text)
EndFunc

Func LogWriteLineRaw($text)
    LogWriteRaw($text & @CRLF)
EndFunc
