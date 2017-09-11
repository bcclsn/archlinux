#!/bin/bash

testo="*************************************************************************
INFORMATIVA ALL’UTENTE.
*************************************************************************
Free license software by rebellion and thanks to «MoMy»
*************************************************************************
ATTENZIONE dipendenze da installare:
- pv
- zenity
*************************************************************************
Script di gestione backup incrementali e loro ripristino. Il backup incrementale raccoglie in
una cartella (di  destinazione) il primo backup completo di una cartella (di provenienza); in
seguito vengono creati ulteriori archivi con le sole modifiche apportate  alla cartella di pro-
venienza, il tutto gestito da un file .idx presente nella cartella dell’archivio.

Se però si desidera compiere un backup di una cartella non incrementale basterà, dopo aver
creato per la prima volta l’archivio, eliminare il  file .idx mediante l’opzione di 'gestione files'
di questo script; fate attenzione a non cancellare il  file .idx quando sono presenti più di un
backup incrementali altrimenti non sarà più possibile ripristinare il backup a meno di non e-
strarre il file ‘cartella’_backup0-gg-mm-aa.tar.gz relativo alla data gg-mm-aa.

Per estrarre un backup completo basta cliccare sul file .tar.gz col tasto  sn o  dx a seconda
della distribuzione/DE in uso. Tutti gli archivi creati sono compressi con gzip."

## controllo dipendenze
[ -e "/usr/bin/pv" ] && [ -e "/usr/bin/zenity" ]
case $? in
 1 )
  if [ ! -e "/usr/bin/pv" ] ; then dip="pv" ; fi
  if [ ! -e "/usr/bin/zenity" ] ; then [ -e "/usr/bin/pv" ] && dip="zenity" || dip=$dip" e zenity" ; fi
  zenity --error --width=500 --height=100 --text="Errore: dipendenze non soddisfatte, installa $dip.
Applicazione terminata."
  exit 0
  ;;
esac

## mostra testo iniziale?
if [ $(sed -e '$!d' $0) = "#info=on" ] ; then
 info=$(zenity --list --width=450 --height=600 --title="GESTIONE BACKUP INCREMENTALI" --text="$testo" --radiolist --column="clicca" --column="opzione" TRUE "Mostra ancora all'avvio" FALSE "Non mostrare più all'avvio")
 case $info in
  "Non mostrare più all'avvio" )
   sed -i '$ d' $0
   echo "#info=off" >> $0
   ;;
  "" )
   zenity --notification --text="gestione backup terminata, ciao."
   exit 0
   ;;
 esac
fi

## menù iniziale
var="mostra info al prossimo riavvio"
while [ "$var" = "mostra info al prossimo riavvio" ]
do
if [ $(sed -e '$!d' $0) = "#info=on" ] ; then
 var=$(zenity --list --width=450 --height=300 --title="GESTIONE BACKUP/RIPRISTINO" --text="Seleziona l'opzione desiderata" --radiolist --column="clicca" --column="opzione" TRUE "script di BACKUP" FALSE "script di RIPRISTINO" FALSE "GESTIONE FILES")
else
 var=$(zenity --width=450 --height=300 --list --title="GESTIONE BACKUP/RIPRISTINO" --text="Seleziona l'opzione desiderata" --column="" "script di BACKUP" "script di RIPRISTINO" "GESTIONE FILES" "mostra info al prossimo riavvio")
fi
if [ "$var" = "mostra info al prossimo riavvio" ] ; then sed -i '$ d' $0 ; echo "#info=on" >> $0 ; fi
done

## scelte dal menù iniziale
case $var in
 "script di BACKUP" )
  dest=$(zenity --file-selection --directory --title="Seleziona la cartella di backup" 2> /dev/null)
 case $? in
  0 )
   prov=$(zenity --file-selection --directory --title="Seleziona la cartella da copiare" 2> /dev/null)
   if [[ $? -eq 0 ]]; then
    [ $(du -s $prov | awk '{print $1}') -gt $(df $dest | tr "\n" ' ' | awk '{print $12}') ]
    if [[ $? -eq 1 ]]; then
     cartella=${prov##*/}
     count=0 ; for i in $(find $dest -maxdepth 1 -name *.tar.gz) ; do let count=count+1 ; done
     backupfile=$cartella"_backup"$count"-"$(date +%d-%m-%Y).tar.gz
     testo="cartella di destinazione:
$dest

cartella di provenienza:
$prov

file di backup:
$backupfile"
     zenity --question --title="BACKUP INCREMENTALE" --text="$testo"
     if [ $? -eq 0 ]; then
      log="backup_"$cartella.idx
      if [ -e $dest/$backupfile ]; then
       zenity --notification --window-icon="info" --text="c'è già un backup, non più di un backup al giorno"
      else
       (tar c --listed-incremental=$dest/$log f - $prov | pv -n -s $(du -sb $prov | awk '{print$1}') | gzip > $dest/$backupfile) 2>&1 | zenity --progress --no-cancel --width=450 --height=120 --title="AVVIO BACKUP" --text="backup in esecuzione, attendere.."
       zenity --notification --window-icon="info" --text="backup eseguito con successo."
      fi
     else
      zenity --notification --text="gestione backup terminata, ciao."
     fi
    else
     zenity --notification --window-icon="error" --text="backup non eseguito: spazio su disco non sufficiente."
    fi
   else
    zenity --notification --text="gestione backup terminata, ciao."
   fi
   ;;
  1 )
   zenity --notification --text="gestione backup terminata, ciao."
   ;;
 esac
 [ "$(ls -A $dest)" ] && echo "" || rm -r $dest
  ;;
 "script di RIPRISTINO" )
  prov=$(zenity --file-selection --directory --title="Seleziona la cartella dell'archivio" 2> /dev/null)
  case $? in
   0 )
    if [ "$(find $prov -maxdepth 1 -name *.tar.gz)" = "" ] ; then zenity --notification --window-icon="error" --text="nessun archivio presente nella cartella."
   else
     dest=$(zenity --file-selection --directory --title="Seleziona la cartella dove ripristinare" 2> /dev/null)
     if [[ $? -eq 0 ]]; then
      [ $(du -s $prov | awk '{print $1}') -gt $(df $dest | tr "\n" ' ' | awk '{print $12}') ]
      if [[ $? -eq 1 ]]; then
       vararch=$(find $prov -maxdepth 1 -name *.tar.gz | grep _backup0) ; archivio=${vararch%%_*}"_backup.tar.gz" ; archivio=${archivio##*/}
       val=$(du -sh $prov | awk '{print$1}')
       testo="
cartella dove ripristinare:
$dest

cartella dell'archivio:
$prov

archivio da ripristinare:
$archivio
$val byte"
       zenity --question --height=400 --title="BACKUP INCREMENTALE" --text="$testo"
       if [ $? -eq 0 ] ; then
        count=0 ; for i in $(find $prov -maxdepth 1 -name *.tar.gz) ; do a=$(du -sb $i | awk '{print$1}') ; let count=count+a ; done
        for file in $( find $prov -maxdepth 1 -name *.tar.gz )
        do
         cd $prov
         (pv -n -s $count | tar xzv --listed-incremental=/dev/null --file ${file##*/} -C $dest) 2>&1 | zenity --progress --no-cancel --width=450 --height=120 --title="RIPRISTINO $archivio" --text="ripristino dell'archivio $file in esecuzione, attendere.."
        done
        zenity --notification --window-icon="info" --text="ripristino eseguito con successo."
       else
        zenity --notification --text="gestione backup terminata, ciao."
       fi
      else
       zenity --notification --window-icon="error" --text="ripristino non eseguito: spazio su disco non sufficiente."
      fi
     else
      zenity --notification --text="gestione backup terminata, ciao."
     fi
    fi
   ;;
  "" )
   zenity --notification --text="gestione backup terminata, ciao."
   ;;
  esac
  ;;
 "" )
  zenity --notification --text="gestione backup terminata, ciao."
  ;;
 "GESTIONE FILES" )
  file=$(zenity --file-selection --title="Seleziona il file da elimnare" 2> /dev/null)
  if [[ $? -eq 0 ]]; then
   [ zenity --question --height=400 --title="BACKUP INCREMENTALE" --text="eliminare $file?" ] && echo "" || (rm $file && zenity --notification --text="file '${file##*/}' eliminato.")
  else
   zenity --notification --text="gestione backup terminata, ciao."
  fi
  ;;
esac


exit 0

#info=on