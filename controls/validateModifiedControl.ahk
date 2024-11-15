#Requires AutoHotkey v1.1

validateModifiedControl(num) { ; you came from activationKeyCheck() or #If Expression hotkeys
    global

    If !hotkeys[num] {
        collapseControlModificationMsg := "
( Join`s
validateModifiedControl(num) corruption prevention.
`n
`nThe num value encountered is: " num "
`n
`nError: This num value doesn't identify a hotkey.
`nApp will exit. (Please report this error to the fairbox developers.)
)"
        Gui, +OwnDialogs
        MsgBox, % collapseControlModificationMsg
        ExitApp
    }

    ; saves every control contents to their respective variables. we need control content stored in HK%num%
    Gui, controlsWindow:Submit, NoHide 

    HK%num% := getHotkeyControlFormat(HK%num%) ; strip of ~ and # modifiers

    HK%num% := strReplace(HK%num%, "SC15D", "AppsKey")      ; Use friendlier names,
    HK%num% := strReplace(HK%num%, "SC154", "PrintScreen")  ; instead of these scan codes.
    
    /*  Keep in mind that the ~ modifier is never included in the retrieved hotkey control content.
        So, we need to add it before setting the hotkey, if the user wants to.
    */
    if !preventBehavior%num% {
        HK%num% := "~" HK%num% ;    add the (~) modifier. This prevents a key from being blocked.
    }

    checkDuplicateHK(num)

    IniWrite, % HK%num%, hotkeys.ini, Hotkeys, % num
    savedHK%num% := HK%num%
    
    ; update hotkey control contents for the user to see
    GuiControl, controlsWindow:, HK%num%, % getHotkeyControlFormat(HK%num%)
    return
}

checkDuplicateHK(num) {
    global
    searchHK := strReplace(HK%num%, "~")
    if (searchHK != "") { ; if there's a hotkey
        Loop,% hotkeys.Length() {
            ; if hotkey is case-insensitive equal to a saved hotkey then it can be a duplicate
            If (searchHK = strReplace(savedHK%A_Index%, "~", "")) { 
                If (num == A_Index) { ; if the apparent "duplicated control" is actually itself
                    continue
                }
                
                StringUpper, printDuplicateKey, searchHK, T ; HK%num% Title Case string for pretty message
    
                GuiControl, controlsWindow:, HK%num% ; clear the control.
                Gui, controlsWindow:Submit, NoHide ; clear HK%num%
    
                duplIndex := A_Index ; store index. we can't rely on A_Index because of the next inner loop
                Gui, +OwnDialogs
                MsgBox,, % "Controls Editor: Can't assign duplicate key", % "" 
                . "Key ''" printDuplicateKey "'' already taken by ''" hotkeys[duplIndex]" button.''" 
    
                /*  known Issue:
                    Keys Tab, Enter, Space and Backspace, do not flash. 
                    probably all keys that normally can perform tasks in windows GUI, do not flash.
                */            
                ;Flash the original hotkey to alert the user.
                guiFontDefault("controlsWindow")
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
                break ; a single found key duplicate is enough (also there should be only one)
            }
        }
    }
    return
}
/* ; legacy

setHotkeyFromGui(num, existingHotkey, guiHotkey) {
    global
    If enabledHotkeys {
        ;If previous hotkey exists,
        If (strReplace(existingHotkey, "~") != "") { ; note that this relies on Hotkey "~" not existing
            Hotkey, % existingHotkey, Label%num%, Off ;  disable it.
            Hotkey, % existingHotkey " UP", Label%num%_UP, Off ;  disable it.
        }
        If (strReplace(guiHotkey, "~") != ""){ ;If new hotkey exists,
            if (hotkeys[num] = "Input On/Off") {
                Hotkey, If ; hotkey always active
            } 
            else {
                Hotkey, If, enabledGameControls ; conditional hotkey
            }
            Hotkey, % guiHotkey, Label%num%, On             ; enable hotkey.
            Hotkey, % guiHotkey " UP", Label%num%_UP, On
        }
    }
    return
}

*/
