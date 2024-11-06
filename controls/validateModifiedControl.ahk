#Requires AutoHotkey v1.1

validateModifiedControl(num) { ; you came from activationKeyCheck() or #If Expression hotkeys
    global

    If !hotkeys[num] {
        MsgBox, % "validateModifiedControl corruption prevention . num: (" num ")`n"
        ExitApp
    }

    ; saves every control contents to their respective variables. we need control content stored in HK%num%
    Gui, controlsWindow:Submit, NoHide 

    HK%num% := strReplace(HK%num%, "SC15D", "AppsKey")      ; Use friendlier names,
    HK%num% := strReplace(HK%num%, "SC154", "PrintScreen")  ; instead of these scan codes.
    
    checkDuplicateHK(num)
    /*  Keep in mind that the ~ modifier is never included in the retrieved control content.
        So, if the user doesn't want to prevent functionality,
    */
    if !preventBehavior%num% {
        HK%num% := "~" HK%num% ;    add the (~) modifier. This prevents a key from being blocked.
    }

    setHotkeyFromGui(num, savedHK%num%, HK%num%)
    IniWrite, % HK%num%, hotkeys.ini, Hotkeys, % num
    savedHK%num% := HK%num%
    
    ; display the new hotkey in the window
    GuiControl, controlsWindow:, HK%num%, % getHotkeyControlFormat(HK%num%)
    return
}

checkDuplicateHK(num) {
    global

    Loop,% hotkeys.Length() {
        ; if hotkey is non-empty and is case-insensitive equal to a saved hotkey, then it can be a duplicate
        If (HK%num% != "" and HK%num% = strReplace(savedHK%A_Index%, "~", "")) { 
            If (num == A_Index) { ; the "duplicated control" is actually itself
                continue
            }
            
            StringUpper, printDuplicateKey, HK%num%, T ; HK%num% Title Case string for pretty message

            GuiControl, controlsWindow:, HK%num% ; clear the control.
            Gui, controlsWindow:Submit, NoHide ; clear HK%num%

            duplIndex := A_Index ; store index. we can't rely on A_Index because of the next inner loop
            MsgBox, % "Key ''" printDuplicateKey "'' already taken by ''" hotkeys[duplIndex]" button.''" 

            /*  known Issue:
                Keys Tab, Enter, Space and Backspace, do not flash. 
                probably all keys that normally can perform tasks in windows GUI, do not flash.
            */            
            ;Flash the original hotkey to alert the user.
            Loop,3 {
                Gui, controlsWindow:Font, bold underline
                GuiControl, controlsWindow:Font, HK%duplIndex% 
                Gui, controlsWindow:Font, norm underline cRed
                GuiControl, controlsWindow:Font, gameBtName%duplIndex%
                Sleep,130
                guiFontDefault("controlsWindow")
                GuiControl, controlsWindow:Font, HK%duplIndex%
                GuiControl, controlsWindow:Font, gameBtName%duplIndex%
                Sleep,130
            }
            break
        }
    }
    return
}

setHotkeyFromGui(num, existingHotkey, guiHotkey) {
    global
    If enabledHotkeys {
        If (existingHotkey != "") { ;If previous hotkey exists,
            Hotkey, %existingHotkey%, Label%num%, Off ;  disable it.
            Hotkey, %existingHotkey% UP, Label%num%_UP, Off ;  disable it.
        }
        If (strReplace(guiHotkey, "~") != ""){ ;If new hotkey exists,
            Hotkey, %guiHotkey%, Label%num%, On ;  enable it.
            Hotkey, %guiHotkey% UP, Label%num%_UP, On ;  enable it.
        }
    }
    return
}