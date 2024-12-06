#Requires AutoHotkey v1.1

guiFontDefault(windowName) { ; next Gui,Add or GuiControl,Font commands will have this font in their text when called
    Gui, % windowName ":Font", s8 cDefault norm, Tahoma
    return
}

guiFontContent(windowName) { ; next Gui,Add or GuiControl,Font commands will have this font in their text when called
    Gui, % windowName ":Font", s10 cDefault norm, Arial
    return
}