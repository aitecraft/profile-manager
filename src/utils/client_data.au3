#include-once
#include <JSON.au3>
#include <Array.au3>
#include "../gui/extras.au3"
#include "end_program.au3"

Global Const $client_file_name = "resources/client_data.json"
Global $client_data

Func CD_LoadData()
    $client_data = json_decode(FileRead($client_file_name))
    If $client_data == "" Then
        Local $files[0]
        CDSet('files', $files)
        CD_SetOptimizerMod(Null)
        CD_SetVersion(0)
    EndIf
EndFunc

Func CDGet($path)
    return Json_Get($client_data, '.' & $path)
EndFunc

Func CDSet($path, $val)
    Json_Put($client_data, '.' & $path, $val)
EndFunc

Func CD_UpdateFile()
    $file = FileOpen($client_file_name, $FO_OVERWRITE)
    FileWrite($file, Json_Encode_Pretty($client_data, $JSON_PRETTY_PRINT, "    ", "," & @CRLF, "," & @CRLF, ": " ))
    FileClose($file)
EndFunc

Func CD_GetFilesList()
    return CDGet('files')
EndFunc

Func CD_RemoveFileFromList($file_path)
    Local $files = CD_GetFilesList()
    Local $index = _ArraySearch($files, $file_path)
    If $index >= 0 Then
        _ArrayDelete($files, $index)
        CDSet('files', $files)
    Else
        UnexpectedExitErrorMsgBox()
        EndProgram()
    EndIf
EndFunc

Func CD_AddFileToList($file_path)
    If _ArraySearch(CD_GetFilesList(), $file_path) = -1 Then 
        CDSet('files[' & UBound(CD_GetFilesList()) & ']', $file_path)
    EndIf
EndFunc

Func CD_GetOptimizerMod()
    return CDGet('optimizer_mod')
EndFunc

Func CD_SetOptimizerMod($mod_name)
    CDSet('optimizer_mod', $mod_name)
EndFunc

Func CD_GetVersion()
    return CDGet('version')
EndFunc

Func CD_SetVersion($ver)
    CDSet('version', $ver)
EndFunc
