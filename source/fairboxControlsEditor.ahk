#Requires AutoHotkey v1
#SingleInstance force
#NoEnv
#MenuMaskKey vke8

SetWorkingDir, %A_ScriptDir%

#include %A_LineFile%\..\controls\controlsEditorWindow\controlsEditorWindow.ahk

#include %A_LineFile%\..\controls
#include, loadHotkeysIni.ahk

#include %A_LineFile%\..\menu
#include, controlsEditorTrayMenu.ahk

#include %A_LineFile%\..\system
#include, guiFont.ahk
#include, hotkeys.ahk ; globals

; close fairbox
DetectHiddenWindows, On
        ;    0x111 = WN_COMMAND code
        ;           65307 = exit code
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairbox.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairbox.exe
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxDebug.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxDebug.exe
DetectHiddenWindows, Off

FileInstall, install\config.ini, % A_ScriptDir "\config.ini", 0 ; for when config.ini doesn't exist

; MainIntoControlsWindow is designed to only be true in volatile memory
IniRead, openedFromMain, config.ini, LaunchMode, MainIntoControlsWindow
IniWrite, % false      , config.ini, LaunchMode, MainIntoControlsWindow

deleteFailingHotkey := true

enabledHotkeys := false
enabledGameControls := false

constructControlsEditorTrayMenu() ; puts the custom menu items in the tray

loadHotkeysIni()

constructControlsWindow()

showControlsWindow()

return ; end of autoexecute section

; /////////////////////// hotkeys, and the functions and subroutines that handle hotkeys

ControlsWindowGuiClose:
    If openedFromMain {
        gosub LabelOpenMain
    } else {
        ExitApp
    }
return

LabelOpenMain:
    IniWrite, % True, config.ini, LaunchMode, ControlsWindowIntoMain
    IniWrite, % openedFromMain, config.ini, LaunchMode, MainIntoControlsWindow
    Run, fairbox.ahk, % A_ScriptDir, UseErrorLevel
    if (ErrorLevel = "ERROR") {
        Run, fairbox.exe, % A_ScriptDir, UseErrorLevel
        if (ErrorLevel = "ERROR") {
            MsgBox, % "Couldn't open fairbox. Path: " A_ScriptDir "\fairbox.*"
        }
    }
    ; if fairbox runs, it will close this script now.
return

LabelRefreshControlsWindow:
    ; we save this so we don't forget to go back to main automatically
    IniWrite, % openedFromMain, config.ini, LaunchMode, MainIntoControlsWindow 
    Reload
return

/*  FYI:
    when a hotkey control has the checkbox Special Bind, these hotkeys take priority over the
    others below, just because I put them earlier in the script.

    currentControlVarNameSp := HotkeyCtrlHasFocusIsSpecial() doubles as an assignment and a expression
    that is interpreted as false if and only if HotkeyCtrlHasFocusIsSpecial() evaluates to 0 or "".
    And each time one of the following keys is pressed, HotkeyCtrlHasFocusIsSpecial() is newly evaluated.
*/

#If currentControlVarNameSp := HotkeyCtrlHasFocusIsSpecial()
    LControl & RAlt:: ; AltGr
    LControl::
    RControl::
    LShift::
    RShift::
    LAlt::
    RAlt::
    LWin::
    RWin::
    +::
        Critical
        Gui, controlsWindow:Submit, NoHide
        ;Get the index of the hotkey control. example: "HK20" -> 20 is Start
        hotkeySpecialNum := SubStr(currentControlVarNameSp, 3)
        If (A_ThisHotkey = "LControl & RAlt") {
            ; make the control display the altgr activation key.
            GuiControl, controlsWindow:, HK%hotkeySpecialNum%, % "^RAlt" 
        }
        else {
            ;  make the control display the hotkey.
            GuiControl,controlsWindow:, HK%hotkeySpecialNum%, % A_ThisHotkey 
        }

        validateModifiedControl(hotkeySpecialNum)
        Critical Off
    return
#If ; end of conditional hotkeys

/*  FYI: currentControlVarNameSp := HotkeyCtrlHasFocus() doubles as an assignment and a expression
    that is interpreted as false if and only if HotkeyCtrlHasFocus() evaluates to 0 or "".
    And each time one of the following keys is pressed, HotkeyCtrlHasFocus() gets newly evaluated.
*/
#If currentControlVarName := HotkeyCtrlHasFocus()
    *AppsKey::      ; Add support for these keys,
    *Delete::       ; which the hotkey control does not normally allow.
    *Enter::
    *Escape::
    *Pause::
    *PrintScreen::
    *Space::
    *Tab::
        Critical
        modifier := ""
        If GetKeyState("Shift","P")
            modifier .= "+"
        If GetKeyState("Ctrl","P")
            modifier .= "^"
        If GetKeyState("Alt","P")
            modifier .= "!"
        ; overwrite the control content
        GuiControl, controlsWindow:, %currentControlVarName%, % modifier SubStr(A_ThisHotkey,2) ; omit the *
        ; overwrite the control content
        hotkeyNum := SubStr(currentControlVarName, 3)
        validateModifiedControl(hotkeyNum)
        Critical Off
    return
    *BackSpace:: ; BackSpace has two roles.
        Critical
        if hotkeyCtrlHasFocusIsSpecial() { ; bind
            modifier := ""
            If GetKeyState("Shift","P")
                modifier .= "+"
            If GetKeyState("Ctrl","P")
                modifier .= "^"
            If GetKeyState("Alt","P")
                modifier .= "!"
            ; overwrite the control content
            GuiControl, controlsWindow:, %currentControlVarName%, % modifier "BackSpace"
            ;Get the index of the hotkey control. example: "HK20" -> 20 is Start
            hotkeySpecialNum := SubStr(currentControlVarName, 3)
            validateModifiedControl(hotkeySpecialNum)
        }
        else { ; clear
            GuiControl, controlsWindow:, %currentControlVarName% ; clear the control content
            ;Get the index of the hotkey control. example: "HK20" -> 20 is Start
            hotkeyNum := SubStr(currentControlVarName, 3)
            validateModifiedControl(hotkeyNum)
        }
        Critical Off
    return
#If ; end of conditional hotkeys

/*  stuffs: there is a graphical glitch aand you can replicate it by:
    click on a control
    hold alt
    press backspace
    lift alt

    The display shows ALT+

    is there a way to fix this?
*/
