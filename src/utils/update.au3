#include-once
#include "api_helper.au3"
#include "client_data.au3"
#include "fabric_setup.au3"
#include "files_api_helper.au3"
#include "../gui/optimizer_mod.au3"
#include <JSON.au3>

Func InstallOrUpdate($forced = False, $forcedFiles = False, $forcedFabric = False, $filesDownloadCallback = "")
    ; If Optimizer Mod is set to null, make user set optimizer mod first.
    $om_val = CD_GetOptimizerMod()
    If Json_IsNull($om_val) Or $om_val == "" Then
        OM_Dlg_Create()
    EndIf

    If Not $forced Then
        If (CD_GetVersion() >= API_GetLatestVersion()) Then
            ; Already up-to-date
            Return 'uptodate'
        EndIf
    EndIf

    ; If Optimizer Mod last updated has changed, AND if the previous mod no longer exists in API, make user set optimizer mod,
    If (CD_GetVersion() < API_GetOptimizer("last_updated_version")) Then
        ; Find Mod ID in API
        Local $found = False

        For $mod In API_GetOptimizer("options")
            If CD_GetOptimizerMod() == $mod Then
                $found = True
                ExitLoop
            EndIf
        Next

        If Not $found Then
            OM_Dlg_Create()
        EndIf
    EndIf
    
    ;#cs
    $fabric = Fabric_InstallOrUpdate($forcedFabric)
    If Not $fabric Then
        Return False
    EndIf
    ;#ce

    $files = FAPI_InstallOrUpdate($forcedFiles, $filesDownloadCallback)
    If $files Then
        CD_SetVersion(API_GetLatestVersion())
    Else
        CD_ClearFilesList()
    EndIf

    ;CD_ClearFilesList()
    
    CD_UpdateFile()
    Return $files
EndFunc