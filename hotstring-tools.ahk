; DetectHiddenWindows, On
; SetWinDelay, -1 ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
; SetKeyDelay, -1, -1 ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
; SetMouseDelay, -1 ; Remove short delay done automatically after Click and MouseMove/Click/Drag

class KeyEntry {
    name := ""
    text := ""
}

class HotstringTools {
    static IniFile := A_WorkingDir "\macros.ini"
    static HotEntries := {}
    __New() {

    }
    ParseSection(header) { 
        IniArray := {}
        SectionArray := this._GetIniSectionArray(header)
        for k, v in SectionArray {
            entry := new KeyEntry()
            splitKey := StrSplit(v, "=")
            key := splitkey[1]
            text := splitkey[2]
            ; extract the name of the ini listing if present
            reg := RegExMatch(text, "[$]\{(.*)}.*", matched)
            if (reg = 1) {
            entry.name := matched.Value(1)
                text := RegExReplace(text, "[$]\{(.*)}", "")
            }
            entry.text := RegExReplace(text, "i)\\eol", "`r`n")
            this.HotEntries[key] := entry
        }
        return this.HotEntries
    }
    _GetIniSectionArray(header) {
        sectionEntry := IniRead(this.IniFile, header) ; get section from ini file
        sectionList := StrSplit(sectionEntry, "`n") ; split each line of section into array
        return sectionList ; return the array
    }
    AddEntry(name, text) {
        entry := new KeyEntry()
        entry.name := name
        entry.text := text
        return entry
    }
    MakeListView(inGui) {

    }
}

/*
ini := new HotstringTools()
tester := ini.hotstrings["test"]
entries := ini.ParseSection("Macros")

for k, v in entries {
    MsgBox(k)
    MsgBox(v.name)
    MsgBox(v.text)
}
*/