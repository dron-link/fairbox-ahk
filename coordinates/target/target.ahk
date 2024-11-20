#Requires AutoHotkey v1.1

#include, formatTargetCoordinates.ahk
#include, loadCoordinateValues.ahk ; you can customize the coordinates in that file
;;; this file
#include, targetCoordinateTreeWithCBinds.ahk

class targetCoordinateTreeSkeleton {
    format := {unitCircle : false, centerOffsetBy128 : false}

    ; to store coordinates.
    normal := {}
    airdodge := {}
    fireFox := new this.modCAngleRoleTree
    extendedB := new this.modCAngleRoleTree   

    class modCAngleRoleTree {
        __New() {
            global keysModCAngleRole
            for index, roleKey in keysModCAngleRole {
                this["modXC" roleKey] := ""
                this["modYC" roleKey] := ""
            }
        }
    }
}

