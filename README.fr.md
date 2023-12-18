[English](README.md) | French

# Utiliser un onduleur connecté à un NAS Synology (maître) avec un NAS Asustor (esclave) <!-- omit in toc -->

> **Objectif**<br>
> Utiliser, depuis un NAS Asustor, un onduleur en "slave" (UPS) qui est connecté en USB (donc en maître) sur un NAS Synology avec DSM 7.1.x, donc en maître sur le Synology.

<br>

> **Note**
> <br>
> Les commandes suivantes sont pour la plupart à lancer en root dans un terminal, pensez à faire un : `sudo -i`

<br> 

> **Warning**
> <br>Attention, pour que l'Asustor reçoive bien les instructions du serveur UPS, il est évident que toute chaine de transmission soit placée sur l'onduleur : le NAS Synology qui fait office de serveur UPS, l'éventuel switch auquel est connecté le(s) NAS, et le NAS Asustor.

<br>

> ***Sujet sur [forum-nas.fr](www.forum-nas.fr) :***
>   
> - [Utiliser un onduleur connecté à un NAS Synology (maître) avec un NAS Asustor (esclave)](https://www.forum-nas.fr/)
> <br> &nbsp;

<hr>

> **Note**
>  <br>Ce qui suit a été utilisé avec succès avec les NAS suivants :
>  - Asustor AS6704T sous ADM 4.2.0.RE71 
>  - Synology DS920+ sous DSM 7.1.1-42962 Update 4


<hr>

### Table des matières <!-- omit in toc -->

- [I. Configuration de l'UPS en esclave dans ADM](#i-configuration-de-lups-en-esclave-dans-adm)
  - [I.1. Ajout d'un UPS réseau](#i1-ajout-dun-ups-réseau)
  - [I.2. Configuration de la gestion d'alimentation dans ADM](#i2-configuration-de-la-gestion-dalimentation-dans-adm)
- [II. Configuration de l'UPS en maître dans DSM](#ii-configuration-de-lups-en-maître-dans-dsm)
- [III. Configuration en SSH de l'UPS en escalve dans les fichiers de configuration sur l'Asustor](#iii-configuration-en-ssh-de-lups-en-escalve-dans-les-fichiers-de-configuration-sur-lasustor)
  - [III.1. Création du script qui va s'occuper des modifications à faire et aussi de sauvegarder les fichiers de `/etc/ups/`](#iii1-création-du-script-qui-va-soccuper-des-modifications-à-faire-et-aussi-de-sauvegarder-les-fichiers-de-etcups)
  - [III.2. Explications du script et mise en route](#iii2-explications-du-script-et-mise-en-route)
    - [III.2.1. Quelques explications](#iii21-quelques-explications)
    - [III.2.2. Lancement manuel du script pour vérifier que tout se passe bien](#iii22-lancement-manuel-du-script-pour-vérifier-que-tout-se-passe-bien)
    - [III.2.3. Création d'un lien symbolique du script vers `/usr/local/etc/init.d/`](#iii23-création-dun-lien-symbolique-du-script-vers-usrlocaletcinitd)
- [IV. Inspirations pour réaliser ce tuto](#iv-inspirations-pour-réaliser-ce-tuto)

<hr>


## I. Configuration de l'UPS en esclave dans ADM

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

---

## II. Configuration de l'UPS en maître dans DSM

Dans DSM, il faut paramétrer le serveur UPS en maître pour l'onduleur connecté en USB.
Suivre les instructions de la capture suivante :

<img src="https://github.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/raw/main/images/5-DSM-Configuration-Alimentation-UPS.png" width="100%" >

L'Asustor pourra maintenant accéder à l'UPS connecté sur le Synology.

> **Note**
> <br>Il faudra aussi que le pare-feu du NAS autorise la connexion depuis l'IP de l'asustor sur le service de l'UPS. Au besoin, créer une règle dédiée.

---

## III. Configuration en SSH de l'UPS en escalve dans les fichiers de configuration sur l'Asustor

On attaque ici la partie un peu pénible, car il faut se connecter en SSH au NAS Asustor.

J'utilise ici mon compte administrateur `User-Admin` pour me connecter à l'asustor dont l'IP est `192.168.2.203` sur le port personnalisé `1234` (ces valeurs sont à changer par les vôtres !) :

```bash
ssh User-Admin@192.168.2.203 -p 1234
```

Le fichier à modifier est `/etc/ups/upsmon.conf`. Et ce fichier est réinitialisé à chaque reboot du NAS !

Il va donc falloir utiliser un script qu'on va faire lancer après chaque démarrage du NAS pour modifier ce fichier, et lancer les quelques commandes pour que ces modifications soient prises en compte.

### III.1. Création du script qui va s'occuper des modifications à faire et aussi de sauvegarder les fichiers de `/etc/ups/`

Il faut donc créer un script dans un dossier partagé. Moi j'ai choisi de placer mes différents scripts dans le dossier `/share/docker/_scripts/`. Si vous utiliser un autre emplacement, il faudra modifier en conséquence ce chemin d'accès.

Le script s'appelle `partage-UPS-Synology-avec-NAS-Asustor.sh`, il faudra le placer dans le dossier choisi, via ADM par exemple.
(Il est possible d'utiliser un éditeur en ligne de commande comme vi, ou nano (à installer avec opkg, après avoir installé le paquet Entware)).

Le script : [partage-UPS-Synology-avec-NAS-Asustor.sh](https://raw.githubusercontent.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/main/partage-UPS-Synology-avec-NAS-Asustor.sh)

<details>
  <summary>Clique ici pour afficher le script</summary>
  
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

</details>

### III.2. Explications du script et mise en route

#### III.2.1. Quelques explications

1. Le script va construire, grâce aux variables paramétrées précédemment, la ligne correcte qui va permettre au NAS Asustor de communiquer avec le serveur UPS sur le NAS Synology.
2. Le script va afficher le contenu du fichier qui sera modifié `/etc/ups/upsmon.conf`.
3. Ensuite, il va créer si besoin le dossier de destination de la sauvegarde `DEST_BACKUP`, puis copier le contenu du dossier `/etc/ups/` dans ce dossier `DEST_BACKUP`.
4. Ensuite, avec la commande `sed`, il va modifier uniquement la deuxième ligne du fichier `/etc/ups/upsmon.conf` pour passer de :
   
   ```EditorConfig
   MONITOR asustor@192.168.2.200 1 admin 1111 slave
   ```
   
   à :
   
   ```EditorConfig
   MONITOR ups@192.168.2.200 1 monuser secret slave
   ```
   
   *Les adresses IP seront certainement différentes.*
5. Puis, il affiche à nouveau le fichier `upsmon.conf` qui vient d'être modifié.
6. Et enfin, avec les commandes `upsmon -c stop` et `upsmon`, il va arrêter puis relancer le démon `upsmon` afin de prendre en compte les modifications faites dans le fichier `upsmon.conf`.

#### III.2.2. Lancement manuel du script pour vérifier que tout se passe bien

On va lancer manuellement le script pour être sûr que ce dernier modifie correctement le fichier de configuration.

On se place donc dans le dossier le contenant, et on fait en sorte qu'il puisse être exécuté :

```bash
chmod +x partage-UPS-Synology-avec-NAS-Asustor.sh
```

Puis on le lance :

```bash
./partage-UPS-Synology-avec-NAS-Asustor.sh
```

On devrait voir s'afficher le contenu du fichier avant la modification, puis après la modification, puis ceci :

```log
Network UPS Tools upsmon 2.7.2
kill: No such process
UPS: ups@192.168.2.200 (slave) (power value 1)
Using power down flag file /etc/killpower
```

Cela indique que `upsmon` a bien été connecté au serveur UPS du synology en mode slave.

Vous pouvez dès lors faire un crash test : couper l'alimentation électrique de l'onduleur branché au Synology.

> **Warning**
> <br>Attention, pour que l'Asustor reçoive bien les instructions du serveur UPS, il est évident que toute chaine de transmission soit placée sur l'onduleur : le NAS Synology qui fait office de serveur UPS, l'éventuel switch auquel est connecté le(s) NAS, et le NAS Asustor.

Si tout s'est bien passé, vous devriez pouvoir observer ce genre d'évènement dans les logs visibles dans "***System Information***" :

<img src="https://github.com/MilesTEG1/Partage-UPS-Synology-avec-NAS-Asustor/raw/main/images/6-ADM-System-Information-Log.png" width="100%" >

#### III.2.3. Création d'un lien symbolique du script vers `/usr/local/etc/init.d/`

Rappel : le script est placé dans le dossier choisi au [§-III.1.](#iii1-création-du-script-qui-va-soccuper-des-modifications-à-faire-et-aussi-de-sauvegarder-les-fichiers-de-etcups), pour ce qui me concerne c'est : `/share/docker/_scripts/`.

Il faut faire un lien symbolique vers `/usr/local/etc/init.d/` afin que le script soit lancé à chaque démarrage du NAS.

> **Important**
> <br>Le nom du lien a une grande importance, puisque s'il commence par `Sxxx` il sera lancé au démarrage, avec l'option `start` en paramètre (option dont on ne se servira pas, et donc pas testée dans le script). Si le lien commence par `Kxxx` il sera lancé à l'extinction du NAS, avec l'option `stop`, et nous n'avons pas besoin de script qui se lance à l'extinction pour l'onduleur.

Il faut donc lancer la commande suivante (pensez à adapter le chemin d'accès du script `/share/docker/_scripts/partage-UPS-Synology-avec-NAS-Asustor.sh` :

```bash
ln -s /share/docker/_scripts/partage-UPS-Synology-avec-NAS-Asustor.sh /usr/local/etc/init.d/S84UPSpartageAvecSYNOLOGY
```

Voilà, le lien est fait, il ne reste plus qu'à rebooter le NAS pour voir si le fichier est bien modifié après le reboot.

Utiliser la commande suivante pour vérifier si le fichier est bien modifié :

```shell
cat /etc/ups/upsmon.conf
```

---
---

## IV. Inspirations pour réaliser ce tuto

- [Network UPS Tools (NUT) Ultimate Guide #Linux NUT Client (remote)](https://docs.technotim.live/posts/NUT-server-guide/#linux-nut-client-remote)
- [Use Synology NAS as UPS Server to safely power down your other servers/computers](https://www.reddit.com/r/synology/comments/gtkjam/use_synology_nas_as_ups_server_to_safely_power/)
- [How To: Create a usable pool/volume to use as storage using NVMe(s) in the M.2 slots on the DS920+ (and others) running DSM 7 # Synology Server](https://kb.xnaas.info/en/public/synology/ups/#synology-server)
