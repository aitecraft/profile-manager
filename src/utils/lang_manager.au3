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

Func LangNum($num)
    ; Convert to string
    $num_str = String($num)

    If Not (StringIsInt($num_str) Or StringIsFloat($num_str)) Then
        Return "[error-localizing-number]"
    EndIf

    ; Localize
    $output = LangStringNum($num_str)
    
    ; Optional reverse
    If LangJsonNum("reverse.reverse_final_string") Then $output = StringReverse($output)

    Return $output
EndFunc

Func LangJsonNum($term)
    Return Json_Get($current_lang, ".numbers." & $term)
EndFunc

Func LangStringNum($num_str)
    $ret = ""
    For $char In StringSplit($num_str, "", 2)
        If $char == "-" Then
            $new = LangJsonNum("negative_notation")
        ElseIf $char == "." Then
            $new = LangJsonNum("decimal_point_notation")
        Else
            $new = LangJsonNum("characters[" & $char & "]")
        EndIf
        $ret = $ret & $new
    Next
    Return $ret
EndFunc

Func LangDynamic($term, $dict)
    $txt = Lang($term)

    For $key In $dict
        $search_term = "$<" & $key & ">"
        $txt = StringReplace($txt, $search_term, $dict.Item($key))
    Next

    Return $txt
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
