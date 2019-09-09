class DynamicHotstring extends GuiBase {
    key := ""
    string := ""
    matches := []
    Gui := {}

    __New(key, string) {
        this.string := string
        this.key := key
    }

    BuildChangeList() {
        pos := 0
        hash := map()
        Loop {
            pos := RegExMatch(this.string, "\{([A-Za-z]+)}", found, pos+1)
            if (!pos)
                break
            word := found[1]
            if (!hash.Has(word)) {
                hash[word] := 1
                this.matches.Push(word)
            }
        }
    }

    Show(opt := "") {
        this.MakeGui()
        this.Gui.Show(Opt)
    }

    MakeGui() {
        out := this.string
        g := GuiCreate()
        g.Title := "Fill Values"
        this.BuildChangeList()
        for x, v in this.matches {
            g.Add("Text", "section x2 w90", v)
            g.Add("Edit", "ys wp+30 vBox" x)
        }
        Okay := g.Add("Button", "x0 w180", "Okay")
        Okay.OnEvent("Click", (*) => this.MakeString())
        this.Gui := g
    }

    BuildFormatString() {
        out := this.string
        for x, v in this.matches {
            out := RegExReplace(out, "\{" v "(:.+?)?}", "{" A_Index "$1}")
        }
        return out
    }

    Extract() {
        values := []
        for k, v in this.matches {
            box := this.gui["Box" A_Index]
            values.Push(box.Text)
        }
        return values
    }

    MakeString() {
        this.Gui.Hide()
        values := this.Extract()
        formatter := this.BuildFormatString()
        out := Format(formatter, values*)
        this.PasteText(this.key, out)
    }
}
