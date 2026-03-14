# Keymap visualizer (ZMK Totem)

Uses [keymap-drawer](https://github.com/caksoylar/keymap-drawer) to turn the ZMK keymap into an SVG.

**Prereqs:** `zmk/` subtree in this repo (`make zmk-add` if needed). Python 3 and pipx:

```bash
pipx install keymap-drawer
```

**Generate SVG:** From the **dotfiles repo root** (not this dir):

```bash
make keymap-viz
```

**View:** Open `keymap-viz/index.html` in a browser (or `make keymap-viz-open` if you added that target). The SVG is embedded there.

**Keymap path:** Default is `zmk/config/totem.keymap`. Override with `make keymap-viz ZMK_KEYMAP=/path/to/other.keymap`.