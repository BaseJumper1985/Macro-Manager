
class GuiUseEntry extends GuiBase {
    helpText := "
    (
        Use the Search field at the top left to find a hotstring.
        Pressing Enter will select the top item from the list and
        paste its result into the last focused window.

        You can also change the formatting of the text by selecting
        one of the options on the right then Clicking [Okay] or
        Double Clicking the Hotstring in the List.
    )"
    __New() {
        this.MakeGui()
    }
    Show(opt := "") {
        this.Gui.Show(opt)
        this.GuiUpdate()
    }
    PlaceText(*) {
        key := this.ListSelection("T")
        if (key = "Trigger")
        {
            MsgBox("Nothing selected.`nPlease select an item from the list.")
            return
        }
        this.Gui.Hide()
        WinWaitNotActive("Insert Hotstring")
        this.OutputType(key)
    }

    MakeGui() {
        this.MakeBaseGui()
        g := this.Gui
        g.Title := "Insert Hotstring"
        this.Gui.MenuBar := this.GuiHotstringMenuBar(this.helpText)
        gOkay := g.Add("Button", "default ys section", "Okay")
        gCancel := g.Add("Button", "ys", "Cancel")
        gPreview := g.Add("Edit", "r27 w400 xs ReadOnly")
        g["List"].OnEvent("DoubleClick", (*) => this.PlaceText())
        g["List"].OnEvent("ItemFocus", (*) => gPreview.Text := this.Text[this.ListSelection()])
        g["Search"].OnEvent("Change", (*) => gPreview.Text := this.Text[this.ListSelection()])
        gOkay.OnEvent("Click", (*) => this.PlaceText())
        gCancel.OnEvent("Click", (*) => this.Gui.Hide())
        gCancel.OnEvent("Click", (*) => this.GuiUpdate())
    }
}

class GuiEditEntries extends GuiBase {
    ;Gui := {}
    inputFields := ["Input", "Name", "Type", "Edit"]
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
    __New() {
        this.MakeGui()
    }
    Show(opt := "") {
        this.Gui.Show(opt)
        this.GuiUpdate()
        this.CheckFields()
    }

    MakeGui() {
        leftWidth := 400
/*
        g := GuiCreate()
        g.Title := "Edit Hotstrings"
        g.SetFont("s11")
        gList := g.Add("ListView", "vList section w" leftWidth " r14", "Trigger|Name")
*/
        this.MakeBaseGui()
        g := this.Gui
        g.MenuBar := this.GuiHotstringMenuBar(this.helpText)
        gDelete := g.Add("Button", "", "Delete Hotstring")
        g.Add("Text", "ys section", "Trigger")
        g.Add("Edit", "vInput ys r1 w" this.inputWidth)
        iPosX := g["Input"].Pos.X
        iPosH := g["Input"].Pos.H
        boxPos := Format("x{1} w{2} h{3}", g["Input"].Pos.X, this.inputWidth, g["Input"].Pos.H)
        g.Add("Text", "section xs", "Name")
        g.Add("Edit", "vName r1 ys " boxPos, "")
        g.Add("Text", "section xs", "Type")
        g.Add("DropDownList", "vType ys r2 " boxPos, "Standard|Dynamic")
        gAdd := g.Add("Button", "vApply ys h" iPosH, "Apply")
        gAdd.Enable := false
        gClear := g.Add("Button", "ys h" iPosH, "Clear")
        g.Add("Edit", "vEdit r25 xs w400 WantTab", "Place hotstring result here") ; hotstring result editor
        
        for x in this.inputFields {
            g[x].OnEvent("Change", (*) => this.CheckFields())
        }
        g["List"].OnEvent("ItemFocus", (*) => this.SetText()) ; => single line function to assign a value. Java inspired
        gDelete.OnEvent("Click", (*) => this.GuiRemoveHotstrings(this.ListSelection()))
        gAdd.OnEvent("Click", (*) => this.GuiModifyLine(g["Input"].Text, g["Edit"].Text, g["Name"].Text))
        gClear.OnEvent("Click", (*) => this.ClearFields())
        g.OnEvent("Size", (*) => this.CheckFields())
    }

    ClearFields(*) {
        g := this.Gui
        g["Input"].text := g["Edit"].text := g["Name"].text := ""
        g["Type"].Value := 0
        this.CheckFields()
    }
    
    CheckFields(*) {
        g := this.Gui
        valid := false
        if (RegexMatch(g["Input"].Text, "^[a-z]{3,}$")
            and g["Name"].Text
            and g["Edit"].Text
            and g["Type"].Text != "") {
            valid := true
            ;MsgBox(valid)
        }
        else {
            valid := false
            ;MsgBox(valid)
        }
        g["Apply"].Enabled := valid
    }

    GuiModifyLine(key, text, name) {
        g := this.Gui
        canWrite := "Yes"
        if (this.macros.has(key)) {
            canWrite := MsgBox("There is already an entry called [" key "]`nWould you like to replace it?", "Overwrite", "YN")
        }
        if (canWrite = "Yes") {
            if (!FileExist(iniFile) or regexmatch(FileExist(iniFile), ".*R.*")) { 
                canWrite := "No"
                MsgBox("Cannot write to the file or file does not exist.`nMake sure the program has write access to the [macros.ini] file.")
            }
            else {
                
                key := StrLower(key)
                this.AddEntry(key, g["Type"].Text, name, text) ; modifying entries will reset the <used> count.
                this.SetHotstring(key, 1) ; create the hotstrings and make sure they are enabled
                this.GuiUpdate()
            }
        }
    }

    ; set the input field and the edit box the reflect the current selection
    ; in the list box control
    SetText() {
        g := this.Gui
        l := g["list"]
        key := l.GetText(l.GetNext())
        g["Edit"].Text := this.Text[key]
        g["Name"].Text := this.Name[key]
        g["Type"].Value := (this.Type[key] = "Standard") ? 1 : 2
        g["Input"].Text := key
        this.CheckFields()
    }

    GuiRemoveHotstrings(deleter) {
        ; get confirmation from the user before continuing
        confirm := MsgBox("Are you sure you want to delete the hotstring [" deleter "]`nand its resulting text`n" this.Text[deleter], "Confirm", "YN")
        if (confirm = "Yes") {
            IniDelete(iniFile, "Macros", deleter) ; remove the line from the ini file
            if (ErrorLevel) { 
                MsgBox("Cannot write to the file.`nMake sure you are running the program from`na location with proper access rights.")
            }
            else {
                this.macros.Delete(deleter) ; remove key from assosiative array of hotstring objects
                this.GuiUpdate() ; destroy and rebuild relavent guis
                this.SetHotstring(deleter, 0) ; desable matching hotstring with
            }
        }
    }
}
