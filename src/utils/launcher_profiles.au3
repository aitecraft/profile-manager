#include-once
#include <JSON.au3>
#include "read_config.au3"
#include "json_io.au3"

Global $launcher_profiles

Func LauncherProfiles_Init()
    $launcher_profiles = Json_FromFile(Config_GetMCDir() & "/launcher_profiles.json")
EndFunc

Func LauncherProfile_Put($path, $value)
    Json_Put($launcher_profiles, ".profiles." & Config_Profile_GetID() & "." & $path, $value)
EndFunc

Func LauncherProfiles_Update()
    Json_ToFile(Config_GetMCDir() & "/launcher_profiles.json", $launcher_profiles)
EndFunc
