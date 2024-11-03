#Requires AutoHotkey v1.1

hkIniAutoGen()

hkIniAutoGen() {
    hkIniPath := A_ScriptDir "\hotkeys.ini"
    ; if hotkeys.ini doesn't exist, create it
    AttributeString := FileExist(hkIniPath)
    if (!AttributeString) {
        OutputDebug, hotkeys.ini found to not exist. generating it...
        hkIniTextDefault := "
        (
[Hotkeys]
1=~]
2=~3
3=~2
4=~4
5=~v
6=~b
7=~m
8=~o
9=~q
10=~9
11=~p
12=~0
13=~[
14=~k
15=~Space
16=~n
17=~,
18=~-
19=~=
20=~7
21=~+Up
22=~+Down
23=~+Left
24=~+Right
25=~
        )"
        FileAppend, % hkIniTextDefault, % hkIniPath
    }

    return
}