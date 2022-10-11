#include-once
#include <JSON.au3>
#include <FileConstants.au3>
#include "http.au3"
#include "misc.au3"

Func Json_ToString(ByRef $json_obj)
    Return Json_Encode_Pretty($json_obj, $JSON_PRETTY_PRINT + $JSON_UNESCAPED_SLASHES, "    ", "," & @CRLF, "," & @CRLF, ": " )
EndFunc

Func Json_ToFile($path, ByRef $json_obj)
    CreateFolderFromFilePath($path)
    $file = FileOpen($path, $FO_OVERWRITE)
    FileWrite($file, Json_ToString($json_obj))
    FileClose($file)
EndFunc

Func Json_Parse($json, $strip = False)
    If $strip Then $json = Json_Strip($json)
    Return Json_Decode($json)
EndFunc

Func Json_FromFile($path, $strip = False)
    Return Json_Parse(FileRead($path), $strip)
EndFunc

Func Json_FromURL($url, $strip = False)
    Return Json_Parse(HttpGet($url), $strip)
EndFunc

; Following Comments and Comma stripping code is derived from
; https://github.com/sindresorhus/strip-json-comments
; (MIT License)
Func Json_Strip($str)
    Const $singleComment = 1
    Const $multiComment = 2

    $isInsideString = False
    $isInsideComment = False
    $offset = 0
    $buffer = ""
    $result = ""
    $commaIndex = -1

    For $index = 0 To StringLen($str)
        $currentCharacter = StringMid($str, $index + 1, 1)
        $nextCharacter = StringMid($str, $index + 2, 1)

        If ((Not $isInsideComment) And $currentCharacter == '"') Then
            If (Not isEscaped($str, $index)) Then
                $isInsideString = Not $isInsideString
            EndIf
        EndIf

        If ($isInsideString) Then
            ContinueLoop
        EndIf

        If ((Not $isInsideComment) And $currentCharacter & $nextCharacter == "//") Then
            $buffer &= slice($str, $offset, $index)
            $offset = $index
            $isInsideComment = $singleComment
            $index += 1
        ElseIf ($isInsideComment = $singleComment And $currentCharacter & $nextCharacter == @CRLF) Then
            $index += 1
            $isInsideComment = False
            $offset = $index
            ContinueLoop
        ElseIf ($isInsideComment = $singleComment And $currentCharacter == @LF) Then
            $isInsideComment = False
            $offset = $index
        ElseIf ((Not $isInsideComment) And $currentCharacter & $nextCharacter == "/*" ) Then
            $buffer &= slice($str, $offset, $index)
            $offset = $index
            $isInsideComment = $multiComment
            $index += 1
            ContinueLoop
        ElseIf ($isInsideComment = $multiComment And $currentCharacter & $nextCharacter == "*/") Then
            $index += 1
            $isInsideComment = False
            $offset = $index + 1
            ContinueLoop
        ElseIf (Not $isInsideComment) Then
            If ($commaIndex <> -1) Then
                If ($currentCharacter == "}" Or $currentCharacter == "]") Then
                    $buffer &= slice($str, $offset, $index)
                    $result &= slice($buffer, 1)
                    $buffer = ""
                    $offset = $index
                    $commaIndex = -1
                ElseIf ($currentCharacter <> " " And $currentCharacter <> @TAB And $currentCharacter <> @CR And $currentCharacter <> @LF) Then
                    $buffer &= slice($str, $offset, $index)
                    $offset = $index
                    $commaIndex = -1
                EndIf
            ElseIf ($currentCharacter == ",") Then
                $result &= $buffer & slice($str, $offset, $index)
                $buffer = ""
                $offset = $index
                $commaIndex = $index
            EndIf
        EndIf
    Next

    Return $result & $buffer & slice($str, $offset)
EndFunc

Func slice($str, $start, $end = -1)
    If $end = -1 Then $end = StringLen($str)
    If $end <= $start Then Return ""

    Return StringMid($str, $start + 1, $end - $start)
EndFunc

Func isEscaped($str, $quotePosition)
    $index = $quotePosition - 1
    $backslashCount = 0

    While (StringMid($str, $index + 1, 1) == "\") 
		$index -= 1;
		$backslashCount += 1;
	Wend

    Return (Mod($backslashCount, 2) <> 0)
EndFunc
