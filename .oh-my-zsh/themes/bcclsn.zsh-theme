## bcclsn.zsh-theme 
## v2.0

local ret_status="${reset_status} %{$fg_bold[green]%}• %{$fg_bold[yellow]%}• %{$fg_bold[red]%}•   %{$reset_color%}"

PROMPT='${ret_status}%{$fg_bold[green]%}%p%{$fg[cyan]%}%c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} %{$reset_color%}'
RPROMPT='%{$fg[white]%}(%*)%{$reset_color%}'

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX=" (%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) %{$fg[green]%}✓%{$reset_color%}"
