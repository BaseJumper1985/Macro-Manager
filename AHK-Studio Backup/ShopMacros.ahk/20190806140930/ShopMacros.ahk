#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
#SingleInstance, Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SetTimer, CheckIdle, 5000

Menu, Tray, Add,% "Open INI File for Editing", OpenIni
Menu, Tray, Add,% "Reload This Program", ManReload

;INI file
IniFile = %A_WorkingDir%\macros.ini
IniRead, Sections, %IniFile%
IniRead, SectionEntries, %IniFile%, % "Macros"
SectionList := StrSplit(Sections, "`n")

ParsedIni := {}
Loop, Parse, SectionEntries, `n
{
	SplitKey := StrSplit(A_LoopField, "=")
	ParsedIni[SplitKey[1]] := SplitKey[2]
}

if "rofl" in ParsedIni
{
	MsgBox % "Found it!"
}
;Main program loop
Loop
{
	Matcher := ""
	MatchLen := 0
	Punct := ""
	Loop
	{
		TimedOut:
		Input, Letter, V L1 T2, {Left}{Right}{Up}{Down}{BackSpace}^c^x^a
		if (ErrorLevel = "TimeOut")
		{
			Suspend, On
			Suspend, Off
			Goto, TimedOut
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
	for k, v in ParsedIni
	{
		SetKeyDelay, -1, -1
		if (k == Matcher)
		{
			SendInput, {BackSpace %MatchLen%}
			temp := ClipboardAll
			Clipboard := v Punct
			SendInput, ^v
			Clipboard := temp
		}
	}
}

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

ManReload:
Reload
return