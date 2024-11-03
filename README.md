# fairbox-ahk

fairbox-ahk converts your keyboard into a purely digital game controller (a.k.a. rectangle or box) devised to play Melee. Its design is based on the B0XX, the most popular purely digital Melee controller.

fairbox-ahk serves as a ground to experiment with ways to implement features that are missing from the predecessor of this program, b0xx-ahk.

Two of such features new to the Melee keyboard players are pivot nerfs and sdi nerfs; the playerbase has been integrating these into their rectangle controllers. Currently, fairbox-ahk is in the middle of development; we advise that you wait for its full release before using it.

The developers of fairbox-ahk are unaffiliated with the creators/producers of the B0XX. 

# General Info

This program shares its design with b0xx-ahk, so reading [b0xx-ahk's guide](https://github.com/agirardeau/b0xx-ahk) will help you understand how to use fairbox.

# Development/Testing Info

## Requirements

1. Install Autohotkey from https://autohotkey.com/.
2. Install AHK-CvJoyInterface, a library for linking Autohotkey and vJoy. Download CvJoyInterface.ahk from https://github.com/evilC/AHK-CvJoyInterface and place it inside Autohotkey's Lib folder (for me this was located at C:\Program Files\AutoHotkey\Lib). Create the Lib folder if it does not already exist.

## Setup

1. Clone this fairbox-ahk repository, or download it.
2. (Skip this step if you already use b0xx-ahk) Download vJoy from https://sourceforge.net/projects/vjoystick/?source=typ_redirect. After installing, run "Configure vJoy" (can be found by searching in the start menu). Set the number of buttons to 12 and hit apply.
3. (Skip this step if you already use b0xx-ahk) Follow the instructions for your emulator:
    1. If you're using Slippi, find your Slippi installation. In most cases it might be in  __C:\Users\\\<YourUsername\>\AppData\Roaming\Slippi Launcher__. Once you find your installation, place the fairbox-keyboard.ini file inside the  __\<YourSlippiInstallation\>\netplay\User\Config\Profiles\GCPad__ folder, creating any subfolders that do not already exist.
    2. If you're using Dolphin, place the fairbox-keyboard.ini file inside the  __C:\Users\\\<YourUsername\>\AppData\Roaming\Dolphin Emulator\Config\Profiles\GCPad__ folder or __\<YourDolphinInstallation\>\Sys\Profiles\GCPad__ folder, creating any subfolders that do not already exist. (For older Dolphin versions place fairbox-keyboard.ini inside __\<YourDolphinInstallation\>\User\Config\Profiles\GCPad__).
    3. If you're using SmashLadder Dolphin Launcher, navigate to your SmashLadder Dolphin installation. It might be in __C:\Users\\\<YourUsername\>\AppData\Roaming\SmashLadder Dolphin Launcher\dolphin_downloads__. Once you're there, place the fairbox-keyboard.ini file inside the  __\<YourSmashLadderInstallation\>\netplay\User\Config\Profiles\GCPad__ folder, creating any subfolders that do not already exist.
4. In the emulator, open up the controller config. Set player 1 to Standard Controller, then hit configure. Under Profile, select the fairbox-keyboard profile (or the b0xx-keyboard profile if you skipped step 3) and hit load. Verify that Device is set to DInput/0/vJoy. Hit OK.
5. (Optional) If you already use b0xx-ahk you can choose to reuse your custom layout: hotkeys.ini, by copying it, then pasting it in your fairbox folder.
6. To execute fairbox, run fairbox.ahk, or compile it and then run fairbox.exe
7. (Optional) The fairbox-keyboard profile works perfectly with Slippi Dolphin, but for some other versions of Dolphin there's a good chance that your fairbox won't be perfectly calibrated, and many analog coordinates will show as off by one unit. Although it doesn't affect gameplay much, you should fix this if you find it. Place the file __fairbox-kb-recalibrated.ini__ inside the GCPad folder, that is, the same location of Step 3. In the emulator, open up the controller config. Set player 1 to Standard Controller, then hit configure. Under Profile, select the fairbox-kb-recalibrated profile and hit load. Verify that Device is set to DInput/0/vJoy. Hit OK.

## Compile

After making changes to the source code, compile fairbox.exe by right-clicking fairbox.ahk and selecting "Compile Script." Autohotkey must be installed.

# Support

Invite to the Discord chat for Melee keyboard discussion: [20XX / #keyboard](https://discord.gg/KydHfzTbdG). The folks there will be usually happy to help you.

If the invite doesn't work, go to https://b0xx.com/pages/more-info and join the 20XX server with the invite linked in there, then look for the #keyboard chat.