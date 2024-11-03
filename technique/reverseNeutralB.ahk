#Requires AutoHotkey v1.1

getReverseNeutralBNerf(ByRef aX, ByRef aY) {
    global ANALOG_DEAD_MAX, global ANALOG_STICK_MIN, global ANALOG_STICK_MAX, 
    global ANALOG_SPECIAL_LEFT, global ANALOG_SPECIAL_RIGHT, global buttonB

    if (buttonB and Abs(aX) > ANALOG_DEAD_MAX and Abs(aY) <= ANALOG_DEAD_MAX) { ; out of x deadzone and in y deadzone
        if (aX < 0 and aX > ANALOG_SPECIAL_LEFT) { ; inside leftward neutral-B range
            return [ANALOG_STICK_MIN, 0]
        } else if (aX > 0 and aX < ANALOG_SPECIAL_RIGHT) { ; inside rightward neutral-B range
            return [ANALOG_STICK_MAX, 0]
        }
    }
    return [aX, aY]
}