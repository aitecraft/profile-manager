#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include "../utils/lang_manager.au3"
#include "../utils/read_config.au3"
#include "../utils/version.au3"
#include "extras.au3"
#include "main_window.au3"
#include "../utils/write_prefs.au3"
#include "../utils/fabric_setup.au3"

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
    
    ; ----------------------------
    ; Import Options
    SMLang('import')
    $menu_import = GUICtrlCreateMenu(MLangT())
    
    If (Config_Proprietary_AitecraftLauncherImport()) Then
        $menu_import_aitecraft = GUICtrlCreateMenuItem(MLangO('aitecraft_launcher'), $menu_import)
        GUICtrlSetOnEvent(-1, "Import_Aitecraft")
    EndIf

    $menu_import_general = GUICtrlCreateMenuItem(MLangO('general'), $menu_import)
    GUICtrlSetOnEvent(-1, "Import_General")
    ; ----------------------------

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
    ; Change Skin Option
    If (Config_Proprietary_ChangeSkin()) Then
        SMLang('aitecraft')

        $menu_aitecraft = GUICtrlCreateMenu(MLangT())
        $menu_aitecraft_change_skin = GUICtrlCreateMenuItem(MLangO('change_skin'), $menu_aitecraft)
        GUICtrlSetOnEvent(-1, "Aitecraft_ChangeSkin")
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

Func Import_Aitecraft()
    NotImplementedMsgBox()
EndFunc

Func Import_General()
    NotImplementedMsgBox()
EndFunc

Func Open_Mods()
    NotImplementedMsgBox()
EndFunc

Func Open_Logs()
    NotImplementedMsgBox()
EndFunc

Func Open_RP()
    NotImplementedMsgBox()
EndFunc

Func Open_Schematics()
    NotImplementedMsgBox()
EndFunc

Func Open_Profile()
    NotImplementedMsgBox()
EndFunc

Func Aitecraft_ChangeSkin()
    NotImplementedMsgBox()
EndFunc

Func About_Version()
    SMLang('about')
    QuickOKMsgBox(MLangO('version'), $version)
EndFunc

Func About_ViewSrc()
    NotImplementedMsgBox()
EndFunc