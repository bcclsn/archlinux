#!/bin/bash

# WARNING!!! IT'S ONLY AN ALPHA VERSION
#            SCRIPT NOT VERIFIED
#            USE IT AT YOUR RISK

# mount snapshot folder #
mount -t btrfs -o compress=lzo,subvol=/ /dev/sda2 /mnt/btrfs

# remove the snapshot #
cd /mnt/btrfs/snap-root
btrfs subvolume delete "$(ls -1 | head -n -2)"
cd /mnt/btrfs/snap-home
btrfs subvolume delete "$(ls -1 | head -n -2)"
cd ../..

# umount
umount /mnt/btrfs

exit 0

################################################
##                                bcclsn v1.0 ##
################################################