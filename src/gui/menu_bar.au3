#include-once
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <JSON.au3>
#include "../utils/lang_manager.au3"
#include "../utils/read_config.au3"
#include "../utils/version.au3"
#include "extras.au3"
#include "main_window.au3"
#include "../utils/write_prefs.au3"
#include "../utils/fabric_setup.au3"
#include "../utils/api_helper.au3"
#include "../utils/client_data.au3"

Global $option = ''
Global $ctrlToTerm

; Menu Lang
Func MLang($term)
    Return Lang('menu_bar.' & $option & '.' & $term)
EndFunc

; Menu Lang Option
Func MLangO($term)
    Return MLang('options.' & $term)
EndFunc

; Menu Lang Title
Func MLangT()
    Return MLang('title')
EndFunc

; Set Menu Lang
Func SMLang($term)
    $option = $term
EndFunc

Func MainWindowMenuBar()

    If (Config_GUIGet_OpenFoldersMenu()) Then
        ; ----------------------------
        ; Open Folder Options
        SMLang('open')
        $menu_open = GUICtrlCreateMenu(MLangT())
        
        $menu_open_mods = GUICtrlCreateMenuItem(MLangO('mods_folder'), $menu_open)
        GUICtrlSetOnEvent(-1, "Open_Mods")

        $menu_open_logs = GUICtrlCreateMenuItem(MLangO('logs_folder'), $menu_open)
        GUICtrlSetOnEvent(-1, "Open_Logs")

        $menu_open_rp = GUICtrlCreateMenuItem(MLangO('resourcepack_folder'), $menu_open)
        GUICtrlSetOnEvent(-1, "Open_RP")

        If Config_Proprietary_OpenSchematicsFolderOption() Then
            $menu_open_schematics = GUICtrlCreateMenuItem(MLangO('schematics_folder'), $menu_open)
            GUICtrlSetOnEvent(-1, "Open_Schematics")
        EndIf
        
        $menu_open_profile = GUICtrlCreateMenuItem(MLangO('profile_folder'), $menu_open)
        GUICtrlSetOnEvent(-1, "Open_Profile")
        ; ----------------------------
    EndIf

    ; ----------------------------
    ; Settings..
    
    SMLang('settings')
    $menu_settings = GUICtrlCreateMenu(MLangT())
    
    If Config_GUIGet_ProfileSettings() Then
        Global $menu_settings_createEmptyJAR = GUICtrlCreateMenuItem(MLangO('create_empty_jar'), $menu_settings)
        SetMenuBarCheckboxState(-1, Config_GetCreateEmptyJAR())
        GUICtrlSetOnEvent(-1, "Settings_CreateEmptyJAR")

        Global $menu_settings_profileNameIsID = GUICtrlCreateMenuItem(MLangO('profile_name_is_id'), $menu_settings)
        SetMenuBarCheckboxState(-1, Config_GetProfileNameIsID())
        GUICtrlSetOnEvent(-1, "Settings_ProfileNameIsID")
        
        GUICtrlCreateMenuItem("", $menu_settings)
    EndIf

    Global $menu_settings_strictHashCheck = GUICtrlCreateMenuItem(MLangO('strict_hash_check'), $menu_settings)
    SetMenuBarCheckboxState(-1, Config_GetStrictHashCheck())
    GUICtrlSetOnEvent(-1, "Settings_StrictHashCheck")

    GUICtrlCreateMenuItem("", $menu_settings)

    Global $menu_settings_mc_dir = GUICtrlCreateMenuItem(MLangO('mc_dir'), $menu_settings)
    GUICtrlSetOnEvent(-1, "Settings_MCDir")

    ; ----------------------------

    ; ----------------------------
    ; Language Options..
    SMLang('language')
    $menu_language = GUICtrlCreateMenu(MLangT())

    Global $menu_lang_options[GetLanguageCount()]
    Local $lang_ids = GetLangIdsList()
    Local $i = 0
    For $lang in GetLangNamesList()
        $menu_lang_options[$i] = GUICtrlCreateMenuItem($lang, $menu_language, -1, 1)
        GUICtrlSetOnEvent(-1, "OnLanguageChange")
        If IsCurrentLang($lang_ids[$i]) Then
            GUICtrlSetState(-1, $GUI_CHECKED)
        EndIf
        $i += 1
    Next
    ; ----------------------------

    ; ----------------------------
    ; Modpack-specfic Change Skin and Open Website Options
    If (Config_Proprietary_Links_Exists()) Then
        SMLang('links')

        $ctrlToTerm = ObjCreate("Scripting.Dictionary")

        $menu_links = GUICtrlCreateMenu(MLangT())
        Links_Create($menu_links, Config_Proprietary_Links())
    EndIf
    ; ----------------------------

    ; ----------------------------
    ; About Options
    SMLang('about')
    $menu_about = GUICtrlCreateMenu(MLangT())

    $menu_about_version = GUICtrlCreateMenuItem(MLangO('version'), $menu_about)
    GUICtrlSetOnEvent(-1, "About_Version")

    $menu_about_view_src = GUICtrlCreateMenuItem(MLangO('view_source'), $menu_about)
    GUICtrlSetOnEvent(-1, "About_ViewSrc")
    ; ----------------------------

EndFunc

Func OnLanguageChange()
    $lang_ids = GetLangIdsList()
    $result_id = ''
    $result = False
    For $i = 0 To GetLanguageCount()
        If $menu_lang_options[$i] == @GUI_CtrlId Then
            $result = LoadLangFromIdWithCheck($lang_ids[$i])
            $result_id = $lang_ids[$i]
            ExitLoop
        EndIf
    Next

    If $result Then
        Prefs_SetLanguage($result_id)
        ReloadApp()
    EndIf
EndFunc

;Func Import_Aitecraft()
;    NotImplementedMsgBox()
;EndFunc

;Func Import_General()
;    NotImplementedMsgBox()
;EndFunc

Func Open_Mods()
    OpenFolder(Config_Profile_GetDir("mods"))
EndFunc

Func Open_Logs()
    OpenFolder(Config_Profile_GetDir("logs"))
EndFunc

Func Open_RP()
    OpenFolder(Config_Profile_GetDir("resourcepacks"))
EndFunc

Func Open_Schematics()
    OpenFolder(Config_Profile_GetDir("schematics"))
EndFunc

Func Open_Profile()
    OpenFolder(Config_Profile_GetDir())
EndFunc

Func Settings_CreateEmptyJAR()
    If QuickYesNoMsgBox_Lang("compatibility_settings_changed_warning.create_empty_jar", $mbExclamation) = 6 Then
        Prefs_SetCreateEmptyJAR(Not Config_GetCreateEmptyJAR())
        SetMenuBarCheckboxState($menu_settings_createEmptyJAR, Config_GetCreateEmptyJAR())
    EndIf
EndFunc

Func Settings_ProfileNameIsID()
    If QuickYesNoMsgBox_Lang("compatibility_settings_changed_warning.profile_name_is_id", $mbExclamation) = 6 Then
        Prefs_SetProfileNameIsID(Not Config_GetProfileNameIsID())
        SetMenuBarCheckboxState($menu_settings_profileNameIsID, Config_GetProfileNameIsID())
    EndIf
EndFunc

Func Settings_StrictHashCheck()
    If QuickYesNoMsgBox_Lang("strict_hash_check_changed_warning") = 6 Then
        Prefs_SetStrictHashCheck(Not Config_GetStrictHashCheck())
        SetMenuBarCheckboxState($menu_settings_strictHashCheck, Config_GetStrictHashCheck())
    EndIf
EndFunc

Func Settings_MCDir()
    ; First confirm if user wants to change MC Directory
    $ob = ObjCreate("Scripting.Dictionary")
    $ob.Add("mc_dir", Config_GetMCDir())
    
    If QuickYesNoMsgBox_LangDynamic("mc_dir_changed_warning", $ob, $mbQuestion) = 6 Then
        $new_dir = AskUserForMCDir(GetMainWindowHandle())
        
        ; If user chooses cancel or closes the window
        If $new_dir = "" Then
            Return
        EndIf
        
        ; Save old directory's Client Data
        CD_UpdateFile()

        ; Set value in prefs for new directory
        Prefs_SetMC_Dir($new_dir)
        ; Reload Client Data from new directory
        CD_LoadData()
        ; Reload App - refreshes GUI
        ReloadApp()
    EndIf
EndFunc

Func Links_Create($menu, $entries, $root = "", $lang_root = "links")
    For $entry in $entries
        If IsString($entry) Then
            SMLang($lang_root)
            If $entry == "<separator>" Then $entry = ""
            If $entry == "" Then
                GUICtrlCreateMenuItem($entry, $menu)
            Else
                $item = GUICtrlCreateMenuItem(MLangO($entry), $menu)
                GUICtrlSetOnEvent(-1, "Links_Click")
                $ctrlToTerm.Add($item, $root & $entry)
            EndIf
        ElseIf Json_IsObject($entry) Then
            $key = Json_ObjGet($entry, "key")
            $newLang = $lang_root & ".options." & $key
            SMLang($newLang)
            $newMenu = GUICtrlCreateMenu(MLangT(), $menu)
            Links_Create($newMenu, Json_ObjGet($entry, "content"), $root & $key & ".", $newLang)
        EndIf
    Next
EndFunc

Func Links_Click()
    OpenInBrowser(API_GetLink($ctrlToTerm.Item(@GUI_CtrlId)))
EndFunc

Func About_Version()
    SMLang('about')
    QuickOKMsgBox(MLangO('version'), $version)
EndFunc

Func About_ViewSrc()
    OpenInBrowser(API_GetSrcRepoURL())
EndFunc

Func SetMenuBarCheckboxState($control, $state)
    If $state Then
        GUICtrlSetState($control, $GUI_CHECKED)
    Else
        GUICtrlSetState($control, $GUI_UNCHECKED)
    EndIf
EndFunc
