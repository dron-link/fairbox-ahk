#Requires AutoHotkey v1

initializeInputViewerGUI() {
    global hotkeysList, global imgBtnReleaseHandle, global imgBtnPressHandle
    FileInstall, install\viewer-layout.ini, % A_ScriptDir "\viewer-layout.ini", 0

    imgBtnReleasePath := A_ScriptDir "\img\button.png"
    imgBtnPressPath := A_ScriptDir "\img\button_press.png"

    FileCreateDir, % A_ScriptDir "\img"
    FileInstall, install\img\button.png, % A_ScriptDir imgBtnReleasePath, 0
    FileInstall, install\img\button_press.png, % A_ScriptDir imgBtnPressPath, 0

    imgBtnReleaseHandle := LoadPicture(imgBtnReleasePath, "w-1 h-1")
    imgBtnPressHandle := LoadPicture(imgBtnPressPath, "w-1 h-1")

    ; window construction
    Loop, % hotkeysList.Length() {
        IniRead, buttonShow, viewer-layout.ini, % hotkeysList[A_Index], % "Show"
        if !buttonShow {
            continue ; go to next button
        }

        IniRead, x, viewer-layout.ini, % hotkeysList[A_Index], % "X"
        IniRead, y, viewer-layout.ini, % hotkeysList[A_Index], % "Y"

        addButtonAndItsGlobalVariable(x, y, hotkeysList[A_Index])
        
        ; captions
        IniRead, captionShow, viewer-layout.ini, % hotkeysList[A_Index], % "CaptionShow"
        if !captionShow {
            continue ; go to next button
        }
        IniRead, caption, viewer-layout.ini, % hotkeysList[A_Index], % "Caption"
        IniRead, captionX, viewer-layout.ini, % hotkeysList[A_Index], % "CaptionRelativeX"
        IniRead, captionY, viewer-layout.ini, % hotkeysList[A_Index], % "CaptionRelativeY"

        ; because "xp+" -N doesn't work as it should, we do this workaround
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

    return
}

addButtonAndItsGlobalVariable(x, y, hotkeyName) {
    global
    Gui, inputViewerWindow:Add, Picture, % "xm+" x " ym+" y " vViewer" hotkeysList[A_Index], % "hbitmap:*" imgBtnReleaseHandle
}