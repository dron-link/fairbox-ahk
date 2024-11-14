#Requires AutoHotkey v1.1

loadHotkeysIni() {
    global

    FileInstall, install\hotkeys.ini, % A_ScriptDir "\hotkeys.ini", 0 ; for when hotkeys.ini doesn't exist
    for index in hotkeys {
        ; Attempt to retrieve a hotkey activation key from the INI file. If it fails: we get ""
        IniRead, savedHK%index%, hotkeys.ini, Hotkeys, % index, %A_Space%

        savedHK%index% := strReplace(savedHK%index%, "<#") ; do away with win modifiers if there's any
        savedHK%index% := strReplace(savedHK%index%, ">#")
        savedHK%index% := strReplace(savedHK%index%, "#")

        HK%index% := savedHK%index%
    }
    return
}
