#Requires AutoHotkey v1.1

class outOfDeadzoneInfo {
    __New(boolIs, timestamp) {
        this.is := boolIs
        this.timestamp := timestamp
    }
}

class leftstickOutOfDeadzoneBase {

    class upBase {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        addedToQueue := {}
        queueTimestamp := {}
        saved := new outOfDeadzoneInfo(false, -1000)
        is(aY) {
            global ANALOG_DEAD_MAX
            return (aY > ANALOG_DEAD_MAX)
        }
    }
    
    class downBase {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        addedToQueue := {}
        queueTimestamp := {}
        saved := new outOfDeadzoneInfo(false, -1000)
        is(aY) {
            global ANALOG_DEAD_MIN
            return (aY < ANALOG_DEAD_MIN)
        }
    }    

    __New() {
        this.up := new this.upBase
        this.down := new this.downBase
    }
}

saveOutOfDeadzoneHistory(ByRef outOfDeadzone) {

    outOfDeadzone.up.saved := outOfDeadzone.up.unsaved
    ; empty memory of queued deadzone changes
    outOfDeadzone.up.addedToQueue := {}
    outOfDeadzone.up.queueTimestamp := {}

    outOfDeadzone.down.saved := outOfDeadzone.down.unsaved
    outOfDeadzone.down.addedToQueue := {}
    outOfDeadzone.down.queueTimestamp := {}

    return
}

getCurrentOutOfDeadzoneInfo(analogAxisValue, outOfDeadzoneDirection) {
    global currentTimeMS

    deadzoneStatus := outOfDeadzoneDirection.is(analogAxisValue)
    if !outOfDeadzoneDirection.addedToQueue[deadzoneStatus] {
        if (deadzoneStatus == outOfDeadzoneDirection.saved.is) {
            outOfDeadzoneDirection.queueTimestamp[deadzoneStatus] := outOfDeadzoneDirection.saved.timestamp
        } else {
            outOfDeadzoneDirection.queueTimestamp[deadzoneStatus] := currentTimeMS
        }
        outOfDeadzoneDirection.addedToQueue[deadzoneStatus] := true
    }
    
    return new outOfDeadzoneInfo(deadzoneStatus
    , outOfDeadzoneDirection.queueTimestamp[deadzoneStatus])   
}