#include-once
#include "../utils/update.au3"
#include "../utils/lang_manager.au3"
#include "extras.au3"
#include "status_bar.au3"
#include <StaticConstants.au3>

Func OnClick_StartButton()
    Status_SetPleaseWait()

    $res = InstallOrUpdate(False, False, False, Status_DownloadCallback)

    Status_Hide()

    If $res == "uptodate" Then
        QuickOKMsgBox_Lang("update_done.uptodate")
    ElseIf $res Then
        QuickOKMsgBox_Lang("update_done.success")
    Else
        ;0x10 - Error Icon
        QuickOKMsgBox_Lang("update_done.failure",0x10)
    EndIf
EndFunc

Func MainWindowStartButton()
    $startButton = GUICtrlCreateButton(Lang("buttons.start"), 100, 20, 150, 80)
    GUICtrlSetOnEvent(-1, "OnClick_StartButton")
EndFunc