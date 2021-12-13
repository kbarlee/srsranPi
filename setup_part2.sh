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
if (whiptail --title "Run local core?" --yesno "Hit yes to set up a local core" 8 78); then 

    # EPC config
    if (whiptail --title "Edit the MME config" --yesno "Hit yes to edit the MME config. Make sure to set your MCC/MNC, and MME bind address)" 8 78); then

        nano /root/.config/srslte/epc.conf

    fi
    # HSS config
    if (whiptail --title "Edit the HSS config" --yesno "Hit yes to edit the HSS config. Enter your SIM details (following the included example)" 8 78); then

        nano /root/.config/srslte/user_db.csv

    fi
    systemctl enable srsepc
    systemctl restart srsepc
    systemctl status srsepc

    echo "*******************************************"
    echo " Core config files can be found at:"
    echo "   /root/.config/srslte/epc.conf"
    echo "   /root/.config/srslte/user_db.csv"
    echo " "
    echo " To stop/restart srsepc service, run:"
    echo "   sudo systemctl restart srsepc"
    echo "   sudo systemctl stop srsepc"
    echo "*******************************************"

fi

## eNB config
if (whiptail --title "Edit the eNB config" --yesno "Hit yes to edit the eNB config. Make sure to set your MCC/MNC, MME/GTP/S1AP bind addresses, and DL EARFCN (set to a channel you are legally permitted to broadcast on)" 8 78); then

    nano /root/.config/srslte/enb.conf

fi
systemctl enable srsenb
systemctl restart srsenb
systemctl status srsenb

echo "*******************************************"
echo " eNB config file can be found at:"
echo "   /root/.config/srslte/enb.conf"
echo " "
echo " To stop/restart srsenb service, run:"
echo "   sudo systemctl restart srsenb"
echo "   sudo systemctl stop srsenb"
echo " "
echo " To reconnect to active srsenb screen session, run:"
echo "   sudo screen -r ENB"
echo " "
echo " To detach from the screen session, use keyboard commands:"
echo "   CTRL + A + D"
echo " "
echo " Setup part 2 complete!"
echo "*******************************************"