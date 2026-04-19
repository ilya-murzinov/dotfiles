# dotfiles

Configs and key mappings. Symlink into `$HOME` via `make install`.

## Layout

| Dir | Contents |
|-----|----------|
| `vim/` | .vimrc, .ideavimrc |
| `nvim/` | init.lua, lua/plugins.lua |
| `tmux/` | .tmux.conf |
| `zsh/` | .zshrc |
| `kitty/` | kitty.conf |
| `karabiner/` | TypeScript source → `~/.config/karabiner/karabiner.json` |
| `bin/` | Scripts (`proj-picker`) |
| `vial/` | Vial keymaps (.vil) — load in [Vial](https://get.vial.today/) |
| `zmk/` | ZMK firmware config (Totem) — git subtree |

## Theme

All tools use **Catppuccin** (Mocha/Macchiato):

- **Kitty**: catppuccin macchiato
- **tmux**: catppuccin/tmux — macchiato
- **vim/nvim**: catppuccin — macchiato
- **zsh**: agnoster prompt with catppuccin palette

## Install

```bash
cd ~/dotfiles
make install
```

Override destination: `make install DEST=/other/home`. Remove symlinks: `make uninstall`.

**Karabiner:** `make karabiner` then restart Karabiner-Elements.

**ZMK:** first time `make zmk-add`, then `make zmk-pull` / `make zmk-push`.

**Keymap visualizer:** `make keymap-viz` → `keymap-viz/totem.svg`.

---

## Docs

- [Vim](docs/vim.md)
- [Tmux](docs/tmux.md)
- [Zsh](docs/zsh.md)
