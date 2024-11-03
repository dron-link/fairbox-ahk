#Requires AutoHotkey v1.1

testNerfsByHand(activation) {
    global
    if activation {
        nerfManualTestMode := 1
        /* Manual_Nerf_Testing
          0 no test mode
          1 pivoting, to u-tilt or d-tilt range in less than 8 frames
          2 pivoting, to up-angled f-tilt in less than 8 frames
          3 pivoting, to down-angled f-tilt in less than 8 frames
          4 dashing above or below deadzone (to time out the tap-jump or d-smash execution window 
            by placing the stick in the same active y zone)
            then pivoting and inputting an up-tilt or d-tilt under 5 frames
          5 Crouching to u-tilt range in less than 3 frames

          follow execution instructions shown on debug message screen or below
        */
        
        OutputDebug, % "testNerfsByHand`nmode: " nerfManualTestMode ". "

        Switch nerfManualTestMode
        {
        case 1: ; pivot with left/right NSOCD while pressing up or down (optional: then press A)
            target.normal.vertical := [0, ANALOG_DEAD_MAX + 2 * ANALOG_STEP]
            target.normal.quadrant := [79, 1]
            OutputDebug, % "pivoting, to u-tilt or d-tilt range in less than 8 frames`n"
            . "INSTRUCTIONS: pivot with left/right NSOCD while pressing up or down (optional: then press A)"

        case 2: ; pivot with modX while pressing up (optional: then press A)
            target.normal.quadrant := [79, 1]
            target.normal.vertical := target.normal.origin
            OutputDebug, % "pivoting, to up-angled f-tilt in less than 8 frames`n"
            . "INSTRUCTIONS: pivot with modX while pressing up (optional: then press A)"
        case 3: ; pivot with modX while pressing down (optional: then press A)
            target.normal.quadrant := [79, 1]
            target.normal.vertical := target.normal.origin
            target.normal.quadrantModX := [ANALOG_DEAD_MAX + 7 * ANALOG_STEP, ANALOG_DEAD_MAX + ANALOG_STEP]
            OutputDebug, % "pivoting, to down-angled f-tilt in less than 8 frames`n"
            . "INSTRUCTIONS: pivot by modX while pressing down (optional: then press A)"
        case 4: ; pivot with left/right NSOCD while holding one of the vertical keys (optional: then press A)
            target.normal.quadrant := [72 + ANALOG_STEP, ANALOG_DEAD_MAX + 2 * ANALOG_STEP]
            target.normal.vertical := [0, ANALOG_DEAD_MAX + 2 * ANALOG_STEP]
        OutputDebug, % "dashing above or below deadzone (to time out the tap-jump or d-smash execution window by placing`n"
            . "the stick in the same active y zone) then pivoting and inputting an up-tilt or d-tilt under 5 frames`n"
            . "INSTRUCTIONS: pivot by left/right NSOCD while holding one of the vertical keys (optional: then press A)"
        case 5: ; press up -> no tap jump. press down, then quickly press up -> nerf (tap jump)
            target.normal.vertical := [0, -ANALOG_CROUCH]
            OutputDebug, % "Crouching to u-tilt range in less than 3 frames`n"
            . "INSTRUCTIONS: press up -> no tap jump. press down, then quickly press up -> nerf (tap jump)"
        }
        OutputDebug, % "`n"
    }
    return
}