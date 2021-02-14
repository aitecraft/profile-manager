#include-once
#include "read_config.au3"
#include "json_io.au3"
#include <JSON.au3>

Func Prefs_SetLanguage($lang_id)
    Json_Put($prefs, '.language', $lang_id)
EndFunc

Func Prefs_SetJVM_Heap_Size($val)
    Json_Put($prefs, '.jvm_heap_size', $val)
EndFunc

Func Prefs_SetMC_Dir($val)
    Json_Put($prefs, '.mc_dir', $val)
EndFunc

Func Prefs_SetProfileNameIsSameAsProfileID($val)
    Json_Put($prefs, '.profile_name_is_id', $val)
EndFunc

Func Prefs_UpdateFile()
    Json_ToFile($prefsFileName, $prefs)
EndFunc
