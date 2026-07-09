if [[ -z $ZSH_THEME_CLOUD_PREFIX ]]; then
    ZSH_THEME_CLOUD_PREFIX='☁'
fi

# Git prompt function (replacement for oh-my-zsh)
function git_prompt_info() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
    
    if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
        echo "%{$fg[green]%}(%{$fg[yellow]%}$branch%{$fg[green]%})%{$reset_color%}"
    else
        echo "%{$fg[green]%}(%{$fg[yellow]%}$branch%{$fg[green]%}) %{$fg[yellow]%}⚡%{$reset_color%}"
    fi
}

PROMPT='%{$fg_bold[white]%}$ZSH_THEME_CLOUD_PREFIX %{$fg_bold[green]%} %{$fg[green]%}%c %{$fg_bold[cyan]%}$(git_prompt_info)%{$fg_bold[cyan]%}› %{$reset_color%}'

RPROMPT='%{$fg[blue]%}%~%{$reset_color%}'
