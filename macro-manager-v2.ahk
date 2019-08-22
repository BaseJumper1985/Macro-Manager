; ========================
; Auto Execute Section
; ========================
#Warn  ; enable warnings to assist with detecting common errors
#Persistent ; make sure the program does not shut down on its own
#SingleInstance ; only one copy of the program is allowed open at a time
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory

; global variables: Keep this very small and only when it makes good sense.
global iniFile := A_WorkingDir "\macros.ini" ; get the path to the ini file for later use
global parsedIni := ParseIni(iniFile, "Macros") ; parse the ini file and set the contents of parsedIni to match

global GhotUse := GuiInsertHotstring() ; get object of the gui for hotstring insertion
global GhotModify := GuiEditHotstrings() ; get object of the gui for hotstring modifcation/addition/deletion

fMenu := MenuCreate() ; create the right click menu for use with the programs gui elements
fMenu.Add("Insert Hotstring Here.", (*) => GhotUse.Show()) ; open insert hotstring dialog
fMenu.Add("Convert Text", (*) => ParseSelection()) ; open parse text and replace with hotsting results dialog
fMenu.Add("Edit Hotstrings", (*) => GhotModify.Show()) ; open modify hotstring dialog
Hotkey("#RButton", (*) => fMenu.Show()) ; assign control + right mouse button to open a small popup manu
PopMenu(ByRef item) {
	item.Show()
	return
}

Hotkey("#h", (*) => GhotUse.Show())

trayMenu := A_TrayMenu
trayMenu.Delete()
trayMenu.Add("Edit Hotstrings", (*) => GhotModify.Show()) ; open modify hotstring dialog
trayMenu.Add("Take a Break", (*) => TakeBreak(trayMenu))
trayMenu.Add("Exit", (*) => ExitApp())
TakeBreak(this) {
	Suspend()
	this.ToggleCheck("Take a Break")
}

MakeAllHotstrings() ; starts the main process and creates all the hotstrings from the ini file

/*
Hotkey("~LShift & ~RShift", (*) => SetCapsLockState("On"))
Hotkey("~LShift", (*) => SetCapsLockState("Off"))
Hotkey("~RShift", (*) => SetCapsLockState("Off"))


+CapsLock::return		; Shift+CapsLock
!CapsLock::return		; Alt+CapsLock
^CapsLock::return		; Ctrl+CapsLock
#CapsLock::return		; Win+CapsLock
^!CapsLock::return	; Ctrl+Alt+CapsLock
^!#CapsLock::return	; Ctrl+Alt+Win+CapsLock
Capslock::
CaspsEscCtrl() {
	canLoop := 1
	Loop {
		if (GetKeyState("Capslock", "P")) {
			if (canLoop = 1) {
				Send("{LControl Down}")
				canLoop := 0
			}
			Sleep(50)
		}
		else {
			Send("{LControl Up}")
			return
		}
	}
}
#WheelDown::Send("{Blind}^#{Right}")
#WheelUp::Send("{Blind}^#{Left}")
 ; For MouseIsOver, see #If example 1.
WheelUp::
MouseGetPos(, , , traybar)
if (traybar = "ToolbarWindow323")
	Send "{Volume_Up}"     ; Wheel over taskbar: increase/decrease volume.
else
	Send "{WheelUp}"
return
WheelDown::
MouseGetPos(, , , traybar)
if (traybar = "ToolbarWindow323")
	Send "{Volume_Down}"     ; Wheel over taskbar: increase/decrease volume.
else
	Send "{WheelDown}"
return
*/


; ========================
; Make All Hotstrings
; ========================
MakeAllHotstrings() {
	; Create all the HotStrings and make a key lookup for other tasks.
	for k, v in parsedIni
	{
		SetHotstrings(k)
	}
}

GetIniSectionArray(file, header) {
	sectionEntry := IniRead(file, header) ; get section from ini file
	sectionList := StrSplit(sectionEntry, "`n") ; split each line of section into array
	return sectionList ; return the array
}


ParseIni(file, header) {
	KeyArray := {}
	SectionArray := GetIniSectionArray(file, header)
	for k, v in SectionArray
	{
		splitKey := StrSplit(v, "=")
		KeyArray[splitKey[1]] := RegExReplace(splitKey[2], "i)\\EOL", "`n")
	}
	return KeyArray
}

; takes input string and creats two other versions eg. lol/Lol/LOL
; these are used in the different types of key replacements
CasedKeys(sKey) {
	c := [] ; case modified keys
	c[1] := Format("{1:l}",      sKey) ; format key all lower case
	c[2] := Format("{1:U}{2:l}", SubStr(sKey, 1, 1), SubStr(sKey, 2)) ; format key senetence case
	c[3] := Format("{1:U}",      sKey) ; format key all caps
	return c
}

; set hotstring from a given list of cased keys
SetHotstrings(key, stringEnable := 1) {
	cKeys := CasedKeys(key)
	for x in cKeys
	{
		Hotstring(":CX:" cKeys[x] " ", "PasteText", stringEnable)
	}
	return
}

FormatText(hKey) {
	cleanKey := Trim(RegExReplace(hKey, "^:\w*:"))
	iniValue := parsedIni[cleanKey] ; parsedIni is global
	if (RegExMatch(cleanKey, "^[A-Z][a-z]+$")) {
		output := Format("{1:U}{2}", SubStr(iniValue, 1, 1), SubStr(iniValue, 2))
	} else if (RegExMatch(cleanKey, "^[A-Z]+$")) {
		output := Format("{1:t}", iniValue)	
	} else {
		output := Format("{1}", iniValue)
	}
	return output
}

PasteText() {
	output := FormatText(A_ThisHotkey)
	Clipboard := output
	sleep(50)
	Send("^v")
	return
}

ParseSelection(*) {
	result := MsgBox("First select the text you want to modify then click Ok", "Convert Selection", "OC " 262144)
	if (result = "Ok") {
		Send("^c")
		Sleep(250)
		Modify := Clipboard
		Sleep(250)
		for k, v in parsedIni { ; parsedIni is global
			Modify := RegExReplace(Modify, "i)\b" k "\b", v)
		}
		Clipboard := Modify
		Sleep(250)
		SendInput("^v")
	}
	return
}

; ========================
; Gui Utilities
; ========================

; ------------------------
; Menubar Controls
; ------------------------

GuiHotstringMenuBar(helpText) {
	files := MenuCreate()
	files.Add("&Exit", (*) => ExitApp())
	help := MenuCreate()
	help.Add("Open &Help", (*) => MsgBox(helpText, "Help"))
	menus := MenuBarCreate()
	menus.Add("File", files)
	menus.Add("Help", help)
	return menus
}

; ------------------------
; Insert Hotstring From List
; ------------------------

GuiInsertHotstring() {
	helpText := "
	(
		Use the Search field at the top left to find a hotstring.
		Pressing Enter will select the top item from the list and
		paste its result into the last focused window.

		You can also change the formatting of the text by selecting
		one of the options on the right then Clicking [Okay] or
		Double Clicking the Hotstring in the List.
	)"
	Gui := GuiCreate()
	Gui.MenuBar := GuiHotstringMenuBar(helpText)
	Gui.SetFont("s12")
	Gui.Title := "Insert Hotstring"
	listKeys := GetIniKeys()
	gSearch := Gui.Add("Edit", , "Search")
	gList := Gui.Add("ListBox", "section w200 r12", listKeys)
	gList.Name := "hotstringList"
	
	gText := Gui.Add("Text", "w320 r8" , "this is text")

	radioGroup := Gui.Add("Radio", "checked xs+210 ys", "Paste without changes.")
	Gui.Add("Radio", , "Capitalize First Letter.")
	Gui.Add("Radio", , "Title Case Entire Phrase.")
	radioGroup.Name := "radioGroup"
	
	gOkay := Gui.Add("Button", "default section", "Okay")
	gCancel := Gui.Add("Button", "ys", "Cancel")

	gSearch.OnEvent("Change", (*) => SearchList())
	gSearch.OnEvent("Focus", (*) => Send("^a"))
	gList.OnEvent("Change", (*) => gText.Text := parsedIni[gList.Text]) ; => single line function to assign a value. Java inspired
	gList.OnEvent("DoubleClick", (*) => PlaceText())
	gOkay.OnEvent("Click", (*) => PlaceText())
	gOkay.OnEvent("Click", (*) => GuiListUpdate())
	gCancel.OnEvent("Click", (*) => Gui.Hide())
	gCancel.OnEvent("Click", (*) => GuiListUpdate())
	Gui.OnEvent("Size", (*) => GuiListUpdate())
	Gui.OnEvent("Close", (*) => GuiListUpdate())
	return Gui
	
	PlaceText(*) {
		Gui.Hide() ; always make sure to submit before checking values
		cKeys := CasedKeys(gList.Text)
		result := Gui.Submit(0)
		rv := result["radioGroup"]
		Gui.Control["radioGroup"].Value := 1
		ClipBoard := FormatText(cKeys[rv])
		WinWaitNotActive("Insert Hotstring")
		; sleep(50)
		; ClipBoard := parsedIni[l.Text]
		send("^v")
	}

	SearchList(*) {
		term := gSearch.Text
		letters := StrSplit(term)
		tempKeyList := GetIniKeys()
		gList.Delete()
		matchedCount := 0
		for x in tempKeyList {
			regTerm := ".*"
			for c in  letters {
				regTerm .= "[" letters[c] "].*"
			}
			matched := RegExMatch(tempKeyList[x], regTerm)
			if (matched) {
				gList.Add(tempKeyList[x])
				matchedCount += matched
			}

		}
		if (matchedCount) {
			gList.Choose(1)
			gText.Text := parsedIni[gList.Text]

		}
		;MsgBox(regTerm)
	}
}

; ------------------------
; Add/Remove Hostrings
; ------------------------

GuiEditHotstrings() {
	helpText := "
	(
		You can use this window to:
		Create, Edit, and Delete Hotstrings

		To add a new Hotstring, simply fill in the [Box] at
		the top of the window with a new Hotstring then type the
		result of the Hotstring in the box below and click [Apply]

		To Delete a Hotstring, select the Hotstring from the List
		on the left then click [Delete Hotstring]

		To Edit a Hotstring, select a Hotstring from the List on the
		left then change result of the Hotstring in the [Box] to
		the right before clicking [Apply]
	)"
	Gui := GuiCreate()
	Gui.Title := "Edit Hotstrings"
	Gui.MenuBar := GuiHotstringMenuBar(helpText)
	Gui.SetFont("s12")
	listKeys := GetIniKeys()
	gList := Gui.Add("ListBox", "section w200 r12", listKeys)
	gList.Name := "hotstringList"
	gDelete := Gui.Add("Button", "", "Delete Hotstring")
	gText := Gui.Add("Text", "ys", "New Hotstring")
	gInput := Gui.Add("Edit", "ys r1 w200") ; hotstring input box
	gAdd := Gui.Add("Button", "ys h" gInput.Pos.H, "Apply")
	gEdit := Gui.Add("Edit", Format("r12 x{1} y{2} w400 WantTab" ; hotstring result editor
							, gText.Pos.X, gText.Pos.Y+35), "Place hotstring result here")
	
	
	gLIst.OnEvent("Change", (*) => SetText()) ; => single line function to assign a value. Java inspired
	gDelete.OnEvent("Click", (*) => GuiRemoveHotstrings(gList.Text))
	gAdd.OnEvent("Click", (*) => GuiModifyLine(gInput.Text, gEdit.Text))
	;GuiListUpdate()
	return Gui

	GuiModifyLine(key, value) {
		newValue := RegExReplace(value, "\R", "\eol")
		IniWrite(newValue, iniFile, "Macros", key) ; write the new key and value the ini file
		sleep 80 ; wait for 80 miliseconds as writes may not finish before the program moves on
		SetHotstrings(key, 1) ; create the hotstrings and make sure they are enabled
		parsedIni[key] := newValue
		GuiListUpdate()
		;GuiResets()
	}

	; set the input field and the edit box the reflect the current selection
	; in the list box control
	SetText() {
		gEdit.Text := parsedIni[gList.Text]
		gInput.Text := gList.Text
	}

	; resets the hotstring insertion gui so it gets any channged values
	GuiResets() {
		GhotUse.Destroy()
		GhotUse := GuiInsertHotstring()
	}

	GuiRemoveHotstrings(deleter) {
		; get confirmation from the user before continuing
		confirm := MsgBox("Are you sure you want to delete the hotstring [" deleter "]`nand its resulting text`n" parsedIni[deleter], "Confirm", "YN")
		if (confirm = "Yes") {
			IniDelete(iniFile, "Macros", deleter) ; remove the line from the ini file
			parsedIni.Delete(deleter) ; remove key from assosiative array of hotstrings
			GuiListUpdate() ; destroy and rebuild relavent guis
			;gList.Delete(gList.Value) ; remove matching value from the list
			SetHotstrings(deleter, 0) ; desable all hotstring with (enable=0)
		}

	}
}

; update the list box contents to reflect the new contents of the parsedIni array
GetIniKeys() {
	listItems := []
	for k, v in parsedIni {
		listItems.Push(k)
	}
	return listItems
}

GuiListUpdate() {
	g := [GhotUse, GhotModify]
	for x in g {
		l := g[x].Control["hotstringList"]
		l.Delete()
		l.Add(GetIniKeys())
	}
}

; ========================
; 
; ========================

ManReload(*) {
	Reload
	return
}