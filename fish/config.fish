if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Custom aliases (ported from ~/.bashrc)
alias install 'sudo pacman -S'
alias cs 'opencode service stop'
alias remove 'sudo rm -rf'
alias reboot '/usr/bin/reboot --no-wall'
alias shutdown '/usr/bin/shutdown --no-wall'
alias co 'copilot --yolo'
alias copilot 'copilot --yolo'
alias codex 'codex --yolo'
alias clean 'sudo rm -rf /var/cache/pacman/pkg/*'
alias zed 'zeditor'
alias a 'omarchy-agent --inline'
alias c 'opencode --auto'
alias cy 'codex --approve-for-me'
alias d 'docker'
alias r 'rails'
alias t 'tmux attach || tmux new -s Work'
alias h 'herdr'
alias ic 'tdl c'
alias ix 'tdl cx'
alias icx 'tdl c cx'
alias mup 'MISE_MINIMUM_RELEASE_AGE=0 mise up'

# Git
alias g 'git'
alias gcm 'git commit -m'
alias gcam 'git commit -a -m'
alias gcad 'git commit -a --amend'

# File system
if type -q eza
    alias ls 'eza -lh --group-directories-first --icons=auto'
    alias lsa 'ls -a'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias lta 'lt -a'
end

if test "$TERM" = "xterm-kitty"
    alias ff "fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
else
    alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
end
alias eff '$EDITOR (ff)'

function sff
    if test (count $argv) -eq 0
        echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
        return 1
    end
    set -l file (find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | fzf)
    and test -n "$file"
    and scp "$file" "$argv[1]"
end

if type -q zoxide
    alias cd 'zd'
    function zd
        if test (count $argv) -eq 0
            builtin cd ~; or return
        else if test -d "$argv[1]"
            builtin cd "$argv[1]"; or return
        else
            if not z $argv
                echo "Error: Directory not found"
                return 1
            end
            printf "\U000F17A9 "
            pwd
        end
    end
end

function open
    xdg-open $argv >/dev/null 2>&1 &
end
# Flutter / Android SDK (lightweight setup)
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
set -gx ANDROID_SDK_ROOT $HOME/Android/Sdk
set -gx ANDROID_HOME $ANDROID_SDK_ROOT
set -gx PATH $JAVA_HOME/bin $ANDROID_SDK_ROOT/cmdline-tools/latest/bin $ANDROID_SDK_ROOT/platform-tools $ANDROID_SDK_ROOT/emulator $HOME/.local/share/mise/installs/flutter/latest/bin $PATH
if test -d $HOME/.local/share/mise/shims
    set -gx PATH $HOME/.local/share/mise/shims $PATH
end
