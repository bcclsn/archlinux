#!/bin/bash

# WARNING!!! IT'S ONLY AN BETA VERSION
#            USE IT AT YOUR RISK

# mount snapshot folder #
mount -t btrfs -o compress=lzo,subvol=/ /dev/sda2 /mnt/btrfs

# remove the snapshot #
cd /mnt/btrfs/snap-root
btrfs subvolume delete "$(ls -1 | head -n -2)"
cd /mnt/btrfs/snap-home
btrfs subvolume delete "$(ls -1 | head -n -2)"
cd ~/

# update grup.cfg (grub-btrfs) #
# enable if you use the script standalone
#grub-mkconfig -o /boot/grub/grub.cfg

# umount and exit
umount /mnt/btrfs
exit 0

################################################
##                                bcclsn v1.1 ##
################################################
