#Requires AutoHotkey v1.1

getFuzzyHorizontal100(outputX, outputY, historyX, historyY) {
    /*  if you input [+/- 80, 0], that value may be passed to the game
        as [+/- 80, +/- 1] for as long as you hold the stick in the same place
    */
    global ANALOG_STICK_MAX, global ANALOG_STEP, global FUZZ_1_00_PROBABILITY

    if(Abs(outputY) <= ANALOG_STEP and Abs(outputX) == ANALOG_STICK_MAX) {
        if (Abs(historyY) <= ANALOG_STEP and outputX == historyX) {
            return historyY
        } else {
            Random, ran100, 0, 99 ; spans 100%
            if (ran100 < FUZZ_1_00_PROBABILITY) {
                result := Mod(ran100, 2) ? ANALOG_STEP : (-ANALOG_STEP)
                return result
            } else {
                return 0
            }
        }
    } else {
        return outputY
    }
}
