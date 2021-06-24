#include-once
#include "api_helper.au3"
#include "json_io.au3"
#include "../gui/extras.au3"
#include <JSON.au3>

Func ModrinthAPI_GetData($modID, $target_version)
    $mod_data_url = API_GetModrinthAPIEndpoint() & "mod/" & $modID
    $mod_data = Json_FromURL($mod_data_url)

    $internal_modID = Json_Get($mod_data, ".id")

    $mod_versions_list_url = API_GetModrinthAPIEndpoint() & "mod/" & $internal_modID & "/version"
    $mod_versions = Json_FromURL($mod_versions_list_url)

    ; Iterate through versions list and pick version
    $version_index = -1

    For $i=0 to UBound($mod_versions)-1
        $version_num = Json_ObjGet($mod_versions[$i], "version_number")

        If $version_num = $target_version Then
            $version_index = $i
            ExitLoop
        EndIf
    Next

    If $version_index == -1 Then
        UnexpectedExitErrorMsgBox()
        Exit
    EndIf

    
    ; Ensure a "primary" file exists or the files list has 1 element
    $files_list = Json_ObjGet($mod_versions[$version_index], "files")

    $file_index = -1

    If UBound($files_list) == 1 Then
        $file_index = 0
    Else
        For $i=0 to UBound($files_list)-1
            $file_is_primary = Json_ObjGet($files_list[$i], "primary")
            If $file_is_primary Then
                $file_index = $i
                ExitLoop
            EndIf
        Next
    EndIf

    If $file_index == -1 Then
        UnexpectedExitErrorMsgBox()
        Exit
    EndIf
    

    ; The return object
    $processed_json = Json_ObjCreate()
    

    ; SHA-512 Hash
    $hash = Json_Get($files_list[$i], ".hashes.sha512")
    StringUpper($hash)
    $hash = "0x" & $hash
    
    Json_Put($processed_json, ".hash", $hash)

    ; File Download URL
    Json_Put($processed_json, ".url", Json_Get($files_list[$i], ".url"))

    Return $processed_json
EndFunc

