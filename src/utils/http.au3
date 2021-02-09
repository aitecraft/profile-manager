#include-once

Func HttpGet($url, $data = "")
    Const $HTTP_STATUS_OK = 200

    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

    $oHTTP.Open("GET", $url & "?" & $data, False)
    If (@error) Then Return SetError(1, 0, 0)

    $oHTTP.Send()
    If (@error) Then Return SetError(2, 0, 0)

    If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)

    Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc
