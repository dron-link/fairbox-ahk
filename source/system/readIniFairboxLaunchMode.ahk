#Requires AutoHotkey v1

readIniFairboxLaunchMode() {
    global enabledHotkeys
    global showWelcomeTray
    global inputViewerOnLaunch
    global enabledGameControls

    if enabledHotkeys {
        showWelcomeTray := true
    } else {
        showWelcomeTray := false
    }

    ; do we come from Edit Controls?
    IniRead, openedFromControlsEditor, config.ini, LaunchMode, ControlsWindowIntoMain
    IniWrite, % false                , config.ini, LaunchMode, ControlsWindowIntoMain
    IniRead, controlsEditorWasOpenedFromHere, config.ini, LaunchMode, MainIntoControlsWindow
    IniWrite, % false                       , config.ini, LaunchMode, MainIntoControlsWindow
    if (openedFromControlsEditor and controlsEditorWasOpenedFromHere) {
        ; we recall the Input On/Off toggle state
        IniRead, enabledGameControls, config.ini, LaunchMode, EnabledControlsRecall
        showWelcomeTray := false
    }

    IniRead, inputViewerOnLaunch, config.ini, LaunchMode, InputViewerOnLaunch
    IniWrite, % false           , config.ini, LaunchMode, InputViewerOnLaunch

    return
}