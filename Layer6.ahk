#Requires AutoHotkey v2.0
hVDA := DllCall("LoadLibrary", "Str", A_ScriptDir . "\VirtualDesktopAccessor.dll", "Ptr")
TraySetIcon "Layer6.ico" ; You can choose your own icon here

; Disable win key's default behavior (like opening the Start menu)
~LWin::Send "{Blind}{vkE8}"



; Disable Win+S (Windows Search) to avoid conflicts with Everything
;~#s::Send "{Blind}"

; Win + S opens Everything
;~#s::Run "\everything\everything.exe "

; Win + D open windows menu like hyprland
#d::Send "^{Esc}"
; Win + Q = (Alt+F4)
#q:: WinClose "A"

; changes desktop up to 6 desks, you can add more if you have more desktops
$#1:: {
    Send "{Blind}{vkE8}"  ; disable win key's default behavior (like opening the Start menu)
    GoToDesktopDragAware(0)
}
$#2:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(1)
}
$#3:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(2)
}
$#4:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(3)
}
$#5:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(4)
}
$#6:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(5)
}
$#7:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(6)
}
$#8:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(7)
}
$#9:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(8)
}
$#0:: {
    Send "{Blind}{vkE8}"
    GoToDesktopDragAware(9)
}



#+1:: MoveAndGo(0)
#+2:: MoveAndGo(1)
#+3:: MoveAndGo(2)
#+4:: MoveAndGo(3)
#+5:: MoveAndGo(4)
#+6:: MoveAndGo(5)
#+7:: MoveAndGo(6)
#+8:: MoveAndGo(7)
#+9:: MoveAndGo(8)
#+0:: MoveAndGo(9)

#Enter:: {
    path := "./"
    if WinActive("ahk_class CabinetWClass") {
        try {
            hwnd := WinGetID("A")
            for window in ComObject("Shell.Application").Windows {
                if (window.hwnd == hwnd) {
                    sel := window.Document.SelectedItems
                    if (sel.Count > 0 && InStr(FileExist(sel.Item(0).Path), "D"))
                        path := sel.Item(0).Path
                    else
                        path := window.Document.Folder.Self.Path
                    break
                }
            }
        }
    }
    if (path != "")
        Run 'wsl.exe -d archlinux -u user --cd "' path '"'
    else
        Run 'wsl.exe -d archlinux -u user'
}

GoToDesktopDragAware(index) {
    count := DllCall("VirtualDesktopAccessor\GetDesktopCount", "Int")
    if (index >= count) {
        MsgBox "Desktop " (index + 1) " não existe! (total: " count ")"
        return
    }
    if GetKeyState("LButton", "P") {
        hwnd := WinGetID("A")
        DllCall("VirtualDesktopAccessor\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", index)
    }
    DllCall("VirtualDesktopAccessor\GoToDesktopNumber", "Int", index)
}

MoveAndGo(index) {
    count := DllCall("VirtualDesktopAccessor\GetDesktopCount", "Int")
    if (index >= count) {
        MsgBox "Desktop " (index + 1) " não existe! (total: " count ")"
        return
    }
    hwnd := WinGetID("A")
    DllCall("VirtualDesktopAccessor\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", index)
    DllCall("VirtualDesktopAccessor\GoToDesktopNumber", "Int", index)
}
