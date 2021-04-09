#include-once
#include <GUIConstantsEx.au3>
#include "../utils/lang_manager.au3"
#include "menu_bar.au3"
#include "../utils/end_program.au3"
#include "update_gui.au3"
#include "profile_settings.au3"
#include "misc_settings.au3"
#include "optimizer_mod.au3"

Global $hMainGui

Func CreateMainWindow()
    Global $hMainGui = GUICreate(Lang('general.app_title'), 350, 485)
    GUISetOnEvent($GUI_EVENT_CLOSE, "CloseApp")

    MainWindowMenuBar()
    MainWindowUpdateGUI()
    MainWindowOMSettings(180)
    MainWindowMiscSettings(250)
    MainWindowProfileSettings(320)
EndFunc

Func GetMainWindowHandle()
    Return $hMainGui
EndFunc

Func ShowMainWindow()
    GUISetState(@SW_SHOW, $hMainGUI)
EndFunc

Func HideMainWindow()
    GUISetState(@SW_HIDE, $hMainGUI)
EndFunc

Func FreezeMainWindow()
    GUISetState(@SW_DISABLE, $hMainGUI)
EndFunc

Func UnfreezeMainWindow()
    GUISetState(@SW_ENABLE, $hMainGUI)
    GUISetState(@SW_RESTORE, $hMainGUI)
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
