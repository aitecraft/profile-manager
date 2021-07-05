#include-once
#include "main_window.au3"
#include <JSON.au3>
#include "../utils/client_data.au3"
#include "../utils/lang_manager.au3"
#include <ComboConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include "../utils/api_helper.au3"
#include "../utils/update.au3"
#include "extras.au3"

Global $om_mod_label
Global $om_dlg_gui
Global $om_dlg_cbox
Global $om_dlg_desc_label
Global $om_dlg_button
Global $om_dlg_ins_after_close
Global $om_script_pause_end

Func MainWindowOMSettings($top)
    OM_CreateGroup($top)
    OM_CreateLabelAndButton($top + 18)
    Return $top + 70
EndFunc

Func OM_CreateGroup($top)
    GUICtrlCreateGroup(Lang("labels.optimizer_mod"), 5, $top, 340, 60)
EndFunc

Func OM_CreateLabelAndButton($top)
    $om_mod_label = GUICtrlCreateLabel(OM_GetSelectedName(), 15, $top + 8, 150, 20)
    GUICtrlCreateButton(Lang("buttons.change"), 230, $top, 100, 30)
    GUICtrlSetOnEvent(-1, "OM_ChangeButtonClick")
EndFunc

Func OM_ChangeButtonClick()
    OM_Dlg_Create(True, False)
EndFunc

Func _WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
    If BitAND($wParam, 0x0000FFFF) =  $om_dlg_button Then 
        If OM_Dlg_ConfirmButtonOnClick() Then
            $om_script_pause_end = True
            GUIRegisterMsg($WM_COMMAND, "")
        EndIf
    EndIf        
    Return $GUI_RUNDEFMSG
EndFunc

Func OM_Dlg_Create($run_install_after_close = False, $pause_script = True)
    $om_dlg_gui = GUICreate(Lang("labels.optimizer_mod"), 250, 210, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_BORDER), -1, GetMainWindowHandle())

    ; Move GUI to be slightly below center of main window
    $mainpos = WinGetPos(GetMainWindowHandle())
    $xpos = $mainpos[0] + (($mainpos[2]/2) - (250 / 2))
    WinMove($om_dlg_gui, "", $xpos, $mainpos[1] + 200 + 50)

    GUICtrlCreateLabel(Lang("labels.pick_optimizer_mod"), 8, 8, 228, 25)

    $om_dlg_cbox_init_val = ""
    $current_name = OM_GetSelectedName()
    $om_options = API_GetOptimizer("options")

    ; If something is selected
    ; Make sure it exists in API
    For $mod In $om_options
        If CD_GetOptimizerMod() == $mod Then
            $om_dlg_cbox_init_val = $current_name
            ExitLoop
        EndIf
    Next
    
    $om_dlg_cbox = GUICtrlCreateCombo($om_dlg_cbox_init_val, 40, 50, 169, 25, $CBS_DROPDOWNLIST)
    GUICtrlSetOnEvent(-1, "OM_Dlg_ComboChanged")

    ; Add other options 
    For $mod in $om_options
        If CD_GetOptimizerMod() <> $mod Then
            GUICtrlSetData(-1, OM_GetName($mod))
        EndIf
    Next

    ; Mod Description
    $om_dlg_desc_label = GUICtrlCreateLabel(OM_GetSelectedDescription(), 8, 90, 228, 50, $SS_CENTER)

    $om_dlg_button = GUICtrlCreateButton(Lang("buttons.confirm"), 64, 166, 113, 33)
    If Not ($pause_script) Then
        GUICtrlSetOnEvent(-1, "OM_Dlg_ConfirmButtonOnClick")
    EndIf

    $om_dlg_ins_after_close = $run_install_after_close

    FreezeMainWindow()
    GUISetState(@SW_SHOW, $om_dlg_gui)

    If ($pause_script) Then
        GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")

        $om_script_pause_end = False
        Do
            Sleep(100)
        Until $om_script_pause_end
    EndIf

EndFunc

Func Util_ModNameToID($name)
    $mod_id = ""

    For $mod In API_GetOptimizer("options")
        If $name == OM_GetName($mod) Then
            $mod_id = $mod
            ExitLoop
        EndIf
    Next

    If $mod_id = "" Then
        UnexpectedExitErrorMsgBox("optimizer_mod.au3 -> Util_ModNameToID", "optimizer_mod_unexpected", $name)
        Exit
    EndIf

    Return $mod_id
EndFunc

Func OM_Dlg_ComboChanged()
    $val = GUICtrlRead($om_dlg_cbox)
    GUICtrlSetData($om_dlg_desc_label, OM_GetDescription(Util_ModNameToID($val)))
EndFunc

Func OM_Dlg_ConfirmButtonOnClick()
    ; Do the confirmation stuff
    $val = GUICtrlRead($om_dlg_cbox)
    If $val == "" Then
        QuickOKMsgBox_Lang("select_one")
        Return False
    EndIf

    ; Freeze Optimizer Dialog
    GUISetState(@SW_DISABLE, $om_dlg_gui)

    CD_SetOptimizerMod(Util_ModNameToID($val))
    GUICtrlSetData($om_mod_label, OM_GetSelectedName())

    ; Update files
    If $om_dlg_ins_after_close Then
        InstallOrUpdate(True)
    EndIf

    ; Close window
    UnfreezeMainWindow()
    GUIDelete($om_dlg_gui)

    Return True

    ;$om_script_pause_end = True
EndFunc

Func OM_GetSelectedName()
    Return OM_GetName(CD_GetOptimizerMod())
EndFunc

Func OM_GetSelectedDescription()
    Return OM_GetDescription(CD_GetOptimizerMod())
EndFunc

Func OM_GetName($lang_str)
    If Json_IsNull($lang_str) Or $lang_str = "" Then
        Return ""
    EndIf
    Return Lang("optimizer_mods." & $lang_str & ".name")
EndFunc

Func OM_GetDescription($lang_str)
    If Json_IsNull($lang_str) Or $lang_str = "" Then
        Return ""
    EndIf
    Return Lang("optimizer_mods." & $lang_str & ".description")
EndFunc
