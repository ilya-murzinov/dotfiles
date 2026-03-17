# Dotfiles: symlink configs into HOME (run from repo root after clone)
# Usage: make install   [DEST=~]   default DEST is $$HOME
#        make uninstall             remove symlinks

DEST ?= $(HOME)
REPO := $(CURDIR)

.PHONY: install uninstall karabiner zmk-add zmk-pull zmk-push keymap-drawer-deps keymap-viz

install:
	$(MAKE) link-vim link-tmux link-zsh link-iterm2
	@echo "Done. Linked dotfiles from $(REPO) to $(DEST)"

karabiner:
	@mkdir -p "$(DEST)/.config/karabiner"
	@cd "$(REPO)/karabiner" && npm install
	@cd "$(REPO)/karabiner" && env HOME="$(DEST)" npm run build
	@echo "Karabiner config written to $(DEST)/.config/karabiner/karabiner.json"

uninstall:
	@rm -f "$(DEST)/.vimrc" "$(DEST)/.ideavimrc" "$(DEST)/.tmux.conf" "$(DEST)/.zshrc"
	@defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool false 2>/dev/null || true
	@defaults delete com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true
	@echo "Removed symlinks. iTerm2: switched back to default preferences location."

# Single-file links
link-vim:
	ln -sf "$(REPO)/vim/.vimrc" "$(DEST)/.vimrc"
	ln -sf "$(REPO)/vim/.ideavimrc" "$(DEST)/.ideavimrc"

link-tmux:
	ln -sf "$(REPO)/tmux/.tmux.conf" "$(DEST)/.tmux.conf"

link-zsh:
	ln -sf "$(REPO)/zsh/.zshrc" "$(DEST)/.zshrc"

# iTerm2: use "Load preferences from custom folder" (symlinked plist is unreliable on fresh installs)
# Run from repo root so REPO is correct. Quit iTerm, run make install, reopen iTerm.
link-iterm2:
	@test -d "$(REPO)/iterm2" || (echo "Error: $(REPO)/iterm2 not found. Run make from dotfiles repo root." && exit 1)
	@ITERM2_DIR="$(shell cd "$(REPO)" 2>/dev/null && pwd)/iterm2"; \
	defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$$ITERM2_DIR"; \
	defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true; \
	echo "iTerm2: preferences folder set to $$ITERM2_DIR (quit iTerm and reopen to apply)"

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

# Keymap visualizer (ZMK → SVG via keymap-drawer). Installs pipx + keymap-drawer if missing.
ZMK_KEYMAP ?= $(REPO)/zmk/config/totem.keymap
KEYMAP_VIZ_DIR := $(REPO)/keymap-viz

keymap-drawer-deps:
	@command -v keymap >/dev/null 2>&1 && exit 0; \
	if ! command -v pipx >/dev/null 2>&1; then \
	  echo "Installing pipx via Homebrew..."; \
	  brew install pipx; \
	  pipx ensurepath 2>/dev/null || true; \
	fi; \
	PIPX=$$(command -v pipx 2>/dev/null || echo "$$(brew --prefix 2>/dev/null)/bin/pipx"); \
	if [ -z "$$PIPX" ] || [ ! -x "$$PIPX" ]; then echo "Could not find pipx. Install with: brew install pipx"; exit 1; fi; \
	echo "Installing keymap-drawer..."; \
	$$PIPX install keymap-drawer; \
	echo "Done. If 'keymap' is not found, run: pipx ensurepath && restart your shell."

keymap-viz: keymap-drawer-deps
	@test -f "$(ZMK_KEYMAP)" || (echo "ZMK keymap not found: $(ZMK_KEYMAP). Run 'make zmk-add' first." && exit 1)
	@mkdir -p "$(KEYMAP_VIZ_DIR)"
	@KEYMAP_CMD=$$(command -v keymap 2>/dev/null || echo "pipx run keymap-drawer keymap"); \
	$$KEYMAP_CMD parse -c 10 -z "$(ZMK_KEYMAP)" -o "$(KEYMAP_VIZ_DIR)/totem.yaml"; \
	$$KEYMAP_CMD draw "$(KEYMAP_VIZ_DIR)/totem.yaml" > "$(KEYMAP_VIZ_DIR)/totem.svg"
	@echo "Keymap SVG: $(KEYMAP_VIZ_DIR)/totem.svg — see keymap-viz/README.md"