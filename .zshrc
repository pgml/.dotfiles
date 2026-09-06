export PATH=$HOME/.bin/:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:/usr/local/bin:/usr/local/go/bin:$HOME/go/bin:/usr/bin:$HOME/.luarocks/bin:$HOME/.cargo/bin/

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/

# stuff for niri
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_DIRS=/usr/share:/usr/local/share:$HOME/.local/share:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share
export XDG_CURRENT_DESKTOP=wlroots
export KDE_FULL_SESSION=true
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export XDG_MENU_PREFIX=plasma-

export ZSH="$HOME/.zsh"
source $ZSH/fancystuff.zsh

export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

alias krunner="XDG_MENU_PREFIX=niri- krunner"
alias love="SDL_VIDEODRIVER=wayland love"

alias ..="cd .."
alias ls="ls --color"
alias l="ls"
alias ll="l -l"
alias la="ll -a"
alias c="z"
alias cd="z"

alias vim=nvim

ulimit -n 65535

eval "$(zoxide init zsh)"
