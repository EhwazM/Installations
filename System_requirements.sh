#!/bin/bash
set -e

read -p "Do you need to connect to wi-fi? (y/n)" _YesNotWIFI

if [ "$_YesNotWIFI" = "y" ]; then
    read -p "Red Name:" _RedName
    read -p "password:" _RedPassword
    systemctl start --now NetworkManager.service
    nmcli device wifi connect $_RedName password $_RedPassword
fi

