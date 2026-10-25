# Chaos — Sistema de Camadas de Hotkeys para Windows

> **AutoHotkey v2** · Windows 10/11 · desktops virtuais, gerenciamento de janelas estilo KDE e um launcher de camadas tudo-em-um

# Download pré-compilado do ahk (não há necessidade de instalar o ahk v2): https://github.com/higorflores/Multilayers/releases/download/v0.1/Release.zip



O **Chaos** é um conjunto de scripts AutoHotkey v2 organizados em **camadas (layers)**. Uma camada principal (**Layer 0**) fica sempre ativa e transforma o `CapsLock` em uma tecla modificadora, permitindo ligar e desligar módulos independentes sob demanda — como se fossem "modos" do teclado.

Este documento cobre as camadas centrais do projeto:

| Camada | Arquivo | Função |
|---|---|---|
| **Layer 0** | `Layer0.ahk` | Core: gerenciador de camadas, hotkeys globais e teclas F13–F24 |
| **Layer 5** | `Layer5.ahk` | Mover/redimensionar janelas estilo KDE (Alt + mouse) |
| **Layer 6** | `Layer6.ahk` | Desktops virtuais + integração WSL |

Complementos: `cheatsheet.ahk` (overlay com todos os atalhos)
---

## Requisitos

- **Windows 10/11**
- **[AutoHotkey v2.0](https://www.autohotkey.com/)** ou superior — apenas se você rodar os `.ahk` diretamente (os `.exe` já são compilados)
- **`VirtualDesktopAccessor.dll`** — deve estar na mesma pasta do `Layer6.ahk`/`Layer6.exe` (já incluído no repositório)
- **Opcional:** WSL com a distro `archlinux` configurada (usado pelo atalho `Win + Enter` da Layer 6)

---

## Instalação

1. Instale o AutoHotkey v2.
2. Clone ou baixe este repositório.
3. Execute **`Layer0.ahk`** (ou `Layer0.exe`). Só o Layer 0 precisa ficar rodando — as demais camadas são ligadas sob demanda por ele.
4. Ative as camadas:
   - `CapsLock + S` — liga a **Layer 5** (KDE Move)
   - `CapsLock + D` — liga a **Layer 6** (Desktops virtuais)

**Iniciar com o Windows:** coloque um atalho em `shell:startup`, ou use o **Launcher** — na primeira execução ele se eleva uma única vez (UAC) e registra uma *Scheduled Task* com `RunLevel = HIGHEST`; nas execuções seguintes a Layer 0 roda como administrador **sem novo prompt de UAC**.

Alternativa: **`Chaos.exe`** empacota launcher + Layer 0 + Layer 5 + Layer 6 + cheatsheet em um único executável.

---

## Arquitetura

```
Layer 0 (sempre ativo — o "kernel")
│
│  CapsLock + <tecla>  →  liga / desliga uma layer
│
├── [S] Layer 5 ... KDE Move ......... mover/redimensionar janelas com Alt+mouse
├── [D] Layer 6 ... Desktops ......... desktops virtuais + WSL
├── [Q/W/E/A] ... layers externas .... Layer1, Layer2 , Layer3, Layer4
│
└── [1..0/-/=] . F13–F24 ............ teclas de função virtuais
```

Cada layer é um processo AHK separado. A Layer 0 detecta se uma layer está rodando procurando sua janela (com `DetectHiddenWindows` + correspondência por regex no caminho do script) e a encerra com `WinClose`. Ao ligar/desligar, um **tooltip OSD** (`Layer: <tecla>` / `Layer: OFF`) aparece por 800 ms.

---

## Layer 0 — Core

Arquivo: [`Layer0.ahk`](Layer0.ahk)

### Hotkeys globais

| Atalho | Ação |
|---|---|
| `Enter` | Remapeado para `NumpadEnter` |
| `Alt + Shift + Espaço` | Play / Pause da mídia |
| `CapsLock + Ç` | Abre o painel de som (`mmsys.cpl`) |
| `CapsLock + 1 … 0`, `-`, `=` | Envia `F13` … `F24` (teclas de função virtuais) |
| `CapsLock + Q/W/E/A/S/D/Z/C` | Liga/desliga a layer correspondente |

> O CapsLock continua funcionando normalmente quando pressionado sozinho — ele só vira modificador em combinação com outras teclas.

### Mapa de camadas

| Tecla | Alvo | Flags |
|---|---|---|
| `Q` | `Layer1.ahk` | `TOGGLE + EXCLUSIVE` |
| `W` | `Layer1.ahk` | `TOGGLE + EXCLUSIVE` |
| `E` | `Layer3.ahk` | `TOGGLE + EXCLUSIVE` |
| `A` | `Layer4.ahk` | `TOGGLE + EXCLUSIVE` |
| `S` | `Layer5.ahk` — KDE Move | `TOGGLE + PERSISTENT` |
| `D` | `Layer6.ahk` — Desktops | `TOGGLE + PERSISTENT` |
| `Z` | `Layer7.ahk` — independente | `TOGGLE + PERSISTENT` |
| `C` | `Toolbox\Index.py` | `TOGGLE + PERSISTENT` |

> Os alvos de `Q`, `W`, `E`, `A`, `Z` e `C` são scripts externos a este pacote (layers auxiliares de outros projetos). Ajuste os caminhos no `Map()` no topo do script conforme sua instalação.

### Sistema de flags

| Flag | Valor | Efeito |
|---|---|---|
| `FLAG_TOGGLE` | `1` | Segundo pressionamento desliga: se a layer já está rodando, ela é fechada |
| `FLAG_EXCLUSIVE` | `2` | Ao ligar, encerra (`ProcessClose`) qualquer outra layer também exclusiva que esteja ativa — layers com essa flag são mutuamente excludentes entre si |
| `FLAG_PERSISTENT` | `4` | Layer "independente": coexiste com as demais, inclusive com as exclusivas |
| `FLAG_MOMENTARY` | `8` | Roda apenas enquanto a tecla estiver pressionada (`KeyWait` + `WinClose`) — definida, ainda não usada por nenhuma layer |

Na prática: `Q/W/E/A` competem entre si (ligar uma desliga as outras), enquanto `S/D/Z/C` podem ficar ativas simultaneamente — o que permite, por exemplo, usar **KDE Move e desktops virtuais ao mesmo tempo**.

---

## Layer 5 — KDE Move

Arquivo: [`Layer5.ahk`](Layer5.ahk) · Ativação: `CapsLock + S`

Adaptação para AutoHotkey v2 do clássico *"Easy Window Dragging — KDE style"* (por Jonny, do fórum do AutoHotkey). Permite mover e redimensionar janelas clicando **em qualquer ponto** delas, sem mirar na barra de título ou na borda.

| Atalho | Ação |
|---|---|
| `Alt` + arrastar (botão esquerdo) | **Move** a janela sob o cursor |
| `Alt` + arrastar (botão direito) | **Redimensiona** pela borda/canto mais próximo do cursor |
| `Alt, Alt` + clique esquerdo | **Minimiza** a janela sob o cursor |
| `Alt, Alt` + clique direito | **Maximiza / restaura** a janela |
| `Alt, Alt` + clique do meio | **Fecha** a janela |

Este foi copiado e modificado para ahk 2.0, creditos a https://github.com/pfisterer/autohotkey-scripts/blob/master/kde-style-window-move.ahk

Detalhes de comportamento:

- **Duplo-Alt**: pressione e solte `Alt` duas vezes seguidas (intervalo < 400 ms). Mantenha a segunda pressão até clicar. Depois da ação, o estado é resetado.
- Durante o arrasto, você pode **soltar o Alt após o primeiro clique** — o movimento/redimensionamento continua até soltar o botão do mouse.
- O redimensionamento usa a posição inicial do cursor para decidir quais bordas mover (lógica de quadrantes em relação ao centro da janela).
- Janelas **maximizadas** são ignoradas para mover/redimensionar (mas respondem ao Duplo-Alt).
- A minimização usa `PostMessage` com `SC_MINIMIZE` em vez de `WinMinimize`, para contornar um bug conhecido com o PSPad.

---

## Layer 6 — Desktops Virtuais

Arquivo: [`Layer6.ahk`](Layer6.ahk) · Ativação: `CapsLock + D` · Ícone de bandeja: `Ultramarines.ico`

Gerenciamento de desktops virtuais do Windows via **`VirtualDesktopAccessor.dll`** (carregada com `LoadLibrary` na inicialização do script), com comportamentos inspirados em gerenciadores de janelas em tiling como o **Hyprland**.

| Atalho | Ação |
|---|---|
| `Win` (sozinho) | Menu Iniciar **suprimido** (a tecla envia `vkE8`, uma chave virtual não atribuída) |
| `Win + D` | Envia `Ctrl + Esc` (menu estilo Hyprland) |
| `Win + Q` | Fecha a janela ativa (equivalente a `Alt + F4`) |
| `Win + 1 … 0` | Vai para o desktop **1 … 10** |
| `Win + 1 … 0` com botão esq. pressionado | Vai para o desktop **levando a janela ativa junto** ("drag aware") |
| `Win + Shift + 1 … 0` | **Move** a janela ativa para o desktop N **e segue** ela |
| `Win + Enter` | Abre o terminal **WSL (Arch)** na pasta atual do Explorer |

Detalhes de comportamento:

- **Drag aware:** se você estiver com o botão esquerdo do mouse pressionado ao apertar `Win + N`, a janela ativa é movida para o desktop de destino junto com a troca — útil para "levar" janelas durante um arrasto.
- **Validação:** se o desktop destino não existir, exibe um aviso (`Desktop N não existe! (total: M)`) em vez de falhar silenciosamente.
- **WSL:** com o Explorer ativo, o terminal abre na pasta atual (ou na pasta selecionada, se o item selecionado for um diretório); nos demais casos, abre no diretório padrão do usuário WSL.
  - O comando usado é `wsl.exe -d archlinux -u user --cd "<pasta>"` — **troque a distro e o usuário** no script (`#Enter` em `Layer6.ahk`) para a sua configuração.
- Há um gancho preparado (comentado) para abrir o **Everything** com `Win + S`, desativado por padrão para não conflitar com a busca do Windows.

> **Nota sobre a DLL:** o `VirtualDesktopAccessor.dll` depende de detalhes internos do Windows que mudam entre versões/builds. Se a troca de desktops parar de funcionar após uma atualização grande do Windows, substitua a DLL por uma versão atualizada ([Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor)).

---

## Cheatsheet

Arquivo: [`cheatsheet.ahk`](cheatsheet.ahk)

Overlay minimalista (tema escuro, `Consolas`) sempre no topo, exibido no canto superior direito da tela, com o resumo de todos os atalhos das Layers 0, 5 e 6. Feche com `Esc`.

---

## Compilação

| Artefato | Como gerar | Observação |
|---|---|---|
| `Layer5.exe`, `Layer6.exe` | [Ahk2Exe](https://www.autohotkey.com/boards/viewtopic.php?t=78209) com base v2 | Empacota os scripts `.ahk` individuais |
| `Chaos.exe` | `build_release.bat` | Usa Ahk2Exe com base `AutoHotkey64.exe` v2.0.19; embute ícones e a DLL via `FileInstall` |


---

## Estrutura do projeto

```
.
├── Layer0.ahk                  # Core: gerenciador de layers (CapsLock)
├── Layer5.ahk                  # KDE Move: mover/redimensionar com Alt+mouse
├── Layer6.ahk                  # Desktops virtuais + WSL
├── cheatsheet.ahk              # Overlay de atalhos
└── VirtualDesktopAccessor.dll  # Dependência da Layer 6

```
VirtualDesktopAccessor.dll foi copiado de https://github.com/Ciantic/VirtualDesktopAccessor
---

## Avisos e limitações

- Com a **Layer 6 ativa, a tecla `Win` sozinha deixa de abrir o menu Iniciar**, e `Win + D` é sobrescrito (vira `Ctrl + Esc`). É o comportamento pretendido (estilo tiling WM), mas desligue a layer (`CapsLock + D`) se precisar do padrão do Windows.
- Layers marcadas como `EXCLUSIVE` são encerradas com `ProcessClose` (fechamento forçado) ao dar lugar a outra exclusiva.
- Os caminhos das layers externas (`Layer1.ahk`, `Layer3.py`, `Toolbox\...` etc.) são específicos da instalação original — edite o `Map()` no topo da `Layer0.ahk` para apontar para os seus scripts, do contrário os atalhos `Q/W/E/A/Z/C` gerarão erro de execução.
- O atalho `CapsLock + Ç` pressupõe **layout ABNT** (teclado brasileiro).
- Testado com AutoHotkey v2.0; versões antigas (v1.x) não são compatíveis.

---

## Créditos

- [AutoHotkey v2](https://www.autohotkey.com/) — Lexikos e comunidade.
- *"Easy Window Dragging — KDE style"* — script original de **Jonny**, com créditos a ck, thinkstorm, Chris e aurelian (base da Layer 5).
- [VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor) — DLL de acesso aos desktops virtuais do Windows (base da Layer 6).
