#Requires AutoHotkey v1.1

detectNonIntegers(aX, aY) {
    if aX is not Integer
        OutputDebug, detectNonIntegers() problem . coordinate x type is not integer`n
    if aY is not Integer
        OutputDebug, detectNonIntegers() problem . coordinate y type is not integer`n
    return
}  

testTrimToCircle() {
    global

    Loop, 256 {
        testX := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
        Loop, 256 {
            testY := ANALOG_STICK_OFFSETCANCEL + A_Index - 1
            testCoordinates := trimToCircle(testX, testY)
            if (testCoordinates[1] != testX or testCoordinates[2] != testY) {
                if (testCoordinates[1]**2 + testCoordinates[2]**2 > ANALOG_STICK_MAX**2) {
                    OutputDebug, % "trimToCircle overshoot " 
                    . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
                }
                if (testCoordinates[1]**2 + testCoordinates[2]**2 <= 56**2 + 55**2) {
                    OutputDebug, % "trimToCircle undershoot " 
                    . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
                }
            } else if (testCoordinates[1]**2 + testCoordinates[2]**2 > ANALOG_STICK_MAX**2) {
                OutputDebug, % "trimToCircle ignored or didn't change coord out of circle " 
                . testX " " testY "`n" testCoordinates[1] " " testCoordinates[2] "`n"
            }
            
        }
    }
    OutputDebug, % "trimToCircle test concluded"

    return
}

calibrationTest() {
    global
  
    myStick.SetAxisByIndex(16384, 1)
    myStick.SetAxisByIndex(16384, 2)
    OutputDebug, % "calibrationTest begin`n"
    MsgBox, % "calibrationTest begin?"
    Loop, 50 {
      myStick.SetAxisByIndex(16384, 1)
      myStick.SetAxisByIndex(16384, 2)
      Sleep, 15
    }
  
    /*
    startIntended := 0
    endIntended := -80
    sleepTime := 400
    rangeStepper(yComp, startIntended, endIntended, sleepTime)
    */
    /*
    startStick := 129-64
    endStick := 129-64
    sleepTime := 3000
    rangeCrawler(YComp, startStick, endStick, sleepTime)
    */
  
    OutputDebug, % "calibrationTest end`n"
    Sleep, 1000
    myStick.SetAxisByIndex(16384, 1)
    myStick.SetAxisByIndex(16384, 2)
    OutputDebug, % "stick reset`n"
    ExitApp
    
    /*
      findings: 
      ax1+b=y1
      ax2+b=y2

      a(x2-x1)=y2-y1
      a=(y2-y1)/(x2-x1)

      b=y1-ax1

      
      
    */
    return
  }


rangeStepper(axisIndex, startStep, endStep, sleepTime) {
    global
    OutputDebug, % "rangeStepper`n"
    stepTotal := Abs(endStep - startStep) + 1

    stepCurrent := startStep
    Loop, % stepTotal {
        if (axisIndex == xComp) {
            myStick.SetAxisByIndex(16384 + Round(128.63 * stepCurrent), xComp)
        } else if (axisIndex == yComp) {
            myStick.SetAxisByIndex(16384 - Round(128.38 * stepCurrent) - 83, yComp)
        }
        OutputDebug, % stepCurrent "`n"
        if (endStep >= startStep) {
            stepCurrent += 1
        } else if (endStep < startStep) {
            stepCurrent -= 1
        }
        Sleep, sleepTime
    }
    return
}

rangeCrawler(axisIndex, startStick, endStick, sleepTime) {
    global
    OutputDebug, % "rangeCrawler`n"
    stickTotal := Abs(endStick - startStick) + 1
    stickCurrent := startStick
    Loop, % stickTotal {
        myStick.SetAxisByIndex(16384 + stickCurrent, axisIndex)
        OutputDebug, % stickCurrent "`n"
        if (endStick >= startStick) {
            stickCurrent += 1
        } else if (endStick < startStick) {
            stickCurrent -= 1
        }
        Sleep, sleepTime
    }
    return
}

