# Why no travel time nerfing in the works?
Keyboard + ahk players on the cheap end are probably a majority. If a person has enough money then I don't see why they wouldn't just buy a controller eventually.

Unlike controllers, with gaming-oriented firmware written by professionals, pc/keyboard setups have presumably no widespread consistency in their latency and scan rates. Some setups bring input polling rates as large as 15.6ms (that's slow from the perspective of player microtiming) and there will be probably many cases where we can do nothing about it from within Autohotkey. Coupling that with the need to simulate travel time properly, and possible unexpected behaviors from Autohotkey, it becomes a daunting problem to solve. 

## Ideas:
* getting the polling latency from somewhere and decide if we should apply TT based on that info
* rewrite portions of the program to work with more granular timing to send to Dolphin. 
* figuring out how to test the quality of the implementation.

Gaming keyboards + gaming pc's: their low scanning latency might translate into low output latency to the game. That fosters consistency and maybe in this situation it's worth to try to implement travel time for those setups, but let's not put TT simulation in cheap keyboards and software with too much latency and with inconsistent input delay.

For that matter I (dron-link) won't be focusing on implementing travel time simulation.

# Development notes

## APPROACH

  We add an intermediate step in the updateAnalogStick() function.
  We take the coordinates (x, y) that are solely determined by the current keypresses and we limit what they could do ingame by sending to the game the output of limitOutputs(x, y) instead.

### History approach: (adapted from CarVac).
  We store the information of outputs passed to the game so we can refer to that info when scanning for techniques that need nerfs.

### Handling simultaneous leftstick button presses:
  The player has a grace period of 3.9 milliseconds (in practice it could be  more, depending on things we can't control, but never more than 16 milliseconds) before assuming their input settled.
  Justification: People virtually never press two buttons at the exact same time even when they intend to, and independently of that, Autohotkey, the OS or the keyboard can be arbitrary with how they process "simultaneous" inputs and the time gap between them.
  We give the player a timelimit before we make the assumption that the input settled.
  With our input processing method, any input/output undone before the timelimit expires, won't be kept in history. Only the last of the inputs is saved. This comes to relevance when reading the history to detect techniques.
  With this, we mainly want to factor out inconsistencies between different keyboards.
  We deduced that this makes the detection of techniques more accurate and consistent accross gaming setups.

### Pivot detection. (empty pivots) ( Adapted from CarVac 's work )
  The detector trips if you input a dash, and if, before entering run state and over the course of the first dash, you input another dash in the opposite direction  held for about 1 frame total.
  Once we detect an empty pivot, we make certain actions unavailable for a number of frames.

### Uncrouch detection ( Adapted from CarVac 's work)
  This detector trips when you exit the leftstick vertical range that allows the player to hold crouch.
  We rule out inputting an unbuffered up-tilt until a certain number of frames pass.

### Horizontal 1.0 fuzzing
  The Game cube controller can be inconsistent in, or uncapable of, reaching horizontal 1.0 or -1.0, getting stuck at +/-0.9875 .
  We emulate some of that inconsistency by sometimes outputting horizontal +/- 0,9875 instead of +/- 1.0.
  Still, Universal Controller Fix v0.84 and newer, and alternatively SSBM1.03 get rid of these problems for Game cube controllers "and" for this script.

## A pivot nerf case review
This is a diagram of a coordinate circle. Order of inputs is 2 -> 1 -> aX
```

              y ^
                |
                |
    dashL |           |dashR
   ---- 2 |     o     | 1 ---->
                   (aX)rX    x
                |
                |
          
```

* a pivot is detected by examining the limitedOutput x (aX). its timestamp is currentTime and its staleness is none
* (aX) needs to be nerfed because its below y deadzone 
* output is nerfed, yielding rX
* dashHistory updates but because rX is in the same zone as 1, no new entries are added into the dash history
* ---> in the next pass, the pivot detector will detect a failure in dash length (based on the dash history)
