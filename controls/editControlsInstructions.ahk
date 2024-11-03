#Requires AutoHotkey v1.1

addEditControlsInstructions(xOff, yOff) {
    instructionsText1 := "
(
Click on the control you want to edit and press the key you want to map to it.

To clear a control, click on it and press Back. If you try to bind a 
key that already was bound, the program won't let you do it, and it will
alert you of the control you need to make a change to.

''Prevent Default Behavior'' eliminates any side effect of pressing a key
or key combination. Use it ONLY when you play using keys that can mess
up your gaming session. Recommended keys to mark, if you use them:
Tab, Esc, Shift, Alt, Ctrl, Windows icon, F1, F2, F3, F4, F5, F6...
)"

    instructionsText2 := "
(
To map one of the following: Back, Shift, Alt, Ctrl, Windows icon, + (not
numpad), or AltGr, you must mark the control with ''Special Bind'' first,
then click on the control and press the key.

Note: if even with Special Bind active, you can't bind Tab, Back, or Space, 
and you don't receive an alert that your chosen key is already used, there's
a good chance this program just refused to alert you of it.
Look closer for any button that already uses that key, then clear that key.

Note: After you're done, check if all of your keybindings work.

Note: If two different key bindings appear here with the same name, they
may still work as two different keys, but to know for sure, check it.

Note: even if a key binding shows here as an invisible character, it may
still work.

Tip: You can reopen the program by right-clicking the tray and selecting
''Reload this Script'' or with the key combination Ctrl+Alt+R.

Tip: to restore defaults, close this program, go to the folder containing your
program ''fairbox'' and delete the file named ''hotkeys.ini'' once.
)"

    yOff += 30
    Gui, Font, s11 norm, Segoe
    Gui, Add, GroupBox, xm+%xOff% ym+%yOff% w475 r27, % "Instructions" ; options r%n% means n rows max allocated
    Gui, Add, Text, xp+15 yp+25, % instructionsText1
    guiFontDefault()
    Gui, Add, Button, w220 gTurnOffHotkeysMessage, % "How to use marked keys normally again"
    Gui, Font, s11 norm, Segoe
    Gui, Add, Text, xp yp+42, % instructionsText2
    guiFontDefault()   
    return
}

turnOffHotkeysMessage() {
    MsgBox, % "If you need to use the keys normally, right-click the program's tray icon "
        . "and click ''Suspend Hotkeys'' - or press Ctrl+Alt+S if each one of those keys work. "
        . "This turns off all game buttons "
        . "until you repeat this action.`n`n"
        . "Additionally, closing this program also makes all keys work again."
}