#Requires AutoHotkey v1.1

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

            duplIndex := A_Index
            
            StringUpper, printDuplicateKey, HK%num%, T ; HK%num% Title Case string
            MsgBox, % "Key ''" printDuplicateKey "'' already taken by ''" hotkeys[duplIndex]" button.''" 

            GuiControl,,HK%num% ; clear the control.
            Gui, Submit, NoHide ; clear HK%num%
            /*  known Issue:
                Keys Tab, Enter, Space and Backspace, do not flash. 
                probably all keys that otherwise perform operations in windows GUI, do not flash.
            */
            
            Loop,3 {
                Gui, Font, w1000 underline
                GuiControl, Font, HK%duplIndex% ;Flash the original hotkey to alert the user.
                Gui, Font, norm cRed
                GuiControl, Font, gameBtName%duplIndex%
                Sleep,130
                guiFontDefault()
                GuiControl, Font, HK%duplIndex% ;Flash the original hotkey to alert the user.
                GuiControl, Font, gameBtName%duplIndex%
                Sleep,130
            }
            break
        }
    }
    return
}

setHK(num,INI,GUI) {
    global
    If enabledHotkeys {
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