# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

#  zed
alias zed='zeditor'

# trash-cli
alias rm='trash'

# Go path
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:/usr/local/go/bin:$GOBIN"

# govm
# export PATH="$HOME/.govm/shim:$PATH"

# fzf Ctrl+F directory navigation
fzf_cd_widget() {
  local selected
  selected=$(fd --type d --hidden --follow --exclude ".git" . "$HOME" | fzf --height=40% --layout=reverse --border)
  if [[ -n "$selected" ]]; then
    builtin cd "$selected" || return
     printf '\e[38;2;191;191;191m'
    pwd
  fi
}

# Bind Ctrl+F using readline
bind -x '"\C-f": fzf_cd_widget'
