# Kitana managed Zsh entrypoint

export PATH="$HOME/.local/bin:$HOME/.local/share/kitana/bin:$PATH"

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=32768
SAVEHIST="$HISTSIZE"
setopt append_history
setopt hist_ignore_dups
setopt share_history

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export SUDO_EDITOR="${SUDO_EDITOR:-$EDITOR}"
export TERMINAL="${TERMINAL:-ghostty}"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

alias lsa='ls -a'
alias lta='lt -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias ls='eza -lha --group-directories-first --icons=auto'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias n='nvim'
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"
alias fix_fkeys='echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode'

zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf " -> " && pwd || echo "Error: Directory not found"
  fi
}
alias cd='zd'

open() {
  xdg-open "$@" >/dev/null 2>&1
}

fastfetch() {
  clear
  printf '\e[1A\e[2K'
  command fastfetch "$@"
}

compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress='tar -xzf'

refresh-xcompose() {
  pkill fcitx5
  setsid fcitx5 &>/dev/null &
}

if command -v starship >/dev/null 2>&1 && [ "${TERM:-}" != "dumb" ]; then
  eval "$(starship init zsh)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
fi

if [ -f /usr/share/fzf/completion.zsh ]; then
  source /usr/share/fzf/completion.zsh
fi

for file in "$HOME/.config/zsh/custom/"*.zsh; do
  [ -e "$file" ] && source "$file"
done
