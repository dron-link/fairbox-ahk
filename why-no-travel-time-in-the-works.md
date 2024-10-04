# Why no travel time nerfing in the works?
  Unlike for controllers, with their gaming-oriented firmware written by professionals, there is presumably no widespread consistency in the latency and scan rates of computer and keyboard setups. Some setups bring input polling rates as large as 15.6ms (that's slow) and there's probably some case where we can do nothing about it from Autohotkey. Coupling that with the need to simulate travel time properly, and possible unexpected behaviors from Autohotkey, it becomes a daunting problem to solve. 

## Ideas:
  *getting the polling latency from somewhere and decide from there if we should apply TT

  *rewrite portions of the program to work with more granular timing to send to Dolphin. 

  *figuring out how to test the quality of the implementation.


  I am not taking into consideration gaming keyboards + gaming pc s. Their low scanning latency MIGHT translate into low output latency to the game. That favors consistency and maybe it's worth to try to implement travel time for those setups, but let's not put TT simulation in cheap keyboards and software with too much latency and with inconsistent input delay.
  I (dron-link) won't be putting work in travel time simulation.

