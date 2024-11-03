#Requires AutoHotkey v1.1

class leftstickOutOfDeadzoneBase {
    class upBase {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        queue := {}
        saved := new outOfDeadzoneInfo(false, -1000)
        isOut(aY) {
            global ANALOG_DEAD_MAX
            return (aY > ANALOG_DEAD_MAX)
        }
    }
    
    class downBase {
        unsaved := new outOfDeadzoneInfo(false, -1000)
        queue := {}
        saved := new outOfDeadzoneInfo(false, -1000)
        isOut(aY) {
            global ANALOG_DEAD_MIN
            return (aY < ANALOG_DEAD_MIN)
        }
    }    

    __New() {
        this.up := new this.upBase
        this.down := new this.downBase
    }

    saveHistory() {
        this.up.saved := this.up.unsaved, this.up.queue := {}
        this.down.saved := this.down.unsaved, this.down.queue := {}
        return
    }

    storeInfoBeforeMultipressEnds(aY) {
        return storeOutOfDeadzoneInfoBeforeMultipressEnds(aY, this)
    }
}

