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
global EditHotstrings := new GuiEditEntries()

fMenu := MenuCreate() ; create the right click menu for use with the prograMS gui elements
fMenu.Add("Insert Hotstring Here.", (*) => InsertHotstrings.Show()) ; open insert hotstring dialog
fMenu.Add("Convert Text", (*) => ParseSelection()) ; open parse text and replace with hotsting results dialog
fMenu.Add("Edit Hotstrings", (*) => EditHotstrings.Show()) ; open modify hotstring dialog
fMenu.Add("Import/Export", (*) => ImEx.Show()) ; open import/export window
Hotkey("#RButton", (*) => fMenu.Show()) ; assign control + right mouse button to open a small popup manu
PopMenu(ByRef item) {
    item.Show()
    return
}

Hotkey("$#h", (*) => InsertHotstrings.Show())

Hotstring(":*:dt  ", (*) => DateTimeOut())
DateTimeOut() {
    out := Format("{1}-{2}-{3} {4}:{5}", A_YYYY, A_MM, A_DD, A_Hour, A_Min)
    Send(out)
}

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
; 
; ========================

ManReload(*) {
    Reload
    return
}
