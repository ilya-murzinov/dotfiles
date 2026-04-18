# Dotfiles: symlink configs into HOME (run from repo root after clone)
# Usage: make install   [DEST=~]   default DEST is $$HOME
#        make uninstall             remove symlinks

DEST ?= $(HOME)
REPO := $(CURDIR)

.PHONY: install uninstall karabiner bundle-minimal zmk-add zmk-pull zmk-push zmk-force-push zmk-sync keymap-drawer-deps keymap-viz

install:
	$(MAKE) link-vim link-nvim link-tmux link-zsh link-kitty link-iterm2-dynamic-profiles
	@echo "Done. Linked dotfiles from $(REPO) to $(DEST)"

karabiner:
	@mkdir -p "$(DEST)/.config/karabiner"
	@cd "$(REPO)/karabiner" && npm install
	@cd "$(REPO)/karabiner" && env HOME="$(DEST)" npm run build
	@echo "Karabiner config written to $(DEST)/.config/karabiner/karabiner.json"

uninstall:
	@rm -f "$(DEST)/.vimrc" "$(DEST)/.vimrcm" "$(DEST)/.ideavimrc" "$(DEST)/.tmux.conf" "$(DEST)/.zshrc"
	@rm -f "$(DEST)/.vim/core.vim" "$(DEST)/.vim/plugins.vim" "$(DEST)/.vim/mappings.vim" "$(DEST)/.vim/autocmds.vim"
	@rm -rf "$(DEST)/.vim/plugin-config"
	@rm -f "$(DEST)/.config/nvim/init.lua" "$(DEST)/.config/nvim/lua/plugins.lua"
	@rm -f "$(DEST)/.config/kitty/kitty.conf" "$(DEST)/.config/kitty/catppuccin-mocha.conf"
	@rm -rf "$(DEST)/Library/Application Support/iTerm2/DynamicProfiles"
	@echo "Removed symlinks."

bundle-minimal:
	@cat vim/.vim/core.vim vim/.vim/mappings.vim > vim/.vimrcm
	@echo 'colorscheme slate' >> vim/.vimrcm
	@echo "Written: vim/.vimrcm"

link-vim: bundle-minimal
	@mkdir -p "$(DEST)/.vim"
	ln -sf "$(REPO)/vim/.vimrc" "$(DEST)/.vimrc"
	ln -sf "$(REPO)/vim/.vimrcm" "$(DEST)/.vimrcm"
	ln -sf "$(REPO)/vim/.ideavimrc" "$(DEST)/.ideavimrc"
	ln -sf "$(REPO)/vim/.vim/core.vim" "$(DEST)/.vim/core.vim"
	ln -sf "$(REPO)/vim/.vim/plugins.vim" "$(DEST)/.vim/plugins.vim"
	ln -sf "$(REPO)/vim/.vim/mappings.vim" "$(DEST)/.vim/mappings.vim"
	ln -sf "$(REPO)/vim/.vim/autocmds.vim" "$(DEST)/.vim/autocmds.vim"
	@rm -rf "$(DEST)/.vim/plugin-config"
	ln -s "$(REPO)/vim/.vim/plugin-config" "$(DEST)/.vim/plugin-config"

link-nvim:
	@mkdir -p "$(DEST)/.config/nvim/lua"
	ln -sf "$(REPO)/nvim/init.lua" "$(DEST)/.config/nvim/init.lua"
	ln -sf "$(REPO)/nvim/lua/plugins.lua" "$(DEST)/.config/nvim/lua/plugins.lua"

link-tmux:
	ln -sf "$(REPO)/tmux/.tmux.conf" "$(DEST)/.tmux.conf"

link-zsh:
	ln -sf "$(REPO)/zsh/.zshrc" "$(DEST)/.zshrc"

link-kitty:
	@mkdir -p "$(DEST)/.config/kitty"
	ln -sf "$(REPO)/kitty/kitty.conf" "$(DEST)/.config/kitty/kitty.conf"
	ln -sf "$(REPO)/kitty/catppuccin-mocha.conf" "$(DEST)/.config/kitty/catppuccin-mocha.conf"

link-iterm2-dynamic-profiles:
	@pgrep -x iTerm2 >/dev/null 2>&1 && (echo "Error: Quit iTerm2 first (Cmd+Q), then run again." && exit 1) || true
	@mkdir -p "$(REPO)/iterm2/DynamicProfiles"
	@echo "iTerm2: Clearing old preferences..."
	@defaults delete com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || true
	@defaults delete com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true
	@ITERM2_SUPPORT="$(DEST)/Library/Application Support/iTerm2"; \
	ITERM2_DIR="$$ITERM2_SUPPORT/DynamicProfiles"; \
	rm -rf "$$ITERM2_DIR"; \
	ln -sf "$(REPO)/iterm2/DynamicProfiles" "$$ITERM2_DIR"; \
	echo "iTerm2: DynamicProfiles symlinked to $(REPO)/iterm2/DynamicProfiles"

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

zmk-force-push: zmk-remote
	git subtree split --prefix=zmk -b zmk-split-tmp
	git push zmk-config zmk-split-tmp:master --force
	git branch -D zmk-split-tmp

zmk-sync:
	python3 sync_keymap.py

