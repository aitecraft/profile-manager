#include-once
#include "log.au3"
#include "../gui/extras.au3"

Func HttpGet($url)
    Const $HTTP_STATUS_OK = 200

    LogWrite("[HTTP] Request URL: " & $url)

    Local $oError = ObjEvent("AutoIt.Error", "HttpErrFunc")
    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

    $oHTTP.Open("GET", $url, False)
    If (@error) Then Return SetError(1, 0, 0)

    $oHTTP.Send()
    If (@error) Then Return SetError(2, 0, 0)

    If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)

    LogWrite("[HTTP] Response OK")

    Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc

Func HttpErrFunc($oError)
    LogWrite("[HTTP] [ERROR] COM Error during HTTP Request!")
    LogWrite("[HTTP] [ERROR] Number: 0x" & Hex($oError.number, 8))
    LogWrite("[HTTP] [ERROR] Description: " & $oError.description)
    LogWrite("[HTTP] [ERROR] Win Description: " & $oError.windescription)
    LogWrite("[HTTP] [ERROR] Line: " & $oError.scriptline)
    
    HTTPErrorMsgBox()
    Exit
EndFunc
