# Dotfiles via GNU Stow (https://www.gnu.org/software/stow/). Package dirs mirror paths under $HOME.
#   make install              # stow (+ bin/ → ~/bin), brew helpers, vim-plug, TPM
#   make install DEST=/path
#   make uninstall            # stow -D (remove symlinks Stow created)
#   install-pre-stow          # unlink legacy symlinks before Stow (never touches ~/.local/bin)
#   make vim-minimal          # swap full Vim for minimal (mutually exclusive with vim package)
#   make vim-full             # swap back to full Vim
# Destructive: zmk-force-push / zmk-piantor-force-push require CONFIRM=yes

DEST ?= $(HOME)
REPO := $(CURDIR)
STOW := stow
STOW_PACKAGES := aerospace bin kitty nvim starship tmux vim yazi zsh

.PHONY: install uninstall install-stow install-pre-stow install-plug install-tpm \
	install-zsh-plugins install-starship install-yazi \
	vim-minimal vim-full \
	karabiner \
	zmk-remote zmk-add zmk-pull zmk-push zmk-force-push zmk-sync \
	zmk-piantor-remote zmk-piantor-add zmk-piantor-pull zmk-piantor-push zmk-piantor-force-push

install: install-stow install-zsh-plugins install-starship install-yazi install-pre-stow
	cd "$(REPO)" && $(STOW) -D --target="$(DEST)" vim-minimal 2>/dev/null || true
	cd "$(REPO)" && $(STOW) --no-folding --target="$(DEST)" $(STOW_PACKAGES)
	$(MAKE) install-plug install-tpm
	@echo "Done. Stowed from $(REPO) into $(DEST)"

uninstall:
	cd "$(REPO)" && $(STOW) -D --target="$(DEST)" $(STOW_PACKAGES) 2>/dev/null || true
	cd "$(REPO)" && $(STOW) -D --target="$(DEST)" vim-minimal 2>/dev/null || true
	@rm -f "$(DEST)/.vim/autoload/plug.vim"
	@rm -f "$(DEST)/.p10k.zsh"
	@echo "Unstowed packages; removed vim-plug bootstrap and stale p10k path if present."

install-stow:
	@if ! command -v $(STOW) >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			brew list stow >/dev/null 2>&1 || brew install stow; \
		else \
			echo "GNU Stow not found. Install it (e.g. brew install stow) and retry."; \
			exit 1; \
		fi; \
	fi

install-pre-stow:
	@home="$(DEST)"; \
	for rel in \
		.aerospace.toml \
		bin/proj-picker \
		bin/tmux-open-in-vim \
		bin/tmux-resize-all \
		.config/kitty/kitty.conf \
		.config/kitty/catppuccin-mocha.conf \
		.config/nvim/init.lua \
		.config/nvim/lua/plugins.lua \
		.config/nvim/lua/setup.lua \
		.config/starship.toml \
		.config/yazi/yazi.toml \
		.tmux.conf \
		.zshrc \
		.vimrc \
		.vimrc_minimal \
		.ideavimrc \
		.vim/autocmds.vim \
		.vim/core.vim \
		.vim/functions.vim \
		.vim/mappings.vim \
		.vim/plugins.vim \
		.vim/reload.vim \
		.vim/plugin-config; do \
			f="$$home/$$rel"; \
			[ ! -L "$$f" ] || rm "$$f"; \
		done

# --- Vim / Neovim -------------------------------------------------------------

install-plug:
	@if [ ! -f "$(DEST)/.vim/autoload/plug.vim" ]; then \
		mkdir -p "$(DEST)/.vim/autoload"; \
		curl -fLo "$(DEST)/.vim/autoload/plug.vim" \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
	fi

# Tmux Plugin Manager (used by tmux/.tmux.conf @plugin lines)
install-tpm:
	@if [ ! -f "$(DEST)/.tmux/plugins/tpm/tpm" ]; then \
		if ! command -v git >/dev/null 2>&1; then \
			echo "install-tpm: git not found; install git and retry."; \
			exit 1; \
		fi; \
		mkdir -p "$(DEST)/.tmux/plugins"; \
		GIT_TERMINAL_PROMPT=0 git clone --depth 1 https://github.com/tmux-plugins/tpm \
			"$(DEST)/.tmux/plugins/tpm"; \
	fi

# Minimal Vimrc shares core/*.vim via symlinks inside vim-minimal/.vim/
vim-minimal: install-stow install-pre-stow install-plug
	cd "$(REPO)" && $(STOW) -D --target="$(DEST)" vim 2>/dev/null || true
	cd "$(REPO)" && $(STOW) --no-folding --target="$(DEST)" vim-minimal

vim-full: install-stow install-pre-stow install-plug
	cd "$(REPO)" && $(STOW) -D --target="$(DEST)" vim-minimal 2>/dev/null || true
	cd "$(REPO)" && $(STOW) --no-folding --target="$(DEST)" vim

# --- Zsh / CLI tooling -------------------------------------------------------

install-zsh-plugins:
	@if command -v brew >/dev/null 2>&1; then \
		missing=""; \
		for p in zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting; do \
			brew list "$$p" >/dev/null 2>&1 || missing="$$missing $$p"; \
		done; \
		if [ -n "$$missing" ]; then brew install $$missing; \
		else echo "install-zsh-plugins: already present"; fi; \
	else \
		echo "install-zsh-plugins: no brew in PATH (install those formulae yourself)"; \
	fi

install-starship:
	@if command -v brew >/dev/null 2>&1; then \
		brew list starship >/dev/null 2>&1 || brew install starship; \
	else \
		echo "install-starship: no brew in PATH"; \
	fi

install-yazi:
	@if command -v brew >/dev/null 2>&1; then \
		missing=""; \
		for p in yazi fd ripgrep; do brew list "$$p" >/dev/null 2>&1 || missing="$$missing $$p"; done; \
		if [ -n "$$missing" ]; then brew install $$missing; \
		else echo "install-yazi: brew formulae already present"; fi; \
	else \
		echo "install-yazi: no brew in PATH"; \
	fi
	@if [ ! -d "$(DEST)/.config/yazi/flavors/catppuccin-mocha.yazi" ]; then \
		tmp=$$(mktemp -d); \
		git clone --depth 1 https://github.com/yazi-rs/flavors.git "$$tmp/flavors" && \
		mkdir -p "$(DEST)/.config/yazi/flavors" && \
		cp -R "$$tmp/flavors/catppuccin-mocha.yazi" "$(DEST)/.config/yazi/flavors/" && \
		rm -rf "$$tmp"; \
	fi

# --- Karabiner ---------------------------------------------------------------

karabiner:
	@mkdir -p "$(DEST)/.config/karabiner"
	@if [ ! -d "$(REPO)/karabiner/node_modules" ]; then \
		cd "$(REPO)/karabiner" && npm install; \
	fi
	@cd "$(REPO)/karabiner" && env HOME="$(DEST)" npm run build
	@echo "Karabiner config written to $(DEST)/.config/karabiner/karabiner.json"

# --- ZMK subtrees -------------------------------------------------------------

zmk-remote:
	@git remote get-url zmk-config >/dev/null 2>&1 || git remote add zmk-config git@github.com:ilya-murzinov/zmk-config-totem-stable.git

zmk-add: zmk-remote
	@if [ -f "$(REPO)/zmk/config/totem.keymap" ]; then \
		echo "zmk-add: zmk/ already present; skip"; \
	else \
		echo "Fetching zmk-config..."; \
		git fetch zmk-config master; \
		git subtree add --prefix=zmk zmk-config master --squash; \
	fi

zmk-pull: zmk-remote
	git subtree pull --prefix=zmk zmk-config master --squash

zmk-push: zmk-remote
	git subtree push --prefix=zmk zmk-config master

zmk-force-push: zmk-remote
	@if [ "$(CONFIRM)" != yes ]; then \
		echo "refusing: set CONFIRM=yes to force-push zmk subtree"; exit 1; \
	fi
	git subtree split --prefix=zmk -b zmk-split-tmp
	git push zmk-config zmk-split-tmp:master --force
	git branch -D zmk-split-tmp

zmk-sync:
	python3 sync_keymap.py

zmk-piantor-remote:
	@git remote get-url zmk-piantor-config >/dev/null 2>&1 || git remote add zmk-piantor-config git@github.com:ilia-murzinov/zmk-config.git

zmk-piantor-add: zmk-piantor-remote
	@if [ -f "$(REPO)/zmk-piantor/config/piantor_pro_bt.keymap" ]; then \
		echo "zmk-piantor-add: zmk-piantor/ already present; skip"; \
	else \
		echo "Fetching zmk-piantor-config..."; \
		git fetch zmk-piantor-config main; \
		git subtree add --prefix=zmk-piantor zmk-piantor-config main --squash; \
	fi

zmk-piantor-pull: zmk-piantor-remote
	@git merge --abort >/dev/null 2>&1 || true
	@git rebase --abort >/dev/null 2>&1 || true
	@git cherry-pick --abort >/dev/null 2>&1 || true
	@STASHED=0; \
	if ! git diff --quiet || ! git diff --cached --quiet; then \
		echo "working tree dirty, stashing changes before subtree pull"; \
		git stash push -u -m "auto: zmk-piantor-pull" >/dev/null; \
		STASHED=1; \
	fi; \
	git fetch zmk-piantor-config main; \
	git subtree pull --prefix=zmk-piantor zmk-piantor-config main --squash || ( \
		echo "subtree pull conflicted, taking upstream version for zmk-piantor/"; \
		git checkout --theirs zmk-piantor; \
		git add zmk-piantor; \
		git commit --no-edit; \
	); \
	if [ $$STASHED -eq 1 ]; then \
		echo "local changes are stashed (git stash list). Reapply manually: git stash pop"; \
	fi

zmk-piantor-push: zmk-piantor-remote
	git subtree push --prefix=zmk-piantor zmk-piantor-config main

zmk-piantor-force-push: zmk-piantor-remote
	@if [ "$(CONFIRM)" != yes ]; then \
		echo "refusing: set CONFIRM=yes to force-push zmk-piantor subtree"; exit 1; \
	fi
	git subtree split --prefix=zmk-piantor -b zmk-piantor-split-tmp
	git push zmk-piantor-config zmk-piantor-split-tmp:main --force
	git branch -D zmk-piantor-split-tmp
