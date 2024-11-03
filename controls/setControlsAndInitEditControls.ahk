#Requires AutoHotkey v1.1

setControlsAndInitWindow() { ; adopt saved hotkeys and initialize Edit Controls menu
    global
    for index, element in hotkeys {
        ; determine start position of each set of gui elements
        if (index > 24) {
            xOff := 420 + descriptionWidth
            yOff := (index-1-24)*25
        } else {
            xOff := 0
            yOff := (index-1)*25
        }
    
        hotkeyIndexNow := index ; save in case of showing error message
        SetTimer, blameCulpritHotkey, -800 ; if this thread is interrupted by an error, a msgbox will display
    
        ; adds borderless text N°1 and associates it to variable gameBtName1, and so on
        Gui, Add, Text, xm+%xOff% ym+%yOff% vGameBtName%index%, % element " button:"
        ; Attempt to retrieve a hotkey activation key from the INI file.
        IniRead, savedHK%index%, hotkeys.ini, Hotkeys, % index, %A_Space%
        ;Activate saved hotkey
        If (enabledHotkeys and strReplace(savedHK%index%, "~", "") != "") { ;If new hotkey exists,
            Hotkey, % savedHK%index%, Label%index% ;  enable it.
            Hotkey, % savedHK%index% . " UP", Label%index%_UP ;  enable it.
    
            /*  sets the value of the variable associated with the Prevent Default Behavior checkbox.
                The value is retrieved every time we assign a new hotkey:
                IF the checkbox is unmarked, we put "~" before the string that represents the key combination
                retrieved from the hotkey control.
            */
            if InStr(savedHK%index%, "~") { ; if ~ is in the activation key
                ; the user wants the key or key combination to preserve all its functionality
                preventBehavior%index% := false
            } else {
                ; the key will only work as a controller input; won't work outside of the game
                preventBehavior%index% := true 
            }
        }
        ; empty hotkeys will display as unmarked
        if (strReplace(savedHK%index%, "~", "") = "") {
            preventBehavior%index% := false
        }
    
        xOffHK := xOff + 117 ; advance past the text of the button name for the hotkey control location
    
        HK%index% := savedHK%index%
        ;Add controls and show the saved key
        Gui, Add, Hotkey, xm+%xOffHK% ym+%yOff% w%descriptionWidth% vHK%index% gActivationKeyCheck, % getHotkeyControlFormat(savedHK%index%)
        if !preventBehavior%index% {
            Gui, Add, CheckBox, x+5 vPreventBehavior%index% gDefaultBehaviorChange, % "Prevent Default Behavior"
        } else {
            Gui, Add, CheckBox, x+5 vPreventBehavior%index% Checked gDefaultBehaviorChange, % "Prevent Default Behavior"
        }
        isSpecialKey%index% := false
        Gui, Add, CheckBox, x+5 vIsSpecialKey%index% gSpecialKeyChange, % "Special Bind"
    
        SetTimer, blameCulpritHotkey, Delete ; the operation of retrieving the activation key was successful
    }
    return
}

blameCulpritHotkey() {
    global hotkeys, global hotkeyIndexNow
    myErrorMsg := "Error while reading hotkeys on app launch. "
        . "The culprit hotkey is " hotkeys[hotkeyIndexNow] " (button number " hotkeyIndexNow ").`n`n"
        . "Attempt one of the following:`n`n"
        . "Open " A_ScriptDir "\hotkeys.ini and "
        . "delete the text to the right of ''" hotkeyIndexNow "=''`n"
        . "There's no need to change anything else.`n`n"
        . "The other solution is to "
        . "rename the file the file hotkeys.ini, or moving it away, or deleting it. " 
        . "All controls will be reset to their factory values but "
        . "this will let you edit the controls normally again."
    OutputDebug, % myErrorMsg "`n"
    MsgBox, % myErrorMsg
}