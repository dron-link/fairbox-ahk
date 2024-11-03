#Requires AutoHotkey v1.1

getHotkeyControlFormat(activationKey) {
    /*  Removes tilde (~) and Win (#) modifiers from hotkey control box content...
        They are incompatible with hotkey controls (cannot be shown in hotkey control boxes).
        The only modifiers supported are  ^ (Control), ! (Alt), and + (Shift).

        The "allow default functionality" modifier (~) still make their way to the
        hotkey thanks to validateHK()
    */
    result := StrReplace(activationKey, "#", ""), result := StrReplace(result, "~", "")
    return result
}

getStrippedFromModifiers(stringIn) {
    /*  strips a hotkey control's content of all modifiers. 
    useful to see if there's anything in it other than modifiers
    */
    modStrippedHK := strReplace(stringIn, "!"), modStrippedHK := strReplace(modStrippedHK, "^")
    modStrippedHK := strReplace(modStrippedHK, "+"), modStrippedHK := strReplace(modStrippedHK, "<")
    modStrippedHK := strReplace(modStrippedHK, ">")
    return modStrippedHK
}