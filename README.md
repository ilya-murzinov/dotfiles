# dotfiles

Configs and cheatsheets. Symlink into `$HOME` (or use [GNU Stow](https://www.gnu.org/software/stow/)).

## Layout

| Dir | Contents | Install |
|-----|----------|---------|
| `vim/` | .vimrc, .ideavimrc | symlink via `make install` |
| `tmux/` | .tmux.conf, cheatsheet.md | symlink via `make install` |
| `karabiner/` | Karabiner-Elements config (TypeScript source) | `make karabiner` — builds to `~/.config/karabiner/karabiner.json` |
| `vial/` | Vial keymaps (Corne / Corne Mini .vil) — load in [Vial](https://get.vial.today/) when flashing | Open the .vil file in Vial |
| `zmk/` | ZMK firmware config (Totem) — git subtree from zmk-config-totem-stable | `make zmk-pull` / `make zmk-push` to sync |
| `keymap-viz/` | Keymap visualizer (ZMK → SVG via [keymap-drawer](https://github.com/caksoylar/keymap-drawer)) | `make keymap-viz` then open `keymap-viz/index.html` |

## Install (symlink)

From the repo root (e.g. after `git clone ... ~/dotfiles`):

```bash
cd ~/dotfiles
make install
```

Links into `$(HOME)` by default. Override with `make install DEST=/other/home`. Use `make uninstall` to remove the symlinks.

**Karabiner (macOS):** Requires Node.js. Run `make karabiner` to build and write the config to `~/.config/karabiner/karabiner.json`. Restart Karabiner-Elements afterward.

**ZMK (keyboard firmware):** The `zmk/` directory is a git subtree of [zmk-config-totem-stable](https://github.com/ilya-murzinov/zmk-config-totem-stable). First time (or on a fresh clone without zmk): commit any local changes, then run `make zmk-add`. After that use `make zmk-pull` to pull updates and `make zmk-push` to push local zmk changes.

**Keymap visualizer:** Renders the ZMK Totem keymap as SVG. Requires [keymap-drawer](https://github.com/caksoylar/keymap-drawer) (`pipx install keymap-drawer`) and the `zmk/` subtree. Run `make keymap-viz` to generate `keymap-viz/totem.svg`, then open `keymap-viz/index.html` in a browser. `make keymap-viz-open` builds and opens it.