#Requires AutoHotkey v1.1.37

#SingleInstance force
#NoEnv

xComp := 1
yComp := 2

showInputViewer() {
    global
    Gui, inputViewerWindow:Show, w%viewerDefaultWidth% h%viewerDefaultHeight%, % "Input Viewer - fairbox"
}

viewerDefault := []
Loop, 20 { 
    viewerDefault[A_Index] := {buttonCoords: [], captionCoords: []}
}

viewerDefaultWidth := 950
viewerDefaultHeight := 472

viewerDefault[1].buttonCoords[xComp] := 812
viewerDefault[1].buttonCoords[yComp] := 150
viewerDefault[1].caption := "Up"
viewerDefault[1].captionCoords[xComp] := 22
viewerDefault[1].captionCoords[yComp] := 62

viewerDefault[2].buttonCoords[xComp] := 197
viewerDefault[2].buttonCoords[yComp] := 105
viewerDefault[2].caption := "Down"
viewerDefault[2].captionCoords[xComp] := 15
viewerDefault[2].captionCoords[yComp] := -18

viewerDefault[3].buttonCoords[xComp] := 131
viewerDefault[3].buttonCoords[yComp] := 113
viewerDefault[3].caption := "Left"
viewerDefault[3].captionCoords[xComp] := 20
viewerDefault[3].captionCoords[yComp] := -18

viewerDefault[4].buttonCoords[xComp] := 258
viewerDefault[4].buttonCoords[yComp] := 132
viewerDefault[4].caption := "Right"
viewerDefault[4].captionCoords[xComp] := 16
viewerDefault[4].captionCoords[yComp] := -20

viewerDefault[5].buttonCoords[xComp] := 273
viewerDefault[5].buttonCoords[yComp] := 289
viewerDefault[5].caption := "Mod X"
viewerDefault[5].captionCoords[xComp] := 16
viewerDefault[5].captionCoords[yComp] := -20

viewerDefault[6].buttonCoords[xComp] := 332 
viewerDefault[6].buttonCoords[yComp] := 324
viewerDefault[6].caption := "Mod Y"
viewerDefault[6].captionCoords[xComp] := 16
viewerDefault[6].captionCoords[yComp] := -20

viewerDefault[7].buttonCoords[xComp] := 609
viewerDefault[7].buttonCoords[yComp] := 288
viewerDefault[7].caption := "A"
viewerDefault[7].captionCoords[xComp] := 55
viewerDefault[7].captionCoords[yComp] := 50

viewerDefault[8].buttonCoords[xComp] := 625 
viewerDefault[8].buttonCoords[yComp] := 133
viewerDefault[8].caption := "B"
viewerDefault[8].captionCoords[xComp] := -16
viewerDefault[8].captionCoords[yComp] := 21

viewerDefault[9].buttonCoords[xComp] := 72
viewerDefault[9].buttonCoords[yComp] := 150
viewerDefault[9].caption := "L"
viewerDefault[9].captionCoords[xComp] := 16
viewerDefault[9].captionCoords[yComp] := -20

viewerDefault[10].buttonCoords[xComp] := 625
viewerDefault[10].buttonCoords[yComp] := 69
viewerDefault[10].caption := "R"
viewerDefault[10].captionCoords[xComp] := 23
viewerDefault[10].captionCoords[yComp] := -18

viewerDefault[11].buttonCoords[xComp] := 686
viewerDefault[11].buttonCoords[yComp] := 105
viewerDefault[11].caption := "X"
viewerDefault[11].captionCoords[xComp] := 25
viewerDefault[11].captionCoords[yComp] := 62

viewerDefault[12].buttonCoords[xComp] := 686
viewerDefault[12].buttonCoords[yComp] := 42
viewerDefault[12].caption := "Y"
viewerDefault[12].captionCoords[xComp] := 25
viewerDefault[12].captionCoords[yComp] := -18

viewerDefault[13].buttonCoords[xComp] := 752
viewerDefault[13].buttonCoords[yComp] := 113
viewerDefault[13].caption := "Z"
viewerDefault[13].captionCoords[xComp] := 25
viewerDefault[13].captionCoords[yComp] := 62

viewerDefault[14].buttonCoords[xComp] := 609
viewerDefault[14].buttonCoords[yComp] := 215
viewerDefault[14].caption := "C-Up"
viewerDefault[14].captionCoords[xComp] := -20
viewerDefault[14].captionCoords[yComp] := -15

viewerDefault[15].buttonCoords[xComp] := 552
viewerDefault[15].buttonCoords[yComp] := 324
viewerDefault[15].caption := "C-Down"
viewerDefault[15].captionCoords[xComp] := -30
viewerDefault[15].captionCoords[yComp] := 56

viewerDefault[16].buttonCoords[xComp] := 552
viewerDefault[16].buttonCoords[yComp] := 251
viewerDefault[16].caption := "C-Left"
viewerDefault[16].captionCoords[xComp] := -35
viewerDefault[16].captionCoords[yComp] := 23

viewerDefault[17].buttonCoords[xComp] := 666
viewerDefault[17].buttonCoords[yComp] := 251
viewerDefault[17].caption := "C-Right"
viewerDefault[17].captionCoords[xComp] := 56
viewerDefault[17].captionCoords[yComp] := -18

viewerDefault[18].buttonCoords[xComp] := 752
viewerDefault[18].buttonCoords[yComp] := 49
viewerDefault[18].caption := "LS"
viewerDefault[18].captionCoords[xComp] := 22
viewerDefault[18].captionCoords[yComp] := -18

viewerDefault[19].buttonCoords[xComp] := 812
viewerDefault[19].buttonCoords[yComp] := 86
viewerDefault[19].caption := "MS"
viewerDefault[19].captionCoords[xComp] := 22
viewerDefault[19].captionCoords[yComp] := -18

viewerDefault[20].buttonCoords[xComp] := 442
viewerDefault[20].buttonCoords[yComp] := 133
viewerDefault[20].caption := "Start"
viewerDefault[20].captionCoords[xComp] := 16
viewerDefault[20].captionCoords[yComp] := -20

doneButtons := 20
; cheats:
; diff between index and middle is 61 27
; diff between middle and ring is 63 8
; diff between ring and pinky is 56 37
; diff between upper and lower row is 0 64
; diff right thumb hex lattice is ? ?

imgBtnReleasePath := A_ScriptDir "\img\button.png"
imgBtnPressPath := A_ScriptDir "\img\button_press.png"

FileCreateDir, % A_ScriptDir "\img"
FileInstall, install\img\button.png, % A_ScriptDir imgBtnReleasePath, 0
FileInstall, install\img\button_press.png, % A_ScriptDir imgBtnPressPath, 0

imgBtnReleaseHnd := LoadPicture(imgBtnReleasePath, "w-1 h-1")
imgBtnPressHnd := LoadPicture(imgBtnPressPath, "w-1 h-1")

Menu, Tray, Add, % "show Input Viewer", showInputViewer

; button construction

; Gui, inputViewerWindow:Add, Picture, xm ym, % A_ScriptDir "\install\img\b0xx-24mm-topPanel-transparent.png"

Loop,% doneButtons {
    xBtn := viewerDefault[A_Index].buttonCoords[xComp]
    yBtn := viewerDefault[A_Index].buttonCoords[yComp]
    Gui, inputViewerWindow:Add, Picture, xm+%xBtn% ym+%yBtn% vInViewerBtn´´%A_Index%, % "hbitmap:*" imgBtnReleaseHnd
    xCptn := viewerDefault[A_Index].captionCoords[xComp]
    yCptn := viewerDefault[A_Index].captionCoords[yComp]
    if (xCptn >= 0) {
        xSgn := "+"
    } else if (xCptn < 0) { ; cuz xp+-N doesnt work as it should...
        xSgn := "-", xCptn *= -1
    }
    if (yCptn >= 0) { 
        ySgn := "+"
    } else if (yCptn < 0) {
        ySgn := "-", yCptn *= -1
    }
    Gui, inputViewerWindow:Add, Text, xp%xSgn%%xCptn% yp%ySgn%%yCptn%, % viewerDefault[A_Index].caption
}




showInputViewer()


Esc:: ExitApp
r:: Reload