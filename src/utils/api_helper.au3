#include-once
#include "read_config.au3"
#include <JSON.au3>
#include "../gui/extras.au3"
#include "end_program.au3"

Global $api_data
Global $files_api_data
Global Const $supported_api_format_version = 1

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

    ; Ensure API Format Version is supported
    If (APIGet("metadata.api_format_version") <> $supported_api_format_version) Then
        UnsupportedAPIFormatVersionMsgBox()
        EndProgram()
    EndIf

    ; Now load up the files API as well.
    $files_api_url = API_GetFAPIEndpoint() & API_GetFAPIIndex()
    $response = HttpGet($files_api_url)
    $files_api_data = Json_Decode($response)
EndFunc

Func APIGet($path)
    Return Json_Get($api_data, "." & $path)
EndFunc

Func FAPIGet($path)
    Return Json_Get($files_api_data, "." & $path)
EndFunc

Func API_GetFAPIEndpoint()
    return APIGet("files_api.endpoint")
EndFunc

Func API_GetFAPIIndex()
    return APIGet("files_api.index")
EndFunc

Func API_GetLatestVersion()
    return APIGet("latest_version")
EndFunc

Func API_GetFabric($path)
    return APIGet("fabric." & $path)
EndFunc

Func API_GetOptimizer($path)
    return APIGet("optimizer_mods." & $path)
EndFunc

#cs
 Func API_GetLatestFullVersionJSON()
    $latest_full_version = APIGet("modpack.latest.full.version")
    return VAPI_GetSpecificVersionJSON($latest_full_version)
EndFunc

Func VAPI_GetSpecificVersionJSON($version)
    $versions_array = Json_ObjGet($files_api_data, "versions")
    For $i = 0 To UBound($versions_array) - 1
        $ver_num = Json_ObjGet($versions_array[$i], "version")
        If ($ver_num == $version) Then
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

Func API_GetLatestIncrementalVersionJSON()
    $latest_inc_version = APIGet("modpack.latest.incremental.version")
    return VAPI_GetSpecificVersionJSON($latest_inc_version)
EndFunc
 
#ce