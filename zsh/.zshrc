export PATH="/usr/local/bin:$PATH"
[[ -d "$HOME/bin" ]] && PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
[[ -d /opt/homebrew/bin ]] && PATH="/opt/homebrew/bin:$PATH"
export PATH

# --- Completion (Homebrew site-functions + zsh built-ins; no framework) ---
typeset -U fpath FPATH
if (( $+commands[brew] )); then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select

# --- History ---
HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history
[[ -d $HISTFILE:h ]] || mkdir -p "$HISTFILE:h"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# --- Shell behavior ---
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
WORDCHARS=${WORDCHARS/\/}

# --- Editor ---
if (( $+commands[nvim] )); then
  export EDITOR=nvim
  export VISUAL=nvim
fi

# --- SDKMAN, local overrides ---
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# --- zoxide (replaces cd) ---
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# --- yazi (cwd follows on quit: y + q; Q quits without cd) ---
if (( $+commands[yazi] )); then
  y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
  }
fi

# --- Vi line editing (Homebrew zsh-vi-mode, else plain vim mode) ---
function zvm_config() {
  ZVM_INIT_MODE=sourcing
  ZVM_LAZY_KEYBINDINGS=false
  ZVM_KEYTIMEOUT=0.25
  # yy / yw etc. also sync to macOS clipboard when pbcopy exists (see plugin zvm_clipboard_detect)
  ZVM_SYSTEM_CLIPBOARD_ENABLED=true
}

_zvm_file=
if (( $+commands[brew] )); then
  _zb="$(brew --prefix zsh-vi-mode 2>/dev/null)"
  [[ -n $_zb && -f $_zb/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]] \
    && _zvm_file=$_zb/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
fi

if [[ -n $_zvm_file ]]; then
  # zvm_after_init must be defined before sourcing so zvm calls it at end of source
  function zvm_after_init() {
    bindkey '^[[A' history-beginning-search-backward
    bindkey '^[[B' history-beginning-search-forward
  }
  source "$_zvm_file"
else
  bindkey -v
  KEYTIMEOUT=25
  bindkey '^[[A' history-beginning-search-backward
  bindkey '^[[B' history-beginning-search-forward
fi
unset _zb _zvm_file

# Starship must run once after vi-mode binds; do not rely on STARSHIP_SHELL (some terminals
# export it without running init → eval skipped → no PROMPT because starship is on PATH).
if (( $+commands[starship] )) && (( ! ${+functions[prompt_starship_precmd]} )); then
  eval "$(starship init zsh)"
fi

# fzf (after zsh-vi-mode)
source "$(brew --prefix fzf)/shell/key-bindings.zsh"
source "$(brew --prefix fzf)/shell/completion.zsh"

alias nv='nvim'
alias vn='nvim'
alias vm='nvim'
alias vim='nvim'

if ! (( $+commands[starship] )); then
  autoload -Uz vcs_info add-zsh-hook
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' unstagedstr '*'
  zstyle ':vcs_info:git:*' stagedstr '+'
  zstyle ':vcs_info:git:*' formats '(%b%m%u%c)'
  zstyle ':vcs_info:git:*' actionformats '(%b|%a%m%u%c)'
  _dotfiles_vcs_precmd() { vcs_info }
  add-zsh-hook precmd _dotfiles_vcs_precmd
  setopt PROMPT_SUBST
  PROMPT='%F{cyan}%2~%f %F{magenta}${vcs_info_msg_0_}%f%# '
fi

# --- Autosuggestions & syntax highlighting (highlighting must load last) ---
_brewp=
(( $+commands[brew] )) && _brewp="$(brew --prefix 2>/dev/null)"
[[ -n $_brewp && -r "$_brewp/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
  && source "$_brewp/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -n $_brewp && -r "$_brewp/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] \
  && source "$_brewp/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset _brewp

# Ctrl+P: projects / obsidian / dotfiles (depth 1); bind after highlighting
_proj_cd() {
  local selected
  selected=$({ find ~/projects ~/obsidian -mindepth 1 -maxdepth 1 -type d; echo ~/dotfiles; } 2>/dev/null | fzf)
  if [[ -n $selected ]]; then
    cd "$selected" || return
    zle reset-prompt
  fi
}
zle -N _proj_cd
if (( $+functions[zvm_bindkey] )); then
  zvm_bindkey viins '^p' _proj_cd
  zvm_bindkey vicmd '^p' _proj_cd
else
  bindkey -M viins '^p' _proj_cd
  bindkey -M vicmd '^p' _proj_cd
fi

# Ctrl+Y: run yazi cwd picker (same as typing `y` + Enter)
if (( $+functions[y] )); then
  _launch_yazi() {
    BUFFER=y
    zle accept-line
  }
  zle -N _launch_yazi
  if (( $+functions[zvm_bindkey] )); then
    zvm_bindkey viins '^y' _launch_yazi
    zvm_bindkey vicmd '^y' _launch_yazi
  else
    bindkey -M viins '^y' _launch_yazi
    bindkey -M vicmd '^y' _launch_yazi
  fi
fi

# Attach to first unattached tmux session
if [[ -z "$TMUX" ]]; then
  orphan=$(tmux list-sessions -F '#{?session_attached,,#{session_name}}' 2>/dev/null | head -1)
  [[ -n "$orphan" ]] && exec tmux attach -t "$orphan" -d
fi
