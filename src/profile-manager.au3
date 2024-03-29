#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#AutoIt3Wrapper_Icon=aitecraft.ico
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Description=Aitecraft Profile Manager
#AutoIt3Wrapper_Res_Fileversion=0.8.0.0
#AutoIt3Wrapper_Res_ProductName=Aitecraft Profile Manager
#AutoIt3Wrapper_Res_ProductVersion=beta-0.8.0
#AutoIt3Wrapper_Res_CompanyName=Aitecraft
#AutoIt3Wrapper_Res_LegalCopyright=MIT License
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "utils/read_config.au3"
#include "utils/lang_manager.au3"
#include "gui/core.au3"
#include "utils/client_data.au3"
#include "utils/log.au3"
#include "utils/version.au3"

; Initialize
InitLog()
LogWrite("Profile Manager Version: " & $version)

LoadConfig()
LoadLanguageList()
LoadLang(Config_GetLang())
CD_LoadData()

; GUI
InitGUI()

; Keep GUI alive
While 1
    Sleep(100)
WEnd
