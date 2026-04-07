#!/bin/bash
set -euo pipefail

# --- FORCE TERMINAL (for double-click) ---
if [[ -z "${TERM:-}" ]]; then
    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal -- bash "$0" "$@"
    elif command -v xfce4-terminal &>/dev/null; then
        xfce4-terminal -e "bash $0 $*"
    else
        echo "Terminal non détecté. Exécutez depuis un terminal."
        exit 1
    fi
    exit
fi

# --- DEPENDENCIES ---
# Ensure required commands exist: dd, sha256sum, blkdiscard, nvme
REQUIRED_CMDS=(dd sha256sum blkdiscard nvme)
MISSING_CMDS=()
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v $cmd &>/dev/null; then
        MISSING_CMDS+=("$cmd")
    fi
done

if [ ${#MISSING_CMDS[@]} -gt 0 ]; then
    echo -e "\e[33mInstallation des dépendances manquantes : ${MISSING_CMDS[*]}\e[0m"
    apt update
    apt install -y "${MISSING_CMDS[@]}"
fi

# --- REQUIRE ROOT ---
if [[ $EUID -ne 0 ]]; then
    echo -e "\e[31mErreur: Exécutez en ROOT.\e[0m"
    read -p "Appuyez sur Entrée pour quitter..."
    exit 1
fi

# --- PARSE ARGUMENTS ---
SELECTED_DISKS=""
MODE="interactive"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --disk)
            SELECTED_DISKS+="$2 "
            MODE="cli"
            shift
            ;;
        --all)
            MODE="all"
            ;;
        *)
            echo "Argument inconnu: $1"
            exit 1
            ;;
    esac
    shift
done

# --- GET ROOT DISK (live USB detection) ---
ROOT_DISK=$(findmnt -no SOURCE / | sed 's/[0-9]*$//')

# --- INTERACTIVE MODE ---
if [[ "$MODE" == "interactive" ]]; then
    echo -e "\e[36m=== CONFIGURATION DE L'AUDIT ===\e[0m"
    read -p "Email pour identification (logs locaux) : " GPG_USER

    echo -e "\n\e[33m[DISQUES DISPONIBLES]\e[0m"

    mapfile -t DISK_LIST < <(lsblk -dno NAME,SIZE,ROTA,TYPE,MODEL | grep -v "loop" || true)

    echo "0) TOUS LES DISQUES (sauf OS live USB)"
    for i in "${!DISK_LIST[@]}"; do
        echo "$((i+1))) ${DISK_LIST[$i]}"
    done

    read -p "Sélectionnez le numéro du disque à effacer : " DISK_CHOICE

    if [[ "$DISK_CHOICE" -eq 0 ]]; then
        for DISK in $(lsblk -dno NAME | grep -v "loop"); do
            [[ "/dev/$DISK" == "$ROOT_DISK" ]] && continue
            SELECTED_DISKS+="/dev/$DISK "
        done
    else
        INDEX=$((DISK_CHOICE-1))
        DISK_NAME=$(echo "${DISK_LIST[$INDEX]}" | awk '{print $1}')
        SELECTED_DISKS="/dev/$DISK_NAME"
    fi
fi

# --- ALL MODE ---
if [[ "$MODE" == "all" ]]; then
    for DISK in $(lsblk -dno NAME | grep -v "loop"); do
        [[ "/dev/$DISK" == "$ROOT_DISK" ]] && continue
        SELECTED_DISKS+="/dev/$DISK "
    done
fi

# --- VALIDATION ---
if [[ -z "$SELECTED_DISKS" ]]; then
    echo "Aucun disque sélectionné."
    exit 1
fi

echo -e "\nDisques sélectionnés : $SELECTED_DISKS"

read -p "Tapez ERASE pour confirmer : " CONFIRM
if [[ "$CONFIRM" != "ERASE" ]]; then
    echo "Annulé."
    exit 0
fi

# --- WIPE HDD ---
wipe_hdd() {
    local DISK="$1"
    local SIZE=$(blockdev --getsize64 "$DISK")

    for PASS in 1 2 3; do
        echo -e "\n-- Passe $PASS --"

        INPUT="/dev/urandom"
        [[ $PASS -eq 3 ]] && INPUT="/dev/zero"

        echo "Effacement en cours... (passe $PASS)"
        dd if="$INPUT" of="$DISK" bs=4M status=progress conv=notrunc

        echo "Passe $PASS terminée."
    done

    echo "Vérification SHA256..."
    HASH=$(dd if="$DISK" bs=4M status=none | sha256sum | awk '{print $1}')
    echo "SHA256: $HASH"
}

# --- WIPE SSD/NVMe ---
wipe_nvme() {
    local DISK="$1"
    if command -v nvme &>/dev/null; then
        echo "Format NVMe via nvme-cli..."
        nvme format "$DISK" --ses=2 --force || nvme format "$DISK" --ses=1 --force
    else
        echo "Utilisation de blkdiscard..."
        blkdiscard "$DISK" || echo "Échec blkdiscard (vérifiez support matériel)"
    fi
}

# --- MAIN LOOP ---
for DISK in $SELECTED_DISKS; do
    echo -e "\nTraitement de $DISK"

    ROTA=$(lsblk -dno ROTA "$DISK")

    if [[ "$DISK" == *nvme* ]] || [[ "$ROTA" -eq 0 ]]; then
        wipe_nvme "$DISK"
    else
        wipe_hdd "$DISK"
    fi
done

echo -e "\n--- TERMINÉ ---"
read -p "Appuyez sur Entrée pour quitter..."
