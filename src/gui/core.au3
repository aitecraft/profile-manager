#include "main_window.au3"
#include "../utils/log.au3"

Func InitGUI()
    LogWrite("[GUI] Initializing")

    ; Enable GDI Scaling
    If @OSVersion = 'WIN_10' Then DllCall("User32.dll", "bool", "SetProcessDpiAwarenessContext" , "HWND", "DPI_AWARENESS_CONTEXT" -5)
    
    Opt("GUIOnEventMode", 1)
    Opt("GUICloseOnESC", 0)

    CreateMainWindow()
    ShowMainWindow()

    LogWrite("[GUI] Initialized")
EndFunc