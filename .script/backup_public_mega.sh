#!/bin/bash

# help menu #
SCRIPT=$(basename $0)                                                          # imposta il nome dello script come variabile
HELP="$SCRIPT [option]\n
 [-b] backup
 [-r] restore
 [-h] help"

# controllo che sia stato passato almeno un argomento #
if [ $# -eq 0 ] ; then   			                                # se lo script è eseguito senza argomenti
   echo -e "$HELP"		                                                # stampa l'help
   exit 1         		                                                # ed esce
fi

# dichiaro le opzioni accettate (i due punti iniziali sopprimono i messaggi di errore) #
while getopts ":brh" option ; do

   # manual OnBootSec monotonic timer option #
   while true ; do OnBootSec=$(cat /proc/uptime | awk '{print $1}') ; if [ ${OnBootSec%.*} -gt 180 ] ; then break ; fi ; done

   # check connection #
   if (ping -q -c 1 -W 1 8.8.8.8 >/dev/null || ping -q -c 1 -W 1 google.com >/dev/null) ; then

      # setting the confidential variables #
      export PASSPHRASE="insert here your passphrase"
      USER="insert here your account id"
      PASS="insert here your master application key"
      HOST="mega.nz"
      NAME="insert here the name of the backup"
      DIR="set the directory that you would to backup"
      MDIR="set the mega directory"
      LOG="set log path"

   else
      # get error #
      export DISPLAY=:0 && zenity --warning --width=180 --height=80 \
                                            --title="assenza connessione" \
                                            --text="il backup verrà saltato" \
                                            --timeout=12 2> /dev/null
      exit 1
   fi

   case $option in
      b) # timestamp #
         echo "" >> $LOG
         date >> $LOG

         # doing a monthly full backup (1M) #
         duplicity --full-if-older-than 1M \
                   --exclude ~/.local/share/Trash \
                   --exclude ~/.cache \
                   --name=$NAME $DIR mega://$USER:$PASS@$HOST/$MDIR >> $LOG

         # deleting full backups older than 2 months (2) #
         duplicity remove-all-but-n-full 2 --force mega://$USER:$PASS@$HOST/$MDIR >> $LOG

         # unsetting the confidential variables #
         unset PASSPHRASE

         # notify #
         export DISPLAY=:0 && zenity --info --width=150 --height=80 \
                                            --title="duplicity" \
                                            --text="backup completato" \
                                            --timeout=6 2> /dev/null
         ;;

      r) # insert restore path #
         if RDIR="$(zenity --entry --title="duplicity" --text="seleziona cartella di destinazione")" ; then

            # timestamp  #
            echo "" >> $RDIR/duplicity.log
            date >> $RDIR/duplicity.log

            # to restore a folder from your backup #
            duplicity restore mega://$USER:$PASS@$HOST/$MDIR $RDIR >> $RDIR/duplicity.log

            # unsetting the confidential variables #
            unset PASSPHRASE

            #notify #
            export DISPLAY=:0 && zenity --info --width=150 --height=80 \
                                               --title="duplicity" \
                                               --text="restore completato" \
                                               --timeout=6 2> /dev/null

         else
            # get error #
            zenity --error --width=150 --height=80 \
                           --title="Error" \
                           --text="restore fallito!" \
                           --timeout=12 2> /dev/null
            exit 1
         fi
         ;;

      h) echo -e "\n $HELP";;
      *) echo -e "\n invalid option!\n\n $HELP";;
   esac
done
exit 0

################################################
##                                bcclsn v2.3 ##
################################################
