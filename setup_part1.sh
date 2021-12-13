#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

apt update & apt upgrade -y
apt install cmake

## USRP setup?
if (whiptail --title "Using a USRP?" --yesno "Hit yes to install USRP support" 8 78); then
    # UHD
    apt install libuhd-dev libuhd3.15.0 uhd-host
    /usr/lib/uhd/utils/uhd_images_downloader.py
fi

## LimeSDR setup?
if (whiptail --title "Using a LimeSDR?" --yesno "Hit yes to install LimeSDR support" 8 78); then
    # SoapySDR
    cd SoapySDR
    mkdir build && cd build
    cmake ..
    make -j4
    make install
    ldconfig
    # LimeSuite
    apt install libusb-1.0-0-dev -y
    cd LimeSuite
    mkdir builddir && cd builddir
    cmake ../
    make -j4
    make install
    ldconfig
    cd ..
    cd udev-rules
    ./install.sh
fi

## srsRAN
apt install libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev -y
cd srsRAN
mkdir build && cd build
cmake ../
make -j4
make install
ldconfig
# copy default srsRAN configs to /root
./srslte_install_configs.sh user


## Governor
systemctl disable ondemand
apt install linux-tools-raspi
echo GOVERNOR="performance" >> /etc/default/cpufrequtils

## Overclock
if (whiptail --title "Do you want to overclock your Pi4 to 2GHz?" --yesno "Only do this if you have a heatsink. This script will edit boot configs for 'Ubuntu Pi' and 'Raspberry Pi OS'. If you are running a different distro you will need to run this manually." 8 78); >
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        echo "found Ubuntu, setting overclock config in /boot/firmware/config.txt"
        echo -e "\nover_voltage=6\narm_freq=2000" >> /boot/firmware/config.txt
    fi
    if [[ "$ID" == "raspbian" ]]; then
        echo "found Raspberry Pi OS, setting overclock config in /boot/config.txt"
        echo -e "\nover_voltage=6\narm_freq=2000" >> /boot/config.txt
    fi
fi

echo "Setup part 1 complete! Reboot your Pi now."