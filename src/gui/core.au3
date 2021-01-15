#include "main_window.au3"

Func InitGUI()
    Opt("GUIOnEventMode", 1)
    Opt("GUICloseOnESC", 0)

    CreateMainWindow()
    ShowMainWindow()
EndFunc