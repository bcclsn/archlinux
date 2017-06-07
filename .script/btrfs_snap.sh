#!/bin/bash

mount -t btrfs -o subvol=/ /dev/sda2 /mnt/btrfs
btrfs subvolume snapshot / /mnt/btrfs/snap-root/root-$(date +%H:%M-%d-%m-%y)
#btrfs subvolume snapshot /home /mnt/btrfs/snap-home/home-$(date +%H:%M-%d-%m-%y)
umount /mnt/btrfs
exit 0
