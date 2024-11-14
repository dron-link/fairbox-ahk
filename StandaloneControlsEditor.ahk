#Requires AutoHotkey v1.1.37.02
#Warn All, OutputDebug
#SingleInstance force
#NoEnv
#MenuMaskKey vke8

#include %A_ScriptDir%\controls
#include, addControlsWindowInstructions.ahk
#include, constructControlsWindow.ahk
#include, goToFunctionsUponGuiInteraction.ahk
#include, hotkeyControlHasFocus.ahk
#include, hotkeyHelpers.ahk
#include, loadHotkeysIni.ahk
#include, validateModifiedControl.ahk

#include %A_ScriptDir%\menu
#include, menu.ahk

#include %A_ScriptDir%\system
#include, fairboxConstants.ahk ; globals

guiFontDefault(windowName) { ; next Gui,Add or GuiControl,Font commands will have this font in their text when called
    Gui, % windowName ":Font", s8 cDefault norm, Tahoma
    return
}

guiFontContent(windowName) { ; next Gui,Add or GuiControl,Font commands will have this font in their text when called
    Gui, % windowName ":Font", s10 cDefault norm, Arial
    return
}

deleteFailingHotkey := true

enabledHotkeys := false
enabledGameControls := false

constructTrayMenu() ; puts the custom menu items in the tray

for i in hotkeys {
    ; ### for hotkey activation keys, and gui hotkey controls. create the global variables associated to:
    ; button name,       hotkey control,  the real hotkey,    special bind checkbox, Prev.Def.B. checkbox
    gameBtName%i% := "", HK%i% := "",     savedHK%i% := "",   isSpecialKey%i% := "", preventBehavior%i% := ""
}

loadHotkeysIni()

constructControlsWindow()

showControlsWindow()

return ; end of autoexecute section

; /////////////////////// hotkeys, and the functions and subroutines that handle hotkeys

ControlsWindowGuiClose:
ExitApp

/*  FYI:
    when a hotkey control has the checkbox Special Bind, these hotkeys take priority over the
    others below, just because they appear earlier in the script.

    currentControlVarNameSp := HotkeyCtrlHasFocusIsSpecial() doubles as an assignment and a expression
    that is interpreted as false if and only if HotkeyCtrlHasFocusIsSpecial() evaluates to 0 or "".
    And each time one of the following keys is pressed, HotkeyCtrlHasFocusIsSpecial() gets newly evaluated.
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
        hotkeyNum := SubStr(currentControlVarNameSp, 3)
        If (A_ThisHotkey = "LControl & RAlt") {
            GuiControl, controlsWindow:, HK%hotkeyNum%, % "^RAlt" ; make the control display altgr activation key.
        }
        else {
            GuiControl,controlsWindow:, HK%hotkeyNum%, % A_ThisHotkey ;  make the control display the hotkey.
        }

        validateModifiedControl(hotkeyNum)
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
    *BackSpace:: ; BackSpace has two usages.
        Critical
        if hotkeyCtrlHasFocusIsSpecial() {
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
            hotkeyNum := SubStr(currentControlVarName, 3)
            validateModifiedControl(hotkeyNum)
        } else {
            GuiControl, controlsWindow:, %currentControlVarName% ; clear the control content
            ;Get the index of the hotkey control. example: "HK20" -> 20 is Start
            hotkeyNum := SubStr(currentControlVarName, 3)
            validateModifiedControl(hotkeyNum)
        }
        Critical Off
    return
#If ; end of conditional hotkeys

#If enabledGameControls ; because an existing directive was needed to use Hotkey, If, enabledGameControls

/*  stuffs: there is a graphical glitch
    click on a control
    hold alt
    press backspace
    lift alt

    The display shows ALT+

    is there a way to fix this
*/
