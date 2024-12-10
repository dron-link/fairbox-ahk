#Requires AutoHotkey v1.1
/*  constants... extracted from the game engine, and other sources of information.
    the idea and comments behind these constants is copied from CarVac/HayBox.
    I sourced most from CarVac/HayBox, Altimor's Stickmap and the Melee Analog Reference Project discord
*/

ANALOG_STEP := 1
MS_PER_FRAME := 1000 / 60  ; game runs at 60 fps
PI := 3.141592653589793
DEG_TO_RADIAN := PI / 180
UNITCIRC_TO_INT := 80 ; factor for converting coordinate formats
INT_TO_UNITCIRC := 1/80
ANALOG_STICK_OFFSETCANCEL := -128 ; for converting unsigned bytes into 0-centered coordinatees
