#Requires AutoHotkey v1.1

constructControlsWindow() { ; adopt saved hotkeys and initialize Edit Controls menu
    global
    ; width of the hotkey control boxes of the Edit Controls Window
    IniRead, descriptionWidth, config.ini, UserSettings, ControlsEditorKeyDisplayWidth
    ; determine upper left position of first row of gui elements
    yOff := 3
    Loop, % hotkeysList.Length() {
        if (hotkeysList[A_Index] = "") { ; We skip empty hotkey IDs if there are any
            Continue
        }
        ; determine upper left position of each set of gui elements
        if (hotkeysList[A_Index] = "legacyDebugKey") {
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
        If (strReplace(savedHK%A_Index%, "~", "") = "") { ; hotkey doesn't exist
            preventBehavior%A_Index% := false ; empty slots will display as unmarked
        } 
        else if InStr(savedHK%A_Index%, "~") { ; hotkey is ~[modifiers+key]
            preventBehavior%A_Index% := false 
        } else { ; hotkey is [modifiers+key]
            preventBehavior%A_Index% := true 
        }
        
        GuiFontDefault("controlsWindow")
        ; adds borderless text of the control name and associates it to variable gameBtName1, and so on
        Gui, controlsWindow:Add, Text, xm ym+%yOff% vGameBtName%A_Index%, % hotkeysDisplay[A_Index] ":" 
        ;Add controls and show the saved key
        HK%A_Index% := savedHK%A_Index% ; each control is associated to their respective HK variable
        Gui, controlsWindow:Add, Hotkey, xm+107 yp-3 w%descriptionWidth% vHK%A_Index% gActivationKeyCheck, % getHotkeyControlFormat(savedHK%A_Index%)
        ; add Prevent Default Behavior checkbox
        ifPrevent := preventBehavior%A_Index%
        Gui, controlsWindow:Add, CheckBox, x+5 yp+3 vPreventBehavior%A_Index% Checked%ifPrevent% gDefaultBehaviorChange, % "Prevent Default Behavior"
        ; add Special Bind checkbox
        isSpecialKey%A_Index% := false
        Gui, controlsWindow:Add, CheckBox, x+5 vIsSpecialKey%A_Index% gSpecialKeyChange, % "Special Bind"   
        
        ; determine upper left position of next row of gui elements
        yOff += 22
    }
    addControlsWindowInstructions(descriptionWidth)

    guiFontDefault("controlsWindow")
    Gui, controlsWindow:Add, Button, y+30 w70 h40 gLabelRefreshControlsWindow, % "Refresh"
    Gui, controlsWindow:Add, Button, x+6 w70 h40 gLabelOpenMain, % "Play"

    return
}

