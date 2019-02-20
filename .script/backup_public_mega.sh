#!/bin/bash

# mega #
# setting the confidential variables #
export PASSPHRASE="insert here your passphrase"
USER="insert here your account id"
PASS="insert here your master application key"
HOST="mega.nz"
NAME="insert here the name of the backup"
DIR="set the directory that you would to backup"
MDIR="set the mega directory"

# doing a monthly full backup (1M) #
duplicity --full-if-older-than 1M --name=$NAME $DIR mega://$USER:$PASS@$HOST/$MDIR

# deleting full backups older than 2 months (2) #
duplicity remove-all-but-n-full 2 --force mega://$USER:$PASS@$HOST/$MDIR

# to restore a folder from your backup #
# comment the previuos command and set the directory
#RESTORE_DIR=
#duplicity restore mega://$USER:$PASS@$HOST/$MDIR $RESTORE_DIR

# notify #
#notify-send "duplicity" \
#            "backup completato" \
#            -i /usr/share/icons/Adwaita/scalable/apps/system-file-manager-symbolic.svg \
#            -t 60000
zenity --notification --text "backup completato"

################################################
##                                bcclsn v1.2 ##
################################################
