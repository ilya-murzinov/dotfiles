# Dotfiles: symlink configs into HOME (run from repo root after clone)
# Usage: make install   [DEST=~]   default DEST is $$HOME
#        make uninstall             remove symlinks

DEST ?= $(HOME)
REPO := $(CURDIR)

.PHONY: install uninstall karabiner zmk-add zmk-pull zmk-push keymap-viz keymap-viz-open

install:
	$(MAKE) link-vim link-tmux
	@echo "Done. Linked dotfiles from $(REPO) to $(DEST)"

karabiner:
	@mkdir -p "$(DEST)/.config/karabiner"
	@cd "$(REPO)/karabiner" && npm install
	@cd "$(REPO)/karabiner" && env HOME="$(DEST)" npm run build
	@echo "Karabiner config written to $(DEST)/.config/karabiner/karabiner.json"

uninstall:
	@rm -f "$(DEST)/.vimrc" "$(DEST)/.ideavimrc" "$(DEST)/.tmux.conf"
	@echo "Removed symlinks."

# Single-file links
link-vim:
	ln -sf "$(REPO)/vim/.vimrc" "$(DEST)/.vimrc"
	ln -sf "$(REPO)/vim/.ideavimrc" "$(DEST)/.ideavimrc"

link-tmux:
	ln -sf "$(REPO)/tmux/.tmux.conf" "$(DEST)/.tmux.conf"

# ZMK config: subtree linked to zmk-config-totem-stable repo
zmk-remote:
	@git remote get-url zmk-config >/dev/null 2>&1 || git remote add zmk-config git@github.com:ilya-murzinov/zmk-config-totem-stable.git

zmk-add: zmk-remote
	@echo "Fetching zmk-config..."
	@git fetch zmk-config master
	git subtree add --prefix=zmk zmk-config master --squash

zmk-pull: zmk-remote
	git subtree pull --prefix=zmk zmk-config master --squash

zmk-push: zmk-remote
	git subtree push --prefix=zmk zmk-config master

# Keymap visualizer (ZMK → SVG via keymap-drawer). Requires: pipx install keymap-drawer, zmk/ in repo
ZMK_KEYMAP ?= $(REPO)/zmk/config/totem.keymap
KEYMAP_VIZ_DIR := $(REPO)/keymap-viz

keymap-viz:
	@command -v keymap >/dev/null 2>&1 || (echo "Install keymap-drawer: pipx install keymap-drawer" && exit 1)
	@test -f "$(ZMK_KEYMAP)" || (echo "ZMK keymap not found: $(ZMK_KEYMAP). Run 'make zmk-add' first." && exit 1)
	keymap parse -c 10 -z "$(ZMK_KEYMAP)" -o "$(KEYMAP_VIZ_DIR)/totem.yaml"
	keymap draw "$(KEYMAP_VIZ_DIR)/totem.yaml" > "$(KEYMAP_VIZ_DIR)/totem.svg"
	@echo "Keymap SVG: $(KEYMAP_VIZ_DIR)/totem.svg — open keymap-viz/index.html to view"

keymap-viz-open: keymap-viz
	@open "$(KEYMAP_VIZ_DIR)/index.html" 2>/dev/null || xdg-open "$(KEYMAP_VIZ_DIR)/index.html" 2>/dev/null || echo "Open $(KEYMAP_VIZ_DIR)/index.html in your browser"