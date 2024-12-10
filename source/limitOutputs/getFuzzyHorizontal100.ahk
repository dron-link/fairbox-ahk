#Requires AutoHotkey v1

/*  if you input [+/- 80, 0], that value may be passed to the game
    as [+/- 80, +/- 1] for as long as you hold the stick in the same place
*/
getFuzzyHorizontal100(outputX, outputY, historyX, historyY) {
    global ANALOG_STICK_MAX, global FUZZ_1_00_PROBABILITY
    ; early Returns ahead.

    if !(outputY == 0 and Abs(outputX) >= ANALOG_STICK_MAX) {
        return outputY
    }

    if (Abs(historyY) <= 1 and outputX == historyX) {
        return historyY
    }

    Random, random100, 0, 99 ; spans 100%
    ; the chance that this evaluates to true is FUZZ_1_00_PROBABILITY.
    ; As FUZZ_1_00_PROBABILITY gets closer to 100% this will be true more frequently
    if (random100 < FUZZ_1_00_PROBABILITY) { 
        Random, yesNo, 0, 1
        return yesNo ? 1 : -1
    }

    ; else
    return 0
}
