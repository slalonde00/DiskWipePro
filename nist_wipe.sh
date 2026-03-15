#!/bin/bash
# Vérification ROOT
[[ $EUID -ne 0 ]] && echo -e "\e[31mErreur: Exécutez en ROOT.\e[0m" && exit 1

# --- CONFIGURATION INTERACTIVE ---
echo -e "\e[36m=== CONFIGURATION DE L'AUDIT ===\e[0m"
read -p "Email pour identification (pour logs locaux) : " GPG_USER

# --- SÉLECTION DU DISQUE ---
echo -e "\n\e[33m[CHOIX DU DISQUE]\e[0m"
mapfile -t DISK_LIST < <(lsblk -dno NAME,SIZE,MODEL | grep -v "loop")

echo "0) TOUS LES DISQUES"
for i in "${!DISK_LIST[@]}"; do
    echo "$((i+1))) ${DISK_LIST[$i]}"
done

read -p "Sélectionnez le numéro du disque à traiter : " DISK_CHOICE

if [[ "$DISK_CHOICE" -eq 0 ]];
