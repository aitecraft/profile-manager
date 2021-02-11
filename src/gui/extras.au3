#include-once
#include "../utils/lang_manager.au3"
#include "libs/CustomMsgBox.au3"

Func QuickOKMsgBox($title, $message, $flags = $mbInformation)
    xMsgBox($flags, $title, $message, Lang('buttons.ok'))
EndFunc

Func QuickOKMsgBox_Lang($lang_str, $flags = $mbInformation)
    QuickOKMsgBox(Lang($lang_str & '.title'), Lang($lang_str & '.message'), $flags)
EndFunc

Func NotImplementedMsgBox()
    ;MsgBox($MB_OK + $MB_ICONINFORMATION, Lang('todo.title'), Lang('todo.message'))
    ;xMsgBox($mbInformation, Lang('todo.title'), Lang('todo.message'), Lang('buttons.ok'))
    ;QuickOKMsgBox(Lang('todo.title'), Lang('todo.message'))
    QuickOKMsgBox_Lang("todo")
EndFunc

Func UnexpectedExitErrorMsgBox()
    ;MsgBox($MB_OK + $MB_ICONINFORMATION, Lang('errors.unexpected_exit.title'), Lang('errors.unexpected_exit.message'))
    ;QuickOKMsgBox(Lang('errors.unexpected_exit.title'), Lang('errors.unexpected_exit.message'), $mbCritical)
    QuickOKMsgBox_Lang("errors.unexpected_exit", $mbCritical)
EndFunc

Func UnsupportedAPIFormatVersionMsgBox()
    QuickOKMsgBox_Lang("errors.unsupported_api_format_version", $mbCritical)
    ;QuickOKMsgBox(Lang('errors.unsupported_api_format_version.title'), Lang('errors.unsupported_api_format_version.message'), $mbCritical)
    ;MsgBox($MB_OK + $MB_ICONINFORMATION, Lang('errors.unsupported_api_format_version.title'), Lang('errors.unsupported_api_format_version.message'))
EndFunc

Func OpenFolder()

EndFunc

