#include-once
#include <JSON.au3>
#include "lang_manager.au3"
#include "json_io.au3"
#include "misc.au3"
#include "log.au3"

Global Const $configFileName = "resources/config.json"
Global Const $prefsFileName = "resources/prefs.json"
Global $config = 0
Global $prefs = 0

; Helper Function for reading from prefs before config
Func GetPref($prefsPath, $configPath)
    $prefsVal = json_get($prefs, $prefsPath)
    If (@error == 1 And @extended == 0) Or Json_IsNull($prefsVal) Then
        ; Doesn't exist in prefs JSON
        ; Get default value from config
        $confVal = Json_Get($config, $configPath)
        ; Add value to prefs
        Json_Put($prefs, $prefsPath, $confVal)
        ; Log
        LogWrite("[PREFS] Initialized " & $prefsPath & " to default value of " & $confVal)
        ; Return
        Return $confVal
    Else
        Return $prefsVal
    EndIf
EndFunc

; Initialize Config Data
Func LoadConfig()
    LogWrite("[CONFIG] Loading config file - " & $configFileName)
    $config = Json_FromFile($configFileName, True)
    LogWrite("[CONFIG] Loaded config file.")

    LogWrite("[CONFIG] Loading prefs file - " & $prefsFileName)
    
    ; Strip comments from prefs.json even though it is a generated file
    ; Users may modify it and add comments, so we may have to strip them
    ; Comments will be lost when the application exits.
    $prefs = Json_FromFile($prefsFileName, True)
    
    LogWrite("[CONFIG] Loaded prefs file.")
    
    LogWrite("[CONFIG] Minecraft Directory: " & Config_GetMCDir())
    LogWrite("[CONFIG] Profile ID: " & Config_Profile_GetID())
    LogWrite("[CONFIG] Profile Directory: " & Config_Profile_GetDir())
EndFunc

; API Root URL
Func Config_GetAPIEndpoint()
    return json_get($config, '.api_endpoint')
EndFunc

; Minecraft Installation Directory
Func Config_GetMCDir()
    ;Local $mc_dir = json_get($config, '.default_mc_dir')
    Local $mc_dir = GetPref('.mc_dir', '.defaults.mc_dir')
    return StringReplace($mc_dir, '<appdata>', @AppDataDir)
EndFunc

Func Config_GetLang()
    return GetPref('.language', '.defaults.lang')
EndFunc

; Profile Name
Func Config_Profile_GetName()
    ; Crude Support for old Minecraft Launchers
    ; Old MC Launchers seem to not support a different value for Profile ID and Profile Name.
    ; So we'll just set the name to the profile ID.
    If Config_GetProfileNameIsID() Then
        return Config_Profile_GetID()
    EndIf

    return Lang('general.custom_profile')
EndFunc

Func Config_GetProfileNameIsID()
    return GetPref('.profile_name_is_id', '.defaults.compatibility.profile_name_is_id')
EndFunc

Func Config_GetCreateEmptyJAR()
    return GetPref('.create_empty_jar', '.defaults.compatibility.create_empty_jar')
EndFunc

Func Config_GetStrictHashCheck()
    return GetPref('.strict_hash_check', '.defaults.strict_hash_check')
EndFunc

; Profile ID (just needs to be unique, used only by launcher)
Func Config_Profile_GetID()
    return json_get($config, '.profile.id')
EndFunc

; Profile Directory (mods, saves and settings files are all inside this directory)
Func Config_Profile_GetDir($sub_dir = "")
    Local $profile_dir = json_get($config, '.profile.dir')
    If $sub_dir <> "" Then
        $profile_dir &= "\" & $sub_dir
        NormalizePath($profile_dir)
    EndIf
    return StringReplace(StringReplace($profile_dir, '<mc_dir>', Config_GetMCDir()), '<appdata>', @AppDataDir)
EndFunc

Func Config_Profile_GetJVM_Minimum_Heap_Size()
    Return Json_Get($config, '.profile.jvm.minimum_heap_size')
EndFunc

; Maximum Memory Allocated to the Java VM Heap.
Func Config_Profile_GetJVM_Heap_Size()
    return GetPref('.jvm_heap_size', '.defaults.jvm_heap_size')
EndFunc

; Arguments passed to the Java VM.
Func Config_Profile_GetJVM_Args()
    $j_args = json_get($config, '.profile.jvm.args')
    $mem_args = "-Xmx" & Config_Profile_GetJVM_Heap_Size() & "M -Xms" & Config_Profile_GetJVM_Heap_Size() & "M "

    return ($mem_args & $j_args)
EndFunc

; Base64 Encoded Image, to be used as an icon in the Official Minecraft Launcher
Func Config_Profile_GetIcon()
    $icon_file = json_get($config, '.profile.misc.encoded_icon_file')

    If Json_IsNull($icon_file) Or $icon_file = "" Or $icon_file = Null Then
        return Null
    EndIf

    return FileRead($icon_file)
EndFunc

Func Config_Proprietary_Links()
    return json_get($config, '.proprietary.links')
EndFunc

Func Config_Proprietary_Links_Exists()
    $links = Config_Proprietary_Links()
    Return IsArray($links) And UBound($links) >= 1
EndFunc

Func Config_Proprietary_OpenSchematicsFolderOption()
    return json_get($config, '.proprietary.open_schematics_folder_option')
EndFunc

Func Config_GUIGet_OpenFoldersMenu()
    Return Json_Get($config, '.gui.open_folders_menu')
EndFunc

Func Config_GUIGet_OptimizerMod()
    Return Json_Get($config, '.gui.optimizer_mod')
EndFunc

Func Config_GUIGet_Misc_ReinstallFabric()
    Return Json_Get($config, '.gui.misc.reinstall_fabric')
EndFunc

Func Config_GUIGet_Misc_VerifyFiles()
    Return Json_Get($config, '.gui.misc.verify_files')
EndFunc

Func Config_GUIGet_ProfileSettings()
    Return Json_Get($config, '.gui.profile_settings')
EndFunc
