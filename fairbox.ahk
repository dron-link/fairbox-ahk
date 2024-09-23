#SingleInstance force
#NoEnv
#include <CvJoyInterface>
SetBatchLines, -1

/* DRON hello.

 this file is agirardeaudale B0XX-autohotkey  https://github.com/agirardeau/b0xx-ahk
 with a small modification in behavior.
 sdi and pivot nerfs adapted from CarVac 's work  https://github.com/CarVac/HayBox
 more info extracted from B0XX documentation  https://b0xx.com/pages/resources
 and B0XX: The Movie  https://www.youtube.com/watch?v=uTYSgyca8cI
 and the Melee Controller Ruleset Proposal 2024 
 https://docs.google.com/document/d/1abMqoatAGh_ZhQD1qJaQx6YqFAppCjU5KyF3mgvDQVw/

 rough change list
 - DRON comments is me trying to understand the blocks of code
 - neutral SOCD implementation, did away with the old SOCD handling
 - implemented 1.0 cardinal fuzzing (in a way that doesn't affect UCF latest ver. players at all)
 - implemented pivot nerfing. it will need lots of testing and timing enhancement, but as of now it basically works
 - reimplemented reverse neutral-B lockout nerf
 - implement crouch to uptilt nerf
 - TODO change upYTimestamp, downYTimestamp, uncrouchTimestamp mechanics to simultaneous-vs-saved type mechanics
 - TODO make the sea of detector, unsaved, and saved named variables, into objects. (it will tidy up code)
 - TODO implement SDI nerfs
 - TODO use setTimer to lift nerfs without waiting for player input
 - TODO use setTimer to call updateAnalogStick and possibly lift pivot nerfs after 4 frames, 5 frames and 8 frames
 - TODO use setTimer to lift a 2fjump nerf 2 frames after it was forced (idea: CarVac)


setTimer polling rate is apparently 15.6ms, don't expect much precision from it. (At least it's shorter than a smash melee frame)

*/


; HISTORYLEN := 5 ; DRON default 5 changes in target stick position memorized 
AHISTORYLEN := 1
SHISTORYLEN := 5 ; MINIMUM 5
DHISTORYLEN := 3 ; MINIMUM 3

/* 
  DRON 
  ctrl-f this: For_Easy_Nerf_Testing
 */
nerfTestMode :=1

hotkeys := [ "Analog Up"             ; 1
           , "Analog Down"           ; 2
           , "Analog Left"           ; 3
           , "Analog Right"          ; 4
           , "ModX"                  ; 5
           , "ModY"                  ; 6
           , "A"                     ; 7
           , "B"                     ; 8
           , "L"                     ; 9
           , "R"                     ; 10
           , "X"                     ; 11
           , "Y"                     ; 12
           , "Z"                     ; 13
           , "C-stick Up"            ; 14
           , "C-stick Down"          ; 15
           , "C-stick Left"          ; 16
           , "C-stick Right"         ; 17
           , "Light Shield"          ; 18
           , "Mid Shield"            ; 19
           , "Start"                 ; 20
           , "D-pad Up"              ; 21
           , "D-pad Down"            ; 22
           , "D-pad Left"            ; 23
           , "D-pad Right"           ; 24
           , "Debug"]                ; 25

Menu, Tray, Click, 1
Menu, Tray, Add, Edit Controls, ShowGui
Menu, Tray, Default, Edit Controls

for index, element in hotkeys{
 Gui, Add, Text, xm vLB%index%, %element% Hotkey:
 IniRead, savedHK%index%, hotkeys.ini, Hotkeys, %index%, %A_Space%
 If savedHK%index%                                       ;Check for saved hotkeys in INI file.
  Hotkey,% savedHK%index%, Label%index%                 ;Activate saved hotkeys if found.
  Hotkey,% savedHK%index% . " UP", Label%index%_UP                 ;Activate saved hotkeys if found.
  ;TrayTip, B0XX, Label%index%_UP, 3, 0
  ;TrayTip, B0XX, % savedHK%A_Index%, 3, 0
  ;TrayTip, B0XX, % savedHK%index% . " UP", 3, 0
 checked := false
 if(!InStr(savedHK%index%, "~", false)){
  checked := true
 }
 StringReplace, noMods, savedHK%index%, ~                  ;Remove tilde (~) and Win (#) modifiers...
 StringReplace, noMods, noMods, #,,UseErrorLevel              ;They are incompatible with hotkey controls (cannot be shown).
 Gui, Add, Hotkey, x+5 w50 vHK%index% gGuiLabel, %noMods%        ;Add hotkey controls and show saved hotkeys.
 if(!checked)
  Gui, Add, CheckBox, x+5 vCB%index% gGuiLabel, Prevent Default Behavior  ;Add checkboxes to allow the Windows key (#) as a modifier..
 else
  Gui, Add, CheckBox, x+5 vCB%index% Checked gGuiLabel, Prevent Default Behavior  ;Add checkboxes to allow the Windows key (#) as a modifier..
}                                                               ;Check the box if Win modifier is used.

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
TrayTip, B0XX, modded Script Started, 3, 0



; DRON the idea and comments behind these constants is copied from CarVac/HayBox
ANALOG_STEP := 0.0125
MS_PER_FRAME := 1000 / 60  ; game runs at 60 fps
PI := 3.141592653589793
DEG_TO_RADIAN := PI / 180

ANALOG_STICK_MIN := -1 ; > coordinate, then it's out of stick range
ANALOG_DEAD_MIN := -0.2750 ; > coordinate, then it's outside the deadzone and to the left/down
ANALOG_STICK_NEUTRAL := 0
ANALOG_DEAD_MAX := 0.2750 ; < coordinate, then it's outside the deadzone and to the right/up
ANALOG_STICK_MAX := 1 ; < coordinate, then it's out of stick range
ANALOG_CROUCH := -0.6250 ; >= y coordinate, then the character is holding crouch
ANALOG_DOWNSMASH := -0.6625 ; >= y coordinate, then the character could downsmash, shield drop, fastfall, drop from platform etc
ANALOG_TAPJUMP := 0.6625 ; <= y coordinate, then the character is in u-smash or tap-jump range
ANALOG_DASH_LEFT := -0.8000 ; >= x coordinate, then f-smash or dash left
ANALOG_DASH_RIGHT := 0.8000 ; <= x coordinate, means f-smash or dash right
ANALOG_SDI_LEFT := -0.7000 ; >= x coordinate, then it's left sdi range
ANALOG_SDI_RIGHT := 0.7000 ; <= x coordinate, then it's right sdi range
ANALOG_SDI_UP := 0.7000 ; <= y coordinate
ANALOG_SDI_DOWN := - 0.7000 ; >= y coordinate
MELEE_SDI_RAD := 0.7 * 0.7 ; <= x^2+y^2, and not in x or y deadzone then it's diagonal SDI range
ANALOG_ANGLE_FIFTY_RATIO_13 := tan(50 * DEG_TO_RADIAN) ; <= y/x where y and x are the same sign and out of deadzone,
                                                  ; then coordinate angle is 50 degrees or above away from x axis
ANALOG_ANGLE_FIFTY_RATIO_24 := -tan(50 * DEG_TO_RADIAN) ; >= y/x where y and x are a different sign (quadrants 2 and 4)
ANALOG_ANGLE_XAXIS_RATIO_13 := tan(20 * DEG_TO_RADIAN) ; > y/x where y and x are the same sign and out of deadzone,
                                                          ; then angle is too close to X axis
ANALOG_ANGLE_XAXIS_RATIO_24 := -tan(20 * DEG_TO_RADIAN)
ANALOG_ANGLE_YAXIS_RATIO_13 := tan((90 - 20) * DEG_TO_RADIAN) ; < y/x where y and x are the same sign and out of deadzone,
                                                          ; then angle is too close to Y axis
ANALOG_ANGLE_YAXIS_RATIO_24 := -tan((90 - 20) * DEG_TO_RADIAN)                                                          
ANALOG_SPECIAL_LEFT := -0.6000 ; >= x coordinate, then it's in range to forward-B to the left
ANALOG_SPECIAL_RIGHT := 0.6000 ; <= x coordinate, then it's in range to forward-B to the right
ANALOG_SPECIAL_DOWN := -0.5500 ; >= y coordinate, then it's down-B range
ANALOG_SPECIAL_UP := 0.5500 ; <= y coordinate, then it's up-B range
ANALOG_SPOTDODGE_MIN_LEFT := -0.6875 ; <= x coordinate, and-
ANALOG_SPOTDODGE_MIN_RIGHT := 0.6875 ; >= x coordinate, then you are in spotdodge or middle shield-drop horizontal range 
ANALOG_SPOTDODGE_MIN_VERTICAL := -0.7000 ; >= y coordinate, then you are in spotdodge vertical (and below middle shield-drop) range

TIMELIMIT_DOWNUP := 3 * MS_PER_FRAME ; // ms, how long after a crouch to upward input should it begin a jump?
JUMP_TIME := 2.01 * MS_PER_FRAME ; // after a recent crouch to upward input, always hold full up only for 2 frames

TIMELIMIT_FRAME := MS_PER_FRAME   ; for use in pivot feasibility check
TIMELIMIT_HALFFRAME := MS_PER_FRAME / 2
TIMELIMIT_DEBOUNCE := 6 ; ms, to combat the effect of mechanical switch bounce. i don't know if this is relevant in today's keyboards
TIMELIMIT_SIMULTANEOUS := 3.5 ; ms > current time minus last input timestamp, means that this input and last one can be considered as 
                              ; an intended single input and not two separate inputs

TIMELIMIT_TAPSHUTOFF := 4 * MS_PER_FRAME ; 4 frames for tap jump shutoff, also d-smash shutoff

TIMELIMIT_BURSTSDI := 5.5 * MS_PER_FRAME ; ms
TIMELIMIT_TAP_PLUS := 8.5 * MS_PER_FRAME ; // 3 additional frames

TIMELIMIT_CARDIAG := 8 * MS_PER_FRAME ; ms, fyi cardiag means cardinal diagonal

TIMELIMIT_PIVOTTILT := 8 * MS_PER_FRAME
TIMELIMIT_PIVOTTILT_YDASH := 5 * MS_PER_FRAME
TIMESTALE_PIVOT_INPUTSEQUENCE := 15 * MS_PER_FRAME
FORCE_FTILT := 0.3750 ; value taken from CarVac haybox
TIMESTALE_SDI_INPUTSEQUENCE := 8 * MS_PER_FRAME

FUZZ_1_00_PROBABILITY := 50 ; percent of probability that the X output is 0.9875 instead of 1.0000


; state variables
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

mostRecentVertical := ""  ;  DRON this pair will go unused
mostRecentHorizontal := ""

mostRecentVerticalC := ""  ;  DRON this pair will go unused
mostRecentHorizontalC := ""

simultaneousHorizontalModifierLockout := false  ;  DRON will go unused in the new code

currentTimeMS := 0
nerfLiftFire := false ; DRON if a nerf lift timer fires this will be set true
upY := false ; DRON if current Y is above deadzone 
upYTimestamp := -1000
downY := false
downYTimestamp := -1000
force2FJumpTimestamp := -1000   ; CarVac HayBox timed nerf. Inactive by default.
pivotForced2FJump := false                ; <--- Search references for this
crouchForced2FJump := false               ; <-- and this if you want to activate it
uncrouchTimestamp := -1000 ; ms, DRON how long since the player exited the crouch range

finalCoords := [ANALOG_STICK_NEUTRAL, ANALOG_STICK_NEUTRAL] ; DRON left stick coordinates that are intended to be sent to vjoy

;  DRON these variables are to be used as value identifiers. not keys
DIDNT_SCAN := -1
P_NONE := 0 ; id: no pivot
P_LEFTRIGHT := 2 ; id: left to right pivot
P_RIGHTLEFT := 1
NOT_DASH := 0 ; id: when the x coordinate is in neither of the zones that trigger dash
ZONE_CENTER := 0 ; id: when the x and y coordinate is in no zone that can trigger SDI
; DRON for bitwise:
ZONE_DIR := ((1<<4) - 1)  ; 0b0000'1111
ZONE_U := 1               ; 0b0000'0001
ZONE_D := 1<<1            ; 0b0000'0010
ZONE_L := 1<<2
ZONE_R := 1<<3
BITS_SDI := ((1<<4) - 1) << 4 ; 0b1111'0000
BITS_SDI_QUARTERC := 1<<4     ; 0b0001'0000
BITS_SDI_TAP_CARD := 1<<5     ; 0b0010'0000
BITS_SDI_TAP_DIAG := 1<<6
BITS_SDI_TAP_CRDG := 1<<7
; DRON zone history keys
zh := {timestamp : 1, stale : 2, zone : 3, popcount : 4}
; DRON analog history keys
ah := {x : 1 , y : 2 , timestamp : 3 , simultFinal : 4}
; DRON coordinate components simple array keys
XComp := 1
YComp := 2
; DRON mapping sdi zone bit population count, to direction type
POP_CENTER := 0
POP_CARD := 1
POP_DIAG := 2
; DRON analog history simultFinal bits
FINAL_DASHZONE := 1
FINAL_SDIZONE := 1<<1

    
; analog history
aHistory := []
Loop, % AHISTORYLEN { 
  aHistory[A_Index, ah.x] := ANALOG_STICK_NEUTRAL
  aHistory[A_Index, ah.y] := ANALOG_STICK_NEUTRAL
  aHistory[A_Index, ah.timestamp] := 0
  aHistory[A_Index, ah.simultFinal] := 0
}
currentIndexA := 1 ; DRON the index for accessing analog history

; // for sdi nerfs, we want to record only movement between sdi zones, ignoring movement within zones
sdiZoneHist := []
Loop, % SHISTORYLEN {
  sdiZoneHist[A_Index, zh.timestamp] := 0
  sdiZoneHist[A_Index, zh.stale] := true
  sdiZoneHist[A_Index, zh.zone] := ZONE_CENTER
  sdiZoneHist[A_Index, zh.popcount] := 0
}
sdiSimultZone := ZONE_CENTER
sdiSimultTimestamp := -1000

; // for pivot nerfs, we want to record only movement between dash zones, ignoring movement within zones
dashZoneHist := []
Loop, % DHISTORYLEN {
  dashZoneHist[A_Index, zh.timestamp] := 0
  dashZoneHist[A_Index, zh.stale] := true
  dashZoneHist[A_Index, zh.zone] := NOT_DASH
}
dashSimultTimestamp := -1000
unsavedDashZone := NOT_DASH
unsavedDashTimestamp := -1000
detectorDirection := P_NONE
unsavedDirection := P_NONE  ; pivot values : P_NONE , P_RIGHTLEFT , P_LEFTRIGHT
savedDirection := P_NONE
detectorPivotTimestamp := -1000
unsavedPivotTimestamp := -1000
savedPivotTimestamp := -1000


; b0xx constants. ; DRON coordinates get mirrored and rotated appropiately thanks to reflectCoords()
coordsOrigin := [0, 0]
coordsVertical := [0, 1]
coordsVerticalModX := [0, 0.5375]
coordsVerticalModY := [0, 0.7375]
coordsHorizontal := [1, 0]
coordsHorizontalModX := [0.6625, 0]
coordsHorizontalModY := [0.3375, 0]
coordsQuadrant := [0.7, 0.7]            ;  magnitude < angle    is the polar form notation of 2d coordinates
coordsQuadrantModX := [0.7375, 0.3125]  ;  0.8000    < 22.96 deg
coordsQuadrantModY := [0.3125, 0.7375]  ;  

coordsAirdodgeVertical := coordsVertical
coordsAirdodgeVerticalModX := coordsVerticalModX
coordsAirdodgeVerticalModY := coordsVerticalModY
coordsAirdodgeHorizontal := coordsHorizontal
coordsAirdodgeHorizontalModX := coordsHorizontalModX
coordsAirdodgeHorizontalModY := coordsHorizontalModY
coordsAirdodgeQuadrant12 := coordsQuadrant
coordsAirdodgeQuadrant34 := [0.7, 0.6875]
coordsAirdodgeQuadrantModX := [0.6375, 0.375] ; 30.47 deg. b0xx default
coordsAirdodgeQuadrant12ModY := [0.475, 0.875] ; 61.50 deg. b0xx default
coordsAirdodgeQuadrant34ModY := [0.5, 0.85] ; 59.53 deg b0xx default

/* DRON   "Firefox Angles" 
   Note to Self: the closer the C-button is to the left hand, the closer the angle
   to QuadrantMod (23 degrees) and the farther the angle from 45 degrees. Angles are evenly
   distributed for use with Firefox (Fox Falco Up-B) without regard for vector
   magnitude, which can be small, inconsistent
   Player accesses them by pressing a diagonal, a mod button and a C-button
*/

coordsFirefoxModXCClosestToAxis := [0.7, 0.3625]     ; ~27 deg
coordsFirefoxModXCSecondClosestToAxis := [0.7875, 0.4875]  ; ~32 deg
coordsFirefoxModXCSecondClosestTo45Deg := [0.7, 0.5125]       ; ~36 deg
coordsFirefoxModXCClosestTo45Deg := [0.6125, 0.525]  ; ~41 deg
coordsFirefoxModYCClosestTo45Deg := [0.6375, 0.7625] ; ~50 deg
coordsFirefoxModYCSecondClosestTo45Deg := [0.5125, 0.7]       ; ~54 deg
coordsFirefoxModYCSecondClosestToAxis := [0.4875, 0.7875]  ; ~58 deg
coordsFirefoxModYCClosestToAxis := [0.3625, 0.7]     ; ~63 deg

/* DRON    "Extended Up-B Angles" 
   Note to Self: These are not for use with Fox or Falco but with other characters
   with Up-B angles. These coordinates are closer to the rim than Firefox coordinates.
   That means they have a bigger vector magnitude. Angles aren't materially different from Firefox angles.
   The player accesses them by pressing a diagonal, a mod button
   and the B button; C-button angling is optional
 */
coordsExtendedFirefoxModX := [0.9125, 0.3875]       ; ~23 deg
coordsExtendedFirefoxModXCClosestToAxis := [0.875, 0.45]     ; ~27 deg
coordsExtendedFirefoxModXCSecondClosestToAxis := [0.85, 0.525]     ; ~32 deg
coordsExtendedFirefoxModXCSecondClosestTo45Deg := [0.7375, 0.5375]    ; ~36 deg
coordsExtendedFirefoxModXCClosestTo45Deg := [0.6375, 0.5375] ; ~40 deg
coordsExtendedFirefoxModYCClosestTo45Deg := [0.5875, 0.7125] ; ~50 deg
coordsExtendedFirefoxModYCSecondClosestTo45Deg := [0.5875, 0.8]       ; ~54 deg
coordsExtendedFirefoxModYCSecondClosestToAxis := [0.525, 0.85]     ; ~58 deg
coordsExtendedFirefoxModYCClosestToAxis := [0.45, 0.875]     ; ~63 deg
coordsExtendedFirefoxModY := [0.3875, 0.9125]       ; ~67 deg

; We are going to set personalized c-button angle bindings
cStickAngling := ["ClosestToAxis", "SecondClosestToAxis", "SecondClosestTo45Deg", "ClosestTo45Deg"]
cIniCompleteness := 0
cIniDir := A_ScriptDir "\c-stick-angle-bindings.ini"
; if c-stick-angle-bindings.ini doesn't exist, create it
AttributeString := FileExist(cIniDir)
if (!AttributeString) {
  cIniTextDefault := "
  (
[cStickAngling]
" cStickAngling[1] "=c-down
" cStickAngling[2] "=c-left
" cStickAngling[3] "=c-up
" cStickAngling[4] "=c-right
  )"
  FileAppend, % cIniTextDefault, % cIniDir
}
; c-stick-angle-bindings ini completeness check
for index, element in cStickAngling {
  IniRead, cButtonBringsAngle%element%, c-stick-angle-bindings.ini, cStickAngling, % element, %A_Space% 
  if (cButtonBringsAngle%element% = "cDown" or cButtonBringsAngle%element% = "c-down") {
    cIniCompleteness |= 1
  } else if (cButtonBringsAngle%element% = "cLeft" or cButtonBringsAngle%element% = "c-left") {
    cIniCompleteness |= 1<<1
  } else if (cButtonBringsAngle%element% = "cUp" or cButtonBringsAngle%element% = "c-up") {
    cIniCompleteness |= 1<<2
  } else if (cButtonBringsAngle%element% = "cRight" or cButtonBringsAngle%element% = "c-right") {
    cIniCompleteness |= 1<<3
  }
}
; dealing with an incomplete c-stick-angle-bindings ini
if (cIniCompleteness != (1<<4) - 1) {
  cIniDefault := ["cDown", "cLeft", "cUp", "cRight"]
  for index, element in cStickAngling {
    cButtonBringsAngle%element% := cIniDefault[index]
  }
}  
; assigning firefox angles and c-stick extended up-B angles according to c-stick-angle-bindings ini
for index, element in cStickAngling {
  if (cButtonBringsAngle%element% = "cDown" or cButtonBringsAngle%element% = "c-down") {
    coordsFirefoxModXCDown := coordsFirefoxModXC%element%
    coordsFirefoxModYCDown := coordsFirefoxModYC%element%
    coordsExtendedFirefoxModXCDown := coordsExtendedFirefoxModXC%element%
    coordsExtendedFirefoxModYCDown := coordsExtendedFirefoxModYC%element%
  } else if (cButtonBringsAngle%element% = "cLeft" or cButtonBringsAngle%element% = "c-left") {
    coordsFirefoxModXCLeft := coordsFirefoxModXC%element%
    coordsFirefoxModYCLeft := coordsFirefoxModYC%element%
    coordsExtendedFirefoxModXCLeft := coordsExtendedFirefoxModXC%element%
    coordsExtendedFirefoxModYCLeft := coordsExtendedFirefoxModYC%element%
  } else if (cButtonBringsAngle%element% = "cUp" or cButtonBringsAngle%element% = "c-up") {
    coordsFirefoxModXCUp := coordsFirefoxModXC%element%
    coordsFirefoxModYCUp := coordsFirefoxModYC%element%
    coordsExtendedFirefoxModXCUp := coordsExtendedFirefoxModXC%element%
    coordsExtendedFirefoxModYCUp := coordsExtendedFirefoxModYC%element%
  } else if (cButtonBringsAngle%element% = "cRight" or cButtonBringsAngle%element% = "c-right") {
    coordsFirefoxModXCRight := coordsFirefoxModXC%element%
    coordsFirefoxModYCRight := coordsFirefoxModYC%element%
    coordsExtendedFirefoxModXCRight := coordsExtendedFirefoxModXC%element%
    coordsExtendedFirefoxModYCRight := coordsExtendedFirefoxModYC%element%
  }
}


 /* DRON the banned coordinate list should be near here if we are going to put it in the script 
 */


/* DRON For_Easy_Nerf_Testing
  0 no test mode
  1 pivoting, to u-tilt or d-tilt range in less than 8 frames
  2 pivoting, to up-angled f-tilt in less than 8 frames
  3 pivoting, to down-angled f-tilt in less than 8 frames
  4 dashing above or below deadzone (to time out the tap-jump or d-smash execution window by placing the stick in the same active y zone)
    then pivoting and inputting an up-tilt or d-tilt under 5 frames
  n Crouching to u-tilt range in less than 3 frames

  follow execution instructions below
*/
Switch nerfTestMode
{
  case 1:  ; pivot by left/right NSOCD while pressing up or down (optional: then press A)
      coordsVertical := [0, ANALOG_DEAD_MAX + 2 * ANALOG_STEP]
      coordsQuadrant := [0.9875, 0.0125]
  case 2:  ; pivot by modX while pressing up (optional: then press A)
      coordsQuadrant := [0.9875, 0.0125]
      coordsvertical := coordsOrigin
  case 3:  ; pivot by modX while pressing down (optional: then press A)
      coordsQuadrant := [0.9875, 0.0125]
      coordsvertical := coordsOrigin
      coordsQuadrantModX := [ANALOG_DEAD_MAX + 7 * ANALOG_STEP, ANALOG_DEAD_MAX + ANALOG_STEP]
  case 4:  ; pivot by left/right NSOCD while holding one of the vertical keys (optional: then press A)
      coordsQuadrant := [0.9000 + ANALOG_STEP, ANALOG_DEAD_MAX + 2 * ANALOG_STEP]
      coordsVertical := [0, ANALOG_DEAD_MAX + 2 * ANALOG_STEP]

}

; Debug info
/*
  DRON In the original code, lastCoordTrace was used as an intended inputs display
  as opposed to a final, real outputs display. These two did differ in the turnaround side B case. 
  
  from what i gathered, this is how you read its values:
  L-Q-X means
  airdodge quadrant modX input
  F-Y-U means
  firefox/extended modY c-up input

  L airdodge   H horizontal   X modX  U c-up
  N no shield  Q quadrant     Y modY  L c-left
               Y vertical             D c-down
               F firefox/ext          R c-right
               O [0, 0]
*/
lastCoordTrace := ""


reverseNeutralBNerf(aX, aY) {
  global

  result := [aX, aY]

  if (buttonB and Abs(aX) > ANALOG_DEAD_MAX and Abs(aY) <= ANALOG_DEAD_MAX) { ; out of x deadzone and in y deadzone
    if (aX < 0 and aX > ANALOG_SPECIAL_LEFT) { ; inside leftward neutral-B range
      result[XComp] := ANALOG_STICK_MIN
      result[YComp] := ANALOG_STICK_NEUTRAL
    } else if (aX > 0 and aX < ANALOG_SPECIAL_RIGHT) {
      result[XComp] := ANALOG_STICK_MAX
      result[YComp] := ANALOG_STICK_NEUTRAL
    } 
  }

  return result
}


yDeadzoneTrackAndFlag(aX, aY) {
  global
  
  if (aY > ANALOG_DEAD_MAX) {
    if (aHistory[currentIndexA, ah.y] <= ANALOG_DEAD_MAX) { ; if the entry before current does not go above y deadzone
      upY := true
      upYTimestamp := currentTimeMS
    } 
  } else {
    upY := false
  }

  if (aY < ANALOG_DEAD_MIN) {
    if (aHistory[currentIndexA, ah.y] >= ANALOG_DEAD_MIN) {
      downY := true
      downYTimestamp := currentTimeMS
    }
  } else {
    downY := false
  }

  return
}


dashZone(aX) { ; 
  global ANALOG_DASH_LEFT
  global ANALOG_DASH_RIGHT
  global NOT_DASH
  global ZONE_L
  global ZONE_R
  if (aX <= ANALOG_DASH_LEFT) {
    result := ZONE_L
  } else if (aX >= ANALOG_DASH_RIGHT) {
    result := ZONE_R
  } else {
    result := NOT_DASH
  }
  return result
}


  /*

              y ^
                |
                |
    dashL |           |dashR
   ---- 2 |     o     | 1 ---->
                   (aX)rX    x
                |
                |
      

    .a pivot is detected by examining the limitedOutput x (aX). its timestamp is currentTime and its staleness is none
    .(aX) needs to be nerfed because its below y deadzone 
    .output is nerfed, yielding rX
    .dashHistory updates but because rX is in the same zone as 1, no new entries are added into the dash history
    .---> in the next pass, the pivot detector will detect a failure in dash length
  */
detectPivot(aX) {
  global

  result := P_NONE
  pivotDebug := false ; if you want to enable detectPivot() testing, set this true
  pivotDiscarded := -1 ; for testing
  detectorDashZone := dashZone(aX)
  /* ; DRON ignoring timing, has the player inputted the correct sequence?
    pivot inputs:
    --- past --- current
    3---2---1---aX        means:      notes:
        R   L   N       p rightleft
    R   -   L   N       p rightleft   (it's R N L N because there can't be R R or L L)
        L   R   N       p leftright
    L   -   R   N       p leftright   (L N R N)
  */

  if (detectorDashZone == NOT_DASH) {  
    if (dashZoneHist[1, zh.zone] == ZONE_L and (dashZoneHist[2, zh.zone] == ZONE_R or dashZoneHist[3, zh.zone] == ZONE_R)) {
      result := P_RIGHTLEFT
      pivotDiscarded := false
    }
    else if (dashZoneHist[1, zh.zone] == ZONE_R and (dashZoneHist[2, zh.zone] == ZONE_L or dashZoneHist[3, zh.zone] == ZONE_L)) {
      result := P_LEFTRIGHT
      pivotDiscarded := false
    }
  }

  /*
  debugMessage := detectorDashZone . "-"
  Loop, % DHISTORYLEN {
    debugMessage .= dashZoneHist[A_Index, zh.zone] . "-"
  }
  Msgbox % debugMessage
  */ 

  if (result != P_NONE) {  ; this is the code block for discarding pivot attempts

    pivotLength := currentTimeMS - dashZoneHist[1, zh.timestamp] ; ms, stores latest dash duration

    ; //check for staleness (meaning that some inputs are too old for this to be a successful pivot)
    if dashZoneHist[2, zh.stale] {
      result := P_NONE
      if (pivotDiscarded == false) {
        pivotDiscarded := 1
      }
    } else if (dashZoneHist[2, zh.zone] == NOT_DASH and dashZoneHist[3, zh.stale]) { ; aX neutral  1 opposite  2 neutral  3 cardinal
      result := P_NONE
      if (pivotDiscarded == false) {
        pivotDiscarded := 1
      }

    ; has the player only held the latest dash for around 1 frame in duration? that's necessary for pivoting
    } else if (pivotLength < TIMELIMIT_HALFFRAME or pivotLength > TIMELIMIT_FRAME + TIMELIMIT_HALFFRAME) {
      ; //less than 50% chance it was a successful pivot
      result := P_NONE
      if (pivotDiscarded == false) {
        pivotDiscarded := 2
      }    
    }
  } ; end of block for discarding pivot attempts

  if pivotDebug {
    Switch pivotDiscarded {
      Case false:
          if (result == P_LEFTRIGHT) {
            Msgbox P_LEFTRIGHT
          } else if (result == P_RIGHTLEFT) {
            Msgbox P_RIGHTLEFT
          }
      Case 1:
          Msgbox stage 1 stale p_none
      Case 2:
          Msgbox stage 2 length p_none
    }
  }

  return result
}


scaler(component, factor) { ; just in case, let me say this will return a coordinate component of the form 0.0125n
  result := Round(80 * component * factor) / 80
  return result
}


pivotNerf(aX, aY, direction, pivotTimestamp) { 
  global

  result := [aX, aY]

  ; unityDistanceFactor in combination with scaler() will set the result's magnitude as ~0.9875. don't want to go past the unit circle
  unityDistanceFactor := (ANALOG_STICK_MAX - ANALOG_STEP) / sqrt(aX**2 + aY**2) ;                                   for no good reason

  /*  DRON
      if upY and the player has not shut off tap jump with actions done before completing the pivot (such as angled dash)
      and tap jump hasn't been forced already for this pivot
        force tap jump
      if downY and tap-down can be done
        carry to rim
      if the player has shut off tap jump with actions done before completing the pivot
      and tap jump hasn't been forced already for this pivot
        force f-tilt
      if the player has shut off tap down with actions done before completing the pivot
        force f-tilt
  */

  ; if upY and the player has not shut off tap jump WITH actions done before completing the pivot (such as upY dashes)
  if (upY and (currentTimeMS - upYTimestamp < TIMELIMIT_TAPSHUTOFF or upYTimestamp >= pivotTimestamp) and not pivotForced2FJump) { 
    pivotForced2FJump := false ; change to true to activate CarVac HayBox style timed nerf 
    force2FJumpTimestamp := currentTimeMS

    if (Abs(aX) > aY) {   ; //Force all upward angles to a minimum of 45deg away from the horizontal
                          ; //to prevent pivot uftilt and ensure tap jump
      if (aX > 0) {
        result[XComp] := Round(79 * cos(45 * DEG_TO_RADIAN)) / 80 ; coordinate distance from origin will be ~79/80 or ~0.9875
      } else if (aX < 0) {
        result[XComp] := - Round(79 * cos(45 * DEG_TO_RADIAN)) / 80
      }
      result[YComp] := Round(79 * sin(45 * DEG_TO_RADIAN)) / 80 

    } else {
      result[XComp] := scaler(aX, unityDistanceFactor) ; again, distance will be ~79/80 or ~0.9875
      result[YComp] := scaler(aY, unityDistanceFactor)
    }

  ; if the player hasn't shut off tap downsmash
  } else if (downY and currentTimeMS - downYTimestamp < TIMELIMIT_TAPSHUTOFF) { 

    result[XComp] := scaler(aX, unityDistanceFactor)
    result[YComp] := scaler(aY, unityDistanceFactor)

  ; if the player shut off the tap-jump or tap upsmash, by pivoting with upY dashes
  } else if (upY and upYTimestamp < pivotTimestamp
    and currentTimeMS - pivotTimestamp < TIMELIMIT_PIVOTTILT_YDASH and not pivotForced2FJump) {
              
    if (direction == P_RIGHTLEFT) {
      result[XComp] := - FORCE_FTILT                ; apparently CarVac uses the opposite x directions for the ftilt.
    } else if (direction == P_LEFTRIGHT) {          ; what does the proposal team mean when saying pressing A too early?
      result[XComp] := FORCE_FTILT
    }
    result[YComp] := FORCE_FTILT

  ; if the player shut off tap downsmash, by pivoting with upY dashes
  } else if (downY and downYTimestamp < pivotTimestamp and currentTimeMS - pivotTimestamp < TIMELIMIT_PIVOTTILT_YDASH) {
    if (direction == P_RIGHTLEFT) {
      result[XComp] := - FORCE_FTILT  
    } else if (direction == P_LEFTRIGHT) {
      result[XComp] := FORCE_FTILT
    }
    result[YComp] := - FORCE_FTILT
  } ; else if (downY and downYTimestamp >= pivotTimestamp) no nerfs are applied

  return result
}


crouchUptiltLockout(aX, aY) {
  global
  result := [aX, aY]

  if (aY > ANALOG_CROUCH) {
    if (aHistory[currentIndexA, ah.y] <= ANALOG_CROUCH) { 
      uncrouchTimestamp := currentTimeMS ; the player just uncrouched (or rather exited the crouch range)
    }
  }

  if (aY > ANALOG_DEAD_MAX and Abs(aX) <= ANALOG_DEAD_MAX
    and currentTimeMS - uncrouchTimestamp < TIMELIMIT_DOWNUP and not crouchForced2FJump) {
    result[XComp] := ANALOG_STICK_NEUTRAL  
    result[YComp] := ANALOG_STICK_MAX        
    crouchForced2FJump := false ; change to true to activate CarVac HayBox style timed nerf 
    force2FJumpTimestamp := currentTimeMS
  } else if (currentTimeMS - uncrouchTimestamp >= TIMELIMIT_DOWNUP) {
    crouchForced2FJump := false
  }

  return result
}


countPopulation(bitsIn) { ; //not a general purpose popcount, this is specifically for sdi zones
  result := 0
  Loop,4 {
    result += (bitsIn>>(A_Index-1)) & 1
  }
  return result
}


sdiZone(aX, aY) { 
  global        

  result := 0
  if (Min(Abs(aX), Abs(aY)) <= ANALOG_DEAD_MAX) { ; is x or y in the deadzone
    if (aX >= ANALOG_SDI_RIGHT) {
      result |= ZONE_R
    } else if (aX <= ANALOG_SDI_LEFT) {
      result |= ZONE_L
    } else if (aY >= ANALOG_SDI_UP) {
      result |= ZONE_U
    } else if (aY <= ANALOG_SDI_DOWN) {
      result |= ZONE_D
    }
  } else if (aX**2 + aY**2 >= MELEE_SDI_RAD) { ; is the distance far enough for diagonal sdi
    if (aX > 0) {
      result |= ZONE_R
    } else { ; if aX < 0
      result |= ZONE_L
    }
    if (aY > 0) {
        result |= ZONE_U
    } else { ; if aY < 0
        result |= ZONE_D
    }
  }

  return result
}


isBurstSDI1Button(outputIn) {
  global

  output := outputIn

  ; //detect repeated center-cardinal sequences, or repeated cardinal-diagonal sequences
  ; // if we're changing zones back and forth
  if (sdiZoneHist[1, zh.zone] != sdiZoneHist[2, zh.zone]
    and sdiZoneHist[1, zh.zone] == sdiZoneHist[3, zh.zone]
    and sdiZoneHist[2, zh.zone] == sdiZoneHist[4, zh.zone]) {
    ;//check the time duration
    timePressToPress := sdiZoneHist[1, zh.timestamp] - sdiZoneHist[3, zh.timestamp]
    ;//We want to nerf it if there is more than one press every TIMELIMIT_BURSTSDI ms, 
    ;//but not if the previous release duration is less than 1 frame
    if (sdiZoneHist[4, zh.stale] == false and timePressToPress < TIMELIMIT_BURSTSDI and timePressToPress > TIMELIMIT_DEBOUNCE) {
      if (sdiZoneHist[1, zh.zone] == ZONE_CENTER or sdiZoneHist[2, zh.zone] == ZONE_CENTER) {
        output |= BITS_SDI_TAP_CARD ;//if one of the pairs of zones is zero, it's tapping a cardinal (or tapping a diagonal modifier)
      } else if (sdiZoneHist[1, zh.popcount] + sdiZoneHist[2, zh.popcount] == POP_DIAG + POP_CARD 
        and (sdiZoneHist[1, zh.zone] & sdiZoneHist[2, zh.zone])) {
        output |= BITS_SDI_TAP_DIAG ;//one pair is cardinal and the other is adjacent diagonal
      }
    }
  }

  return output
}


isBurstSDICrDg(outputIn) {
  global
  output := outputIn

  ;//if the last 5 inputs are in the origin, one cardinal, and one diagonal
  ;//and that there was a recent return to center
  ;//at least one of each zone, and at least two diagonals
  origCount := 0
  cardCount := 0
  diagCount := 0
  diagZone := (1<<8) - 1 ; 0b1111'1111
  Loop,5 {
    popcnt := sdiZoneHist[A_Index, zh.popcount]
    if (popcnt == POP_CENTER) {
      origCount += 1
    } else if (popcnt == POP_CARD) {
      cardCount += 1
    } else { ; if popcnt == POP_DIAG
      diagCount += 1
      diagZone &= sdiZoneHist[A_Index, zh.zone] ;//if two of these diagonals don't match, it'll have zero or one bits set
                                                ; if they match, the pop will be two bits
    }
  }

  ;//to limit scope of these vars
  ;//check the bit count of diagonal matching
  diagMatch := countPopulation(diagZone) == 2
  ;//check whether the input was fast enough
  shortTime := (sdiZoneHist[1, zh.timestamp] - sdiZoneHist[5, zh.timestamp] < TIMELIMIT_BURSTSDI
    and sdiZoneHist[1, zh.timestamp] - sdiZoneHist[2, zh.timestamp] > TIMELIMIT_SIMULTANEOUS
    and sdiZoneHist[5, zh.stale] == false)
  ;// if only the same diagonal was pressed
  ;//              if the origin, cardinal, and two diagonals were all entered
  ;//                                                            within the time limit
  if(diagMatch and origCount and cardCount and diagCount > 1 and shortTime) {
    output |= BITS_SDI_TAP_CRDG
  }

  return output
}


isBurstSDIQuarterCircle(outputIn) {
  global
  output := outputIn

  ;//3 input sdi
  ;//center-cardinal-diagonal-diagonal
  ;//center-cardinal-diagonal-same cardinal-diagonal
  ;//all directions except center must be the same
  cardZone := (1<<8) - 1 ; 0b1111'1111
  diagZone := (1<<8) - 1
  origCount = 0;
  cardCount = 0;
  diagCount = 0;
  Loop,5 {
    popcnt := sdiZoneHist[A_Index, zh.popcount]
    if (popcnt == POP_CENTER) {
      origCount += 1
      break ;//stop counting once there's an origin
    } else if (popcnt == POP_CARD) {
      cardCount += 1
      cardZone &= sdiZoneHist[A_Index, zh.zone] ;//if there are two different cardinals then it'll have zero bits set
    } else { ; if popcnt == POP_DIAG
      diagCount += 1
      diagZone &= sdiZoneHist[A_Index, zh.zone] ; if these are adjacent, it'll have one bit set
    }
  }
  
  ;//to limit scope of these vars
  ;//check the bit count of diagonal matching
  adjacentDiag := countPopulation(diagZone) == 1 and (cardZone & diagZone)
  shortTime := sdiZoneHist[1, zh.timestamp] - sdiZoneHist[4, zh.timestamp] < TIMELIMIT_BURSTSDI
    and not (sdiZoneHist[3, zh.stale] or (sdiZoneHist[4, zh.stale] and sdiZoneHist[4, zh.zone] != ZONE_CENTER))
  ;//if it hit two different diagonals
  ;//                  hit origin, at least one cardinal, and two diagonals
  ;//                                                                within the time limit
  if (adjacentDiag and origCount and cardCount and diagCount > 1 and shortTime) {
    output |= BITS_SDI_QUARTERC
  }

  return output
}


detectBurstSDI(aX, aY) {
  global

  output := 0
  sdiZoneHist[1, zh.zone] := sdiZone(aX, aY)
  sdiZoneHist[1, zh.popcount] := countPopulation(sdiZoneHist[1, zh.zone])
  sdiZoneHist[1, zh.timestamp] := currentTimeMS
  sdiZoneHist[1, zh.stale] := false

  output := isBurstSDI1Button(output)
  if (sdiZoneHist[1, zh.zone] != sdiZoneHist[2, zh.zone]) {
    output := isBurstSDICrDg(output)
  }
  output := isBurstSDIQuarterCircle(output)

  ;//return the last cardinal in the zone list before the last diagonal, useful for SDI diagonal nerfs.
  Loop, % SHISTORYLEN {
    if (sdiZoneHist[A_Index, zh.popcount] == POP_DIAG) {
      i := A_Index + 1
      while (i <= SHISTORYLEN) {
        if (sdiZoneHist[i, zh.popcount] == POP_CARD) {
          output |= sdiZoneHist[i, zh.zone]
          break
        }
        i += i
      }
      break
    }
  }

  return output
}


getFuzzyHorizontal100(outputX, outputY, historyX, historyY) {   ; DRON if you input +-1.0, that value may be passed to the game
  global ANALOG_STICK_MIN                                       ;      as +-0.9875 for as long as you hold the stick.
  global ANALOG_STICK_NEUTRAL
  global ANALOG_STICK_MAX
  global ANALOG_STEP
  global FUZZ_1_00_PROBABILITY

  result := outputX

  /*
  this is how it's done:
  if the output X is x cardinal or close, and the output Y is the analog stick neutral
      if the history X is a fuzzed x cardinal of the same sign, and history Y is neutral
        output X := history X
      else
        Fuzz X
  else no action
  */

  if (Abs(outputX) >= ANALOG_STICK_MAX - ANALOG_STEP and outputY == ANALOG_STICK_NEUTRAL) {
    if (Abs(historyX) >= ANALOG_STICK_MAX - ANALOG_STEP and historyY == ANALOG_STICK_NEUTRAL
      and not ((outputX > 0) ^ (historyX > 0)) ) {
      result := historyX
    } else {
      Random, ran100, 0, 99  ; spans 100%
      if (outputX > 0) {
        result := ANALOG_STICK_MAX - ANALOG_STEP * (ran100 < FUZZ_1_00_PROBABILITY) ; <-- chance that the result is 0.9875
      } else { ; if outputX < 0
        result := ANALOG_STICK_MIN + ANALOG_STEP * (ran100 < FUZZ_1_00_PROBABILITY)
      }
    }
  }

  return result
}


miscellaneousTimestamps() {
  global
  return
}


updateDashZoneHistory() {
  global

  /* we need to see if enough time has passed for the input to not be part of a multiple key single input. and that it is different
  from the last entry and so we need a new entry
  */
  if (currentTimeMS - dashSimultTimestamp >= TIMELIMIT_SIMULTANEOUS
    and dashZoneHist[1, zh.zone] != unsavedDashZone) {
    i := DHISTORYLEN - 1
    ; push everything 1 slot towards the back of the timeline
    while (i >= 1) { 
      dashZoneHist[i + 1, zh.timestamp] := dashZoneHist[i, zh.timestamp]
      dashZoneHist[i + 1, zh.stale] := dashZoneHist[i, zh.stale]
      dashZoneHist[i + 1, zh.zone] := dashZoneHist[i, zh.zone]
      i -= 1
    }

    dashZoneHist[1, zh.timestamp] := unsavedDashTimestamp
    dashZoneHist[1, zh.stale] := false
    dashZoneHist[1, zh.zone] := unsavedDashZone    
  } 
  /* debug tool
  else if (currentTimeMS - dashSimultTimestamp < TIMELIMIT_SIMULTANEOUS
    and dashZoneHist[1, zh.zone] != unsavedDashZone) {
    Msgbox simultaneous change in dash zones
  }
  */

  return
}

makeDashZoneStale() {
  global
  ; check if a dash entry (and subsequent ones) are stale, and flag them
  Loop, % DHISTORYLEN { 
    if ((currentTimeMS - dashZoneHist[A_Index, zh.timestamp]) > (TIMESTALE_PIVOT_INPUTSEQUENCE)) {
      staleIndex := A_Index ; found stale entry
      while (staleIndex <= DHISTORYLEN) {
        dashZoneHist[staleIndex, zh.stale] := true
        staleIndex += 1
      }
      break
    }
  }

  return
}

savePivotHistory() {
  global

  updateDashZoneHistory()
  makeDashZoneStale()

  ; if there's an unsaved direction and the window for simultaneous inputs expired...
  if (unsavedDirection != P_NONE and currentTimeMS - dashSimultTimestamp >= TIMELIMIT_SIMULTANEOUS) {
    savedPivotTimestamp := unsavedPivotTimestamp
    savedDirection := unsavedDirection
    ; savedDirection/pivotTimestamp will deal with the nerf from now on - and we need to avoid re-firing this "if"
    unsavedDirection := P_NONE  
  }

  return
}

rememberDashZonesNotSaved(aX) {
  global
  ; if the dashzone that will sent to the game is different from the previous, then we record
  if (dashZone(aX) != unsavedDashZone) {
    unsavedDashZone := dashZone(aX)
    unsavedDashTimestamp := currentTimeMS
    ; we need to see if the current input actually represents a fresh new dash zone (either from a lone input or 
    ; as the FIRST keystroke of a group of simultaneous keystrokes) in order to assign a timestamp to it
    if (currentTimeMS - dashSimultTimestamp >= TIMELIMIT_SIMULTANEOUS) {
      dashSimultTimestamp := currentTimeMS
      aHistory[currentIndexA, ah.simultFinal] |= FINAL_DASHZONE
    }
  }

  return
}


updateSDIZoneHistory() {
  global

  ; we need to see if enough time has passed for the input to not be part of a multiple key single input

  ; sdiZoneHist update
  ; we reserve sdiZoneHist[1, zh] for sdi detector
  if (currentTimeMS - sdiSimultTimestamp >= TIMELIMIT_SIMULTANEOUS
    and sdiZoneHist[2, zh.zone] != sdiSimultZone) {
    i := SHISTORYLEN - 1
    while (i >= 2) {
      sdiZoneHist[i + 1, zh.timestamp] := sdiZoneHist[i, zh.timestamp]
      sdiZoneHist[i + 1, zh.stale] := sdiZoneHist[i, zh.stale]
      sdiZoneHist[i + 1, zh.zone] := sdiZoneHist[i, zh.zone]
      sdiZoneHist[i + 1, zh.popcount] := sdiZoneHist[i, zh.popcount]
      i -= 1
    }
    sdiZoneHist[2, zh.timestamp] := sdiSimultTimestamp
    sdiZoneHist[2, zh.stale] := false
    sdiZoneHist[2, zh.zone] := sdiSimultZone
    sdiZoneHist[2, zh.popcount] := countPopulation(sdiSimultZone)
  }

  return
}

makeSDIZoneStale() {
  global

  Loop, % SHISTORYLEN { ; check if a sdi zone entry (and subsequent ones) are stale, and flag them
    if (currentTimeMS - sdiZoneHist[A_Index, zh.timestamp] > TIMESTALE_SDI_INPUTSEQUENCE) {
      staleIndex := A_Index ; found stale entry
      while(staleIndex <= SHISTORYLEN) {
        sdiZoneHist[staleIndex, zh.stale] := true
        staleIndex += 1
      }
      break
    }
  }

  return
}

saveSDIHistory() {
  global

  updateSDIZoneHistory()
  makeSDIZoneStale()

  return
}

rememberSDIZonesNotSaved(aX, aY) {
  global

  /*

  if (currentTimeMS - sdiSimultTimestamp >= TIMELIMIT_SIMULTANEOUS and sdiZone(aX, aY) != sdiSimultZone) {
    sdiSimultZone := sdiZone(aX, aY)
    sdiSimultTimestamp := currentTimeMS
    aHistory[currentIndexA, ah.simultFinal] |= FINAL_SDIZONE
  }
  */
  
  return
}


updateAnalogHistory(aX, aY) {
  global

  ; currentIndexA is lagging 1 behind the current input. we need to see if the current input actually represents a new analog coordinate
  ; otherwise the history simply ignores the repeated input and the index doesn't move from what was once new
  if (aHistory[currentIndexA, ah.x] != aX or aHistory[currentIndexA, ah.y] != aY) {
    ; save current analog stick position info in history
    currentIndexA := (currentIndexA == HISTORYLEN) ? 1 : (currentIndexA + 1)  ; this index goes in circles...
    aHistory[currentIndexA, ah.timestamp] := currentTimeMS
    aHistory[currentIndexA, ah.x] := aX
    aHistory[currentIndexA, ah.y] := aY
    aHistory[currentIndexA, ah.simultFinal] := 0
  }

  return
}


limitOutputs(rawCoords) { ; DRON ---------------------------------------------------------------------
  global

  currentTimeMS := A_TickCount

  savePivotHistory()

  saveSDIHistory()
  miscellaneousTimestamps()

  ; these are the coordinates that this function will return. they will include any necessary nerf
  limitedOutput := {leftStickX : rawCoords[XComp], leftStickY : rawCoords[YComp]}
  
  ; a jump that lasts for JUMP_TIME ms (2 frames) that is a way to nerf u-tilt attempts
  if (currentTimeMS - force2FJumpTimestamp < JUMP_TIME 
    and ((pivotForced2FJump and unsavedDirection == P_NONE) 
    or crouchForced2FJump)) { 
    limitedOutput.leftStickX := aHistory[currentIndexA, ah.x] ; force output to keep the last coordinate (a jump)
    limitedOutput.leftStickY := aHistory[currentIndexA, ah.y]
  
  } else { ; process the player input and converts it into legal output

    processed := reverseNeutralBNerf(limitedOutput.leftStickX, limitedOutput.leftStickY)  
    limitedOutput.leftStickX := processed[XComp]
    limitedOutput.leftStickY := processed[YComp]

    yDeadzoneTrackAndFlag(limitedOutput.leftStickX, limitedOutput.leftStickY)

    ; if the dash zone of the player input changes, we need to see if this marks a successful input of a pivot 
    detectorDirection := DIDNT_SCAN
    pivotWasNerfed := false
    if (dashZone(limitedOutput.leftStickX) != unsavedDashZone) {
      detectorDirection := detectPivot(limitedOutput.leftStickX)
      if (detectorDirection != P_NONE) {
        pivotForced2FJump := false
        detectorPivotTimestamp := currentTimeMS
        nerfedPivotCoords := pivotNerf(limitedOutput.leftStickX, limitedOutput.leftStickY, detectorDirection, detectorPivotTimestamp)
        pivotWasNerfed := true
      ; if the player spoiled the successful pivot instantaneously after inputting it...
      } else if (currentTimeMS - dashSimultTimestamp < TIMELIMIT_SIMULTANEOUS
          and dashSimultTimestamp <= detectorPivotTimestamp) {
          pivotForced2FJump := false
      }
    }

    ; if the instantaneous pivot detector didn't alert of a newfound pivot, we check to see if we need to nerf based on previous pivots
    if (detectorDirection != P_LEFTRIGHT and detectorDirection != P_RIGHTLEFT and not pivotWasNerfed) {
      ; if there's a pivot outputted previously and the player hasn't spoiled it with simultaneous inputs yet
      if (unsavedDirection != P_NONE and dashZone(limitedOutput.leftStickX) == unsavedDashZone) { 
        nerfedPivotCoords := pivotNerf(limitedOutput.leftStickX, limitedOutput.leftStickY, unsavedDirection, unsavedPivotTimestamp)
        pivotWasNerfed := true
      ; nerfing the output is considered until TIMELIMIT_PIVOTTILT milliseconds pass
      } else if (currentTimeMS - savedPivotTimestamp < TIMELIMIT_PIVOTTILT and not pivotWasNerfed) {
        nerfedPivotCoords := pivotNerf(limitedOutput.leftStickX, limitedOutput.leftStickY, savedDirection, savedPivotTimestamp)
        pivotWasNerfed := true
      } else {
        pivotForced2FJump := false
      }
    }

    if pivotWasNerfed {
      limitedOutput.leftStickX := nerfedPivotCoords[XComp]
      limitedOutput.leftStickY := nerfedPivotCoords[YComp]
    }

    ; crouch u-tilt nerf
    processed := crouchUptiltLockout(limitedOutput.leftStickX, limitedOutput.leftStickY)
    limitedOutput.leftStickX := processed[XComp]
    limitedOutput.leftStickY := processed[YComp]

    ; DRON WIP
    ; sdi := detectBurstSDI(limitedOutput.leftStickX, limitedOutput.leftStickY)

    ; fuzz the x +1.00 or -1.00
    limitedOutput.leftStickX := getFuzzyHorizontal100(limitedOutput.leftStickX, limitedOutput.leftStickY
      , aHistory[currentIndexA, ah.x], aHistory[currentIndexA, ah.y])

    ; if the detected pivot will be passed to the game, record it as "unsaved" 
    ; handles the case of nerfing the "neutral" of a pivot into a dash, so it damages the successful pivot input
    if (detectorDirection == P_RIGHTLEFT or detectorDirection == P_LEFTRIGHT) {
      if (dashZone(limitedOutput.leftStickX) == NOT_DASH) {
        unsavedPivotTimestamp := detectorPivotTimestamp
        unsavedDirection := detectorDirection
      } else if (dashZone(limitedOutput.leftStickX) != NOT_DASH) {
        unsavedDirection := P_NONE
      }
    } else if (detectorDirection == P_NONE){
      unsavedDirection := P_NONE
    }

  } ; end of processing the player input and converting it into legal output

  rememberSDIZonesNotSaved(limitedOutput.leftStickX, limitedOutput.leftStickY)

  rememberDashZonesNotSaved(limitedOutput.leftStickX)

  ; memorizes realtime leftstick coordinates passed to the game
  updateAnalogHistory(limitedOutput.leftStickX, limitedOutput.leftStickY)

  
  return limitedOutput
}


; Utility functions

up() {
  global
  return buttonUp and not buttonDown ; DRON here is the neutral SOCD implementation
}

down() {
  global
  return buttonDown and not buttonUp
}

left() {
  global
  return buttonLeft and not buttonRight
}

right() {
  global
  return buttonRight and not buttonLeft
}

cUp() {
  global
  return buttonCUp and not buttonCDown and not bothMods()
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
  return buttonCRight and not buttonCLeft and not bothMods()
}

modX() {
  global
  ; deactivate if either:
  ;   - modY is also held
  ;   - both left and right are held (and were pressed after modX) while neither up or down is active (
  ; DRON this last bullet point won't carry into the new code because of NSOCD
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


; Updates the position on the analog stick based on the current held buttons
; DRON new section imo
updateAnalogStick() {
  global finalCoords

  coords := getAnalogCoords()
  finalOutput := limitOutputs(coords) ; DRON this finalCoords that we pass is what we set last time
  finalCoords := [finalOutput.leftStickX, finalOutput.leftStickY]    ; and these are the coordinates that will be set next
  ; finalCoords := coords
  ; setAnalogStick(coords
  setAnalogStick(finalCoords)
}



updateCStick() {
  setCStick(getCStickCoords())
}

getAnalogCoords() {  ; DRON of note is that airdodge coordinates get priority over Firefox angles and extended angles
  global             ; DRON this restricts the accessible angles. Maybe that shouldn't happen. 
  if (anyShield()) {
    coords := getAnalogCoordsAirdodge()
  } else if (anyMod() and anyQuadrant() and (anyC() or buttonB)) {
    coords := getAnalogCoordsFirefox()
  } else {
    coords := getAnalogCoordsWithNoShield()
  }

  return reflectCoords(coords)
}

reflectCoords(coords) {
  x := coords[1]
  y := coords[2]
  if (down()) {
    y := -y
  }
  if (left()) {
    x := -x
  }
  return [x, y]
}

getAnalogCoordsAirdodge() {
  global
  if (neither(anyVert(), anyHoriz())) {
    lastCoordTrace := "L-O"
    return coordsOrigin
  } else if (anyQuadrant()) {
    if (modX()) {
      lastCoordTrace := "L-Q-X"
      return coordsAirdodgeQuadrantModX
    } else if (modY()) {
      lastCoordTrace := "L-Q-Y"
      return up() ? coordsAirdodgeQuadrant12ModY : coordsAirdodgeQuadrant34ModY
    } else {
      lastCoordTrace := "L-Q"
      return up() ? coordsAirdodgeQuadrant12 : coordsAirdodgeQuadrant34
    }
  } else if (anyVert()) {
	if (modX()) {
      lastCoordTrace := "L-V-X"
      return coordsAirdodgeVerticalModX
    } else if (modY()) {
      lastCoordTrace := "L-V-Y"
      return coordsAirdodgeVerticalModY
    } else {
      lastCoordTrace := "L-V"
      return coordsAirdodgeVertical
    }
  } else { ; if (anyHoriz())
    if (modX()) {
      lastCoordTrace := "L-H-X"
      return coordsAirdodgeHorizontalModX
    } else if (modY()) {
      lastCoordTrace := "L-H-Y"
      return coordsAirdodgeHorizontalModY
    } else {
      lastCoordTrace := "L-H"
      return coordsAirdodgeHorizontal
    }
  }
}

getAnalogCoordsWithNoShield() {
  global
  if (neither(anyVert(), anyHoriz())) {
    lastCoordTrace := "N-O"
    return coordsOrigin
  } else if (anyQuadrant()) {
    if (modX()) {
      lastCoordTrace := "N-Q-X"
      return coordsQuadrantModX
    } else if (modY()) {
      lastCoordTrace := "N-Q-Y"
      return coordsQuadrantModY
    } else {
      lastCoordTrace := "N-Q"
      return coordsQuadrant
    }
  } else if (anyVert()) {
    if (modX()) {
      lastCoordTrace := "N-V-X"
      return coordsVerticalModX
    } else if (modY()) {
      lastCoordTrace := "N-V-Y"
      return coordsVerticalModY
    } else {
      lastCoordTrace := "N-V"
      return coordsVertical
    }
  } else { ; if (anyHoriz())
    if (modX()) {
      lastCoordTrace := "N-H-X"
      return coordsHorizontalModX
    } else if (modY()) {
      lastCoordTrace := "N-H-Y"
      return coordsHorizontalModY
    } else {
      lastCoordTrace := "N-H"
      return coordsHorizontal
    }
  }
}

getAnalogCoordsFirefox() {
  global
  if (modX()) {
    if (cUp()) {
      lastCoordTrace := "F-X-U"
      return buttonB ? coordsExtendedFirefoxModXCUp : coordsFirefoxModXCUp
    } else if (cDown()) {
      lastCoordTrace := "F-X-D"
      return buttonB ? coordsExtendedFirefoxModXCDown : coordsFirefoxModXCDown
    } else if (cLeft()) {
      lastCoordTrace := "F-X-L"
      return buttonB ? coordsExtendedFirefoxModXCLeft : coordsFirefoxModXCLeft
    } else if (cRight()) {
      lastCoordTrace := "F-X-R"
      return buttonB ? coordsExtendedFirefoxModXCRight : coordsFirefoxModXCRight
    } else {
      lastCoordTrace := "F-X"
      return coordsExtendedFirefoxModX
    }
  } else if (modY()) {
    if (cUp()) {
      lastCoordTrace := "F-Y-U"
      return buttonB ? coordsExtendedFirefoxModYCUp : coordsFirefoxModYCUp
    } else if (cDown()) {
      lastCoordTrace := "F-Y-D"
      return buttonB ? coordsExtendedFirefoxModYCDown : coordsFirefoxModYCDown
    } else if (cLeft()) {
      lastCoordTrace := "F-Y-L"
      return buttonB ? coordsExtendedFirefoxModYCLeft : coordsFirefoxModYCLeft
    } else if (cRight()) {
      lastCoordTrace := "F-Y-R"
      return buttonB ? coordsExtendedFirefoxModYCRight : coordsFirefoxModYCRight
    } else {
      lastCoordTrace := "F-Y"
      return coordsExtendedFirefoxModY
    }
  }
}

setAnalogStick(finalCoords) {
  global myStick
  ;convertedCoords := convertCoords(coords)
  convertedCoords := convertCoords(finalCoords)
  myStick.SetAxisByIndex(convertedCoords[1], 1)
  myStick.SetAxisByIndex(convertedCoords[2], 2)
}

getCStickCoords() {
  global
  if (neither(anyVertC(), anyHorizC())) {
    cCoords := [0, 0]
  } else if (anyVertC() and anyHorizC()) {
    cCoords := [0.525, 0.85]
  } else if (anyVertC()) {
      cCoords := [0, 1]
  } else {
    if (modX() and up()) {
      cCoords := [0.9, 0.5]
    } else if (modX() and down()) {
      cCoords := [0.9, -0.5]
    } else {
      cCoords := [1, 0]
    }
  }

  return reflectCStickCoords(cCoords)
}

reflectCStickCoords(xAndY) {
  x := xAndY[1]
  y := xAndY[2]
  if (cDown()) {
    y := -y
  }
  if (cLeft()) {
    x := -x
  }
  return [x, y]
}

setCStick(cCoords) {
  global myStick
  convertedCoords := convertCoords(cCoords)
  myStick.SetAxisByIndex(convertedCoords[1], 4)
  myStick.SetAxisByIndex(convertedCoords[2], 5)
}

; Converts coordinates from melee values (-1 to 1) to vJoy values (0 to 32767).
convertCoords(xAndY) {
  mx = 10271 ; Why this number? idk, I would have thought it should be 16384 * (80 / 128) = 10240, but this works
  my = -10271
  bx = 16448 ; 16384 + 64
  by = 16320 ; 16384 - 64
  return [ mx * xAndY[1] + bx
         , my * xAndY[2] + by ]
}

setAnalogR(value) {
  global
  ; vJoy/Dolphin does something strange with rounding analog shoulder presses. In general,
  ; it seems to want to round to odd values, so
  ;   16384 => 0.00000 (0)   <-- actual value used for 0
  ;   19532 => 0.35000 (49)  <-- actual value used for 49
  ;   22424 => 0.67875 (95)  <-- actual value used for 94
  ;   22384 => 0.67875 (95)
  ;   22383 => 0.66429 (93)
  ; But, *extremely* inconsistently, I have seen the following:
  ;   22464 => 0.67143 (94)
  ; Which no sense and I can't reproduce. 
  convertedValue := 16384 * (1 + (value  / 255))
  myStick.SetAxisByIndex(convertedValue, 3)
}

neither(a, b) {
  return (not a) and (not b)
}

validateHK(GuiControl) {
 global lastHK
 Gui, Submit, NoHide
 lastHK := %GuiControl%                     ;Backup the hotkey, in case it needs to be reshown.
 num := SubStr(GuiControl,3)                ;Get the index number of the hotkey control.
 If (HK%num% != "") {                       ;If the hotkey is not blank...
  StringReplace, HK%num%, HK%num%, SC15D, AppsKey      ;Use friendlier names,
  StringReplace, HK%num%, HK%num%, SC154, PrintScreen  ;  instead of these scan codes.
  ;If CB%num%                                ;  If the 'Win' box is checked, then add its modifier (#).
   ;HK%num% := "#" HK%num%
  If (!CB%num% && !RegExMatch(HK%num%,"[#!\^\+]"))       ;  If the new hotkey has no modifiers, add the (~) modifier.
   HK%num% := "~" HK%num%                   ;    This prevents any key from being blocked.
  checkDuplicateHK(num)
 }
 If (savedHK%num% || HK%num%)               ;Unless both are empty,
  setHK(num, savedHK%num%, HK%num%)         ;  update INI/GUI
}

checkDuplicateHK(num) {
 global
 Loop,% hotkeys.Length()
  If (HK%num% = savedHK%A_Index%) {
   dup := A_Index
   TrayTip, B0XX, Hotkey Already Taken, 3, 0
   Loop,6 {
    GuiControl,% "Disable" b:=!b, HK%dup%   ;Flash the original hotkey to alert the user.
    Sleep,200
   }
   GuiControl,,HK%num%,% HK%num% :=""       ;Delete the hotkey and clear the control.
   break
  }
}

setHK(num,INI,GUI) {
 If INI{                          ;If previous hotkey exists,
  Hotkey, %INI%, Label%num%, Off  ;  disable it.
  Hotkey, %INI% UP, Label%num%_UP, Off  ;  disable it.
}
 If GUI{                           ;If new hotkey exists,
  Hotkey, %GUI%, Label%num%, On   ;  enable it.
  Hotkey, %GUI% UP, Label%num%_UP, On   ;  enable it.
}
 IniWrite,% GUI ? GUI:null, hotkeys.ini, Hotkeys, %num%
 savedHK%num%  := HK%num%
 ;TrayTip, Label%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
}

#MenuMaskKey vk07                 ;Requires AHK_L 38+
#If ctrl := HotkeyCtrlHasFocus()
 *AppsKey::                       ;Add support for these special keys,
 *BackSpace::                     ;  which the hotkey control does not normally allow.
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
  Gui, Submit, NoHide             ;If BackSpace is the first key press, Gui has never been submitted.
  If (A_ThisHotkey == "*BackSpace" && %ctrl% && !modifier)   ;If the control has text but no modifiers held,
   GuiControl,,%ctrl%                                       ;  allow BackSpace to clear that text.
  Else                                                     ;Otherwise,
   GuiControl,,%ctrl%, % modifier SubStr(A_ThisHotkey,2)  ;  show the hotkey.
  validateHK(ctrl)
 return
#If

HotkeyCtrlHasFocus() {
 GuiControlGet, ctrl, Focus       ;ClassNN
 If InStr(ctrl,"hotkey") {
  GuiControlGet, ctrl, FocusV     ;Associated variable
  Return, ctrl
 }
}


;----------------------------Labels

;Show GUI from tray Icon
ShowGui:
    Gui, show,, Dynamic Hotkeys
    GuiControl, Focus, LB1 ; this puts the windows "focus" on the checkbox, that way it isn't immediately waiting for input on the 1st input box
return

GuiLabel:
 If %A_GuiControl% in +,^,!,+^,+!,^!,+^!    ;If the hotkey contains only modifiers, return to wait for a key.
  return
 If InStr(%A_GuiControl%,"vk07")            ;vk07 = MenuMaskKey (see below)
  GuiControl,,%A_GuiControl%, % lastHK      ;Reshow the hotkey, because MenuMaskKey clears it.
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

lastUpPress := 0
lastDownPress := 0
lastLeftPress := 0
lastRightPress := 0
timeSinceRunningScript := A_TickCount

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

  conditionalAppend(flagArray, simultaneousHorizontalModifierLockout, "SHML") ; DRON unused in new code

  activeButtonList := stringJoin(", ", activeArray)
  pressedButtonList := stringJoin(", ", pressedArray)
  flagList := stringJoin(", ", flagArray)

  trace1 := lastCoordTrace

  analogCoords := getAnalogCoords()
  cStickCoords := getCStickCoords()

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
    , analogCoords[1], analogCoords[2]
    , cStickCoords[1], cStickCoords[2]
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


