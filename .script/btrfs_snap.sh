#!/bin/bash

mount -t btrfs -o subvol=/ /dev/sda2 /mnt/btrfs
btrfs subvolume snapshot / /mnt/btrfs/snap-root/root-$(date +%d-%B-%y_%T)
btrfs subvolume snapshot /home /mnt/btrfs/snap-home/home-$(date +%d-%B-%y_%T)
umount /mnt/btrfs
exit 0
