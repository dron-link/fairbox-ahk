#Requires AutoHotkey v1.1

showControlsWindow() {
    global loadHotkeysIniFail
    if !loadHotkeysIniFail {
        Gui, controlsWindow:Show,, % "Controls Editor - fairbox"
        ; prevents immediately waiting for input on the 1st input box (assoc variable HK1) when showing gui
        GuiControl, controlsWindow:Focus, gameBtName1
    } else {
        MsgBox, % "Controls failed to load from the file hotkeys.ini. The Controls Editor can't launch."
    }
    
    return
}

activationKeyCheck() { ; thread launched by controlsWindow GUI / hotkey control box
    global
    Critical, On
    /*  A_GuiControl contains the NAME of the variable that holds the content 
        of the hotkey control that is in focus
    */
    num := SubStr(A_GuiControl, 3) ;Get the index of the hotkey control. example: "HK20" -> 20 is Start

    if (getStrippedFromModifiers(%A_GuiControl%) = "")  { ;If the hotkey contains only modifiers
        ;Reshow the existing hotkey in the hotkey control.
        GuiControl,,%A_GuiControl%, % getHotkeyControlFormat(savedHK%num%)
    }
    /*  finding the MenuMaskKey (vke8) means that Autohotkey wants to prevent
        the OS from interpreting some spurious thing as the press of an important key, such as Windows key.
        Apparently this is the solution to a problem in Autohotkey
    */
    else if InStr(%A_GuiControl%, "vke8") {
        ;Reshow the existing hotkey in the hotkey control. Mask key cannot be intentional from the user
        GuiControl,,%A_GuiControl%, % getHotkeyControlFormat(HK%num%) 
    } 
    else if InStr(%A_GuiControl%, "#") { ; user can't enter hotkeys with the win modifier, but just in case
        ; extraneous case
        OutputDebug,% "activationKeyCheck(): win modifier was found!`n"
                    . "activationKeyCheck(): extraneous case, this should never need to happen`n"
                    . "activationKeyCheck(): keep in mind that win modifiers render a key`n"
                    . "activationKeyCheck(): unable to show in a Hotkey control.`n"
        ; overwrites the control content with existing hotkey without Win modifier
        GuiControl,,%A_GuiControl%, % getHotkeyControlFormat(HK%num%) 
        ; fix hotkey if it was a Win-modifier-using hotkey 
        validateModifiedControl(num)
    }
    else {
        validateModifiedControl(num)
    }
    Critical, Off
    return
}

defaultBehaviorChange() {
    Critical, On
    ;Get the index of the hotkey control.
    num := SubStr(A_GuiControl, 16) ; example:  "preventBehavior20" -> 20 is Start
    
    validateModifiedControl(num)
    Critical, Off
    return
}

specialKeyChange() { ; thread launched by controlsWindow GUI / special bind checkbox
    global
    ; all controls' content including special bind checkboxes are stored in their respective variables
    Gui, Submit, NoHide 
    return
}

