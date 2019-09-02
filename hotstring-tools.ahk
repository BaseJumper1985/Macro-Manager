class HotVars {
    static IniFileLocation := ""
    static IniHotstrings := {}
}

class HotstringTools {
    IniFile := HotVars.IniFileLocation
    macros := HotVars.IniHotstrings
    static Fields := ["name", "used", "text"]
    __New(fileInput) {
        this.IniFile := fileInput
        HotVars.IniFileLocation := fileInput
    }
    Modified[key] {
        get => this.macros[key].modified
        set {
            this.macros[key].modified := value
        }
    }
    Used[key] {
        get => this.macros[key].used
        set {
            this.macros[key].used := value
            this.Modified[key] := 1
        }
    }
    Text[key] {
        get => this.macros[key].text
        set {
            this.macros[key].text := value
            this.Modified[key] := 1
        }
    }
    Name[key] {
        get => this.macros[key].name
        set {
            this.macros[key].name := value
            this.Modified[key] := 1
        }
    }
    GetHotstrings(header) {
        array := this.GetIniSectionArray(header)
        tempEntries := this.ParseSection(array)
        this.macros := tempEntries
        return tempEntries
    }
    ParseSection(SectionArray) { 
        IniArray := {}
        for k, v in SectionArray {
            entry := {}
            splitKey := StrSplit(v, "=")
            key := splitkey[1]
            text := splitkey[2]
            ; extract the name of the ini listing if present
            entry := this.ParseElements(text, this.Fields)
            entry.modified := 0
            entry.text := RegExReplace(entry.text, "i)\\eol", "`r`n")
            ;MsgBox("item: [" entry.name "] was used " entry.used " times")
            IniArray[key] := entry
        }
        return IniArray
    }
    ParseElements(inText, items) {
        entry := {}
        for i, item in items {
            reg := RegExMatch(inText, "\{" item ":(?P<" item ">.*?)}(,|$)", matched)
            if (reg) {
                entry.%item% := matched[item]
            }
        }
        return entry
    }
    AddHotstring(key, name, text) {
        entry := {}
        entry.used := 0
        entry.modified := 1
        entry.name := name
        entry.text := text
        this.macros[key] := entry
    }
    GetIniSectionArray(header) {
        sectionEntry := IniRead(this.IniFile, header) ; get section from ini file
        sectionList := StrSplit(sectionEntry, "`n") ; split each line of section into array
        return sectionList ; return the array
    }
    MakeIniEntry(key) {
        out := ""
        for k, label in this.Fields {
            out .= this.MakeLabel(label, this.macros[key].%label%)
            if (k < this.Fields.Length())
                out .= ","
        }
        return out
    }
    MakeLabel(label, content) {
        out := RegExReplace(content, "\R", "\eol")
        out := "{" label ":" out "}"
        return out
    }
    SaveModified() {
        for k, v in this.macros {
            notify := 0
            if (v.modified = 1) {
                if (notify) {
                    TrayTip("Saved", "The config file has been updated", "Mute")
                    notify := 0
                }
                v.modified := 0
                IniWrite(hst.MakeIniEntry(k), this.IniFile, "Macros", k)
            }
        }
    }
}

class ImportExport extends HotstringTools {
    imexgui := {} ; import/export GUI
    __New() {
        this.MakeImExGui()
    }
    MakeImExGui() {
        gui := GuiCreate()
        newHot := gui.Add("ListView", "checked section w400 r12", "test1|test2|test3")
        newHot.Modify(1, "Check")
        newHot.Enabled := false
        toggleVis := gui.Add("Button", "default w90 xs", "Toggle")
        import := gui.Add("Edit", "ys w400 xp hp", "")
        oldHot := gui.Add("ListView", "ys w400 r12", "alt1|alt2|alt3")
        oldHot.Name := "oldHot"

        toggleVis.OnEvent("Click", (*) => this.ParseLines(newHot, import))
        gui.OnEvent("Close", (*) => this.Close())
        this.imexgui := gui
        this.FillExport()
    }
    Show(ops := "") => this.imexgui.show(ops)
    Hide(ops := "") => this.imexgui.hide(ops)
    Close() {
        this.imexgui.Destroy()
        this.MakeImExGui()
    }
    
    ParseLines(hot, imp) {
        hot.Enabled := (hot.Enabled = true) ? false : true
        imp.Visible := (imp.Visible = true) ? false : true
    }
    FillExport() {
        MsgBox(HotVars.IniFileLocation)
    }
}
