#include-once
#include <GUIConstantsEx.au3>
#include "../utils/lang_manager.au3"
#include "menu_bar.au3"
#include "../utils/end_program.au3"

Global $hMainGui = 0

Func CreateMainWindow()
    $hMainGui = GUICreate(Lang('general.app_title'), 700, 550)
    GUISetOnEvent($GUI_EVENT_CLOSE, "CloseApp")

    MainWindowMenuBar()
EndFunc

Func ShowMainWindow()
    GUISetState(@SW_SHOW, $hMainGUI)
EndFunc

Func HideMainWindow()
    GUISetState(@SW_HIDE, $hMainGUI)
EndFunc

Func CloseApp()
    EndProgram()
EndFunc

Func ReloadApp()
    HideMainWindow()
    EndProgram(False)
    GUIDelete($hMainGui)
    CreateMainWindow()
    ShowMainWindow()
EndFunc
