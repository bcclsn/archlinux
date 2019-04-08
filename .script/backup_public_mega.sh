#!/bin/bash

# manual OnBootSec monotonic timer option #
while true ; do OnBootSec=$(cat /proc/uptime | awk '{print $1}') ; if [ ${OnBootSec%.*} -gt 300 ] ; then break ; fi ; done

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
   LOG="insert path and name"

   # timestamp #
   echo "" >> $LOG
   date | tee $LOG

   # doing a monthly full backup (1M) #
   duplicity --full-if-older-than 1M --name=$NAME $DIR mega://$USER:$PASS@$HOST/$MDIR | tee $LOG

   # deleting full backups older than 2 months (2) #
   duplicity remove-all-but-n-full 2 --force mega://$USER:$PASS@$HOST/$MDIR | tee $LOG

   # to restore a folder from your backup #
   # comment the previuos command and set the directory
   #RESTORE_DIR=
   #duplicity restore mega://$USER:$PASS@$HOST/$MDIR $RESTORE_DIR | tee $LOG

   # unsetting the confidential variables #
   unset PASSPHRASE

   # notify #
   export DISPLAY=:0 && zenity --info --width=150 --height=80 \
          --title "duplicity" \
          --text "backup completato" \
          --timeout=6 2> /dev/null

else
   # get error #
   export DISPLAY=:0 && zenity --warning --width=180 --height=80 \
          --title "assenza connessione" \
          --text "il backup verrà saltato" \
          --timeout=6 2> /dev/null
fi

################################################
##                                bcclsn v1.7 ##
################################################
