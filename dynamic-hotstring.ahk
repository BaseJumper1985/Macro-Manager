#include gui-base.ahk

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
        pos := 1 ;The starting position where RegExMatch will start from allowing traversal of the string.
        hash := map() ;Hash map for use in avoiding duplicates.
        Loop {
            pos := RegExMatch(this.string, "\{([A-Za-z]+)}", found, pos)
            if (!pos)
                break ;break if RegExMatch does not find a match in the string.
            word := found[1]
            ;Use .Has method of maps to check for the presence of a value. This allows for the ilimination of duplicates.
            if (!hash.Has(StrLower(word))) { ;use StrLower because maps are case sensitive
                hash[word] := 1
                this.matches.Push(word)
            }
            pos := pos + found.Len(0) - 2
        }
    }

    Show(opt := "") {
        this.MakeGui()
        this.Gui.Show(Opt)
    }

    ;Build the gui using using unique values in the input string.
    MakeGui() {
        out := this.string
        g := GuiCreate()
        g.Title := "Fill Values"
        this.BuildChangeList()
        for x, v in this.matches {
            g.Add("Text", "section x2 w90", v)
            g.Add("Edit", "ys wp+30 vBox" x) ;Each loop will append an incremented value to the var name of the input box.
        }
        Okay := g.Add("Button", "x0 w180", "Okay")
        Okay.OnEvent("Click", (*) => this.MakeString()) ;call the function that builds the new ouput string.
        this.Gui := g
    }

    ;Format the text using case information extracted from each replacement field in the input string.
    FormatText(key, word) {
        out := word
        if (!RegExMatch(word, "^[A-Z].+")) {
            if (RegExMatch(key, "^[A-Z\s]+$")) {
                out := Format("{1:U}", word)
            }
            else if (RegExMatch(key, "^[A-Z][\w\s]+$")) {
                out := Format("{1:U}{2}", SubStr(word, 1, 1), SubStr(word, 2))
            }
        }
        return out
    }

    FillValues(values) {
        out := this.string
        for x, v in this.matches { ;For each unique item found when parsing the input string.
            pos := 1 ;start at position 1 (beginning of string)
            word := values[A_Index] ;a single entry from the gui, pulled from *Box#* of each gui Edit box.
            Loop {
                pos := RegExMatch(out, "i)\{(" v ")(:.+?)?}", matches, pos)
                if (!pos)
                    break
                key := matches[1]
                replace := this.FormatText(key, word)
                out := RegExReplace(out, "i)\{(" v ")(:.+?)?}", replace, , 1, pos)
                pos := pos + matches.Len(0) - 2
            }
        }
        return out
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
        out := this.FillValues(values)
        this.PasteText(this.key, out)
    }

/*
    MakeString() {
        this.Gui.Hide()
        values := this.Extract()
        formatter := this.BuildFormatString()
        out := Format(formatter, values*)
        this.PasteText(this.key, out)
    }
*/
}
