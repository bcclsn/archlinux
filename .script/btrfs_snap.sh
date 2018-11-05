#!/bin/bash

# mount snapshot folder #
mount -t btrfs -o compress=lzo,subvol=/ /dev/sda2 /mnt/btrfs

# get the snapshot #
btrfs subvolume snapshot / /mnt/btrfs/snap-root/root--$(date +%b.%d.%y--%H:%M)
#btrfs subvolume snapshot /home /mnt/btrfs/snap-home/home--$(date +%b.%d.%y--%H:%M)

# umount and exit
umount /mnt/btrfs
exit 0

################################################
##                                bcclsn v1.0 ##
################################################
