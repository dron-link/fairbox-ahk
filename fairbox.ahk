#Requires AutoHotkey v1.1.37
#Warn All, OutputDebug
#SingleInstance force
#NoEnv
#include <CvJoyInterface>
SetBatchLines, -1
#include %A_ScriptDir%
#include, engineConstants.ahk ; needed for most other things
#include, hkIniAutogenerator.ahk ; create hotkeys.ini
#include, testingTools.ahk
#include, targetObjStructure.ahk ; defines targetCoordinateTree class
target := new targetCoordinateTree
#include, targetCoordinateValues.ahk ; you can customize the coordinates here
#include, targetFormatting.ahk
#include, fairboxGlobalDeclarations.ahk
#include, outputMiscMethods.ahk
#include, nerfUncrouch.ahk
#include, nerfPivot.ahk
#include, nerfSDI.ahk
#include, nerfBasedOnHistory.ahk
#include, trackDeadzoneExits.ahk

testNerfsByHand(false) ; configure at testingTools.ahk, then set this parameter true. to test timing lockout nerfs

/*  this file is agirardeaudale B0XX-autohotkey  https://github.com/agirardeau/b0xx-ahk
    i, dron-link, am weaving new features into it, creating 'fairbox'

DISCLAIMER
I AM NOT A PROGRAMMER BY TRADE. i believe that the community would appreciate if you, a programmer,
took matters in your hands and made a more powerful, stable, and readable version of this program.
Other than to use it after the lack of alternatives, I made this with the hope that this script 
contains any useful ideas for you.

contact info:
Discord
    aiiiiiiiiiiu     ; over at B0XX server
GitHub
    https://github.com/dron-link

sdi and pivot nerfs adapted from CarVac 's work  https://github.com/CarVac/HayBox
more info extracted from B0XX documentation  https://b0xx.com/pages/resources
and B0XX: The Movie  https://www.youtube.com/watch?v=uTYSgyca8cI
and the Melee Controller Ruleset Proposal 2024 (outdated?)
https://docs.google.com/document/d/1abMqoatAGh_ZhQD1qJaQx6YqFAppCjU5KyF3mgvDQVw/
and Altimor's Stickmap https://marp-e3fcf.web.app/

When I messaged CarVac and Practical_TAS, they were kind enough to give me suggestions for this project.

  ---------------------

this project is proof of concept of how can we implement a variety of analog stick nerfs in Autohotkey.

everything is subject to modification and may not be present in the finalized version.
+++ i'm considering helping to make a faithful b0xx v4.1-like for keyboards in the future.

rough change list and to-do
 - implemented neutral SOCD, did away with the old SOCD handling for now
 - implemented empty pivot nerfing. it will need lots of timing accuracy testing and trigger testing, but as of now it does the job
 - reimplemented reverse neutral-B lockout nerf
 - implement crouch to uptilt nerf
 - allow for c-stick button leftstick angle modifier binding changes (or c-stick-angle-bindings for short)
    by editing a certain autogenerated file
 - implemented coordinate circle clamping
 - implemented 1.0 cardinal fuzzing (y fuzzing). UCF and v1.03 fixes are compatible with this nerf
 - made a function that deals the task of getting the nerfed coordinates for timing based nerfs. "nerfBasedOnHistory"

 - TODO remake queue timestamps into a sparsely populated array of timestamps of first encounters of .did within
    multipress
 - TODO make certain global variables into static locals
 - TODO add cx and cy entries to the output history
 - TODO explore writing a function nerfConflictManager() to deal with pivot vs. sdi, and uncrouch vs. sdi. prioritize player input
 - TODO consider outputting 1.0 cardinals and 45° large diagonals past the analog circle?
 - TODO implement SDI nerfs
 - TODO use setTimer to lift nerfs without waiting for player input
    ¬ call updateAnalogStick and possibly lift pivot nerfs after 4 frames, 5 frames and 8 frames
    ¬ use setTimer to lift a 2f jump nerf 2 frames after it was forced (idea origin: CarVac HayBox)
 - TODO implement coordinate target inconditional bans
 - TODO write tests
 - TODO make some in-game debug display by taking control of the c-stick and d-pad (idea taken from: CarVac)
 - TODO make a debug mode, debugACertainProcess? outputDebug, % expression

setTimer firing rate is apparently 15.6ms, don't expect much precision from it
(at least it's shorter than a game cube input polling interval), but I expect that most nerf lifts will be one frame late sometimes.
Maybe we can improve the script by increasing the polling frequency? solution using WinMM

*/

hotkeys := [ "Analog Up" ; 1
    , "Analog Down" ; 2
    , "Analog Left" ; 3
    , "Analog Right" ; 4
    , "ModX" ; 5
    , "ModY" ; 6
    , "A" ; 7
    , "B" ; 8
    , "L" ; 9
    , "R" ; 10
    , "X" ; 11
    , "Y" ; 12
    , "Z" ; 13
    , "C-stick Up" ; 14
    , "C-stick Down" ; 15
    , "C-stick Left" ; 16
    , "C-stick Right" ; 17
    , "Light Shield" ; 18
    , "Mid Shield" ; 19
    , "Start" ; 20
    , "D-pad Up" ; 21
    , "D-pad Down" ; 22
    , "D-pad Left" ; 23
    , "D-pad Right" ; 24
    , "Debug"] ; 25

; reads c-stick-angle-bindings.ini and assigns coordinates according to its contents
target.bindAnglesToCStick()

Menu, Tray, Click, 1 ; default option appears when tray is clicked once
Menu, Tray, Add, % "Edit Controls", ShowGui ; adds Edit Controls as a submenu and goto ShowGui
Menu, Tray, Default, % "Edit Controls"

; adopt saved hotkeys and silently initialize Edit Controls menu
for index, element in hotkeys{
    ; vLB1 associates this to variable LB1 and so on
    Gui, Add, Text, xm vLB%index%, % element " Hotkey:"
    ; Attempt to retrieve a hotkey saved as a string in INI file.
    IniRead, savedHK%index%, hotkeys.ini, Hotkeys, %index%, %A_Space%  
    If savedHK%index% { ; If something was retrieved,
        ;Activate saved hotkey
        Hotkey, % savedHK%index%, Label%index% 
        Hotkey, % savedHK%index% . " UP", Label%index%_UP
    }

    if InStr(savedHK%index%, "~", false) {
        preventDefaultBehavior := false ; When the hotkey fires, its key's native function will not be blocked 
    } else {
        preventDefaultBehavior := true
    }
    /*  Remove tilde (~) and Win (#) modifiers...
        They are incompatible with hotkey controls (cannot be shown in gui).
    */
    noMods := StrReplace(savedHK%index%, "~")
    noMods := StrReplace(noMods, "#")

    ; syntax: Gui, Add, ControlType, xPos wWidth vVar gGoto, TextBody
    Gui, Add, Hotkey, x+5 w150 vHK%index% gGuiLabel, % noMods ;Add hotkey controls and show the saved hotkeys in them
    if(!preventDefaultBehavior)
        ;Add checkboxes to allow the Windows key (#) as a modifier..
        Gui, Add, CheckBox, x+5 vCB%index% gGuiLabel, % "Prevent Default Behavior" 
    else
        Gui, Add, CheckBox, x+5 vCB%index% Checked gGuiLabel, % "Prevent Default Behavior"
} ;Check the box if Win modifier is used.

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

buttonA := false
buttonB := false
buttonL := false
buttonR := false
buttonX := false
buttonY := false
buttonZ := false

buttonLightShield := false
buttonMidShield := false

buttonModX := false
buttonModY := false

buttonCUp := false
buttonCDown := false
buttonCLeft := false
buttonCRight := false

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

; ///////////// Get the same coordinates but now with nerfs

limitOutputs(rawCoords) {
    global TIMELIMIT_SIMULTANEOUS, global TIMELIMIT_PIVOTTILT, global TIMELIMIT_DOWNUP, global ZONE_CENTER
    global xComp, global yComp, global currentTimeMS, global sdiZoneHist
    
    ; ### first call setup

    static output := new outputBase
    ; objects that store the info of previous relevant areas the control stick was inside of
    static outOfDeadzone := new leftstickOutOfDeadzoneBase
    static dashZone := new baseDashZone
    static crouchZone := new baseCrouchZone
    ; objects that store the previously executed techniques that activate timing lockouts
    static pivot := new basePivot
    static uncrouch := new baseUncrouch

    static limitOutputsInitialized := False
    if !limitOutputsInitialized {
        /*  this is a way to bundle outOfDeadzone info with the pivot and uncrouch objects 
            to make the info visible to pivot.getNerfedCoords() and uncrouch.getNerfedCoords()
        */
        ; 
        pivot.outOfDeadzone := outOfDeadzone 
        uncrouch.outOfDeadzone := outOfDeadzone
        limitOutputsInitialized := True
    }

    ; ### update the variables
    
    currentTimeMS := A_TickCount
    output.limited := new outputHistoryEntry(rawCoords[xComp], rawCoords[yComp], currentTimeMS)
    /*  true if current input and those that follow can't be considered as part of the previous multipress;
        only runs once, after a multipress ends.
    */
    if (currentTimeMS - output.latestMultipressBeginningTimestamp >= TIMELIMIT_SIMULTANEOUS 
        and !output.hist[1].multipress.ended) {
        output.hist[1].multipress.ended := true
        outOfDeadzone.saveHistory()
        crouchZone.saveHistory()
        uncrouch.saveHistory()
        dashZone.saveHistory()
        pivot.saveHistory()
    }
    uncrouch.lockoutExpiryCheck()
    dashZone.checkHistoryEntryStaleness()
    pivot.lockoutExpiryCheck()

    ; ### processes the player input and converts it into legal output

    output.reverseNeutralBNerf()

    ; if technique needs to be nerfed, this writes the nerfed coordinates in nerfedCoords
    pivot.nerfSearch(output.limited.x, output.limited.y, dashZone)
    uncrouch.nerfSearch(output.limited.x, output.limited.y, crouchZone)

    output.chooseLockout(pivot, uncrouch)

    ; fuzz the y when x is +1.00 or -1.00
    output.horizontalRimFuzz()
    
    ; ### record output to read it in next calls of this function

    uncrouch.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y, crouchZone)
    pivot.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y, dashZone)
    
    if (output.limited.x != output.hist[1].x or output.limited.y != output.hist[1].y) {
        outOfDeadzone.storeInfoBeforeMultipressEnds(output.limited.y)
        crouchZone.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y)
        dashZone.storeInfoBeforeMultipressEnds(output.limited.x, output.limited.y)

        ; if true, next input to be stored is potentially the beginning of a simultaneous multiple key press (aka multipress)
        if output.hist[1].multipress.ended {
            output.limited.multipress.began := true
            output.latestMultipressBeginningTimestamp := output.limited.timestamp ; obviously, currentTimeMS
        }
        ; registers even the shortest-lasting leftstick coordinates passed to vjoy
        output.hist.Pop(), output.hist.InsertAt(1, output.limited)
    }

    return output.limited
}

/*  //////////////////////////////////////
    This function is tasked to update the position on the analog stick
    based on the currently seen cardinal directions and modifiers
*/
updateAnalogStick() {
    coords := getAnalogCoords()
    finalOutput := limitOutputs(coords)
    finalCoords := [finalOutput.x, finalOutput.y]
    setAnalogStick(finalCoords)
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

; //////////////// Get CStick coordinates. unit circle format, code written by agirardeaudale
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
validateHK(GuiControl) {
    global lastHK
    Gui, Submit, NoHide ; saves control contents to their respective variables
    lastHK := %GuiControl% ;Backup the hotkey, in case it needs to be reshown.
    num := SubStr(GuiControl,3) ;Get the index of the hotkey control. example: "20" is Start
    If (HK%num% != "") { ;If the hotkey is not blank...
        HK%num% := strReplace(HK%num%, "SC15D", "AppsKey")      ; Use friendlier names,
        HK%num% := strReplace(HK%num%, "SC154", "PrintScreen")  ; instead of these scan codes.
        If (!CB%num% && !RegExMatch(HK%num%,"[#!\^\+]")) ;  If the new hotkey has no modifiers, add the (~) modifier.
            HK%num% := "~" HK%num% ;    This prevents any key from being blocked.
        checkDuplicateHK(num)
    }
    If (savedHK%num% || HK%num%) ;Unless both are empty,
        setHK(num, savedHK%num%, HK%num%) ;  update INI/GUI
}

checkDuplicateHK(num) {
    global
    Loop,% hotkeys.Length()
        If (HK%num% = savedHK%A_Index%) {
            dup := A_Index
            TrayTip, B0XX, Hotkey Already Taken, 3, 0
            Loop,6 {
                GuiControl,% "Disable" b:=!b, HK%dup% ;Flash the original hotkey to alert the user.
                Sleep,200
            }
            GuiControl,,HK%num%,% HK%num% :="" ;Delete the hotkey and clear the control.
            break
        }
}

setHK(num,INI,GUI) {
    If INI{ ;If previous hotkey exists,
        Hotkey, %INI%, Label%num%, Off ;  disable it.
        Hotkey, %INI% UP, Label%num%_UP, Off ;  disable it.
    }
    If GUI{ ;If new hotkey exists,
        Hotkey, %GUI%, Label%num%, On ;  enable it.
        Hotkey, %GUI% UP, Label%num%_UP, On ;  enable it.
    }
    IniWrite,% GUI ? GUI : "", hotkeys.ini, Hotkeys, %num%
    savedHK%num% := HK%num%
    ;TrayTip, Label%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
}

#MenuMaskKey vkE8
#If ctrl := HotkeyCtrlHasFocus()
    *AppsKey:: ;Add support for these special keys,
    *BackSpace:: ;  which the hotkey control does not normally allow.
    *Delete::
    *Enter::
    *Escape::
    *Pause::
    *PrintScreen::
    *Space::
    *Tab::
        modifier := ""
        If GetKeyState("Shift","P")
            modifier .= "+"
        If GetKeyState("Ctrl","P")
            modifier .= "^"
        If GetKeyState("Alt","P")
            modifier .= "!"
        Gui, Submit, NoHide ;If BackSpace is the first key press, Gui has never been submitted.
        If (A_ThisHotkey == "*BackSpace" && %ctrl% && !modifier) ;If the control has text but no modifiers held,
            GuiControl,,%ctrl% ;  allow BackSpace to clear that text.
        Else ;Otherwise,
            GuiControl,,%ctrl%, % modifier SubStr(A_ThisHotkey,2) ;  show the hotkey.
        validateHK(ctrl)
    return
#If

HotkeyCtrlHasFocus() {
    GuiControlGet, ctrl, Focus ;ClassNN
    If InStr(ctrl,"hotkey") {
        GuiControlGet, ctrl, FocusV ;Associated variable
        Return, ctrl
    }
}

;----------------------------Labels

;Show GUI from tray Icon
ShowGui:
    Gui, show,, Dynamic Hotkeys
    /*  this puts the windows "focus" on the text description, 
        that way it isn't immediately waiting for input on the 1st input box (HK1)
    */
    GuiControl, Focus, LB1 
return

GuiLabel:
    If %A_GuiControl% in +,^,!,+^,+!,^!,+^! ;If the hotkey contains only modifiers, return to wait for a key.
        return
    If InStr(%A_GuiControl%, "vkE8") ;vkE8 = MenuMaskKey
        GuiControl,,%A_GuiControl%, % lastHK ;Reshow the hotkey, because MenuMaskKey clears it.
    Else
        validateHK(A_GuiControl)
return

;-------macros

Pause::Suspend
^!r:: Reload
SetKeyDelay, 0
#MaxHotkeysPerInterval 200

^!s::
    Suspend
    If A_IsSuspended
        TrayTip, B0XX, Hotkeys Disabled, 3, 0
    Else
        TrayTip, B0XX, Hotkeys Enabled, 3, 0
Return

; Analog Up
Label1:
    buttonUp := true
    updateAnalogStick()
    updateCStick()
return

Label1_UP:
    buttonUp := false
    updateAnalogStick()
    updateCStick()
return

; Analog Down
Label2:
    buttonDown := true
    updateAnalogStick()
    updateCStick()
return

Label2_UP:
    buttonDown := false
    updateAnalogStick()
    updateCStick()
return

; Analog Left
Label3:
    buttonLeft := true
    updateAnalogStick()
return

Label3_UP:
    buttonLeft := false
    updateAnalogStick()
return

; Analog Right
Label4:
    buttonRight := true
    updateAnalogStick()
return

Label4_UP:
    buttonRight := false
    updateAnalogStick()
return

; ModX
Label5:
    buttonModX := true
    updateAnalogStick()
    updateCStick()
return

Label5_UP:
    buttonModX := false
    updateAnalogStick()
    updateCStick()
return

; ModY
Label6:
    buttonModY := true
    updateAnalogStick()
return

Label6_UP:
    buttonModY := false
    updateAnalogStick()
return

; A
Label7:
    buttonA := true
    myStick.SetBtn(1,5)
return

Label7_UP:
    buttonA := false
    myStick.SetBtn(0,5)
return

; B
Label8:
    buttonB := true
    myStick.SetBtn(1, 4)
    updateAnalogStick()
return

Label8_UP:
    buttonB := false
    myStick.SetBtn(0, 4)
    updateAnalogStick()
return

; L
Label9:
    buttonL := true
    myStick.SetBtn(1, 1)
    updateAnalogStick()
return

Label9_UP:
    buttonL := false
    myStick.SetBtn(0, 1)
    updateAnalogStick()
return

; R
Label10:
    buttonR := true
    myStick.SetBtn(1, 3)
    updateAnalogStick()
return

Label10_UP:
    buttonR := false
    myStick.SetBtn(0, 3)
    updateAnalogStick()
return

; X
Label11:
    buttonX := true
    myStick.SetBtn(1, 6)
return

Label11_UP:
    buttonX := false
    myStick.SetBtn(0, 6)
return

; Y
Label12:
    buttonY := true
    myStick.SetBtn(1, 2)
return

Label12_UP:
    buttonY := false
    myStick.SetBtn(0, 2)
return

; Z
Label13:
    buttonZ := true
    myStick.SetBtn(1, 7)
    updateAnalogStick()
return

Label13_UP:
    buttonZ := false
    myStick.SetBtn(0, 7)
    updateAnalogStick()
return

; C Up
Label14:
    buttonCUp := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 9)
    } else {
        updateCStick()
        updateAnalogStick()
    }
return

Label14_UP:
    buttonCUp := false
    myStick.SetBtn(0, 9)
    updateCStick()
    updateAnalogStick()
return

; C Down
Label15:
    buttonCDown := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 11)
    } else {
        updateCStick()
        updateAnalogStick()
    }
return

Label15_UP:
    buttonCDown := false
    myStick.SetBtn(0, 11)
    updateCStick()
    updateAnalogStick()
return

; C Left
Label16:
    buttonCLeft := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 10)
    } else {
        updateCStick()
        updateAnalogStick()
    }
return

Label16_UP:
    buttonCLeft := false
    myStick.SetBtn(0, 10)
    updateCStick()
    updateAnalogStick()
return

; C Right
Label17:
    buttonCRight := true
    if (bothMods()) {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 12)
    } else {
        updateCStick()
        updateAnalogStick()
    }
return

Label17_UP:
    buttonCRight := false
    myStick.SetBtn(0, 12)
    updateCStick()
    updateAnalogStick()
return

; Lightshield (Light)
Label18:
    buttonLightShield := true
    setAnalogR(49)
return

Label18_UP:
    buttonLightShield := false
    setAnalogR(0)
return

; Lightshield (Medium)
Label19:
    buttonMidShield := true
    setAnalogR(94)
return

Label19_UP:
    buttonMidShield := false
    setAnalogR(0)
return

; Start
Label20:
    myStick.SetBtn(1, 8)
return

Label20_UP:
    myStick.SetBtn(0, 8)
return

; D Up
Label21:
    myStick.SetBtn(1, 9)
return

Label21_UP:
    myStick.SetBtn(0, 9)
return

; D Down
Label22:
    myStick.SetBtn(1, 11)
return

Label22_UP:
    myStick.SetBtn(0, 11)
return

; D Left
Label23:
    myStick.SetBtn(1, 10)
return

Label23_UP:
    myStick.SetBtn(0, 10)
return

; D Right
Label24:
    myStick.SetBtn(1, 12)
return

Label24_UP:
    myStick.SetBtn(0, 12)
return

; Debug
Label25:
    debugString := getDebug()
    Msgbox % debugString

Label25_UP:
return

; /////////////// Creates the Debug message. code written by agirardeaudale

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

