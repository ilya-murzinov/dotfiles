# Tmux cheatsheet (C-t prefix, vim-style)

Prefix is **C-t** (with HRM: hold `s` then press `t`).

## Session
| Keys   | Action        |
|--------|----------------|
| `tmux` | New session    |
| `tmux new -s name` | Named session |
| `C-t d` | Detach        |
| `tmux attach -t name` | Attach to session |
| `C-t r` | Reload config |

## Panes
| Keys   | Action           |
|--------|------------------|
| `C-t v`  | Split vertical   |
| `C-t b`  | Split horizontal |
| `C-t h`  | Focus left       |
| `C-t j`  | Focus down      |
| `C-t k`  | Focus up        |
| `C-t l`  | Focus right     |
| `C-t C-h/j/k/l` | Resize pane (repeatable) |
| `C-t x`  | Kill pane       |
| `C-t z`  | Zoom pane (toggle) |

## Windows
| Keys   | Action        |
|--------|----------------|
| `C-t c` | New window    |
| `C-t n` | Next window  |
| `C-t p` | Prev window  |
| `C-t ,` | Rename window |
| `C-t 0-9` | Go to window N |
| `C-t q` | Kill window  |

## Copy mode (vi keys)
| Keys   | Action           |
|--------|-------------------|
| `C-t y` | Enter copy mode (y = yank; avoids [ on small layout) |
| `v`    | Begin selection   |
| `y`    | Yank (copy to clipboard) |
| `o`    | Open selection (path/URL in app; tmux-open) |
| `q`    | Quit copy mode   |

## Plugins
| Plugin | Keys / behavior |
|--------|------------------|
| **resurrect** | `C-t C-s` save session, `C-t C-r` restore |
| **continuum** | Auto-saves every 15 min; restores session when you start tmux |
| **yank** | Copy in copy mode uses system clipboard |
| **open** | In copy mode: select text, press `o` to open path/URL in browser/app |
| **catppuccin** | Theme + rounded window tabs |

## With your layout
- **Prefix**: hold `s` (Ctrl) + `t`.
- **Pane nav**: same as nav layer — `C-t` then `h`/`j`/`k`/`l`.
- **Escape** (e.g. copy mode): use `q+w` combo or `q` to exit copy mode.