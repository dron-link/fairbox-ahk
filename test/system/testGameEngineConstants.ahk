#Requires AutoHotkey v1.1

testGameEngineConstants() {
    global
    if (ANALOG_STEP == 1
        and MS_PER_FRAME == 1000 / 60  ; game runs at 60 fps
        and PI == 3.141592653589793
        and DEG_TO_RADIAN == PI / 180
        and UNITCIRC_TO_INT == 80 
        and INT_TO_UNITCIRC == 1/80
        and ANALOG_STICK_OFFSETCANCEL == -128
        and ANALOG_STICK_MIN == -80 
        and ANALOG_DEAD_MIN == -22
        and ANALOG_DEAD_MAX == 22
        and ANALOG_STICK_MAX == 80 
        and ANALOG_CROUCH == -50 
        and ANALOG_DOWNSMASH == -53 
        and ANALOG_TAPJUMP == 55
        and ANALOG_DASH_LEFT == -64
        and ANALOG_DASH_RIGHT == 64 
        and ANALOG_SDI_LEFT == -56
        and ANALOG_SDI_RIGHT == 56
        and ANALOG_SDI_UP == 56
        and ANALOG_SDI_DOWN == -56 
        and MELEE_SDI_RAD == 56 * 56
        and ANALOG_ANGLE_FIFTY_RATIO_13 == tan(50 * DEG_TO_RADIAN)
        and ANALOG_ANGLE_FIFTY_RATIO_24 == -tan(50 * DEG_TO_RADIAN) 
        and ANALOG_ANGLE_XAXIS_RATIO_13 == tan(20 * DEG_TO_RADIAN)
        and ANALOG_ANGLE_XAXIS_RATIO_24 == -tan(20 * DEG_TO_RADIAN)
        and ANALOG_ANGLE_YAXIS_RATIO_13 == tan((90 - 20) * DEG_TO_RADIAN) 
        and ANALOG_ANGLE_YAXIS_RATIO_24 == -tan((90 - 20) * DEG_TO_RADIAN)
        and ANALOG_SPECIAL_LEFT == -48
        and ANALOG_SPECIAL_RIGHT == 48
        and ANALOG_SPECIAL_DOWN == -44
        and ANALOG_SPECIAL_UP == 44 
        and ANALOG_SPOTDODGE_MIN_LEFT == -55 
        and ANALOG_SPOTDODGE_MIN_RIGHT == 55 
        and ANALOG_SPOTDODGE_MIN_VERTICAL == -56
        and TIMELIMIT_DOWNUP == 3 * MS_PER_FRAME
        and JUMP_TIME == 2 * MS_PER_FRAME 
        and TIMELIMIT_FRAME == MS_PER_FRAME  
        and TIMELIMIT_HALFFRAME == MS_PER_FRAME / 2
        and TIMELIMIT_DEBOUNCE == 6 
        and TIMELIMIT_SIMULTANEOUS == 4
        and TIMELIMIT_TAPSHUTOFF == 4 * MS_PER_FRAME
        and TIMELIMIT_BURSTSDI == 5.5 * MS_PER_FRAME
        and TIMELIMIT_TAP_PLUS == 8.5 * MS_PER_FRAME
        and TIMELIMIT_CARDIAG == 8 * MS_PER_FRAME
        and TIMELIMIT_PIVOTTILT == 8 * MS_PER_FRAME 
        and TIMELIMIT_PIVOTTILT_YDASH == 5 * MS_PER_FRAME
        and TIMESTALE_PIVOT_INPUTSEQUENCE == 15 * MS_PER_FRAME
        and FORCE_FTILT == 30
        and TIMESTALE_SDI_INPUTSEQUENCE == 8 * MS_PER_FRAME
        and FUZZ_1_00_PROBABILITY == 50) { 
        OutputDebug, % "testGameEngineConstants(): passed. all pseudo-constants have their values unchanged.`n"
    } else {
        OutputDebug, % "testGameEngineConstants(): failed.`n"
    }
}
