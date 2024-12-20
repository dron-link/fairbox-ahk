#Requires AutoHotkey v1
#NoEnv
#MenuMaskKey vke8
#MaxHotkeysPerInterval 200
; optimizations from
; https://www.autohotkey.com/boards/viewtopic.php?t=6413
SetBatchLines, -1
SetKeyDelay, -1, -1
SendMode Input

#include <CvJoyInterface>

SetWorkingDir, %A_ScriptDir%

#include %A_LineFile%\..\analogZoneInfo\analogZoneInfo.ahk

#include %A_LineFile%\..\controls
#include, initializeHotkeys.ahk
#include, loadHotkeysIni.ahk

#include %A_LineFile%\..\coordinates\coordinates.ahk

#include %A_LineFile%\..\inputViewer
#include, constructInputViewerWindow.ahk ; globals
#include, showInputViewer.ahk
#include, updateInputViewerButton.ahk
#include, updateInputViewerEnabledControlsAlert.ahk

#include %A_LineFile%\..\limitOutputs\limitOutputs.ahk

#include %A_LineFile%\..\menu
#include, constructMainsTrayMenu.ahk
#include, mainIntoControlsWindow.ahk

#include %A_LineFile%\..\system
#include, fairboxConstants.ahk ; globals
#include, gameEngineConstants.ahk ; globals
#include, getDebugLegacy.ahk
#include, guiFont.ahk
#include, hotkeys.ahk ; globals
#include, keysModCAngleRole.ahk ; globals
#include, readIniFairboxLaunchMode.ahk
#include, resetAllButtons.ahk

#include %A_LineFile%\..\technique\technique.ahk

/*

DISCLAIMER
I, dron-link, AM NOT A DEVELOPER BY TRADE.
Other than due to a lack of alternatives, I made this with the hope that this script
contains any useful ideas for you if you're an experienced programmer that wants to
embark on a project like this.

contact info:
Discord
    Aiu     ; over at 20XX Discord server, specifically in #keyboard : https://discord.gg/KydHfzTbdG
; if the link doesnt work try searching for the 20XX invite https://b0xx.com/pages/more-info
GitHub
    https://github.com/dron-link

sdi, uncrouch, and pivot nerfs, and history saving adapted from CarVac 's work
https://github.com/CarVac/HayBox/blob/master/src/modes/MeleeLimits.cpp

  ---------------------

this project started as a proof of concept of how can we implement a variety of analog stick nerfs
in Autohotkey. since then it has evolved into something of an improvement over the finalized b0xx-ahk

everything is subject to modification and may not be present in the finalized version.
+++ i'm considering helping to make a faithful b0xx v4.1-like for keyboards in the future.

rough list of remaining tasks
- TODO write tests
- TODO create a Setup Help for first launch
- TODO disable all traytip messages option
- TODO increase hotkey control width option
- TODO restore default hotkeys button
- TODO somehow ensure that displayed hotkeys always reflect the real ones. i suggest a test
- TODO primitive input viewer, or graphic input viewer, possibly as a separate .exe app
- TODO b0xx example layout picture window? maybe not necessary if i do the graphic input viewer
- TODO add cx and cy entries to the output history, but for what specifically?
- TODO consider outputting 1.0 cardinals and 45° large diagonals past the analog circle?
- TODO implement SDI nerfs
- TODO use setTimer to lift nerfs without waiting for player input
    ¬ call updateAnalogStick and possibly lift pivot nerfs after 4 frames, 5 frames and 8 frames
    ¬ use setTimer to lift a 2f jump nerf 2 frames after it was forced (idea origin: CarVac HayBox)
- TODO implement coordinate target inconditional bans
- TODO make some in-game debug display by taking control of the c-stick and d-pad (idea taken from: CarVac/Haybox)

setTimer firing rate is apparently 15.6ms, don't expect much precision from it
(at least it's shorter than a game cube input polling interval), but I expect that most nerf lifts will be one frame late sometimes.
Maybe we can improve the script by increasing the polling frequency? solution using WinMM dll

*/
currentTimeMS := 0
isInputViewerOpen := false

; close the controls editor
DetectHiddenWindows, On
;    0x111 = WN_COMMAND code
;           65307 = exit code
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditor.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditor.exe
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditorDebug.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\fairboxControlsEditorDebug.exe
DetectHiddenWindows, Off

FileInstall, install\config.ini, % A_ScriptDir "\config.ini", 0 ; for when config.ini doesn't exist

enabledHotkeys := true
enabledGameControls := true
showWelcomeTray := true

readIniFairboxLaunchMode()

; load global UserSettings
IniRead, deleteFailingHotkey, config.ini, UserSettings, DeleteFailingHotkey
IniRead, secondIPCleaning, config.ini, UserSettings, 2ipCleaning

/*  i can't use the __New() metafunction or else this evaluates as "" uh????
    ps: now i reflected on my mistake: exiting __New() with a return. shoulda left it without that line
*/
target := new targetCoordinateTreeWithCBinds
target.loadCoordinates()

constructMainsTrayMenu() ; puts the custom menu items in the tray

loadHotkeysIni()

; Create an object from vJoy Interface Class.
vJoyInterface := new CvJoyInterface()

; Was vJoy installed and the DLL Loaded?
if !vJoyInterface.vJoyEnabled() {
    ; Show log of what happened
    Msgbox % vJoyInterface.LoadLibraryLog
    ExitApp
}

myStick := vJoyInterface.Devices[1]

; for 2ip and opposing horizontals modifier lockout
mostRecentVerticalAnalog := ""
mostRecentHorizontalAnalog := ""

mostRecentVerticalC := ""
mostRecentHorizontalC := ""

opposingHorizontalsModLockout := false

/*  Debug info
    this is how you read its values:
    L-Q-X means
    airdodge quadrant modX input
    F-Y-U means
    fireFox/extended modY c-up input

    L airdodge   H horizontal   X modX  U c-up
    N no shield  Q quadrant     Y modY  L c-left
                 Y vertical             D c-down
                 F fireFox/ext          R c-right
                 O [0, 0]
*/
; Debug info
lastCoordTrace := ""

if enabledHotkeys {
    ; initial undefined vjoy behavior - this could fix the bug: reset all buttons on startup
    resetAllButtons()
}

if showWelcomeTray {
    ; Alert User that script has started
    TrayTip, % "fairbox", % "Script Started", 3, 0
}

if !enabledHotkeys {
    TrayTip, % "fairbox", % "ATTENTION. enabledHotkeys: " . (enabledHotkeys? "true" : "false"), 3, 0
}

if inputViewerOnLaunch {
    showInputViewer()
}

Critical
initializeHotkeys()

return ; end of autoexecute

/*  check what directions, modifiers and buttons we should listen to,
    based on things like opposite cardinal buttons presses, D-Pad mode etc
*/
up() {
    global
    if secondIPCleaning {
        return buttonUp and mostRecentVerticalAnalog = "U"
    } ; else
    return buttonUp and !buttonDown ; neutral SOCD
}

down() {
    global
    if secondIPCleaning {
        return buttonDown and mostRecentVerticalAnalog = "D"
    } ; else
    return buttonDown and !buttonUp ; neutral SOCD
}

left() {
    global
    if secondIPCleaning {
        return buttonLeft and mostRecentHorizontalAnalog = "L"
    } ; else
    return buttonLeft and !buttonRight ; neutral SOCD
}

right() {
    global
    if secondIPCleaning {
        return buttonRight and mostRecentHorizontalAnalog = "R"
    } ; else
    return buttonRight and !buttonLeft ; neutral SOCD
}

cUp() {
    global
    if secondIPCleaning {
        return buttonCUp and mostRecentVerticalC = "U" and !bothMods()
    } ; else
    return buttonCUp and !buttonCDown and !bothMods() ; neutral SOCD
}

cDown() {
    global
    if secondIPCleaning {
        return buttonCDown and mostRecentVerticalC = "D" and !bothMods()
    } ; else
    return buttonCDown and !buttonCUp and !bothMods() ; neutral SOCD
}

cLeft() {
    global
    if secondIPCleaning {
        return buttonCLeft and mostRecentHorizontalC = "L" and !bothMods()
    } ; else
    return buttonCLeft and !buttonCRight and !bothMods() ; neutral SOCD
}

cRight() {
    global
    if secondIPCleaning {
        return buttonCRight and mostRecentHorizontalC = "R" and !bothMods()
    } ; else
    return buttonCRight and !buttonCLeft and !bothMods() ; neutral SOCD
}

modX() {
    global
    /*  deactivate if either:
        - modY is also physically held
        - opposingHorizontalsModLockout: both left and right are held (and were pressed after modX)
          while neither up or down is active
    */
    if secondIPCleaning {
        return buttonModX and !buttonModY and (!opposingHorizontalsModLockout or anyVert())
    } ; else
    return buttonModX and !buttonModY ; the mod lockout is incompatible with NSOCD
}

modY() {
    global
    return buttonModY and !buttonModX
}

; The following are some helpers
anyVert() {
    return up() or down()
}

anyHoriz() {
    return left() or right()
}

anyQuadrant() {
    return anyVert() and anyHoriz()
}

anyMod() {
    return modX() or modY()
}

bothMods() {
    global
    return buttonModX and buttonModY
}

anyShield() {
    global
    return buttonL or buttonR or buttonLightShield or buttonMidShield
}

anyVertC() {
    return cUp() or cDown()
}

anyHorizC() {
    return cLeft() or cRight()
}

anyC() {
    return cUp() or cDown() or cLeft() or cRight()
}

; /// update analog axes

/*  This function is tasked to update the position on the analog stick
    based on the currently seen cardinal directions and modifiers
*/
updateAnalogStick() {
    global xComp, global yComp, global currentTimeMS
    currentTimeMS := A_TickCount
    coords := getAnalogCoords()
    finalOutput := getOutputLimited(coords[xComp], coords[yComp])
    setAnalogStick([finalOutput.x, finalOutput.y])
    return
}

; Send VJoy-formatted coordinates to vjoy interface
setAnalogStick(finalCoords) {
    global xComp, global yComp, global myStick
    convertedCoords := convertIntegerToVJoy(finalCoords)
    myStick.SetAxisByIndex(convertedCoords[xComp], 1) ; control stick (leftstick, analog stick) X
    myStick.SetAxisByIndex(convertedCoords[yComp], 2) ; same, Y
    return
}

/*  This function is tasked to update the position on the c-stick
    based on the currently seen cardinal directions and modifiers
*/
updateCStick() {
    setCStick(getCStickCoords())
    return
}

setCStick(cStickCoords) {
    global xComp, global yComp, global myStick
    convertedCoords := convertIntegerToVJoy(cStickCoords)
    myStick.SetAxisByIndex(convertedCoords[xComp], 4) ; c-stick (rightstick) X
    myStick.SetAxisByIndex(convertedCoords[yComp], 5) ; same, Y
    return
}

/*  Converts coordinates from gamecube controller integers (the fighting game engine limits the
    coordinates to a circle that's centered in 0,0 and extends 80 units into all directions)
    to vJoy values (whose full range is 0 to 32767 and is centered around 16384,16384).
*/
convertIntegerToVJoy(finalCoords) {
    global xComp, global yComp
    convertedCoords := []
    convertedCoords[xComp] := 16384 + Round(128.63 * finalCoords[xComp])
    convertedCoords[yComp] := 16301 - Round(128.38 * finalCoords[yComp])
    return convertedCoords
}

setAnalogR(value) {
    global myStick
    /*  vJoy/Dolphin does something strange with rounding analog shoulder presses. In general,
        it seems to want to round to odd values, so
            16384 => 0.00000 (0)   <-- actual value used for 0
            19532 => 0.35000 (49)  <-- actual value used for 49
            22424 => 0.67875 (95)  <-- actual value used for 94
            22384 => 0.67875 (95)
            22383 => 0.66429 (93)
        But, *extremely* inconsistently, I have seen the following:
            22464 => 0.67143 (94)
        Which no sense and I can't reproduce.
    */
    Return myStick.SetAxisByIndex(16384 * (1 + value / 255), 3) ; 3 is the analog shoulder press axis
}

; /// hotkeys, and the subroutines that handle hotkeys

; timer labels
uncrouchNerfLiftTimerLabel:
pivotYDashNerfLiftTimerLabel:
pivotNerfLiftTimerLabel:
    updateAnalogStick()
    Critical, Off
    Sleep, -1
return

inputViewerWindowGuiClose:
    Gui, inputViewerWindow:Destroy
    isInputViewerOpen := false
return

; GAME CONTROLS Labels ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Control Stick (Leftstick)
buttonUpLabel:
    if !buttonUp {
        buttonUp := true, mostRecentVerticalAnalog := "U", updateAnalogStick(), updateCStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonUp")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonUpLabel_UP:
    buttonUp := false, updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonUp")
return

buttonDownLabel:
    if !buttonDown {
        buttonDown := true, mostRecentVerticalAnalog := "D", updateAnalogStick(), updateCStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonDown")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonDownLabel_UP:
    buttonDown := false, updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonDown")
return

buttonLeftLabel:
    if !buttonLeft {
        if buttonRight {
            opposingHorizontalsModLockout := true
        }
        buttonLeft := true, mostRecentHorizontalAnalog := "L", updateAnalogStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonLeft")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonLeftLabel_UP:
    buttonLeft := false, opposingHorizontalsModLockout := false, updateAnalogStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonLeft")
return

buttonRightLabel:
    if !buttonRight {
        if buttonLeft {
            opposingHorizontalsModLockout := true
        }
        buttonRight := true, mostRecentHorizontalAnalog := "R", updateAnalogStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonRight")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonRightLabel_UP:
    buttonRight := false, opposingHorizontalsModLockout := false, updateAnalogStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonRight")
return

; Dedicated modifiers
buttonModXLabel:
    /*  opposingHorizontalsModLockout is order dependant,
        it only applies if modifier isn't pressed after horizontals
    */
    if !buttonModX {
        opposingHorizontalsModLockout := false
        buttonModX := true, updateAnalogStick(), updateCStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonModX")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonModXLabel_UP:
    buttonModX := false , opposingHorizontalsModLockout := false, updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonModX")
return

buttonModYLabel:
    if !buttonModY {
        buttonModY := true, updateAnalogStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonModY")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonModYLabel_UP:
    buttonModY := false, updateAnalogStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonModY")
return

;
buttonALabel:
    if !buttonA {
        buttonA := true, myStick.SetBtn(1,5), updateAnalogStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonA")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonALabel_UP:
    buttonA := false, myStick.SetBtn(0,5)
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonA")
return

buttonBLabel:
    if !buttonB {
        buttonB := true, myStick.SetBtn(1, 4), updateAnalogStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonB")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonBLabel_UP:
    buttonB := false, myStick.SetBtn(0, 4), updateAnalogStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonB")
return

buttonLLabel:
    if !buttonL {
        buttonL := true, myStick.SetBtn(1, 1), updateAnalogStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonL")
    } else {
        Critical Off
        Sleep -1
    }

return

buttonLLabel_UP:
    buttonL := false, myStick.SetBtn(0, 1), updateAnalogStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonL")
return

buttonRLabel:
    if !buttonR {
        buttonR := true, myStick.SetBtn(1, 3), updateAnalogStick()
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonR")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonRLabel_UP:
    buttonR := false, myStick.SetBtn(0, 3), updateAnalogStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonR")
return

buttonXLabel:
    if !buttonX {
        buttonX := true, myStick.SetBtn(1, 6)
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonX")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonXLabel_UP:
    buttonX := false, myStick.SetBtn(0, 6)
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonX")
return

buttonYLabel:
    if !buttonY {
        buttonY := true, myStick.SetBtn(1, 2)
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonY")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonYLabel_UP:
    buttonY := false, myStick.SetBtn(0, 2)
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonY")
return

buttonZLabel:
    if !buttonZ {
        buttonZ := true, myStick.SetBtn(1, 7)
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonZ")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonZLabel_UP:
    buttonZ := false, myStick.SetBtn(0, 7)
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonZ")
return

; C-stick (Rightstick) buttons
buttonCUpLabel:
    if !buttonCUp {
        buttonCUp := true
        if bothMods() {
            ; Pressing ModX and ModY simultaneously changes C buttons to D pad
            myStick.SetBtn(1, 9)
        } else {
            mostRecentVerticalC := "U", updateAnalogStick(), updateCStick()
        }
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonCUp")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonCUpLabel_UP:
    buttonCUp := false, myStick.SetBtn(0, 9), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonCUp")
return

buttonCDownLabel:
    if !buttonCDown {
        buttonCDown := true
        if bothMods() {
            ; Pressing ModX and ModY simultaneously changes C buttons to D pad
            myStick.SetBtn(1, 11)
        } else {
            mostRecentVerticalC := "D", updateAnalogStick(), updateCStick()
        }
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonCDown")
    } else {
        Critical Off
        Sleep -1
    }

return

buttonCDownLabel_UP:
    buttonCDown := false, myStick.SetBtn(0, 11), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonCDown")
return

buttonCLeftLabel:
    if !buttonCLeft {
        buttonCLeft := true
        if bothMods() {
            ; Pressing ModX and ModY simultaneously changes C buttons to D pad
            myStick.SetBtn(1, 10)
        } else {
            mostRecentHorizontalC := "L", updateAnalogStick(), updateCStick()
        }
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonCLeft")
    } else {
        Critical Off
        Sleep -1
    }

return

buttonCLeftLabel_UP:
    buttonCLeft := false, myStick.SetBtn(0, 10), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonCLeft")
return

buttonCRightLabel:
    if !buttonCRight {
        buttonCRight := true
        if bothMods() {
            ; Pressing ModX and ModY simultaneously changes C buttons to D pad
            myStick.SetBtn(1, 12)
        } else {
            mostRecentHorizontalC := "R", updateAnalogStick(), updateCStick()
        }
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonCRight")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonCRightLabel_UP:
    buttonCRight := false, myStick.SetBtn(0, 12), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonCRight")
return

; Analog Shielding
buttonLightShieldLabel:
    if !buttonLightShield {
        buttonLightShield := true, setAnalogR(49)
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonLightShield")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonLightShieldLabel_UP:
    buttonLightShield := false, setAnalogR(0)
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonLightShield")
return

buttonMidShieldLabel:
    if !buttonMidShield {
        buttonMidShield := true, setAnalogR(94)
        Critical Off
        Sleep -1
        updateInputViewerButton("buttonMidShield")
    } else {
        Critical Off
        Sleep -1
    }
return

buttonMidShieldLabel_UP:
    buttonMidShield := false, setAnalogR(0)
    Critical Off
    Sleep -1
    updateInputViewerButton("buttonMidShield")
Return

;
buttonStartLabel:
    if !buttonStart {
        buttonStart := true, myStick.SetBtn(1, 8)
        updateInputViewerButton("buttonStart")
    }
    Critical Off
    Sleep -1
return

buttonStartLabel_UP:
    buttonStart := false, myStick.SetBtn(0, 8)
    updateInputViewerButton("buttonStart")
    Critical Off
    Sleep -1
return

; D-pad
buttonDPadUpLabel:
    if !buttonDPadUp {
        buttonDPadUp := true, myStick.SetBtn(1, 9)
    }
    Critical Off
    Sleep -1
return

buttonDPadUpLabel_UP:
    buttonDPadUp := false, myStick.SetBtn(0, 9)
    Critical Off
    Sleep -1
return

buttonDPadDownLabel:
    if !buttonDPadDown {
        buttonDPadDown := true, myStick.SetBtn(1, 11)
    }
    Critical Off
    Sleep -1
return

buttonDPadDownLabel_UP:
    buttonDPadDown := false, myStick.SetBtn(0, 11)
    Critical Off
    Sleep -1
return

buttonDPadLeftLabel:
    if !buttonDPadLeft {
        buttonDPadLeft := true, myStick.SetBtn(1, 10)
    }
    Critical Off
    Sleep -1
return

buttonDPadLeftLabel_UP:
    buttonDPadLeft := false, myStick.SetBtn(0, 10)
    Critical Off
    Sleep -1
return

buttonDPadRightLabel:
    if !buttonDPadRight {
        buttonDPadRight := true, myStick.SetBtn(1, 12)
    }
    Critical Off
    Sleep -1
return

buttonDPadRightLabel_UP:
    buttonDPadRight := false, myStick.SetBtn(0, 12)
    Critical Off
    Sleep -1
return

;
legacyDebugKeyLabel:
    Msgbox, % getDebug()
    Critical Off
return

legacyDebugKeyLabel_UP:
return

; Input On/Off
inputToggleKeyLabel:
    resetAllButtons()
    enabledGameControls := !enabledGameControls
    if isInputViewerOpen {
        updateInputViewerEnabledControlsAlert(enabledGameControls)
    }
    Critical Off
return

inputToggleKeyLabel_UP:
return

#If enabledGameControls ; because an existing directive was needed to use Hotkey, If, enabledGameControls
#If