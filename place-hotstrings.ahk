
class PlaceHotstrings extends HTools {
    MakeGui() {
    helpText := "
    (
        Use the Search field at the top left to find a hotstring.
        Pressing Enter will select the top item from the list and
        paste its result into the last focused window.

        You can also change the formatting of the text by selecting
        one of the options on the right then Clicking [Okay] or
        Double Clicking the Hotstring in the List.
    )"
    leftWidth := 400
    preview := []
    Gui := GuiCreate()
    ;Gui.MenuBar := GuiHotstringMenuBar(helpText)
    Gui.SetFont("s12")
    Gui.Title := "Insert Hotstring"
    gSearch := Gui.Add("Edit", "w" leftWidth , "Search")
    
    gSearch.Name := "searchBox"
    gList := Gui.Add("ListView", "section w" leftWidth " r12", "Trigger|Name")
    for k, v in hst.macros {
        gList.Add(, k, v.name)
    }
    gList.Name := "hotstringList"
    
    gText := Gui.Add("Text", "r8 w400" , "Hotstring Preview")

    radioGroup := Gui.Add("Radio", "checked ys", "Paste without changes.")
    Gui.Add("Radio", , "Capitalize First Letter.")
    Gui.Add("Radio", , "Title Case Entire Phrase.")
    radioGroup.Name := "radioGroup"
    
    gOkay := Gui.Add("Button", "default section", "Okay")
    gCancel := Gui.Add("Button", "ys", "Cancel")

    gSearch.OnEvent("Change", (*) => this.SearchListView())
    gSearch.OnEvent("Focus", (*) => Send("^a"))
    gList.OnEvent("ItemFocus", (*) => OnFocus()) ; => single line function to assign a value. Java inspired
    gList.OnEvent("DoubleClick", (*) => PlaceText())
    gOkay.OnEvent("Click", (*) => PlaceText())
    gCancel.OnEvent("Click", (*) => Gui.Hide())
    gCancel.OnEvent("Click", (*) => GuiListUpdate())
    Gui.OnEvent("Size", (*) => GuiListUpdate())
    Gui.OnEvent("Close", (*) => GuiListUpdate())
    return Gui
    }

    OnFocus() {
        gText.Pos.W := 700
        gText.Text := hst.Text[ListSelection("T")]
    }
	ListSelection(type := "T") {
		if(type = "T") {
			return gList.GetText(gList.GetNext())
		}
	}
    
    PlaceText(*) {
        Gui.Hide()
		rowNum := gList.GetNext()
		rowText := gList.GetText(rowNum)
        cKeys := hst.CasedKeys(rowText)
        result := Gui.Submit(0)
        rv := result.radioGroup
        ClipBoard := hst.FormatText(cKeys[rv])
        WinWaitNotActive("Insert Hotstring")
        Gui["radioGroup"].Value := 1
        send("^v")
        hst.Used[rowText]++
    }

    SearchListView(*) {
        term := gSearch.Text
        letters := StrSplit(term)
        gList.Opt("-Redraw")
        gList.Delete()
		rowNum := gList.GetNext()
        matchedCount := 0
        for k, v in hst.macros {
            regTerm := "^.*"
            for inl, letter in  letters {
                regTerm .= letter ".*"
            }
            regTerm .= "$"
            haystack := (v.name != "") ? v.name : k
            matched := RegExMatch(haystack, "i)" regTerm)
            if (matched) {
                gList.Add(, k, v.name)
                matchedCount += matched
            }

        }
        if (matchedCount) {
			gList.Modify(rowNum, "+select")
            firstRow := gList.GetText(gList.GetNext())
            gText.Text := hst.Text[firstRow]

        }
        gList.Opt("+Redraw")
    }
}