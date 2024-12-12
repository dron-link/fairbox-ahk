#Requires AutoHotkey v1

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