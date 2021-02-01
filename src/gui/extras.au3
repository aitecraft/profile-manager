#include-once
#include "../utils/lang_manager.au3"
#include <MsgBoxConstants.au3>

Func NotImplementedMsgBox()
    MsgBox($MB_OK + $MB_ICONINFORMATION, Lang('todo.title'), Lang('todo.message'))
EndFunc

Func UnexpectedExitErrorMsgBox()
    MsgBox($MB_OK + $MB_ICONINFORMATION, Lang('errors.unexpected_exit.title'), Lang('errors.unexpected_exit.message'))
EndFunc

Func OpenFolder()

EndFunc

