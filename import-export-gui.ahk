class ImportExport extends HTools {
    imported := map()
    g := {} ; interface control objects
    imexgui := {} ; import/export GUI

    __New() {
    }
    MakeImExGui() {
        gui := GuiCreate()
        this.g.newHot := gui.Add("ListView", "section checked w400 r12", "Trigger|Name|Match")
        this.g.newHot.Name := "newHot"
        this.g.newHot.Visible := false
        size := format(" w{1} h{2} "
            ,this.g.newHot.Pos.W,this.g.newHot.Pos.H)
        this.g.input := gui.Add("Edit", "ys xs" size, "")
        this.g.import := gui.Add("Button", "w90 xs", "Import")
        this.g.oldHot := gui.Add("ListView", "section ys" size, "Trigger|Name")
        this.g.transfer := gui.Add("Button", "xs w90", "Transfer")
        this.g.oldHot.Name := "oldHot"

        this.g.import.OnEvent("Click", (*) => this.ParseLines())
        this.g.newHot.OnEvent("Click", (*) => this.Compare())
        ;this.g.transfer.OnEvent("Click", (*) => this.OldToNew())
        gui.OnEvent("Close", (*) => this.imexgui.Destroy())
        this.imexgui := gui
    }
    Recreate() {
        this.imexgui.Destroy()
        this.MakeImExGui()
    }
    Show(ops := "") {
        this.MakeImExGui()
        this.imexgui.show(ops)
        this.FillExport()
    }
    Hide(ops := "") => this.imexgui.hide(ops)
    Compare() {
        lold := this.g.oldHot
        lnew := this.g.newHot
        newSel := lnew.GetText(lnew.GetNext(), 3)
        lold.Modify(newSel, "+Select")

    }
    ParseLines() {
        oldHot := this.g.oldHot, newHot := this.g.newHot, input := this.g.input
        newHot.Visible := true ; (hot.Visible = false) ? true : false
        input.Visible := false ; (imp.Visible = true) ? false : true
        this.imported := this.ParseSection(input.text)
        newHot.Opt("-Redraw")
        foundItems := []
        Loop oldHot.GetCount() {
            ;found := 0
            count := A_Index
            for k, v in this.imported { 
                if (k = oldHot.GetText(count)) { 
                    ;found := 1
                    foundItems.Push(count)
                }
            }
        }
        for k, v in this.imported
            newHot.Add(, k, v.name, foundItems[A_Index])
        newHot.Opt("+Redraw")
    }
    FillExport() {
        oldHot := this.imexgui["oldHot"]
        oldHot.Opt("-Redraw")
        for k, v in this.macros {
            oldHot.Add(, k, v.name)
        }
        oldHot.Opt("+Redraw")
    }
}
