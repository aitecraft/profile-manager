#include-once
#include "../utils/update.au3"
#include "../utils/lang_manager.au3"
#include "extras.au3"
#include <StaticConstants.au3>

Global $progress_bar
Global $progress_label_1
Global $progress_label_2

Func DownloadCallback($downloaded_count, $total_count, $downloaded_size, $total_broken, $total_size)
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

Func OnClick_StartButton()
    GUICtrlSetData($progress_label_1, Lang("labels.please_wait"))

    $res = InstallOrUpdate(False, DownloadCallback)

    ; Hide everything
    GUICtrlSetState($progress_bar, 32)
    GUICtrlSetData($progress_label_1, "")
    GUICtrlSetData($progress_label_2, "")

    If $res == "uptodate" Then
        QuickOKMsgBox_Lang("update_done.uptodate")
    ElseIf $res Then
        QuickOKMsgBox_Lang("update_done.success")
    Else
        ;0x10 - Error Icon
        QuickOKMsgBox_Lang("update_done.failure",0x10)
    EndIf
EndFunc

Func MainWindowUpdateGUI()
    $startButton = GUICtrlCreateButton(Lang("buttons.start"), 100, 20, 150, 80)
    GUICtrlSetOnEvent(-1, "OnClick_StartButton")

    $progress_bar = GUICtrlCreateProgress(21, 110, 308, 20)
    ; Hide the progress bar
    GUICtrlSetState(-1, 32)

    $progress_label_1 = GUICtrlCreateLabel("", 5, 140, 330, 15, BitOR($SS_CENTER, $SS_CENTERIMAGE))

    $progress_label_2 = GUICtrlCreateLabel("", 5, 160, 330, 15, BitOR($SS_CENTER, $SS_CENTERIMAGE))
EndFunc
