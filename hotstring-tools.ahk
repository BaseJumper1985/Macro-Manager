class HTools {
    static IniFile := ""
    static HObjects := map()
    Fields := ["name", "used", "text"]
    __New(fileInput) {
        %this.__class%.IniFile := fileInput
        this.GetHotstrings("Macros")
        this.MakeAllHotstrings()
    }
    Setting[key] {
        get => IniRead(%this.__class%.IniFile, "Settings", key)
        set => IniWrite(value, %this.__class%.IniFile, "Settings", key)
    }
    ; Do not set values using this unless you also set modified := 1
    ; or the changes will not be passed to the ini file.
    Macros[] {
        get => %this.__class%.HObjects
        set => %this.__class%.HObjects := value
    }
    Modified[key] {
        get => %this.__class%.HObjects[key].modified
        set {
            %this.__class%.HObjects[key].modified := value
        }
    }
    Used[key] {
        get => %this.__class%.HObjects[key].used
        set {
            %this.__class%.HObjects[key].used := value
            this.Modified[key] := 1
        }
    }
    Text[key] {
        get => %this.__class%.HObjects[key].text
        set {
            %this.__class%.HObjects[key].text := value
            this.Modified[key] := 1
        }
    }
    Name[key] {
        get => %this.__class%.HObjects[key].name
        set {
            %this.__class%.HObjects[key].name := value
            this.Modified[key] := 1
        }
    }

    GetHotstrings(header) {
        tempArray := this.GetIniSection(header)
        tempEntries := this.ParseSection(tempArray)
        this.Macros := tempEntries
        return tempEntries
    }

    MakeAllHotstrings() {
        ; Create all the HotStrings and make a key lookup for other tasks.
        for k in this.Macros {
            this.SetHotstring(k)
        }
    }
    ; takes input string and creates two other versions eg. lol/Lol/LOL
    ; these are used in the different types of key replacements that deal
    ; with capitalization and the like.
    CasedKeys(sKey) {
        c := [] ; case modified keys
        c.Push Format("{1:l}",      sKey) ; format key all lower case
        c.Push Format("{1:U}{2:l}", SubStr(sKey, 1, 1), SubStr(sKey, 2)) ; format key senetence case
        c.Push Format("{1:U}",      sKey) ; format key all caps
        return c
    }

    ; set hotstring from a given list of cased keys
    SetHotstring(key, stringEnable := 1) {
        cKeys := this.CasedKeys(key)
        for i, x in cKeys {
            Hotstring(":CX:" x " ", (*) => this.PasteText(A_ThisHotkey), stringEnable)
        }
    }

    PasteText(hKey) {
        key := Trim(RegExReplace(hKey, "^:\w*:"))
        out := this.FormatText(key)
        Clipboard := out
        sleep(50)
        Send("^v")
        this.Used[key]++
        return
    }

    FormatText(key) {
        iniText := this.Text[StrLower(key)] ; hotstrings is global
        if (RegExMatch(key, "^[A-Z][a-z]+$")) {
            out := Format("{1:U}{2}", SubStr(iniText, 1, 1), SubStr(iniText, 2))
        }
        else if (RegExMatch(key, "^[A-Z]+$")) {
            out := Format("{1:t}", iniText)    
        }
        else {
            out := Format("{1}", iniText)
        }
        return out
    }

    ParseSection(section) { 
        IniArray := map()
        sectionArray := StrSplit(section, "`n") ; split each line of section into array
        for k, v in sectionArray {
            if (v != "") {
                splitKey := StrSplit(v, "=")
                key := splitkey[1]
                text := splitkey[2]
                ; extract the name of the ini listing if present
                IniArray[key] := this.ParseElements(text, this.Fields)
            }
        }
        return IniArray
    }

    ParseElements(inText, fields) {
        entry := {}
        for i, item in fields {
            reg := RegExMatch(inText, "\{" item ":(?P<" item ">.*?)}(,|$)", matched)
            if (reg) {
                entry.%item% := matched[item]
            }
        }
        entry.modified := 0
        entry.text := RegExReplace(entry.text, "i)\\eol", "`r`n")
        return entry
    }

    AddHotstring(key, name, text) {
        entry := {}
        entry.used := 0
        entry.modified := 1
        entry.name := name
        entry.text := text
        this.Macros[key] := entry
    }

    GetIniSection(header) {
        ; get section from ini file and return the text from the ini section
        return IniRead(%this.__class%.IniFile, header)
    }

    MakeIniEntry(key) {
        out := ""
        for k, label in this.Fields {
            out .= this.MakeLabel(label, this.Macros[key].%label%)
            if (k < this.Fields.Length)
                out .= ","
        }
        return out
    }

    MakeLabel(label, content) {
        out := RegExReplace(content, "\R", "\eol")
        out := "{" label ":" out "}"
        return out
    }

    ParseSelection(*) {
        result := MsgBox("First select the text you want to modify then click Ok", "Convert Selection", "OC " 262144)
        if (result = "Ok") {
            Send("^c")
            Sleep(250)
            Modify := Clipboard
            Sleep(250)
            for k, v in this.Macros { ; hotstrings is global
                Modify := RegExReplace(Modify, "i)\b" k "\b", v.text)
            }
            Clipboard := Modify
            Sleep(250)
            SendInput("^v")
        }
    }

    SaveModified() {
        for k, v in this.Macros {
            notify := 0
            if (v.modified = 1) {
                if (notify) {
                    TrayTip("Saved", "The config file has been updated", "Mute")
                    notify := 0
                }
                v.modified := 0
                newEntry := this.MakeIniEntry(k)
                IniWrite(newEntry, %this.__class%.IniFile, "Macros", k)
            }
        }
    }

}
