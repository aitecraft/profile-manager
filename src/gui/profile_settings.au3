#include-once
#include "../utils/lang_manager.au3"
#include "../utils/read_config.au3"
#include "../utils/write_prefs.au3"
#include "../utils/launcher_profiles.au3"

Global $mem_val_label
Global $mem_slider

Func MainWindowProfileSettings()
    CreateJVMHeapSlider(150)
    CreateUpdateProfileButton(210)
EndFunc

Func CreateUpdateProfileButton($top)
    GUICtrlCreateButton(Lang("buttons.update_profile"), 125, $top, 100, 40)
    GUICtrlSetOnEvent(-1, "UpdateProfileButtonClicked")
EndFunc

Func CreateJVMHeapSlider($top)
    GUICtrlCreateLabel(Lang("labels.jvm_heap_size"), 20, $top + 15)
    $mem_slider = GUICtrlCreateSlider(120, $top, 200, 25)
    GUICtrlSetLimit(-1, 8, 1)
    GUICtrlSetOnEvent(-1, "MemSliderMoved")
    GUICtrlSetData(-1, Config_Profile_GetJVM_Heap_Size() / 1024)

    $mem_val_label = GUICtrlCreateLabel(GUICtrlRead($mem_slider) & " " & Lang("units.gb"), 210, $top+30)
EndFunc

Func UpdateProfileButtonClicked()
    LauncherProfiles_Init()
    LauncherProfile_Put("javaArgs", Config_Profile_GetJVM_Args())
    LauncherProfiles_Update()
    Prefs_UpdateFile()
EndFunc

Func MemSliderMoved()
    $value = GUICtrlRead(@GUI_CtrlId)
    ;ConsoleWrite($value & @CRLF)
    GUICtrlSetData($mem_val_label, $value & " " & Lang("units.gb"))
    Prefs_SetJVM_Heap_Size($value * 1024)
EndFunc
