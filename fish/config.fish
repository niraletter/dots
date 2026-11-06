if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Custom aliases (ported from ~/.bashrc)
alias install 'sudo pacman -S'
alias cs 'opencode service stop'
alias remove 'sudo rm -rf'
alias reboot 'sudo reboot --no-wall'
alias shutdown 'sudo shutdown --no-wall'
alias co 'copilot --yolo'
alias copilot 'copilot --yolo'
alias codex 'codex --yolo'
alias clean 'sudo rm -rf /var/cache/pacman/pkg/*'



# Flutter / Android SDK (lightweight setup)
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
set -gx ANDROID_SDK_ROOT $HOME/Android/Sdk
set -gx ANDROID_HOME $ANDROID_SDK_ROOT
set -gx PATH $JAVA_HOME/bin $ANDROID_SDK_ROOT/cmdline-tools/latest/bin $ANDROID_SDK_ROOT/platform-tools $ANDROID_SDK_ROOT/emulator $HOME/.local/share/mise/installs/flutter/latest/bin $PATH
if test -d $HOME/.local/share/mise/shims
    set -gx PATH $HOME/.local/share/mise/shims $PATH
end
