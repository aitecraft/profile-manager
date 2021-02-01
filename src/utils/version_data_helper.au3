#include-once
#include <JSON.au3>
#include "api_helper.au3"

Global $version_data

Func Version_SetVersionData($json_object, $latest = False)
    $version_data = $json_object
EndFunc

Func Version_SetDataToLatestFull()
    $version_data = API_GetLatestFullVersionJSON()
EndFunc

Func Version_GetOptiFineURL()
    return VDataGet("optimizer_mod.optifine.url")
EndFunc

Func VDataGet($path)
    return Json_Get($version_data, "." & $path)
EndFunc
