; #Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.

; global variables: Keep this very small and only when it makes good sense.
global iniFile := A_WorkingDir "\macros.ini"
global parsedIni := ParseIni(iniFile, "Macros")
global fMenu := MenuCreate()
global GhotUse := GuiInsertHotstring()
global GhotModify := GuiEditHotstrings()

fMenu.Add("Insert Hotstring Here.", (*) => GhotUse.Show())
fMenu.Add("Convert Text", "ParseSelection")
fMenu.Add("Edit Hotstrings", (*) => GhotModify.Show())

FormatMenu := Func("PopMenu").Bind(fMenu)
Hotkey("^RButton", FormatMenu)

PopMenu(ByRef item)
{
	item.Show()
	return
}


MakeAllHotstrings()

; ========================
; Make All Hotstrings
; ========================
MakeAllHotstrings()
{
	Hotstring "CX"
	Paste := Func("PasteText") ; Function object to bind parameters
	; Create all the HotStrings and make a key lookup for other tasks.
	for k, v in parsedIni
	{
		cKeys := CasedKeys(k)
		MakeHotstrings(cKeys, Paste)
	}
}

GetIniSectionArray(file, header)
{
	sectionEntries := IniRead(file, header)
	sectionList := StrSplit(sectionEntries, "`n")
	return sectionList
}

listKeys := ""

; global parsedIni := {} ; Mark as global because functions can't see any variables from outside otherwise.

ParseIni(file, header)
{
	KeyArray := {}
	SectionArray := GetIniSectionArray(file, header)
	for k, v in SectionArray
	{
		splitKey := StrSplit(v, "=")
		KeyArray[splitKey[1]] := RegExReplace(splitKey[2], "i)\\EOL", "`n")
	}
	return KeyArray
}


CasedKeys(sKey)
{
	c := [] ; case modified keys
	c[1] := Format("{1:l}",      sKey)
	c[2] := Format("{1:U}{2:l}", SubStr(sKey, 1, 1), SubStr(sKey, 2))
	c[3] := Format("{1:U}",      sKey)
	return c
}

MakeHotstrings(cKeys, Paste)
{
	for x in cKeys
	{
		Hotstring(":CX:" cKeys[x] " ", "PasteText")
	}
	return
}

FormatText(hKey)
{
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

PasteText()
{
	output := FormatText(A_ThisHotkey)
	Clipboard := output
	sleep(50)
	Send("^v")
	return
}

ParseSelection(*)
{
	result := MsgBox("First select the text you want to modify then click Ok", "Convert Selection", "OC " 262144)
	if (result = "Ok")
	{
		Send("^c")
		Sleep(250)
		Modify := Clipboard
		Sleep(250)
		for k, v in parsedIni ; parsedIni is global
		{
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

GuiInsertHotstring()
{
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
	
	PlaceText(*)
	{
		Gui.Submit() ; always make sure to submit before checking values
		cKeys := CasedKeys(lHot.Text)
		for k in radioGroup
		{
			if (radioGroup[k].Value = 1) ; check if value = 1 to show button is marked
			{
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

GuiEditHotstrings()
{
	Gui := GuiCreate()
	gList := Gui.Add("ListBox", "section w200 r12", "")
	gDelete := Gui.Add("Button", "", "Delete hotstring")
	gText := Gui.Add("Text", "ys", "New Hotstring")
	gInput := Gui.Add("Edit", "ys r1 w100")
	gAdd := Gui.Add("Button", "ys", "Add")
	gEdit := Gui.Add("Edit", "r12 x" gText.Pos.X " y" gText.Pos.Y+30 " w400", "Place replacement text here")

	gLIst.OnEvent("Change", (*) => gEdit.Value := parsedIni[gList.Text]) ; => single line function to assign a value. Java inspired
	gDelete.OnEvent("Click", (*) => GuiRemoveHotstrings(gList.Text))
	gAdd.OnEvent("Click", (*) => GuiModifyLine(gInput.Text, gEdit.Text))
	GuiListUpdate()
	return Gui

	GuiModifyLine(key, value)
	{
		Gui.Submit()
		newValue := RegExReplace(value, "\R", "\eol")
		IniWrite(newValue, iniFile, "Macros", key)
		sleep 80
		parsedIni := ParseIni(iniFile, "Macros")
		GuiListUpdate()
	}

	GuiListUpdate()
	{
		listItems := []
		gList.Delete()
		for k, v in parsedIni
			listItems.Push(k)
		gLIst.Add(listItems)
	}

	GuiRemoveHotstrings(deleter)
	{
		confirm := MsgBox("Are you sure you want to delete the hotstring [" deleter "]`nand its resulting text`n" parsedIni[deleter], "Confirm", "YNC")
		if (confirm = "Yes")
		{
			/*
			IniDelete(iniFile, "Macros", deleter)
			*/
			parsedIni.Delete(deleter)
			GhotUse.Destroy()
			GhotUse := GuiInsertHotstring()
			delArray := CasedKeys(deleter)
			gList.Delete(gList.Value)
			for k, v in delArray
			{
				; msgbox(":CX:" v " ")
				Hotstring(":CX:" v " ", "PasteText", 0)
			}
		}

	}
}


;gHots := new EditHotstrings()
;gHots.text := "new text"

; ========================
; 
; ========================

ManReload(*)
{
	Reload
	return
}