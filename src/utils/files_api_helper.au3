#include-once
#include "api_helper.au3"
#include "json_io.au3"
#include "client_data.au3"
#include "read_config.au3"
#include "../gui/extras.au3"
#include "../gui/status_bar.au3"
#include "log.au3"
#include "download.au3"
#include "modrinth_api_helper.au3"
#include "curseforge_api_helper.au3"
#include <StringConstants.au3>
#include <JSON.au3>
#include <Array.au3>
#include <Crypt.au3>

Global $files_api_data
Global $files_download_list_urls[0]
Global $files_download_list_file_paths[0]

Func FAPI_Init()
    LogWrite("[FILES API] Initializing...")
    $files_api_url = API_GetFAPIEndpoint()
    LogWrite("[FILES API] Loading from " & $files_api_url)
    $files_api_data = Json_FromURL($files_api_url, True)
    LogWrite("[FILES API] Loaded.")
EndFunc

Func FAPI_GetFromFilePath($path)    
    $obj = Json_ObjGet($files_api_data, $path)
    
    If @error = 1 Then
        Return False
    EndIf
    Return $obj
EndFunc

Func FAPI_DeleteFromFilePath($path)
    Json_ObjDelete($files_api_data, $path)
EndFunc

Func FAPI_FilePathToFullPath($path)
    Return Config_Profile_GetDir() & "\" & $path
EndFunc

Func FAPI_GetAllFilePaths()
    Return Json_ObjGetKeys($files_api_data)
EndFunc

Func FAPIFile_GetLastUpdated(ByRef $obj)
    Return Json_ObjGet($obj, "last_updated_version")
EndFunc

Func FAPIFile_GetHash(ByRef $obj)
    Return Json_ObjGet($obj, "hash")
EndFunc

Func FAPIFile_GetURL(ByRef $obj)
    Return Json_ObjGet($obj, "url")
EndFunc

Func FAPIFile_GetProvider(ByRef $obj)
    Return Json_ObjGet($obj, "provider")
EndFunc

Func FAPIFile_ProcessModrinth(ByRef $obj)
    If FAPIFile_IsModrinth($obj) Then
        $mod_slug = Json_ObjGet($obj, "slug")
        $mod_version = Json_ObjGet($obj, "version")
        LogWrite("[FILES API] [MODRINTH] Processing for "  & $mod_slug & " - " & $mod_version)
        $modrinth_data = ModrinthAPI_GetData($mod_slug, $mod_version)
        
        $hash = Json_ObjGet($modrinth_data, "hash")
        $url = Json_ObjGet($modrinth_data, "url")

        Json_ObjPut($obj, "hash", $hash)
        Json_ObjPut($obj, "url", $url)
    EndIf
EndFunc

Func FAPIFile_ProcessCurseforge(ByRef $obj)
    If FAPIFile_IsCurseforge($obj) Then
        $mod_id = Json_ObjGet($obj, "mod_id")
        $file_id = Json_ObjGet($obj, "file_id")
        LogWrite("[FILES API] [CURSEFORGE] Processing for "  & $mod_id & " - " & $file_id)
        $curseforge_data = CurseforgeAPI_GetData($mod_id, $file_id)
        
        $hash = Json_ObjGet($curseforge_data, "hash")
        $url = Json_ObjGet($curseforge_data, "url")

        Json_ObjPut($obj, "hash", $hash)
        Json_ObjPut($obj, "url", $url)
    EndIf
EndFunc

Func FAPIFile_CheckProvider(ByRef $obj, $query)
    $provider = FAPIFile_GetProvider($obj)
    If $provider == $query Then
        Return True
    EndIf
    Return False
EndFunc

Func FAPIFile_IsModrinth(ByRef $obj)
    Return FAPIFile_CheckProvider($obj, "modrinth")
EndFunc

Func FAPIFile_IsCurseforge(ByRef $obj)
    Return FAPIFile_CheckProvider($obj, "curseforge")
EndFunc

Func FAPIFile_IgnoreHashMismatch(ByRef $obj)
    $ignore_mismatch = Json_ObjGet($obj, "ignore_hash_mismatch")

    ; If key does not exist, do NOT ignore mismatches 
    If @error = 1 Then
        Return False
    EndIf

    Return $ignore_mismatch
EndFunc

Func FAPIFile_CheckCondition(ByRef $obj, $condition_key, $condition_value)
    $condition_obj = Json_ObjGet($obj, "condition")

    ; If condition key not found, then return true / download file anyway
    ; This function returns false only if the condition key exists
    If @error = 1 Then
        Return True
    EndIf


    $current_condition_obj = Json_ObjGet($condition_obj, $condition_key)

    If @error = 1 Then
        ; If $condition_key doesn't exist, ignore.
        Return True
    EndIf


    If IsArray($current_condition_obj) Then
        For $val In $current_condition_obj
            ; If any value in array matches, then return True
            If $val == $condition_value Then Return True
        Next
    Else
        If $current_condition_obj == $condition_value Then Return True
    EndIf

    Return False
EndFunc

Func FAPIFile_InitDownloadList()
    Local $empty_arr[0]
    $files_download_list_urls = $empty_arr
    $files_download_list_file_paths = $empty_arr
EndFunc

Func FAPIFile_AddToDownloadList($file, $url)
    If Json_IsNull($url) Or $url = Null Or $url = "" Then
        UnexpectedExitErrorMsgBox("files_api_helper.au3 -> FAPIFile_AddToDownloadList", "files_api_no_url_provided", $file)
        Exit
    Else
        LogWrite("[FILES API] Added " & $file & " to download list. URL: " & $url)
        _ArrayAdd($files_download_list_urls, $url)
        _ArrayAdd($files_download_list_file_paths, FAPI_FilePathToFullPath($file))
    EndIf
EndFunc

Func FAPIFile_DownloadFromList($downloadCallback = "")
    If UBound($files_download_list_urls) <= 0 Then
        Return True
    EndIf

    If Not IsFunc($downloadCallback) Then $downloadCallback = Status_DownloadCallback
    Return DownloadFileBulk($files_download_list_urls, $files_download_list_file_paths, $downloadCallback)
EndFunc

Func FAPI_InstallOrUpdate($hashCheckAllFiles = False, $downloadCallback = "")

    Status_SetParsingFilesAPI()

    FAPI_Init()
    FAPIFile_InitDownloadList()

    ; Total number of external provider files
    $external_total = 0

    ; Apply condition filters
    For $file In FAPI_GetAllFilePaths()
        
        $fobj = FAPI_GetFromFilePath($file)

        ; Also ensure all files' Last Updated is not > API Latest Version
        If API_GetLatestVersion() < FAPIFile_GetLastUpdated($fobj) Then
            UnexpectedExitErrorMsgBox("files_api_helper.au3 -> FAPI_InstallOrUpdate", "files_api_has_version_num_greater_than_api", $file)
            Exit
        EndIf
        
        ; Condition Filter
        If Not (FAPIFile_CheckCondition($fobj, "optimizer_mod", CD_GetOptimizerMod())) Then
            FAPI_DeleteFromFilePath($file)
        ElseIf FAPIFile_IsCurseforge($fobj) Or FAPIFile_IsModrinth($fobj) Then
            $external_total += 1
        EndIf
        
    Next

    ; Resolve External Provider Files
    If $external_total > 0 Then
        LogWrite("[FILES API] Started processing data from Modrinth and CurseForge")
        $current = 1
        For $file In FAPI_GetAllFilePaths() 
            Status_SetParsingExternalAPI($current, $external_total)
            $fobj = FAPI_GetFromFilePath($file)

            FAPIFile_ProcessModrinth($fobj)
            FAPIFile_ProcessCurseforge($fobj)
            $current += 1
        Next
        LogWrite("[FILES API] Finished processing data from Modrinth and CurseForge")
    EndIf

    Status_SetCheckingFiles()

    ; Initialize the crypt library
    If $hashCheckAllFiles Then _Crypt_Startup()

    ; Do the actual file check and downloading
    For $file In CD_GetFilesList()
        $obj = FAPI_GetFromFilePath($file)

        If $obj <> False Then
            If (CD_GetVersion() >= FAPIFile_GetLastUpdated($obj)) Then
                ; We can just ignore this..., file exists and is up-to-date.
                ; TODO
                ; Maybe add check for whether or not file actually exists here later?
                ; If missing then add to download list

                If $hashCheckAllFiles Then
                    $filepath = FAPI_FilePathToFullPath($file)

                    If FileExists($filepath) Then
                        $local_hash = ""
                        
                        If FAPIFile_IsModrinth($obj) Then
                            ; SHA 512 if modrinth is the provider
                            $local_hash = _Crypt_HashFile($filepath, $CALG_SHA_512)
                        ElseIf FAPIFile_IsCurseforge($obj) Then
                            ; SHA 1 if curseforge is provider
                            $local_hash = _Crypt_HashFile($filepath, $CALG_SHA1)
                        Else
                            ; SHA 256 for self-provided
                            $local_hash = _Crypt_HashFile($filepath, $CALG_SHA_256)
                        EndIf

                        $remote_hash = FAPIFile_GetHash($obj)
                        If $local_hash = $remote_hash Then
                            ; File exists and hash matches with API. Do nothing.
                            LogWrite("[FILES API] Hash matched - " & $file)
                        Else
                            ; File exists but hash mismatch
                            If Config_GetStrictHashCheck() Or Not FAPIFile_IgnoreHashMismatch($obj)  Then
                                LogWrite("[FILES API] [WARNING] Hash mismatch! - " & $file)
                                FAPIFile_AddToDownloadList($file, FAPIFile_GetURL($obj))
                            Else
                                LogWrite("[FILES API] Hash mismatch! (ignored) - " & $file)
                            EndIf
                        EndIf
                    Else
                        ; File doesn't exist
                        ;ConsoleWrite("File doesn't exist! - " & $filepath)
                        FAPIFile_AddToDownloadList($file, FAPIFile_GetURL($obj))
                    EndIf
                EndIf
            Else
                ; TODO Implement Special attributes (only download_from_browser for now)
                ; File out-of-date.
                ; Add to download list, and remove from FAPI.
                
                FAPIFile_AddToDownloadList($file, FAPIFile_GetURL($obj))
            EndIf
            
            ; Regardless of whether or not file needs to be downloaded
            ; Remove it from the Files API Object
            ; We've already processed it
            ; So we'll remove it
            FAPI_DeleteFromFilePath($file)
        Else
            ; File no longer in modpack list
            ; Delete file in this case
            CD_RemoveFileFromList($file)
            FileDelete(FAPI_FilePathToFullPath($file))
            LogWrite("[FILES API] File deleted - " & $file)
        EndIf
    Next

    ; Shutdown the crypt library
    If $hashCheckAllFiles Then _Crypt_Shutdown()

    ; Now, add all files remaining in the FAPI to the Download List
    ; Also add those files to the CD File List
    For $file In FAPI_GetAllFilePaths()
        $file_obj = FAPI_GetFromFilePath($file)
        
        FAPIFile_AddToDownloadList($file, FAPIFile_GetURL($file_obj))
        CD_AddFileToList($file)
    Next

    ; Start Download
    Return FAPIFile_DownloadFromList($downloadCallback)
EndFunc
