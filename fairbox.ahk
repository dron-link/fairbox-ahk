#Requires AutoHotkey v1.1.37.02
#Warn All, OutputDebug
#SingleInstance force
#NoEnv
SetBatchLines, -1
ListLines Off

#MenuMaskKey vke8
SetWorkingDir, %A_ScriptDir%

#include <CvJoyInterface>

currentTimeMS := 0

#include %A_ScriptDir%\analogZoneInfo\crouchZone
#include, crouchZone.ahk

#include %A_ScriptDir%\analogZoneInfo\dashZone
#include, dashZone.ahk

#include %A_ScriptDir%\analogZoneInfo\outOfDeadzone
#include, outOfDeadzone.ahk

#include %A_ScriptDir%\controls
#include, initializeControls.ahk
#include, loadHotkeysIni.ahk

#include %A_ScriptDir%\coordinates\target
#include, target.ahk

#include %A_ScriptDir%\coordinates
#include, coordinates.ahk

#include %A_ScriptDir%\limitOutputs
#include, limitOutputs.ahk

#include %A_ScriptDir%\menu
#include, mainsTrayMenu.ahk

#include %A_ScriptDir%\system
#include, fairboxConstants.ahk ; globals
#include, gameEngineConstants.ahk ; globals
#include, getDebugLegacy.ahk
#include, guiFont.ahk
#include, hotkeys.ahk ; globals
#include, keysModCAngleRole.ahk ; globals

#include %A_ScriptDir%\technique\pivot
#include, pivot.ahk

#include %A_ScriptDir%\technique\uncrouch
#include, uncrouch.ahk

#include %A_ScriptDir%\technique
#include, getReverseNeutralBNerf.ahk
#include, timingBasedTechniqueHistoryEntry.ahk
; always save for last.
#include %A_ScriptDir%\test
#include, director.ahk

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
- TODO create a showControlsWindowOnFirstLaunch
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

; exit an active controls editor
DetectHiddenWindows, On
PostMessage, 0x111, 65307,,, %A_ScriptDir%\StandaloneControlsEditor.ahk
PostMessage, 0x111, 65307,,, %A_ScriptDir%\StandaloneControlsEditor.exe
DetectHiddenWindows, Off

FileInstall, install\config.ini, % A_ScriptDir "\config.ini", 0 ; for when config.ini doesn't exist

enabledHotkeys := true
enabledGameControls := true
showWelcomeTray := true
loadConfigIniLaunchMode()
loadConfigIniLaunchMode() {
    global enabledHotkeys
    global showWelcomeTray
    
    if enabledHotkeys {
        showWelcomeTray := true
    } else {
        showWelcomeTray := false
    }

    ; do we come from Edit Controls?
    IniRead, openedFromControlsEditor, config.ini, LaunchMode, ControlsWindowIntoMain
    IniWrite, % false                , config.ini, LaunchMode, ControlsWindowIntoMain
    if openedFromControlsEditor {
        ; we recall the Input On/Off toggle state
        IniRead, enabledGameControls, config.ini, LaunchMode, EnabledControlsRecall
        showWelcomeTray := false
    }
    return
}

; load global UserSettings
IniRead, deleteFailingHotkey, config.ini, UserSettings, DeleteFailingHotkey
IniRead, secondIPCleaning, config.ini, UserSettings, 2ipCleaning

target := new targetCoordinateTreeWithCBinds ; upon using the __New() metafunction this evaluates as "" uh????
target.loadCoordinates()

constructMainsTrayMenu() ; puts the custom menu items in the tray

for i in hotkeys {
    ; ### for hotkey activation keys, and gui hotkey controls. instantiate the global variables associated to:
    ; the hotkey
    savedHK%i% := ""
}

loadHotkeysIni()

initializeControls()

; Create an object from vJoy Interface Class.
vJoyInterface := new CvJoyInterface()

; Was vJoy installed and the DLL Loaded?
if !vJoyInterface.vJoyEnabled() {
    ; Show log of what happened
    Msgbox % vJoyInterface.LoadLibraryLog
    ExitApp
}

myStick := vJoyInterface.Devices[1]


; for 2ip and opposite horizontal mod lock
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

if showWelcomeTray {
    ; Alert User that script has started
    TrayTip, % "fairbox", % "Script Started", 3, 0
}

; arbitrary vjoy initial status - bug fix: reset all buttons on startup
for index in hotkeys {
    gosub Label%index%_UP
}

endOfLaunchThreadTests()

return ; end of autoexecute

/*  ////////////////////////////////
    check what directions, modifiers and buttons we should listen to,
    based on things like opposite cardinal direction modes, D-Pad mode etc
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

/*  This function is tasked to update the position on the analog stick
    based on the currently seen cardinal directions and modifiers
*/
updateAnalogStick() {
    global xComp, global yComp, global currentTimeMS
    currentTimeMS := A_TickCount
    coords := getAnalogCoords()
    finalOutput := limitOutputs(coords[xComp], coords[yComp])
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

; /////////////////////// hotkeys, and the functions and subroutines that handle hotkeys

;-------macros

^!r:: Reload ; Ctrl+Alt+R
SetKeyDelay, 0
#MaxHotkeysPerInterval 200

/*
^!s:: ; Ctrl+Alt+S
    Suspend, Toggle
    If A_IsSuspended
        TrayTip, % "Rectangle Controller Script:", % "Hotkeys Disabled (''Suspend'' Mode)", 2, 0
    Else
        TrayTip, % "Rectangle Controller Script:", % "Hotkeys Enabled", 2, 0
Return
*/

; Analog Up
Label1:
    Critical
    buttonUp := true, mostRecentVerticalAnalog := "U", updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

Label1_UP:
    Critical
    buttonUp := false, updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

; Analog Down
Label2:
    Critical
    buttonDown := true, mostRecentVerticalAnalog := "D", updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

Label2_UP:
    Critical
    buttonDown := false, updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

; Analog Left
Label3:
    Critical
    if (buttonRight and !buttonLeft){ ; !buttonLeft prevents keyboard resend
        opposingHorizontalsModLockout := true
    }
    buttonLeft := true, mostRecentHorizontalAnalog := "L", updateAnalogStick()
    Critical Off
    Sleep -1
return

Label3_UP:
    Critical
    buttonLeft := false, opposingHorizontalsModLockout := false, updateAnalogStick()
    Critical Off
    Sleep -1
return

; Analog Right
Label4:
    Critical
    if (buttonLeft and !buttonRight) { ; !buttonRight prevents keyboard resend
        opposingHorizontalsModLockout := true
    }
    buttonRight := true, mostRecentHorizontalAnalog := "R", updateAnalogStick()
    Critical Off
    Sleep -1
return

Label4_UP:
    Critical
    buttonRight := false, opposingHorizontalsModLockout := false, updateAnalogStick()
    Critical Off
    Sleep -1
return

; ModX
Label5:
    Critical
    /*  opposingHorizontalsModLockout is order dependant,
        it only applies if modifier isn't pressed after horizontals
    */
    if !buttonModX { ; !buttonModX prevents keyboard resend
        opposingHorizontalsModLockout := false 
    }
    buttonModX := true, updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

Label5_UP:
    Critical
    buttonModX := false , opposingHorizontalsModLockout := false, updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

; ModY
Label6:
    Critical
    buttonModY := true, updateAnalogStick()
    Critical Off
    Sleep -1
return

Label6_UP:
    Critical
    buttonModY := false, updateAnalogStick()
    Critical Off
    Sleep -1
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
    Critical
    buttonB := true, myStick.SetBtn(1, 4), updateAnalogStick()
    Critical Off
    Sleep -1
return

Label8_UP:
    Critical
    buttonB := false, myStick.SetBtn(0, 4), updateAnalogStick()
    Critical Off
    Sleep -1
return

; L
Label9:
    Critical
    buttonL := true, myStick.SetBtn(1, 1), updateAnalogStick()
    Critical Off
    Sleep -1
return

Label9_UP:
    Critical
    buttonL := false, myStick.SetBtn(0, 1), updateAnalogStick()
    Critical Off
    Sleep -1
return

; R
Label10:
    Critical
    buttonR := true, myStick.SetBtn(1, 3), updateAnalogStick()
    Critical Off
    Sleep -1
return

Label10_UP:
    Critical
    buttonR := false, myStick.SetBtn(0, 3), updateAnalogStick()
    Critical Off
    Sleep -1
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
    buttonZ := true, myStick.SetBtn(1, 7)
return

Label13_UP:
    buttonZ := false, myStick.SetBtn(0, 7)
return

; C Up
Label14:
    Critical
    buttonCUp := true
    if bothMods() {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 9)
    } else {
        mostRecentVerticalC := "U", updateAnalogStick(), updateCStick()
    }
    Critical Off
    Sleep -1
return

Label14_UP:
    Critical
    buttonCUp := false, myStick.SetBtn(0, 9), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

; C Down
Label15:
    Critical
    buttonCDown := true
    if bothMods() {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 11)
    } else {
        mostRecentVerticalC := "D", updateAnalogStick(), updateCStick()
    }
    Critical Off
    Sleep -1
return

Label15_UP:
    Critical
    buttonCDown := false, myStick.SetBtn(0, 11), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

; C Left
Label16:
    Critical
    buttonCLeft := true
    if bothMods() {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 10)
    } else {
        mostRecentHorizontalC := "L", updateAnalogStick(), updateCStick()
    }
    Critical Off
    Sleep -1
return

Label16_UP:
    Critical
    buttonCLeft := false, myStick.SetBtn(0, 10), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
return

; C Right
Label17:
    Critical
    buttonCRight := true
    if bothMods() {
        ; Pressing ModX and ModY simultaneously changes C buttons to D pad
        myStick.SetBtn(1, 12)
    } else {
        mostRecentHorizontalC := "R", updateAnalogStick(), updateCStick()
    }
    Critical Off
    Sleep -1
return

Label17_UP:
    Critical
    buttonCRight := false, myStick.SetBtn(0, 12), updateAnalogStick(), updateCStick()
    Critical Off
    Sleep -1
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
    Msgbox, % getDebug()
return

Label25_UP:
return

; Input On/Off
Label26:
    enabledGameControls := !enabledGameControls
return

Label26_UP:
return

#If enabledGameControls ; because an existing directive was needed to use Hotkey, If, enabledGameControls
#If

