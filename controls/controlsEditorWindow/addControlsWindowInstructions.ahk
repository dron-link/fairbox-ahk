#Requires AutoHotkey v1.1

addControlsWindowInstructions(descriptionWidth) {
    xOff := 380 + descriptionWidth

    guiFontContent("controlsWindow")
    Gui, controlsWindow:Add, Text, xm+%xOff% ym, % "Instructions:"

    addControlsWindowInstructionsParagraph(xOff, "
( Join`s
Click on the control you want to edit and press the key you want to map to it.
)")
    addControlsWindowInstructionsParagraph(xOff, "
( Join`s
To clear a control, click on it and press Back. If you try to bind a key that already was bound,
the program won't let you do it, and it will alert you of the control you need to make a change to.
)")
    addControlsWindowInstructionsParagraph(xOff, "
( Join`s
''Prevent Default Behavior'' eliminates any side effect of pressing a key or key combination.
Use it ONLY when you play using keys that can mess up your gaming session.
Recommended keys to mark, if you use them: Tab, Esc, Shift, Alt,
Ctrl, Windows icon, F1, F2, F3, F4, F5, F6...
)")
    
    ; add a help popup button here
    guiFontDefault("controlsWindow")
    Gui, controlsWindow:Add, Button, w230 gTurnOffHotkeysMessage, % "How to use marked keys normally again"
    
    guiFontContent("controlsWindow")

    addControlsWindowInstructionsParagraph(xOff, "
( Join`s
To map one of the following: Back, Shift, Alt, Ctrl,
Windows icon, + key (if not in the numpad), or AltGr, 
you must mark the control with ''Special Bind'' first, then click on the control and press the key.
)")

    ; add a help popup button here
    guiFontDefault("controlsWindow")
    Gui, controlsWindow:Add, Button, w200 gControlsKnownIssuesMessage, % "Known issues (Troubleshooting)"

    guiFontContent("controlsWindow")

    addControlsWindowInstructionsParagraph(xOff, "
( Join`s
Tip #1: After you're done, check if all of your keybindings work.
)")
    addControlsWindowInstructionsParagraph(xOff, "
( Join`s
Tip #2: You can reopen the program by right-clicking the tray
and selecting ''Reload this Script'' or with the key combination Ctrl+Alt+R.
)")
    addControlsWindowInstructionsParagraph(xOff, "
( Join`s
Tip #3: to restore defaults, close this program, go to the fairbox folder
and delete the file named ''hotkeys.ini'', and then, launch the program.
)")
    addControlsWindowInstructionsParagraph(xOff, "")
    addControlsWindowInstructionsParagraph(xOff, "Current fairbox folder: " A_ScriptDir)
    return
}

addControlsWindowInstructionsParagraph(xOff, paragraph) {
    textWrapWidth := 380
    paragraphSeparation := 9
    Gui, controlsWindow:Add, Text, xm+%xOff% y+%paragraphSeparation% +Wrap w%textWrapWidth%, % paragraph
    return
}

turnOffHotkeysMessage() {
    Gui, +OwnDialogs
    turnOffHotkeysMessageString := "
( Join`s
If you need to use the keys normally, the easiest thing you can do is binding a key as the Input
On/Off control. Pressing it turns off all game buttons and lets you use all the keyboard keys normally.
To go back to playing, press it again.
`n
`nAnother option is to right-click the program's tray icon and click ''Suspend Hotkeys''.
This turns off all controls until you repeat this action.
`n
`nLast, closing fairbox makes all keys work again.
)"
    MsgBox,, % "Prevent Default Behavior info" , % turnOffHotkeysMessageString
}

controlsKnownIssuesMessage() {
    Gui, +OwnDialogs
    controlsKnownIssuesMessageString := "
( Join`s
#1: If two different key bindings appear here with the same name, they may still work as two different keys,
but to know for sure, check it.
`n
`n#2: Even if a key binding shows here as an invisible character, it may still work.
`n
`n#3: If you see some extraneous error message that keeps appearing, take a screenshot of it and send it to the fairbox developers along with the hotkeys.ini from the fairbox folder.
`nCurrent fairbox folder: " A_ScriptDir "
)"
    MsgBox,, % "Known Issues with the Controls Editor" , % controlsKnownIssuesMessageString
}