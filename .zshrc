# Path to your oh-my-zsh installation.
    export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
  ZSH_THEME="bcclsn-v2"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
    ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
    HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(sudo dirhistory web-search zsh-syntax-highlighting)

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh
source $HOME/.zsh/alias.zsh
source $HOME/.zsh/setopt.zsh

# You may need to manually set your language environment
    export LANG=it_IT.UTF-8

# Preferred editor for local and remote sessions
    if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='nano'
    else
        export EDITOR='nano'
    fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases  
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

## Set tmux for all terminals
#    if [[ -z "$TMUX" ]]; then
#        ID="`tmux ls | grep -vm1 attached | cut -d: -f1`"
#    if [[ -z "$ID" ]]; then
#       tmux new-session
#    else
#       tmux attach-session -t "$ID"
#    fi
#    fi

# create a directory, then change into it

##echo "inizio blocco info"
echo ""                                                          
echo "$fg[cyan] Last -Syu: $reset_color $(grep "pacman -S -y -u" /var/log/pacman.log | tail -n1 | cut -c 2- | cut -c-16)"            
echo "$fg[cyan] Kernel:    $reset_color $(uname -r)"  
#echo "$fg[cyan] HDD:      $reset_color $(df -h | grep "/dev/sda1" | cut -c 23- | cut -c-4)/$(df -h | grep "/dev/sda1" | cut -c 18- | cut -c-3)"              
#echo "$fg[cyan] RAM:       $reset_color $(free -m | grep "Mem:" | cut -c 28- | cut -c -4)/$(free -m | grep "Mem:" | cut -c 16- | cut -c -4)"
#echo "$fg[cyan] Battery:   $reset_color $(cat /sys/class/power_supply/BAT1/capacity)%"                      
#echo "$fg[cyan] CPU Temp:  $reset_color $(cut -c 1,2 /sys/class/thermal/thermal_zone0/temp)°C"        
echo ""
#echo "$fg[cyan] Welcome to ArchLinux: Free as in Freedom, not as in Beer $reset_color"                                   
#echo " $fg[black]███$reset_color$fg[red]███$reset_color$fg[green]███$reset_color$fg[yellow]███$reset_color$fg[blue]███$reset_color$fg[magenta]███$reset_color$fg[cyan]███$reset_color$fg[white]███$reset_color"
#echo ""
#echo ""
##echo "fine blocco info"


##echo "inizio blocco info - utente root"
#echo ""
#echo "$fg[cyan] Last -Syu: $reset_color $(grep "pacman -Syu" /var/log/pacman.log | tail -n1 | cut -c 2- | cut -c-16)"            
#echo "$fg[cyan] Kernel:    $reset_color $(uname -r)"  
#echo ""
#echo "$fg[cyan] Welcome to Archlinux... GOD Mode $reset_color"                                   
#echo ""
##echo "fine blocco info - utente root"

