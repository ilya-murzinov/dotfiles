# Tmux

Prefix: **C-s**

## Sessions

| Keys | Action |
|------|--------|
| `tmux` | New session |
| `tmux new -s name` | Named session |
| `C-s d` | Detach |
| `tmux attach -t name` | Attach to session |

## Panes

| Keys | Action |
|------|--------|
| `C-s s` | Split horizontal (below) |
| `C-s v` | Split vertical (right) |
| `C-h/j/k/l` | Navigate panes (vim-tmux-navigator) |
| `C-s C-h/j/k/l` | Resize pane (repeatable) |
| `C-s M` | Toggle mouse |
| `C-s x` | Kill pane |
| `C-s z` | Zoom pane |

## Windows

| Keys | Action |
|------|--------|
| `C-s n` | New window |
| `C-s ]` / `[` | Next / previous window |
| `C-s 1`…`9` | Go to window 1–9 |
| `C-s <` / `>` | Move window left / right |
| `C-s w` | fzf window picker |
| `C-s r w` | Rename window |
| `C-s r c` | Reload config |
| `C-s f` | Open new window in chosen project dir (fzf) |

## Copy mode (vi keys)

| Keys | Action |
|------|--------|
| `C-s c` | Enter copy mode |
| `v` | Begin selection |
| `y` | Yank to clipboard (tmux-yank) |
| `Escape` | Cancel |
| `o` | Open selection (URL/path) |
| `C-o` | Open in editor |
| `S` | Web search |

## Plugins

| Plugin | Behavior |
|--------|----------|
| **resurrect** | Save/restore session |
| **continuum** | Auto-save every 15 min, restore on start |
| **yank** | Copy to system clipboard in copy mode |
| **open** | Open paths/URLs from copy mode |
| **catppuccin** | Macchiato theme, rounded tabs |
| **vim-tmux-navigator** | C-h/j/k/l across Vim splits and tmux panes |

## Notes

- **Shift+Enter** sent as `\e[13;2u` for apps like Claude Code. In iTerm2: Key Mappings → Shift+Enter → Send Escape Sequence → `[13;2u`.
