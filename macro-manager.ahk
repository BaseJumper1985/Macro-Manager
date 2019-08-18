#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
#SingleInstance, Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include add-macro-gui.ahk
SetCapsLockState, Off


; SetTimer, CheckIdle, 5000

; Menu, Tray, Add,% "Parse Clipboard Contents", ParseClipboard
; Menu, Tray, Add,% "Open INI File for Editing", OpenIni
Menu, Tray, Add,% "Reload This Program", ManReload
; Menu, Tray, Add,% "Create a New Macro", NewMacro

;INI file
iniFile := A_WorkingDir "\macros.ini"
IniRead, sections, % iniFile
IniRead, sectionEntries, % iniFile, % "Macros"
sectionList := StrSplit(sections, "`n")

global parsedIni := {} ; Mark as global because functions can't see any variables from outside otherwise.
listKeys := ""



; Create all the HotStrings and make a key lookup for other tasks.
ParseMacros:
Paste := Func("PasteText")
Loop, Parse, sectionEntries, `n
{
	splitKey := StrSplit(A_LoopField, "=")
	parsedIni[splitKey[1]] := RegExReplace(splitKey[2], "i)\\EOL", "`n")
	cKeys := CasedKeys(splitKey[1])
	MakeHotstrings(cKeys, Paste)
}

MacroSelector()
{
	static
	for k, v in parsedIni
	{
		MsgBox % parsedIni[k]
		listKeys := listKeys k "|"
	}
	listWidth := 100
	Gui, Add, ListBox, gListClicked vClickedItem r12 w%listWidth%,% listKeys
	Gui, Add, Text, vMacroPreview r12 xp+%listWidth%+5 wp+%listWidth%
	;Gui, Add, Radio, vRadioValue xp+%listWidth%+5, % "Normal"
	;Gui, Add, Radio, , % "Uppercase"
	;Gui, Add, Radio, , % "Titlecase"
	
	Gui, Add, Button, , Ok
	Gui, Show, Center, Test
	return
	
	ListClicked:
	Gui, Submit, Nohide
	GuiControl, , MacroPreview, % parsedIni[ClickedItem]
	; MsgBox % "Clicked an item!"
	return
}

CasedKeys(sKey)
{
	c := {}
	c["lower"] := Format("{1:l}",      sKey)
	c["upper"] := Format("{1:U}{2:l}", SubStr(sKey, 1, 1), SubStr(sKey, 2))
	c["title"] := Format("{1:U}",      sKey)
	return c
}

MakeHotstrings(cKeys, Paste)
{
	Hotstring(":CX:" cKeys["lower"] " ", Paste.Bind("lower"))
	Hotstring(":CX:" cKeys["upper"] " ", Paste.Bind("upper"))
	Hotstring(":CX:" cKeys["title"] " ", Paste.Bind("title"))
	return
}

PasteText(cased)
{
	cleanKey := Trim(RegExReplace(A_ThisHotkey, "^:\w*:"))
	cleanKey := format("{1}", cleanKey)
	iniValue := parsedIni[cleanKey]
	if (cased == "upper")
		output := Format("{1:U}{2}", SubStr(iniValue, 1, 1), SubStr(iniValue, 2))
	else if (cased == "title")
		output := Format("{1:t}", iniValue)	
	else if (cased == "lower")
		output := Format("{1}", iniValue)
	Clipboard := output
	sleep, 50
	Send, ^v
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
		for k, v in parsedIni
		{
			Modify := RegExReplace(Modify, "\b" k "\b", v)
		}
		Clipboard := Modify
		SendInput, ^v
	}
	return
*/

OpenIni()
{
	Run, notepad.exe %iniFile%
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