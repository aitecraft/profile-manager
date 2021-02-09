#include-once
#include "read_config.au3"
#include "client_data.au3"
#include "api_helper.au3"
#include "../gui/extras.au3"
#include "end_program.au3"
#include "download.au3"
#include "json_io.au3"
#include <JSON.au3>
#include <Array.au3>

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

Func Fabric_InstallerDWProgress($txt, $done, $total)
    ConsoleWrite($txt & @CRLF)
EndFunc

Func Fabric_GetInstallerCommand()
    ; Base
    $command = "java -jar fabric-installer.jar client -noprofile "
    
    ; Add Directory (-dir) parameter
    $command = $command & '-dir "' & Config_GetMCDir() & '" '
    
    ; Add Snapshot (-snapshot) parameter if targeting snapshots
    If API_GetFabric("loader.snapshot") Then
        $command = $command & "-snapshot "
    EndIf

    ; Add Fabric Loader version (-loader) parameter
    $loader_version = API_GetFabric("loader.version")
    If $loader_version = "latest" Then
        $loader_version = $target_loader_version
    EndIf
    
    $command = $command & '-loader "' & $loader_version & '" ' 
    ; Add Minecraft version (-mcversion) parameter
    $command = $command & '-mcversion "' & API_GetFabric("loader.mc_version") & '"'

    ;ConsoleWrite($command)

    return $command
EndFunc

Func Fabric_FixVersionJSON()
    MojangAPI_Init(API_GetFabric("loader.mc_version"))
    
    $libs = MojangAPI_Get("libraries")
    _ArrayConcatenate($libs, FabricAPI_Get("libraries"))
    MojangAPI_Put("libraries", $libs)

    MojangAPI_Put("id", FabricAPI_Get("id"))

    MojangAPI_Put("mainClass", FabricAPI_Get("mainClass"))

    MojangAPI_Put("type", "release")

    Json_ToFile(Config_GetMCDir() & "/versions/" & FabricAPI_Get("id") & "/" & FabricAPI_Get("id") & ".json", $mc_version_data)
EndFunc

Func Fabric_InstallOrUpdate()
    If (CD_GetVersion() >= API_GetFabric("last_updated_version")) Then
        ; Already up-to-date
        Return False
    EndIf

    If Not (API_GetFabric("install")) Then
        ; Fabric installation disabled
        Return False
    EndIf

    ; Init Fabric's API Data
    FabricAPI_Init(API_GetFabric("loader.version"), API_GetFabric("loader.mc_version"))

    ; Download fabric installer
    $installer_src = API_GetFabric("installer.get_from")
    $download_url = ""

    If $installer_src = "api" Then
        
        $installer_list_json = Json_FromURL(API_GetFabric("installer.api_endpoint"))

        If @error > 0 Then
            Fabric_ErrorOutAndExit()
        EndIf

        If (API_GetFabric("installer.get_version") = "latest") Then
            $download_url = Json_ObjGet($installer_list_json[0], "url") 
        Else
            $found = False
            For $i = 0 To UBound($installer_list_json) - 1
                If Json_ObjGet($installer_list_json[$i], "version") == API_GetFabric("installer.get_version") Then
                    $download_url = Json_ObjGet($installer_list_json[$i], "url")
                    $found = True
                    ExitLoop
                EndIf
            Next

            If Not ($found) Then
                Fabric_ErrorOutAndExit()
            EndIf
        EndIf

    ElseIf $installer_src == "url" Then
        $download_url = API_GetFabric("url")
        If Json_IsNull($download_url) Then
            Fabric_ErrorOutAndExit()
        EndIf
    Else
        Fabric_ErrorOutAndExit()
    EndIf

    ;#cs
    $installer_dw_success = DownloadFile($download_url, "resources/fabric/fabric-installer.jar", Fabric_InstallerDWProgress)

    If Not $installer_dw_success Then
        ; Todo handle this error a bit better. At least a more specific error message
        Fabric_ErrorOutAndExit()
    EndIf
    ;#ce

    $fabric_installer_success = RunWait(@ComSpec & " /c " & Fabric_GetInstallerCommand(), "resources/fabric/", @SW_MAXIMIZE)

    If @error > 0 Then
        Fabric_ErrorOutAndExit()
    EndIf

    ; Todo also check return code
    
    Fabric_FixVersionJSON()

    Return True
EndFunc
