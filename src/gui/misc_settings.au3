#include-once
#include "extras.au3"
#include "../utils/update.au3"

Func MainWindowMiscSettings($top)
    MS_CreateGroup($top)
    MS_CreateButtons($top + 18)
    ; Verify files button
    ; Reinstall fabric button
    ; Optimizer mod change button [no, move to its own section]
    ; Both will just call the files API
    ; add check to files api if a file ver > api's latest ver cuz that would mean fapi&api out of sync
    ; or allow re init of API
EndFunc

Func MS_CreateGroup($top)
    GUICtrlCreateGroup(Lang("labels.misc_settings"), 5, $top, 340, 60)
EndFunc

Func MS_CreateButtons($top)
    GUICtrlCreateButton(Lang("buttons.reinstall_fabric"), 20, $top, 150, 30)
    GUICtrlSetOnEvent(-1, "MS_ReinstallFabric")
    GUICtrlCreateButton(Lang("buttons.verify_files"), 180, $top, 150, 30)
    GUICtrlSetOnEvent(-1, "MS_VerifyFiles")
EndFunc

Func MS_ReinstallFabric()
    Status_SetPleaseWait()

    $res = InstallOrUpdate(True, False, True, Status_DownloadCallback)

    Status_Hide()

    If $res Then
        QuickOKMsgBox_Lang("fabric_reinstall_done.success")
    Else
        ;0x10 - Error Icon
        QuickOKMsgBox_Lang("fabric_reinstall_done.failure",0x10)
    EndIf
EndFunc

Func MS_VerifyFiles()
    Status_SetPleaseWait()

    $res = InstallOrUpdate(True, True, False, Status_DownloadCallback)

    Status_Hide()

    If $res Then
        QuickOKMsgBox_Lang("file_verify_done.success")
    Else
        ;0x10 - Error Icon
        QuickOKMsgBox_Lang("file_verify_done.failure",0x10)
    EndIf
EndFunc
