#Requires AutoHotkey v1.1.37
#Warn All, OutputDebug
#SingleInstance force
#NoEnv
#include <CvJoyInterface>
SetBatchLines, -1
#MenuMaskKey vkE8 ; virtual key code that is unused by windows
#include %A_ScriptDir%
currentTimeMS := 0
#include, controls\hkIniAutogenerator.ahk 
#include, system\fairboxConstants.ahk
#include, system\gameEngineConstants.ahk
#include, system\infoEntryClasses.ahk
#include, menu\menu.ahk
#include, coordinates\targetObjStructure.ahk
#include, coordinates\targetCoordinateValues.ahk ; you can customize the coordinates in this file
#include, coordinates\targetFormatting.ahk
#include, limitOutputs\outputClass.ahk
#include, limitOutputs\limitOutputs.ahk
#include, limitOutputs\getFuzzyHorizontal100.ahk
#include, analogZoneInfo\outOfDeadzone.ahk
#include, analogZoneInfo\outOfDeadzoneClass.ahk
#include, analogZoneInfo\crouchZone.ahk
#include, analogZoneInfo\crouchZoneClass.ahk
#include, analogZoneInfo\dashZone.ahk 
#include, analogZoneInfo\dashZoneClass.ahk
#include, technique\reverseNeutralB.ahk
#include, technique\nerfBasedOnHistory.ahk
#include, technique\uncrouch.ahk
#include, technique\uncrouchClass.ahk
#include, technique\pivot\pivot.ahk
#include, technique\pivot\pivotClass.ahk
#include, technique\pivot\detectPivot.ahk
#include, technique\pivot\getPivotLockoutNerfedCoords.ahk
#include, controls\hotkeyHelpers.ahk
#include, controls\setControlsAndConstructGui.ahk
#include, controls\goFunctionsUponInteraction.ahk
#include, controls\hotkeyValidation.ahk
#include, controls\editControlsInstructions.ahk
#include, controls\hotkeyControlHasFocus.ahk
#include, test\miscTestingTools.ahk
; #include, test\calibrationTest.ahk
#include, test\testNerfsByHand.ahk

/*  

DISCLAIMER
I (dron-link) AM NOT A DEVELOPER BY TRADE.
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
 - TODO custom IfWinActive for users to make the hotkeys only work when the emulator window is focused 
 - TODO reformat c-stick coordinates, make them into integers instead of floats
 - TODO that popup message boxes should be owned by the window that the user invoked them from
 - TODO disable all traytip messages option
 - TODO increase hotkey control width option
 - TODO restore default hotkeys button
 - TODO check that displayed hotkeys always reflect the real ones
 - TODO primitive input viewer, or graphic input viewer, as a separate .exe app
 - TODO b0xx example layout picture window? maybe not necessary if i do the graphic input viewer
 - TODO create a ReloadAndShowWindowAgain
 - TODO add cx and cy entries to the output history
 - TODO consider outputting 1.0 cardinals and 45° large diagonals past the analog circle?
 - TODO implement SDI nerfs
 - TODO use setTimer to lift nerfs without waiting for player input
    ¬ call updateAnalogStick and possibly lift pivot nerfs after 4 frames, 5 frames and 8 frames
    ¬ use setTimer to lift a 2f jump nerf 2 frames after it was forced (idea origin: CarVac HayBox)
 - TODO implement coordinate target inconditional bans
 - TODO write tests
 - TODO make some in-game debug display by taking control of the c-stick and d-pad (idea taken from: CarVac/Haybox)
 - TODO make a debug mode, debugACertainProcess? outputDebug, % expression

setTimer firing rate is apparently 15.6ms, don't expect much precision from it
(at least it's shorter than a game cube input polling interval), but I expect that most nerf lifts will be one frame late sometimes.
Maybe we can improve the script by increasing the polling frequency? solution using WinMM dll

*/

hkIniAutoGenerator() ; create hotkeys.ini if missing

target := new targetCoordinateTree
target.loadCoordinates()
target.formatCoordinates()
; reads c-stick-angle-bindings.ini and assigns coordinates according to its contents
target.bindAnglesToCStick()

enabledHotkeys := true
; configure at testingTools.ahk, then set this parameter true. to test timing lockout nerfs
testNerfsByHand(false) 

guiFontDefault(windowName) { ; next Gui,Add or GuiControl,Font commands will have this font in their text when called
    Gui, % windowName ":Font", s8 cDefault norm, Tahoma
    return
}

guiFontContent(windowName) { ; next Gui,Add or GuiControl,Font commands will have this font in their text when called
    Gui, % windowName ":Font", s10 cDefault norm, Arial
    return
}

trayAddEditControls() ; creates the Edit Controls option in the tray

for i in hotkeys {
    ; ### for hotkey activation keys, and gui hotkey controls. create the global variables associated to:
    ; button name,       hotkey control,  hotkeys.ini values, special bind checkbox, Prev.Def.B. checkbox
    gameBtName%i% := "", HK%i% := "",     savedHK%i% := "",   isSpecialKey%i% := "", preventBehavior%i% := ""
}

descriptionWidth := 115 ; width of the hotkey control boxes of the Edit Controls Window
setControlsAndConstructGui()  ; adopt saved hotkeys and initialize Edit Controls Window. 

;----------Start Hotkey Handling-----------

; Create an object from vJoy Interface Class.
vJoyInterface := new CvJoyInterface()

; Was vJoy installed and the DLL Loaded?
if (!vJoyInterface.vJoyEnabled()) {
    ; Show log of what happened
    Msgbox % vJoyInterface.LoadLibraryLog
    ExitApp
}

myStick := vJoyInterface.Devices[1]

; Alert User that script has started
TrayTip, % "fairbox", % "Script Started", 3, 0

; state variables
; if true, keyboard key is pressed
buttonUp := false
buttonDown := false
buttonLeft := false
buttonRight := false

buttonModX := false
buttonModY := false

buttonA := false
buttonB := false
buttonL := false
buttonR := false
buttonX := false
buttonY := false
buttonZ := false

buttonCUp := false
buttonCDown := false
buttonCLeft := false
buttonCRight := false

buttonLightShield := false
buttonMidShield := false

buttonStart := false

buttonDPadUp := false
buttonDPadDown := false
buttonDPadLeft := false
buttonDPadRight := false


; strings for when press order matters
mostRecentVertical := "" ; this pair of variables went unused because of neutral SOCD
mostRecentHorizontal := ""

mostRecentVerticalC := "" ; this pair of variables went unused because of neutral SOCD
mostRecentHorizontalC := ""

simultaneousHorizontalModifierLockout := false ; this variable went unused because of neutral SOCD

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

; arbitrary vjoy initial status bug fix: reset all buttons on startup
if enabledHotkeys {
    for index in hotkeys {
        gosub Label%index%_UP
    }
}

/*  ////////////////////////////////
    check what directions, modifiers and buttons we should listen to,
    based on things like opposite cardinal direction modes, D-Pad mode etc
*/
up() {
    global
    return buttonUp and not buttonDown ; here is the neutral SOCD implementation
}

down() {
    global
    return buttonDown and not buttonUp ; here
}

left() {
    global
    return buttonLeft and not buttonRight ; here
}

right() {
    global
    return buttonRight and not buttonLeft ; here
}

cUp() {
    global
    return buttonCUp and not buttonCDown and not bothMods() ; here...
}

cDown() {
    global
    return buttonCDown and not buttonCUp and not bothMods()
}

cLeft() {
    global
    return buttonCLeft and not buttonCRight and not bothMods()
}

cRight() {
    global
    return buttonCRight and not buttonCLeft and not bothMods() ; ... up to here
}

modX() {
    global
    /*  deactivate if either:
        - modY is also held
        - both left and right are held (and were pressed after modX) while neither up or down is active
        this last bullet point won't carry into the new code because of NSOCD
    */
    return buttonModX and not buttonModY
}

modY() {
    global
    return buttonModY and not buttonModX
}

anyVert() {
    global
    return up() or down()
}

anyHoriz() {
    global
    return left() or right()
}

anyQuadrant() {
    global
    return anyVert() and anyHoriz()
}

anyMod() {
    global
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
    global
    return cUp() or cDown()
}

anyHorizC() {
    global
    return cLeft() or cRight()
}

anyC() {
    global
    return cUp() or cDown() or cLeft() or cRight()
}

; ///////////// Search for the analog stick coordinates that our controller asked for
getAnalogCoords() {
    global buttonB
    if (anyShield()) {
        quadrantICoords := getAnalogCoordsAirdodge()
    } else if (anyMod() and anyQuadrant() and (anyC() or buttonB)) {
        quadrantICoords := getAnalogCoordsFirefox()
    } else {
        quadrantICoords := getAnalogCoordsWithNoShield()
    }

    return reflectCoords(quadrantICoords)
}

getAnalogCoordsWithNoShield() {
    global
    if (!anyVert() and !anyHoriz()) {
        lastCoordTrace := "N-O"
        return new target.normal.origin
    } else if (anyQuadrant()) {
        if (modX()) {
            lastCoordTrace := "N-Q-X"
            return new target.normal.quadrantModX
        } else if (modY()) {
            lastCoordTrace := "N-Q-Y"
            return new target.normal.quadrantModY
        } else {
            lastCoordTrace := "N-Q"
            return new target.normal.quadrant
        }
    } else if (anyVert()) {
        if (modX()) {
            lastCoordTrace := "N-V-X"
            return new target.normal.verticalModX
        } else if (modY()) {
            lastCoordTrace := "N-V-Y"
            return new target.normal.verticalModY
        } else {
            lastCoordTrace := "N-V"
            return new target.normal.vertical
        }
    } else { ; if (anyHoriz())
        if (modX()) {
            lastCoordTrace := "N-H-X"
            return new target.normal.horizontalModX
        } else if (modY()) {
            lastCoordTrace := "N-H-Y"
            return new target.normal.horizontalModY
        } else {
            lastCoordTrace := "N-H"
            return new target.normal.horizontal
        }
    }
}

getAnalogCoordsAirdodge() {
    global
    if (!anyVert() and !anyHoriz()) {
        lastCoordTrace := "L-O"
        return new target.normal.origin
    } else if (anyQuadrant()) {
        if (modX()) {
            lastCoordTrace := "L-Q-X"
            return new target.airdodge.quadrantModX
        } else if (modY()) {
            lastCoordTrace := "L-Q-Y"
            return up() ? new target.airdodge.quadrant12ModY : new target.airdodge.quadrant34ModY
        } else {
            lastCoordTrace := "L-Q"
            return up() ? new target.airdodge.quadrant12 : new target.airdodge.quadrant34
        }
    } else if (anyVert()) {
        if (modX()) {
            lastCoordTrace := "L-V-X"
            return new target.airdodge.verticalModX
        } else if (modY()) {
            lastCoordTrace := "L-V-Y"
            return new target.airdodge.verticalModY
        } else {
            lastCoordTrace := "L-V"
            return new target.airdodge.vertical
        }
    } else { ; if (anyHoriz())
        if (modX()) {
            lastCoordTrace := "L-H-X"
            return new target.airdodge.horizontalModX
        } else if (modY()) {
            lastCoordTrace := "L-H-Y"
            return new target.airdodge.horizontalModY
        } else {
            lastCoordTrace := "L-H"
            return new target.airdodge.horizontal
        }
    }
}

getAnalogCoordsFirefox() {
    global
    if (modX()) {
        if (cUp()) {
            lastCoordTrace := "F-X-U"
            return buttonB ? new target.extendedB.modXCUp : new target.fireFox.modXCUp
        } else if (cDown()) {
            lastCoordTrace := "F-X-D"
            return buttonB ? new target.extendedB.modXCDown : new target.fireFox.modXCDown
        } else if (cLeft()) {
            lastCoordTrace := "F-X-L"
            return buttonB ? new target.extendedB.modXCLeft : new target.fireFox.modXCLeft
        } else if (cRight()) {
            lastCoordTrace := "F-X-R"
            return buttonB ? new target.extendedB.modXCRight : new target.fireFox.modXCRight
        } else {
            lastCoordTrace := "F-X"
            ; if buttonB
            return new target.extendedB.modX
        }
    } else if (modY()) {
        if (cUp()) {
            lastCoordTrace := "F-Y-U"
            return buttonB ? new target.extendedB.modYCUp : new target.fireFox.modYCUp
        } else if (cDown()) {
            lastCoordTrace := "F-Y-D"
            return buttonB ? new target.extendedB.modYCDown : new target.fireFox.modYCDown
        } else if (cLeft()) {
            lastCoordTrace := "F-Y-L"
            return buttonB ? new target.extendedB.modYCLeft : new target.fireFox.modYCLeft
        } else if (cRight()) {
            lastCoordTrace := "F-Y-R"
            return buttonB ? new target.extendedB.modYCRight : new target.fireFox.modYCRight
        } else {
            lastCoordTrace := "F-Y"
            ; if buttonB
            return new target.extendedB.modY
        }
    }
}

reflectCoords(quadrantICoords) {
    global xComp, global yComp
    x := quadrantICoords[xComp], y := quadrantICoords[yComp]
    if (down()) {
        y *= -1
    }
    if (left()) {
        x *= -1
    }
    return [x, y]
}

/*  //////////////////////////////////////
    This function is tasked to update the position on the analog stick
    based on the currently seen cardinal directions and modifiers
*/
updateAnalogStick() {
    global currentTimeMS
    Critical, On ; thread can't be interrupted by a hotkey until the following code executes
    currentTimeMS := A_TickCount
    coords := getAnalogCoords()
    finalOutput := limitOutputs(coords)
    finalCoords := [finalOutput.x, finalOutput.y]
    setAnalogStick(finalCoords)
    Critical, Off
    Sleep, -1
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

; Send VJoy-formatted coordinates to vjoy interface
setAnalogStick(finalCoords) {
    global xComp, global yComp, global myStick
    convertedCoords := convertIntegerToVJoy(finalCoords)
    myStick.SetAxisByIndex(convertedCoords[xComp], 1) ; control stick (leftstick, analog stick) X
    myStick.SetAxisByIndex(convertedCoords[yComp], 2) ; same, Y
    return
}

; //////////////// Get CStick coordinates. unit circle format
getCStickCoords() {
    global
    if (!anyVertC() and !anyHorizC()) {
        cStickCoords := [0, 0]
    } else if (anyVertC() and anyHorizC()) {
        cStickCoords := [0.525, 0.85]
    } else if (anyVertC()) {
        cStickCoords := [0, 1]
    } else {
        if (modX() and up()) {
            cStickCoords := [0.9, 0.5]
        } else if (modX() and down()) {
            cStickCoords := [0.9, -0.5]
        } else {
            cStickCoords := [1, 0]
        }
    }
    return reflectCStickCoords(cStickCoords)
}

reflectCStickCoords(cStickCoords) {
    global xComp, global yComp
    x := cStickCoords[xComp]
    y := cStickCoords[yComp]
    if (cDown()) {
        y *= -1
    }
    if (cLeft()) {
        x *= -1
    }
    return [x, y]
}

/*  //////////////////////////////////////
    This function is tasked to update the position on the c-stick
    based on the currently seen cardinal directions and modifiers
*/
updateCStick() {
    setCStick(getCStickCoords())
    return
}

setCStick(cStickCoords) {
    global xComp, global yComp, global myStick
    convertedCoords := convertCStickCoords(cStickCoords)
    myStick.SetAxisByIndex(convertedCoords[xComp], 4) ; c-stick (rightstick) X
    myStick.SetAxisByIndex(convertedCoords[yComp], 5) ; same, Y
    return
}

convertCStickCoords(cStickCoords) { ; Converts coordinates from melee values (-1 to 1) to vJoy values (0 to 32767).
    mx = 10271 ; Why this number? idk, I would have thought it should be 16384 * (80 / 128) = 10240, but this works
    my = -10271
    bx = 16448 ; 16384 + 64
    by = 16320 ; 16384 - 64
    return [ mx * cStickCoords[1] + bx
        , my * cStickCoords[2] + by ]
}

setAnalogR(value) {
    global
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
    convertedValue := 16384 * (1 + (value / 255))
    myStick.SetAxisByIndex(convertedValue, 3)
    Return
}

; /////////////////////// hotkeys, and the functions and subroutines that handle hotkeys

; when a hotkey has the checkbox Special Bind, these hotkey labels take priority over the others
#If currentControlVarNameSp := HotkeyCtrlHasFocusIsSpecial()
    LControl & RAlt::
    LControl::
    RControl::
    LShift::
    RShift::
    LAlt::
    RAlt::
    LWin::
    RWin::
    +:: 
        Critical, On
        Gui, controlsWindow:Submit, NoHide
        labelNum := SubStr(currentControlVarNameSp, 3)
        OutputDebug, % A_ThisHotkey " " labelNum "`n"
        If (A_ThisHotkey = "LControl & RAlt") {
            GuiControl, controlsWindow:, HK%labelNum%, % "^RAlt" ; make the control display altgr activation key.
        }
        else if InStr(A_ThisHotkey, "*BackSpace") {
            ; leave it as it is
        }
        else {
            GuiControl,controlsWindow:, HK%labelNum%, % A_ThisHotkey ;  make the control display the hotkey.
        }

        validateHK(labelNum)
        Critical, Off
    return
    *BackSpace::
        Critical, On
        modifier := ""
        If GetKeyState("Shift","P")
            modifier .= "+"
        If GetKeyState("Ctrl","P")
            modifier .= "^"
        If GetKeyState("Alt","P")
            modifier .= "!"
        Gui, controlsWindow:Submit, NoHide
        GuiControl, controlsWindow:, %currentControlVarNameSp%, % modifier "BackSpace" ; overwrite the control content
        labelNum := SubStr(currentControlVarNameSp, 3)
        validateHK(labelNum)
        Critical, Off
    return
#If

#If currentControlVarName := HotkeyCtrlHasFocus() ; expr evaluated every time we press one of these keys
    *AppsKey::      ; Add support for these keys,
    *Delete::       ; which the hotkey control does not normally allow.
    *Enter::
    *Escape::
    *Pause::
    *PrintScreen::
    *Space::
    *Tab::
        Critical, On
        modifier := ""
        If GetKeyState("Shift","P")
            modifier .= "+"
        If GetKeyState("Ctrl","P")
            modifier .= "^"
        If GetKeyState("Alt","P")
            modifier .= "!"
        Gui, controlsWindow:Submit, NoHide
        ; overwrite the control content
        GuiControl, controlsWindow:, %currentControlVarName%, % modifier SubStr(A_ThisHotkey,2) 
        labelNum := SubStr(currentControlVarName, 3)
        validateHK(labelNum)
        Critical, Off
    return
#If ; end of conditional hotkeys

;-------macros

Pause::Suspend
^!r:: Reload ; Ctrl+Alt+R
SetKeyDelay, 0
#MaxHotkeysPerInterval 200

^!s:: ; Ctrl+Alt+S
    Suspend, Toggle
    If A_IsSuspended
        TrayTip, % "Rectangle Controller Script:", % "Hotkeys Disabled (''Suspend'' Mode)", 2, 0
    Else
        TrayTip, % "Rectangle Controller Script:", % "Hotkeys Enabled", 2, 0
Return

; Analog Up
Label1:
    buttonUp := true, updateAnalogStick(), updateCStick()
return

Label1_UP:
    buttonUp := false, updateAnalogStick(), updateCStick()
return

; Analog Down
Label2:
    buttonDown := true, updateAnalogStick(), updateCStick()
return

Label2_UP:
    buttonDown := false, updateAnalogStick(), updateCStick()
return

; Analog Left
Label3:
    buttonLeft := true, updateAnalogStick()
return

Label3_UP:
    buttonLeft := false, updateAnalogStick()
return

; Analog Right
Label4:
    buttonRight := true, updateAnalogStick()
return

Label4_UP:
    buttonRight := false, updateAnalogStick()
return

; ModX
Label5:
    buttonModX := true, updateAnalogStick(), updateCStick()
return

Label5_UP:
    buttonModX := false, updateAnalogStick(), updateCStick()
return

; ModY
Label6:
    buttonModY := true, updateAnalogStick()
return

Label6_UP:
    buttonModY := false, updateAnalogStick()
return

; A
Label7:
    buttonA := true, myStick.SetBtn(1,5)
return

Label7_UP:
    buttonA := false, myStick.SetBtn(0,5)
return

; B
Label8:
    buttonB := true, myStick.SetBtn(1, 4), updateAnalogStick()
return

Label8_UP:
    buttonB := false, myStick.SetBtn(0, 4), updateAnalogStick()
return

; L
Label9:
    buttonL := true, myStick.SetBtn(1, 1), updateAnalogStick()
return

Label9_UP:
    buttonL := false, myStick.SetBtn(0, 1), updateAnalogStick()
return

; R
Label10:
    buttonR := true, myStick.SetBtn(1, 3), updateAnalogStick()
return

Label10_UP:
    buttonR := false, myStick.SetBtn(0, 3), updateAnalogStick()
return

; X
Label11:
    buttonX := true, myStick.SetBtn(1, 6)
return

Label11_UP:
    buttonX := false, myStick.SetBtn(0, 6)
return

; Y
Label12:
    buttonY := true, myStick.SetBtn(1, 2)
return

Label12_UP:
    buttonY := false, myStick.SetBtn(0, 2)
return

; Z
Label13:
    buttonZ := true, myStick.SetBtn(1, 7), ; updateAnalogStick() ; I wonder why was this here
return

Label13_UP:
    buttonZ := false, myStick.SetBtn(0, 7), ; updateAnalogStick()
return

; C Up
Label14:
    buttonCUp := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 9)
    } else {
        updateAnalogStick(), updateCStick()
    }
return

Label14_UP:
    buttonCUp := false, myStick.SetBtn(0, 9), updateAnalogStick(), updateCStick()
return

; C Down
Label15:
    buttonCDown := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 11)
    } else {
        updateAnalogStick(), updateCStick()
    }
return

Label15_UP:
    buttonCDown := false, myStick.SetBtn(0, 11), updateAnalogStick(), updateCStick()
return

; C Left
Label16:
    buttonCLeft := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 10)
    } else {
        updateAnalogStick(), updateCStick()
    }
return

Label16_UP:
    buttonCLeft := false, myStick.SetBtn(0, 10), updateAnalogStick(), updateCStick()
return

; C Right
Label17:
    buttonCRight := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 12)
    } else {
        updateAnalogStick(), updateCStick()
    }
return

Label17_UP:
    buttonCRight := false, myStick.SetBtn(0, 12), updateAnalogStick(), updateCStick()
return

; Lightshield (Light)
Label18:
    buttonLightShield := true, setAnalogR(49)
return

Label18_UP:
    buttonLightShield := false, setAnalogR(0)
return

; Lightshield (Medium)
Label19:
    buttonMidShield := true, setAnalogR(94)
return

Label19_UP:
    buttonMidShield := false, setAnalogR(0)
return

; Start
Label20:
    buttonStart := true, myStick.SetBtn(1, 8)
return

Label20_UP:
    buttonStart := false, myStick.SetBtn(0, 8)
return

; D Up
Label21:
    buttonDPadUp := true, myStick.SetBtn(1, 9)
return

Label21_UP:
    buttonDPadUp := true, myStick.SetBtn(0, 9)
return

; D Down
Label22:
    buttonDPadDown := true, myStick.SetBtn(1, 11)
return

Label22_UP:
    buttonDPadDown := false, myStick.SetBtn(0, 11)
return

; D Left
Label23:
    buttonDPadLeft := true, myStick.SetBtn(1, 10)
return

Label23_UP:
    buttonDPadLeft := false, myStick.SetBtn(0, 10)
return

; D Right
Label24:
    buttonDPadRight := true, myStick.SetBtn(1, 12)
return

Label24_UP:
    buttonDPadRight := false, myStick.SetBtn(0, 12)
return

; Debug
Label25:
    debugString := getDebug()
    Msgbox % debugString
return

Label25_UP:
return

; /////////////// Creates the Debug message. code not updated yet

getDebug() {
    global
    activeArray := []
    pressedArray := []
    flagArray := []

    appendButtonState(activeArray, pressedArray, up(), buttonUp, "Up")
    appendButtonState(activeArray, pressedArray, down(), buttonDown, "Down")
    appendButtonState(activeArray, pressedArray, left(), buttonLeft, "Left")
    appendButtonState(activeArray, pressedArray, right(), buttonRight, "Right")

    appendButtonState(activeArray, pressedArray, modX(), buttonModX, "ModX")
    appendButtonState(activeArray, pressedArray, modY(), buttonModY, "ModY")

    appendButtonState(activeArray, pressedArray, buttonA, false, "A")
    appendButtonState(activeArray, pressedArray, buttonB, false, "B")
    appendButtonState(activeArray, pressedArray, buttonL, false, "L")
    appendButtonState(activeArray, pressedArray, buttonR, false, "R")
    appendButtonState(activeArray, pressedArray, buttonX, false, "X")
    appendButtonState(activeArray, pressedArray, buttonY, false, "Y")
    appendButtonState(activeArray, pressedArray, buttonZ, false, "Z")

    appendButtonState(activeArray, pressedArray, buttonLightShield, false, "LightShield")
    appendButtonState(activeArray, pressedArray, buttonMidShield, false, "MidShield")

    appendButtonState(activeArray, pressedArray, CUp(), buttonCUp, "C-Up")
    appendButtonState(activeArray, pressedArray, CDown(), buttonCDown, "C-Down")
    appendButtonState(activeArray, pressedArray, CLeft(), buttonCLeft, "C-Left")
    appendButtonState(activeArray, pressedArray, CRight(), buttonCRight, "C-Right")

    conditionalAppend(flagArray, simultaneousHorizontalModifierLockout, "SHML") ; unused in new code because of neutral SOCD

    activeButtonList := stringJoin(", ", activeArray)
    pressedButtonList := stringJoin(", ", pressedArray)
    flagList := stringJoin(", ", flagArray)

    trace1 := lastCoordTrace

    analogCoordsDbg := getAnalogCoords()
    cStickCoordsDbg := getCStickCoords()

    trace2 := lastCoordTrace

    trace := trace1 == trace2 ? trace1 : Format("{1}/{2}", trace1, trace2)

    debugFormatString =
    (

        Analog Stick: [{1}, {2}]
        C Stick: [{3}, {4}]

        Active held buttons:
        {5}

        Disabled held buttons:
        {6}

        Flags:
        {7}

        Trace:
    {8}
    )

    return Format(debugFormatString
        , analogCoordsDbg[1], analogCoordsDbg[2]
        , cStickCoordsDbg[1], cStickCoordsDbg[2]
        , activeButtonList, pressedButtonList, flagList
        , trace)
}

appendButtonState(activeArray, pressedArray, isActive, isPressed, name) {
    if (isActive) {
        activeArray.Push(name)
    } else if (isPressed) {
        pressedArray.Push(name)
    }
}

conditionalAppend(array, condition, value) {
    if (condition) {
        array.Push(value)
    }
}

; From https://www.autohotkey.com/boards/viewtopic.php?t=7124
stringJoin(sep, params) {
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}


