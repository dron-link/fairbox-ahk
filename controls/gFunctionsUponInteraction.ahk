#Requires AutoHotkey v1.1

initializeTray() {
    Menu, Tray, Click, 1
    Menu, Tray, Add, % "Edit Controls", showControlsGui
    Menu, Tray, Default, % "Edit Controls"
    return
}

showControlsGui() { ;Show GUI from tray Icon
    Gui, show,, % "Controls Editor"
    ; prevents immediately waiting for input on the 1st input box (HK1) when showing gui
    GuiControl, Focus, gameBtName1
    return
}

activationKeyCheck() {
    global
    Critical, On
    ; A_GuiControl is the name of the variable with the content of the hotkey control that is in focus

    num := SubStr(A_GuiControl, 3) ;Get the index of the hotkey control. example: "HK20" -> 20 is Start

    ;If the hotkey contains only modifiers, clear the key.
    If %A_GuiControl% in +,^,!,+^,+!,^!,+^!
        GuiControl,,%A_GuiControl%, % "" 
    ;vkE8 (MenuMaskKey value) means we send a masked key to the operative system.
    else if InStr(%A_GuiControl%, "vkE8") {
        ;Reshow the existing hotkey in the hotkey control. Mask key cannot be intentional from the user
        GuiControl,,%A_GuiControl%, % getHotkeyControlFormat(HK%num%) 
    } 
    else if (InStr(%A_GuiControl%, "#")) {
        ; extraneous case, this should not happen
        OutputDebug,% "activationKeyCheck(): win modifier was found!`n"
                    . "activationKeyCheck(): extraneous case, this should never need to happen`n"
                    . "activationKeyCheck(): keep in mind that win modifiers render a key`n"
                    . "activationKeyCheck(): unable to show in a Hotkey control.`n"
        ; overwrites the control content with existing hotkey without Win modifier
        GuiControl,,%A_GuiControl%, % getHotkeyControlFormat(HK%num%) 
        ; fix hotkey if it was a Win-modifier-using hotkey 
        validateHK(num)
    }
    else {
        validateHK(num)
    }
    Critical, Off
    return
}

defaultBehaviorChange() {
    Critical, On
    num := SubStr(A_GuiControl, 16)
    ;  If hotkey exists, and the user doesn't want to prevent functionality,
    validateHK(num)
    Critical, Off
    return
}

specialKeyChange() {
    global
    Gui, Submit, NoHide
    return
}

