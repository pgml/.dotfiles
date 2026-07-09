export PATH=$HOME/.bin/:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:/usr/local/bin:/usr/local/go/bin:$HOME/go/bin:/usr/bin:$HOME/.luarocks/bin

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

export ZSH="$HOME/.oh-my-zsh"
#export ZSH="$HOME/.zsh"

if [[ -n $ZMX_SESSION ]]; then
  export PS1="[$ZMX_SESSION] ${PS1}"
fi

export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

if [[ -n $ZMX_SESSION ]]; then
	export PS1="[$ZMX_SESSION] ${PS1}"
fi

alias l="ls"
alias ll="ls -l"
alias la="ll -a"
alias krunner="XDG_MENU_PREFIX=niri- krunner"
alias anyrun="XDG_MENU_PREFIX=niri- anyrun"
alias love="SDL_VIDEODRIVER=wayland love"
alias c="z"

ZSH_THEME=pgml
plugins=(git)

source $ZSH/oh-my-zsh.sh
source $HOME/.zsh/utils
#source $ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh
#source $ZSH/zsh-history-substring-search/zsh-history-substring-search.zsh
#source $ZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source $ZSH/utils

#bindkey '^[[A' history-substring-search-up
#bindkey '^[[B' history-substring-search-down

# Enable colors and prompt substitution
#autoload -U colors && colors
#setopt PROMPT_SUBST
#source $ZSH/pgml.zsh-theme


alias vim=nvim

ulimit -n 65535

# pnpm
export PNPM_HOME="/home/r/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

eval "$(zoxide init zsh)"
