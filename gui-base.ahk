#include gui-edit-use.ahk
class GuiBase extends HTools {
    static GuiLists := []
    inputWidth := 200
    searchSuccess := false
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
        g.SetFont("s11", "Consolas")
        gText := g.Add("Text", "section vText r4 w" leftWidth , "Hotstring Preview")
        g.SetFont()
        g.SetFont("s12", "Ms Sans")
        gSearch := g.Add("Edit", "vSearch w" leftWidth , "Search")
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
        for i, gui in this.Guis {
            l := gui["List"]
            l.Opt("-Redraw")
            l.Delete()
            l.InsertCol(3, "0")
            for key, value in this.Macros {
                l.Add(, key, value.name, value.used)
            }
            l.ModifyCol(1, "AutoHdr")
            l.ModifyCol(2, "AutoHdr")
            l.DeleteCol(3)
            l.Opt("+Redraw")
        }
    }

    GuiHotstringMenuBar(helpText) {
        files := MenuCreate()
        files.Add("&Exit Application", (*) => ExitApp())
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

    ListSelection(type := "T", col := 1) {
        l := this.Gui["List"]
        if(type = "T") {
            return l.GetText(l.GetNext(), col)
        }
    }

    SearchListView(*) {
        l := this.gui["List"]
        search := this.gui["Search"].Text
        if (!search or !RegExMatch(search, "[\w\s]+")) {
            this.GuiUpdate()
            return
        }
        letters := StrSplit(search)
        l.Opt("-Redraw")
        l.Delete()
        l.InsertCol(3, "0")
        matchedCount := 0
        for k, v in this.Macros {
            regTerm := "^.*" ; beggining of string
            for inl, letter in  letters {
                regTerm .= letter ".*" ; any letters appearing in the same sequence at location.
            }
            regTerm .= "$" ; end of string
            haystack := k v.name
            matched := RegExMatch(haystack, "i)" regTerm)
            if (matched) {
                l.Add(, k, v.name, v.used)
                matchedCount += matched
            }

        }
        if (matchedCount) {
            l.ModifyCol(1, "AutoHdr")
            l.ModifyCol(2, "AutoHdr")
            l.ModifyCol(3, "0 SortDesc")
            l.Modify(0, "-select")
            l.Modify(1, "+select")
            this.OnFocus()
        }
        l.DeleteCol(3)
        l.Opt("+Redraw")
    }
}

