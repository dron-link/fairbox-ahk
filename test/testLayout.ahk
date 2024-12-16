#Requires AutoHotkey v1.1.37.02

#SingleInstance force
#NoEnv

#include %A_WorkingDir%\source\system\hotkeys.ahk

showInputViewer() {
    global
    Gui, inputViewerWindow:Show, w%viewerWindowWidth% h%viewerWindowHeight%, % "Input Viewer - fairbox"
}

; cheats:
; diff between index and middle is 61 27
; diff between middle and ring is 63 8
; diff between ring and pinky is 56 37
; diff between upper and lower row is 0 64
; diff right thumb hex lattice is ? ?

imgBtnReleasePath := A_WorkingDir "\img\button.png"
imgBtnPressPath := A_WorkingDir "\img\button_press.png"

imgBtnReleaseHandle := LoadPicture(imgBtnReleasePath, "w-1 h-1")
imgBtnPressHandle := LoadPicture(imgBtnPressPath, "w-1 h-1")

Menu, Tray, Add, % "show Input Viewer", showInputViewer

; window construction
IniRead, viewerWindowWidth, viewer-layout.ini, fairbox-input-viewer-window, % "Width"
IniRead, viewerWindowHeight, viewer-layout.ini, fairbox-input-viewer-window, % "Height"
Loop, % hotkeysList.Length() {
    IniRead, buttonShow, viewer-layout.ini, % hotkeysList[A_Index], % "Show"
    if !buttonShow {
        continue ; go to next button
    }

    IniRead, x, viewer-layout.ini, % hotkeysList[A_Index], % "X"
    IniRead, y, viewer-layout.ini, % hotkeysList[A_Index], % "Y"

    Gui, inputViewerWindow:Add, Picture, % "xm+" x " ym+" y " vViewer" hotkeysList[A_Index], % "hbitmap:*" imgBtnReleaseHandle

    ; captions
    IniRead, captionShow, viewer-layout.ini, % hotkeysList[A_Index], % "CaptionShow"
    if !captionShow {
        continue ; go to next button
    }
    IniRead, caption, viewer-layout.ini, % hotkeysList[A_Index], % "Caption"
    IniRead, captionX, viewer-layout.ini, % hotkeysList[A_Index], % "CaptionRelativeX"
    IniRead, captionY, viewer-layout.ini, % hotkeysList[A_Index], % "CaptionRelativeY"

    if (captionX >= 0) {
        positionSignX := "+" 
    } else {
        positionSignX := "-", captionX := Abs(captionX)
    }
    if (captionY >= 0) {
        positionSignY := "+" 
    } else {
        positionSignY := "-", captionY := Abs(captionY)
    }

    Gui, inputViewerWindow:Add, Text, xp%positionSignX%%captionX% yp%positionSignY%%captionY%, % caption
}

showInputViewer()

return ; end of autoexecute section



inputViewerWindowGuiClose:
    ExitApp
return

^r:: Reload ; Ctrl-R