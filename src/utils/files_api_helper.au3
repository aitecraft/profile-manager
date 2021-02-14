#include-once
#include "api_helper.au3"
#include "json_io.au3"
#include "client_data.au3"
#include "read_config.au3"
#include "../gui/extras.au3"
#include "download.au3"
#include <StringConstants.au3>
#include <JSON.au3>
#include <Array.au3>

Global $files_api_data
Global $files_download_list_urls[0]
Global $files_download_list_file_paths[0]

Func FAPI_Init()
    $files_api_url = API_GetFAPIEndpoint() & API_GetFAPIIndex()
    $files_api_data = Json_FromURL($files_api_url)
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

Func FAPIFile_GetLastUpdated($obj)
    Return Json_ObjGet($obj, "last_updated_version")
EndFunc

Func FAPIFile_GetURL($obj)
    Return Json_ObjGet($obj, "url")
EndFunc

Func FAPIFile_InitDownloadList()
    Local $empty_arr[0]
    $files_download_list_urls = $empty_arr
    $files_download_list_file_paths = $empty_arr
EndFunc

Func FAPIFile_AddToDownloadList($file, $url)
    If Json_IsNull($url) Or $url = Null Or $url = "" Then
        UnexpectedExitErrorMsgBox()
        Exit
    Else
        _ArrayAdd($files_download_list_urls, $url)
        _ArrayAdd($files_download_list_file_paths, FAPI_FilePathToFullPath($file))
    EndIf
EndFunc

Func FAPIFile_DownloadCallback($txt, $dw, $total)
    ConsoleWrite($txt & @CRLF)
EndFunc

Func FAPIFile_DownloadFromList()
    If UBound($files_download_list_urls) <= 0 Then
        Return True
    EndIf

    Return DownloadFileBulk($files_download_list_urls, $files_download_list_file_paths, FAPIFile_DownloadCallback)
EndFunc

Func FAPI_InstallOrUpdate()

    FAPI_Init()
    FAPIFile_InitDownloadList()

    For $file In CD_GetFilesList()
        $obj = FAPI_GetFromFilePath($file)
        If $obj <> False Then
            If (CD_GetVersion() >= FAPIFile_GetLastUpdated($obj)) Then
                ; We can just ignore this..., file exists and is up-to-date.
                ; TODO
                ; Maybe add check for whether or not file actually exists here later?
                ; If missing then add to download list
            Else
                ; TODO Add Condition checks
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
        EndIf
    Next

    ; Now, add all files remaining in the FAPI to the Download List
    ; Also add those files to the CD File List
    For $file In FAPI_GetAllFilePaths()
        FAPIFile_AddToDownloadList($file, FAPIFile_GetURL(FAPI_GetFromFilePath($file)))
        CD_AddFileToList($file)
    Next

    ; Start Download
    Return FAPIFile_DownloadFromList()
EndFunc
