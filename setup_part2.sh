#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

## Copy tweaked eNB config
cp _config/enb.conf /root/.config/srsenb/enb.conf

## Load system services
apt install screen -y
cp _service/* /etc/systemd/system/
systemctl daemon reload

## Run ePC?
if (whiptail --title "Run local core?" --yesno "Hit yes to set up a local core" 8 78); >
    # EPC config
    if (whiptail --title "Edit the MME config" --yesno "Hit yes to edit the MME config. Make sure to set your MCC/MNC, and MME bind address)" 8 78); >
        nano /root/.config/srsenb/epc.conf
    fi
    # HSS config
    if (whiptail --title "Edit the HSS config" --yesno "Hit yes to edit the HSS config. Enter your SIM details following the example)" 8 7>
        nano /root/.config/srsenb/user_db.csv
    fi
    systemctl enable srsepc
    systemctl restart srsepc
fi

## eNB config
if (whiptail --title "Edit the eNB config" --yesno "Hit yes to edit the eNB config. Make sure to set your MCC/MNC, MME/GTP/S1AP bind addresses, and DL EARFCN (set to a channel you are legally permitted to broadcast on)" 8 78); >
    nano /root/.config/srsenb/enb.conf
fi
systemctl enable srsenb
systemctl restart srsenb
