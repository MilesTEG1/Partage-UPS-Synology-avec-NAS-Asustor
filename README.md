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
  - [I.2. aaaaa](#i2-aaaaa)
- [II. Configuration en SSH de l'UPS dans les fichiers de configuration](#ii-configuration-en-ssh-de-lups-dans-les-fichiers-de-configuration)
  - [II.1. aaaaa](#ii1-aaaaa)
  - [II.2. aaaaa](#ii2-aaaaa)
- [III. Inspirations pour réaliser ce tuto](#iii-inspirations-pour-réaliser-ce-tuto)

<hr>


## I. Configuration de l'UPS dans ADM

### I.1. Ajout d'un UPS réseau

Il faut commencer par ajouter une connexion à un serveur UPS dans ADM. Pour cela, il faut aller dans "External Devices", et configurer comme suit :


### I.2. aaaaa


## II. Configuration en SSH de l'UPS dans les fichiers de configuration

### II.1. aaaaa

Il faut arrêter le démon `upsmon` avec la commande :

```bash
upsmon -c stop
```

On a ceci en retour :

```log
Network UPS Tools upsmon 2.7.2
```


### II.2. aaaaa

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