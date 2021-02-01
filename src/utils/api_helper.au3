#include-once
#include "read_config.au3"
#include <JSON.au3>
#include "../gui/extras.au3"

Global $api_data
Global $versions_api_data

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

Func InitAPIData()
    $api_url = Config_GetAPIEndpoint() & Config_GetAPIIndex()
    $response = HttpGet($api_url)
    $api_data = Json_Decode($response)

    ; Now load up the versions API as well.
    $versions_api_url = API_GetVAPIEndpoint() & API_GetVAPIIndex()
    $response = HttpGet($versions_api_url)
    $versions_api_data = Json_Decode($response)
EndFunc

Func APIGet($path)
    Return Json_Get($api_data, "." & $path)
EndFunc

Func VAPIGet($path)
    Return Json_Get($versions_api_data, "." & $path)
EndFunc

Func API_GetVAPIEndpoint()
    return APIGet("versions_api.endpoint")
EndFunc

Func API_GetVAPIIndex()
    return APIGet("versions_api.index")
EndFunc

Func API_GetLatestFullVersionJSON()
    $latest_full_version = APIGet("modpack.latest.full.version")

    $versions_array = Json_ObjGet($versions_api_data, "versions")
    For $i = 0 To UBound($versions_array) - 1
        $ver_num = Json_ObjGet($versions_array[$i], "version")
        If ($ver_num == $latest_full_version) Then
            ;$incremental_only = Json_ObjGet($versions_array[$i], "incremental_only")
            
            ;If ($incremental_only) Then
                
            ;EndIf

            $url = Json_ObjGet($versions_array[$i], "url")
            
            If Json_IsNull($url) Then
                If VAPIGet("api.url_from_name_if_null") Then
                    $url = API_GetVAPIEndpoint() & $ver_num & "/" & VAPIGet("api.index_if_null")
                Else
                    UnexpectedExitErrorMsgBox()
                    Exit
                EndIf
            EndIf

            $response = HttpGet($url)
            Return Json_Decode($response)
        EndIf
    Next


EndFunc


