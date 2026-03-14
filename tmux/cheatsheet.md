# Tmux cheatsheet (C-t prefix, vim-style)

Prefix is **C-t** (with HRM: hold s then press t). For bindings, only letters, C-letter, and **comma, dot, quotes** are used (no %, |, &, etc.).

## Session

| Keys                  | Action            |
| --------------------- | ----------------- |
| `tmux`                | New session       |
| `tmux new -s name`    | Named session     |
| `C-t d`               | Detach            |
| `tmux attach -t name` | Attach to session |
| `C-t r`               | Reload config     |

## Panes

| Keys      | Action                         |
| --------- | ------------------------------ |
| `C-t v`   | Split vertical                 |
| `C-t b`   | Split horizontal               |
| `C-t h`   | Focus left                     |
| `C-t j`   | Focus down                     |
| `C-t k`   | Focus up                       |
| `C-t l`   | Focus right                    |
| `C-t C-h` | Resize pane left (repeatable)  |
| `C-t C-j` | Resize pane down (repeatable)  |
| `C-t C-k` | Resize pane up (repeatable)    |
| `C-t C-l` | Resize pane right (repeatable) |
| `C-t x`   | Kill pane                      |
| `C-t z`   | Zoom pane (toggle)             |

## Windows

| Keys              | Action                            |
| ----------------- | --------------------------------- |
| `C-t c`           | New window                        |
| `C-t n`           | Next window                       |
| `C-t p`           | Prev window                       |
| `C-t ,`           | Rename window                     |
| `C-t 1` … `C-t 9` | Go to window 1–9                  |
| `C-t 0`           | Go to window 10 (if base-index 1) |
| `C-t q`           | Kill window                       |

## Copy mode (vi keys)

| Keys    | Action                      |
| ------- | --------------------------- |
| `C-t y` | Enter copy mode             |
| `v`     | Begin selection             |
| `y`     | Yank selection to clipboard |
| `q`     | Quit copy mode              |

### In copy mode (yank / open)

| Keys    | Action                                      |
| ------- | ------------------------------------------- |
| `y`     | Copy selection to clipboard (yank)          |
| `C-t L` | Copy current line to clipboard (tmux-yank)  |
| `o`     | Open selection (URL/path in app; tmux-open) |
| `C-o`   | Open selection in $EDITOR (tmux-open)       |
| `S`     | Search selection (tmux-open)                |

## Plugins

| Plugin         | Keys / behavior                                                                |
| -------------- | ------------------------------------------------------------------------------ |
| **resurrect**  | `C-t S` save session, `C-t R` restore                                          |
| **continuum**  | Auto-saves every 15 min; restores session when tmux starts                     |
| **yank**       | Copy in copy mode to system clipboard; `C-t L` copy line                       |
| **open**       | In copy mode: select text, `o` open path/URL, `C-o` open in editor, `S` search |
| **catppuccin** | Theme and rounded window tabs                                                  |

## With your layout

- **Prefix**: hold s (Ctrl) then t.
- **Pane nav**: same as nav layer — C-t then h j k l.
- **Escape** (e.g. copy mode): press q to exit copy mode.
