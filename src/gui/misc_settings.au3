#include-once
#include "extras.au3"
#include "../utils/update.au3"
#include "../utils/read_config.au3"
#include "profile_import.au3"

Func MainWindowMiscSettings($top)
    MS_CreateGroup($top)
    MS_CreateButtons($top + 18)

    If Config_GUIGet_Misc_Import() Then
        Return $top + 110
    Else
        Return $top + 70
    EndIf
EndFunc

Func MS_CreateGroup($top)
    $height = 60
    If Config_GUIGet_Misc_Import() Then $height = 100
    GUICtrlCreateGroup(Lang("labels.misc_settings"), 5, $top, 340, $height)
EndFunc

Func MS_CreateButtons($top)
    
    GUICtrlCreateButton(Lang("buttons.reinstall_fabric"), 20, $top, 150, 30)
    GUICtrlSetOnEvent(-1, "MS_ReinstallFabric")
    
    If Not Config_GUIGet_Misc_ReinstallFabric() Then
        GUICtrlSetState(-1, 128)
    EndIf

    ; ----------------------------------------

    GUICtrlCreateButton(Lang("buttons.verify_files"), 180, $top, 150, 30)
    GUICtrlSetOnEvent(-1, "MS_VerifyFiles")
    
    If Not Config_GUIGet_Misc_VerifyFiles() Then
        GUICtrlSetState(-1, 128)
    EndIf

    ; ----------------------------------------

    If Config_GUIGet_Misc_Import() Then
        GUICtrlCreateButton(Lang("buttons.import_profile"), 100, $top + 40, 150, 30)
        GUICtrlSetOnEvent(-1, "MS_ImportProfile")
    EndIf

EndFunc

Func MS_ReinstallFabric()
    $res = InstallOrUpdate(True, False, True, Status_DownloadCallback)

    If $res Then
        QuickOKMsgBox_Lang("fabric_reinstall_done.success")
    Else
        ;0x10 - Error Icon
        QuickOKMsgBox_Lang("fabric_reinstall_done.failure",0x10)
    EndIf
EndFunc

Func MS_VerifyFiles()
    $res = InstallOrUpdate(True, True, False, Status_DownloadCallback)

    If $res Then
        QuickOKMsgBox_Lang("file_verify_done.success")
    Else
        ;0x10 - Error Icon
        QuickOKMsgBox_Lang("file_verify_done.failure",0x10)
    EndIf
EndFunc

Func MS_ImportProfile()
    Import_Dlg_Create()
EndFunc
