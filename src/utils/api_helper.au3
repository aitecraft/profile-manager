#include-once
#include "read_config.au3"
#include <JSON.au3>
#include "../gui/extras.au3"
#include "end_program.au3"
#include "json_io.au3"
#include "log.au3"

Global $api_data
Global Const $supported_api_format_version = -2
Global $api_initialized = False

Func InitAPIData()
    LogWrite("[API] Initializing...")
    $api_url = Config_GetAPIEndpoint()
    LogWrite("[API] Loading from " & $api_url)
    
    $api_data = Json_FromURL($api_url, True)
    $api_initialized = True

    LogWrite("[API] Initialized.")

    ; Ensure API Format Version is supported
    If (APIGet("metadata.api_format_version") <> $supported_api_format_version) Then
        $api_initialized = False
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
    return APIGet("files_api_endpoint")
EndFunc

Func API_GetModrinthAPIEndpoint()
    return APIGet("modrinth_api_endpoint")
EndFunc

Func API_GetCurseforgeAPIEndpoint()
    return APIGet("curseforge_api_endpoint")
EndFunc

Func API_GetLatestVersion()
    return APIGet("latest_version")
EndFunc

Func API_GetFabric($path)
    return APIGet("fabric." & $path)
EndFunc

Func API_OptimizerExists()
    $query = APIGet("optimizer_mods")
    Return Not (Json_IsNull($query) Or $query == "")
EndFunc

Func API_GetOptimizer($path)
    return APIGet("optimizer_mods." & $path)
EndFunc

Func API_GetLink($path)
    return APIGet("links." & $path)
EndFunc

Func API_GetSrcRepoURL()
    return API_GetLink("source_repo")
EndFunc
