#include-once
#include <Array.au3>

Global Const $version = "alpha-0.5.1"

Const $version_history[8] = ["alpha-0.5.1", "alpha-0.5", "alpha-0.4", "alpha-0.3.1", "alpha-0.3.0", "alpha-0.2.0", "alpha-0.1.0", "alpha-0.0.1"]

Func ThisVersionGreaterThanOrEqualTo($compare_ver)
    _ArraySearch($version_history, $compare_ver)
    If @error == 6 Then
        Return False
    EndIf
    Return True
EndFunc
