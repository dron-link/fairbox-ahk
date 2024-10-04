
; order must correspond to cDefaultBindings
keysModCAngleRole := ["closestToAxis", "secondClosestToAxis", "secondClosestTo45Deg", "closestTo45Deg"]
modCAngleRole := {}
for index, roleKey in keysModCAngleRole {
    modCAngleRole[roleKey] := ""
}
class baseTarget {

    ; to store coordinates. 
    fireFox := {}
    fireFox.modXC := new modCAngleRole
    fireFox.modYC := new modCAngleRole
    extendedB := {}
    extendedB.modXC := new modCAngleRole
    extendedB.modYC := new modCAngleRole
  
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
                this.fireFox.modXC.down := this.fireFox.modXC[roleKey]
                this.fireFox.modYC.down := this.fireFox.modYC[roleKey]
                this.extendedB.modXC.down := this.extendedB.modXC[roleKey]
                this.extendedB.modYC.down := this.extendedB.modYC[roleKey]
            } else if (readModCAngleRole[roleKey] = "cLeft") {
                this.fireFox.modXC.left := this.fireFox.modXC[roleKey]
                this.fireFox.modYC.left := this.fireFox.modYC[roleKey]
                this.extendedB.modXC.left := this.extendedB.modXC[roleKey]
                this.extendedB.modYC.left := this.extendedB.modYC[roleKey]
            } else if (readModCAngleRole[roleKey] = "cUp") {
                this.fireFox.modXC.up := this.fireFox.modXC[roleKey]
                this.fireFox.modYC.up := this.fireFox.modYC[roleKey]
                this.extendedB.modXC.up := this.extendedB.modXC[roleKey]
                this.extendedB.modYC.up := this.extendedB.modYC[roleKey]
            } else if (readModCAngleRole[roleKey] = "cRight") {
                this.fireFox.modXC.right := this.fireFox.modXC[roleKey]
                this.fireFox.modYC.right := this.fireFox.modYC[roleKey]
                this.extendedB.modXC.right := this.extendedB.modXC[roleKey]
                this.extendedB.modYC.right := this.extendedB.modYC[roleKey]
            }
        }
        return
    }
}

