#!/bin/bash

# get current mac address and define matlab one #
curr_mac=$(ip link show wlp1s0 | grep "ether" | cut -c 16- | cut -c -17)
matl_mac="66:B7:7E:76:58:9E"

# spoofing mac address #
if (zenity --password --title "MAC Spoofing" | \
    (sudo -S ip link set dev wlp1s0 down & \
     sudo -S ip link set dev wlp1s0 address $matl_mac & \
     sudo -S ip link set dev wlp1s0 up)\
   ) ; then

    # start matlab in a tmux session #
    tmux new-session -d -s matlab 'matlab -desktop'
    sleep 20

    # restore previous address and exit #
    sudo -S ip link set dev wlp1s0 down & \
    sudo -S ip link set dev wlp1s0 address $curr_mac & \
    sudo -S ip link set dev wlp1s0 up & \

# get error #
else
    zenity --error --title "Error" \
                   --text "Password sbagliata!" \
                   --width=150 --height=80
fi

# clear sudo cache and exit #
sudo -k
exit 0

################################################
##                                bcclsn v2.4 ##
################################################
