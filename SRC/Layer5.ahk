#SingleInstance Force

; Easy Window Dragging -- KDE style (requires XP/2k/NT) -- by Jonny
; https://www.autohotkey.com
; This script makes it much easier to move or resize a window: 1) Hold down
; the ALT key and LEFT-click anywhere inside a window to drag it to a new
; location; 2) Hold down ALT and RIGHT-click-drag anywhere inside a window
; to easily resize it; 3) Press ALT twice, but before releasing it the second
; time, left-click to minimize the window under the mouse cursor, right-click
; to maximize it, or middle-click to close it.

; This script was inspired by and built on many like it
; in the forum. Thanks go out to ck, thinkstorm, Chris,
; and aurelian for a job well done.

; The Double-Alt modifier is activated by pressing
; Alt twice, much like a double-click. Hold the second
; press down until you click.
;
; The shortcuts:
;  Alt + Left Button  : Drag to move a window.
;  Alt + Right Button : Drag to resize a window.
;  Double-Alt + Left Button   : Minimize a window.
;  Double-Alt + Right Button  : Maximize/Restore a window.
;  Double-Alt + Middle Button : Close a window.
;
; You can optionally release Alt after the first
; click rather than holding it down the whole time.


; Em v2, muitas diretivas como #NoEnv, SendMode Input, e SetWorkingDir são o padrão.
; #SingleInstance Force já foi definido no topo.
; A verificação de versão (If A_AhkVersion...) não é necessária em v2.

; Em v2, o padrão é CoordMode, Mouse, Screen, então não é necessário
; setá-lo no script, a menos que você queira um comportamento diferente.
; SetWinDelay 2 é o padrão, então essa linha também não é necessária.

DoubleAlt := false

!LButton::
{
    if DoubleAlt {
        MouseGetPos(&KDE_X, &KDE_Y, &KDE_id)
        ; Esta mensagem é quase equivalente a WinMinimize,
        ; mas evita um bug com o PSPad.
        PostMessage(0x112, 0xF020, 0, 0, "ahk_id " KDE_id)
        DoubleAlt := false
        return
    }

    MouseGetPos(&KDE_X1, &KDE_Y1, &KDE_id)
    win := WinGetMinMax("ahk_id " KDE_id)
    if win == 1
        return

    WinGetPos(&KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, "ahk_id " KDE_id)

    Loop {
        if not GetKeyState("LButton", "P")
            break

        MouseGetPos(&KDE_X2, &KDE_Y2)
        KDE_X2 -= KDE_X1
        KDE_Y2 -= KDE_Y1
        KDE_WinX2 := KDE_WinX1 + KDE_X2
        KDE_WinY2 := KDE_WinY1 + KDE_Y2
        WinMove(KDE_WinX2, KDE_WinY2, , , "ahk_id " KDE_id)
    }
}

!RButton::
{
    if DoubleAlt {
        MouseGetPos(&KDE_X, &KDE_Y, &KDE_id)
        win := WinGetMinMax("ahk_id " KDE_id)
        if win == 1
            WinRestore("ahk_id " KDE_id)
        else
            WinMaximize("ahk_id " KDE_id)
        DoubleAlt := false
        return
    }

    MouseGetPos(&KDE_X1, &KDE_Y1, &KDE_id)
    win := WinGetMinMax("ahk_id " KDE_id)
    if win == 1
        return

    WinGetPos(&KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, "ahk_id " KDE_id)

    if (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
        KDE_WinLeft := 1
    else
        KDE_WinLeft := -1
    if (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
        KDE_WinUp := 1
    else
        KDE_WinUp := -1

    Loop {
        if not GetKeyState("RButton", "P")
            break

        MouseGetPos(&KDE_X2, &KDE_Y2)
        WinGetPos(&KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, "ahk_id " KDE_id)

        KDE_X2 -= KDE_X1
        KDE_Y2 -= KDE_Y1
        
        WinMove(KDE_WinX1 + (KDE_WinLeft + 1) / 2 * KDE_X2
                , KDE_WinY1 + (KDE_WinUp + 1) / 2 * KDE_Y2
                , KDE_WinW - KDE_WinLeft * KDE_X2
                , KDE_WinH - KDE_WinUp * KDE_Y2
                , "ahk_id " KDE_id)

        KDE_X1 := KDE_X2 + KDE_X1
        KDE_Y1 := KDE_Y2 + KDE_Y1
    }
}

!MButton::
{
    if DoubleAlt {
        MouseGetPos(&KDE_X, &KDE_Y, &KDE_id)
        WinClose("ahk_id " KDE_id)
        DoubleAlt := false
        return
    }
}

~*Alt Up::
{
    if (A_TimeSincePriorHotkey < 400) {
        DoubleAlt := true
    } else {
        DoubleAlt := false
    }
}