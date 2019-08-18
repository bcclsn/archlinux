#!/bin/bash

# set the folder providing the wallpapers #
wallpaperdir='/home/bcclsn/Immagini/wallpaper'
files=($wallpaperdir/*)

# choose random wallpaper and set as desktop background #
randompic=`printf "%s\n" "${files[RANDOM % ${#files[@]}]}"`
gsettings set org.gnome.desktop.background picture-uri $randompic

# set the delay (2h = 7200s) #
sleep 7200

# start a new self-instance using the previous delay #
exec $0
exit 0 										# questo comando non verrà mai eseguito :P

################################################
##                                bcclsn v1.0 ##
################################################
