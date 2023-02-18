# Utiliser un onduleur connecté à un NAS Synology (maître) avec un NAS Asustor (esclave) <!-- omit in toc -->

> **Objectif :**<br>
> Utiliser, depuis un NAS Asustor, un onduleur en "slave" (UPS) qui est connecté en USB sur un NAS Synology avec DSM 7.1.x, donc en maître sur le Synology.

> **Note :**<br>
> Les commandes suivantes sont pour la plupart à lancer en root dans un terminal, pensez à faire un : `sudo -i`

<br>

> ***Sujet sur [forum-nas.fr](www.forum-nas.fr) :***
>   
> - [Utiliser un onduleur connecté à un NAS Synology (maître) avec un NAS Asustor (esclave)](https://www.forum-nas.fr/)
> <br> &nbsp;

<hr>

### Table des matières <!-- omit in toc -->

- [I. Configuration de l'UPS dans ADM](#i-configuration-de-lups-dans-adm)
  - [I.1. Ajout d'un UPS réseau](#i1-ajout-dun-ups-réseau)
  - [I.2. Configuration de la gestion d'alimentation dans ADM](#i2-configuration-de-la-gestion-dalimentation-dans-adm)
- [II. Configuration en SSH de l'UPS dans les fichiers de configuration](#ii-configuration-en-ssh-de-lups-dans-les-fichiers-de-configuration)
  - [II.1. Création du script qui va s'occuper des modifications à faire et aussi de sauvegarder les fichiers de `/etc/ups/`](#ii1-création-du-script-qui-va-soccuper-des-modifications-à-faire-et-aussi-de-sauvegarder-les-fichiers-de-etcups)
  - [II.2. Explications du script et mise en route](#ii2-explications-du-script-et-mise-en-route)
  - [II.3. aaaaa](#ii3-aaaaa)
- [III. Inspirations pour réaliser ce tuto](#iii-inspirations-pour-réaliser-ce-tuto)

<hr>

## I. Configuration de l'UPS dans ADM

### I.1. Ajout d'un UPS réseau

Il faut commencer par ajouter une connexion à un serveur UPS dans ADM. Pour cela, il faut aller dans "***External Devices***", et configurer comme suit :

- Cocher la case "***Enable network UPS Support***" ;
- Choisir "***Network UPS Slave***" ;
- Entrer l'adresse IP du NAS Synology sur lequel est connecté en USB l'onduleur (UPS) ;

<img src="https://github.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/raw/main/images/1-ADM-External-Devices-1.png" width="100%" >

Il est possible de choisir une de ces deux options :
<img src="https://github.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/raw/main/images/1-ADM-External-Devices-1bis.png" width="50%" >

J'ai choisi d'utiliser le "***Safe-Mode***" ("*Mode sûr*" en français) 5 minutes car ça laisse 5 minutes avant que le NAS ne s'éteigne, car si c'est sur "Shutdown", le NAS lancera la procédure d’extinction dès qu'il recevra l’information de la coupure de courant.

Voilà [ce que dit l'aide en ligne de Asustor](https://www.asustor.com/fr/online/online_help?id=56) :

<img src="https://github.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/raw/main/images/2-ADM-External-Devices-Help.png" width="100%" >

Une fois les réglages faits/choisis, vous devriez obtenir quelque chose de ce style :

<img src="https://github.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/raw/main/images/3-ADM-External-Devices-2.png" width="100%" >

Il faut noter qu'on n'obtient pas d'informations ni sur le % de batterie de l'onduleur, ni sur la durée restante. Et même après avoir fini de suivre le tuto ce sera encore ainsi.
Je n'ai pas réussi à faire en sorte d'avoir ces informations dans ADM... Elles restent quand même visible dans DSM sur le Synology.

### I.2. Configuration de la gestion d'alimentation dans ADM

Il est recommandé de ne pas activer le "***EuP Mode***" :
<img src="https://github.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/raw/main/images/4-ADM-Settings-Hardware-Power.png" width="100%" >

Je préfère laisser le NAS reprendre son état d'avant la coupure de courant dès que ce dernier est restauré. Ainsi, si le NAS était allumé, quand le courant sera revenu, il redémarrera.

## II. Configuration en SSH de l'UPS dans les fichiers de configuration

On attaque ici la partie un peu pénible, car il faut se connecter en SSH au NAS.

J'utilise ici mon compte administrateur `User-Admin` pour me connecter à l'asustor dont l'IP est `192.168.2.203` sur le port personnalisé `1234` (ces valeurs sont à changer par les vôtres !) :

```bash
ssh User-Admin@192.168.2.203 -p 1234
```

Le fichier à modifier est `/etc/ups/upsmon.conf`. Et ce fichier est réinitialisé à chaque reboot du NAS !

Il va donc falloir utiliser un script qu'on va faire lancer après chaque démarrage du NAS pour modifier ce fichier, et lancer les quelques commandes pour que ces modifications soient prises en compte.

### II.1. Création du script qui va s'occuper des modifications à faire et aussi de sauvegarder les fichiers de `/etc/ups/`

Il faut donc créer un script dans un dossier partagé. Moi j'ai choisi de placer mes différents scripts dans le dossier `/share/docker/_scripts/`. Si vous utiliser un autre emplacement, il faudra modifier en conséquence ce chemin d'accès.

Le script s'appelle `partage-UPS-Synology-avec-NAS-Asustor.sh`, il faudra le placer dans le dossier choisi, via ADM par exemple.
(Il est possible d'utiliser un éditeur en ligne de commande comme vi, ou nano (à installer avec opkg, après avoir installé le paquet Entware)).

Le script : partage-UPS-Synology-avec-NAS-Asustor.sh

```bash
#!/bin/sh
# Script de modification du fichier /etc/ups/upsmon.conf avec backup des fichiers contenus dans /etc/ups
# Faire un :
# chmod +x partage-UPS-Synology-avec-NAS-Asustor.sh

# Pour que les modifications soient effectuées à chaque redémarrage, il faut faire un lien dans /usr/local/etc/init.d/
#
# ln -s /share/docker/_scripts/partage-UPS-Synology-avec-NAS-Asustor.sh /usr/local/etc/init.d/S84UPSpartageAvecSYNOLOGY
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
sudo cp "$UPS_CONF_PATH" $DEST_BACKUP

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
```

Il faudra modifier les variables suivantes pour les accorder avec votre configuration. Normalement pour un NAS Synology, seules les variables `IP_Syno_UPS` et `DEST_BACKUP` seront à modifier.

```bash
#####################################################
## Variables à modifier
    NOM_UPS_Syno="ups"
    IP_Syno_UPS="192.168.2.200"
    USER_UPS="monuser"
    USER_MDP_UPS="secret"

    DEST_BACKUP=/home/User-Admin/UPS-CONF-Backup
##
#####################################################
```



### II.2. Explications du script et mise en route

Une fois ce script placé dans le dossier choisi, pour ce qui me concerne c'est : `/share/docker/_scripts/`, il faut faire un lien symbolique vers `/usr/local/etc/init.d/` afin que le script soit lancé à chaque démarrage du NAS.

Le nom du lien a une grande importance, puisque s'il commence par `Sxxx` il sera lancé au démarrage, avec l'option `start` en paramètre (option dont on ne se servira pas, et donc pas testée dans le script). Si le lien commence par `Kxxx` il sera lancé à l'extinction du NAS, avec l'option `stop`, et nous n'avons pas besoin de script qui se lance à l'extinction pour l'onduleur.

Il faut donc lancer la commande suivante (pensez à adapter le chemin d'accès du script `/share/docker/_scripts/partage-UPS-Synology-avec-NAS-Asustor.sh` :

```bash
ln -s /share/docker/_scripts/partage-UPS-Synology-avec-NAS-Asustor.sh /usr/local/etc/init.d/S84UPSpartageAvecSYNOLOGY
```




On a ceci en retour :

```log
Network UPS Tools upsmon 2.7.2
```


### II.3. aaaaa

Une fois les fichiers modifiés (ou restaurés), on relance le démon :

```bash
upsmon
````

On a ceci en retour :

```log
Network UPS Tools upsmon 2.7.2
kill: No such process
UPS: ups@192.168.2.200 (slave) (power value 1)
Using power down flag file /etc/killpower
```


## III. Inspirations pour réaliser ce tuto

- [Network UPS Tools (NUT) Ultimate Guide #Linux NUT Client (remote)](https://docs.technotim.live/posts/NUT-server-guide/#linux-nut-client-remote)
- [Use Synology NAS as UPS Server to safely power down your other servers/computers](https://www.reddit.com/r/synology/comments/gtkjam/use_synology_nas_as_ups_server_to_safely_power/)
- [How To: Create a usable pool/volume to use as storage using NVMe(s) in the M.2 slots on the DS920+ (and others) running DSM 7 # Synology Server](https://kb.xnaas.info/en/public/synology/ups/#synology-server)