#include-once
#include "api_helper.au3"
#include "json_io.au3"
#include "../gui/extras.au3"
#include <JSON.au3>

Func CurseforgeAPI_GetData($mod_id, $file_id)
    $file_api_url = API_GetCurseforgeAPIEndpoint() & "mods/" & $mod_id & "/files/" & $file_id
    $response = Json_FromURL($file_api_url)
    $file = Json_ObjGet($response, "data")

    $SHA1_hash = ""
    $hashes = Json_ObjGet($file, "hashes")
    For $hash in $hashes
        ; SHA-1 has algo: 1
        If Json_ObjGet($hash, "algo") = 1 Then
            $SHA1_hash = Json_ObjGet($hash, "value")
            ExitLoop
        EndIf
    Next

    If $SHA1_hash == "" Then
        UnexpectedExitErrorMsgBox("curseforge_api_helper.au3 -> CurseforgeAPI_GetData", "curseforge_api_no_sha1_hash", $mod_id & " - " & $file_id)
        Exit
    EndIf


    $processed_json = Json_ObjCreate()

    StringUpper($SHA1_hash)
    $SHA1_hash = "0x" & $SHA1_hash
    Json_Put($processed_json, ".hash", $SHA1_hash)

    ; File Download URL
    Json_Put($processed_json, ".url", Json_ObjGet($file, "downloadUrl"))

    Return $processed_json
EndFunc
