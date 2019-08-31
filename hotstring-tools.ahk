; DetectHiddenWindows, On
; SetWinDelay, -1 ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
; SetKeyDelay, -1, -1 ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
; SetMouseDelay, -1 ; Remove short delay done automatically after Click and MouseMove/Click/Drag

class HotstringTools {
    static IniFile := ""
    static HotEntries := {}
    static fields := ["name", "used", "text"]
    __New(fileInput) {
        this.IniFile := fileInput
    }
    ParseSection(header) { 
        IniArray := {}
        SectionArray := this.GetIniSectionArray(header)
        for k, v in SectionArray {
            entry := {}
            splitKey := StrSplit(v, "=")
            key := splitkey[1]
            text := splitkey[2]
            ; extract the name of the ini listing if present
            entry := this.GetElements(text, this.fields)
            entry.text := RegExReplace(entry.text, "i)\\eol", "`r`n")
            ;MsgBox("item: [" entry.name "] was used " entry.used " times")
            this.HotEntries[key] := entry
        }
        return this.HotEntries
    }
    GetIniSectionArray(header) {
        sectionEntry := IniRead(this.IniFile, header) ; get section from ini file
        sectionList := StrSplit(sectionEntry, "`n") ; split each line of section into array
        return sectionList ; return the array
    }
    AddEntry(name, text) {
        entry := {}
        entry.name := name
        entry.text := text
        return entry
    }
    MakeLabel(label, content) {
        out := RegExReplace(content, "\R", "\eol")
        out := "${" label ":" out "}"
        return out
    }
    MakeAllLabels(label) {

    }
    GetElements(inText, items) {
        entry := {}
        entry.complete := inText
        for x in items {
            item := items[x]
            reg := RegExMatch(inText, "\$\{" item ":(?P<" item ">.*?)}", matched)
            if (reg) {
                entry.%item% := matched[item]
            }
        }
        return entry
    }
    MakeListView(inGui) {

    }
}

/*
class ListRightClick {
    rightMenu := {}
    __New() {

    }
}
*/
