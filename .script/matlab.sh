#!/bin/bash

# get current mac address (random) and define matlab address #
curr_mac=$(ip link show wlp1s0 | grep "ether" | cut -c 16- | cut -c -17)
matl_mac="66:B7:7E:76:58:9E"

# spoofing mac address #
sudo -S ip link set dev wlp1s0 down
sudo -S ip link set dev wlp1s0 address $matl_mac
sudo -S ip link set dev wlp1s0 up

# start matlab #
matlab -desktop

# restore previous address and exit #
sudo -S ip link set dev wlp1s0 down
sudo -S ip link set dev wlp1s0 address $curr_mac
sudo -S ip link set dev wlp1s0 up
exit 0

################################################
##                                bcclsn v2.0 ##
################################################
