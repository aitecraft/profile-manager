#include-once
#include "api_helper.au3"
#include "client_data.au3"
#include "fabric_setup.au3"
#include "files_api_helper.au3"

Func InstallOrUpdate()
    If (CD_GetVersion() >= API_GetLatestVersion()) Then
        ; Already up-to-date
        Return 'uptodate'
    EndIf
    
    ;#cs
    $fabric = Fabric_InstallOrUpdate()
    If Not $fabric Then
        Return False
    EndIf
    ;#ce

    $files = FAPI_InstallOrUpdate()
    If $files Then
        CD_SetVersion(API_GetLatestVersion())
    Else
        CD_ClearFilesList()
    EndIf

    ;CD_ClearFilesList()
    
    CD_UpdateFile()
    Return $files
EndFunc