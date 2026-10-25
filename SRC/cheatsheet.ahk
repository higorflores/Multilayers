#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

cheat := Gui("+AlwaysOnTop -Caption +ToolWindow +Border", "Cheatsheet")
cheat.BackColor := "0x1E1E1E"
cheat.MarginX := 20
cheat.MarginY := 14

cheat.SetFont("s11 bold", "Consolas")
cheat.AddText("c61AFEF", "  CHEATSHEET  ·  LAYERS 0 / 5 / 6")

AddSection("LAYER 0  ·  CORE", [
    ["Enter", "NumpadEnter"],
    ["Alt + Shift + Space", "Play / Pause mídia"],
    ["CapsLock + ç", "Painel de Som (mmsys.cpl)"],
    ["CapsLock + 1..0  -  =", "F13 ... F24"],
    ["CapsLock + Q", "Layer 1"],
    ["CapsLock + W", "midi_fader.py"],
    ["CapsLock + E", "Layer 3"],
    ["CapsLock + A", "Layer 4"],
    ["CapsLock + S", "Layer 5  ·  KDE Move"],
    ["CapsLock + D", "Layer 6  ·  Desktops"],
    ["CapsLock + Z", "Layer 7"],
    ["CapsLock + C", "Index.py"]
])

AddSection("LAYER 5  ·  KDE MOVE", [
    ["Alt + Arrastar Esq.", "Mover janela"],
    ["Alt + Arrastar Dir.", "Redimensionar janela"],
    ["Alt Alt + Clique Esq.", "Minimizar"],
    ["Alt Alt + Clique Dir.", "Maximizar / Restaurar"],
    ["Alt Alt + Clique Meio", "Fechar janela"]
])

AddSection("LAYER 6  ·  DESKTOPS VIRTUAIS", [
    ["Win", "Bloqueia menu Iniciar"],
    ["Win + D", "Menu de janelas (Ctrl+Esc)"],
    ["Win + Q", "Fechar janela ativa"],
    ["Win + 1..0", "Ir para desktop 1..10"],
    ["Win + 1..0 + arrastar", "Mover janela p/ desktop"],
    ["Win + Shift + 1..0", "Mover janela e ir"],
    ["Win + Enter", "WSL Archlinux (pasta atual)"]
])

cheat.SetFont("s9 italic", "Consolas")
cheat.AddText("c808080", "  Esc fecha")

cheat.OnEvent("Close", CloseCheat)
Hotkey "Esc", CloseCheat

cheat.Show("NoActivate")
WinGetPos , , &w, &h, "ahk_id " cheat.Hwnd
WinMove A_ScreenWidth - w - 24, 48, , , "ahk_id " cheat.Hwnd

AddSection(header, rows) {
    global cheat
    cheat.SetFont("s10 bold", "Consolas")
    cheat.AddText("cE5C07B", "  " header)
    cheat.SetFont("s10", "Consolas")
    for row in rows
        cheat.AddText("cD0D0D0", "    " Format("{1,-24}", row[1]) " " row[2])
}

CloseCheat(*) {
    ExitApp
}
