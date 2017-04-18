#!/bin/bash

while [[ 1 -eq 1 ]]; do
for i in $(echo /home/bcclsn/Immagini/wallpaper/*.jpg); do
echo $i
gsettings set org.gnome.desktop.background picture-uri file:///${i}
sleep 60;
done
done
