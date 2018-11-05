#!/bin/bash

# spoofing mac address #
sudo ip link set dev wlp1s0 down
sudo ip link set dev wlp1s0 address 66:B7:7E:76:58:9E
sudo ip link set dev wlp1s0 up

# start matlab and exit #
matlab -desktop
exit 0

################################################
##                                bcclsn v1.0 ##
################################################
