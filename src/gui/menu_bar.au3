#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include "../utils/lang_manager.au3"
#include "../utils/read_config.au3"
#include "../utils/version.au3"
#include "extras.au3"
#include "main_window.au3"
#include "../utils/write_prefs.au3"
#include "../utils/fabric_setup.au3"
#include "../utils/api_helper.au3"

Global $option = ''

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
    If (Config_Proprietary_ChangeSkin() Or Config_Proprietary_OpenWebsite()) Then
        SMLang('aitecraft')

        $menu_aitecraft = GUICtrlCreateMenu(MLangT())

        If Config_Proprietary_ChangeSkin() Then
            $menu_aitecraft_change_skin = GUICtrlCreateMenuItem(MLangO('change_skin'), $menu_aitecraft)
            GUICtrlSetOnEvent(-1, "Aitecraft_ChangeSkin")
        EndIf

        If Config_Proprietary_OpenWebsite() Then
            $menu_aitecraft_open_website = GUICtrlCreateMenuItem(MLangO('open_website'), $menu_aitecraft)
            GUICtrlSetOnEvent(-1, "Aitecraft_OpenWebsite")
        EndIf
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

Func Settings_MCDir()
    NotImplementedMsgBox()
EndFunc

Func Aitecraft_ChangeSkin()
    OpenInBrowser(API_GetSkinChangerURL())
EndFunc

Func Aitecraft_OpenWebsite()
    OpenInBrowser(API_GetWebsiteURL())
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
