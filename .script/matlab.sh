#!/bin/bash

# get current mac address and define matlab one #
curr_mac=$(ip link show wlp1s0 | grep "ether" | cut -c 16- | cut -c -17)
matl_mac="66:B7:7E:76:58:9E"

# spoofing mac address #
sudo ip link set dev wlp1s0 down
sudo ip link set dev wlp1s0 address $matl_mac
sudo ip link set dev wlp1s0 up

# start matlab in a tmux session #
tmux new-session -d -s matlab 'matlab -desktop'
sleep 20

# restore previous address #
sudo ip link set dev wlp1s0 down
sudo ip link set dev wlp1s0 address $curr_mac
sudo ip link set dev wlp1s0 up

# clear sudo cache and exit #
sudo -k
exit 0

################################################
##                              bcclsn v2.1.2 ##
################################################