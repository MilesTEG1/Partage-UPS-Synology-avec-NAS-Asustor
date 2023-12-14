#!/bin/sh
# Script de modification du fichier /etc/ups/upsmon.conf avec backup des fichiers contenus dans /etc/ups
# Faire un :
# chmod +x Share_Synology_UPS_with_Asustor.sh

# Pour que les modifications soient effectuées à chaque redémarrage, il faut faire un lien dans /usr/local/etc/init.d/
#
# ln -s /share/docker/_scripts/Share_Synology_UPS_with_Asustor.sh /usr/local/etc/init.d/S84UPSpartageAvecSYNOLOGY
#
# init.d colle l'option 'start' à tout ce qui se nomme Sxxxx et 'stop' à tout ce qui se nomme 'Kxxx'

#####################################################
## Variables à modifier
    NOM_UPS_Syno="ups"
    IP_Syno_UPS="192.168.2.200"
    USER_UPS="monuser"
    USER_MDP_UPS="secret"

    DEST_BACKUP=/home/User-Admin/UPS-CONF-Backup
##
#####################################################

UPS_CONF_PATH=/etc/ups

CHAINE_FINALE="MONITOR $NOM_UPS_Syno@$IP_Syno_UPS 1 $USER_UPS $USER_MDP_UPS slave"

# # DEBUT DEBUG :
# UPS_CONF_PATH=/home/User-Admin
# printf "\nChaine finale = "
# echo $CHAINE_FINALE
printf "\n--- Début du fichier upsmon.conf non modifié ---\n"
cat $UPS_CONF_PATH/upsmon.conf
printf "\n--- Fin du fichier upsmon.conf non modifié ---\n"
# # FIN DEBUG

# Copie backup des fichiers du dossier UPS_CONF_PATH
mkdir -p $DEST_BACKUP
sudo cp "$UPS_CONF_PATH"/* "$DEST_BACKUP"

# Modification du fichier upsmon.conf pour utiliser en slave l'UPS branché en USB sur le Synology
sudo sed -i "2s/.*/${CHAINE_FINALE}/" $UPS_CONF_PATH/upsmon.conf

# DEBUT DEBUG :
printf "\n--- Début du fichier upsmon.conf MODIFIÉ ---\n"
cat $UPS_CONF_PATH/upsmon.conf
printf "\n--- Fin du fichier upsmon.conf MODIFIÉ ---\n"
# FIN DEBUG

# Commandes pour redémarrer le démon upsmon :
upsmon -c stop
upsmon
