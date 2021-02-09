#include-once
#include "json_io.au3"
#include <JSON.au3>
#include <MsgBoxConstants.au3>

Const $languageListFileName = "resources/lang/languages.json"
Const $languageFilesFolder = "resources/lang/"

Global $languages = 0
Global $current_lang = 0
Global $current_lang_id = ''

; Initialize Config Data
Func LoadLanguageList()
    $lang_info = Json_FromFile($languageListFileName)
    $languages = Json_ObjGet($lang_info, "languages")
EndFunc

Func LoadLang($name)
    $loaded = False
    For $i=0 to UBound($languages)-1
        $id = Json_ObjGet($languages[$i], "id")
        If (StringCompare($name, $id) == 0) Then
            $loaded = True
            $current_lang = Json_FromFile($languageFilesFolder & Json_ObjGet($languages[$i], "file_name"))
            $current_lang_id = $id
            ExitLoop
        EndIf
    Next

    If Not $Loaded Then
        MsgBox($MB_OK + $MB_ICONINFORMATION, "Error", "Program tried to load invalid language file...")
    EndIf
EndFunc

Func Lang($term)
    $ret = json_get($current_lang, ".strings." & $term)
    If @error == 1 And @extended == 0 Then
        Return $term
    ElseIf json_isnull($ret) Then
        Return $term
    Else
        Return $ret
    EndIf
EndFunc

Func GetLangNamesList()
    Local $lang_list[UBound($languages)]

    For $i=0 to UBound($languages)-1        
        $name = Json_ObjGet($languages[$i], "name")
        $lang_list[$i] = $name 
    Next

    Return $lang_list
EndFunc

Func GetLangIdsList()
    Local $lang_list[UBound($languages)]

    For $i=0 to UBound($languages)-1        
        $id = Json_ObjGet($languages[$i], "id")
        $lang_list[$i] = $id 
    Next

    Return $lang_list
EndFunc

Func IsCurrentLang($id)
    Return StringCompare($id, $current_lang_id) == 0
EndFunc

Func LoadLangFromIdWithCheck($e)
    If Not IsCurrentLang($e) Then
        LoadLang($e)
        Return True
    EndIf
    Return False
EndFunc

Func GetLanguageCount()
    Return UBound($languages)
EndFunc
