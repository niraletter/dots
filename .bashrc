# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# alias for zed
alias zed='zeditor'

# alias for timer
#alias timer='~/.config/waybar/scripts/timer.sh'
#alias pomo='~/.config/waybar/scripts/timer.sh pomo'


# Go path
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:/usr/local/go/bin:$GOBIN"

# govm
. "$HOME/.local/share/../bin/env"
export PATH="$HOME/.govm/shim:$PATH"

export PATH=$PATH:~/.spicetify

# fzf Ctrl+F directory navigation
fzf_cd_widget() {
  # let the user select a directory
  local selected
  selected=$(fd --type d --hidden --follow --exclude ".git" . "$HOME" | fzf --height=40% --layout=reverse --border)
  if [[ -n "$selected" ]]; then
    # change directory in current shell
    builtin cd "$selected" || return
    # update the prompt immediately
     printf '\e[38;2;191;191;191m'
    pwd
  fi
}

# Bind Ctrl+F using readline
bind -x '"\C-f": fzf_cd_widget'
