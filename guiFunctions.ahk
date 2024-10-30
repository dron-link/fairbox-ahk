#Requires AutoHotkey v1.1

initializeTray() {
    objShowTheGui := Func("ShowGui")
    Menu, Tray, Click, 1
    Menu, Tray, Add, % "Edit Controls", % objShowTheGui
    Menu, Tray, Default, % "Edit Controls"
    return
}

ShowGui() { ;Show GUI from tray Icon
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
    result := StrReplace(activationKey, "#", "")
    result := StrReplace(result, "~", "")
    return result
}

activationKeyCheck() {
    global lastHK, global currentControlVarName
    currentControlVarName := HotkeyCtrlHasFocus()

    ; A_GuiControl is the name of the variable with the content of the hotkey control that is in focus

    ;Retrieve the index of the hotkey
    num := SubStr(A_GuiControl, 3)

    ;If the hotkey contains only modifiers, return to wait for a key.
    If %A_GuiControl% in +,^,!,+^,+!,^!,+^!
        return
    ;vkE8 (MenuMaskKey value) means the key is masked to the operative system.
    If InStr(%A_GuiControl%, "vkE8") {
        GuiControl,,%A_GuiControl%, % lastHK ;Reshow the hotkey, because MenuMaskKey clears it.
    } else {
        validateHK(A_GuiControl)
    }
    return
}

checkBoxChange() {
    num := SubStr(A_GuiControl, 16)
    ;  If hotkey exists, and the user doesn't want to prevent functionality,
    If (!preventBehavior%num% and strReplace(HK%num%, "~", ""))
        HK%num% := "~" HK%num% ;    add the (~) modifier. This prevents any key from being blocked.
    Else if (preventBehavior%num%) {
        HK%num% := strReplace(HK%num%, "~", "")
    }
    If (strReplace(savedHK%num%, "~", "") or strReplace(HK%num%, "~", "")) { ;Unless both are empty,
        setHK(num, savedHK%num%, HK%num%) ;  update INI/GUI
        savedHK%num% := HK%num%
    }
}

validateHK(controlVarName) { ; you came from activationKeyCheck() or #If Expression hotkeys
    global
    Gui, Submit, NoHide ; saves control contents to their respective variables

    num := SubStr(controlVarName, 3) ;Get the index of the hotkey control. example: "HK20" -> 20 is Start
    lastHK := savedHK%num% ;Backup the hotkey, in case it needs to be reshown.
    If (HK%num% != "") { ;If the hotkey is not blank...
        HK%num% := strReplace(HK%num%, "SC15D", "AppsKey")      ; Use friendlier names,
        HK%num% := strReplace(HK%num%, "SC154", "PrintScreen")  ; instead of these scan codes.
        ;  If the new hotkey is not (# ! ^ +), and the user doesn't want to prevent functionality,
        If (!preventBehavior%num% and !RegExMatch(HK%num%,"[#!\^\+]"))
            HK%num% := "~" HK%num% ;    add the (~) modifier. This prevents any key from being blocked.
        checkDuplicateHK(num)
    }

    If (strReplace(savedHK%num%, "~", "") or strReplace(HK%num%, "~", "")) ;Unless both are empty,
        setHK(num, savedHK%num%, HK%num%) ;  update INI/GUI
    savedHK%num% := HK%num%
}

checkDuplicateHK(num) {
    global
    tryHK := strReplace(HK%num%, "~", "")
    Loop,% hotkeys.Length() {
        If (tryHK = strReplace(savedHK%A_Index%, "~", "")) { ; case-insensitive compare activation keys
            duplIndex := A_Index
            TrayTip, % "Rectangle Controller Script:", % "Hotkey Already Taken", 2, 0
            Loop,3 {
                Gui, Font, cRed bold
                GuiControl, Font, HK%duplIndex% ;Flash the original hotkey to alert the user.
                Sleep,200
                Gui, Font, cDefault norm
                GuiControl, Font, HK%duplIndex% ;Flash the original hotkey to alert the user.
                Sleep,200
            }
            GuiControl,% "Disable" false, HK%duplIndex%
            GuiControl,,HK%num%,% HK%num% :="" ;Delete the hotkey and clear the control.
            break
        }
    }
    return
}

setHK(num,INI,GUI) {
    global takeoverForTest
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

    IniWrite,% GUI ? GUI : "~", hotkeys.ini, Hotkeys, %num%
    return
}

blameCulpritHotkey() {
    global hotkeys, global hotkeyIndexNow
    myErrorMsg := "Error while reading hotkeys on startup. "
        . "The culprit hotkey is " hotkeys[hotkeyIndexNow] " (button number " hotkeyIndexNow ")"
    OutputDebug, % myErrorMsg "`n"
    MsgBox, % myErrorMsg
}

HotkeyCtrlHasFocus() {
    ;Retrieves the control ID (ClassNN) for the control that currently has focus
    GuiControlGet, vCurrentControlID, Focus

    If (InStr(vCurrentControlID, "hotkey")) {
        GuiControlGet, vCurrentControlAssociatedVarName, FocusV
        Return vCurrentControlAssociatedVarName
    }
    Return
}

/*
replaceLastSpecialCharacter(activationKey) {
    lastChar := SubStr(activationKey, 0)
    if (lastChar = "^") {
        GuiControl,, activationKey, SubStr(activationKey, 1, -1) . "Control"
    } else if (lastChar = "!") {
        GuiControl,, activationKey, SubStr(activationKey, 1, -1) . "Alt"
    } else if (lastChar = "+") {
        GuiControl,, activationKey, SubStr(activationKey, 1, -1) . "Shift"
    } else if (lastChar = "#") {
        GuiControl,, activationKey, SubStr(activationKey, 1, -1) . "Win"
    }
    return
}

replaceCompanionCharIfSpecial(activationKey) {
    if (strLen(activationKey) > 1) {
        companionChar := SubStr(activationKey, -1, 1)
        if (companionChar = "<") {
            GuiControl,, activationKey, SubStr(activationKey, 1, -2) . "L" . SubStr(activationKey, 0)
        } else if (companionChar = ">") {
            GuiControl,, activationKey, SubStr(activationKey, 1, -2) . "R" . SubStr(activationKey, 0)
        }
    }
    return
}

*/