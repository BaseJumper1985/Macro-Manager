class ImportExport extends HTools {
    imported := Map()
    gui := {} ; import/export GUI
    __New() {
    }
    MakeImExGui() {
        g := GuiCreate()
        g.SetFont("s12")
        lList := g.Add("ListView", "section checked w400 r12", "Trigger|Name|Conflict")
        lList.Visible := false
        lList.Name := "lList"
        size := format(" w{1} h{2} "
            ,lList.Pos.W, lList.Pos.H)
        input := g.Add("Edit", "ys xs" size, "")
        lText := g.Add("Text", "border" size,"")
        input.Name := "input"
        ;text := 
        import := g.Add("Button", "w90 ys", "Import")
        import.Visible := false
        import.Name := "import"
        parseIn := g.Add("Button", "wp xp yp ", "Parse")
        parseIn.Name := "parseIn"
        transfer := g.Add("Button", "wp", "Transfer")
        rList := g.Add("ListView", "section ys" size, "Trigger|Name")
        rList.Name := "rList"
        rText := g.Add("Text", "border" size,"")

        parseIn.OnEvent("Click", (*) => this.ParseLines(lList, rList, input))
        import.OnEvent("Click", (*) => this.ImportChecked(lList))
        lList.OnEvent("ItemFocus", (*) => this.Compare(lList, lText, rList, rText))
        transfer.OnEvent("Click", (*) => this.OldToText())
        g.OnEvent("Close", (*) => this.gui.Destroy())
        this.gui := g
    }
    Recreate() {
        this.gui.Destroy()
        this.MakeImExGui()
    }
    Show(ops := "") {
        this.MakeImExGui()
        this.gui.show(ops)
        this.FillExport()
    }
    ImportChecked(lList) {
        currentRow := 0
        Loop {
            currentRow := lList.GetNext(currentRow, "C")
            if (!currentRow)
                break
            key := lList.GetText(currentRow, 1)
            this.Macros[key] := this.imported[key]
            /*
            name := this.imported[key].name
            text := this.imported[key].text
            this.AddHotstring(key, name, text)
            this.Modified[key] := 1
            */
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
    FillRList(rList) {
        rList.Opt("-Redraw")
        for k, v in this.macros {
            rList.Add(, k, v.name)
        }
        rList.Opt("+Redraw")
    }
}
