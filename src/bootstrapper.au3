#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "utils/download.au3"
#include "utils/json_io.au3"
#include "utils/misc.au3"

#include <JSON.au3>
#include <Array.au3>
#include <Crypt.au3>

$config = Json_FromFile("resources/bootstrapper.json")

$api_data = Json_FromURL(Json_ObjGet($config, "api"))

_Crypt_Startup()

$download_needed = False

Global $files_download_list_urls[0]
Global $files_download_list_file_paths[0]


For $file In Json_ObjGetKeys($api_data)
    $obj = Json_ObjGet($api_data, $file)

    $local_hash = _Crypt_HashFile($file, $CALG_SHA_256)
    $remote_hash = Json_ObjGet($obj, "hash")

    If Not (FileExists($file) And $local_hash = $remote_hash) Then
        _ArrayAdd($files_download_list_urls, Json_ObjGet($obj, "url"))
        _ArrayAdd($files_download_list_file_paths, $file)
        $download_needed = True
    EndIf
Next

_Crypt_Shutdown()

;_ArrayDisplay($files_download_list_file_paths)
;_ArrayDisplay($files_download_list_urls)

;#cs
If $download_needed Then
    $dw_status = DownloadFileBulk($files_download_list_urls, $files_download_list_file_paths, PlaceholderDownloadCallback)
EndIf

If Not $download_needed Or $dw_status Then
    Run(@AutoItExe & ' "resources/profile-manager.a3x"')
EndIf
#ce

Func PlaceholderDownloadCallback($downloaded_count, $total_count, $downloaded_size, $total_broken, $total_size)
    ConsoleWrite($downloaded_size & @CRLF)
EndFunc