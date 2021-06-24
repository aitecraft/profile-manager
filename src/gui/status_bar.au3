#include-once
#include <StaticConstants.au3>
#include "../utils/lang_manager.au3"

Global $progress_bar
Global $progress_label_1
Global $progress_label_2

Func Status_DownloadCallback($downloaded_count, $total_count, $downloaded_size, $total_broken, $total_size)
    ; Unhide Progress Bar
    GUICtrlSetState($progress_bar, 16)
    
    $progress = Floor(($downloaded_count / $total_count) * 100)
    GUICtrlSetData($progress_bar, $progress)

    $ob = ObjCreate("Scripting.Dictionary")
    $ob.Add("downloaded_count", LangNum($downloaded_count))
    $ob.Add("total_count", LangNum($total_count))
    GUICtrlSetData($progress_label_1, LangDynamic("labels_dynamic.progress_file_count", $ob))

    $ob = ObjCreate("Scripting.Dictionary")
    
    ; This $downloaded_size is already a localized string with appropriate memory unit
    $ob.Add("downloaded_size", $downloaded_size)
    

    If ($total_broken) Then
        GUICtrlSetData($progress_label_2, LangDynamic("labels_dynamic.progress_size_total_unknown", $ob))
    Else
        $ob.Add("total_size", $total_size)
        GUICtrlSetData($progress_label_2, LangDynamic("labels_dynamic.progress_size", $ob))
    EndIf
EndFunc

Func Status_SetPleaseWait()
    GUICtrlSetData($progress_label_1, Lang("labels.status.please_wait"))
EndFunc

Func Status_SetInstallingFabric()
    GUICtrlSetData($progress_label_2, Lang("labels.status.installing_fabric"))
EndFunc

Func Status_SetParsingFilesAPI()
    GUICtrlSetData($progress_label_2, Lang("labels.status.parsing_files_api"))
EndFunc

Func Status_SetCheckingFiles()
    GUICtrlSetData($progress_label_2, Lang("labels.status.checking_files"))
EndFunc

Func Status_Hide()
    ; Hide everything
    GUICtrlSetState($progress_bar, 32)
    GUICtrlSetData($progress_label_1, "")
    GUICtrlSetData($progress_label_2, "")
EndFunc

Func MainWindowStatusBar($top)
    $progress_bar = GUICtrlCreateProgress(21, $top, 308, 20)
    ; Hide the progress bar
    GUICtrlSetState($progress_bar, 32)

    $progress_label_1 = GUICtrlCreateLabel("", 5, $top + 30, 330, 15, BitOR($SS_CENTER, $SS_CENTERIMAGE))

    $progress_label_2 = GUICtrlCreateLabel("", 5, $top + 50, 330, 15, BitOR($SS_CENTER, $SS_CENTERIMAGE))

    Return $top + 70
EndFunc
