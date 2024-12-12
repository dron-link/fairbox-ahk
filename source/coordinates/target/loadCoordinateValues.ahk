#Requires AutoHotkey v1

loadCoordinateValues(ByRef target) {
    /*  true if components are in form: 
        <-1, ..., -0.0125, 0, 0.0125, 0.0250, 0.0375, 0.0500, ..., 0.9875, 1>
        false if they're in the form: 
        <-80, -79, ..., -1, 0, -1, ..., 79, 80>  OR  <48, 49, ... 127, 128, 129, ..., 207, 208>
    */
    target.format.unitCircle := true

    ; set to true if the values are centered around 128 instead of 0
    target.format.centerOffsetBy128 := false

    ; b0xx constants. ; coordinates get mirrored and rotated appropiately thanks to reflectCoords()
    target.normal.origin := [0, 0]
    target.normal.vertical := [0, 1]
    target.normal.verticalModX := [0, 0.5375]
    target.normal.verticalModY := [0, 0.7375]
    target.normal.horizontal := [1, 0]
    target.normal.horizontalModX := [0.6625, 0]
    target.normal.horizontalModY := [0.3375, 0]
    target.normal.quadrant := [0.7, 0.7]
    target.normal.quadrantModX := [0.7375, 0.3125]
    target.normal.quadrantModY := [0.3125, 0.7375]

    target.airdodge.vertical := [0, 1]
    target.airdodge.verticalModX := [0, 0.5375]
    target.airdodge.verticalModY := [0, 0.7375]
    target.airdodge.horizontal := [1, 0]
    target.airdodge.horizontalModX := [0.6625, 0]
    target.airdodge.horizontalModY := [0.3375, 0]
    target.airdodge.quadrant12 := [0.7, 0.7]
    target.airdodge.quadrant34 := [0.7, 0.6875]
    target.airdodge.quadrantModX := [0.6375, 0.375]
    target.airdodge.quadrant12ModY := [0.475, 0.875]
    target.airdodge.quadrant34ModY := [0.5, 0.85]

    target.fireFox.modXCClosestToAxis := [0.7, 0.3625]   ; ~27 deg
    target.fireFox.modXCSecondClosestToAxis := [0.7875, 0.4875]  ; ~32 deg
    target.fireFox.modXCSecondClosestTo45Deg := [0.7, 0.5125]  ; ~36 deg
    target.fireFox.modXCClosestTo45Deg := [0.6125, 0.525]  ; ~41 deg
    target.fireFox.modYCClosestTo45Deg := [0.5875, 0.7125]   ; ~50 deg ; fixed from previous [0.6375, 0.7625]
    target.fireFox.modYCSecondClosestTo45Deg := [0.5125, 0.7]  ; ~54 deg
    target.fireFox.modYCSecondClosestToAxis := [0.4875, 0.7875]  ; ~58 deg
    target.fireFox.modYCClosestToAxis := [0.3625, 0.7]   ; ~63 deg

    target.extendedB.modX := [0.9125, 0.3875]   ; ~23 deg
    target.extendedB.modXCClosestToAxis := [0.875, 0.45]   ; ~27 deg
    target.extendedB.modXCSecondClosestToAxis := [0.85, 0.525]   ; ~32 deg
    target.extendedB.modXCSecondClosestTo45Deg := [0.7375, 0.5375]   ; ~36 deg
    target.extendedB.modXCClosestTo45Deg := [0.6375, 0.5375]   ; ~40 deg
    target.extendedB.modYCClosestTo45Deg := [0.6375, 0.7625]   ; ~50 deg ; fixed from previous [0.5875, 0.7125]
    target.extendedB.modYCSecondClosestTo45Deg := [0.5875, 0.8]  ; ~54 deg
    target.extendedB.modYCSecondClosestToAxis := [0.525, 0.85]   ; ~58 deg
    target.extendedB.modYCClosestToAxis := [0.45, 0.875]   ; ~63 deg
    target.extendedB.modY := [0.3875, 0.9125]   ; ~67 deg

    return
}