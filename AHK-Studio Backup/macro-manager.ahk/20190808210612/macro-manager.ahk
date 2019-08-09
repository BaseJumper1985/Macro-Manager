#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
#SingleInstance, Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SetTimer, CheckIdle, 5000

; Menu, Tray, Add,% "Parse Clipboard Contents", ParseClipboard
; Menu, Tray, Add,% "Open INI File for Editing", OpenIni
Menu, Tray, Add,% "Reload This Program", % ManReload()

;INI file
IniFile = %A_WorkingDir%\macros.ini
IniRead, Sections, %IniFile%
IniRead, SectionEntries, %IniFile%, % "Macros"
SectionList := StrSplit(Sections, "`n")

ParsedIni := {}
SearchList := []

; Create all the HotStrings and make a key lookup for other tasks.
Loop, Parse, SectionEntries, `n
{
	SplitKey := StrSplit(A_LoopField, "=")
	SearchList.Push(SplitKey[1])
	Hotstring("::" SplitKey[1] " ", SplitKey[2])
	ParsedIni[SplitKey[1]] := SplitKey[2]
}

/* This may no longer be needed becuase I am stupid.
	
;Main program loop
Loop
{
	Matcher := ""
	MatchLen := 0
	Punct := ""
	Loop
	{
		Input, Letter, V L1 T2, {Left}{Right}{Up}{Down}{BackSpace}^c^x^a
		if (ErrorLevel = "TimeOut")
		{
			Suspend, On
			Suspend, Off
			continue
		}
		if Letter is not alpha
		{
			if Letter is not digit
			{
				MatchLen := MatchLen + 1
				Punct := Letter
				break
			}
		}
		if (Letter = "")
		{
			Matcher := ""
			MatchLen := 0
		}
		else
		{
			Matcher := Matcher Letter
			MatchLen := StrLen(Matcher)
		}
	}
	if (Matcher = "")
		continue
	if (ParsedIni.HasKey(Matcher))
	{
		SetKeyDelay, -1, -1
		SendInput, {BackSpace %MatchLen%}
		temp := ClipboardAll
		Clipboard := ParsedIni[Matcher] Punct
		SendInput, ^v
		sleep, 500
		Clipboard := temp
		ClipWait, 0, 1
	}
}
*/
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


OpenIni:
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
return

CheckIdle:
if (A_TimeIdle > 4000)
{
	Suspend, On
	Suspend, Off
}
return
*/

ManReload()
{
	Reload
	return
}