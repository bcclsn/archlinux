#!/bin/bash

# backblaze b2 #
# setting the confidential variables #
export PASSPHRASE="insert here your passphrase"
ACCOUNT_ID="insert here your account id"
APP_KEY="insert here your master application key"
BUCKETS="insert here your buckets"
NAME="insert here the name of the backup"
DIR="set the directory that you would to backup"

# doing a monthly full backup (1M) #
duplicity --full-if-older-than 1M --name=$NAME $DIR b2://$ACCOUNT_ID:$APP_KEY@$BUCKETS

# deleting full backups older than 2 months (2) #
duplicity remove-all-but-n-full 2 --force b2://$ACCOUNT_ID:$APP_KEY@$BUCKETS

# to restore a folder from your backup #
# comment the previuos command and set the directory
#RESTORE_DIR=
#duplicity restore b2://$ACCOUNT_ID:$APP_KEY@$BUCKETS $RESTORE_DIR

# notify #
#notify-send "duplicity" \
#            "backup completato" \
#            -i /usr/share/icons/Adwaita/scalable/apps/system-file-manager-symbolic.svg \
#            -t 60000
zenity --info --width=150 --height=80 \
       --title "duplicity" \
       --text "backup completato" \
       --timeout=6 2> /dev/null

################################################
##                                bcclsn v1.2 ##
################################################
