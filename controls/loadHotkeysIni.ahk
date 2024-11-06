#Requires AutoHotkey v1.1

loadHotkeysIni() {
    global
    for index in hotkeys {
        alertTimer := new blameCulpritHotkey(index)

        ; Attempt to retrieve a hotkey activation key from the INI file.
        IniRead, savedHK%index%, hotkeys.ini, Hotkeys, % index, %A_Space%

        savedHK%index% := strReplace(savedHK%index%, "#") ; do away with win modifiers if there's any
        If (enabledHotkeys and strReplace(savedHK%index%, "~") != "") { ;If new hotkey exists,
            Hotkey, % savedHK%index%, Label%index% ;  enable it.
            Hotkey, % savedHK%index% . " UP", Label%index%_UP ;  enable it.
        }

        HK%index% := savedHK%index%

        alertTimer.stop() ; the operation of retrieving the activation key finished
    }
    return
}

class blameCulpritHotkey {
    timer := ObjBindMethod(this, "blameMethod")
    __New(culpritNum) { ; adapted from autohotkey documentation example on setTimer
        this.num := culpritNum
        timer := this.timer
        setTimer, % timer, -800 ; if retrieving the activation key takes more than 800ms, blameMethod will fire
    }
    blameMethod() {
        global hotkeys, global loadHotkeysIniFail
        myErrorMsg := "Error while reading hotkeys on app launch. "
            . "The culprit hotkey is " hotkeys[this.num] " (button number " this.num ").`n`n"
            . "Attempt one of the following:`n`n"
            . "Open " A_ScriptDir "\hotkeys.ini and "
            . "delete the text to the right of ''" this.num "=''`n"
            . "There's no need to change anything else.`n`n"
            . "The other solution is to "
            . "rename the file the file hotkeys.ini, or moving it away, or deleting it. "
            . "All controls will be reset to their factory values but "
            . "this will let you edit the controls normally again."
        loadHotkeysIniFail := true
        OutputDebug, % "`n "myErrorMsg "`n"
        MsgBox, % myErrorMsg
        return
    }
    stop() {
        timer := this.timer
        setTimer, % timer, Delete
        return
    }
}