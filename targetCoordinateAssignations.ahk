target := new baseTarget

modeIsUnitCircle := true ; don't set to false because the code hasn't been tested yet with that condition
; assign the coordinates of c-stick modifier action
target.fireFox.modXC.closestToAxis := [0.7, 0.3625]   ; ~27 deg
target.fireFox.modXC.secondClosestToAxis := [0.7875, 0.4875]  ; ~32 deg
target.fireFox.modXC.secondClosestTo45Deg := [0.7, 0.5125]  ; ~36 deg
target.fireFox.modXC.closestTo45Deg := [0.6125, 0.525]  ; ~41 deg 
target.fireFox.modYC.closestTo45Deg := [0.5875, 0.7125]   ; ~50 deg ; fixed from previous [0.6375, 0.7625]
target.fireFox.modYC.secondClosestTo45Deg := [0.5125, 0.7]  ; ~54 deg
target.fireFox.modYC.secondClosestToAxis := [0.4875, 0.7875]  ; ~58 deg
target.fireFox.modYC.closestToAxis := [0.3625, 0.7]   ; ~63 deg
target.extendedB.modXC.closestToAxis := [0.875, 0.45]   ; ~27 deg
target.extendedB.modXC.secondClosestToAxis := [0.85, 0.525]   ; ~32 deg
target.extendedB.modXC.secondClosestTo45Deg := [0.7375, 0.5375]   ; ~36 deg
target.extendedB.modXC.closestTo45Deg := [0.6375, 0.5375]   ; ~40 deg
target.extendedB.modYC.closestTo45Deg := [0.6375, 0.7625]   ; ~50 deg ; fixed from previous [0.5875, 0.7125]
target.extendedB.modYC.secondClosestTo45Deg := [0.5875, 0.8]  ; ~54 deg
target.extendedB.modYC.secondClosestToAxis := [0.525, 0.85]   ; ~58 deg
target.extendedB.modYC.closestToAxis := [0.45, 0.875]   ; ~63 deg

; b0xx constants. ; coordinates get mirrored and rotated appropiately thanks to reflectCoords()
coordsOrigin := [0, 0]
coordsVertical := [0, 1]
coordsVerticalModX := [0, 0.5375]
coordsVerticalModY := [0, 0.7375]
coordsHorizontal := [1, 0]
coordsHorizontalModX := [0.6625, 0]
coordsHorizontalModY := [0.3375, 0]
coordsQuadrant := [0.7, 0.7]            ;  magnitude < angle    is the polar form notation of 2d coordinates
coordsQuadrantModX := [0.7375, 0.3125]  ;  0.8000    < 22.96 deg
coordsQuadrantModY := [0.3125, 0.7375]  ;  

coordsAirdodgeVertical := coordsVertical
coordsAirdodgeVerticalModX := coordsVerticalModX
coordsAirdodgeVerticalModY := coordsVerticalModY
coordsAirdodgeHorizontal := coordsHorizontal
coordsAirdodgeHorizontalModX := coordsHorizontalModX
coordsAirdodgeHorizontalModY := coordsHorizontalModY
coordsAirdodgeQuadrant12 := coordsQuadrant
coordsAirdodgeQuadrant34 := [0.7, 0.6875]
coordsAirdodgeQuadrantModX := [0.6375, 0.375] ; 30.47 deg. b0xx default
coordsAirdodgeQuadrant12ModY := [0.475, 0.875] ; 61.50 deg. b0xx default
coordsAirdodgeQuadrant34ModY := [0.5, 0.85] ; 59.53 deg b0xx default

coordsFirefoxModX := coordsQuadrantModX
coordsFirefoxModY := coordsQuadrantModY
coordsExtendedFirefoxModX := [0.9125, 0.3875]       ; ~23 deg
coordsExtendedFirefoxModY := [0.3875, 0.9125]       ; ~67 deg