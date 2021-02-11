#include-once
#include "../utils/update.au3"
#include "../utils/lang_manager.au3"
#include "extras.au3"


Func OnClick_StartButton()
    $res = InstallOrUpdate()

    If $res == "uptodate" Then
        QuickOKMsgBox_Lang("update_done.uptodate")
    ElseIf $res Then
        QuickOKMsgBox_Lang("update_done.success")
    Else
        QuickOKMsgBox_Lang("update_done.failure",0x10)
    EndIf
EndFunc

Func MainWindowButtons()
    $startButton = GUICtrlCreateButton(Lang("buttons.start"), 100, 20, 150, 80)
    GUICtrlSetOnEvent(-1, "OnClick_StartButton")
EndFunc
