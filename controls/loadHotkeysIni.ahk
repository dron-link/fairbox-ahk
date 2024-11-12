#Requires AutoHotkey v1.1

loadHotkeysIni() {
    global

    invalidHotkeysMsg := ""

    FileInstall, install\hotkeys.ini, % A_ScriptDir "\hotkeys.ini", 0 ; for when hotkeys.ini doesn't exist
    for index in hotkeys {
        ; alertTimer := new blameCulpritHotkey(index)

        ; Attempt to retrieve a hotkey activation key from the INI file.
        IniRead, savedHK%index%, hotkeys.ini, Hotkeys, % index, %A_Space%

        savedHK%index% := strReplace(savedHK%index%, "<#") ; do away with win modifiers if there's any
        savedHK%index% := strReplace(savedHK%index%, ">#")
        savedHK%index% := strReplace(savedHK%index%, "#")

        If (enabledHotkeys and strReplace(savedHK%index%, "~") != "") { ;If what was retrieved is a hotkey,
            if (hotkeys[index] = "Input On/Off") {
                Hotkey, If ; always active
            } else {
                Hotkey, If, enabledGameControls ; conditional hotkey
            }
            Hotkey, % savedHK%index%, Label%index%, UseErrorLevel              ; enable the hotkey.
            If (ErrorLevel != KEY_NAME_ERROR) {
                Switch ErrorLevel
                {
                    Case 1:
                        MsgBox, % "LoadHotkeys: The Label parameter specifies a nonexistent label name. "
                    Case 3:
                        MsgBox, % "LoadHotkeys: Unsupported prefix key."
                    Case 4:
                        MsgBox, % "LoadHotkeys: The KeyName parameter is not suitable for use with the AltTab or ShiftAltTab actions. A combination of (at most) two keys is required."
                    Case 5:
                        MsgBox, % "LoadHotkeys: The command attempted to modify a nonexistent hotkey."
                    Case 6:
                        MsgBox, % "LoadHotkeys: The command attempted to modify a nonexistent variant of an existing hotkey. To solve this, use Hotkey IfWin to set the criteria to match those of the hotkey to be modified."
                }
                Hotkey, % savedHK%index% . " UP", Label%index%_UP
            } else {
                invalidHotkeysMsg .= ""
                    . "The key name #" index " that corresponds to the " hotkeys[index] " button: "
                    . savedHK%index% " is not a valid hotkey." "`n"
                if deleteFailingHotkey {
                    IniWrite, % "~", hotkeys.ini, Hotkeys, % index ; deletes this hotkey in hotkeys.ini
                }
            }

        }

        HK%index% := savedHK%index%

        ; alertTimer.stop() ; the operation of retrieving the activation key finished
    }

    if invalidHotkeysMsg {
        if deleteFailingHotkey {
            invalidHotkeysMsg .= "`nThe key bindings mentioned were cleared.`n"
                . "Attempt opening the Controls Editor "
                . "and try binding a key to these buttons again."

            MsgBox, % invalidHotkeysMsg
        } else {
            enabledHotkeys := false
            promptInvalidHotkeys(invalidHotkeysMsg)
        }
    }

    return
}

promptInvalidHotkeys(invalidHotkeysMsg) {
    Critical
    invalidHotkeysMsg .= "`ndeleteFailingHotkey is turned off.`n`n`n"

    invalidHotkeysMsg .= ""
        . "Attempt one of the following:"
        . "`n`n"
        . "Open " A_ScriptDir "\hotkeys.ini and "
        . "delete the text (key name) to the right of the ''='' sign after each invalid hotkey's number,"
        . "or write a valid key name in its place."
        . "`n"
        . "There's no need to change anything else."
        . "`n`n"
        . "The other solution is to "
        . "rename the file the file hotkeys.ini, or moving it away, or deleting it. "
        . "All controls will be reset to their factory values but "
        . "this will let you edit the controls normally again."

    MsgBox, % invalidHotkeysMsg
    Critical Off
    ExitApp
}
