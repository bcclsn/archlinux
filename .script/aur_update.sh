#!/bin/bash

####################################################################################################################

# Gestione AUR v5.4-2 - patch bcclsn
# Script di aggiornamento/inserimento pacchetti installati da AUR, by rebellion
#
# Da lanciare SOLO tramite terminale per visualizzare messaggi di dialogo con lo script
#
# Per il manuale d'uso digitare: (sh )/path/to/file -h
# Gli aggiornamenti sono organizzati in ~/.cache/AUR/$nomepacchetto dove sono presenti PKGBUILD, pkg compilato
#  e lo snapshot scaricato .tar.gz
# Licenza GPL

####################################################################################################################

controllo_dipendenze_core () {
      for ((ii=1;ii<=$numero_dipendenze;ii++)) ; do dip=$(echo $type_dip | awk -v xx=$ii '{print$xx}') ; dip=${dip%%>*} ; dip=${dip%%<*} ; dip=${dip%%=*}
         if pacman -Si $dip &>/dev/null ; then
            if pacman -Q $dip &>/dev/null ; then dips="${LIGHT_WHITE}$dip${NC}=====> ${LIGHT_GREEN}installata${NC}" ; else dips="${LIGHT_WHITE}$dip${NC}=====> ${LIGHT_RED}non installata${NC}" ; fi
         else
            if ldconfig -p | grep $dip &>/dev/null ; then
               dips="${LIGHT_WHITE}$dip${NC}=====> ${LIGHT_GREEN}installata${NC}"
            else
               check_aur=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=$dip" | grep "resultcount\":1")
               if [ "$check_aur" != "" ] ; then
                  a=$(pacman -Qqm | grep "$dip")
                  if [ "$a" != "" ] ; then dips="${LIGHT_WHITE}$dip${NC}=====> ${LIGHT_GREEN}installata (AUR)${NC}" ; else dips="${LIGHT_WHITE}$dip${NC}=====> ${LIGHT_RED}non installata (AUR)${NC}"; [[ "$dip_core" != "opt" ]] && check_dip_aur="no" ; fi
               else
                  if ! pacman -Q $dip &>/dev/null ; then
                     num=$(echo $dip | tr -dc '0-9')
                     a_check=$(echo $dip | grep "-")
                     if [ "$a_check" = "" ] ; then
                        dip=$(printf '%s' "$dip" | tr -d '0123456789')
                        dip=$dip" "$num
                     fi
                  fi
                  check=$(pacman -Qs $dip | grep local | grep -w "local/$dip")
                  if [ "$check" != "" ] ; then dips="${LIGHT_WHITE}$dip${NC}=====> ${LIGHT_GREEN}installata${NC}" ; else dips="${LIGHT_WHITE}$dip${NC}=====> ${LIGHT_RED}non installata${NC}" ; fi
               fi
            fi
         fi
         echo -e $dips
      done
}

controllo_dipendenze () {
   check_dip_aur="ok" ; a="\"Depends\"" ; aa="\",\""
   dipendenze=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=$package_name")
   make_dip=${dipendenze##*MakeDepends} ; if [ "$make_dip" = "$dipendenze" ] ; then make_dip="nessuna" ; else make_dip=${make_dip%%]*} ; make_dip=${make_dip:4} ; make_dip=${make_dip:0: -1} ; make_dip=${make_dip//$aa/ } ; fi
   main_dip=${dipendenze##*$a} ; if [ "$main_dip" = "$dipendenze" ] ; then main_dip="nessuna" ; else main_dip=${main_dip%%]*} ; main_dip=${main_dip:3} ; main_dip=${main_dip:0: -1} ; main_dip=${main_dip//$aa/ } ; fi
   opt_dip=${dipendenze##*OptDepends} ; if [ "$opt_dip" = "$dipendenze" ] ; then opt_dip="nessuna" ; else opt_dip=${opt_dip%%]*} ; opt_dip=${opt_dip:4} ; opt_dip=${opt_dip:0: -1} ; opt_dip=${opt_dip//$aa/ } ; fi
   echo "DIPENDENZE:"
   if [ "$main_dip" != "nessuna" ] ; then
      numero_dipendenze=$(($(grep -o " " <<<"$main_dip" | wc -l)+1))
      dip_core="main"
      type_dip=$main_dip
      controllo_dipendenze_core
   else echo -e "${LIGHT_WHITE}NESSUNA dipendenza richiesta.${NC}"
   fi
   echo -e "\nDIPENDENZE OPZIONALI:"
   if [ "$opt_dip" != "nessuna" ] ; then
      numero_dipendenze=$(($(grep -o " " <<<"$opt_dip" | wc -l)+1))
      dip_core="opt"
      type_dip=$opt_dip
      controllo_dipendenze_core
   else echo -e "${LIGHT_WHITE}NESSUNA dipendenza opzionale richiesta.${NC}"
   fi
   echo -e "\nDIPENDENZE PER LA COMPILAZIONE (MAKE):"
   if [ "$make_dip" != "nessuna" ] ; then
      numero_dipendenze=$(($(grep -o " " <<<"$make_dip" | wc -l)+1))
      dip_core="make"
      type_dip=$make_dip
      controllo_dipendenze_core
   else echo -e "${LIGHT_WHITE}NESSUNA dipendenza per la compilazione richiesta.${NC}"
   fi
}

updating () {
      risultato=""
      for ((i=1;i<=$numero;i++)) ; do
         clear
         echo -n "Controllo connessione internet..."
         if ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null ; then
            echo -e "${LIGHT_WHITE}Connessione ok${NC}"
            package_name=$(echo $update | awk -v x=$i '{print$x}')
            echo -e "Installazione ${LIGHT_WHITE}$package_name${NC}:"
            package_name_tar=$package_name".tar.gz" ; echo -en "ricerca ${LIGHT_WHITE}$package_name_tar${NC}..."
            package_name_tar_old=$package_name_tar".old"
            package_dir="/home/$USER/.cache/AUR" ; [[ -d "$package_dir" ]] || mkdir /home/$USER/.cache/AUR
            package_path="/home/$USER/.cache/AUR/$package_name_tar" ; package_path_old=$package_path".old"
            package_dir_name="/home/$USER/.cache/AUR/$package_name"
            package_dir_name_old=$package_dir_name"_old"
            echo "fatto." ; echo -n "Ricerca versioni..."
            versione_new=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=$package_name" | grep "Version") ; outofdate=$(echo $versione_new | grep "OutOfDate\":null") ; [[ "$outofdate" = "" ]] && outofdate="(OutOfDate)" || outofdate=""
            versione_new=${versione_new//,/ } ; versione_new=$(echo $versione_new | awk '{print$8}') ; versione_new=${versione_new:11} ; versione_new=${versione_new:0: -1}$outofdate
            versione_old=$(pacman -Qi $package_name | grep "Versione" | awk '{print$3}')
            echo "fatto." ; echo -e "Versione installata: ${LIGHT_WHITE}$versione_old${NC}\nVersione da installare: ${LIGHT_WHITE}$versione_new${NC}"
            echo -e "\nControllo dipendenze del pacchetto ${LIGHT_WHITE}$package_name${NC}:\n"
            controllo_dipendenze
            pkg="n"
            # if [ -f "$package_dir/$package_name/PKGBUILD" ] ; then
            #   echo ; read -p "Vuoi consultare il PKGBUILD in locale di $package_name prima di aggiornare? [s/n]" pkg
            #   if [ "$pkg" = "s" ] ; then clear ; echo -e "${LIGHT_WHITE}$package_dir/$package_name/PKGBUILD${NC}\n" ; cat $package_dir/$package_name/PKGBUILD ; premi_invio ; fi
            # else
            #   echo ; echo -e "${LIGHT_WHITE}PKGBUILD${NC} in $package_dir/$package_name ${LIGHT_WHITE}assente${NC}." ; premi_invio
            # fi
            if [ "$check_dip_aur" = "ok" ] && dialog --title "pacchetto $package_name" --backtitle "Gestore AUR" --yesno "Verranno installate eventuali dipendenze mancanti presenti in community. Confermi l'aggiornamento?" 7 60 ; then clear
               [[ -d "$package_dir_name" ]] && mv $package_dir_name $package_dir_name_old
               echo -e "Aggiornamento ${LIGHT_WHITE}"$package_name"${NC} in corso, non spengere il pc o la connessione.\nbackup ${LIGHT_WHITE}"$package_dir_name"${NC}---> fatto\nbackup ${LIGHT_WHITE}"$package_name_tar"${NC}---> fatto"
               if wget -P $package_dir https://aur.archlinux.org/cgit/aur.git/snapshot/$package_name_tar ; then
                  tar -xvzf $package_dir/$package_name_tar -C $package_dir
                  read -p "Vuoi consultare il PKGBUILD scaricato? [s/n]" pkg
                  case $pkg in
                     "s")
                       if [ -e "/usr/bin/nano" ] ; then nano /home/$USER/.cache/AUR/$package_name/PKGBUILD ; else echo -e "Editor ${LIGHT_WHITE}nano${NC} non installato.\nVuoi installarlo adesso?" ; read -p "[s=si/n=no]" nan ; [[ "$nan" = "s" ]] && echo "${LIGHT_WHITE}sudo pacman -S nano..." && sudo pacman -S nano && nano /home/$USER/.cache/AUR/$package_name/PKGBUILD ; fi
                     ;;
                  esac
                  echo ; read -p "Confermi l'aggiornamento? [s/n]" pkg
                  if [ "$pkg" = "s" ] ; then
                     echo "Compilazione (makepkg) in corso..."
					 cd /home/$USER/.cache/AUR/$package_name
					 if makepkg -s ; then
                        tput cuu 1 ; echo "Compilazione (makepkg) terminata con successo."
                        echo -e "Installazione ${LIGHT_WHITE}$package_name${NC} scaricato" ; sudo pacman -U *.pkg.tar.xz --noconfirm
                        [[ -f "$package_dir_name_old"/"$package_name_tar" ]] && mv "$package_dir_name_old"/"$package_name_tar" /home/$USER/.cache/AUR/$package_name_tar".old"
                        [[ -d "$package_dir_name_old" ]] && echo -en "Rimozione ${LIGHT_WHITE}$package_dir_name_old${NC} di backup..." && rm -r $package_dir_name_old && echo "fatto."
                        echo -en "Pulizia cartella di compilazione ${LIGHT_WHITE}$package_dir_name${NC}..."
                        package_pkg=$(find /home/$USER/.cache/AUR/$package_name -type f -name "$package_name*" | grep "pkg.tar.xz") ; mv $package_pkg $package_dir
                        pkgbuildnew="PKGBUILDnew" ; mv /home/$USER/.cache/AUR/$package_name/PKGBUILD $package_dir/$pkgbuildnew
                        rm -rf $package_dir_name ; mkdir $package_dir/$package_name
                        package_pkg=$(find /home/$USER/.cache/AUR -type f -name "$package_name*" | grep "pkg.tar.xz") ; mv $package_pkg $package_dir_name
                        mv /home/$USER/.cache/AUR/$pkgbuildnew $package_dir_name/PKGBUILD
                        package_targz=$(find /home/$USER/.cache/AUR -type f -name "$package_name*" | grep ".tar.gz") ; mv $package_targz $package_dir_name
                        [[ -f /home/$USER/.cache/AUR/$package_name_tar_old ]] && mv /home/$USER/.cache/AUR/$package_name_tar_old /home/$USER/.cache/AUR/$package_name
                        echo -e "${LIGHT_WHITE}fatto${NC}" ; sleep 1
                        dialog --title "pacchetto $package_name" --backtitle "Gestore AUR" --msgbox "Aggiornamento eseguito!" 7 60 ; clear ; risultato=$risultato" "${LIGHT_WHITE}$package_name${NC}"-->${LIGHT_GREEN}installato${NC}\n"
                     else
                        tput cuu 1 ; echo "Compilazione (makepkg) abortita.   "
                        echo "Aggiornamento fallito."
                        echo -en "Rimozione cartella ${LIGHT_WHITE}$package_dir_name${NC} (cartella scompattata ${LIGHT_WHITE}$package_name_tar${NC} scaricato) e ripristino backup..."
                        rm -rf $package_dir/$package_name
                        [[ -f "$package_dir"/"$package_name_tar" ]] && rm $package_dir/$package_name_tar
                        [[ -d "$package_dir_name_old" ]] && mv $package_dir_name_old $package_dir_name
                        echo "fatto."
                        premi_invio
                        risultato=$risultato" "${LIGHT_WHITE}$package_name${NC}"-->${LIGHT_RED}non_installato_compilazione_interrotta(make)${NC}\n"
                     fi
                  else
                     risultato=$risultato" "${LIGHT_WHITE}$package_name${NC}"-->${LIGHT_RED}non_installato_per_scelta_utente${NC}\n"
                     echo -en "Rimozione cartella ${LIGHT_WHITE}$package_dir_name${NC} (cartella scompattata ${LIGHT_WHITE}$package_name_tar${NC} scaricato) e ripristino backup..."
                     rm -r $package_dir/$package_name
                     [[ -f "$package_dir"/"$package_name_tar" ]] && rm $package_dir/$package_name_tar
                     [[ -d "$package_dir_name_old" ]] && mv $package_dir_name_old $package_dir_name
                     echo "fatto." ; sleep 1
                  fi
               else
                  [[ -d "$package_dir_name_old" ]] && mv $package_dir_name_old $package_dir_name
                  [[ -f "$package_dir"/"$package_name_tar" ]] && rm $package_dir/$package_name_tar
                  dialog --title "pacchetto $package_name" --backtitle "Gestore AUR" --msgbox "Aggiornamento fallito, sembra che AUR non contenga il pacchetto da aggiornare. Ripristinato il backup del pacchetto." 7 60 ; clear
                  risultato=$risultato" "${LIGHT_WHITE}$package_name${NC}"-->${LIGHT_RED}non_installato_non_presente_in_AUR${NC}\n"
               fi
            else
               [[ "$check_dip_aur" = "ok" ]] && risultato=$risultato" "${LIGHT_WHITE}$package_name${NC}"-->${LIGHT_RED}non_installato_per_scelta_utente${NC}\n" || risultato=$risultato" "${LIGHT_WHITE}$package_name${NC}"-->${LIGHT_RED}non installato per mancanza dipendenze AUR${NC}\n"
            fi
         else
            dialog --title "Controllo connessione internet" --backtitle "Gestore AUR" --msgbox "Connessione assente, aggiornamento fallito. $package_name ripristinato all'ultima versione." 7 60 ; clear
            risultato=$risultato" "${LIGHT_WHITE}$package_name${NC}"-->${LIGHT_RED}non_installato_per_assenza_connessione_internet${NC}\n"
         fi
      done
      clear ; echo "Riassunto aggiornamento:" ; echo -e "\n$risultato" ; premi_invio_gnome_term
}

installer () {
  echo -en "\n Controllo connessione internet..."
  if ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null ; then
   echo -e "${LIGHT_WHITE}connesso a internet.${NC}\n"
   PACK_locale=$(pacman -Q $PACK 2>/dev/null)
   PACK_aur=$(curl -s "https://aur.archlinux.org/rpc.php?v=5&type=info&arg=$PACK")
   PACK_aur_check=${PACK_aur##*resultcount} ; PACK_aur_check=${PACK_aur_check:2:1}
   if [ "$PACK_locale" != "" ] ; then pacman -Qi $PACK ; premi_invio_gnome_term
   else
      case $PACK_aur_check in
         "0")
            echo -e "${LIGHT_WHITE}$PACK${LIGHT_RED} non presente in AUR.${NC}" ; premi_invio_gnome_term ;;
         * )
            aaaa="\"" ; stampa=$(echo $PACK_aur | grep Name) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*Name} && stampa=${stampa%%,*} && stampa=${stampa:3} && stampa=${stampa:0: -1} ; echo -e "\nNome                    : ${LIGHT_WHITE}$stampa${NC}"
             stampa=$(echo $PACK_aur | grep Version) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*Version} && stampa=${stampa%%,*} && stampa=${stampa:3} && stampa=${stampa:0: -1} ; echo -e "Versione                : ${LIGHT_WHITE}$stampa${NC}"
            stampa=$(echo $PACK_aur | grep Description) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*Description} ; stampa=${stampa%%,*} ; stampa=${stampa:3} ; stampa=${stampa:0: -2} ; echo -e "Descrizione             : ${LIGHT_WHITE}$stampa${NC}"
            aaa="\"URL\"" ; stampa=$(echo $PACK_aur | grep "$aaa") ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*$aaa} ; stampa=${stampa%%,*} ; stampa=${stampa:2} ; stampa=${stampa:0: -1} && stampa=${stampa//\\/} ; echo -e "URL                     : ${LIGHT_WHITE}${stampa// /}${NC}"
            aaa="\"Depends\"" ; stampa=$(echo $PACK_aur | grep "$aaa") ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*$aaa} && stampa=${stampa%%]*} && stampa=${stampa:2} && stampa=${stampa//,/ } ; echo -e "Dipendenze              : ${LIGHT_WHITE}${stampa//$aaaa/}${NC}"
            stampa=$(echo $PACK_aur | grep OptDepends) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*OptDepends} && stampa=${stampa%%]*} && stampa=${stampa:3} && stampa=${stampa//,/ } ; echo -e "Dipendenze Opzionali    : ${LIGHT_WHITE}${stampa//$aaaa/}${NC}"
            stampa=$(echo $PACK_aur | grep MakeDepends) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*MakeDepends} && stampa=${stampa%%]*} && stampa=${stampa:3} && stampa=${stampa//,/ } ; echo -e "Dipendenze Compilazione : ${LIGHT_WHITE}${stampa//$aaaa/}${NC}"
            stampa=$(echo $PACK_aur | grep OutOfDate) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*OutOfDate} && stampa=${stampa%%,*} && stampa=${stampa:2} ; echo -e "Flag                    : ${LIGHT_WHITE}$stampa${NC}"
            stampa=$(echo $PACK_aur | grep Maintainer) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*Maintainer} && stampa=${stampa%%,*} && stampa=${stampa:3} && stampa=${stampa:0: -1} ; echo -e "Mainteiner              : ${LIGHT_WHITE}$stampa${NC}"
            stampa=$(echo $PACK_aur | grep Conflicts) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*Conflicts} && stampa=${stampa%%]*} && stampa=${stampa:3} && stampa=${stampa//,/ } ; echo -e "Confligge               : ${LIGHT_WHITE}${stampa//$aaaa/}${NC}"
            stampa=$(echo $PACK_aur | grep Provides) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*Provides} && stampa=${stampa%%]*} && stampa=${stampa:3} && stampa=${stampa//,/ } ; echo -e "Fornisce                : ${LIGHT_WHITE}${stampa//$aaaa/}${NC}"
            stampa=$(echo $PACK_aur | grep Replaces) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*Replaces} && stampa=${stampa%%]*} && stampa=${stampa:3} && stampa=${stampa//,/ } ; echo -e "Rimpiazza               : ${LIGHT_WHITE}${stampa//$aaaa/}${NC}"
            stampa=$(echo $PACK_aur | grep License) ; [[ "$stampa" != "" ]] && stampa=${PACK_aur##*License} && stampa=${stampa%%,*} && stampa=${stampa:3} && stampa=${stampa:0: -1} ; echo -e "Licenze                 : ${LIGHT_WHITE}${stampa//$aaaa}${NC}\n"
            package_name=$PACK ; controllo_dipendenze
            if [ "$check_dip_aur" = "ok" ] ; then               
               read -n 1 -p "Vuoi installarlo (assieme a eventuali dipedenze non opzionali mancanti)? [s=si/n=no]" ins
               if [ "$ins" = "s" ] ; then
                check=$(ps aux | grep "[s]udo pacman")
                if [ "$check" = "" ] ; then
                  echo -e "\nInstallazione ${LIGHT_WHITE}$PACK${NC}:"
                  [[ ! -d "/home/$USER/.cache/AUR" ]] && echo -en "Creazione cartella ${LIGHT_WHITE}/home/$USER/.cache/AUR${NC}..." && mkdir /home/$USER/.cache/AUR && echo "fatto."
                  echo -en "Creazione cartella ${LIGHT_WHITE}/home/$USER/.cache/AUR/$PACK${NC}..." && mkdir /home/$USER/.cache/AUR/$PACK && echo "fatto."
                  wget -P /home/$USER/.cache/AUR https://aur.archlinux.org/cgit/aur.git/snapshot/$PACK".tar.gz"
                  tar -xvzf /home/$USER/.cache/AUR/$PACK".tar.gz" -C /home/$USER/.cache/AUR
                  echo ; read -p "Vuoi consultare il PKGBUILD scaricato? [s/n]" pkg
                  case $pkg in
                     "s")
                        if [ -e "/usr/bin/nano" ] ; then nano /home/$USER/.cache/AUR/$PACK/PKGBUILD ; else echo -e "Editor ${LIGHT_WHITE}nano${NC} non installato.\nVuoi installarlo adesso?" ; read -p "[s=si/n=no]" nan ; [[ "$nan" = "s" ]] && echo "${LIGHT_WHITE}sudo pacman -S nano..." && sudo pacman -S nano && nano /home/$USER/.cache/AUR/$PACK/PKGBUILD ; fi
                     ;;
                  esac
                  echo ; read -p "Confermi l'installazione? [s/n]" pkg
                  if [ "$pkg" = "s" ] ; then
                     echo "Compilazione (makepkg) in corso.."
                     cd /home/$USER/.cache/AUR/$PACK
					 if makepkg -s ; then
                        tput cuu 1 ; echo "Compilazione (makepkg) terminata con successo."
                        package=$(find /home/$USER/.cache/AUR/$PACK -maxdepth 1 -type f -name "*.pkg.tar.xz" | grep "$PACK") ; package=${package##*/}
                        if sudo pacman -U /home/$USER/.cache/AUR/$PACK/$package ; then
                           echo -en "Pulizia cartella ${LIGHT_WHITE}/home/$USER/.cache/AUR/$PACK${NC}..."
                           mv /home/$USER/.cache/AUR/$PACK/$package /home/$USER/.cache/AUR
                           mv /home/$USER/.cache/AUR/$PACK/PKGBUILD /home/$USER/.cache/AUR
                           mv /home/$USER/.cache/AUR/$PACK/$package_tar /home/$USER/.cache/AUR
                           rm -rf /home/$USER/.cache/AUR/$PACK && mkdir /home/$USER/.cache/AUR/$PACK
                           mv /home/$USER/.cache/AUR/$package /home/$USER/.cache/AUR/$PACK
                           mv /home/$USER/.cache/AUR/PKGBUILD /home/$USER/.cache/AUR/$PACK
                           mv /home/$USER/.cache/AUR/$PACK".tar.gz" /home/$USER/.cache/AUR/$PACK
                           echo "fatto." ; echo "Installazione terminata." ; premi_invio_gnome_term
                        else
                           echo -n "Rimozione cartella di compilazione e snapshot scaricato..."
                           rm -rf /home/$USER/.cache/AUR/$PACK && rm /home/$USER/.cache/AUR/$PACK".tar.gz" ; echo "fatto." ; premi_invio_gnome_term
                        fi
                     else tput cuu 1 ; echo "Compilazione (makepkg) abortita.  "
                        echo "Installazione fallita."
                        echo -ne "Rimozione cartella ${LIGHT_WHITE}/home/$USER/.cache/AUR/$PACK${NC} e ${LIGHT_WHITE}$PACK.tar.gz${NC} scaricato.." && rm -rf /home/$USER/.cache/AUR/$PACK && rm /home/$USER/.cache/AUR/$PACK".tar.gz" && echo "fatto." ; premi_invio_gnome_term
                     fi
                  else echo -ne "Rimozione cartella ${LIGHT_WHITE}/home/$USER/.cache/AUR/$PACK${NC} e $PACK.tar.gz scaricato.." && rm -rf /home/$USER/.cache/AUR/$PACK && rm /home/$USER/.cache/AUR/$PACK".tar.gz" && echo "fatto."
                  fi
                else dialog --title "Controllo gestione pacchetti (PACMAN)" --backtitle "Gestore AUR" --msgbox "C'è già in esecuzione il gestore pacchetti, attenderne la fine." 7 60
                fi
               fi
            else echo -e "\nMancano alcune dipendenze installabili da AUR.\n" ; premi_invio_gnome_term
            fi
         ;;
      esac
   fi
  else dialog --title "Controllo connessione internet" --backtitle "Gestore AUR" --msgbox "Sembra che manchi la connessione, impossibile proseguire." 7 60
  fi
}

remover () {
   if sudo pacman -R $AUR ; then
      echo -en "\nRimozione cartella ${LIGHT_WHITE}/home/$USER/.cache/AUR/$AUR${NC}..."
      rm -r /home/$USER/.cache/AUR/$AUR
      echo "fatto" ; sleep 1
   fi
   premi_invio_gnome_term
}

controllo_pacchetto () {
   quit=0 ; for i in $(pacman -Qqm) ; do if [ "$i" = "$AUR" ] ; then quit=1 ; fi ; done
   [[ $quit -eq 0 ]] && echo -e "$name: pacchetto '${LIGHT_WHITE}$AUR${NC}' non installato." && premi_invio_gnome_term && exit 0
}

premi_invio () {
   echo ; read -sp "[ premi invio per continuare ]"
}

premi_invio_gnome_term () {
   if [ "$PARENT_COMMAND" = "gnome-terminal-" ] ; then premi_invio ; fi
}

PARENT_COMMAND="$(ps -o comm= $PPID)"
[[ -t 1 ]] && TERMINAL="term" || TERMINAL="no-term"
if [ "$PARENT_COMMAND" != "bash" ] && [ "$PARENT_COMMAND" != "gnome-terminal-" ] && [ "$PARENT_COMMAND" != "zsh" ] ; then notify-send "ERRORE: avvia il Gestore AUR da terminale." ; exit 0 ; fi
name=$0 ; name=${name##*/}
LIGHT_RED='\033[1;31m' ; LIGHT_GREEN='\033[1;32m' ; LIGHT_WHITE='\033[1;37m' ; NC='\033[0m'
if pacman -Q dialog &>/dev/null ; then 
   if [ "$#" -lt 3 ] ; then
      if [ "$1" = "-p" ] && [ "$2" = "" ] ; then clear ; read -p "Inserisci il pacchetto da aggiornare> " AUR ; numero_AUR=1 ; controllo_pacchetto
      elif [ "$1" != "-p" ] && [ "$1" != "-i" ] && [ "$1" != "-h" ] && [ "$1" != "" ] && [ "$1" != "-r" ] ; then echo -e "$name: opzione '${LIGHT_WHITE}$1${NC}' non valida.\n$name: prova '${LIGHT_WHITE}-h${NC}' per help e info." ; premi_invio_gnome_term ; exit 0
      elif [ "$1" = "-p" ] && [ "$2" != "" ] ; then AUR=$2 ; numero_AUR=1 ; controllo_pacchetto
      elif [ "$1" = "" ] ; then
         AUR=$(pacman -Qqm)
         numero_AUR=$(pacman -Qqm | wc -l)
      elif [ "$1" = "-i" ] ; then [[ "$2" = "" ]] && read -p "Inserisci il pacchetto AUR da installare> " PACK || PACK=$2 ; installer ; echo -e "\n${LIGHT_GREEN}*****$name terminato*****${NC}" && sleep 2 ; exit 0
      elif [ "$1" = "-r" ] ; then [[ "$2" = "" ]] && read -p "Inserisci il pacchetto da rimuovere> " AUR || AUR="$2" ; controllo_pacchetto ; remover ; exit 0
      elif [ "$1" = "-h" ] ; then clear ; echo -e "MANUALE $name:\n\n${LIGHT_WHITE}NOME E DESCRIZIONE${NC}\n   $name - utility aggiornamento/installazione pacchetti AUR\n\n${LIGHT_WHITE}SINOSSI${NC}\n   ${LIGHT_WHITE}Uso${NC}\n      $name [OPZIONI] [nomepacchetto]\n\n${LIGHT_WHITE}OPZIONI\n   -p,\n${NC}      aggiornamento con richiesta del nomepacchetto\n\n${LIGHT_WHITE}   -p NOMEPACCHETTO,\n${NC}      aggiornamento NOMEPACCHETTO\n\n${LIGHT_WHITE}   -i,${NC}\n      installazione con richiesta del nomepacchetto\n\n${LIGHT_WHITE}   -i NOMEPACCHETTO,\n${NC}      installazione NOMEPACCHETTO\n\n${LIGHT_WHITE}   -r,${NC}\n      rimozione con richiesta del nomepacchetto\n\n${LIGHT_WHITE}   -r NOMEPACCHETTO,\n${NC}      rimozione NOMEPACCHETTO\n\n${LIGHT_WHITE}   -h,\n${NC}      manuale d'uso\n\n\n${LIGHT_GREEN}*****SOFTWARE BY REBELLION, FREE AND WITH GPL LICENSE*****${NC}" ; premi_invio_gnome_term ; exit 0
      else exit 0
      fi
   else echo -e "$name: troppi argomenti -- ${LIGHT_WHITE}$@${NC}.\n$name: prova '${LIGHT_WHITE}-h${NC}' per help e info." ; premi_invio_gnome_term ; exit 0
   fi
   if [ "$(pacman -Qqm | grep -w "$AUR")" = "" ] ; then echo -e "$name: pacchetto ${LIGHT_WHITE}$AUR${NC} non trovato." ; premi_invio_gnome_term ; exit 0 ; fi
   check=$(ps aux | grep "[s]udo pacman")
   if [ "$check" = "" ] ; then
      clear && echo -n "Controllo connessione internet..."
      if ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null ; then
         echo -e "${LIGHT_WHITE}Connesso a internet.${NC}"
         echo -e "\nCONTROLLO PACCHETTI AGGIORNABILI, attendere..."
         aur=()
         aur_ok=()
         update=""
         count=1
         for ((i=0;i<$numero_AUR;i++)) ; do ii=$((i+1)) ; aur[$i]=$(echo $AUR | awk -v x=$ii '{print$x}')
            tput cuu 1 ; tput cuf 47 ; echo "[$(($i+1))/$numero_AUR]" ; tput el ; echo -e ${LIGHT_WHITE}${aur[$i]}${NC} ; tput cuu 1
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
            dialog --title "Controllo pacchetti installati" --backtitle "Gestore AUR" --msgbox "Tutti i pacchetti AUR installati sono aggiornati alla versione più recente!" 7 60
         else
            tput cuu 1 ; tput el ; echo "RISULTATO RICERCA PACCHETTI AGGIORNABILI:"
            for ((i=0;i<$numero_AUR;i++)) ; do echo -e ${aur[$i]} ; done
            [[ ${#aur_ok[@]} -eq 3 ]] && echo -e "\tt=aggiorna il pacchetto | altro=esci" || echo -e "\tt=aggiorna tutto | s=seleziona aggiornamenti | altro=esci"
            read -n 1 -s azione
            if [ "$azione" = "s" ] && [ ${#aur_ok[@]} -gt 3 ] ; then
               exec 3>&1 ; select=$(dialog --backtitle "Gestore AUR" --checklist "Seleziona i pacchetti da aggiornare:" 20 70 ${#aur_ok[@]} ${aur_ok[@]} 2>&1 1>&3) ; exitcode=$? ; exec 3>&-
               for i in $select ; do update=$update" "${aur_ok[$(((3*$i)-2))]} ; done
               numero=$(grep -o " " <<<"$update" | wc -l)
               [[ "${update// /}" != "" ]] && updating
            elif [ "$azione" = "t" ] ; then numero=$((${#aur_ok[@]}/3))
               for ((i=0;i<$numero;i++)) ; do ii=$(( ($i*3)+1 )) ; update=$update" "${aur_ok[$ii]} ; done
               updating
            fi
         fi
      else
         dialog --title "Controllo connessione internet" --backtitle "Gestore AUR" --msgbox "Sembra che manchi la connessione, impossibile proseguire." 7 60
      fi
   else dialog --title "Controllo gestione pacchetti (PACMAN)" --backtitle "Gestore AUR" --msgbox "C'è già in esecuzione il gestore pacchetti, attenderne la fine." 7 60
   fi
else echo -e "\nsh $name: manca il pacchetto ${LIGHT_WHITE}dialog${NC}, vuoi installarlo (non richiede dipendenze)? [s=si/altro=no]" ; read dialogo
   case $dialogo in
      "s")
         sudo pacman -S dialog ;;
   esac
fi
clear ; echo -e "${LIGHT_GREEN}*****$name terminato*****${NC}" && sleep 1

exit 0
