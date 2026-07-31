#source $ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH/zsh-history-substring-search/zsh-history-substring-search.zsh

# Enable colors and prompt substitution
autoload -U colors && colors
setopt PROMPT_SUBST

# History configuration for proper persistence across sessions
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS

# Initialize zsh completion system
autoload -U compinit && compinit -d "$HOME/.zsh/.zcompdump"

# Utilities register custom completions, so load them after compinit defines compdef.
source $ZSH/utils.zsh

# Docker's package-managed completion can change without compinit invalidating
# its cached registry, so ensure the command is registered on every startup.
autoload -Uz _docker && compdef _docker docker

# Completion settings with visual menu
setopt AUTO_MENU
setopt MENU_COMPLETE
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Styling for completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
export LS_COLORS="di=34:*.c=32:*.h=33"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}%d%f'

if [[ -n $ZMX_SESSION ]]; then
  export PS1="[$ZMX_SESSION] ${PS1}"
fi

source $ZSH/pgml.zsh-theme
