#SingleInstance Force
#Warn
#Requires AutoHotkey v2.0



TraySetIcon "Inquisition.ico"

Enter::NumpadEnter
!+Space::Send "{Media_Play_Pause}"

CapsLock & ç::Run "mmsys.cpl"

DetectHiddenWindows 1
SetTitleMatchMode "RegEx"

/* if !A_IsAdmin
{
    try Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
} */
; -------- FLAGS --------

FLAG_TOGGLE := 1
FLAG_EXCLUSIVE := 2
FLAG_PERSISTENT := 4
FLAG_MOMENTARY := 8

; -------- LAYERS --------

layers := Map(

"q", { path: A_ScriptDir "\Layer1.ahk", flags: FLAG_TOGGLE|FLAG_EXCLUSIVE }, 
"w", { path: A_ScriptDir "\Layer2.ahk", flags: FLAG_TOGGLE|FLAG_EXCLUSIVE },
"e", { path: A_ScriptDir "\Layer3.ahk", flags: FLAG_TOGGLE|FLAG_EXCLUSIVE },

"a", { path: A_ScriptDir "\Layer4.ahk", flags: FLAG_TOGGLE|FLAG_EXCLUSIVE },
"s", { path: A_ScriptDir "\Layer5.ahk", flags: FLAG_TOGGLE|FLAG_PERSISTENT },
"d", { path: A_ScriptDir "\Layer6.ahk", flags: FLAG_TOGGLE|FLAG_PERSISTENT },

; independente
"z", { path: A_ScriptDir "\Layer7.ahk", flags: FLAG_TOGGLE|FLAG_PERSISTENT },

"c", { path: A_ScriptDir "\cheatsheet.ahk", flags: FLAG_TOGGLE|FLAG_PERSISTENT },




)

; -------- HOTKEYS --------

Capslock & q::LayerKey("q")
Capslock & w::LayerKey("w")
Capslock & e::LayerKey("e")
Capslock & a::LayerKey("a")
Capslock & s::LayerKey("s")
Capslock & d::LayerKey("d")
Capslock & z::LayerKey("z")
Capslock & c::LayerKey("c")
;Capslock & 1::LayerKey("1")

CapsLock & 1::F13
CapsLock & 2::F14
CapsLock & 3::F15
CapsLock & 4::F16
CapsLock & 5::F17
CapsLock & 6::F18
CapsLock & 7::F19
CapsLock & 8::F20
CapsLock & 9::F21
CapsLock & 0::F22
CapsLock & -::F23
CapsLock & =::F24
; -------- CORE --------

LayerKey(key){

    global layers
    layer := layers[key]

    path := layer.path
    flags := layer.flags

    running := WinExist("i)\Q" path "\E ahk_class AutoHotkey")

    ; MOMENTARY
    if (flags & FLAG_MOMENTARY){

        Run(path)
        KeyWait key
        WinClose
        return
    }

    ; TOGGLE
    if (flags & FLAG_TOGGLE){
        if running{
            WinClose
            ShowLayer("OFF")
            return
        }
    }

; EXCLUSIVE
if (flags & FLAG_EXCLUSIVE){
    for k, other in layers {
        if (k = key)
            continue
        if (other.flags & FLAG_EXCLUSIVE){
            if (this_id := WinExist("i)\Q" other.path "\E ahk_class AutoHotkey")) {
                targetPID := WinGetPID("ahk_id " this_id)
                ProcessClose(targetPID)
            }
        }
    }
}

    Run(path)

    ShowLayer(key)
}

; -------- OSD --------

ShowLayer(name){

    ToolTip "Layer: " name

    SetTimer () => ToolTip(), -800
}