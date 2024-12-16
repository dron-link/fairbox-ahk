#Requires AutoHotkey v1

showInputViewer() {
    IniRead, viewerWindowWidth, viewer-layout.ini, fairbox-input-viewer-window, % "Width"
    IniRead, viewerWindowHeight, viewer-layout.ini, fairbox-input-viewer-window, % "Height"
    Gui, inputViewerWindow:Show, w%viewerWindowWidth% h%viewerWindowHeight%, % "Input Viewer - fairbox"
}