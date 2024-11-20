#Requires AutoHotkey v1.1.37.02
#Warn All, OutputDebug
#SingleInstance force
#NoEnv
#MenuMaskKey vke8

#include %A_ScriptDir%\controls\controlsEditorWindow
#include, addControlsWindowInstructions.ahk
#include, constructControlsWindow.ahk
#include, goToFunctionsUponGuiInteraction.ahk
#include, hotkeyControlHasFocus.ahk
#include, hotkeyHelpers.ahk
#include, showControlsWindow.ahk
#include, validateModifiedControl.ahk

#include %A_ScriptDir%\controls
#include, loadHotkeysIni.ahk

#include %A_ScriptDir%\menu
#include, controlsEditorTrayMenu.ahk

#include %A_ScriptDir%\system
#include, guiFont.ahk
#include, hotkeys.ahk ; globals

; close fairbox
DetectHiddenWindows, On
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairbox.ahk ; 0x111 = WN_COMMAND code, 65307 = exit code
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairbox.exe
DetectHiddenWindows, Off

FileInstall, install\config.ini, % A_ScriptDir "\config.ini", 0 ; for when config.ini doesn't exist

; MainIntoControlsWindow is designed to only be true in volatile memory
IniRead, openedFromMain, config.ini, LaunchMode, MainIntoControlsWindow
IniWrite, % false      , config.ini, LaunchMode, MainIntoControlsWindow

manualGoToMain := false ; enabled if the user clicks a certain option from the tray

deleteFailingHotkey := true

enabledHotkeys := false
enabledGameControls := false

constructControlsEditorTrayMenu() ; puts the custom menu items in the tray

for i in hotkeys {
    ; create the global variables associated to:
    ; button name,       saved hotkey,     special bind checkbox, Prev. Default B. checkbox
    gameBtName%i% := "", savedHK%i% := "", isSpecialKey%i% := "", preventBehavior%i% := ""
}

loadHotkeysIni()

for i in hotkeys {
    ; create the global variables associated to:
    ; GUI hotkey control
    HK%i% := savedHK%i%
}

constructControlsWindow()

showControlsWindow() 

return ; end of autoexecute section

; /////////////////////// hotkeys, and the functions and subroutines that handle hotkeys

ControlsWindowGuiClose:
    If (openedFromMain or manualGoToMain) {
        manualGoToMain := false ; false until the user clicks "Resume playing" once more
        IniWrite, % True, config.ini, LaunchMode, ControlsWindowIntoMain
        Run, fairbox.ahk, % A_ScriptDir, UseErrorLevel
        if (ErrorLevel = "ERROR") {
            Run, fairbox.exe, % A_ScriptDir, UseErrorLevel
            if (ErrorLevel = "ERROR") {
                MsgBox, % "Couldn't open fairbox. " A_ScriptDir "\fairbox.*"
            }
        }
        ; if fairbox launches, it will close this script here.
    } else {
        ExitApp
    }
return

LabelManualGoToMainFairbox:
    manualGoToMain := true
    if !openedFromMain {
        /*  since we are launching fairbox anew, controls enabled should be the default.
            but fairbox will attempt to recall if controls were enabled using the ini.
            We need to ensure controls will be enabled
        */
        IniWrite, % true, config.ini, LaunchMode, EnabledControlsRecall
    }
    Gosub ControlsWindowGuiClose
return

LabelRefreshControlsWindow:
    IniWrite, % openedFromMain, config.ini, LaunchMode, ControlsWindowIntoMain
    Reload
return

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

/*  stuffs: there is a graphical glitch
    click on a control
    hold alt
    press backspace
    lift alt

    The display shows ALT+

    is there a way to fix this
*/
