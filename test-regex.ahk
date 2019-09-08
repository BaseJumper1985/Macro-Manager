string := "
    (
        some odd ` symbols {such} as " and \ and the like
        as well as some new lines
        just to mix things up.
    )"
pos := 0
matches := [], hash := map()
Loop {
    pos := RegExMatch(string, "\{([A-Za-z]+)}", found, pos+1)
    if (!pos)
        break
    word := found[1]
    if (!hash.Has(word)) {
        hash[word] := 1
        matches.Push(word)
    }
}
;msgbox(matches.Length)
out := string
for x, v in matches {
    out := RegExReplace(out, "\{" v "(:.+?)?}", "{" A_Index "$1}")
}
Gui := GuiCreate()
for x, v in matches {
    gui.Add("Text", "section x2 w90", v)
    gui.Add("Edit", "ys wp vBox" x)
}
Okay := gui.Add("Button", "w180", "Okay")
Okay.OnEvent("Click", (*) => Extract(Gui, matches, out))
Extract(gui, matches, out) {
    values := []
    for k, v in matches {
        values.Push(gui["Box" A_Index].Text)
    }
    msgbox(Format(out, values*))
}

Stringify(string, set := 1) {
    escapes := "
    (
        ([``]
        |["]
        |\\
        |\{
        |})
    )"
    if (set) {
        string := RegExReplace(string, "Simx)" escapes, "\$1")
        string := RegExReplace(string, "\R", "\R")
    }
    else {
        string := RegExReplace(string, "Simx)" "([\\])" escapes, "$2")
        string := RegExReplace(string, "\\R", "`r`n")
    }
    return string
}

newstring := (Stringify(string))
msgbox(newstring)
msgbox(Stringify(newstring, 0))

;Gui.Show()