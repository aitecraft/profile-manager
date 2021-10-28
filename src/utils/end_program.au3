#include-once
#include "write_prefs.au3"
#include "client_data.au3"
#include "log.au3"

Func EndProgram($actually_quit = True)
    Prefs_UpdateFile()
    CD_UpdateFile()

    If $actually_quit Then
        EndLog()
        Exit
    EndIf
EndFunc
