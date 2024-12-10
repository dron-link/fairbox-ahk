#Requires AutoHotkey v1

logAppend(textOut) {
    FileAppend, % textOut "`n", fairbox_log_0.log
}