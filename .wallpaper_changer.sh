#!/bin/bash

wallpaperdir='/home/bcclsn/Immagini/wallpaper/'  							#impostare la cartella con gli sfondi desktop
files=($wallpaperdir/*)
randompic=`printf "%s\n" "${files[RANDOM % ${#files[@]}]}"`
gsettings set org.gnome.desktop.background picture-uri $randompic
#echo $randompic
sleep 5 												#impostare il delay per il cambio sfondo
exec $0 												#Avvia una nuova istanza di se stesso impostato sul delay
exit 0 													#Questo comando non verrà mai eseguito :P


#Se vuoi provarlo via terminale, commenta la riga gsettings e togli il commento a echo $randompic
