```
              y ^
                |
                |
    dashL |           |dashR
   ---- 2 |     o     | 1 ---->
                   (aX)rX    x
                |
                |
      
    (^ Melee coordinate circle ^)


    * a pivot is detected by examining the limitedOutput x (aX). its timestamp is currentTime and its staleness is none
    * (aX) needs to be nerfed because its below y deadzone 
    * output is nerfed, yielding rX
    * dashHistory updates but because rX is in the same zone as 1, no new entries are added into the dash history
    * ---> in the next pass, the pivot detector will detect a failure in dash length
```
