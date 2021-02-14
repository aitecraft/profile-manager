#include-once
#include <JSON.au3>
#include "read_config.au3"
#include "json_io.au3"

Global $launcher_profiles
Global $lp_initialized = False

Func LauncherProfiles_Init()
    If Not $lp_initialized Then
        $launcher_profiles = Json_FromFile(Config_GetMCDir() & "/launcher_profiles.json")
    EndIf
EndFunc

Func LauncherProfile_Put($path, $value)
    Json_Put($launcher_profiles, ".profiles." & Config_Profile_GetID() & "." & $path, $value)
EndFunc

Func LauncherProfiles_Update()
    Json_ToFile(Config_GetMCDir() & "/launcher_profiles.json", $launcher_profiles)
EndFunc
