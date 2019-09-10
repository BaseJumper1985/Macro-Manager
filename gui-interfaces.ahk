#Include dynamic-hotstring.ahk

class GuiBase extends HTools {
    static GuiLists := []
    Gui := {}
    Guis[] {
        set => %this.__class%.GuiLists.Push(value)
        get => %this.__class%.GuiLists
    }

    MakeBaseGui() {
        leftWidth := 300
        preview := []
        g := GuiCreate()
        g.Title := "Insert Hotstring"
        g.SetFont("s12", "Ms Sans")
        gSearch := g.Add("Edit", "vSearch section w" leftWidth , "Search")
        g.SetFont()
        g.SetFont("s11", "Consolas")
        gText := g.Add("Text", "vText r4 w" leftWidth , "Hotstring Preview")
        g.SetFont()
        g.SetFont("s12", "Ms Sans")
        gList := g.Add("ListView", "vList w" leftWidth " r20", "Trigger|Name")


        gSearch.OnEvent("Change", (*) => this.SearchListView())
        gSearch.OnEvent("Focus", (*) => Send("^a"))
        gList.OnEvent("ItemFocus", (*) => this.OnFocus())
        g.OnEvent("Size", (*) => this.GuiUpdate())
        g.OnEvent("Close", (*) => this.GuiUpdate())
        this.Gui := g
        this.Guis := g
    }

    ; update the list box contents to reflect the new contents of the hotstrings array
    GuiUpdate() {
        for i, g in this.Guis {
            l := g["List"]
            l.Opt("-Redraw")
            l.Delete()
            for k, v in this.Macros {
                l.Add(, k, v.name)
            }
            l.Opt("+Redraw")
        }
    }

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

    OnFocus() {
        t := this.Gui["Text"]
        key := this.ListSelection("T")
        info := Format("
        (
            Trigger: {1}
               Name: {2}
               Type: {3}
               Used: {4}
        )"
        , key, this.Name[key], this.Type[key], this.Used[key])
        t.Text := info
    }

    ListSelection(type := "T") {
        l := this.Gui["List"]
        if(type = "T") {
            return l.GetText(l.GetNext())
        }
    }

    SearchListView(*) {
        l := this.gui["List"]
        letters := StrSplit(this.gui["Search"].Text)
        l.Opt("-Redraw")
        l.Delete()
        matchedCount := 0
        for k, v in this.Macros {
            regTerm := "^.*"
            for inl, letter in  letters {
                regTerm .= letter ".*"
            }
            regTerm .= "$"
            haystack := k v.name ; (v.name != "") ? v.name : k
            matched := RegExMatch(haystack, "i)" regTerm)
            if (matched) {
                l.Add(, k, v.name)
                matchedCount += matched
            }

        }
        if (matchedCount) {
            l.Modify(0, "-select")
            l.Modify(1, "+select")
            this.OnFocus()

        }
        l.Opt("+Redraw")
    }
}

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
        gPreview := g.Add("Edit", "r28 w400 xs ReadOnly")
        g["List"].OnEvent("DoubleClick", (*) => this.PlaceText())
        g["List"].OnEvent("ItemFocus", (*) => gPreview.Text := this.Text[this.ListSelection()])
        gOkay.OnEvent("Click", (*) => this.PlaceText())
        gCancel.OnEvent("Click", (*) => this.Gui.Hide())
        gCancel.OnEvent("Click", (*) => this.GuiUpdate())
    }
}

class GuiEditEntries extends GuiBase {
    Gui := {}
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
    }

    MakeGui() {
        leftWidth := 400
        g := GuiCreate()
        g.Title := "Edit Hotstrings"
        g.MenuBar := this.GuiHotstringMenuBar(this.helpText)
        g.SetFont("s11")
        gList := g.Add("ListView", "vList section w" leftWidth " r14", "Trigger|Name")
        gDelete := g.Add("Button", "", "Delete Hotstring")
        g.Add("Text", "ys section", "New Hotstring")
        g.Add("Edit", "vInput ys r1 w200")
        iPos := g["Input"].Pos.H
        gClear := g.Add("Button", "ys h" iPos, "Clear")
        g.Add("Text", "section xs", "Hotstring Name")
        g.Add("Edit", "vName r1 ys", "")
        gAdd := g.Add("Button", "ys h" iPos, "Apply")
        g.Add("DropDownList", "vType xs r2 Choose1", "Hotstring|Dynamic")
        g.Add("Edit", "vEdit r12 xs w400 WantTab", "Place hotstring result here") ; hotstring result editor
        
        
        gLIst.OnEvent("ItemFocus", (*) => this.SetText()) ; => single line function to assign a value. Java inspired
        gDelete.OnEvent("Click", (*) => this.GuiRemoveHotstrings(gList.GetText(gList.GetNext())))
        gAdd.OnEvent("Click", (*) => this.GuiModifyLine(g["Input"].Text, g["Edit"].Text, g["Name"].Text))
        gClear.OnEvent("Click", (*) => g["Input"].text := g["Edit"].text := g["Name"].text := "")
        this.Gui := g
        this.Guis := g
    }

    GuiModifyLine(key, text, name) {
        g := this.Gui
        canWrite := "Yes"
        if (key = "") {
            canWrite := "No"
            MsgBox("You Cannot leave the [New Hotstring] field blank.")
        }
        else if (this.macros.has(key)) { 
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
        g["Input"].Text := key
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
                this.GuiListUpdate() ; destroy and rebuild relavent guis
                this.SetHotstring(deleter, 0) ; desable matching hotstring with
            }
        }
    }
}
