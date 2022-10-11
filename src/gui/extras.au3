#include-once
#include "../utils/lang_manager.au3"
#include "libs/CustomMsgBox.au3"
#include "../utils/misc.au3"
#include "../utils/log.au3"

Func QuickOKMsgBox($title, $message, $flags = $mbInformation)
    xMsgBox($flags, $title, $message, Lang('buttons.ok'))
EndFunc

Func QuickOKMsgBox_Lang($lang_str, $flags = $mbInformation)
    QuickOKMsgBox(Lang('msgboxes.' & $lang_str & '.title'), Lang('msgboxes.' & $lang_str & '.message'), $flags)
EndFunc

Func QuickOKMsgBox_LangDynamic($lang_str, $dict, $flags = $mbInformation)
    QuickOKMsgBox(LangDynamic('msgboxes.' & $lang_str & '.title', $dict), LangDynamic('msgboxes.' & $lang_str & '.message', $dict), $flags)
EndFunc

Func QuickYesNoMsgBox($title, $message, $flags = $mbInformation)
    Return xMsgBox($MB_YESNO + $flags, $title, $message, Lang("buttons.yes"), Lang("buttons.no"))
EndFunc

Func QuickYesNoMsgBox_LangDynamic($lang_str, $dict, $flags = $mbInformation)
    Return QuickYesNoMsgBox(LangDynamic('msgboxes.' & $lang_str & '.title', $dict), LangDynamic('msgboxes.' & $lang_str & '.message', $dict), $flags)
EndFunc

Func QuickYesNoMsgBox_Lang($lang_str, $flags = $mbInformation)
    Return QuickYesNoMsgBox(Lang('msgboxes.' & $lang_str & '.title'), Lang('msgboxes.' & $lang_str & '.message'), $flags)
EndFunc

Func NotImplementedMsgBox()
    ;MsgBox($MB_OK + $MB_ICONINFORMATION, Lang('todo.title'), Lang('todo.message'))
    ;xMsgBox($mbInformation, Lang('todo.title'), Lang('todo.message'), Lang('buttons.ok'))
    ;QuickOKMsgBox(Lang('todo.title'), Lang('todo.message'))
    QuickOKMsgBox_Lang("todo")
EndFunc

Func UnexpectedExitErrorMsgBox($error_trace = "", $error_lang_str = "", $error_additional_info = "")
    LogWrite("[ERROR] Unexpected Exit Error called. More details below:")
    LogWrite("Error Trace: " & $error_trace)
    LogWrite("Error Additional Info: " & $error_additional_info)
    LogWrite("Error Language String: " & $error_lang_str)
    LogWrite("Translated Error Title: " & Lang("errors." & $error_lang_str & ".title"))
    LogWrite("Translated Error Message: " & Lang("errors." & $error_lang_str & ".message"))
    
    If $error_trace == "" Then
        UnexpectedExitErrorMsgBoxBackup()
    Else
        If $error_lang_str == "" Then
            $error_lang_str = "unexpected_error_fallback"
        EndIf

        $ob = ObjCreate("Scripting.Dictionary")
        $ob.Add("error-title", Lang("errors." & $error_lang_str & ".title"))
        $ob.Add("error-message", Lang("errors." & $error_lang_str & ".message"))
        $ob.Add("error-trace", $error_trace)
        $ob.Add("error-extra", $error_additional_info)

        QuickOKMsgBox_LangDynamic("errors.unexpected_error_template", $ob, $mbCritical)
    EndIf
EndFunc

Func UnexpectedExitErrorMsgBoxBackup()
    QuickOKMsgBox_Lang("errors.unexpected_exit", $mbCritical)
EndFunc

Func UnsupportedAPIFormatVersionMsgBox()
    LogWrite("[ERROR] Unsupported API Format Version.")
    QuickOKMsgBox_Lang("errors.unsupported_api_format_version", $mbCritical)
    ;QuickOKMsgBox(Lang('errors.unsupported_api_format_version.title'), Lang('errors.unsupported_api_format_version.message'), $mbCritical)
    ;MsgBox($MB_OK + $MB_ICONINFORMATION, Lang('errors.unsupported_api_format_version.title'), Lang('errors.unsupported_api_format_version.message'))
EndFunc

Func HTTPErrorMsgBox()
    QuickOKMsgBox_Lang("errors.http_error", $mbCritical)
EndFunc

Func OpenFolder($path)
    If Not FileExists($path) Then
        LogWrite("[OPEN FOLDER] Non existant folder (" & $path & ") requested to be opened.")
        $yesno = QuickYesNoMsgBox_Lang("folder_doesnt_exist")
        If $yesno = 6 Then
            LogWrite("[OPEN FOLDER] Created new folder at " & $path )
            CreateFolder($path)
        Else
            Return
        EndIf
    EndIf
    Run("explorer /e, " & '"' & $path & '"')
EndFunc

Func OpenInBrowser($url)
    ShellExecute($url)
EndFunc

Func AskUserForMCDir($mainWindowHandle)
    Return FileSelectFolder(Lang("labels.select_new_mc_dir"), "", 0, "", $mainWindowHandle)
EndFunc
