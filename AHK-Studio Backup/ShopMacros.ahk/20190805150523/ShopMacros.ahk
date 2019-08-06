Menu, Tray, Add,% "Reload This Program", ManReload
Menu, Tray, Add,% "Open INI File for Editing", OpenIni

;INI file
IniFile = %A_WorkingDir%\macros.ini
IniRead, Sections, %IniFile%
SectionList := StrSplit(Sections, "`n")

;Main program loop
Loop
{
	Matcher := ""
	MatchLen := 0
	Punct := ""
	Loop
	{
		Input, Letter, V L1, {BackSpace}
		if Letter is not alpha
		{
			if Letter is not digit
			{
				MatchLen := MatchLen + 1
				Punct = %Letter%
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
			Matcher = %Matcher%%Letter%
			MatchLen := StrLen(Matcher)
		}
	}
	if (Matcher = "")
		continue
	Loop, % SectionList.MaxIndex()
	{
		SetKeyDelay, -1, -1
		IniRead, Phrase, %IniFile%, % SectionList[A_Index], %Matcher%
		if (Phrase != "ERROR")
		{
			SendInput, {BackSpace %MatchLen%}
			Clipboard = %Phrase%%Punct%
			SendInput, ^v
		}
	}
}
ExitApp

OpenIni:
Run, notepad.exe %IniFile%
WinWait,% "macros.ini"
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

ManReload:
Reload
return#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Menu, Tray, Add,% "Reload This Program", ManReload
Menu, Tray, Add,% "Open INI File for Editing", OpenIni

;INI file
IniFile = %A_WorkingDir%\macros.ini
IniRead, Sections, %IniFile%
SectionList := StrSplit(Sections, "`n")

;Main program loop
Loop
{
	Matcher := ""
	MatchLen := 0
	Punct := ""
	Loop
	{
		Input, Letter, V L1, {BackSpace}
		if Letter is not alpha
		{
			if Letter is not digit
			{
				MatchLen := MatchLen + 1
				Punct = %Letter%
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
			Matcher = %Matcher%%Letter%
			MatchLen := StrLen(Matcher)
		}
	}
	if (Matcher = "")
		continue
	Loop, % SectionList.MaxIndex()
	{
		SetKeyDelay, -1, -1
		IniRead, Phrase, %IniFile%, % SectionList[A_Index], %Matcher%
		if (Phrase != "ERROR")
		{
			SendInput, {BackSpace %MatchLen%}
			Clipboard = %Phrase%%Punct%
			SendInput, ^v
		}
	}
}
ExitApp

OpenIni:
Run, notepad.exe %IniFile%
WinWait,% "macros.ini"
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

ManReload:
Reload
return