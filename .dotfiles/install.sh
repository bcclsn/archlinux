#!/bin/bash

USER="bcclsn"

echo "Copying Dotfiles..."

cd /etc
rm libinput-gestures.conf && cp /home/$USER/.dotfiles/config/libinput-gestures.conf libinput-gestures.conf

chattr -i resolv.conf 
rm resolv.conf && cp /home/$USER/.dotfiles/config/resolv.conf resolv.conf
chattr +i resolv.conf

rm fstab && cp /home/$USER/.dotfiles/config/fstab fstab
rm hosts && cp /home/$USER/.dotfiles/config/hosts hosts

cd /etc/default
rm grub && cp /home/$USER/.dotfiles/config/grub grub

cd /etc/dnscrypt-proxy
rm dnscrypt-proxy.toml && cp /home/$USER/.dotfiles/config/dnscrypt-proxy.toml dnscrypt-proxy.toml 

cd /etc/systemd/network
rm 00-default.link && cp /home/$USER/.dotfiles/config/00-default.link 00-default.link 

cd /etc/systemd/system
rm backup.service backup.timer btrfs_snap.service btrfs_snap.timer
ln -s /home/$USER/.dotfiles/systemd/backup.service backup.service
ln -s /home/$USER/.dotfiles/systemd/backup.timer backup.timer
ln -s /home/$USER/.dotfiles/systemd/btrfs_snap.service btrfs_snap.service
ln -s /home/$USER/.dotfiles/systemd/btrfs_snap.timer btrfs_snap.timer

sleep 5
echo "Done"

echo "Reloading deamons..."
systemctl daemon-reload
sleep 5

echo "Enabling Timer 'backup'..."
systemctl enable backup.timer 
sleep 5
 
echo "Enabling Timer 'btrfs_snap'..."
systemctl enable btrfs_snap.timer
sleep 5

echo "Generating grub configuration file..."
grub-mkconfig -o /boot/grub/grub.cfg
sleep 5

################################################
##                                bcclsn v1.0 ##
################################################
