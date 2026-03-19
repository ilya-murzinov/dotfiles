# dotfiles

Configs and key mappings. Symlink into `$HOME` (or use [GNU Stow](https://www.gnu.org/software/stow/)).

## Layout

| Dir           | Contents                                                                                       | Install                                                           |
| ------------- | ---------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `vim/`        | .vimrc, .ideavimrc                                                                             | symlink via `make install`                                        |
| `tmux/`       | .tmux.conf                                                                                     | symlink via `make install`                                       |
| `iterm2/`     | com.googlecode.iterm2.plist                                                                   | symlink via `make install`                                        |
| `cursor/`     | Cursor keybindings.json, settings.json                                                        | symlink via `make install` → `~/Library/Application Support/Cursor/User/` |
| `karabiner/`  | Karabiner-Elements config (TypeScript source)                                                  | `make karabiner` — builds to `~/.config/karabiner/karabiner.json` |
| `vial/`       | Vial keymaps (Corne / Corne Mini .vil) — load in [Vial](https://get.vial.today/) when flashing | Open the .vil file in Vial                                        |
| `zmk/`        | ZMK firmware config (Totem) — git subtree from zmk-config-totem-stable                         | `make zmk-pull` / `make zmk-push` to sync                         |
| `keymap-viz/` | Keymap visualizer (ZMK → SVG via [keymap-drawer](https://github.com/caksoylar/keymap-drawer))  | `make keymap-viz` — picture in `keymap-viz/README.md`             |

## Install

From the repo root:

```bash
cd ~/dotfiles
make install
```

Links into `$HOME` by default. Override with `make install DEST=/other/home`. Use `make uninstall` to remove the symlinks.

**Karabiner (macOS):** Requires Node.js. Run `make karabiner` then restart Karabiner-Elements.

**ZMK (keyboard firmware):** First time: commit any local changes, then `make zmk-add`. Then `make zmk-pull` / `make zmk-push` to sync.

**Keymap visualizer:** `make keymap-viz` (installs pipx + keymap-drawer if needed). Output: `keymap-viz/totem.svg`.

---

## Key mappings

### Tmux (prefix: **C-s**)

All bindings below use prefix **C-s** (Ctrl+s) unless marked `-n` (no prefix).

#### Session

| Keys | Action |
|------|--------|
| `tmux` | New session |
| `tmux new -s name` | Named session |
| `C-s d` | Detach |
| `tmux attach -t name` | Attach to session |
| `C-s r` | Reload config |

#### Panes

| Keys | Action |
|------|--------|
| `C-s s` | Split horizontal (below, like Vim `C-w s`) |
| `C-s v` | Split vertical (right, like Vim `C-w v`) |
| `C-s h` | Focus left |
| `C-s j` | Focus down |
| `C-s k` | Focus up |
| `C-s l` | Focus right |
| `C-s C-h` | Resize pane left (repeatable) |
| `C-s C-j` | Resize pane down (repeatable) |
| `C-s C-k` | Resize pane up (repeatable) |
| `C-s C-l` | Resize pane right (repeatable) |
| `C-s M` | Toggle mouse (Shift+m) |
| `C-s x` | Kill pane |
| `C-s z` | Zoom pane (toggle) |

#### Windows

| Keys | Action |
|------|--------|
| `C-s c` | New window |
| `C-s n` | Next window |
| `C-s p` | Prev window |
| `C-s 1` … `9` | Go to window 1–9 |
| `C-s 0` | Go to window 10 |
| `C-s q` | Kill window (confirm) |

#### Copy mode (vi keys)

| Keys | Action |
|------|--------|
| `C-s y` | Enter copy mode (scrollback) |
| `v` | Begin selection |
| `y` | Yank selection to clipboard (tmux-yank) |
| `q` | Quit copy mode |

In copy mode (tmux-open): `o` open selection (URL/path), `C-o` open in editor, `S` search.

#### Plugins

| Plugin | Behavior |
|--------|----------|
| **resurrect** | Save/restore session |
| **continuum** | Auto-save every 15 min; restore on tmux start |
| **yank** | Copy in copy mode to system clipboard |
| **open** | In copy mode: open path/URL, open in editor, search |
| **catppuccin** | Theme, rounded window tabs |
| **vim-tmux-navigator** | C-h/j/k/l move between Vim splits and tmux panes |

#### Misc

- **Shift+Enter:** Sent as CSI u `\e[13;2u` for apps (e.g. Claude Code). Configure iTerm: Key Mappings → Shift+Enter → Send Escape Sequence → `[13;2u`.

---

### Vim (leader: **Space**)

Leader is **Space**. All mappings below are `Space` + key unless noted.

#### Movement

| Keys | Action |
|------|--------|
| `Space h/j/k/l` | Focus window left/down/up/right |
| `C-h` / `C-j` / `C-k` / `C-l` | vim-tmux-navigator (Vim splits + tmux panes) |
| `PageDown` / `PageUp` | Half page down/up |

#### Registers & edit

| Keys | Action |
|------|--------|
| `Space a` / `s` / `d` | Paste from register a / s / d |
| `Space r` | Show registers "" a s d |
| `Space u` (in Fern) | Fern: leave / parent dir |
| `S-u` | Redo |

#### Search & file

| Keys | Action |
|------|--------|
| `Space ff` | GFiles (fzf) |
| `Space fr` | History (fzf) |
| `Space gs` | Rg/Ag search (ripgrep or ag) |

#### Markdown

| Keys | Action |
|------|--------|
| `Space mp` | MarkdownPreview |
| `Space ms` | MarkdownPreviewStop |

#### Fern (file explorer)

| Keys | Action |
|------|--------|
| `Space pv` | Fern . drawer 30 cols, reveal current |
| `Space pe` / `ps` | Fern . reveal current |
| `Space ph` | Fern ~ reveal current |
| In Fern: `e` | Open file in right pane |
| In Fern: `Space u` | Leave / parent dir |

#### Tabs

| Keys | Action |
|------|--------|
| `Space tn` | Tab new |
| `Space tc` | Tab close |
| `Space th` / `tl` | Tab previous / next |

#### Buffers & save

| Keys | Action |
|------|--------|
| `Space w` | Save |
| `Space Space w` | Bdelete (close buffer) |
| `Space Space qq` | Quit |

#### Git (fugitive + gitgutter)

| Keys / Command | Action |
|----------------|--------|
| `:G` | Git status (summary, stage with `-`, open file with `Enter`) |
| `:G diff` | Diff against index |
| `:G blame` | Blame current file |
| `:G commit` | Commit (write buffer to commit, close to abort) |
| `Space gd` | Show diff of current hunk (gitgutter preview) |
| `Space gu` | Undo hunk (revert changes on current line/block) |
| `Space gn` / `Space gN` | Next / previous hunk |
| `Space gp` | Close preview window (after `gd`) |
| Gutter | **vim-gitgutter**: signs in margin for added/modified/deleted lines |

#### Misc

| Keys | Action |
|------|--------|
| `Space m` | Toggle mouse mode |
| `Space q` | Run macro q |
| `Space n` | /, then lr (custom) |
| `Space sq` | %s/.*/'&',/ (wrap lines in quotes+comma) |
| Visual: `Tab` / `S-Tab` | Indent / outdent (and extend selection) |

#### Plugins

- **fzf** (GFiles, History, Rg)
- **catppuccin** (colorscheme)
- **vim-bbye** (Bdelete)
- **markdown-preview.nvim**
- **fern.vim** + fern-mapping-fzf
- **vim-tmux-navigator**
- **vim-fugitive** (Git commands)
- **vim-gitgutter** (git change signs in gutter)
