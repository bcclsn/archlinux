#!/bin/bash

# IMPORTANTE
# Se stai leggendo questo messaggio
# e non hai aperto volontariamente il programma con un editor di testo
# devi uscire; quindi premere con il tasto destro del mouse sopra al file,
# cliccare proprietà, selezionare permessi ed abilitare CONSENTI L'ESECUZIONE DEL FILE.
# Altrimenti puoi aprire un terminale, dirigerti nella cartella che contiene il file "cd ~/Scrivania"
# e digitare "chmod +x nomefile"

echo "
#########################################################
#			ATTENZIONE!!!!!			#
#	   Questo script ha bisogno di software		#
#      supplemetari (yaourt,Paccache) per eseguire	#
#	        tutte le sue funzionalità.		#
#	   SCEGLIEDO DI UTILIZZARE QUESTO SCRIPT	#
#    ESULI IL SUO WRITER DA QUALSIASI RESPONSABILITÀ	#
#########################################################"


function install_pacman()
{
	read -p "Vuoi prima cercare l'applicazione [N\s]" sel
	if [[ $sel = @(n|N) ]]; then
		read -p "Digita il nome dell'applicazione da installare " software
		sudo pacman -S $software
	elif [[ $sel = @(s|S) ]]; then
		read -p "Digita il nome dell'applicazione da cercare " software
		pacman -Ss $software
		read -p "Digita il nome dell'applicazione da installare " software
		sudo pacman -S $software
	else
		install_pacman
	fi
	software=""
}

function install_yaourt()
{
	read -p "Digita il nome dell'applicazione da installare " software
	yaourt $software
	software=""
}

function agg_yaourt()
{
	echo "Aggiornamento S.O. con yaourt..."
	sudo yaourt -Syua
}

function agg_pacman()
{
	echo "Aggiornamento S.O. con pacman..."
	sudo pacman -Syu
}

function pacman_ott()
{
	echo "Ottimizzazione database pacman..."
	pacman-optimize
}

function cache_del_paccache()
{
	echo "Rimozione cache pacchetti pacman (Paccache)..."
	sudo paccache -rvk1
}

function cache_del()
{
	echo "Rimozione cache pacman..."
	sudo pacman -Sc
}

function cache_del_full()
{
	echo "Rimozione totale della cache pacman..."
	sudo pacman -Scc
}

function remove_orfan()
{
	echo "Rimozione pacchetti orfani"
	sudo pacman -Rs $(pacman -Qtdq)
}

function remove_soft_full()
{
	read -p "Vuoi prima cercare l'applicazione [S\n]" sel
	if [[ $sel = @(n|N) ]]; then
		read -p "Digita il nome dell'applicazione da rimuovere " software
		sudo pacman -Rs $software
	elif [[ $sel = @(s|S) ]]; then
		read -p "Digita il nome dell'applicazione da cercare " software
		pacman -Qs | grep -i local/$software
		software=""
		read -p "Digita il nome dell'applicazione da rimuovere " software
		sudo pacman -Rs $software
	else
		remove_soft_full
	fi
}

function remove_soft()
{
	read -p "Vuoi prima cercare l'applicazione [S\n]" sel
	if [[ $sel = @(n|N) ]]; then
		read -p "Digita il nome dell'applicazione da rimuovere " software
		sudo pacman -R $software
	elif [[ $sel = @(s|S) ]]; then
		read -p "Digita il nome dell'applicazione da cercare " software
		pacman -Qs | grep -i local/$software
		software=""
		read -p "Digita il nome dell'applicazione da rimuovere " software
		sudo pacman -R $software
	else
		remove_soft
	fi
}

declare -a options

options[${#options[*]}]="Installare software con Pacman";
options[${#options[*]}]="Installare software con Yaourt";
options[${#options[*]}]="Aggiornare il S.O. (pacman)";
options[${#options[*]}]="Aggiornare il S.O. (yaourt)";
options[${#options[*]}]="Ottimizzare database pacman";
options[${#options[*]}]="Rimuove cache pacchetti (mantiene solo la penultima versione (Paccache))";
options[${#options[*]}]="Rimuove cache pacchetti scaricati ed attualmente non installati";
options[${#options[*]}]="Rimuove cache pacchetti (Sconsigliata)";
options[${#options[*]}]="Rimuovere pacchetti orfani";
options[${#options[*]}]="Rimuovere Software con tutte le sue dipendenze";
options[${#options[*]}]="Rimuovere Software";
options[${#options[*]}]="Esci";
select opt in "${options[@]}"; do
case ${opt} in

${options[0]}) install_pacman;;
${options[1]}) install_yaourt;;
${options[2]}) agg_pacman;;
${options[3]}) agg_yaourt;;
${options[4]}) pacman_ott;;
${options[5]}) cache_del_paccache;;
${options[6]}) cache_del;;
${options[7]}) cache_del_full;;
${options[8]}) remove_orfan;;
${options[9]}) remove_soft_full;;
${options[10]}) remove_soft;;

(Esci) break; ;;
esac;
done


