class ImportExport extends HTools {
    imported := Map()
    gui := {} ; import/export GUI
    __New() {
    }
    MakeImExGui(*) {
        g := GuiCreate()
        guitop := 8
        g.SetFont("s12")
        g.Title := "Import\Export"
        lList := g.Add("ListView", "section checked w400 r12 y" guitop, "Trigger|Name")
        lList.Visible := false
        lList.Name := "lList"
        size := format(" w{1} h{2} "
            ,lList.Pos.W, lList.Pos.H)
        input := g.Add("Edit", "ys xs" size, "")
        input.Name := "input"
        lChall := g.Add("Button", "section w90", "Check All")
        lChnone := g.Add("Button", "ys", "Check None")
        lText := g.Add("Text", "xs border" size,"")
        import := g.Add("Button", "w90 y120", "Import")
        import.Visible := false
        import.Name := "import"
        parseIn := g.Add("Button", "wp xp yp ", "Parse")
        parseIn.Name := "parseIn"
        clip := g.Add("Button", "wp", "Copy")
        clip.Visible := false
        clip.Name := "clip"
        export := g.Add("Button", "wp xp yp", "Export")
        export.Name := "export"
        rList := g.Add("ListView", "section checked y" guitop size, "Trigger|Name")
        rList.Name := "rList"
        rChall := g.Add("Button", "section w90", "Check All")
        rInvert := g.Add("Button", "ys w90", "Invert")
        rChnone := g.Add("Button", "ys", "Check None")
        rText := g.Add("Text", "xs border" size,"")

        parseIn.OnEvent("Click", (*) => this.ParseLines(lList, rList, input))
        import.OnEvent("Click", (*) => this.ImportChecked(lList))
        lList.OnEvent("ItemFocus", (*) => this.Compare(lList, lText, rList, rText))
        rList.OnEvent("ItemFocus", (*) => rText.Text := this.Text[rList.GetText(rList.GetNext(1, "F"))])

        lChall.OnEvent("Click", (*) => lList.Modify(0, "+Check"))
        lChnone.OnEvent("Click", (*) => lList.Modify(0, "-Check"))
        rChall.OnEvent("Click", (*) => rList.Modify(0, "+Check"))
        rInvert.OnEvent("Click", (*) => this.InvertSelection(rList))
        rChnone.OnEvent("Click", (*) => rList.Modify(0, "-Check"))

        clip.OnEvent("Click", (*) => this.CopyToClipboard(input))
        export.OnEvent("Click", (*) => this.ExportRList(rList, input))
        g.OnEvent("Close", (*) => this.gui.Destroy())
        this.gui := g
    }

    InvertSelection(list) {
        currentRow := list.GetNext(0, "C")
        Loop list.GetCount() {
            if (list.GetNext(A_Index - 1, "C") = A_Index) {
                list.Modify(A_Index, "-check")
            }
            else {
                list.Modify(A_Index, "+check")
            }
        }
    }

    Recreate(*) {
        this.gui.Destroy()
        this.MakeImExGui()
    }

    Show(ops := "") {
        this.MakeImExGui()
        this.gui.show(ops)
        this.FillRList()
    }

    ExportRList(rList, input) {
        export := this.Gui["export"].Visible := false
        clip := this.Gui["clip"].Visible := true
        out := ""
        currentRow := 0
        Loop rList.GetCount() {
            currentRow := rList.GetNext(currentRow, "C")
            if (!currentRow)
                break
            key := rList.GetText(currentRow, 1)
            line := key "=" this.MakeIniEntry(key) "`r`n"
            out .= line
        }
        input.Text := out
    }

    CopyToClipboard(input) {
        input.Focus()
        Send("^a")
        Send("^c")
        MsgBox("Contents copied to clipboard")
    }

    ImportChecked(lList) {
        currentRow := 0
        Loop {
            currentRow := lList.GetNext(currentRow, "C")
            if (!currentRow)
                break
            key := lList.GetText(currentRow, 1)
            this.Macros[key] := this.imported[key]
            this.SetHotstring(key)
        }
    }

    Hide(ops := "") => this.gui.hide(ops)

    ParseLines(lList, rList, input) {
        this.gui["parseIn"].Visible := false
        this.gui["import"].Visible := true
        lList.Visible := true ; (hot.Visible = false) ? true : false
        input.Visible := false ; (imp.Visible = true) ? false : true
        this.imported := this.ParseSection(input.text)
        lList.Opt("-Redraw")
        Loop rList.GetCount() {
            count := A_Index
            for k, v in this.imported { 
                n := this.imported[k]
                if (k = rList.GetText(count, 1)) { 
                    n.rRow := count
                }
                if (!n.rRow) {
                    n.rRow := 0
                }
            }
        }
        for k, v in this.imported {
            v.modified := 1 ; these are all potentially new
            shouldCheck := (v.rRow) ? "" : "check"
            lList.Add(shouldCheck, k, v.name)
        }
        lList.ModifyCol()
        lList.Opt("+Redraw")
    }

    ; return the row index of a row/col value in a ListView object
    FindIn(list, key, col := 1) {
        loop list.GetCount() {
            current := list.GetText(A_Index, col)
            if (current = key) {
                return A_Index
            }
        }
        return 0
    }

    Compare(lList, lText, rList, rText) {
        lkey := lList.GetText(lList.GetNext(,"F"), 1)
        rList.Modify(0, "-Select")
        foundAt := this.FindIn(rList, lKey)
        if (foundAt) {
            rList.Modify(foundAt, "+Select Vis")
        }
        lText.Text := this.imported[lkey].text
        rText.Text := (foundAt) ? this.Text[lkey] : ""
        

    }
    
    FillRList(*) {
        rList := this.Gui["rList"]
        rList.Opt("-Redraw")
        for k, v in this.macros {
            rList.Add(, k, v.name)
        }
        rList.Opt("+Redraw")
    }
}
