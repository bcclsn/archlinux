#!/bin/bash

mount -t btrfs -o subvol=/ /dev/sda2 /mnt/btrfs
btrfs subvolume snapshot / /mnt/btrfs/snap-root/root-$(date +%d.%m.%y--%H:%M)
#btrfs subvolume snapshot /home /mnt/btrfs/snap-home/home-$(date +%d.%m.%y--%H:%M)
umount /mnt/btrfs
exit 0
