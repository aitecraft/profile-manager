#include-once
#include "api_helper.au3"
#include "json_io.au3"
#include <StringConstants.au3>
#include <JSON.au3>

Global $files_api_data

Func FAPI_Init()
    $files_api_url = API_GetFAPIEndpoint() & API_GetFAPIIndex()
    $files_api_data = Json_FromURL($files_api_url)
EndFunc

Func FAPI_GetFromFilePath($path)
    ; Todo work on situation where this $path doesnt exist in the Files API
    ; probably return with seterror or something
    
    $obj = Json_ObjGet($files_api_data, $path)
    
    If @error = 1 Then
        Return False
    EndIf
    Return $obj
EndFunc

Func FAPI_DeleteFromFilePath($path)
    Json_ObjDelete($files_api_data, $path)
EndFunc

Func FAPI_InstallOrUpdate()
    If (CD_GetVersion() >= API_GetFabric("last_updated_version")) Then
        ; Already up-to-date
        Return False
    EndIf
EndFunc
