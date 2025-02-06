#!/bin/bash
set -e

loadkeys us
timedatectl set-ntp true

read -p "Do you need to connect to wi-fi? (y/n)" _YesNotWIFI

if [ "$_YesNotWIFI" = "y" ]; then
    read -p "Red Name:" _RedName
    read -p "password:" _RedPassword
    iwctl --passphrase $_RedPassword station wlan0 connect $_RedName
fi

_PartitionsNames=0
while [ "$_PartitionsNames" -eq 0 ]; do
    echo "Name your partitions after you created them:"
    read -p "EFI: " _EFI
    read -p "SWAP: " _SWAP
    read -p "FS: " _FS
    echo "Are you sure this is correct? EFI=$_EFI, SWAP=$_SWAP, FS=$_FS. (y/n)"
    read _YesNot1
    
    if [ "$_YesNot1" = "y" ]; then
        echo "Partition names are set."
        _PartitionsNames=true
    elif [ "$_YesNot1" = "n" ]; then
        echo "Restarting the process."
        continue
    else
        echo "Invalid input, please try again."
    fi
done

# Formatting partitions
mkfs.fat -F32 -n "UEFI" /dev/$_EFI
mkswap -L "SWAP" /dev/$_SWAP
swapon /dev/$_SWAP

read -p "root name:" _RootName
mkfs.ext4 -L $_RootName /dev/$_FS

echo "Partitions formatting done."

# Mounting
mount /dev/$_FS /mnt/
mkdir -p /mnt/boot/efi/
mount /dev/$_EFI /mnt/boot/efi/

echo "Partitions mounting done."
read -p "Do you have Laptop?: (y/n)" _YesNot2

pacman -Sy

if [ "$_YesNot2" = "y" ]; then
    pacstrap /mnt git curl base base-devel neovim linux-zen linux-zen-headers linux-firmware mkinitcpio xf86-input-libinput
else
    pacstrap /mnt git curl base base-devel neovim linux-zen linux-zen-headers linux-firmware mkinitcpio
fi

genfstab -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

chmod +x Installations/Arch-chroot.sh
chmod +x Installations/System_requirements.sh

cp Installations/Arch-chroot.sh /mnt/

arch-chroot /mnt
