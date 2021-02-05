#include-once
#include <JSON.au3>
#include "api_helper.au3"

Global $version_data
Global $current_version

Func Version_SetVersionData($json_object, $version)
    $version_data = $json_object
    $current_version = $version
EndFunc

Func Version_SetDataToLatestFull()
    If (StringCompare($version, "latest_full") == 0) Then
        Return
    EndIf
    $version_data = API_GetLatestFullVersionJSON()
    $version = "latest_full"
EndFunc

Func Version_SetDataToLatestIncremental()
    If (StringCompare($version, "latest_inc") == 0) Then
        Return
    EndIf
    $version_data = API_GetLatestIncrementalVersionJSON()
    $version = "latest_inc"
EndFunc

Func Version_GetOptiFineURL()
    return VDataGet("optimizer_mod.optifine.url")
EndFunc

;Func Version_Download

Func VDataGet($path)
    return Json_Get($version_data, "." & $path)
EndFunc
