#Requires AutoHotkey v1.1

testFairboxConstants() {
    global
    if (P_RIGHTLEFT == 1 ; id: right to left empty pivot
        and P_LEFTRIGHT == 2 ; id: left to right pivot
        and U_YES == 1 ; id: uncrouch
        and ZONE_CENTER == 0 ; id: in the zone of analog stick neutral
        and ZONE_U == 1 ; 0b0000'0001
        and ZONE_D == 1<<1 ; 0b0000'0010
        and ZONE_L == 1<<2 ; 0b0000'0100
        and ZONE_R == 1<<3 ; 0b0000'1000
        and ZONE_DIR == ((1<<4) - 1) ; 0b0000'1111
        and BITS_SDI == ((1<<4) - 1) << 4 ; 0b1111'0000
        and BITS_SDI_QUARTERC == 1<<4 ; 0b0001'0000
        and BITS_SDI_TAP_CARD == 1<<5 ; 0b0010'0000
        and BITS_SDI_TAP_DIAG == 1<<6
        and BITS_SDI_TAP_CRDG == 1<<7
        and POP_CENTER == 0
        and POP_CARD == 1
        and POP_DIAG == 2
        and xComp == 1
        and yComp == 2) {
        OutputDebug, % "testFairboxConstants(): passed. all pseudo-constants have their values unchanged.`n"
    } else {
        OutputDebug, % "testFairboxConstants(): failed.`n"
    }
}
