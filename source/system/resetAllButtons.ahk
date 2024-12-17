#Requires AutoHotkey v1

resetAllButtons() {
    global myStick, global hotkeysList
    ; method #1
    Loop, % hotkeysList.Length() {
        Gosub, % hotkeysList[A_Index] "Label_UP"
    }
    ; method #2, why not be extra sure
    Loop, 12 {
        myStick.setBtn(0, A_Index)
    }
    setAnalogStick([0, 0])
    setCStick([0, 0])
    setAnalogR(0)
    return
}
