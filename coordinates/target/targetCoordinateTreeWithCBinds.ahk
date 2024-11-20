#Requires AutoHotkey v1.1

class targetCoordinateTreeWithCBinds extends targetCoordinateTreeSkeleton {
    loadCoordinates() {
        loadCoordinateValues(this)
        formatTargetCoordinates(this)
        this.bindAnglesToCStick()
        return
    }

    bindAnglesToCStick() { ; We are going to set personalized c-button angle bindings
        global keysModCAngleRole
        ; if c-stick-angle-bindings.ini doesn't exist, create it
        FileInstall, install\c-stick-angle-bindings.ini, % A_ScriptDir "\c-stick-angle-bindings.ini", 0

        ; c-stick-angle-bindings ini completeness evaluation
        readModCAngleRole := {} ; stores values read from ini
        cIniCompleteness := 0 ; each bit set represents one of four cardinal c-stick directions read

        for index, roleKey in keysModCAngleRole {
            IniRead, readBinding, c-stick-angle-bindings.ini, cStickAngling, % roleKey, %A_Space%
            if (readBinding = "cDown" or readBinding = "c-down"
                or readBinding = "c down") {
                readModCAngleRole[roleKey] := "cDown"
                cIniCompleteness |= 1 ; 0bxxx1
            } else if (readBinding = "cLeft" or readBinding = "c-left"
                or readBinding = "c left") {
                readModCAngleRole[roleKey] := "cLeft"
                cIniCompleteness |= 1<<1 ; 0bxx1x
            } else if (readBinding = "cUp" or readBinding = "c-up"
                or readBinding = "c up") {
                readModCAngleRole[roleKey] := "cUp"
                cIniCompleteness |= 1<<2 ; 0bx1xx
            } else if (readBinding = "cRight" or readBinding = "c-right"
                or readBinding = "c right") {
                readModCAngleRole[roleKey] := "cRight"
                cIniCompleteness |= 1<<3 ; 0b1xxx
            }
        } ; end of completeness evaluation

        ; dealing with an incomplete c-stick-angle-bindings ini
        if (cIniCompleteness < (1<<4) - 1) {
            incompletenessMsg := "Failure retrieving bindings from c-stick-angle-bindings.ini . "
            . "Because of this, the C-Stick angle modifier action was reset to the default "
            . "for as long as this program runs.`n`n"
            . "Error details:`n"
            for index, roleKey in keysModCAngleRole {
                if (readModCAngleRole[roleKey] = "") {
                    incompletenessMsg .= "readModCAngleRole." roleKey " ----UNABLE TO READ----`n"
                } else {
                    incompletenessMsg .= "readModCAngleRole." roleKey " = " readModCAngleRole[roleKey] "`n"
                }

                Switch, roleKey ; These are the default B0XX bindings.
                {
                    Case "ClosestToAxis":
                        readModCAngleRole[roleKey] := "cDown"
                    Case "SecondClosestToAxis":
                        readModCAngleRole[roleKey] := "cLeft"
                    Case "SecondClosestTo45Deg":
                        readModCAngleRole[roleKey] := "cUp"
                    Case "ClosestTo45Deg":
                        readModCAngleRole[roleKey] := "cRight"
                }
            }
            MsgBox, % incompletenessMsg
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