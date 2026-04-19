# Neovim

Neovim sources `~/.vimrc` (all shared vim config + plugins) and adds nvim-only plugins on top.
See [vim.md](vim.md) for shared mappings and plugins.

Plugin managers: **vim-plug** (most plugins), **lazy.nvim** (blink.cmp only).

Leader: **Space**

---

## which-key

Shows available keybindings in a popup after pressing leader (300ms delay).

| Keys | Action |
|------|--------|
| `Space ?` | Show all keybindings |

Leader groups: `f` find · `g` git · `j` java · `s` search · `p` file explorer · `t` tab · `m` markdown · `o` obsidian

---

## blink.cmp

Completion engine. Sources: LSP, path, buffer. `Tab` accepts the selected item.

Markdown buffers also get obsidian sources (`[[` link completion, tags).

---

## fzf-lua

Fuzzy picker backed by fzf. Used as the picker for obsidian.nvim.

---

## diffview.nvim

Side-by-side diff viewer and file history browser. Best used for PR review: check out the branch, then open diffview.

| Keys | Action |
|------|--------|
| `Space gd` | Diff current branch vs `origin/master` |
| `Space gh` | Git history of current file |
| `Space gq` | Close diffview |

**Inside diffview:**

| Keys | Action |
|------|--------|
| `]c` / `[c` | Next / previous hunk |
| `Tab` / `S-Tab` | Next / previous file in the file panel |
| `gf` | Open file in previous window |
| `q` | Close |

---

## nvim-treesitter

Syntax parsing for accurate highlighting and indentation. Installed parsers:
`java` `lua` `python` `javascript` `typescript` `json` `yaml` `toml` `markdown` `bash` `vim` `vimdoc`

No keymaps — runs automatically on buffer open. Add more parsers with `:TSInstall <lang>`.

---

## LSP

Language server support via `nvim-lspconfig`. Servers installed and managed by **Mason** (`:Mason` to open the UI).

### Keymaps (active when an LSP is attached)

| Keys | Action |
|------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `Space rn` | Rename symbol |
| `Space ca` | Code action |
| `Space e` | Show diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |

### Mason

| Command | Action |
|---------|--------|
| `:Mason` | Open Mason UI |
| `:MasonUpdate` | Update all installed servers |
| `:LspInfo` | Show active servers for current buffer |
| `:LspLog` | Open LSP log (debug server startup issues) |

---

## Java (nvim-jdtls)

Java LSP via Eclipse JDT LS, installed by Mason. Starts automatically on any `.java` file. Workspace cache stored per project in `~/.local/share/nvim/jdtls-workspace/`.

### Keymaps (active in Java buffers)

| Keys | Action |
|------|--------|
| `Space jo` | Organize imports |
| `Space jt` | Run nearest test method |
| `Space jT` | Run test class |
| `Space je` | Extract variable |
| `Space jm` | Extract method |

All standard LSP keymaps (`gd`, `K`, etc.) also apply.

**Tips:**
- First open of a project is slow — jdtls indexes the whole codebase
- `:LspInfo` shows whether jdtls attached successfully
- Requires `java` (17+) on `PATH`

---

## obsidian.nvim

Obsidian vault integration. Vault path set via `$OBSIDIAN_VAULT` environment variable.

| Keys | Action |
|------|--------|
| `Space on` | New note |
| `Space of` | Quick switch (fuzzy find notes) |
| `Space os` | Search notes (full text) |
| `Space od` | Open today's daily note |
| `Space ob` | Backlinks for current note |
| `Space ot` | Browse tags |
| `Space ol` | Follow link under cursor |
| `Space oi` | Insert template |

**`[[` completion** works in markdown buffers via blink.cmp — type `[[` to fuzzy-search notes, `#` for headings within a note, `^` for blocks.

**Tips:**
- Note IDs are auto-generated as kebab-case from the title
- `conceallevel=2` hides markup for cleaner reading
- Obsidian LS attaches automatically to markdown files inside the vault
