#Requires Autohotkey v1.1

#include, deadzoneHistoryObjects.ahk
#include, getOutOfDeadzone.ahk
;;; this

class outOfDeadzoneInfo {
    __New(boolOut, timestamp) {
        this.out := boolOut
        this.timestamp := timestamp
    }
}