#include-once
#include "read_config.au3"
#include "client_data.au3"
#include "api_helper.au3"
#include "../gui/extras.au3"
#include "../gui/status_bar.au3"
#include "end_program.au3"
#include "download.au3"
#include "json_io.au3"
#include "misc.au3"
#include "launcher_profiles.au3"
#include "log.au3"
#include <JSON.au3>
#include <Array.au3>
#include <FileConstants.au3>

Global $fabric_loader_version_data
Global $mc_version_data

Func FabricAPI_Init()
    $profile_data_url = API_GetFabric("loader.profile_json")
    $fabric_loader_version_data = Json_FromURL($profile_data_url)
EndFunc

Func FabricAPI_Get($path)
    return Json_Get($fabric_loader_version_data, "." & $path)
EndFunc

Func MojangAPI_Init($mc_version)
    LogWrite("[FABRIC INSTALL] Loading data from Mojang API for " & $mc_version)

    $ver_manifest = Json_FromURL(API_GetFabric("loader.version_manifest"))
    $ver_list = Json_ObjGet($ver_manifest, "versions")

    For $i = 0 To UBound($ver_list) - 1
        If $mc_version == Json_ObjGet($ver_list[$i], "id") Then
            $mc_version_data = Json_FromURL(Json_ObjGet($ver_list[$i], "url"))
            Return True
        EndIf
    Next
    
    UnexpectedExitErrorMsgBox("fabric_setup.au3 -> MojangAPI_Init", "mc_no_matching_version_found", $mc_version)
    EndProgram()
EndFunc

Func MojangAPI_Put($path, $value)
    Json_Put($mc_version_data, "." & $path, $value)
EndFunc

Func MojangAPI_Get($path)
    return Json_Get($mc_version_data, "." & $path)
EndFunc

Func Fabric_CreateVersionJSONAndJAR()
    LogWrite("[FABRIC INSTALL] Installing Fabric version - " & FabricAPI_Get("id"))

    MojangAPI_Init(FabricAPI_Get("inheritsFrom"))
    
    $libs = MojangAPI_Get("libraries")
    _ArrayConcatenate($libs, FabricAPI_Get("libraries"))
    MojangAPI_Put("libraries", $libs)

    $game_args = MojangAPI_Get("arguments.game")
    _ArrayConcatenate($game_args, FabricAPI_Get("arguments.game"))
    MojangAPI_Put("arguments.game", $game_args)

    $jvm_args = MojangAPI_Get("arguments.jvm")
    _ArrayConcatenate($jvm_args, FabricAPI_Get("arguments.jvm"))
    MojangAPI_Put("arguments.jvm", $jvm_args)

    MojangAPI_Put("id", FabricAPI_Get("id"))

    MojangAPI_Put("mainClass", FabricAPI_Get("mainClass"))

    MojangAPI_Put("releaseTime", FabricAPI_Get("releaseTime"))

    MojangAPI_Put("time", FabricAPI_Get("time"))

    MojangAPI_Put("type", "release")

    ; Create Folder if it doesnt exist
    Local $folder = Config_GetMCDir() & "/versions/" & FabricAPI_Get("id") & "/"
    
    CreateFolder($folder)

    ; JAR File
    $jar_file_name = $folder & FabricAPI_Get("id") & ".jar"

    If Config_GetCreateEmptyJAR() Then
        $jar_file = FileOpen($jar_file_name, $FO_OVERWRITE)
        FileWrite($jar_file, "")
        FileClose($jar_file)
    Else
        ; Delete JAR File in case it already exists
        FileDelete($jar_file_name)
    EndIf

    ; Version JSON
    Json_ToFile($folder & FabricAPI_Get("id") & ".json", $mc_version_data)
    LogWrite("[FABRIC INSTALL] Created version JSON")

EndFunc

Func Fabric_UpdateProfile()
    LauncherProfiles_Init()
    
    LauncherProfile_Put("name", Config_Profile_GetName())
    LauncherProfile_Put("gameDir", Config_Profile_GetDir())
    LauncherProfile_Put("javaArgs", Config_Profile_GetJVM_Args())
    LauncherProfile_Put("icon", Config_Profile_GetIcon())
    
    LauncherProfile_Put("lastVersionId", FabricAPI_Get("id"))

    LauncherProfiles_Update()

    LogWrite("[FABRIC INSTALL] Updated " & Config_Profile_GetID() & " launcher profile")
EndFunc

Func Fabric_InstallOrUpdate($forced = False)
    LogWrite("[FABRIC INSTALL] Checking for update...")
    If Not $forced Then
        If (CD_GetVersion() >= API_GetFabric("last_updated_version")) Then
            ; Already up-to-date
            LogWrite("[FABRIC INSTALL] Up-to-date")
            
            Return True
        EndIf
    EndIf

    If Not (API_GetFabric("install")) Then
        LogWrite("[FABRIC INSTALL] Fabric installation disabled by API.")
        ; Fabric installation disabled
        Return True
    EndIf

    LogWrite("[FABRIC INSTALL] Initializing Fabric installation...")
    Status_SetInstallingFabric()


    ; Init Fabric's API Data
    FabricAPI_Init()
    
    Fabric_CreateVersionJSONAndJAR()

    Fabric_UpdateProfile()

    LogWrite("[FABRIC INSTALL] Finished installing Fabric.")


    Return True
EndFunc
