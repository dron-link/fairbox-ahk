#Requires AutoHotkey v1.1

initializeHotkeys() {
    global
    
    if !enabledHotkeys {
        return
    }
    
    invalidHotkeysMsg := "" ; empty string unless we encounter an invalid key on hotkeys.ini

    Loop, % hotkeysList.Length() {
        If (hotkeysList[A_Index] = "") { ; We skip empty hotkey IDs if there are any
            Continue
        }
        If (strReplace(savedHK%A_Index%, "~") != "") { ;If what was retrieved is a hotkey,
            if (hotkeysList[A_Index] = "inputToggleKey") {
                Hotkey, If ; always active
            } 
            else {
                Hotkey, If, enabledGameControls ; conditional hotkey
            }
            Hotkey, % savedHK%A_Index%, % hotkeysList[A_Index] "Label", UseErrorLevel ; try to enable the hotkey.

            /*  The KeyName parameter specifies one or more keys that are either not recognized or 
                not supported by the current keyboard layout/language.
            */
            If (ErrorLevel != 2) { ; 2 = KEY_NAME
                Switch ErrorLevel ; Errors other than KEY_NAME should occur rarely.
                {
                    Case 1: ; all text extracted from autohotkey v1 documentation. hotkey error handling
                        MsgBox, % "initializeHotkeys() " hotkeysList[A_Index] ": The Label parameter specifies a nonexistent label name. "
                    Case 3:
                        MsgBox, % "initializeHotkeys() " hotkeysList[A_Index] ": Unsupported prefix key."
                    Case 4:
                        MsgBox, % "initializeHotkeys() " hotkeysList[A_Index] ": The KeyName parameter is not suitable for use with the AltTab or ShiftAltTab actions. A combination of (at most) two keys is required."
                    Case 5:
                        MsgBox, % "initializeHotkeys() " hotkeysList[A_Index] ": The command attempted to modify a nonexistent hotkey."
                    Case 6:
                        MsgBox, % "initializeHotkeys() " hotkeysList[A_Index] ": The command attempted to modify a nonexistent variant of an existing hotkey. To solve this, use Hotkey IfWin to set the criteria to match those of the hotkey to be modified."
                }
                Hotkey, % savedHK%A_Index% " UP", % hotkeysList[A_Index] "Label_UP" ; enable the hotkey.
            } else {
                invalidHotkeysMsg .= ""
                    . "The key name that corresponds to the " hotkeysDisplay[A_Index] ": "
                    . savedHK%A_Index% " is not a valid hotkey." "`n"
                if deleteFailingHotkey {
                    ; deletes this hotkey in hotkeys.ini
                    IniWrite, % "~", hotkeys.ini, Hotkeys, % hotkeysList[A_Index] 
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
            Suspend
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
`nAnother solution is renaming the file the file hotkeys.ini, or moving it away, or deleting it.
All controls will be reset to their factory values but this will let you edit the controls normally again.
`n
`nFinally, you could open the file " A_ScriptDir "\config.ini, go to where it says DeleteFailingHotkey=0
below the section [UserSettings], then change that 0 into a 1, save the file and launch fairbox again.
)"
    MsgBox, % invalidHotkeysMsg
    ExitApp
}
