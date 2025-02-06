#!/bin/bash
set -e

# nvim /etc/locale.gen
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
read -p "What locale did you choose?:" _LocaleGen
echo LANG=$_LocaleGen > /etc/locale.conf
export LANG=$_LocaleGen

pacman -Sy

ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock -w

read -p "Kyemap:" _KeyMap
echo KEYMAP=$_KeyMap > /etc/vconsole.conf

read -p "PC Name:" _PCName
echo $_PCName > /etc/hostname

# nvim /etc/hosts
echo "
127.0.0.1     localhost

::1           localhost

127.0.1.1     $_PCName.localdomain $_PCName" >> /etc/hosts


echo "Set root password:"
passwd

read -p "User Name:" _UserName
useradd -m -g users -G wheel -s /bin/bash $_UserName
echo "Set $_UserName password"
passwd $_UserName

# nvim /etc/sudoers

sed -i "/root ALL=(ALL:ALL) ALL/a $_UserName ALL=(ALL:ALL) ALL" /etc/sudoers

pacman -S dhcp dhcpcd networkmanager iwd bluez bluez-utils
systemctl enable dhcpcd NetworkManager
systemctl enable bluetooth

pacman -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable

# nvim /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"/' /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=false$/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

# nvim /etc/pacman.conf
sed -i 's/^#Color$/Color/' /etc/pacman.conf
sed -i 's/^#CheckSpace$/CheckSpace/' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 5/' /etc/pacman.conf

sed -i "/#DisableSandbox/a ILoveCandy" /etc/pacman.conf

sed -i 's/^#\[multilib\]$/[multilib]/' /etc/pacman.conf
sed -i 's|^#Include = /etc/pacman.d/mirrorlist$|Include = /etc/pacman.d/mirrorlist|' /etc/pacman.conf

pacman -Syu

pacman -S xdg-user-dirs stow
xdg-user-dirs-update
su $_UserName -c "xdg-user-dirs-update"

pacman -S gnu-free-fonts ttf-hack ttf-inconsolata noto-fonts-emoji fastfetch lsb-release git firefox kitty

echo "you should umount everything with umount -R /mnt"

exit
