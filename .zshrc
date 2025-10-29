export PATH=$HOME/.bin/:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:/usr/local/bin:/usr/local/go/bin:/usr/bin/:$DOTNET_ROOT:$DOTNET_ROOT/tools

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/
export DOTNET_ROOT=$HOME/.dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export OMNISHARP_USE_GLOBAL_MONO=never

# stuff for niri
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_DIRS=/usr/share:/usr/local/share:$HOME/.local/share:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share
export QT_QPA_PLATFORM=wayland
export XDG_CURRENT_DESKTOP=wlroots
export KDE_FULL_SESSION=true
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export XDG_MENU_PREFIX=plasma-

export ZSH="$HOME/.oh-my-zsh"

export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
export GPG_TTY=$(tty)

alias krunner="XDG_MENU_PREFIX=niri- krunner"
alias anyrun="XDG_MENU_PREFIX=niri- anyrun"
alias love="SDL_VIDEODRIVER=wayland love"

ZSH_THEME="kennethreitz"
plugins=(git)

source $ZSH/oh-my-zsh.sh

alias vim=nvim
alias cd2='cd /home2/pgml/'
alias cd3='cd /home3/'

ulimit -n 65535

export PATH=$PATH:/home/pgml/.spicetify
