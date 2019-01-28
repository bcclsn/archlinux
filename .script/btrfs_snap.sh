#!/bin/bash

# mount snapshot folder #
mount -t btrfs -o compress=lzo,subvol=/ /dev/sda2 /mnt/btrfs

# get the snapshot #
btrfs subvolume snapshot / /mnt/btrfs/snap-root/root_$(date +%F_%H:%M)
btrfs subvolume snapshot /home /mnt/btrfs/snap-home/home_$(date +%F_%H:%M)

# umount
umount /mnt/btrfs

# update grub.cfg (grub-btrfs) and exit
grub-mkconfig -o /boot/grub/grub.cfg
exit 0

################################################
##                                bcclsn v1.2 ##
################################################
