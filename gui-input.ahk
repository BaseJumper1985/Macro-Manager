class GuiBase extends HTools {
    static GuiLists := []
    Guis[] {
        set => %this.__class%.GuiLists.Push(value)
        get => %this.__class%.GuiLists
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
        t.Pos.W := 700
        t.Text := this.Text[this.ListSelection("T")]
    }

	ListSelection(type := "T") {
        l := this.Gui["List"]
		if(type = "T") {
			return l.GetText(l.GetNext())
		}
	}

    PlaceText(*) {
        this.Gui.Hide()
        l := this.Gui["List"]
		rowNum := (l.GetNext()) ? l.GetNext() : 1
		key := l.GetText(rowNum)
        WinWaitNotActive("Insert Hotstring")
        this.PasteText(key)
    }
    
    MakeBaseGui() {
        leftWidth := 400
        preview := []
        g := GuiCreate()
        g.SetFont("s12")
        g.Title := "Insert Hotstring"
        gSearch := g.Add("Edit", "vSearch w" leftWidth , "Search")
        gList := g.Add("ListView", "vList section w" leftWidth " r12", "Trigger|Name")
        gText := g.Add("Text", "vText r8 w400" , "Hotstring Preview")

        gOkay := g.Add("Button", "default section", "Okay")
        gCancel := g.Add("Button", "ys", "Cancel")

        gSearch.OnEvent("Change", (*) => this.SearchListView())
        gSearch.OnEvent("Focus", (*) => Send("^a"))
        gList.OnEvent("ItemFocus", (*) => this.OnFocus()) ; => single line function to assign a value. Java inspired
        gList.OnEvent("DoubleClick", (*) => this.PlaceText())
        gOkay.OnEvent("Click", (*) => this.PlaceText())
        gCancel.OnEvent("Click", (*) => this.Gui.Hide())
        gCancel.OnEvent("Click", (*) => this.GuiUpdate())
        g.OnEvent("Size", (*) => this.GuiUpdate())
        g.OnEvent("Close", (*) => this.GuiUpdate())
        this.Gui := g
        this.Guis := g
    }
}

class GuiInputHotstring extends GuiBase {
    Gui := {}
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
    MakeGui() {
        this.MakeBaseGui()
        this.Gui.MenuBar := this.GuiHotstringMenuBar(this.helpText)
    }

    SearchListView(*) {
        l := this.gui["List"]
        letters := StrSplit(this.gui["Search"].Text)
        l.Opt("-Redraw")
        l.Delete()
		rowNum := l.GetNext()
        matchedCount := 0
        for k, v in this.Macros {
            regTerm := "^.*"
            for inl, letter in  letters {
                regTerm .= letter ".*"
            }
            regTerm .= "$"
            haystack := (v.name != "") ? v.name : k
            matched := RegExMatch(haystack, "i)" regTerm)
            if (matched) {
                l.Add(, k, v.name)
                matchedCount += matched
            }

        }
        if (matchedCount) {
			l.Modify(rowNum, "+select")
            firstRow := l.GetText(l.GetNext())
            this.Gui["Text"].Text := this.Text[firstRow]

        }
        l.Opt("+Redraw")
    }
/*
*/
}
