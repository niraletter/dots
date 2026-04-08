#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc


# PATH and OMARCHY variables for Niri session
export OMARCHY_PATH="$HOME/.local/share/omarchy"
export PATH="$OMARCHY_PATH/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"
