#include-once
#include "../utils/lang_manager.au3"
#include "../utils/read_config.au3"
#include "../utils/write_prefs.au3"
#include "../utils/launcher_profiles.au3"

Global $mem_val_label
Global $mem_slider

Func MainWindowProfileSettings($top)
    PS_CreateGroup($top)
    CreateJVMHeapSlider($top+20)
    CreateUpdateProfileButton($top+80)
    Return $top + 140
EndFunc

Func PS_CreateGroup($top)
    GUICtrlCreateGroup(Lang("labels.profile_settings"), 5, $top, 340, 130)
EndFunc

Func CreateUpdateProfileButton($top)
    GUICtrlCreateButton(Lang("buttons.update_profile"), 125, $top, 100, 40)
    GUICtrlSetOnEvent(-1, "UpdateProfileButtonClicked")
EndFunc

Func CreateJVMHeapSlider($top)
    GUICtrlCreateLabel(Lang("labels.jvm_heap_size"), 20, $top + 15)
    $mem_slider = GUICtrlCreateSlider(120, $top, 200, 25)
    
    ; Set 8 GB max limit and specified min limit
    $limit = Config_Profile_GetJVM_Minimum_Heap_Size() / 1024
    GUICtrlSetLimit(-1, 8, $limit)
    GUICtrlSetOnEvent(-1, "MemSliderMoved")
    GUICtrlSetData(-1, Config_Profile_GetJVM_Heap_Size() / 1024)

    $mem_val_label = GUICtrlCreateLabel(GetLabelText(), 210, $top+30)
EndFunc

Func UpdateProfileButtonClicked()
    LauncherProfiles_Init()
    LauncherProfile_Put("javaArgs", Config_Profile_GetJVM_Args())
    LauncherProfile_Put("name", Config_Profile_GetName())
    LauncherProfiles_Update()
    Prefs_UpdateFile()
EndFunc

Func GetLabelText()
    $ob = ObjCreate("Scripting.Dictionary")
    $ob.Add("mem_size_amount", LangNum(Config_Profile_GetJVM_Heap_Size()))
    $ob.Add("mem_size_unit", Lang("units.mb"))
    Return LangDynamic("labels_dynamic.mem_size", $ob)
EndFunc

Func MemSliderMoved()
    $value = GUICtrlRead(@GUI_CtrlId)
    Prefs_SetJVM_Heap_Size($value * 1024)
    ;ConsoleWrite($value & @CRLF)
    GUICtrlSetData($mem_val_label, GetLabelText())
EndFunc
