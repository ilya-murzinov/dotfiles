# Dotfiles: symlink configs into HOME (run from repo root after clone)
# Usage: make install   [DEST=~]   default DEST is $$HOME
#        make uninstall             remove symlinks

DEST ?= $(HOME)
REPO := $(CURDIR)

.PHONY: install uninstall karabiner install-plug link-vim-minimal link-bin link-aerospace zmk-add zmk-pull zmk-push zmk-force-push zmk-sync keymap-drawer-deps keymap-viz

install:
	$(MAKE) link-vim link-nvim link-tmux link-zsh link-kitty link-bin link-aerospace
	@echo "Done. Linked dotfiles from $(REPO) to $(DEST)"

karabiner:
	@mkdir -p "$(DEST)/.config/karabiner"
	@cd "$(REPO)/karabiner" && npm install
	@cd "$(REPO)/karabiner" && env HOME="$(DEST)" npm run build
	@echo "Karabiner config written to $(DEST)/.config/karabiner/karabiner.json"

uninstall:
	@rm -f "$(DEST)/.vimrc" "$(DEST)/.vimrc_minimal" "$(DEST)/.ideavimrc" "$(DEST)/.tmux.conf" "$(DEST)/.zshrc" "$(DEST)/.aerospace.toml"
	@rm -f "$(DEST)/.vim/core.vim" "$(DEST)/.vim/plugins.vim" "$(DEST)/.vim/mappings.vim" "$(DEST)/.vim/autocmds.vim"
	@rm -rf "$(DEST)/.vim/plugin-config"
	@rm -f "$(DEST)/.config/nvim/init.lua" "$(DEST)/.config/nvim/lua/plugins.lua" "$(DEST)/.config/nvim/lua/setup.lua"
	@rm -f "$(DEST)/.config/kitty/kitty.conf" "$(DEST)/.config/kitty/catppuccin-mocha.conf"
	@echo "Removed symlinks."

install-plug:
	@curl -fLo "$(DEST)/.vim/autoload/plug.vim" --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

link-vim-minimal:
	@mkdir -p "$(DEST)/.vim"
	ln -sf "$(REPO)/vim/.vimrc_minimal" "$(DEST)/.vimrc"
	ln -sf "$(REPO)/vim/.vim/core.vim" "$(DEST)/.vim/core.vim"
	ln -sf "$(REPO)/vim/.vim/reload.vim" "$(DEST)/.vim/reload.vim"
	ln -sf "$(REPO)/vim/.vim/functions.vim" "$(DEST)/.vim/functions.vim"
	ln -sf "$(REPO)/vim/.vim/mappings.vim" "$(DEST)/.vim/mappings.vim"
	$(MAKE) install-plug

link-vim:
	@mkdir -p "$(DEST)/.vim"
	ln -sf "$(REPO)/vim/.vimrc" "$(DEST)/.vimrc"
	ln -sf "$(REPO)/vim/.ideavimrc" "$(DEST)/.ideavimrc"
	ln -sf "$(REPO)/vim/.vim/reload.vim" "$(DEST)/.vim/reload.vim"
	ln -sf "$(REPO)/vim/.vim/functions.vim" "$(DEST)/.vim/functions.vim"
	ln -sf "$(REPO)/vim/.vim/core.vim" "$(DEST)/.vim/core.vi"
	ln -sf "$(REPO)/vim/.vim/plugins.vim" "$(DEST)/.vim/plugins.vim"
	ln -sf "$(REPO)/vim/.vim/mappings.vim" "$(DEST)/.vim/mappings.vim"
	ln -sf "$(REPO)/vim/.vim/autocmds.vim" "$(DEST)/.vim/autocmds.vim"
	@rm -rf "$(DEST)/.vim/plugin-config"
	ln -s "$(REPO)/vim/.vim/plugin-config" "$(DEST)/.vim/plugin-config"
	$(MAKE) install-plug

link-nvim:
	@mkdir -p "$(DEST)/.config/nvim/lua"
	ln -sf "$(REPO)/nvim/init.lua" "$(DEST)/.config/nvim/init.lua"
	ln -sf "$(REPO)/nvim/lua/plugins.lua" "$(DEST)/.config/nvim/lua/plugins.lua"
	ln -sf "$(REPO)/nvim/lua/setup.lua" "$(DEST)/.config/nvim/lua/setup.lua"

link-tmux:
	ln -sf "$(REPO)/tmux/.tmux.conf" "$(DEST)/.tmux.conf"

link-zsh:
	ln -sf "$(REPO)/zsh/.zshrc" "$(DEST)/.zshrc"

link-kitty:
	@mkdir -p "$(DEST)/.config/kitty"
	ln -sf "$(REPO)/kitty/kitty.conf" "$(DEST)/.config/kitty/kitty.conf"
	ln -sf "$(REPO)/kitty/catppuccin-mocha.conf" "$(DEST)/.config/kitty/catppuccin-mocha.conf"

link-aerospace:
	ln -sf "$(REPO)/aerospace/.aerospace.toml" "$(DEST)/.aerospace.toml"

link-bin:
	@mkdir -p "$(DEST)/.local/bin"
	ln -sf "$(REPO)/bin/tmux-sessionizer" "$(DEST)/.local/bin/tmux-sessionizer"
	ln -sf "$(REPO)/bin/proj-picker" "$(DEST)/.local/bin/proj-picker"
	ln -sf "$(REPO)/bin/tmux-open-in-vim" "$(DEST)/.local/bin/tmux-open-in-vim"

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

