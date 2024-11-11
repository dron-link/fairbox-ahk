#Requires AutoHotkey v1.1

testGameEngineConstants() {
    global
    if (ANALOG_STEP == 1
        and MS_PER_FRAME == 1000 / 60  ; game runs at 60 fps
        and PI == 3.141592653589793
        and DEG_TO_RADIAN == PI / 180
        and UNITCIRC_TO_INT == 80 ; factor for converting coordinate formats
        and INT_TO_UNITCIRC == 1/80
        and ANALOG_STICK_MIN == -80 ; > coordinate, then it's out of unit circle range
        and ANALOG_DEAD_MIN == -22 ; > coordinate, then it's outside the deadzone and to the left/down
        and ANALOG_DEAD_MAX == 22 ; < coordinate, then it's outside the deadzone and to the right/up
        and ANALOG_STICK_MAX == 80 ; < coordinate, then it's out of unit circle range
        and ANALOG_CROUCH == -50 ; >= y coordinate, then the character is holding crouch
        and ANALOG_DOWNSMASH == -53 ; >= y coordinate, then the character could downsmash, shield drop, fastfall, drop from platform etc
        and ANALOG_TAPJUMP == 55 ; <= y coordinate, then the character is in u-smash or tap-jump range
        and ANALOG_DASH_LEFT == -64 ; >= x coordinate, then f-smash or dash left
        and ANALOG_DASH_RIGHT == 64 ; <= x coordinate, means f-smash or dash right
        and ANALOG_SDI_LEFT == -56 ; >= x coordinate, then it's left sdi range
        and ANALOG_SDI_RIGHT == 56 ; <= x coordinate, then it's right sdi range
        and ANALOG_SDI_UP == 56 ; <= y coordinate
        and ANALOG_SDI_DOWN == - 56 ; >= y coordinate
        and MELEE_SDI_RAD == 56 * 56 ; <= x^2+y^2, and not in x or y deadzone then it's diagonal SDI range
        and ANALOG_ANGLE_FIFTY_RATIO_13 == tan(50 * DEG_TO_RADIAN) ; <= y/x where y and x are the same sign and out of deadzone,
        and ANALOG_ANGLE_FIFTY_RATIO_24 == -tan(50 * DEG_TO_RADIAN) ; >= y/x where y and x are a different sign (quadrants 2 and 4)
        and ANALOG_ANGLE_XAXIS_RATIO_13 == tan(20 * DEG_TO_RADIAN) ; > y/x where y and x are the same sign and out of deadzone,
        and ANALOG_ANGLE_XAXIS_RATIO_24 == -tan(20 * DEG_TO_RADIAN)
        and ANALOG_ANGLE_YAXIS_RATIO_13 == tan((90 - 20) * DEG_TO_RADIAN) ; < y/x where y and x are the same sign and out of deadzone,
        and ANALOG_ANGLE_YAXIS_RATIO_24 == -tan((90 - 20) * DEG_TO_RADIAN)
        and ANALOG_SPECIAL_LEFT == -48 ; >= x coordinate, then it's in range to forward-B to the left
        and ANALOG_SPECIAL_RIGHT == 48 ; <= x coordinate, then it's in range to forward-B to the right
        and ANALOG_SPECIAL_DOWN == -44 ; >= y coordinate, then it's down-B range
        and ANALOG_SPECIAL_UP == 44 ; <= y coordinate, then it's up-B range
        and ANALOG_SPOTDODGE_MIN_LEFT == -55 ; <= x coordinate, and-
        and ANALOG_SPOTDODGE_MIN_RIGHT == 55 ; >= x coordinate, then you are in spotdodge or middle shield-drop horizontal range
        and ANALOG_SPOTDODGE_MIN_VERTICAL == -56 ; >= y coordinate, then you are in spotdodge vertical (and below middle shield-drop) range
        and ANALOG_STICK_OFFSETCANCEL == -128
        and TIMELIMIT_DOWNUP == 3 * MS_PER_FRAME    ; // ms, how long after a crouch to upward input should it begin a jump?
        and JUMP_TIME == 2 * MS_PER_FRAME ; // after a recent crouch to upward input, always hold full up only for 2 frames
        and TIMELIMIT_FRAME == MS_PER_FRAME   ; for use in pivot feasibility check
        and TIMELIMIT_HALFFRAME == MS_PER_FRAME / 2
        and TIMELIMIT_DEBOUNCE == 6 ; ms, to combat the effect of mechanical switch bounce. i don't know if this is relevant in today's keyboards
        and TIMELIMIT_SIMULTANEOUS == 3.1 ; ms > current time minus last input timestamp, means that this input and last one can be considered as
        and TIMELIMIT_TAPSHUTOFF == 4 * MS_PER_FRAME ; 4 frames for tap jump shutoff, also d-smash shutoff and similar actions
        and TIMELIMIT_BURSTSDI == 5.5 * MS_PER_FRAME ; ms
        and TIMELIMIT_TAP_PLUS == 8.5 * MS_PER_FRAME ; // 3 additional frames
        and TIMELIMIT_CARDIAG == 8 * MS_PER_FRAME ; ms, fyi cardiag means cardinal diagonal
        and TIMELIMIT_PIVOTTILT == 8 * MS_PER_FRAME ; pivot timing lockout expiration time
        and TIMELIMIT_PIVOTTILT_YDASH == 5 * MS_PER_FRAME
        and TIMESTALE_PIVOT_INPUTSEQUENCE == 15 * MS_PER_FRAME
        and FORCE_FTILT == 30 ; value taken from CarVac haybox
        and TIMESTALE_SDI_INPUTSEQUENCE == 8 * MS_PER_FRAME
        and FUZZ_1_00_PROBABILITY == 50) { ; %, probability that the X output is 0.9875 instead of 1.0000
        OutputDebug, % "testGameEngineConstants(): passed. all pseudo-constants have their values unchanged.`n"
    } else {
        OutputDebug, % "testGameEngineConstants(): failed.`n"
    }
}
