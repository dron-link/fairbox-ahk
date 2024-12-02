#Requires AutoHotkey v1.1

detectNonIntegers(aX, aY) {
    if aX is not Integer
        OutputDebug, % "detectNonIntegers() problem . coordinate x type is not integer`n"
    if aY is not Integer
        OutputDebug, % "detectNonIntegers() problem . coordinate y type is not integer`n"
    return
}
