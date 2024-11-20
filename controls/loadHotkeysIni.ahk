#Requires AutoHotkey v1.1

loadHotkeysIni() {
    global

    FileInstall, install\hotkeys.ini, % A_ScriptDir "\hotkeys.ini", 0 ; for when hotkeys.ini doesn't exist
    Loop, % hotkeysList.Length() {
        if (hotkeysList[A_Index] = "") { ; We skip empty hotkey IDs if there are any
            Continue
        }
        ; Attempt to retrieve a hotkey activation key from the INI file. If it fails: we get ""
        IniRead, savedHK%A_Index%, hotkeys.ini, Hotkeys, % hotkeysList[A_Index], %A_Space%

        savedHK%A_Index% := strReplace(savedHK%A_Index%, "<#") ; do away with win modifiers if there's any
        savedHK%A_Index% := strReplace(savedHK%A_Index%, ">#")
        savedHK%A_Index% := strReplace(savedHK%A_Index%, "#")
    }
    return
}
