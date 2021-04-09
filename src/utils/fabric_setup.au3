#include-once
#include "read_config.au3"
#include "client_data.au3"
#include "api_helper.au3"
#include "../gui/extras.au3"
#include "end_program.au3"
#include "download.au3"
#include "json_io.au3"
#include "misc.au3"
#include "launcher_profiles.au3"
#include <JSON.au3>
#include <Array.au3>
#include <FileConstants.au3>

Global $fabric_loader_version_data
Global $mc_version_data
Global $target_loader_version

Func FabricAPI_Init($loader_ver, $mc_ver)
    If $loader_ver = "latest" Then
        $loader_list_url_prototype = API_GetFabric("loader.apis.fabric_loader_list.api_endpoint")
        $loader_list_url = StringReplace($loader_list_url_prototype, "<mc_version>", $mc_ver)

        $loader_list_json = Json_FromURL($loader_list_url)
        $loader_ver = Json_Get($loader_list_json, API_GetFabric("loader.apis.fabric_loader_list.get_latest_version"))
    EndIf

    $target_loader_version = $loader_ver

    $profile_data_url_prototype = API_GetFabric("loader.apis.profile_json.api_endpoint")
    $profile_data_url = StringReplace(StringReplace($profile_data_url_prototype, "<mc_version>", $mc_ver), "<loader_version>", $loader_ver)

    $fabric_loader_version_data = Json_FromURL($profile_data_url)
EndFunc

Func FabricAPI_Get($path)
    return Json_Get($fabric_loader_version_data, "." & $path)
EndFunc

Func MojangAPI_Init($mc_version)
    $ver_manifest = Json_FromURL(API_GetFabric("loader.apis.mojang_mc_version_list.api_endpoint"))
    $ver_list = Json_ObjGet($ver_manifest, "versions")

    For $i = 0 To UBound($ver_list) - 1
        If $mc_version == Json_ObjGet($ver_list[$i], "id") Then
            $mc_version_data = Json_FromURL(Json_ObjGet($ver_list[$i], "url"))
            Return True
        EndIf
    Next

    Fabric_ErrorOutAndExit()
EndFunc

Func MojangAPI_Put($path, $value)
    Json_Put($mc_version_data, "." & $path, $value)
EndFunc

Func MojangAPI_Get($path)
    return Json_Get($mc_version_data, "." & $path)
EndFunc

Func Fabric_ErrorOutAndExit()
    UnexpectedExitErrorMsgBox()
    EndProgram()
EndFunc

Func Fabric_CreateVersionJSONAndJAR()
    MojangAPI_Init(API_GetFabric("loader.mc_version"))
    
    $libs = MojangAPI_Get("libraries")
    _ArrayConcatenate($libs, FabricAPI_Get("libraries"))
    MojangAPI_Put("libraries", $libs)

    MojangAPI_Put("id", FabricAPI_Get("id"))

    MojangAPI_Put("mainClass", FabricAPI_Get("mainClass"))

    MojangAPI_Put("type", "release")

    ; Create Folder if it doesnt exist
    Local $folder = Config_GetMCDir() & "/versions/" & FabricAPI_Get("id") & "/"
    
    CreateFolder($folder)

    ; Empty JAR File
    $jar_file = FileOpen($folder & FabricAPI_Get("id") & ".jar", $FO_OVERWRITE)
    FileWrite($jar_file, "")
    FileClose($jar_file)

    ; Version JSON
    Json_ToFile($folder & FabricAPI_Get("id") & ".json", $mc_version_data)
EndFunc

Func Fabric_UpdateProfile()
    LauncherProfiles_Init()
    
    LauncherProfile_Put("name", Config_Profile_GetName())
    LauncherProfile_Put("gameDir", Config_Profile_GetDir())
    LauncherProfile_Put("javaArgs", Config_Profile_GetJVM_Args())
    LauncherProfile_Put("icon", Config_Profile_GetIcon())
    
    LauncherProfile_Put("lastVersionId", FabricAPI_Get("id"))

    LauncherProfiles_Update()
EndFunc

Func Fabric_InstallOrUpdate()
    If (CD_GetVersion() >= API_GetFabric("last_updated_version")) Then
        ; Already up-to-date
        Return True
    EndIf

    If Not (API_GetFabric("install")) Then
        ; Fabric installation disabled
        Return True
    EndIf

    ; Init Fabric's API Data
    FabricAPI_Init(API_GetFabric("loader.version"), API_GetFabric("loader.mc_version"))
    
    Fabric_CreateVersionJSONAndJAR()

    Fabric_UpdateProfile()

    Return True
EndFunc
