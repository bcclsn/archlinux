#!/bin/bash

#############################################################################################################

#aur-update v4.6-2
#script di aggiornamento pacchetti installati da AUR, by rebellion
#da lanciare tramite terminale per visualizzare messaggi di dialogo con lo script
#a es.: gnome-terminal --geometry 75x25 --hide-menubar --title=\"AUR update\" -e \'sh -c \"sh /home/$USER/aur-update\"\'
#opzione 'aur-update -p' per inserire il nome pacchetto da aggiornare
#opzione 'aur-update -p $nomepacchetto' per aggiornare nomepacchetto in automatico
#gli aggiornamenti sono organizzati in ~/.cache/AUR/$nomepacchetto dove sono presenti PKGBUILD, pkg compilato
#e lo snapshot scaricato .tar.gz

#############################################################################################################

controllo_dipendenze () {
   check_dip_aur="ok" ; a="\"Depends\"" ; aa="\",\""
   dipendenze=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=$package_name")
   make_dip=${dipendenze##*MakeDepends} ; if [ "$make_dip" = "$dipendenze" ] ; then make_dip="nessuna" ; else make_dip=${make_dip%%]*} ; make_dip=${make_dip:4} ; make_dip=${make_dip:0: -1} ; make_dip=${make_dip//$aa/ } ; fi
   main_dip=${dipendenze##*$a} ; if [ "$main_dip" = "$dipendenze" ] ; then main_dip="nessuna" ; else main_dip=${main_dip%%]*} ; main_dip=${main_dip:3} ; main_dip=${main_dip:0: -1} ; main_dip=${main_dip//$aa/ } ; fi
   opt_dip=${dipendenze##*OptDepends} ; if [ "$opt_dip" = "$dipendenze" ] ; then opt_dip="nessuna" ; else opt_dip=${opt_dip%%]*} ; opt_dip=${opt_dip:4} ; opt_dip=${opt_dip:0: -1} ; opt_dip=${opt_dip//$aa/ } ; fi
   echo "DIPENDENZE:"
   if [ "$main_dip" != "nessuna" ] ; then
      numero_dipendenze=$(($(grep -o " " <<<"$main_dip" | wc -l)+1))
      for ((ii=1;ii<=$numero_dipendenze;ii++)) ; do dip=$(echo $main_dip | awk -v xx=$ii '{print$xx}') ; dip=${dip%%>*} ; dip=${dip%%<*} ; dip=${dip%%=*} ; if pacman -Q | grep -w "$dip" 1>/dev/null ; then dips=$dip"-----> ${LIGHT_GREEN}installata${NC}" ; else dips=$dip"-----> ${LIGHT_RED}non installata${NC}" ; fi
         if pacman -Si "$dip" &>/dev/null ; then dips=$dips"(community)" ; else dips=$dips"(AUR)" ; check_dip_aur="no" ; fi
         echo -e $dips
      done
   else echo "NESSUNA dipendenza richiesta."
   fi
   echo -e "\nDIPENDENZE OPZIONALI:"
   if [ "$opt_dip" != "nessuna" ] ; then
      numero_dipendenze=$(($(grep -o " " <<<"$opt_dip" | wc -l)+1))
      for ((ii=1;ii<=$numero_dipendenze;ii++)) ; do dip=$(echo $opt_dip | awk -v xx=$ii '{print$xx}') ; dip=${dip%%>*} ; dip=${dip%%<*} ; dip=${dip%%=*} ; if pacman -Q | grep -w "$dip" 1>/dev/null ; then dips=$dip"-----> ${LIGHT_GREEN}installata${NC}" ; else dips=$dip"-----> ${LIGHT_RED}non installata${NC}" ; fi
         if pacman -Si "$dip" &>/dev/null ; then dips=$dips"(community)" ; else dips=$dips"(AUR)" ; fi
         echo -e $dips
      done
   else echo "NESSUNA dipendenza opzionale richiesta."
   fi
   echo -e "\nDIPENDENZE PER LA COMPILAZIONE (MAKE):"
   if [ "$make_dip" != "nessuna" ] ; then
      numero_dipendenze=$(($(grep -o " " <<<"$make_dip" | wc -l)+1))
      for ((ii=1;ii<=$numero_dipendenze;ii++)) ; do dip=$(echo $make_dip | awk -v xx=$ii '{print$xx}') ; dip=${dip%%>*} ; dip=${dip%%<*} ; dip=${dip%%=*} ; if pacman -Q | grep -w "$dip" 1>/dev/null ; then dips=$dip"-----> ${LIGHT_GREEN}installata${NC}" ; else dips=$dip"-----> ${LIGHT_RED}non installata${NC}" ; fi
         if pacman -Si "$dip" &>/dev/null ; then dips=$dips"(community)" ; else dips=$dips"(AUR)" ; check_dip_aur="no" ; fi
         echo -e $dips
      done
   else echo "NESSUNA dipendenza per la compilazione richiesta."
   fi
   pkg="n"
   if [ -f "$package_dir/$package_name/PKGBUILD" ] ; then
      echo ; read -sp "Vuoi consultare il PKGBUILD in locale di $package_name prima di aggiornare? [s/n]" pkg
      if [ "$pkg" = "s" ] ; then clear ; echo -e "${LIGHT_WHITE}$package_dir/$package_name/PKGBUILD\n${NC}" ; cat $package_dir/$package_name/PKGBUILD ; echo ; read -sp "[Premi invio per continuare]" ; fi
   else
      echo ; echo "PKGBUILD in $package_dir/$package_name assente." ; read -s -p "[Premi invio per continuare]"
   fi
}

updating () {
      risultato=""
      for ((i=1;i<=$numero;i++)) ; do
         clear
         echo -n "Controllo connessione internet..."
         if ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null ; then
            echo "Connessione ok"
            package_name=$(echo $update | awk -v x=$i '{print$x}')
            echo "Installazione $package_name:"
            package_name_tar=$package_name".tar.gz" ; echo -n "ricerca $package_name_tar..."
            package_dir_del="/home/$USER/.cache/$package_name"
            package_dir="/home/$USER/.cache/AUR" ; [[ -d "$package_dir" ]] || mkdir /home/$USER/.cache/AUR
            package_path="/home/$USER/.cache/AUR/$package_name_tar" ; package_path_old=$package_path".old"
            package_dir_name="/home/$USER/.cache/AUR/$package_name"
            package_dir_name_old=$package_dir_name"_old"
            echo "fatto." ; echo -n "Ricerca versioni..."
            versione_new=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=$package_name" | grep "Version") ; outofdate=$(echo $versione_new | grep "OutOfDate\":null") ; [[ "$outofdate" = "" ]] && outofdate="(OutOfDate)" || outofdate=""
            versione_new=${versione_new//,/ } ; versione_new=$(echo $versione_new | awk '{print$8}') ; versione_new=${versione_new:11} ; versione_new=${versione_new:0: -1}$outofdate
            versione_old=$(pacman -Qi $package_name | grep "Versione" | awk '{print$3}')
            echo "fatto." ; echo -e "Versione installata: $versione_old\nVersione da installare: $versione_new"
            echo -e "\nControllo dipendenze del pacchetto $package_name:\n"
            controllo_dipendenze
            if [ "$check_dip_aur" = "ok" ] && dialog --title "pacchetto $package_name" --backtitle "Aggiornamento AUR" --yesno "Verranno installate eventuali dipendenze mancanti presenti in community. Confermi l'aggiornamento?" 7 60 ; then clear
               [[ -d "$package_dir_name" ]] && mv $package_dir_name $package_dir_name_old
               echo -e "Aggiornamento "$package_name" in corso, non spengere il pc o la connessione.\nbackup "$package_dir_del"---> fatto\nbackup "$package_name_tar"---> fatto"
               if wget -P $package_dir https://aur.archlinux.org/cgit/aur.git/snapshot/$package_name_tar ; then
                  tar -xvzf $package_dir/$package_name_tar -C $package_dir
                  read -p "Vuoi consultare il PKGBUILD scaricato? [s/n]" pkg
                  case $pkg in
                     "s")
                        [[ -e "/usr/bin/nano" ]] && gnome-terminal --geometry 75x40 --hide-menubar --title "PKGBUILD" -e 'sh -c "nano /home/$USER/.cache/AUR/chrome-gnome-shell-git/PKGBUILD"' 2>/dev/null || gnome-terminal --geometry 50x5 --hide-menubar --title "PKGBUILD" -e 'sh -c "echo && echo \"Installa editor nano con ^sudo pacman -S nano^\" && read -sp \"[PREMI INVIO PER USCIRE]\""' 2>/dev/null
                     ;;
                  esac
                  echo ; read -p "Confermi l'aggiornamento? [s/n]" pkg
                  if [ "$pkg" = "s" ] ; then
                     cd "$package_dir"/"$package_name"
                     if makepkg -s ; then
                        #echo "Disinstallazione $package_name" ; sudo pacman -R $package_name
                        echo "Installazione $package_name scaricato" ; sudo pacman -U *.pkg.tar.xz
                        [[ -d "$package_dir_name_old" ]] && echo -n "Rimozione $package_dir_name_old di backup..." && rm -r $package_dir_name_old && echo "fatto."
                        package_pkg=$(find /home/$USER/.cache/AUR/$package_name -type f -name "$package_name*" | grep "pkg.tar.xz") ; mv $package_pkg $package_dir
                        package_pkgbuild=$(find /home/$USER/.cache/AUR/$package_name -type f -name "$package_name*" | grep "PKGBUILD") ; mv $package_pkgbuild $package_dir
                        rm -r $package_dir_name ; mkdir $package_dir/$package_name
                        package_pkg=$(find /home/$USER/.cache/AUR -type f -name "$package_name*" | grep "pkg.tar.xz") ; mv $package_pkg $package_dir_name
                        package_pkgbuild=$(find /home/$USER/.cache/AUR -type f -name "$package_name*" | grep "PKGBUILD") ; mv $package_pkg $package_dir_name
                        mv $package_dir/$package_name_tar $package_dir/$package_name
                        dialog --title "pacchetto $package_name" --backtitle "Aggiornamento AUR" --msgbox "Aggiornamento eseguito!" 7 60 ; clear ; risultato=$risultato" "$package_name"-->installato\n"
                     else
                        echo "Aggiornamento fallito."
                        echo -n "Rimozione cartella $package_dir_name (cartella scompattata $package_name_tar scaricato) e ripristino backup..."
                        sudo rm -r $package_dir/$package_name
                        [[ -f "$package_dir"/"$package_name_tar" ]] && rm $package_dir/$package_name_tar
                        [[ -d "$package_dir_name_old" ]] && mv $package_dir_name_old $package_dir_name
                        echo "fatto."
                        read -sp "[Premi invio per continuare]"
                        risultato=$risultato" "$package_name"-->non_installato_problemi_nella_compilazione(make)\n"
                     fi
                  else
                     risultato=$risultato" "$package_name"-->non_installato_per_scelta_utente\n"
                     echo -n "Rimozione cartella $package_dir_name (cartella scompattata $package_name_tar scaricato) e ripristino backup..."
                     sudo rm -r $package_dir/$package_name
                     [[ -f "$package_dir"/"$package_name_tar" ]] && rm $package_dir/$package_name_tar
                     [[ -d "$package_dir_name_old" ]] && mv $package_dir_name_old $package_dir_name
                     echo "fatto." ; sleep 2
                  fi
               else
                  [[ -d "$package_dir_name_old" ]] && mv $package_dir_name_old $package_dir_name
                  [[ -f "$package_dir"/"$package_name_tar" ]] && rm $package_dir/$package_name_tar
                  dialog --title "pacchetto $package_name" --backtitle "Aggiornamento AUR" --msgbox "Aggiornamento fallito, sembra che AUR non contenga il pacchetto da aggiornare. Ripristinato il backup del pacchetto." 7 60 ; clear
                  risultato=$risultato" "$package_name"-->non_installato_non_presente_in_AUR\n"
               fi
            else
               [[ "$check_dip_aur" = "ok" ]] && risultato=$risultato" "$package_name"-->non_installato_per_scelta_utente\n" || risultato=$risultato" "$package_name"-->non installato per mancanza dipendenze AUR\n"
            fi
         else
            dialog --title "Controllo connessione internet" --backtitle "Aggiornamento AUR" --msgbox "Connessione assente, aggiornamento fallito. $package_name ripristinato all'ultima versione." 7 60 ; clear
            risultato=$risultato" "$package_name"-->non_installato_per_assenza_connessione_internet\n"
         fi
      done
      clear ; echo "Riassunto aggiornamento:" ; echo -e "\n$risultato" ; echo ; echo "premi invio per terminare..." ; read -s -n 1
}

controllo_pacchetto () {
   quit=0 ; for i in $(pacman -Qqm) ; do if [ "$i" = "$AUR" ] ; then quit=1 ; fi ; done
   [[ $quit -eq 0 ]] && echo "pacchetto '$AUR' non installato." && exit 0
}

if [ "$1" = "-p" ] && [ "$2" = "" ] ; then clear ; read -p "Inserisci il pacchetto da aggiornare> " AUR ; numero_AUR=1 ; controllo_pacchetto
elif [ "$1" != "-p" ] && [ "$1" != "" ] ; then echo "opzione '$1' non valida." ; exit 0
elif [ "$1" = "-p" ] && [ "$2" != "" ] ; then AUR=$2 ; numero_AUR=1 ; controllo_pacchetto
elif [ "$1" = "" ] ; then
   AUR=$(pacman -Qqm)
   numero_AUR=$(pacman -Qqm | wc -l)
else exit 0
fi
if [ "$(pacman -Qqm | grep -w "$AUR")" = "" ] ; then echo "pacchetto $AUR non trovato." ; exit 0 ; fi
check=$(ps aux | grep "[s]udo pacman") ; if [ "$check" = "" ] ; then
LIGHT_RED=='\033[0;31m' ; LIGHT_GREEN='\033[0;32m' ; LIGHT_WHITE='\033[1;37m' ; NC='\033[0m'
clear && echo -n "Controllo connessione internet..."
if ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null ; then
   echo "Connesso a internet."
   echo -e "\nCONTROLLO PACCHETTI AGGIORNABILI, attendere..."
   aur=()
   aur_ok=()
   update=""
   count=1
   for ((i=0;i<$numero_AUR;i++)) ; do ii=$((i+1)) ; aur[$i]=$(echo $AUR | awk -v x=$ii '{print$x}')
      tput cuu 1 ; tput cuf 47 ; echo "[$(($i+1))/$numero_AUR]" ; tput el ; echo ${aur[$i]} ; tput cuu 1
      versione_new=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=${aur[$i]}" | grep "Version") ; outofdate=$(echo $versione_new | grep "OutOfDate\":null")
      if [ "$versione_new" != "" ] ; then
         versione_new=${versione_new//,/ } ; versione_new=$(echo $versione_new | awk '{print$8}') ; versione_new=${versione_new:11} ; versione_new=${versione_new:0: -1}
         versione_old=$(pacman -Qi ${aur[$i]} | grep "Versione" | awk '{print$3}')
         package_path=$(find /home/$USER -type f -name "${aur[$i]}.tar.gz") ; package_path=$(echo $package_path | awk '{print$1}')
         [[ $package_path != "" ]] && hash_old=$(md5sum $package_path | awk '{print$1}') || hash_old=""
         [[ $hash_old != "" ]] && hash_new=$(curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/"${aur[$i]}.tar.gz" | md5sum | awk '{print$1}') || hash_new=""
         if [ "$versione_new" != "$versione_old" ] && ([ "$hash_old" != "$hash_new" ] || [ "$hash_old" = "" ]) ; then
            if [ "$outofdate" != "" ] ; then descrizione="${LIGHT_GREEN}AGGIORNABILE${NC}" ; descr="AGGIORNABILE" ; else descrizione="${LIGHT_GREEN}AGGIORNABILE${NC}(${LIGHT_RED}OutOfDate${NC})" ; descr="AGGIORNABILE_(OutOfDate)" ; fi
            if [ "$hash_old" = "" ] ; then descrizione=$descrizione"_firme_non_confrontabili" ; fi
            aur_ok+=($count ${aur[$i]} off)
            count=$(($count+1))
            aur[$i]=${aur[$i]}" --->"$descrizione
         else if [ "$outofdate" != "" ] ; then descrizione="${LIGHT_WHITE}AGGIORNATO${NC}" ; else descrizione="${LIGHT_WHITE}AGGIORNATO${NC}(${LIGHT_RED}OutOfDate${NC})" ; fi ; aur[$i]=${aur[$i]}" --->"$descrizione
         fi
      else descrizione="${LIGHT_RED}NON PRESENTE IN AUR${NC}" ; aur[$i]=${aur[$i]}" --->"$descrizione
      fi
   done
   if [ "$aur_ok" = "" ] ; then
      dialog --title "Controllo pacchetti installati" --backtitle "Aggiornamento AUR" --msgbox "Tutti i pacchetti AUR installati sono aggiornati alla versione più recente!" 7 60
   else
      tput cuu 1 ; tput el ; echo "RISULTATO RICERCA PACCHETTI AGGIORNABILI:"
      for ((i=0;i<$numero_AUR;i++)) ; do echo -e ${aur[$i]} ; done ; echo -e "\tt=aggiorna tutto | s=seleziona aggiornamenti | altro=esci" ; read -n 1 -s azione
      if [ "$azione" = "s" ] ; then
         exec 3>&1 ; select=$(dialog --backtitle "Aggiornamento AUR" --checklist "Seleziona i pacchetti da aggiornare:" 20 70 ${#aur_ok[@]} ${aur_ok[@]} 2>&1 1>&3) ; exitcode=$? ; exec 3>&-
         for i in $select ; do update=$update" "${aur_ok[$(((3*$i)-2))]} ; done
         numero=$(grep -o " " <<<"$update" | wc -l)
         [[ "${update// /}" != "" ]] && updating
      elif [ "$azione" = "t" ] ; then numero=$((${#aur_ok[@]}/3))
         for ((i=0;i<$numero;i++)) ; do ii=$(( ($i*3)+1 )) ; update=$update" "${aur_ok[$ii]} ; done
         updating
      fi
   fi
else
   dialog --title "Controllo connessione internet" --backtitle "Aggiornamento AUR" --msgbox "Sembra che manchi la connessione, impossibile proseguire." 7 60
fi
else dialog --title "Controllo gestione pacchetti (PACMAN)" --backtitle "Aggiornamento AUR" --msgbox "C'è già in esecuzione il gestore pacchetti, attenderne la fine." 7 60
fi

exit 0

