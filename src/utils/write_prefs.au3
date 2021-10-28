#include-once
#include "read_config.au3"
#include "json_io.au3"
#include "log.au3"
#include <JSON.au3>

Func Prefs_SetLanguage($lang_id)
    Json_Put($prefs, '.language', $lang_id)
    LogWrite("[PREFS] Set language to " & $lang_id)
EndFunc

Func Prefs_SetJVM_Heap_Size($val)
    Json_Put($prefs, '.jvm_heap_size', $val)
    LogWrite("[PREFS] Set JVM Heap Size to " & $val)
EndFunc

Func Prefs_SetMC_Dir($val)
    Json_Put($prefs, '.mc_dir', $val)
    LogWrite("[PREFS] Set MC Directory to " & $val)
EndFunc

Func Prefs_SetProfileNameIsID($val)
    Json_Put($prefs, '.profile_name_is_id', $val)
    LogWrite("[PREFS] Set 'Profile Name is ID' to " & $val)
EndFunc

Func Prefs_SetCreateEmptyJAR($val)
    Json_Put($prefs, '.create_empty_jar', $val)
    LogWrite("[PREFS] Set 'Create Empty JAR' to " & $val)
EndFunc

Func Prefs_UpdateFile()
    Json_ToFile($prefsFileName, $prefs)
    LogWrite("[PREFS] Updated prefs file")
EndFunc
