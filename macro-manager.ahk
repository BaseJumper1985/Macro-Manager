; ========================
; Auto Execute Section
; ========================

#Warn ; enable warnings to assist with detecting common errors
#Persistent ; make sure the program does not shut down on its own
#SingleInstance ; only one copy of the program is allowed open at a time
#MaxThreadsPerHotkey 1 ; no re-entrant hotkey handling
#Include hotstring-tools.ahk
;#include edit-hotstrings
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory

; global variables: Keep this very small and only when it makes good sense.
ini := "\macros.ini"
configFolder := A_AppData "\macro-manager"
global iniFile := configFolder ini ; get the path to the ini file for later use
if (!FileExist(iniFile)) {
    DirCreate(configFolder)
    FileAppend("", iniFile)
}


global hst := new HTools(iniFile)
global imex := new ImportExport()

/*
for tempk, tempv in hst.macros {
    IniWrite(hst.MakeIniEntry(tempk), iniFile, "Macros", tempk) ; write the new key and value the ini file
}
*/

SetTimer((*) => CheckIdle(), 5000)
CheckIdle() {
    if (A_TimeIdlePhysical > 5000) {
        hst.SaveModified()
    }
}

global InsertHotstrings := new GuiUseEntry()
global GhotModify := new GuiEditEntries()
;global GhotModify := GuiEditHotstrings() ; get object of the gui for hotstring modifcation/addition/deletion

fMenu := MenuCreate() ; create the right click menu for use with the prograMS gui elements
fMenu.Add("Insert Hotstring Here.", (*) => InsertHotstrings.Show()) ; open insert hotstring dialog
fMenu.Add("Convert Text", (*) => ParseSelection()) ; open parse text and replace with hotsting results dialog
fMenu.Add("Edit Hotstrings", (*) => GhotModify.Show()) ; open modify hotstring dialog
fMenu.Add("Import/Export", (*) => ImEx.Show()) ; open import/export window
Hotkey("#RButton", (*) => fMenu.Show()) ; assign control + right mouse button to open a small popup manu
PopMenu(ByRef item) {
    item.Show()
    return
}

Hotkey("$#h", (*) => InsertHotstrings.Show())

Hotstring(":*:dt  ", Format("{1}/{2}/{3} {4}:{5}", A_YYYY, A_MM, A_DD, A_Hour, A_Min))

/*
trayMenu := A_TrayMenu
trayMenu.Delete()
trayMenu.Add("Edit Hotstrings", (*) => GhotModify.Show()) ; open modify hotstring dialog
trayMenu.Add("Take a Break", (*) => TakeBreak(trayMenu))
trayMenu.Add("Exit", (*) => ExitApp())
TakeBreak(this) {
    Suspend()
    this.ToggleCheck("Pause Hotkeys")
}
*/

GetSetting(key) {
    return IniRead(HTools.IniFile, "Settings", key)
}


; ========================
; Make All Hotstrings
; ========================

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

/*
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
    gList := Gui.Add("ListView", "section w" leftWidth " r14", "Trigger|Name")
    for k, v in hst.macros {
        gList.Add(, k, v.name)
    }
    gList.Name := "hotstringList"
    gDelete := Gui.Add("Button", "", "Delete Hotstring")
    gText := Gui.Add("Text", "ys section", "New Hotstring")
    gInput := Gui.Add("Edit", "ys r1 w200")
    gClear := Gui.Add("Button", "ys h" gInput.Pos.H, "Clear")
    gDrop := Gui.Add("Text", "section xs", "Hotstring Name")
    gName := Gui.Add("Edit", "r1 ys", "")
    gAdd := Gui.Add("Button", "ys h" gInput.Pos.H, "Apply")
    Gui.Add("DropDownList", "vType r2 choose1 xs h" gInput.Pos.H, "Hotstring|Dynamic")
    gEdit := Gui.Add("Edit", "r12 xs w400 WantTab", "Place hotstring result here") ; hotstring result editor 
    
    
    gLIst.OnEvent("ItemFocus", (*) => SetText()) ; => single line function to assign a value. Java inspired
    gDelete.OnEvent("Click", (*) => GuiRemoveHotstrings(gList.GetText(gList.GetNext())))
    gAdd.OnEvent("Click", (*) => GuiModifyLine(gInput.Text, gEdit.Text, gName.Text))
    gClear.OnEvent("Click", (*) => gInput.text := gEdit.text := gName.text := "")
    return Gui

    GuiModifyLine(key, text, name) {
        canWrite := "Yes"
        if (key = "") {
            canWrite := "No"
            MsgBox("You Cannot leave the [New Hotstring] field blank.")
        }
        else if (hst.macros.has(key)) { 
            canWrite := MsgBox("There is already an entry called [" key "]`nWould you like to replace it?", "Overwrite", "YN")
        }
        if (canWrite = "Yes") {
            if (!FileExist(iniFile) or regexmatch(FileExist(iniFile), ".*R.*")) { 
                canWrite := "No"
                MsgBox("Cannot write to the file or file does not exist.`nMake sure the program has write access to the [macros.ini] file.")
            }
            else {
                ;type := ()
                key := StrLower(key)
                hst.AddEntry(key, "H", name, text) ; modifying entries will reset the <used> count.
                hst.SetHotstring(key, 1) ; create the hotstrings and make sure they are enabled
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
                hst.SetHotstring(deleter, 0) ; desable matching hotstring with
            }
        }
    }
}

; update the list box contents to reflect the new contents of the hotstrings array
GuiListUpdate() {
    g := [GhotModify]
    for i, x in g {
        l := x["hotstringList"]
        l.Opt("-Redraw")
        l.Delete()
        for k, v in hst.macros {
            l.Add(, k, v.name)
        }
        l.Opt("+Redraw")
    }
}
*/

; ========================
; 
; ========================

ManReload(*) {
    Reload
    return
}
