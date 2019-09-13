#include gui-edit-use.ahk
class GuiBase extends HTools {
    static GuiLists := []
    inputWidth := 200
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

