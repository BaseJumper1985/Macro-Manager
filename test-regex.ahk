string := "{This} is {SOME} text. {All} the {WORDS} {All} {All} {All} {All} {All} in {SOME} brackets {should} be {WORDS} the {ONLY} things {FOUND}"
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

Gui.Show()