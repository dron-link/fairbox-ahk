# Why no travel time nerfing in the works?
Keyboard players on the cheap end are probably a majority. If people have enough money then I don't see why they wouldn't just buy a controller. 

Unlike controllers, with their gaming-oriented firmware written by professionals, pc/keyboard setups have presumably no widespread consistency in their latency and scan rates. Some setups bring input polling rates as large as 15.6ms (that's slow from the perspective of player microtiming) and there will be probably many cases where we can do nothing about it from Autohotkey. Coupling that with the need to simulate travel time properly, and possible unexpected behaviors from Autohotkey, it becomes a daunting problem to solve. 

## Ideas:
  *getting the polling latency from somewhere and decide if we should apply TT based on that info

  *rewrite portions of the program to work with more granular timing to send to Dolphin. 

  *figuring out how to test the quality of the implementation.


Gaming keyboards + gaming pc's: their low scanning latency might translate into low output latency to the game. That favors consistency and maybe it's worth to try to implement travel time for those setups, but let's not put TT simulation in cheap keyboards and software with too much latency and with inconsistent input delay.

For that matter [I](dron-link) won't be focusing on implementing travel time simulation.


# A pivot nerf case review
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

