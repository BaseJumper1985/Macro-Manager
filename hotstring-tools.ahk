class HTools {
    static IniFile := ""
    static macros := {}
    static Fields := ["name", "used", "text"]
    __New(fileInput) {
        %this.__Class%.IniFile := fileInput
    }
    Modified[key] {
        get => %this.__Class%.macros[key].modified
        set {
            %this.__Class%.macros[key].modified := value
        }
    }
    Used[key] {
        get => %this.__Class%.macros[key].used
        set {
            %this.__Class%.macros[key].used := value
            this.Modified[key] := 1
        }
    }
    Text[key] {
        get => %this.__Class%.macros[key].text
        set {
            %this.__Class%.macros[key].text := value
            this.Modified[key] := 1
        }
    }
    Name[key] {
        get => %this.__Class%.macros[key].name
        set {
            %this.__Class%.macros[key].name := value
            this.Modified[key] := 1
        }
    }
    GetHotstrings(header) {
        tempArray := this.GetIniSectionArray(header)
        tempEntries := this.ParseSection(tempArray)
        %this.__Class%.macros := tempEntries
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
        %this.__Class%.macros[key] := entry
    }
    GetIniSectionArray(header) {
        sectionEntry := IniRead(this.IniFile, header) ; get section from ini file
        sectionList := StrSplit(sectionEntry, "`n") ; split each line of section into array
        return sectionList ; return the array
    }
    MakeIniEntry(key) {
        out := ""
        for k, label in this.Fields {
            out .= this.MakeLabel(label, %this.__Class%.macros[key].%label%)
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
        for k, v in %this.__Class%.macros {
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

class ImportExport extends HTools {
    imexgui := {} ; import/export GUI
    __New() {
        this.MakeImExGui()
    }
    MakeImExGui() {
        gui := GuiCreate()
        newHot := gui.Add("ListView", "section checked w400 r12", "Trigger|Name")
        newHot.Name := "newHot"
        newHot.Visible := false
        size := format(" w{1} h{2} ",newHot.Pos.W,newHot.Pos.H)
        input := gui.Add("Edit", "ys xs" size, "")
        import := gui.Add("Button", "w90 xs", "Toggle")
        oldHot := gui.Add("ListView", "section ys" size, "Trigger|Name")
        transfer := gui.Add("Button", "xs w90", "Transfer")
        oldHot.Name := "oldHot"

        import.OnEvent("Click", (*) => this.ParseLines(newHot, input))
        transfer.OnEvent("Click", (*) => this.OldToNew())
        gui.OnEvent("Close", (*) => this.Close())
        this.imexgui := gui
    }
    Show(ops := "") {
        this.imexgui.show(ops)
        this.FillExport()
    }
    Hide(ops := "") => this.imexgui.hide(ops)
    Close() {
        this.imexgui.Destroy()
        this.MakeImExGui()
    }
    ParseLines(hot, imp) {
        hot.Visible := (hot.Visible = false) ? true : false
        imp.Visible := (imp.Visible = true) ? false : true
    }
    OldToNew() {
        oldHot := this.imexgui.Control["oldHot"]
        newHot := this.imexgui.Control["newHot"]
        rowNum := 0
        Loop {
            rowNum := oldHot.GetNext(RowNum)
            if (!rowNum) {
                newHot.ModifyCol()
                break
            }
            one := oldHot.GetText(RowNum, 1)
            two := oldHot.GetText(RowNum, 2)
            newHot.Add(,one,two)
        }
    }
    FillExport() {
        oldHot := this.imexgui.Control["oldHot"]
        oldHot.Opt("-Redraw")
        for k, v in %base.__Class%.macros {
            oldHot.Add(, k, v.name)
        }
        oldHot.ModifyCol()
        oldHot.Opt("+Redraw")
    }
}
