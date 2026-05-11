# dotfiles

Configs and key mappings. Installed with **[GNU Stow](https://www.gnu.org/software/stow/)** via `make install` (requires `stow`; `brew install stow` if needed).

Each top-level package directory mirrors paths under `$HOME` (for example `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`).

## Layout

| Dir | Role |
|-----|------|
| `vim/` | `~/.vimrc`, `~/.vim/`, `~/.ideavimrc` |
| `vim-minimal/` | Optional minimal Vim (`make vim-minimal`); `.vim/*.vim` symlink into `vim/.vim/` |
| `nvim/` | `~/.config/nvim/` |
| `tmux/` | `~/.tmux.conf` |
| `zsh/` | `~/.zshrc` |
| `starship/` | `~/.config/starship.toml` |
| `yazi/` | `~/.config/yazi/yazi.toml` |
| `kitty/` | `~/.config/kitty/` |
| `bin/` | `~/bin/` (Stow) — separate from **`~/.local/bin`** (other tools’ installers use that) |
| `aerospace/` | `~/.aerospace.toml` |
| `karabiner/` | TypeScript source → `make karabiner` writes `~/.config/karabiner/karabiner.json` |
| `vial/` | Vial keymaps (.vil) — load in [Vial](https://get.vial.today/) |
| `zmk/` | ZMK firmware config (Totem) — git subtree |

## Theme

All tools use **Catppuccin** (Mocha/Macchiato):

- **Kitty**: catppuccin macchiato
- **tmux**: catppuccin/tmux — macchiato
- **vim/nvim**: catppuccin — macchiato
- **zsh**: [Starship](https://starship.rs/) (`brew install starship` via `make install`). Without Starship: short `%` prompt + `vcs_info` markers.
- **yazi**: Catppuccin Mocha flavor (from [yazi-rs/flavors](https://github.com/yazi-rs/flavors))

## Install

```bash
cd ~/dotfiles
make install
```

Override destination: `make install DEST=/other/home`. Remove Stowed symlinks: `make uninstall`.

**`install-pre-stow`** unlinks symlink leftovers where Stow manages a path (`~/.vimrc`, `~/.config/nvim`, …); it ignores plain files. **`~/.local/bin`** is never modified.

**Minimal Vim instead of full:** `make vim-minimal`. Restore full Vim: `make vim-full` or `make install`.

**Karabiner:** `make karabiner` then restart Karabiner-Elements.

**ZMK:** first time `make zmk-add` (no-op if `zmk/` already exists), then `make zmk-pull` / `make zmk-push`. Force subtree push: `CONFIRM=yes make zmk-force-push`.

**Keymap:** `python3 sync_keymap.py` or `make zmk-sync` to sync Vial → ZMK keymaps.

---

## Docs

- [Vim](docs/vim.md)
- [Neovim](docs/nvim.md)
- [Tmux](docs/tmux.md)
- [Zsh](docs/zsh.md)
- [Yazi](docs/yazi.md)
