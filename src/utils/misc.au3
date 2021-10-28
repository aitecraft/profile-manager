#include-once
#include <Math.au3>

Func CreateFolder($folder)
    NormalizePath($folder)
    If Not FileExists($folder) Then
        DirCreate($folder)
    EndIf
EndFunc

Func CreateFolderFromFilePath($path)
    $lastSlashPos = _Max(StringInStr($path, "/", 1, -1), StringInStr($path, "\", 1, -1))
    
    If $lastSlashPos > 0 Then
        $folder = StringLeft($path, $lastSlashPos)
        CreateFolder($folder)
    EndIf
EndFunc

Func NormalizePath(ByRef $path)
    $path = StringReplace($path, "/", "\")
EndFunc
