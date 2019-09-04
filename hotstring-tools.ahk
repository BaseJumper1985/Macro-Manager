class HTools {
    static IniFile := ""
    static HObjects := map()
    Fields := ["name", "used", "text"]
    __New(fileInput) {
        %this.__class%.IniFile := fileInput
    }
    Macros[] {
        get => %this.__class%.HObjects
        set => %this.__class%.HObjects := value
    }
    Modified[key] {
        get => %this.__class%.HObjects[key].modified
        set {
            %this.__class%.HObjects[key].modified := value
        }
    }
    Used[key] {
        get => %this.__class%.HObjects[key].used
        set {
            %this.__class%.HObjects[key].used := value
            this.Modified[key] := 1
        }
    }
    Text[key] {
        get => %this.__class%.HObjects[key].text
        set {
            %this.__class%.HObjects[key].text := value
            this.Modified[key] := 1
        }
    }
    Name[key] {
        get => %this.__class%.HObjects[key].name
        set {
            %this.__class%.HObjects[key].name := value
            this.Modified[key] := 1
        }
    }
    GetHotstrings(header) {
        tempArray := this.GetIniSection(header)
        tempEntries := this.ParseSection(tempArray)
        this.Macros := tempEntries
        return tempEntries
    }
    ParseSection(section) { 
        IniArray := map()
        sectionArray := StrSplit(section, "`n") ; split each line of section into array
        for k, v in sectionArray {
            if (v != "") {
                splitKey := StrSplit(v, "=")
                key := splitkey[1]
                text := splitkey[2]
                ; extract the name of the ini listing if present
                IniArray[key] := this.ParseElements(text, this.Fields)
            }
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
        entry.modified := 0
        entry.text := RegExReplace(entry.text, "i)\\eol", "`r`n")
        return entry
    }
    AddHotstring(key, name, text) {
        entry := {}
        entry.used := 0
        entry.modified := 1
        entry.name := name
        entry.text := text
        this.Macros[key] := entry
    }
    GetIniSection(header) {
        sectionEntry := IniRead(%this.__class%.IniFile, header) ; get section from ini file
        return sectionEntry ; return the array
    }
    MakeIniEntry(key) {
        out := ""
        for k, label in this.Fields {
            out .= this.MakeLabel(label, this.Macros[key].%label%)
            if (k < this.Fields.Length)
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
        for k, v in this.Macros {
            notify := 0
            if (v.modified = 1) {
                if (notify) {
                    TrayTip("Saved", "The config file has been updated", "Mute")
                    notify := 0
                }
                v.modified := 0
                IniWrite(this.MakeIniEntry(k), %this.__class%.IniFile, "Macros", k)
            }
        }
    }
}

class ImportExport extends HTools {
    imported := map()
    g := {} ; interface control objects
    imexgui := {} ; import/export GUI
    __New() {
    }
    MakeImExGui() {
        gui := GuiCreate()
        this.g.newHot := gui.Add("ListView", "section checked w400 r12", "Trigger|Name|Match")
        this.g.newHot.Name := "newHot"
        this.g.newHot.Visible := false
        size := format(" w{1} h{2} "
            ,this.g.newHot.Pos.W,this.g.newHot.Pos.H)
        this.g.input := gui.Add("Edit", "ys xs" size, "")
        this.g.import := gui.Add("Button", "w90 xs", "Import")
        this.g.oldHot := gui.Add("ListView", "section ys" size, "Trigger|Name")
        this.g.transfer := gui.Add("Button", "xs w90", "Transfer")
        this.g.oldHot.Name := "oldHot"

        this.g.import.OnEvent("Click", (*) => this.ParseLines())
        this.g.newHot.OnEvent("Click", (*) => this.Compare())
        ;this.g.transfer.OnEvent("Click", (*) => this.OldToNew())
        gui.OnEvent("Close", (*) => this.imexgui.Destroy())
        this.imexgui := gui
    }
    Recreate() {
        this.imexgui.Destroy()
        this.MakeImExGui()
    }
    Show(ops := "") {
        this.MakeImExGui()
        this.imexgui.show(ops)
        this.FillExport()
    }
    Hide(ops := "") => this.imexgui.hide(ops)
    Close() {
        this.imexgui.Destroy()
        this.MakeImExGui()
    }
    Compare() {
        lold := this.g.oldHot
        lnew := this.g.newHot
        newSel := lnew.GetText(lnew.GetNext(), 3)
        lold.Modify(newSel, "+Select")

    }
    ParseLines() {
        oldHot := this.g.oldHot, newHot := this.g.newHot, input := this.g.input
        newHot.Visible := true ; (hot.Visible = false) ? true : false
        input.Visible := false ; (imp.Visible = true) ? false : true
        importListItems := this.ParseSection(input.text)
        newHot.Opt("-Redraw")
        foundItems := []
        Loop oldHot.GetCount() {
            ;found := 0
            count := A_Index
            for k, v in importListItems { 
                if (k = oldHot.GetText(count)) { 
                    ;found := 1
                    foundItems.Push(count)
                }
            }
        }
        for k, v in importListItems
            newHot.Add(, k, v.name, foundItems[A_Index])
        newHot.Opt("+Redraw")
    }
    FillExport() {
        oldHot := this.imexgui["oldHot"]
        oldHot.Opt("-Redraw")
        for k, v in this.macros {
            oldHot.Add(, k, v.name)
        }
        ;oldHot.ModifyCol()
        oldHot.Opt("+Redraw")
    }
}
