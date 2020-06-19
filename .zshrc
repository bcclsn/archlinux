export ZSH=$HOME/.oh-my-zsh
export PATH=$HOME/bin:/usr/local/bin:$PATH
export LANG=it_IT.UTF-8
export EDITOR='vim'

HIST_STAMPS="mm/dd/yyyy"
ZSH_THEME="bcclsn-v2"
ENABLE_CORRECTION="true"
plugins=(sudo dirhistory web-search tmux vim-interaction zsh-syntax-highlighting) 

source $ZSH/oh-my-zsh.sh
source $HOME/.zsh/alias.zsh
source $HOME/.zsh/setopt.zsh

## Set tmux for all terminals
#    if [[ -z "$TMUX" ]]; then
#        ID="`tmux ls | grep -vm1 attached | cut -d: -f1`"
#    if [[ -z "$ID" ]]; then
#       tmux new-session
#    else
#       tmux attach-session -t "$ID"
#    fi
#    fi

##echo "inizio blocco info"
echo ""
echo "$fg[cyan] Last -Syu: $reset_color $(grep "pacman -Syu" /var/log/pacman.log | tail -n1 | cut -c 2- | cut -c -10)"
echo "$fg[cyan] Kernel:    $reset_color $(uname -r)"
#echo "$fg[cyan] HDD:      $reset_color $(df -h | grep "/dev/sda1" | cut -c 23- | cut -c -4)/$(df -h | grep "/dev/sda1" | cut -c 18- | cut -c -3)"
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
#echo "$fg[cyan] Last -Syu: $reset_color $(grep "pacman -Syu" /var/log/pacman.log | tail -n1 | cut -c 2- | cut -c -10)"
#echo "$fg[cyan] Kernel:    $reset_color $(uname -r)"
#echo ""
#echo "$fg[cyan] Welcome to Archlinux... GOD Mode $reset_color"
#echo ""
##echo "fine blocco info - utente root"
