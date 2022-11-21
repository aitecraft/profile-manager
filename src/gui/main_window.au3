#include-once
#include <GUIConstantsEx.au3>
#include "../utils/lang_manager.au3"
#include "menu_bar.au3"
#include "../utils/end_program.au3"
#include "../utils/read_config.au3"
#include "../utils/log.au3"
#include "start_button.au3"
#include "profile_settings.au3"
#include "misc_settings.au3"
#include "optimizer_mod.au3"
#include "status_bar.au3"

Global $hMainGui

Func CreateMainWindow()
    Global $hMainGui = GUICreate(Lang('general.app_title'), 350, 485)
    GUISetOnEvent($GUI_EVENT_CLOSE, "CloseApp")

    ; Set font size
    GUISetFont(LangFontSize())

    MainWindowMenuBar()

    ; GUI
    $top = 20
    
    $top = MainWindowStartButton($top)
    $top = MainWindowStatusBar($top)
    
    If Config_GUIGet_OptimizerMod() Then
        $top = MainWindowOMSettings($top)
    EndIf

    If Config_GUIGet_Misc_ReinstallFabric() Or Config_GUIGet_Misc_VerifyFiles() Or Config_GUIGet_Misc_Import() Then
        $top = MainWindowMiscSettings($top)
    EndIf
    
    If Config_GUIGet_ProfileSettings() Then
        $top = MainWindowProfileSettings($top)
    EndIf

    ; Resize accordingly
    WinMove($hMainGui, "", Default, Default, Default, $top + 25 + 25)
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
    LogWrite("Reloading App...")

    HideMainWindow()
    EndProgram(False)
    GUIDelete($hMainGui)
    CreateMainWindow()
    ShowMainWindow()
EndFunc
