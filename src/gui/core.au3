#include "main_window.au3"

Func InitGUI()
    ; Enable GDI Scaling
    If @OSVersion = 'WIN_10' Then DllCall("User32.dll", "bool", "SetProcessDpiAwarenessContext" , "HWND", "DPI_AWARENESS_CONTEXT" -5)
    
    Opt("GUIOnEventMode", 1)
    Opt("GUICloseOnESC", 0)

    CreateMainWindow()
    ShowMainWindow()
EndFunc