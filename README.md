# fairbox-ahk

fairbox-ahk is a modification of [b0xx-ahk](https://github.com/agirardeau/b0xx-ahk) that was created by agirardeaudale which in turn is an adaptation of a [similar script](https://github.com/tlandegger/smashbox-AHK) for Smashbox created by tlandegger. fairbox-ahk serves as a ground to experiment with ways to implement features that are new to keyboard players, such as pivot nerfs and sdi nerfs; features that the playerbase has been integrating into their rectangle controllers. Currently, fairbox-ahk is in a design stage.

I am unaffiliated with the creators/producers of the B0XX. 

# Info

Refer to [b0xx-ahk](https://github.com/agirardeau/b0xx-ahk).

# Development Info

## Requirements

1. Install Autohotkey from https://autohotkey.com/.
2. Install AHK-CvJoyInterface, a library for linking Autohotkey and vJoy. Download CvJoyInterface.ahk from https://github.com/evilC/AHK-CvJoyInterface and place it inside Autohotkey's Lib folder (for me this was located at C:\Program Files\AutoHotkey\Lib). Create the Lib folder if it does not already exist.

## Setup

1. (Skip this step if you already use b0xx-ahk) Download vJoy from https://sourceforge.net/projects/vjoystick/?source=typ_redirect. After installing, run "Configure vJoy" (can be found by searching in the start menu). Set the number of buttons to 12 and hit apply.
2.a. If you're using Slippi, place the fairbox-slippi-keyboard.ini file inside the  __\<YourSlippiInstallation\>\netplay\User\Config\Profiles\GCPad__ folder, creating any subfolders that do not already exist. Your Slippi installation might be in __C:\Users\\\<YourUsername\>\AppData\Roaming\Slippi Launcher__ .
2.b. If you're using Dolphin 5.0, place the fairbox-dolphin-5-keyboard.ini file inside the  __C:\Users\\\<YourUsername\>\AppData\Roaming\Dolphin Emulator\Config\Profiles\GCPad__ folder or __\<YourDolphinInstallation\>\Sys\Profiles\GCPad__ folder, creating any subfolders that do not already exist. (For older Dolphin versions place fairbox-slippi-keyboard.ini inside __\<YourDolphinInstallation\>\User\Config\Profiles\GCPad__)
2.c. If you're using SmashLadder Dolphin Launcher, place the fairbox-slippi-keyboard.ini file inside the  __\<YourSmashLadderInstallation\>\netplay\User\Config\Profiles\GCPad__ folder. Your SmashLadder Dolphin instances might be in __C:\Users\\\<YourUsername\>\AppData\Roaming\SmashLadder Dolphin Launcher\dolphin_downloads__.
3. In Dolphin/Slippi Dolphin, open up the controller config. Set player 1 to Standard Controller, then hit configure. Under Profile, select the fairbox profile and hit load. Verify that Device is set to DInput/0/vJoy. Hit OK.
3. Place all the ahk files in a folder for fairbox. All ahk files must be on the same folder. (If you already use b0xx-ahk you can choose to reuse your custom layout: hotkeys.ini, by copying it, then pasting it in your fairbox folder).
4. To play, run fairbox.ahk, or compile it and then run fairbox.exe

## Compile

After making changes to fairbox.ahk, compile fairbox.exe by right-clicking fairbox.ahk and selecting "Compile Script." Autohotkey must be installed.
