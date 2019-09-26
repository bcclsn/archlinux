#!/bin/bash

# get current mac address and define vivado one #
curr_mac=$(ip link show wlp1s0 | grep "ether" | cut -c 16- | cut -c -17)
matl_mac="62:46:3C:E9:D7:E3"

# spoofing mac address #
sudo ip link set dev wlp1s0 down
sudo ip link set dev wlp1s0 address $matl_mac
sudo ip link set dev wlp1s0 up

# start vivado in a tmux session #
tmux new-session -d -s sh /usr/src/Xilinx/Vivado/2019.1/bin/vivado 'vivado'
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
