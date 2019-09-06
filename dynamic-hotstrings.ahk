class DynamicHotstrings extends HTools {
    dStrings := map()
    gui := {}
    __New() {
        this.MakeDynamicGui()
    }
    Show() {
        this.gui.show()
        this.but.Destroy()
    }
    MakeDynamicGui() {
        g := GuiCreate()
        g.SetFont("s11")
        this.but := g.Add("Button", "section w90", "Add")
        this.string := g.Add("Edit", "ys", "This is a separator.")

        this.but.OnEvent("Click", (*) => this.ParseDynamic())
        this.gui := g
    }
    ParseDynamic() {
        wordList := []
    }
}