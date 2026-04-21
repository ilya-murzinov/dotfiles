# Vim

Leader: **Space**

---

## Core mappings

### Windows & splits

| Keys | Action |
|------|--------|
| `Space v` | Vertical split |
| `Space s` | Horizontal split |
| `Space h/j/k/l` | Focus window left/down/up/right |
| `C-h/j/k/l` | vim-tmux-navigator (splits + tmux panes) |
| `PageDown` / `PageUp` | Half page down/up (`C-d` / `C-u`) |

### Tabs

| Keys | Action |
|------|--------|
| `Space tn` | New tab |
| `Space tx` | Close tab |
| `Space th` / `tl` | Previous / next tab |

#### Registers

| Keys | Action |
|------|--------|
| `Space a/s/d` | Paste from named register a / s / d |
| `Space r` | Show registers `"` `a` `s` `d` |
| `"ay` / `"sy` / `"dy` | Yank into register a / s / d |
| `x` | Delete char without clobbering `"` register |
| `S-u` | Redo |

### Search & replace

| Keys | Action |
|------|--------|
| `C-r` (visual) | Search & replace selected text across file (interactive confirm) |

### Format & indent

| Keys | Action |
|------|--------|
| `Space ft` | Format entire file (`gggqG`) |
| `Space ft` (visual) | Format selection |
| `Tab` / `S-Tab` (visual) | Indent / outdent, keeps selection |

### Buffers & session

| Keys | Action |
|------|--------|
| `Space w` | Save |
| `Space qq` | Quit |

### Misc

| Keys | Action |
|------|--------|
| `Space /` | Toggle comment (vim-commentary) |
| `Space q` | Run macro `q` (`@q`) |
| `Space n` | Jump to next `,` and replace with newline |
| `Space sq` | Wrap every line: `value` → `'value',` |

---

## fzf.vim

**`:Files`** uses `fd` under the hood. **`:Rg`** uses ripgrep — results update as you type.

| Keys | Action |
|------|--------|
| `Space ff` | Files — all files in project |
| `Space fg` | GFiles — git-tracked files only |
| `Space fr` | History — recently opened files |
| `Space sg` | Rg — ripgrep search (opens prompt) |
| `Space sg` (visual) | Rg — search selected text |
| `Space sw` | Rg — search word under cursor |

**Inside fzf popup:**

| Keys | Action |
|------|--------|
| `C-j` / `C-k` | Move up/down |
| `C-t` | Open in new tab |
| `C-x` | Open in horizontal split |
| `C-v` | Open in vertical split |
| `Tab` | Multi-select (mark) |
| `S-Tab` | Multi-deselect |
| `Enter` | Open selected |
| `Esc` | Cancel |

**Tips:**
- `:Rg` with no arg opens live ripgrep — type to filter in real time
- Use `Tab` to select multiple files then `Enter` to open all
- `:BLines` fuzzy search lines in current buffer
- `:Lines` fuzzy search across all open buffers
- `:Marks` jump to a mark
- `:Jumps` navigate jump list
- `:Commands` fuzzy search commands
- `:Maps` fuzzy search key mappings

---

## vim-fugitive

The full git workflow without leaving vim.

### Mappings

| Keys | Action |
|------|--------|
| `Space gc` | Open Git status buffer (`:G`) |
| `Space ga` | Git blame (`--date=short --abbrev=6`) |
| `Space gf` | Git pull |
| `Space gp` | Git push (in status buffer only) |
| `Space gpf` | Git push --force-with-lease |

### Status buffer (`:G`)

| Keys | Action |
|------|--------|
| `s` | Stage file / hunk under cursor |
| `u` | Unstage |
| `-` | Toggle stage/unstage |
| `=` | Inline diff toggle |
| `I` / `P` | `git add -p` (patch stage) |
| `cc` | Commit staged |
| `ca` | Amend last commit |
| `cw` | Reword last commit message |
| `ce` | Amend without editing message |
| `czz` | Stash |
| `czp` | Pop stash |
| `dd` | Diff file under cursor |
| `dv` | Diff in vertical split |
| `ds` / `dh` | Diff in horizontal split |
| `X` | Discard changes |
| `Enter` | Open file |
| `o` | Open in split |
| `O` | Open in new tab |
| `gq` / `q` | Close |
| `g?` | Show all mappings |

### Diff (`:Gdiffsplit`)

In a 3-way merge conflict there are 3 buffers: `//2` (target/ours), `//3` (merge/theirs), working file.

| Keys | Action |
|------|--------|
| `dp` | `diffput` — push hunk to other buffer |
| `do` | `diffget` — pull hunk from other buffer |
| `:diffget //2` | Accept ours (target branch) |
| `:diffget //3` | Accept theirs (merge branch) |
| `]c` / `[c` | Jump to next / previous conflict |
| `:Gwrite` | Mark conflict resolved (`git add %`) |

### Useful commands

| Command | Action |
|---------|--------|
| `:Gdiffsplit` | Diff current file staged vs working |
| `:Gdiffsplit HEAD~1` | Diff against any ref |
| `:Git blame` | Blame sidebar (`Enter` → jump to commit, `o` → split, `A`/`C`/`D` resize) |
| `:0Gclog` | File history in quickfix (`]q` / `[q` to walk) |
| `:Gclog` | Branch history |
| `:Gwrite` | `git add %` (also resolves merge conflict) |
| `:Gread` | `git checkout %` — revert file to index |
| `:GMove new/path` | Rename/move and update buffer |
| `:GDelete` | Delete file and wipe buffer |
| `:Git log --oneline --graph` | ASCII branch graph |
| `:Git stash` / `:Git stash pop` | Stash / pop |

---

## vim-gitgutter

Gutter signs showing per-line git status. Signs update on `updatetime` (set to 50ms).

**Signs:** `+` added  `~` modified  `-` deleted  `_` deleted line below  `‾` first line deleted

| Keys | Action |
|------|--------|
| `Space gd` | Preview hunk diff in floating window |
| `Space gu` | Undo hunk (revert to index) |
| `Space gdn` | Next hunk |
| `Space gdp` | Previous hunk |
| `Space gp` | Close preview window |

**Text objects** (use with `d`, `c`, `v`, `y`):

| Keys | Action |
|------|--------|
| `ic` | Inner hunk |
| `ac` | Around hunk |

**Tips:**
- `]c` / `[c` also jump hunks when not in diff mode
- `:GitGutterFold` folds all unchanged lines — great for reviewing a large file

---

## fern.vim + fern-mapping-fzf

File explorer in a drawer or window. Auto-reveals current file on buffer switch.

### Opening

| Keys | Action |
|------|--------|
| `Space pv` | Drawer (30 cols), reveal current file |
| `Space pe` / `ps` | Full window, reveal current file |
| `Space ph` | Explore from `~` |

### Inside fern

| Keys | Action |
|------|--------|
| `Enter` | Expand dir / open file |
| `e` | Open file in right pane |
| `E` | Open file in new tab |
| `l` | Expand / enter dir |
| `h` | Collapse dir |
| `Space u` | Go to parent dir |
| `-` | Toggle collapse/expand |
| `R` | Rename |
| `D` | Delete |
| `K` | New dir |
| `N` | New file |
| `C` | Copy |
| `M` | Move |
| `yy` | Copy path |
| `!` | Shell command on node |
| `i` | Info |
| `q` | Close fern |
| `g?` | Show all mappings |

### fzf inside fern

| Keys | Action |
|------|--------|
| `ff` | fzf files under selection |
| `fd` | fzf dirs under selection |
| `fa` | fzf files + dirs under selection |
| `frf` | fzf files from root |
| `frd` | fzf dirs from root |
| `fra` | fzf files + dirs from root |

**Tips:**
- Hidden files shown by default (`fern#default_hidden = 1`)
- `vim-rooter` auto-cds to project root, so `Space pv` always opens from the repo root
- Fern auto-reveals the current buffer's file every time you switch buffers

---

## undotree

Visualises the full undo history as a tree — you can recover changes that `u` / `C-r` can't reach.

| Keys | Action |
|------|--------|
| `Space u` | Toggle undotree panel |

**Inside undotree panel:**

| Keys | Action |
|------|--------|
| `j` / `k` | Walk through undo states (older/newer) |
| `J` / `K` | Jump to oldest / newest state |
| `Enter` | Restore selected state |
| `p` | Preview diff of selected state |
| `C` | Clear undo history |
| `q` | Close |

**Tips:**
- Undo history is **persistent** (saved to `~/.vim/undodir`) — survives closing vim
- The panel (layout 3) shows the diff preview below the tree
- Every branch in the tree is a recovery point — you never truly lose edits

---

## vim-commentary

Comment/uncomment with a motion.

| Keys | Action |
|------|--------|
| `Space /` | Toggle comment on current line |
| `gc` + motion | Comment over motion (e.g. `gcip` = comment paragraph) |
| `gc` (visual) | Comment selection |
| `gcc` | Comment current line |
| `gcgc` / `gcu` | Uncomment adjacent commented lines |

**Tips:**
- `gc5j` comments 5 lines down
- `gcap` comments a paragraph
- Works with any filetype that has a `commentstring` set

---

## vim-rooter

Automatically `lcd` to the project root (git root, etc.) when opening a file. Uses `lcd` so other windows are unaffected.

No mappings — runs automatically. Useful because `Space ff` / `Space sg` then search the whole project, not just the current dir.

---

## Tags (markdown frontmatter)

| Keys | Action |
|------|--------|
| `Space ta` | Add tag (completion from all `.md` files in project) |
| `Space ts` | Jump to `tags:` line in frontmatter |

---

## markdown-preview.nvim

Live preview in Chrome. Opens a new Chrome window, syncs scroll position with cursor.

| Keys | Action |
|------|--------|
| `Space mp` | Start preview |
| `Space ms` | Stop preview |

---

