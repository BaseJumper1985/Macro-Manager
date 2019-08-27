
class GuiEditHotstrings extends HotstringTools {
    gList := {}, gText := {}
    __New() { 
        helpText := "
        (
            You can use this window to:
            Create, Edit, and Delete Hotstrings

            To add a new Hotstring, simply fill in the [Box] at
            the top of the window with a new Hotstring then type the
            result of the Hotstring in the box below and click [Apply]

            To Delete a Hotstring, select the Hotstring from the List
            on the left then click [Delete Hotstring]

            To Edit a Hotstring, select a Hotstring from the List on the
            left then change result of the Hotstring in the [Box] to
            the right before clicking [Apply]
        )"
        Gui := GuiCreate()
        Gui.Title := "Edit Hotstrings"
        Gui.MenuBar := GuiHotstringMenuBar(helpText)
        Gui.SetFont("s12")
        listKeys := GetIniKeys()
        gList := Gui.Add("ListBox", "section w200 r12", listKeys)
        gList.Name := "hotstringList"
        gDelete := Gui.Add("Button", "", "Delete Hotstring")
        gText := Gui.Add("Text", "ys", "New Hotstring")
        gInput := Gui.Add("Edit", "ys r1 w200") ; hotstring input box
        gAdd := Gui.Add("Button", "ys h" gInput.Pos.H, "Apply")
        Gui.Add("Text", "section", "Name")
        gName := Gui.Add("Edit", "r1 ys", "")
        gEdit := Gui.Add("Edit", Format("r12 x{1} y{2} w400 WantTab" ; hotstring result editor
                                , gText.Pos.X, gText.Pos.Y+58), "Place hotstring result here")
        
        
        gLIst.OnEvent("Change", (*) => this.SetText()) ; => single line function to assign a value. Java inspired
        gDelete.OnEvent("Click", (*) => this.GuiRemoveHotstrings(gList.Text))
        gAdd.OnEvent("Click", (*) => this.GuiModifyLine(gInput.Text, gEdit.Text, gName.Text))
        ;GuiListUpdate()
        return Gui
    }

    GuiModifyLine(key, value, name := "") {
        newValue := RegExReplace(value, "\R", "\eol")
        if(name != "") {
            name := "${" name "}"
        }
        IniWrite(name newValue, iniFile, "Macros", key) ; write the new key and value the ini file
        sleep 80 ; wait for 80 miliseconds as writes may not finish before the program moves on
        SetHotstrings(key, 1) ; create the hotstrings and make sure they are enabled
        base.HotEntries[key].text := newValue
        GuiListUpdate()
        ;GuiResets()
    }

    ; set the input field and the edit box the reflect the current selection
    ; in the list box control
    SetText() {
        gEdit.Text := base.Hotstrings[gList.Text].text
        gInput.Text := gList.Text
    }

    ; resets the hotstring insertion gui so it gets any channged values
    GuiResets() {
        GhotUse.Destroy()
        GhotUse := GuiInsertHotstring()
    }

    GuiRemoveHotstrings(deleter) {
        ; get confirmation from the user before continuing
        confirm := MsgBox("Are you sure you want to delete the hotstring [" deleter "]`nand its resulting text`n" base.HotEntries[deleter].text, "Confirm", "YN")
        if (confirm = "Yes") {
            IniDelete(iniFile, "Macros", deleter) ; remove the line from the ini file
            HotEntries.Delete(deleter) ; remove key from assosiative array of hotstrings
            GuiListUpdate() ; destroy and rebuild relavent guis
            ;gList.Delete(gList.Value) ; remove matching value from the list
            SetHotstrings(deleter, 0) ; desable all hotstring with (enable=0)
        }
    }
}