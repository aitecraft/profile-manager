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
Global $om_dlg_button
Global $om_dlg_ins_after_close
Global $om_script_pause_end

Func MainWindowOMSettings($top)
    OM_CreateGroup($top)
    OM_CreateLabelAndButton($top + 18)
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
    $om_dlg_gui = GUICreate(Lang("labels.optimizer_mod"), 251, 181, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_BORDER), -1, GetMainWindowHandle())
    
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
    
    $om_dlg_cbox = GUICtrlCreateCombo($om_dlg_cbox_init_val, 40, 72, 169, 25, $CBS_DROPDOWNLIST)

    ; Add other options 
    For $mod in $om_options
        If CD_GetOptimizerMod() <> $mod Then
            GUICtrlSetData($om_dlg_cbox, OM_GetName($mod))
        EndIf
    Next

    $om_dlg_button = GUICtrlCreateButton(Lang("buttons.confirm"), 64, 136, 113, 33)
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

Func OM_Dlg_ConfirmButtonOnClick()
    ; Do the confirmation stuff
    $val = GUICtrlRead($om_dlg_cbox)
    If $val == "" Then
        QuickOKMsgBox_Lang("select_one")
        Return False
    EndIf

    ; Freeze Optimizer Dialog
    GUISetState(@SW_DISABLE, $om_dlg_gui)

    $mod_id = ""

    ; Find Mod ID from Name
    For $mod In API_GetOptimizer("options")
        If $val == OM_GetName($mod) Then
            $mod_id = $mod
            ExitLoop
        EndIf
    Next

    If $mod_id = "" Then
        UnexpectedExitErrorMsgBox()
        Exit
    EndIf

    CD_SetOptimizerMod($mod_id)
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

Func OM_GetName($lang_str)
    If Json_IsNull($lang_str) Or $lang_str = "" Then
        Return ""
    EndIf
    Return Lang("optimizer_mods." & $lang_str)
EndFunc
