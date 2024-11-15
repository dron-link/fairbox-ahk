#Requires AutoHotkey v1.1

initializeControls() {
    global

    if !enabledHotkeys {
        return
    }

    invalidHotkeysMsg := "" ; empty string unless we encounter an invalid key on hotkeys.ini

    for index in hotkeys {
        If (strReplace(savedHK%index%, "~") != "") { ;If what was retrieved is a hotkey,
            if (hotkeys[index] = "Input On/Off") {
                Hotkey, If ; always active
            } 
            else {
                Hotkey, If, enabledGameControls ; conditional hotkey
            }
            Hotkey, % savedHK%index%, Label%index%, UseErrorLevel ; try to enable the hotkey.
            If (ErrorLevel != KEY_NAME_ERROR) {
                Switch ErrorLevel
                {
                    Case 1:
                        MsgBox, % "initialize Control index " index ": The Label parameter specifies a nonexistent label name. "
                    Case 3:
                        MsgBox, % "initialize Control index " index ": Unsupported prefix key."
                    Case 4:
                        MsgBox, % "initialize Control index " index ": The KeyName parameter is not suitable for use with the AltTab or ShiftAltTab actions. A combination of (at most) two keys is required."
                    Case 5:
                        MsgBox, % "initialize Control index " index ": The command attempted to modify a nonexistent hotkey."
                    Case 6:
                        MsgBox, % "initialize Control index " index ": The command attempted to modify a nonexistent variant of an existing hotkey. To solve this, use Hotkey IfWin to set the criteria to match those of the hotkey to be modified."
                }
                Hotkey, % savedHK%index% " UP", Label%index%_UP ; enable the hotkey.
            } else {
                invalidHotkeysMsg .= ""
                    . "The key name #" index " that corresponds to the " hotkeys[index] " button: "
                    . savedHK%index% " is not a valid hotkey." "`n"
                if deleteFailingHotkey {
                    IniWrite, % "~", hotkeys.ini, Hotkeys, % index ; deletes this hotkey in hotkeys.ini
                }
            }
        }
    }

    if invalidHotkeysMsg {
        if deleteFailingHotkey {
            invalidHotkeysMsg .= "
( Join`s
`nThe key bindings mentioned were cleared.
`nAttempt opening the Controls Editor and try binding a key to these buttons again. 
)"

            MsgBox, % invalidHotkeysMsg
        } else {
            enabledHotkeys := false
            promptInvalidHotkeys(invalidHotkeysMsg)
        }
    }

    return
}

promptInvalidHotkeys(invalidHotkeysMsg) {
    invalidHotkeysMsg .= "
( Join`s
`ndeleteFailingHotkey is turned off.
`n
`n
`nAttempt one of the following:
`n
`nOpen " A_ScriptDir "\hotkeys.ini and delete the text (key name) to the right of 
the ''='' sign after each invalid hotkey's number, or write a valid key name in its place.
`nThere's no need to change anything else.
`n
`nThe other solution is renaming the file the file hotkeys.ini, or moving it away, or deleting it.
All controls will be reset to their factory values but this will let you edit the controls normally again.
)"
    MsgBox, % invalidHotkeysMsg
    ExitApp
}
