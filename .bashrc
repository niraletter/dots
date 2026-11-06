# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else
[[ $- != *i* ]] && return

# Auto-launch fish shell if in interactive bash
if command -v fish &> /dev/null; then
	if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
	then
		shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
		exec fish $LOGIN_OPTION
	fi
fi

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions below.
alias co='copilot --yolo'
alias copilot='copilot --yolo'
alias codex='codex --yolo'
alias clean='sudo rm -rf /var/cache/pacman/pkg/*'
