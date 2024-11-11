#Requires AutoHotkey v1.1

constructControlsWindow() { ; adopt saved hotkeys and initialize Edit Controls menu
    global
    descriptionWidth := 115 ; width of the hotkey control boxes of the Edit Controls Window
    
    for index, element in hotkeys {
        ; determine upper left position of each set of gui elements
        if (index == 1) {
            yOff := 3
        } else {
            yOff += 22
        }
        if (hotkeys[index] == "Debug") {
            yOff += 22 ; additional spacing
        }
    
        /*  sets the value of the variable associated with the Prevent Default Behavior checkbox.
            The value is retrieved every time we assign a new hotkey:
            IF the checkbox is unmarked, we put "~" before the string that represents the key combination
            retrieved from the hotkey control.
            The ~ means that the user wants the key or key combination to preserve all its functionality.
            If the hotkey lacks it, the key or key combination will only work as a controller input; 
            the key won't work outside of triggering its respective label subroutine
        */
        If (strReplace(savedHK%index%, "~", "") = "") { ; hotkey doesn't exist
            preventBehavior%index% := false ; empty slots will display as unmarked
        } 
        else if InStr(savedHK%index%, "~") { ; hotkey is ~[modifiers+key]
            preventBehavior%index% := false 
        } else { ; hotkey is [modifiers+key]
            preventBehavior%index% := true 
        }
        
        GuiFontDefault("controlsWindow")
        ; adds borderless text of the control name and associates it to variable gameBtName1, and so on
        Gui, controlsWindow:Add, Text, xm ym+%yOff% vGameBtName%index%, % element 
        . (hotkeys[index] = "Input On/Off" ? ":" : " button:")
        ;Add controls and show the saved key
        Gui, controlsWindow:Add, Hotkey, xm+107 yp-3 w%descriptionWidth% vHK%index% gActivationKeyCheck, % getHotkeyControlFormat(savedHK%index%)
        ; add Prevent Default Behavior checkbox
        ifPrevent := preventBehavior%index%
        Gui, controlsWindow:Add, CheckBox, x+5 yp+3 vPreventBehavior%index% Checked%ifPrevent% gDefaultBehaviorChange, % "Prevent Default Behavior"
        ; add Special Bind checkbox
        isSpecialKey%index% := false
        Gui, controlsWindow:Add, CheckBox, x+5 vIsSpecialKey%index% gSpecialKeyChange, % "Special Bind"    
    }
    addControlsWindowInstructions(descriptionWidth)

    return
}

