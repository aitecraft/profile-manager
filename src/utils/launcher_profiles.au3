#include-once
#include <JSON.au3>
#include "read_config.au3"
#include "json_io.au3"
#include "log.au3"

Global $launcher_profiles
Global $lp_initialized = False

Global $new_launcher = False

Func LauncherProfiles_Init()
    If Not $lp_initialized Then
        If FileExists(Config_GetMCDir() & "/launcher_profiles_microsoft_store.json") Then
            LogWrite("[PROFILE] Minecraft Launcher for Windows detected!")
            $new_launcher = True
            $launcher_profiles = Json_FromFile(Config_GetMCDir() & "/launcher_profiles_microsoft_store.json")
        Else
            $launcher_profiles = Json_FromFile(Config_GetMCDir() & "/launcher_profiles.json")
        EndIf
    EndIf
EndFunc

Func LauncherProfile_Put($path, $value)
    Json_Put($launcher_profiles, ".profiles." & Config_Profile_GetID() & "." & $path, $value)
EndFunc

Func LauncherProfiles_Update()
    If $new_launcher Then
        Json_ToFile(Config_GetMCDir() & "/launcher_profiles_microsoft_store.json", $launcher_profiles)
    Else
        Json_ToFile(Config_GetMCDir() & "/launcher_profiles.json", $launcher_profiles)
    EndIf
EndFunc
