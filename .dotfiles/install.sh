#!/bin/bash

USER="bcclsn"

echo "Copying Dotfiles..."

cd /etc
sudo rm libinput-gestures.conf && sudo cp /home/$USER/.dotfiles/config/libinput-gestures.conf libinput-gestures.conf

sudo chattr -i resolv.conf 
sudo rm resolv.conf && sudo cp /home/$USER/.dotfiles/config/resolv.conf resolv.conf
sudo chattr +i resolv.conf

sudo rm fstab && sudo cp /home/$USER/.dotfiles/config/fstab fstab
sudo rm hosts && sudo cp /home/$USER/.dotfiles/config/hosts hosts
 
cd /etc/default
sudo rm grub && sudo cp /home/$USER/.dotfiles/config/grub grub
 
cd /etc/dnscrypt-proxy
sudo rm dnscrypt-proxy.toml && sudo cp /home/$USER/.dotfiles/config/dnscrypt-proxy.toml dnscrypt-proxy.toml 
 
cd /etc/systemd/network
sudo rm 00-default.link && sudo cp /home/$USER/.dotfiles/config/00-default.link 00-default.link 
 
sleep 5
echo "Done"
 
echo "Generating grub configuration file..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Linking Dotfiles..."
mkdir -p /home/$USER/.config/systemd/user/ && cd $_
rm backup.service backup.timer
ln -s /home/$USER/.dotfiles/systemd/backup.service /home/$USER/.config/systemd/user/backup.service
ln -s /home/$USER/.dotfiles/systemd/backup.timer /home/$USER/.config/systemd/user/backup.timer

echo "Copying Dotfiles..."
cd /etc/systemd/system
rm btrfs_snap.service btrfs_snap.timer
cp /home/$USER/.dotfiles/systemd/btrfs_snap.service btrfs_snap.service
cp /home/$USER/.dotfiles/systemd/btrfs_snap.timer btrfs_snap.timer

sleep 5
cd /home/$USER
echo "Done"

echo "Reloading deamons..."
systemctl daemon-reload && systemctl --user daemon-reload
sleep 5

echo "Enabling Timer 'backup'..."
systemctl --user enable backup.timer 
sleep 5
 
echo "Enabling Timer 'btrfs_snap'..."
systemctl enable btrfs_snap.timer
sleep 5

echo "Done"

################################################
##                                bcclsn v1.3 ##
################################################
