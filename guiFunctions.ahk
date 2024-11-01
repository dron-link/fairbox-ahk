#Requires AutoHotkey v1.1

initializeTray() {
    objShowTheGui := Func("showGui")
    Menu, Tray, Click, 1
    Menu, Tray, Add, % "Edit Controls", % objShowTheGui
    Menu, Tray, Default, % "Edit Controls"
    return
}

showGui() { ;Show GUI from tray Icon
    Gui, show,, % "Dynamic Hotkeys"
    ; prevents immediately waiting for input on the 1st input box (HK1) when showing gui
    GuiControl, Focus, gameBtName1
    return
}

getHotkeyControlFormat(activationKey) {
    /*  Remove tilde (~) and Win (#) modifiers...
        They are incompatible with hotkey controls (cannot be shown in hotkey control boxes).
        The only modifiers supported are  ^ (Control), ! (Alt), and + (Shift).
    */
    result := StrReplace(activationKey, "#", ""), result := StrReplace(result, "~", "")
    return result
}

getStrippedFromModifiers(stringIn) {
    /*  strips a hotkey control's content of all modifiers. 
    useful to see if there's anything in it other than modifiers
    */
    modStrippedHK := strReplace(stringIn, "!"), modStrippedHK := strReplace(modStrippedHK, "^")
    modStrippedHK := strReplace(modStrippedHK, "+"), modStrippedHK := strReplace(modStrippedHK, "<")
    modStrippedHK := strReplace(modStrippedHK, ">")
    return modStrippedHK
}

activationKeyCheck() {
    global
    Critical, On
    ; A_GuiControl is the name of the variable with the content of the hotkey control that is in focus

    num := SubStr(A_GuiControl, 3) ;Get the index of the hotkey control. example: "HK20" -> 20 is Start

    ;If the hotkey contains only modifiers, return to wait for a key.
    If %A_GuiControl% in +,^,!,+^,+!,^!,+^!
        return
    ;vkE8 (MenuMaskKey value) means we send a masked key to the operative system.
    If InStr(%A_GuiControl%, "vkE8") {
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

validateHK(num) { ; you came from activationKeyCheck() or #If Expression hotkeys
    global
    Gui, Submit, NoHide ; saves every control contents to their respective variables. need Hotkey control -> HK
    If !hotkeys[num] {
        MsgBox, % "validateHK corruption prevention . num: (" num ")`n"
        ExitApp
    }

    HK%num% := strReplace(HK%num%, "SC15D", "AppsKey")      ; Use friendlier names,
    HK%num% := strReplace(HK%num%, "SC154", "PrintScreen")  ; instead of these scan codes.
    
    
    checkDuplicateHK(num)
    ;  If the user doesn't want to prevent functionality,
    if !preventBehavior%num% {
        HK%num% := "~" HK%num% ;    add the (~) modifier. This prevents any key from being blocked.
    }
    setHK(num, savedHK%num%, HK%num%) ;  update INI/GUI
    savedHK%num% := HK%num%
    GuiControl,, HK%num%, % getHotkeyControlFormat(HK%num%)
    return
}

checkDuplicateHK(num) {
    global

    Loop,% hotkeys.Length() {
        If (HK%num% != "" and HK%num% = strReplace(savedHK%A_Index%, "~", "")) { ; if case-insensitive equal
            If (num == A_Index) {
                continue
            }
            If (HK%num% = "Space" or HK%num% = "Backspace" or HK%num% = "Tab") {
                OutputDebug, % "checkDuplicateHK. bet flash control doesn't work`n"
            } else {
                OutputDebug, % "checkDuplicateHK. Flash should work`n"
            }
            duplIndex := A_Index
            StringUpper, printDuplicateKey, HK%num%, T ; HK%num% Title Case string
            TrayTip, % "Rectangle Controller Script:", % "Hotkey Already Taken:  " printDuplicateKey, 2, 0
            GuiControl,,HK%num% ; clear the control.
            Gui, Submit, NoHide ; clear HK%num%
            /*  known Issue:
                Keys Tab, Enter, Space and Backspace, do not flash. 
                probably all keys that otherwise perform operations in windows GUI, do not flash.
            */
            Loop,3 {
                Gui, Font, cRed bold
                GuiControl, Font, HK%duplIndex% ;Flash the original hotkey to alert the user.
                Sleep,200
                Gui, Font, cDefault norm
                GuiControl, Font, HK%duplIndex% ;Flash the original hotkey to alert the user.
                Sleep,200
            }
            break
        }
    }
    return
}

setHK(num,INI,GUI) {
    global
    If !takeoverForTest {
        If strReplace(INI, "~", "") { ;If previous hotkey exists,
            Hotkey, %INI%, Label%num%, Off ;  disable it.
            Hotkey, %INI% UP, Label%num%_UP, Off ;  disable it.
        }
        If strReplace(GUI, "~", ""){ ;If new hotkey exists,
            Hotkey, %GUI%, Label%num%, On ;  enable it.
            Hotkey, %GUI% UP, Label%num%_UP, On ;  enable it.
        }
    }
    OutputDebug, % GUI "`n"
    IniWrite,% GUI ? GUI : "", hotkeys.ini, Hotkeys, % num
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

blameCulpritHotkey() {
    global hotkeys, global hotkeyIndexNow
    myErrorMsg := "Error while reading hotkeys on startup. "
        . "The culprit hotkey is " hotkeys[hotkeyIndexNow] " (button number " hotkeyIndexNow ")"
    OutputDebug, % myErrorMsg "`n"
    MsgBox, % myErrorMsg
}

hotkeyCtrlHasFocus() {
    global
    OutputDebug, % "HotkeyCtrlHasFocus ran " A_TickCount " `n"
    ;Retrieves the control ID (ClassNN) for the control that currently has focus
    GuiControlGet, vCurrentControlID, Focus

    If (InStr(vCurrentControlID, "hotkey")) {
        GuiControlGet, vCurrentControlAssociatedVarName, FocusV
        Return vCurrentControlAssociatedVarName
    }
    Return
}

hotkeyCtrlHasFocusIsSpecial() {
    global
    OutputDebug, % "HotkeyCtrlHasFocusIsSpecial ran " A_TickCount " `n"
    ;Retrieves the control ID (ClassNN) for the control that currently has focus
    GuiControlGet, vCurrentControlID, Focus

    If (InStr(vCurrentControlID, "hotkey")) {
        GuiControlGet, vCurrentControlAssociatedVarName, FocusV
        hotkeyIndex := SubStr(vCurrentControlAssociatedVarName, 3)
        OutputDebug, % "hotkeyIndex " hotkeyIndex " isSpecialKey " isSpecialKey%hotkeyIndex% "`n"
        If isSpecialKey%hotkeyIndex% {
            Return vCurrentControlAssociatedVarName
        }
    }
    Return
}

specialKeyChange() {
    global
    Gui, Submit, NoHide
    return
}