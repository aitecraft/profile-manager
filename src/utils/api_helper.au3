#include-once
#include "read_config.au3"
#include <JSON.au3>
#include "../gui/extras.au3"
#include "end_program.au3"
#include "json_io.au3"

Global $api_data
Global Const $supported_api_format_version = -10
Global $api_initialized = False

Func InitAPIData()
    $api_url = Config_GetAPIEndpoint() & Config_GetAPIIndex()
    $api_data = Json_FromURL($api_url)
    $api_initialized = True

    ; Ensure API Format Version is supported
    If (APIGet("metadata.api_format_version") <> $supported_api_format_version) Then
        UnsupportedAPIFormatVersionMsgBox()
        EndProgram()
    EndIf

EndFunc

Func APIGet($path)
    If Not $api_initialized Then
        InitAPIData()
    EndIf
    Return Json_Get($api_data, "." & $path)
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

Func API_GetSrcRepoURL()
    return APIGet("other.source_repo")
EndFunc

Func API_GetSkinChangerURL()
    return APIGet("other.skin_changer")
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