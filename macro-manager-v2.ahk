; #Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.

; global variables: Keep this very small and only when it makes good sense.
global iniFile := A_WorkingDir "\macros.ini" ; get the path to the ini file for later use
global parsedIni := ParseIni(iniFile, "Macros") ; parse the ini file and set the contents of parsedIni to match
global GhotUse := GuiInsertHotstring() ; get object of the gui for hotstring insertion
global GhotModify := GuiEditHotstrings() ; get object of the gui for hotstring modifcation/addition/deletion

fMenu := MenuCreate() ; create the right click menu for use with the programs gui elements
fMenu.Add("Insert Hotstring Here.", (*) => GhotUse.Show()) ; open insert hotstring dialog
fMenu.Add("Convert Text", "ParseSelection") ; open parse text and replace with hotsting results dialog
fMenu.Add("Edit Hotstrings", (*) => GhotModify.Show()) ; open modify hotstring dialog
Hotkey("#RButton", (*) => PopMenu(fMenu)) ; assign control + right mouse button to open a small popup manu
PopMenu(ByRef item) {
	item.Show()
	return
}

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
	if (RegExMatch(cleanKey, "^[A-Z][a-z]+$"))
		output := Format("{1:U}{2}", SubStr(iniValue, 1, 1), SubStr(iniValue, 2))
	else if (RegExMatch(cleanKey, "^[A-Z]+$"))
		output := Format("{1:t}", iniValue)	
	else
		output := Format("{1}", iniValue)
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
; Insert Hotstring From List
; ------------------------

GuiInsertHotstring() {
	listItems := []
	for k, v in parsedIni
		listItems.Push(k)
	Gui := GuiCreate()
	Gui.SetFont("s12")
	lHot := Gui.Add("ListBox", "section w200 r12", listItems)
	tHot := Gui.Add("Text", "w320 r8" , "this is text")

	radioGroup := [Gui.Add("Radio", "checked xs+210 ys", "Paste without changes.")
				,Gui.Add("Radio", , "Capitalize first letter.")
				,Gui.Add("Radio", , "Titlecase entire phrase.")]
	
	bHot := Gui.Add("Button", "default section", "Okay")
	cHot := Gui.Add("Button", "ys", "Cancel")

	lHot.OnEvent("Change", (*) => tHot.Value := parsedIni[lHot.Text]) ; => single line function to assign a value. Java inspired
	lHot.OnEvent("DoubleClick", (*) => PlaceText())
	bHot.OnEvent("Click", (*) => PlaceText())
	cHot.OnEvent("Click", (*) => Gui.Hide())
	return Gui
	
	PlaceText(*) {
		Gui.Hide() ; always make sure to submit before checking values
		cKeys := CasedKeys(lHot.Text)
		for k in radioGroup
		{
			if (radioGroup[k].Value = 1) { ; check if value = 1 to show button is marked
				Clipboard := FormatText(cKeys[k]) ; show text of radio button to verify
				radioGroup[k].Value := 0
			}
		}
		radioGroup[1].Value := 1
		sleep(50)
		; ClipBoard := parsedIni[l.Text]
		send("^v")
	}
}


; ------------------------
; Add/Remove Hostrings
; ------------------------

GuiEditHotstrings() {
	Gui := GuiCreate()
	Gui.Title := "Edit Hotstrings"
	Gui.SetFont("s12")
	gList := Gui.Add("ListBox", "section w200 r12", "")
	gDelete := Gui.Add("Button", "", "Hotstring")
	gText := Gui.Add("Text", "ys", "New Hotstring")
	gInput := Gui.Add("Edit", "ys r1 w100") ; hotstring input box
	gAdd := Gui.Add("Button", "ys h" gInput.Pos.H, "Add")
	gEdit := Gui.Add("Edit", Format("r12 x{1} y{2} w400" ; hotstring result editor
							, gText.Pos.X, gText.Pos.Y+35), "Place hotstring result here")
	gLIst.OnEvent("Change", (*) => SetText()) ; => single line function to assign a value. Java inspired
	gDelete.OnEvent("Click", (*) => GuiRemoveHotstrings(gList.Text))
	gAdd.OnEvent("Click", (*) => GuiModifyLine(gInput.Text, gEdit.Text))
	GuiListUpdate()
	return Gui

	GuiModifyLine(key, value) {
		newValue := RegExReplace(value, "\R", "\eol")
		IniWrite(newValue, iniFile, "Macros", key) ; write the new key and value the ini file
		sleep 80 ; wait for 80 miliseconds as writes may not finish before the program moves on
		SetHotstrings(key, 1) ; create the hotstrings and make sure they are enabled
		parsedIni[key] := newValue
		GuiListUpdate()
		GuiResets()
	}

	; set the input field and the edit box the reflect the current selection
	; in the list box control
	SetText() {
		gEdit.Text := parsedIni[gList.Text]
		gInput.Text := gList.Text
	}

	; update the list box contents to reflect the new contents of the parsedIni array
	GuiListUpdate() {
		listItems := []
		gList.Delete()
		for k, v in parsedIni
			listItems.Push(k)
		gLIst.Add(listItems)
	}

	; resets the hotstring insertion gui so it gets any channged values
	GuiResets() {
		GhotUse.Destroy()
		GhotUse := GuiInsertHotstring()
	}

	GuiRemoveHotstrings(deleter) {
		; get confirmation from the user before continuing
		confirm := MsgBox("Are you sure you want to delete the hotstring [" deleter "]`nand its resulting text`n" parsedIni[deleter], "Confirm", "YNC")
		if (confirm = "Yes") {
			IniDelete(iniFile, "Macros", deleter) ; remove the line from the ini file
			parsedIni.Delete(deleter) ; remove key from assosiative array of hotstrings
			GuiResets() ; destroy and rebuild relavent guis
			gList.Delete(gList.Value) ; remove matching value from the list
			SetHotstrings(deleter, 0) ; desable all hotstring with (enable=0)
		}

	}
}


;gHots := new EditHotstrings()
;gHots.text := "new text"

; ========================
; 
; ========================

ManReload(*) {
	Reload
	return
}