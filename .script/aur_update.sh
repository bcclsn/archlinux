#!/bin/bash

#aur_update.sh v4.1
#script di aggiornamento pacchetti installati da AUR, by rebellion
#preferibilmente da lanciare tramite terminale per visualizzare messaggi di dialogo con lo script
#a es. con: gnome-terminal --hide-menubar --title=\"AUR update\" -e \'sh -c \"sh /home/$USER/aur_update.sh\"\'

controllo_dipendenze () {
   dipendenze=$(pacman -Qi $package_name | grep "Dipenda da") ; dipendenze=${dipendenze:28} ; dipendenze=${dipendenze//  / }
   if [ "$dipendenze" != "Nessuna" ] ; then
      numero_dipendenze=$(($(grep -o " " <<<"$dipendenze" | wc -l)+1))
      for ((ii=1;ii<=$numero_dipendenze;ii++)) ; do dip=$(echo $dipendenze | awk -v xx=$ii '{print$xx}') ; dip=${dip%%>*} ; dip=${dip%%<*} ; dip=${dip%%=*} ; if pacman -Q | grep -w "$dip" 1>/dev/null ; then echo $dip"-----> installata" ; else echo $dip"-----> non installata" ; fi ; done
   else echo "NESSUNA dipendenza richiesta."
   fi
   echo ; read -s -p "premi invio per continuare..."
}

seleziona () {
   selezione=()
   row_max=$((${#aur_ok[@]}/4))
   packages="" ; for ((i=0;i<$row_max;i++)) ; do ii=$(( (i*4)+1 )) ; packages=$packages" "${aur_ok[$ii]} ; done
   clear ; echo -e "PACCHETTI DA AGGIORNARE:\n\n" ; for ((i=0;i<$row_max;i++)) ; do package=$(echo $packages | awk -v x=$(( $i+1 )) '{print$x}') ; echo "( ) $package" ; done ; echo -e "\n----------------\ncurs.su/curs.giù per scorrere - invio per (de)selezionare - q per uscire\n----------------"
   tput sc ; tput cuu $(( $row_max+4 )) ; tput cuf 1 ; riga=1
   while [ "$tasto" != "q" ] ; do
      read -s -N1
      ott1="$REPLY"
      read -s -N2 -t 0.001
      ott2="$REPLY"
      read -s -N1 -t 0.001
      ott3="$REPLY"
      tasto="$ott1$ott2$ott3"
      case "$tasto" in
         $'\x1b\x5b\x41')
            if [ "$riga" = 1 ] ; then tput cud $(( $row_max-1 )) ; riga=$row_max ; else tput cuu 1 ; riga=$(( $riga-1 )) ; fi ;;
         $'\x1b\x5b\x42')
            if [ "$riga" = $row_max ] ; then tput cuu $(( $row_max-1 )) ; riga=1 ; else tput cud 1 ; riga=$(( $riga+1 )) ; fi ;;
         "
")
            if [ "${selezione[$riga]}" = "" ] ; then echo "x" ; selezione[$riga]="$riga"; else echo " " ; selezione[$riga]="" ; fi ; tput cuu 1 ; tput cuf 1 ; if [ "$riga" = $row_max ] ; then tput cuu $(( $row_max-1 )) ; riga=1 ; else tput cud 1 ; riga=$(( $riga+1 )) ; fi ;;
      esac
   done
   tput rc
   update=""
   package="" ; for i in "${selezione[@]}" ; do package=$(echo $packages | awk -v x=$i '{print$x}') ; update=$update" "$package ; done
}

updating () {
      risultato=""
      for ((i=1;i<=$numero;i++)) ; do
         clear
         echo -n "Controllo connessione internet..."
         if ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null ; then
            echo "Connessione ok"
            package_name=$(echo $update | awk -v x=$i '{print$x}')
            echo "Installazione $package_name:" ; echo -n "ricerca $package_name_tar..."
            package_name_tar=$package_name".tar.gz"
            package_dir_del=$(find /home/$USER -type d -name "$package_name") ; package_dir_del=$(echo $package_dir_del | awk '{print$1}')
            [[ "$package_dir_del" != "" ]] && package_dir_del_old=$package_dir_del"_old"
            package_dir=$(find /home/$USER -type d -name "AUR") ; [[ "$package_dir" = "" ]] && package_dir=/home/$USER/AUR && mkdir /home/$USER/AUR
            package_path=$(find /home/$USER -type f -name "$package_name_tar") ; package_path=$(echo $package_path | awk '{print$1}')
            [[ "$package_path" != "" ]] && package_path_old=$package_path".old"
            echo "fatto." ; echo -n "Ricerca versioni..."
            versione_new=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=$package_name" | grep "Version") ; outofdate=$(echo $versione_new | grep "OutOfDate\":null") ; [[ "$outofdate" = "" ]] && outofdate="(OutOfDate)" || outofdate=""
            versione_new=${versione_new//,/ } ; versione_new=$(echo $versione_new | awk '{print$8}') ; versione_new=${versione_new:11} ; versione_new=${versione_new:0: -1}$outofdate
            versione_old=$(pacman -Qi $package_name | grep "Versione" | awk '{print$3}')
            echo "fatto." ; echo -e "Versione installata: $versione_old\nVersione da installare: $versione_new"
            echo -e "\nControllo dipendenze del pacchetto $package_name:\n"
            controllo_dipendenze
            if dialog --title "pacchetto $package_name" --backtitle "Aggiornamento AUR" --yesno "Verranno installate eventuali dipendenze mancanti se non presenti in AUR, altrimenti installale manualmente. Confermi l'aggiornamento?" 7 60 ; then clear
               [[ -d "$package_dir_del" ]] && mv $package_dir_del $package_dir_del_old
               [[ "$package_path" != "" ]] && mv $package_path $package_path_old
               echo -e "Aggiornamento "$package_name" in corso, non spengere il pc o la connessione.\nbackup "$package_dir_del"---> fatto\nbackup "$package_name_tar"---> fatto"
               if wget -P $package_dir https://aur.archlinux.org/cgit/aur.git/snapshot/$package_name_tar ; then
                  tar -xvzf $package_dir/$package_name_tar -C $package_dir
                  cd $package_dir/$package_name
                  if makepkg -s ; then
                     echo "Disinstallazione $package_name" ; sudo pacman -R $package_name
                     echo "Installazione $package_name scaricato" ; sudo pacman -U *.pkg.tar.xz
                     [[ "$package_path_old" != "" ]] && echo -n "Rimozione $package_path_old..." && rm $package_path_old && echo "Fatto."
                     [[ -d "$package_dir_del_old" ]] && echo -n "Rimozione cartella $package_dir_del_old di backup..." && sudo rm -r $package_dir_del_old && echo "Fatto." ; sleep 2
                     dialog --title "pacchetto $package_name" --backtitle "Aggiornamento AUR" --msgbox "Aggiornamento eseguito!" 7 60 ; clear ; risultato=$risultato" "$package_name"-->installato\n"
                  else
                     echo "Rimozione cartella $package_dir_del (cartella scompattata $package_name_tar scaricato)..."
                     sudo rm -r $package_dir/$package_name
                     [[ -d "$package_dir_del_old" ]] && mv $package_dir_del_old $package_dir_del
                     rm $package_dir/$package_name_tar ; [[ "$package_path_old" != "" ]] && mv $package_path_old $package_path
                     dialog --title "pacchetto $package_name" --backtitle "Aggiornamento AUR" --msgbox "Aggiornamento fallito. Ripristinato il backup del pacchetto." 7 60 ; clear ; risultato=$risultato" "$package_name"-->non_installato_problemi_con_dipendenze_o_compilazione\n"
                  fi
               else
                  [[ -d "$package_dir_del_old" ]] && mv $package_dir_del_old $package_dir_del
                  [[ "$package_path_old" != "" ]] && mv $package_path_old $package_path
                  dialog --title "pacchetto $package_name" --backtitle "Aggiornamento AUR" --msgbox "Aggiornamento fallito, sembra che AUR non contenga il pacchetto da aggiornare. Ripristinato il backup del pacchetto." 7 60 ; clear
                  risultato=$risultato" "$package_name"-->non_installato_non_presente_in_AUR\n"
               fi
            else risultato=$risultato" "$package_name"-->non_installato_per_scelta_utente\n"
            fi
         else
            echo "Connessione assente. Ripristino ultima versione di $package_name..." ; sleep 2 ;
            [[ -d "$package_dir_del_old" ]] && mv $package_dir_del_old $package_dir_del
            [[ "$package_path_old" != "" ]] && mv $package_path_old $package_path
            dialog --title "Controllo connessione internet" --backtitle "Aggiornamento AUR" --msgbox "Connessione assente, aggiornamento fallito. $package_name ripristinato all'ultima versione." 7 60 ; clear
            risultato=$risultato" "$package_name"-->non_installato_per_assenza_connessione_internet\n"
         fi
      done
      clear ; echo "Riassunto aggiornamento:" ; echo -e "\n$risultato" ; echo ; echo "premi invio per terminare..." ; read -s -n 1
}

check=$(ps aux | grep "[p]acman -Syu") ; if [ "$check" = "" ] ; then
LIGHT_RED=='\033[0;31m' ; LIGHT_GREEN='\033[0;32m' ; LIGHT_WHITE='\033[1;37m' ; NC='\033[0m'
clear && echo -n "Controllo connessione internet..."
if ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null ; then
   echo "Connesso a internet."
   echo -e "\nCONTROLLO PACCHETTI AGGIORNABILI, attendere..."
   aur=()
   aur_ok=()
   update=""
   AUR=$(pacman -Qqm)
   numero_AUR=$(pacman -Qqm | wc -l)
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
            aur_ok+=(False ${aur[$i]} $versione_old $versione_new)
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
         update=$(zenity --list --title="PACCHETTI AUR AGGIORNABILI" --text="seleziona per aggiornare" --width=1000 --height=650 --checklist --separator=" " --column="" --column="PACCHETTO" --column="VERSIONE INSTALLATA" --column="VERSIONE DA INSTALLARE" "${aur_ok[@]}" 2>/dev/null) ; numero=$(($(grep -o " " <<<"$update" | wc -l)+1))
#         seleziona ; numero=$(grep -o " " <<<"$update" | wc -l)
          [[ "${update// /}" != "" ]] && updating
      elif [ "$azione" = "t" ] ; then numero=$((${#aur_ok[@]}/4))
         for ((i=0;i<$numero;i++)) ; do ii=$(( (i*4)+1 )) ; update=$update" "${aur_ok[$ii]} ; done
         updating
      fi
   fi
else
   dialog --title "Controllo connessione internet" --backtitle "Aggiornamento AUR" --msgbox "Sembra che manchi la connessione, impossibile proseguire." 7 60
fi
else dialog --title "Controllo gestione pacchetti (PACMAN)" --backtitle "Aggiornamento AUR" --msgbox "C'è già in esecuzione il gestore pacchetti, attenderne la fine." 7 60
fi

exit 0