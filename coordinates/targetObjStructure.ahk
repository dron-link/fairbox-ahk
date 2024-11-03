#Requires AutoHotkey v1.1

; order must correspond to cDefaultBindings
keysModCAngleRole := ["ClosestToAxis", "SecondClosestToAxis", "SecondClosestTo45Deg", "ClosestTo45Deg"]
modCAngleRole := {}
for index, roleKey in keysModCAngleRole {
    modCAngleRole["modXC" roleKey] := ""
    modCAngleRole["modYC" roleKey] := ""
}

class targetCoordinateTree {
    format := {unitCircle : false, centerOffsetBy128 : false}

    ; to store coordinates. 
    normal := {}
    airdodge := {}
    fireFox := new modCAngleRole
    extendedB := new modCAngleRole

    loadCoordinates() {
        return assignCoordinateValues(this)
    } 
    formatCoordinates() {
        return formatTargetCoordinates(this)
    }
  
    bindAnglesToCStick() { ; We are going to set personalized c-button angle bindings 
        global keysModCAngleRole   
        global modCAngleRole
        cIniPath := A_ScriptDir "\c-stick-angle-bindings.ini"
        ; if c-stick-angle-bindings.ini doesn't exist, create it
        AttributeString := FileExist(cIniPath)
        if (!AttributeString) {
            OutputDebug, c-stick-angle-bindings.ini found to not exist. generating it...
            cIniTextDefault := "
            (
[cStickAngling]
" keysModCAngleRole[1] "=c-down
" keysModCAngleRole[2] "=c-left
" keysModCAngleRole[3] "=c-up
" keysModCAngleRole[4] "=c-right
            )"
            FileAppend, % cIniTextDefault, % cIniPath
        }
  
        readModCAngleRole := {} ; stores values read from ini
        cIniCompleteness := 0 ; each bit set represents one of four cardinal c-stick directions read
        ; c-stick-angle-bindings ini completeness check
        for index, roleKey in keysModCAngleRole {
            IniRead, readBinding, c-stick-angle-bindings.ini, cStickAngling, % roleKey, %A_Space%
            if (readBinding = "cDown" or readBinding = "c-down"
                or readBinding = "c down") {
                readModCAngleRole[roleKey] := "cDown"
                cIniCompleteness |= 1
            } else if (readBinding = "cLeft" or readBinding = "c-left"
                or readBinding = "c left") {
                readModCAngleRole[roleKey] := "cLeft"
                cIniCompleteness |= 1<<1
            } else if (readBinding = "cUp" or readBinding = "c-up"
                or readBinding = "c up") {
                readModCAngleRole[roleKey] := "cUp"
                cIniCompleteness |= 1<<2
            } else if (readBinding = "cRight" or readBinding = "c-right"
                or readBinding = "c right") {
                readModCAngleRole[roleKey] := "cRight"
                cIniCompleteness |= 1<<3
            }
        }
        ; dealing with an incomplete c-stick-angle-bindings ini
        if (cIniCompleteness < (1<<4) - 1) {
            cDefaultBindings := ["cDown", "cLeft", "cUp", "cRight"]
            for index, roleKey in keysModCAngleRole {
                if (readModCAngleRole[roleKey] = "") {
                    OutputDebug, % "readModCAngleRole." roleKey " ----UNABLE TO READ----`n"
                } else {
                    OutputDebug, % "readModCAngleRole." roleKey " == " readModCAngleRole[roleKey] "`n"
                }
                
                readModCAngleRole[roleKey] := cDefaultBindings[A_Index]
            }
            OutputDebug, failure retrieving bindings from c-stick-angle-bindings.ini . fallback on default...
        }
        ; assigning firefox angles and c-stick extended up-B angles according to values read from ini
        for index, roleKey in keysModCAngleRole {
            if (readModCAngleRole[roleKey] = "cDown") {
                this.fireFox.modXCDown := this.fireFox["modXC" roleKey]
                this.fireFox.modYCDown := this.fireFox["modYC" roleKey]
                this.extendedB.modXCDown := this.extendedB["modXC" roleKey]
                this.extendedB.modYCDown := this.extendedB["modYC" roleKey]
            } else if (readModCAngleRole[roleKey] = "cLeft") {
                this.fireFox.modXCLeft := this.fireFox["modXC" roleKey]
                this.fireFox.modYCLeft := this.fireFox["modYC" roleKey]
                this.extendedB.modXCLeft := this.extendedB["modXC" roleKey]
                this.extendedB.modYCLeft := this.extendedB["modYC" roleKey]
            } else if (readModCAngleRole[roleKey] = "cUp") {
                this.fireFox.modXCUp := this.fireFox["modXC" roleKey]
                this.fireFox.modYCUp := this.fireFox["modYC" roleKey]
                this.extendedB.modXCUp := this.extendedB["modXC" roleKey]
                this.extendedB.modYCUp := this.extendedB["modYC" roleKey]
            } else if (readModCAngleRole[roleKey] = "cRight") {
                this.fireFox.modXCRight := this.fireFox["modXC" roleKey]
                this.fireFox.modYCRight := this.fireFox["modYC" roleKey]
                this.extendedB.modXCRight := this.extendedB["modXC" roleKey]
                this.extendedB.modYCRight := this.extendedB["modYC" roleKey]
            }
        }
        return
    }
}

