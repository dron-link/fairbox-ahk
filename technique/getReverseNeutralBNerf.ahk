#Requires AutoHotkey v1.1

getReverseNeutralBNerf(coords) {
    global ANALOG_DEAD_MIN, ANALOG_DEAD_MAX, global ANALOG_STICK_MIN, global ANALOG_STICK_MAX, 
    global ANALOG_SPECIAL_LEFT, global ANALOG_SPECIAL_RIGHT, global xComp, global yComp, global buttonB
    aX := coords[xComp], aY := coords[yComp]

    if (buttonB and Abs(aY) <= ANALOG_DEAD_MAX) { ; in y deadzone
        if (ANALOG_SPECIAL_LEFT < aX and aX < ANALOG_DEAD_MIN) { ; inside leftward neutral-B range
            return [ANALOG_STICK_MIN, 0]
        } else if (ANALOG_DEAD_MAX < aX and aX < ANALOG_SPECIAL_RIGHT) { ; inside rightward neutral-B range
            return [ANALOG_STICK_MAX, 0]
        }
    }
    
    return coords
}