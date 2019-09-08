class DynamicHotstrings extends HTools {
    string := "Dear {Customer}, your {car} is ready for pickup. Your bill will be {amount}"
    matches := []
    Gui := {}

    BuildChangeList(string) {
        pos := 0
        hash := map()
        Loop {
            pos := RegExMatch(string, "\{([A-Za-z]+)}", found, pos+1)
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
        this.Gui.Show(Opt)
    }

    MakeGui() {
        out := string
        g := GuiCreate()
        for x, v in this.matches {
            g.Add("Text", "section x2 w90", v)
            g.Add("Edit", "ys wp vBox" x)
        }
        Okay := g.Add("Button", "w180", "Okay")
        Okay.OnEvent("Click", (*) => this.Extract(this.Gui, this.matches, out))
        this.Gui := g
    }
    BuildFormatString(gui) {
        for x, v in this.matches {
            out := RegExReplace(out, "\{" v "(:.+?)?}", "{" A_Index "$1}")
        }
    }

    Extract(gui, matches, out) {
        values := []
        for k, v in this.matches {
            values.Push(gui["Box" A_Index].Text)
        }
        return out
    }

}