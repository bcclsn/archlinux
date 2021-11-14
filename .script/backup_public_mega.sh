#!/bin/bash

# help menu #
SCRIPT=$(basename $0)                                                           # imposta il nome dello script come variabile
HELP="$SCRIPT [option]\n
 [-b] backup
 [-r] restore
 [-c] basic cleanup
 [-f] hard cleanup
 [-h] help"

# controllo che sia stato passato almeno un argomento #
if [ $# -eq 0 ] ; then                                                          # se lo script è eseguito senza argomenti
   echo -e "$HELP"                                                              # stampa l'help
   exit 1                                                                       # ed esce
fi

# dichiaro le opzioni accettate (i due punti iniziali sopprimono i messaggi di errore) #
while getopts ":brcfh" option ; do

   # manual OnBootSec monotonic timer option #
   while true ; do OnBootSec=$(cat /proc/uptime | awk '{print $1}') ; if [ ${OnBootSec%.*} -gt 180 ] ; then break ; fi ; done

   # check connection #
   if (ping -q -c 1 -W 1 pornhub.com >/dev/null || ping -q -c 1 -W 1 duckduckgo.com >/dev/null) ; then

      # setting the confidential variables #
      export PASSPHRASE="insert here your passphrase"
      USER="insert here your account id"
      PASS="insert here your master application key"
      HOST="mega.nz"
      NAME="insert here the name of the backup"
      DIR="set the directory that you would to backup"
      PWD="insert here your home path"
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
         echo -e "\n*** $(date) ***\n*** BACKUP\n" >> $LOG

         # doing a monthly full backup (1M) #
         duplicity --full-if-older-than 1M \
                   --exclude=$PWD/.local/share/Trash \
                   --exclude=$PWD/.cache \
                   --log-file=$LOG \
                   --name=$NAME $DIR mega://$USER:$PASS@$HOST/$MDIR

         # deleting full backups older than 1 month #
         duplicity remove-all-but-n-full 1 --force --log-file=$LOG mega://$USER:$PASS@$HOST/$MDIR

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
            echo -e "\n*** $(date) ***\n*** RESTORE\n" >> $RDIR/duplicity.log

            # to restore a folder from your backup #
            duplicity restore --log-file=$RDIR/duplicity.log mega://$USER:$PASS@$HOST/$MDIR $RDIR

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

      c) # basic cleanup #
         echo -e "\n*** $(date) ***\n*** BASIC CLEANUP\n" >> $LOG

         # doing a manual cleanup #
         duplicity cleanup --log-file=$LOG mega://$USER:$PASS@$HOST/$MDIR

         # unsetting the confidential variables #
         unset PASSPHRASE

         # notify #
         export DISPLAY=:0 && zenity --info --width=200 --height=80 \
                                            --title="duplicity" \
                                            --text="basic cleanup completato" \
                                            --timeout=6 2> /dev/null
         ;;
      
      f) # hard cleanup #
         echo -e "\n*** $(date) ***\n*** HARD CLEANUP\n" >> $LOG

         # doing a manual cleanup #
         duplicity cleanup --force --log-file=$LOG mega://$USER:$PASS@$HOST/$MDIR

         # unsetting the confidential variables #
         unset PASSPHRASE

         # notify #
         export DISPLAY=:0 && zenity --info --width=200 --height=80 \
                                            --title="duplicity" \
                                            --text="hard cleanup completato" \
                                            --timeout=6 2> /dev/null
         ;;                                   

      h) echo -e "\n $HELP" ;;
      *) echo -e "\n invalid option!\n\n $HELP" ;;
   esac
done

exit 0

################################################################################
##                                                               bcclsn v2.10 ##
################################################################################

