#include-once
#include <JSON.au3>
#include <FileConstants.au3>
#include "http.au3"

Func Json_ToFile($path, ByRef $json_obj)
    $file = FileOpen(Config_GetMCDir() & "/versions/" & FabricAPI_Get("id") & "/" & FabricAPI_Get("id") & ".json", $FO_OVERWRITE)
    FileWrite($file, Json_Encode_Pretty($json_obj, $JSON_PRETTY_PRINT + $JSON_UNESCAPED_SLASHES, "    ", "," & @CRLF, "," & @CRLF, ": " ))
    FileClose($file)
EndFunc

Func Json_FromFile($path)
    Return Json_Decode(FileRead($path))
EndFunc

Func Json_FromURL($url)
    Return Json_Decode(HttpGet($url))
EndFunc
