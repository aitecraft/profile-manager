#include-once
#include "read_config.au3"
#include <JSON.au3>
#include <FileConstants.au3>

Func Prefs_SetLanguage($lang_id)
    Json_Put($prefs, '.language', $lang_id)
EndFunc

Func Prefs_SetJVM_XMX($val)
    Json_Put($prefs, '.jvm_xmx', $val)
EndFunc

Func Prefs_SetJVM_XMS($val)
    Json_Put($prefs, '.jvm_xms', $val)
EndFunc

Func Prefs_SetMC_Dir($val)
    Json_Put($prefs, '.mc_dir', $val)
EndFunc

Func Prefs_UpdateFile()
    $file = FileOpen($prefsFileName, $FO_OVERWRITE)
    FileWrite($file, Json_Encode_Pretty($prefs, $JSON_PRETTY_PRINT, @TAB, "," & @CRLF, "," & @CRLF, ": " ))
    FileClose($file)
EndFunc