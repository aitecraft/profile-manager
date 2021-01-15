Func ReadLauncherProfiles()
   $launcher_config = json_decode(FileRead($configFileName))
EndFunc