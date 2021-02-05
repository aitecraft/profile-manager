#include-once
#include <JSON.au3>
#include "lang_manager.au3"

Global Const $configFileName = "resources/config.json"
Global Const $prefsFileName = "resources/prefs.json"
Global $config = 0
Global $prefs = 0

; Helper Function for reading from prefs before config
Func GetPref($prefsPath, $configPath)
    $prefsVal = json_get($prefs, $prefsPath)
    If (@error == 1 And @extended == 0) Or Json_IsNull($prefsVal) Then
        Return Json_Get($config, $configPath)
    Else
        Return $prefsVal
    EndIf
EndFunc

; Initialize Config Data
Func LoadConfig()
    $config = json_decode(FileRead($configFileName))
    $prefs = json_decode(FileRead($prefsFileName))
EndFunc

; API Root URL
Func Config_GetAPIEndpoint()
    return json_get($config, '.api.endpoint')
EndFunc

Func Config_GetAPIIndex()
    return json_get($config, '.api.index')
EndFunc

; Minecraft Installation Directory
Func Config_GetMCDir()
    ;Local $mc_dir = json_get($config, '.default_mc_dir')
    Local $mc_dir = GetPref('.mc_dir', '.default_mc_dir')
    return StringReplace($mc_dir, '<appdata>', @AppDataDir)
EndFunc

Func Config_GetLang()
    return GetPref('.language', '.default_lang')
EndFunc

; Profile Name
Func Config_Profile_GetName()
    return Lang('general.custom_profile')
EndFunc

; Profile ID (just needs to be unique, used only by launcher)
Func Config_Profile_GetID()
    return json_get($config, '.profile.main.id')
EndFunc

; Profile Directory (mods, saves and settings files are all inside this directory)
Func Config_Profile_GetDir()
    Local $profile_dir = json_get($config, '.profile.main.dir')
    return StringReplace(StringReplace($profile_dir, '<mc_dir>', Config_GetMCDir()), '<appdata>', @AppDataDir)
EndFunc

; Maximum Memory Allocated to the Java VM.
Func Config_Profile_GetJVM_XMX()
    return GetPref('.jvm_xmx', '.profile.jvm.default_xmx')
EndFunc

; Memory Allocated to the Java VM Stack.
Func Config_Profile_GetJVM_XMS()
    return GetPref('.jvm_xms', '.profile.jvm.default_xms')
EndFunc

; Arguments passed to the Java VM.
Func Config_Profile_GetJVM_Args()
    return json_get($config, '.profile.jvm.args')
EndFunc

; Base64 Encoded Image, to be used as an icon in the Official Minecraft Launcher
Func Config_Profile_GetIcon()
    return FileRead(json_get($config, '.profile.misc.encoded_icon_file'))
EndFunc

Func Config_Proprietary_ChangeSkin()
    return json_get($config, '.proprietary.change_skin_option')
EndFunc

Func Config_Proprietary_AitecraftLauncherImport()
    return json_get($config, '.proprietary.aitecraft_launcher_import')
EndFunc

Func Config_Proprietary_OpenSchematicsFolderOption()
    return json_get($config, '.proprietary.open_schematics_folder_option')
EndFunc
