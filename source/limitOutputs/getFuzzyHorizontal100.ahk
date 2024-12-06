#Requires AutoHotkey v1.1

/*  if you input [+/- 80, 0], that value may be passed to the game
    as [+/- 80, +/- 1] for as long as you hold the stick in the same place
*/
getFuzzyHorizontal100(outputX, outputY, historyX, historyY) {
    global ANALOG_STICK_MAX, global FUZZ_1_00_PROBABILITY
    ; early Returns ahead.

    if (outputY == 0 and Abs(outputX) >= ANALOG_STICK_MAX) {
        ; early Returns ahead.

        if (Abs(historyY) <= 1 and outputX == historyX) {
            return historyY
        }

        Random, ran100, 0, 99 ; spans 100%
        if (ran100 < FUZZ_1_00_PROBABILITY) {
            Random, yesNo, 0, 1
            return yesNo ? 1 : -1
        } 
        ; else
        return 0
    } 
    ; else 
    return outputY
}
