; ========================
; Auto Execute Section
; ========================

#Warn ; enable warnings to assist with detecting common errors
#Persistent ; make sure the program does not shut down on its own
#SingleInstance ; only one copy of the program is allowed open at a time
#MaxThreadsPerHotkey 1 ; no re-entrant hotkey handling
#Include hotstring-tools.ahk
;#Include hotstring-gui.ahk
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory

; global variables: Keep this very small and only when it makes good sense.
ini := "\macros.ini"
configFolder := A_AppData "\macro-manager"
global iniFile := configFolder ini ; get the path to the ini file for later use
if (!FileExist(iniFile)) {
    DirCreate(configFolder)
    FileAppend("", iniFile)
}

global hst := new HotstringTools(iniFile)
hst.GetHotstrings("Macros") ; parse the ini file and set the contents of hotstrings to match
;global hotstrings := hst.GetHotstrings("Macros") ; parse the ini file and set the contents of hotstrings to match

/*
for tempk, tempv in hotstrings {
    IniWrite(hst.MakeIniEntry(tempk), iniFile, "Macros", tempk) ; write the new key and value the ini file
}
*/

SetTimer((*) => CheckIdle(), 5000)
CheckIdle() {
    if (A_TimeIdlePhysical > 5000) {
        hst.SaveModified()
    }
}

global GhotUse := GuiInsertHotstring() ; get object of the gui for hotstring insertion
global GhotModify := GuiEditHotstrings() ; get object of the gui for hotstring modifcation/addition/deletion

fMenu := MenuCreate() ; create the right click menu for use with the prograMS gui elements
fMenu.Add("Insert Hotstring Here.", (*) => OpenInsertMenu()) ; open insert hotstring dialog
fMenu.Add("Convert Text", (*) => ParseSelection()) ; open parse text and replace with hotsting results dialog
fMenu.Add("Edit Hotstrings", (*) => GhotModify.Show()) ; open modify hotstring dialog
Hotkey("#RButton", (*) => fMenu.Show()) ; assign control + right mouse button to open a small popup manu
PopMenu(ByRef item) {
    item.Show()
    return
}

Hotkey("$#h", (*) => GhotUse.Show())
OpenInsertMenu() {
    GhotUse.Show()
	GuiListUpdate()
}

Hotstring(":*:dt  ", Format("{1}/{2}/{3} {4}:{5}", A_YYYY, A_MM, A_DD, A_Hour, A_Min))

trayMenu := A_TrayMenu
trayMenu.Delete()
trayMenu.Add("Edit Hotstrings", (*) => GhotModify.Show()) ; open modify hotstring dialog
trayMenu.Add("Take a Break", (*) => TakeBreak(trayMenu))
trayMenu.Add("Exit", (*) => ExitApp())
TakeBreak(this) {
    Suspend()
    this.ToggleCheck("Pause Hotkeys")
}

imex := new ImportExport()

MakeAllHotstrings() ; starts the main process and creates all the hotstrings from the ini file

; ========================
; Make All Hotstrings
; ========================
MakeAllHotstrings() {
    ; Create all the HotStrings and make a key lookup for other tasks.
    for k in hst.macros {
        SetHotstrings(k)
    }
}

/*
GetIniSectionArray(file, header) {
    sectionEntry := IniRead(file, header) ; get section from ini file
    sectionList := StrSplit(sectionEntry, "`n") ; split each line of section into array
    return sectionList ; return the array
}
*/

; takes input string and creates two other versions eg. lol/Lol/LOL
; these are used in the different types of key replacements that deal
; with capitalization and the like.
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
    for i, x in cKeys {
        Hotstring(":CX:" x " ", (*) => PasteText(A_ThisHotkey), stringEnable)
    }
    return
}

FormatText(key) {
    iniText := hst.Text[key] ; hotstrings is global
    if (RegExMatch(key, "^[A-Z][a-z]+$")) {
        out := Format("{1:U}{2}", SubStr(iniText, 1, 1), SubStr(iniText, 2))
    }
    else if (RegExMatch(key, "^[A-Z]+$")) {
        out := Format("{1:t}", iniText)    
    }
    else {
        out := Format("{1}", iniText)
    }
    return out
}

PasteText(hKey) {
    key := Trim(RegExReplace(hKey, "^:\w*:"))
    out := FormatText(key)
    Clipboard := out
    sleep(50)
    Send("^v")
    hst.Used[key]++
    return
}

ParseSelection(*) {
    result := MsgBox("First select the text you want to modify then click Ok", "Convert Selection", "OC " 262144)
    if (result = "Ok") {
        Send("^c")
        Sleep(250)
        Modify := Clipboard
        Sleep(250)
        for k, v in hst.macros { ; hotstrings is global
            Modify := RegExReplace(Modify, "i)\b" k "\b", v.text)
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
    leftWidth := 400
    preview := []
    Gui := GuiCreate()
    Gui.MenuBar := GuiHotstringMenuBar(helpText)
    Gui.SetFont("s12")
    Gui.Title := "Insert Hotstring"
    gSearch := Gui.Add("Edit", "w" leftWidth , "Search")
    
    gSearch.Name := "searchBox"
    gList := Gui.Add("ListView", "section w" leftWidth " r12", "Trigger|Name")
    for k, v in hst.macros {
        gList.Add(, k, v.name)
    }
    gList.Name := "hotstringList"
    
    gText := Gui.Add("Text", "r8 w400" , "Hotstring Preview")

    radioGroup := Gui.Add("Radio", "checked ys", "Paste without changes.")
    Gui.Add("Radio", , "Capitalize First Letter.")
    Gui.Add("Radio", , "Title Case Entire Phrase.")
    radioGroup.Name := "radioGroup"
    
    gOkay := Gui.Add("Button", "default section", "Okay")
    gCancel := Gui.Add("Button", "ys", "Cancel")

    gSearch.OnEvent("Change", (*) => SearchListView())
    gSearch.OnEvent("Focus", (*) => Send("^a"))
    gList.OnEvent("ItemFocus", (*) => OnFocus()) ; => single line function to assign a value. Java inspired
    gList.OnEvent("DoubleClick", (*) => PlaceText())
    gOkay.OnEvent("Click", (*) => PlaceText())
    gCancel.OnEvent("Click", (*) => Gui.Hide())
    gCancel.OnEvent("Click", (*) => GuiListUpdate())
    Gui.OnEvent("Size", (*) => GuiListUpdate())
    Gui.OnEvent("Close", (*) => GuiListUpdate())
    return Gui

    OnFocus() {
        gText.Pos.W := 700
        gText.Text := hst.Text[ListSelection("T")]
    }
	ListSelection(type := "T") {
		if(type = "T") {
			return gList.GetText(gList.GetNext())
		}
	}
    
    PlaceText(*) {
        Gui.Hide()
		rowNum := gList.GetNext()
		rowText := gList.GetText(rowNum)
        cKeys := CasedKeys(rowText)
        result := Gui.Submit(0)
        rv := result["radioGroup"]
        Gui.Control["radioGroup"].Value := 1
        ClipBoard := FormatText(cKeys[rv])
        WinWaitNotActive("Insert Hotstring")
        send("^v")
        hst.Used[rowText]++
    }

    SearchListView(*) {
        term := gSearch.Text
        letters := StrSplit(term)
        gList.Opt("-Redraw")
        gList.Delete()
		rowNum := gList.GetNext()
        matchedCount := 0
        for k, v in hst.macros {
            regTerm := "^.*"
            for inl, letter in  letters {
                regTerm .= letter ".*"
            }
            regTerm .= "$"
            haystack := (v.name != "") ? v.name : k
            matched := RegExMatch(haystack, "i)" regTerm)
            if (matched) {
                gList.Add(, k, v.name)
                matchedCount += matched
            }

        }
        if (matchedCount) {
			gList.Modify(rowNum, "+select")
            firstRow := gList.GetText(gList.GetNext())
            gText.Text := hst.Text[firstRow]

        }
        gList.Opt("+Redraw")
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
	leftWidth := 400
    Gui := GuiCreate()
    Gui.Title := "Edit Hotstrings"
    Gui.MenuBar := GuiHotstringMenuBar(helpText)
    Gui.SetFont("s11")
	gList := Gui.Add("ListView", "section w" leftWidth " r12", "Trigger|Name")
    for k, v in hst.macros {
        gList.Add(, k, v.name)
    }
    gList.Name := "hotstringList"
    gDelete := Gui.Add("Button", "", "Delete Hotstring")
    gText := Gui.Add("Text", "ys section", "New Hotstring")
    gInput := Gui.Add("Edit", "ys r1 w200")
    gClear := Gui.Add("Button", "ys h" gInput.Pos.H, "Clear")
    Gui.Add("Text", "section xs", "Hotstring Name")
    gName := Gui.Add("Edit", "r1 ys", "")
    gAdd := Gui.Add("Button", "ys h" gInput.Pos.H, "Apply")
    gEdit := Gui.Add("Edit", "r12 xs w400 WantTab", "Place hotstring result here") ; hotstring result editor 
    
    
    gLIst.OnEvent("ItemFocus", (*) => SetText()) ; => single line function to assign a value. Java inspired
    gDelete.OnEvent("Click", (*) => GuiRemoveHotstrings(gList.GetText(gList.GetNext())))
    gAdd.OnEvent("Click", (*) => GuiModifyLine(gInput.Text, gEdit.Text, gName.Text))
    gClear.OnEvent("Click", (*) => gInput.text := gEdit.text := gName.text := "")
    ;GuiListUpdate()
    return Gui

    GuiModifyLine(key, text, name) {
        canWrite := "Yes"
        if (key = "") {
            canWrite := "No"
            MsgBox("You Cannot leave the [New Hotstring] field blank.")
        }
        else if (hst.macros[key]) { 
            canWrite := MsgBox("There is already an entry called [" key "]`nWould you like to replace it?", "Overwrite", "YN")
        }
        if (canWrite = "Yes") {
            if (!FileExist(iniFile) or regexmatch(FileExist(iniFile), ".*R.*")) { 
                canWrite := "No"
                MsgBox("Cannot write to the file or file does not exist.`nMake sure the program has write access to the [macros.ini] file.")
            }
            else {
                key := StrLower(key)
                hst.AddHotstring(key, name, text) ; modifying entries will reset the <used> count.
                SetHotstrings(key, 1) ; create the hotstrings and make sure they are enabled
                GuiListUpdate()
            }
        }
    }

    ; set the input field and the edit box the reflect the current selection
    ; in the list box control
    SetText() {
		key := gList.GetText(gList.GetNext())
        editText := hst.Text[key]
        gEdit.Text := editText
        gName.Text := hst.Name[key]
        gInput.Text := key
    }

    GuiRemoveHotstrings(deleter) {
        ; get confirmation from the user before continuing
        confirm := MsgBox("Are you sure you want to delete the hotstring [" deleter "]`nand its resulting text`n" hst.Text[deleter], "Confirm", "YN")
        if (confirm = "Yes") {
			IniDelete(iniFile, "Macros", deleter) ; remove the line from the ini file
			if (ErrorLevel) { 
				MsgBox("Cannot write to the file.`nMake sure you are running the program from`na location with proper access rights.")
			}
			else {
				hst.macros.Delete(deleter) ; remove key from assosiative array of hotstring objects
				GuiListUpdate() ; destroy and rebuild relavent guis
				SetHotstrings(deleter, 0) ; desable matching hotstring with
			}
        }
    }
}

; update the list box contents to reflect the new contents of the hotstrings array
GuiListUpdate() {
    g := [GhotUse, GhotModify]
    for i, x in g {
        l := x.Control["hotstringList"]
        l.Opt("-Redraw")
        l.Delete()
		for k, v in hst.macros {
			l.Add(, k, v.name)
		}
        l.Opt("+Redraw")
    }
}

; ========================
; 
; ========================

ManReload(*) {
    Reload
    return
}
