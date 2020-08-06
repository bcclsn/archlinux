#!/bin/bash

USER="bcclsn"

echo "Linking Dotfiles..."

cd /home/$USER/.local/share/applications 

rm wallpaper.desktop freecad.desktop matlab.desktop ChibiStudio.desktop

ln -s /home/$USER/.desktop/wallpaper.desktop wallpaper.desktop
ln -s /home/$USER/.desktop/freecad.desktop freecad.desktop
ln -s /home/$USER/.desktop/matlab.desktop matlab.desktop
ln -s /home/$USER/.desktop/ChibiStudio.desktop ChibiStudio.desktop

sleep 5
echo "Done"

################################################
##                                bcclsn v1.0 ##
################################################
