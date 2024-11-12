#Requires AutoHotkey v1.1

FileCreateDir, fairboxLog
runDate := A_Now

logAppend(textOut) {
    global runDate
    FileAppend, % textOut "`n", % "fairboxLog\fairbox_log_" runDate ".log"
}