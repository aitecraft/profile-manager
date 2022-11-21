#include-once
#include <JSON.au3>
#include <ComboConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include "../utils/lang_manager.au3"
#include "../utils/launcher_profiles.au3"
#include "../utils/read_config.au3"
#include "../utils/log.au3"
#include "../utils/misc.au3"
#include "main_window.au3"
#include "extras.au3"

Global $import_dlg_gui
Global $import_dlg_cbox
Global $import_dlg_path_label
Global $import_dlg_button
Global $import_options

Func Import_Dlg_Create()
    $import_options = LauncherProfiles_GetProfiles()
    If $import_options == Null Then 
        QuickOKMsgBox_Lang("no_profiles_to_import")
        Return
    EndIf

    $import_dlg_gui = GUICreate(Lang("labels.import_profile"), 250, 210, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), -1, GetMainWindowHandle())
    GUISetFont(LangFontSize())
    GUISetOnEvent($GUI_EVENT_CLOSE, "Import_Dlg_Closed")

    ; Move GUI to be slightly below center of main window
    $mainpos = WinGetPos(GetMainWindowHandle())
    $xpos = $mainpos[0] + (($mainpos[2]/2) - (250 / 2))
    WinMove($import_dlg_gui, "", $xpos, $mainpos[1] + 200 + 50)

    GUICtrlCreateLabel(Lang("labels.pick_profile"), 8, 8, 228, 50)
    
    $import_dlg_cbox = GUICtrlCreateCombo("", 40, 50, 169, 25, $CBS_DROPDOWNLIST)
    GUICtrlSetOnEvent(-1, "Import_Dlg_ComboChanged")

    For $i = 0 To UBound($import_options) - 1
        GUICtrlSetData(-1, $import_options[$i][0])
    Next

    GUICtrlCreateLabel(Lang("labels.profile_directory"), 8, 90, 228, 20, $SS_CENTER)

    ; Path Label
    $import_dlg_path_label = GUICtrlCreateLabel("", 8, 115, 228, 50, BitOR($SS_CENTER, $DT_END_ELLIPSIS))

    $import_dlg_button = GUICtrlCreateButton(Lang("buttons.confirm"), 64, 166, 113, 33)
    GUICtrlSetOnEvent(-1, "Import_Dlg_ConfirmButtonOnClick")

    FreezeMainWindow()
    GUISetState(@SW_SHOW, $import_dlg_gui)
EndFunc

Func Import_Dlg_GetProfilePath()
    $path = ""
    $val = GUICtrlRead($import_dlg_cbox)
    If $val == "" Then Return
    For $i = 0 To UBound($import_options) - 1
        If $val == $import_options[$i][0] Then
            $path = $import_options[$i][1]
            ExitLoop
        EndIf
    Next
    Return $path
EndFunc

Func Import_Dlg_ComboChanged()
    $path = Import_Dlg_GetProfilePath()
    GUICtrlSetData($import_dlg_path_label, $path)
    GUICtrlSetTip($import_dlg_path_label, $path, Lang("labels.profile_directory"))
EndFunc

Func Import_Dlg_Refresh($disable = False)
    GUISetState(@SW_ENABLE, $import_dlg_gui)
    GUISetState(@SW_RESTORE, $import_dlg_gui)
    If $disable Then GUISetState(@SW_DISABLE, $import_dlg_gui)
EndFunc

Func Import_Dlg_ConfirmButtonOnClick()
    ; Do the confirmation stuff
    $val = GUICtrlRead($import_dlg_cbox)
    If $val == "" Then
        QuickOKMsgBox_Lang("select_one_profile")
        Return False
    EndIf

    Import_Dlg_Refresh(True)

    $source = Import_Dlg_GetProfilePath()
    $ob = ObjCreate("Scripting.Dictionary")
    $ob.Add("dir", $source)
    If QuickYesNoMsgBox_LangDynamic("import_warning", $ob, $mbQuestion) <> 6 Then 
        Import_Dlg_Refresh()
        Return
    EndIf

    Import_Dlg_Refresh(True)
    
    LogWrite("[PROFILE IMPORT] Importing from: " & $source)

    ; Begin Copying config files...
    $count = 0
    $target = Config_Profile_GetDir()
    For $file In Config_GetImports()
        LogWrite("[PROFILE IMPORT] File: " & $file, "")

        $state = ""
        $target_file = $target & "\" & $file
        $source_file = $source & "\" & $file       
        If FileExists($source_file) Then
            CreateFolderFromFilePath($target_file)
            If FileCopy($source_file, $target_file, 1) Then
                $count += 1
                $state = "Success"
            Else
                $state = "Failed [WARNING]"
            EndIf
        Else
            $state = "Skipped"
        EndIf

        LogWriteLineRaw(" - " & $state)
    Next

    LogWrite("[PROFILE IMPORT] Finished import. Copied " & $count & " files.")

    If $count > 0 Then
        $ob = ObjCreate("Scripting.Dictionary")
        $ob.Add("count", $count)
        QuickOKMsgBox_LangDynamic("import_done.success", $ob)
    Else
        QuickOKMsgBox_Lang("import_done.failure", 0x10)
    EndIf

    ; Close window
    UnfreezeMainWindow()
    GUIDelete($import_dlg_gui)
EndFunc

Func Import_Dlg_Closed()
    ; Close window
    UnfreezeMainWindow()
    GUIDelete($import_dlg_gui)
EndFunc
