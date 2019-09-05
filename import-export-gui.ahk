class ImportExport extends HTools {
    imported := Map()
    gui := {} ; import/export GUI
    lastSelect := 1

    __New() {
    }
    getC[name] {
        get => this.guiControls.%name%
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
        leftText := g.Add("Text", "border" size,"")
        leftText.Name := "leftText"
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
        rightText := g.Add("Text", "border" size,"")
        rightText.Name := "rightText"

        parseIn.OnEvent("Click", (*) => this.ParseLines())
        import.OnEvent("Click", (*) => this.ImportSelected())
        lList.OnEvent("ItemFocus", (*) => this.Compare())
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
    Hide(ops := "") => this.gui.hide(ops)
    Compare() {
        lold := this.gui["rList"]
        lnew := this.gui["lList"]
        left := this.gui["leftText"]
        right := this.gui["rightText"]
        lkey := lnew.GetText(lnew.GetNext(), 1)
        newSel := this.imported[lkey].rRow
        rkey := lold.GetText(newSel, 1)
        lold.Modify(0, "-Select")
        lold.Modify(newSel, "+Select Vis")
        left.Text := this.imported[lkey].text
        right.Text := this.Text[lkey]
        

    }
    ParseLines() {
        this.gui["parseIn"].Visible := false
        this.gui["import"].Visible := true
        rList := this.gui["rList"], lList := this.gui["lList"]
            , input := this.gui["input"]
        lList.Visible := true ; (hot.Visible = false) ? true : false
        input.Visible := false ; (imp.Visible = true) ? false : true
        this.imported := this.ParseSection(input.text)
        lList.Opt("-Redraw")
        foundItems := []
        Loop rList.GetCount() {
            ;found := 0
            count := A_Index
            for k, v in this.imported { 
                n := this.imported[k]
                if (k = rList.GetText(count, 1)) { 
                    ;found := 1
                    n.rRow := count
                }
                if (!n.rRow) {
                    n.rRow := 0
                }
            }
        }
        for k, v in this.imported
            lList.Add(, k, v.name)
        lList.Opt("+Redraw")
    }
    FillExport() {
        rList := this.gui["rList"]
        rList.Opt("-Redraw")
        for k, v in this.macros {
            rList.Add(, k, v.name)
        }
        rList.Opt("+Redraw")
    }
}
