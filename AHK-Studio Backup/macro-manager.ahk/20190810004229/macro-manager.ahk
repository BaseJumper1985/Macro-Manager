#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
#SingleInstance, Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SetTimer, CheckIdle, 5000

; Menu, Tray, Add,% "Parse Clipboard Contents", ParseClipboard
; Menu, Tray, Add,% "Open INI File for Editing", OpenIni
Menu, Tray, Add,% "Reload This Program", ManReload
; Menu, Tray, Add,% "Create a New Macro", NewMacro

;INI file
IniFile := A_WorkingDir "\macros.ini"
IniRead, Sections, % IniFile
IniRead, SectionEntries, % IniFile, % "Macros"
SectionList := StrSplit(Sections, "`n")

ParsedIni := {} ; Mark as global because functions can't see any variables from outside otherwise.
SearchList := []

; Create all the HotStrings and make a key lookup for other tasks.
ParseMacros:
Loop, Parse, SectionEntries, `n
{
	splitKey := StrSplit(A_LoopField, "=")
	parsedIni[splitKey[1]] := RegExReplace(splitKey[2], "\\EOL", "`n")
	searchList.Push(SplitKey[1])
	fromattedKeys := 
	lowered := Format("{1:l}",      splitkey[1])
	uppered := Format("{1:U}{2:l}", SubStr(splitKey[1], 1, 1), SubStr(splitKey[1], 2))
	Titled  := Format("{1:U}",      splitKey[1])
	MakeHotstrings(sowered, uppered, titled)
}

FormatKeys(splits)
{
	
}

MakeHotstrings(l, u, t)
{
	Hotstring(":CX:" l " ", "PasteText")
	Hotstring(":CX:" u " ", "PasteUpper")	
	Hotstring(":CX:" t " ", "PasteTitled")
	return
}

PasteText(cased = "lower")
{
	global
	cleanKey := Trim(RegExReplace(A_ThisHotkey, "^:\w*:"))
	cleanKey := format("{1:l}", cleanKey)
	iniValue := parsedIni[cleanKey]
	if (cased == "upper")
		output := Format("{1:U}{2}", SubStr(output, 1, 1), SubStr(output, 2))
	else if (cased == "titled")
		output := Format("{1:t}", Output)	
	else ; default lower
		Output := Format("{1:l}", IniValue)
	Clipboard := Output
	Send, ^v
	return
}

PasteUpper()
{
	PasteText("upper")
	return
}

PasteTitled()
{
	PasteText("titled")
	return
}

/*
	ParseClipboard:
	MsgBox, 4097, , % "First select the text you want to modify then click Ok"
	IfMsgBox, Ok
	{
		Clipboard :=
		Send, ^c
		Sleep, 250
		Modify := Clipboard
		Sleep, 250
		for k, v in ParsedIni
		{
			Modify := RegExReplace(Modify, "\b" k "\b", v)
		}
		Clipboard := Modify
		SendInput, ^v
	}
	return
	
	
	
	CheckIdle:
	if (A_TimeIdle > 4000)
	{
		Suspend, On
		Suspend, Off
	}
	return
*/

OpenIni()
{
	Run, notepad.exe %IniFile%
	WinWait, % "macros.ini"
	Loop
	{
		if WinExist("macros.ini")
			sleep, 1000
		else
		{
			Reload
			break
		}
	}
}
return

ManReload()
{
	Reload
	return
}