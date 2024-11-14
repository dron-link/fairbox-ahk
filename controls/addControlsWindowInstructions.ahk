#Requires AutoHotkey v1.1

addControlsWindowInstructionsParagraph(xOff, paragraph) {
    textWrapWidth := 380
    paragraphSeparation := 9
    Gui, controlsWindow:Add, Text, xm+%xOff% y+%paragraphSeparation% +Wrap w%textWrapWidth%, % paragraph
    return
}

addControlsWindowInstructions(descriptionWidth) {
    xOff := 380 + descriptionWidth

    ; add the group box and the section title
    guiFontDefault("controlsWindow")
    xOffBox := xOff - 15 
    Gui, controlsWindow:Add, GroupBox, xm+%xOffBox% ym w410 h560, % "Instructions"
    
    guiFontContent("controlsWindow")
    ; set up a hidden, empty text element, its coordinates will be used for the next paragraph additions
    xHide := xOff - 25 
    Gui, controlsWindow:Add, Text, xm+%xHide% yp, % ""

    addControlsWindowInstructionsParagraph(xOff, "Click on the control you want to edit and press the key you want to map to it.")
    addControlsWindowInstructionsParagraph(xOff, "To clear a control, click on it and press Back. If you try to bind a key that already was bound, the program won't let you do it, and it will alert you of the control you need to make a change to.")
    addControlsWindowInstructionsParagraph(xOff, "''Prevent Default Behavior'' eliminates any side effect of pressing a key or key combination. Use it ONLY when you play using keys that can mess up your gaming session. Recommended keys to mark, if you use them: Tab, Esc, Shift, Alt, Ctrl, Windows icon, F1, F2, F3, F4, F5, F6...")
    
    ; add a help popup button here
    guiFontDefault("controlsWindow")
    Gui, controlsWindow:Add, Button, w250 gTurnOffHotkeysMessage, % "How to use marked keys normally again"
    
    guiFontContent("controlsWindow")
    addControlsWindowInstructionsParagraph(xOff, "To map one of the following: Back, Shift, Alt, Ctrl,"
    . " Windows icon, + (not numpad), or AltGr, you must mark the control with ''Special Bind'' first, then click on the control and press the key.")

    ; add a help popup button here
    guiFontDefault("controlsWindow")
    Gui, controlsWindow:Add, Button, w130 gControlsKnownIssuesMessage, % "Known issues (Troubleshooting)"

    guiFontContent("controlsWindow")
    addControlsWindowInstructionsParagraph(xOff, "Tip #1: After you're done, check if all of your keybindings work.")
    addControlsWindowInstructionsParagraph(xOff, "Tip #2: You can reopen the program by right-clicking the tray and selecting ''Reload this Script'' or with the key combination Ctrl+Alt+R.")
    addControlsWindowInstructionsParagraph(xOff, "Tip #3: to restore defaults, close this program, go to the folder containing your program ''fairbox'' and delete the file named ''hotkeys.ini'', and then, launch the program.")
    addControlsWindowInstructionsParagraph(xOff, "")
    addControlsWindowInstructionsParagraph(xOff, "Current fairbox folder: " A_ScriptDir)
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
#1: If even with Special Bind active, you can't bind Tab, Back, or Space,
and you don't receive an alert that your chosen key is already used,
there's a good chance this program just refused to alert you of it. 
Look closer for any button that already uses that key, then clear that key.
`n
`n#2: If two different key bindings appear here with the same name, they may still work as two different keys,
but to know for sure, check it.
`n
`n#3: Even if a key binding shows here as an invisible character, it may still work.
)"
    MsgBox,, % "Known Issues with the Controls Editor" , % controlsKnownIssuesMessageString
}