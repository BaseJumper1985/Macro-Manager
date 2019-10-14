#Include import-export-gui.ahk
#include gui-base.ahk
#include dynamic-hotstring.ahk

class HTools {
    static IniFile := ""
    static IniEntries := map()
    Fields := ["name", "type", "used", "text"]
    __New(fileInput) {
        %this.__class%.IniFile := fileInput
        this.GetEntries("Macros")
        this.MakeAllHotstrings()
    }
    Setting[key] {
        get => IniRead(%this.__class%.IniFile, "Settings", key)
        set => IniWrite(value, %this.__class%.IniFile, "Settings", key)
    }
    ; Do not set values using this unless you also set modified := 1
    ; or the changes will not be passed to the ini file.
    Macros[] {
        get => %this.__class%.IniEntries
        set => %this.__class%.IniEntries := value
    }
    Modified[key] {
        get => %this.__class%.IniEntries[key].modified
        set {
            %this.__class%.IniEntries[key].modified := value
        }
    }
    Type[key] {
        get => %this.__class%.IniEntries[key].type
        set {
            %this.__class%.IniEntries[key].type := value
            this.Modified[key] := 1
        }
    }
    Used[key] {
        get => %this.__class%.IniEntries[key].used
        set {
            %this.__class%.IniEntries[key].used := value
            this.Modified[key] := 1
        }
    }
    Text[key] {
        get => %this.__class%.IniEntries[key].text
        set {
            %this.__class%.IniEntries[key].text := value
            this.Modified[key] := 1
        }
    }
    Name[key] {
        get => %this.__class%.IniEntries[key].name
        set {
            %this.__class%.IniEntries[key].name := value
            this.Modified[key] := 1
        }
    }

    GetEntries(header) {
        tempArray := this.GetIniSection(header)
        tempEntries := this.ParseSection(tempArray)
        this.Macros := tempEntries
        return tempEntries
    }

    MakeAllHotstrings() {
        ; Create all the HotStrings and make a key lookup for other tasks.
        for k, v in this.Macros {
            this.SetHotstring(k)
        }
    }

    ; set hotstring from a given list of cased keys
    SetHotstring(key, stringEnable := 1) {
        Hotstring(":*CX:" key "  ", (*) => this.OutputType(A_ThisHotkey), stringEnable)
    }

    OutputType(key) {
        key := Trim(RegExReplace(key, "^:.+?:"))
        if (this.Type[key] = "Standard") {
            this.PasteText(key)
        }
        else if (this.Type[key] = "Dynamic") {
            this.DynamicOut(key)
        }
    }

    DynamicOut(key) {
        this.dynamic := ""
        this.dynamic := DynamicHotstring.new(key, this.Text[key])
        this.dynamic.show()
    }

    PasteText(key, alt := "") {
        out := (alt) ? alt : this.Text[key]
        Clipboard := out
        sleep(50)
        Send("^v")
        this.Used[StrLower(key)]++
        return
    }

    ParseSection(section) { 
        IniArray := map()
        sectionArray := StrSplit(section, "`n") ; split each line of section into array
        for k, v in sectionArray {
            if (v != "") {
                ;splitKey := StrSplit(v, "=") ; this did not handle `=` inside any other parts of the entry.
                pos := RegExMatch(v, "^(\w+)=(.+)", matched)
                key := matched[1]
                text := matched[2]
                ; extract the name of the ini listing if present
                IniArray[key] := this.ParseElements(text)
            }
        }
        return IniArray
    }

    ParseElements(inText) {
        ; quote character for use in regex
        entry := {}
        for i, item in this.fields {
            pos := RegExMatch(inText, "(?:(^|\}))\{" item ":(?P<" item ">.*?[^\\])}", matched)
            if (!pos)
                break
            entry.%item% := (pos) ? matched[item] : ""
            pos := pos + matched.Len(0) - 2
        }
        entry.modified := 0
        entry.text := this.Stringify(entry.text, 0)
        return entry
    }
    
    AddEntry(key, type, name, text) {
        entry := {}
        entry.name := name
        entry.type := type
        entry.used := 0
        entry.modified := 1
        entry.text := text
        this.Macros[key] := entry
    }

    Stringify(string, set := 1) {
        escapes := "
        (
            ([``]
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


    GetIniSection(header) {
        ; get section from ini file and return the text from the ini section
        return IniRead(%this.__class%.IniFile, header)
    }

    MakeIniEntry(key) {
        out := ""
        for k, label in this.Fields {
            out .= this.MakeLabel(label, this.Macros[key].%label%)
        }
        return out
    }

    MakeLabel(label, content) {
        out := this.Stringify(content)
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

/*
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
*/
/*
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
*/