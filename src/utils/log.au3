#include-once
#include <FileConstants.au3>
#include <Date.au3>

Global $logfile
Const $logFileLocation = "resources/pm.log"

Func InitLog()
    $logfile = FileOpen($logFileLocation, $FO_APPEND)
    FileWriteLine($logfile, "---------------- START OF LOG ----------------")
    FileWriteLine($logfile, "Profile Manager Log - Started @ " & _Now())
EndFunc

Func EndLog()
    FileWriteLine($logfile, "Profile Manager Log - Stopped @ " & _Now())
    FileWrite($logfile, "----------------  END OF LOG  ----------------" & @CRLF & @CRLF)
    FileClose($logfile)
EndFunc

Func LogWrite($text)
    FileWrite($logfile, "[" & _Now() & "] " & $text & @CRLF)
EndFunc