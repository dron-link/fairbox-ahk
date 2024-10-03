; order must correspond to cDefaultBindings
keysModCAngleRoles := ["closestToAxis", "secondClosestToAxis", "secondClosestTo45Deg", "closestTo45Deg"]
modCAngleRoles := {}
for index, element in keysModCAngleRoles {
    modCAngleRoles[element] := ""
}
class baseTarget {

    ; to store coordinates. 
    fireFox := {}
    fireFox.modXC := new modCAngleRoles
    fireFox.modYC := new modCAngleRoles
    extendedB := {}
    extendedB.modXC := new modCAngleRoles
    extendedB.modYC := new modCAngleRoles
  
    bindAnglesToCStick() { ; We are going to set personalized c-button angle bindings 
        global keysModCAngleRoles   
        global modCAngleRoles
        cIniPath := A_ScriptDir "\c-stick-angle-bindings.ini"
        ; if c-stick-angle-bindings.ini doesn't exist, create it
        AttributeString := FileExist(cIniPath)
        if (!AttributeString) {
            OutputDebug, c-stick-angle-bindings.ini found to not exist. generating it...
            iniStatementLeftHand := []
            cIniTextDefault := "
            (
[cStickAngling]
" keysModCAngleRoles[1] "=c-down
" keysModCAngleRoles[2] "=c-left
" keysModCAngleRoles[3] "=c-up
" keysModCAngleRoles[4] "=c-right
            )"
            FileAppend, % cIniTextDefault, % cIniPath
        }
  
        readModCAngleRoles := {} ; stores values read from ini
        cIniCompleteness := 0 ; each bit set represents one of four cardinal c-stick directions read
        ; c-stick-angle-bindings ini completeness check
        for keyString, element in modCAngleRoles {
            IniRead, readBinding, c-stick-angle-bindings.ini, cStickAngling, % keyString, %A_Space%
            if (readBinding = "cDown" or readBinding = "c-down"
                or readBinding = "c down") {
                readModCAngleRoles[keyString] := "cDown"
                cIniCompleteness |= 1
            } else if (readBinding = "cLeft" or readBinding = "c-left"
                or readBinding = "c left") {
                readModCAngleRoles[keyString] := "cLeft"
                cIniCompleteness |= 1<<1
            } else if (readBinding = "cUp" or readBinding = "c-up"
                or readBinding = "c up") {
                readModCAngleRoles[keyString] := "cUp"
                cIniCompleteness |= 1<<2
            } else if (readBinding = "cRight" or readBinding = "c-right"
                or readBinding = "c right") {
                readModCAngleRoles[keyString] := "cRight"
                cIniCompleteness |= 1<<3
            }
        }
        ; dealing with an incomplete c-stick-angle-bindings ini
        if (cIniCompleteness < (1<<4) - 1) {
            cDefaultBindings := ["cDown", "cLeft", "cUp", "cRight"]
            for index, element in keysModCAngleRoles {
                if (readModCAngleRoles[element] = "") {
                    OutputDebug, % "readModCAngleRoles." element " ----UNABLE TO READ----`n"
                } else {
                    OutputDebug, % "readModCAngleRoles." element " == " readModCAngleRoles[element] "`n"
                }
                
                readModCAngleRoles[element] := cDefaultBindings[A_Index]
            }
            OutputDebug, failure retrieving bindings from c-stick-angle-bindings.ini . fallback on default...
        }
        ; assigning firefox angles and c-stick extended up-B angles according to values read from ini
        for keyString, element in modCAngleRoles {
            if (readModCAngleRoles[keyString] = "cDown") {
                this.fireFox.modXC.down := this.fireFox.modXC[keyString]
                this.fireFox.modYC.down := this.fireFox.modYC[keyString]
                this.extendedB.modXC.down := this.extendedB.modXC[keyString]
                this.extendedB.modYC.down := this.extendedB.modYC[keyString]
            } else if (readModCAngleRoles[keyString] = "cLeft") {
                this.fireFox.modXC.left := this.fireFox.modXC[keyString]
                this.fireFox.modYC.left := this.fireFox.modYC[keyString]
                this.extendedB.modXC.left := this.extendedB.modXC[keyString]
                this.extendedB.modYC.left := this.extendedB.modYC[keyString]
            } else if (readModCAngleRoles[keyString] = "cUp") {
                this.fireFox.modXC.up := this.fireFox.modXC[keyString]
                this.fireFox.modYC.up := this.fireFox.modYC[keyString]
                this.extendedB.modXC.up := this.extendedB.modXC[keyString]
                this.extendedB.modYC.up := this.extendedB.modYC[keyString]
            } else if (readModCAngleRoles[keyString] = "cRight") {
                this.fireFox.modXC.right := this.fireFox.modXC[keyString]
                this.fireFox.modYC.right := this.fireFox.modYC[keyString]
                this.extendedB.modXC.right := this.extendedB.modXC[keyString]
                this.extendedB.modYC.right := this.extendedB.modYC[keyString]
            }
        }
        return
    }
  }
