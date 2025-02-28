#!/bin/bash
set -e

echo -e "Generating Locales... \n"
# nvim /etc/locale.gen
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen

# read -p "What locale did you choose?:" _LocaleGen
_LocaleGen="en_US.UTF-8"
echo LANG=$_LocaleGen > /etc/locale.conf
export LANG=$_LocaleGen

pacman -Sy --noconfirm

echo -e "Time Zone selection... \n"

ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc

echo -e "Setting Keymap and FONT... (us y Goha-14)\n"
# read -p "Keymap:" _KeyMap
_KeyMap="us"
echo KEYMAP=$_KeyMap >> /etc/vconsole.conf
echo "FONT=Goha-14" >> /etc/vconsole.conf

echo -e "Setting PC and User Config... \n"

while true; do
    read -p "PC Name:" _PCName
    read -p "Is '$_PCName' the correct name? (y/n):" _YesNotPC
    if [ "$_YesNotPC" = "y" ] || [ -z "$_YesNotPC" ]; then
        echo $_PCName > /etc/hostname
        break 
    fi
done

# nvim /etc/hosts
echo -e "\n127.0.0.1     localhost\n\n::1           localhost\n\n127.0.1.1     $_PCName.localdomain $_PCName" >> /etc/hosts

echo -e "\nSet root password:"
passwd

while true; do
    read -p "User Name:" _UserName
    read -p "Is '$_UserName' the correct name? (y/n):" _YesNotUN
    if [ "$_YesNotUN" = "y" ] || [ -z "$_YesNotUN" ]; then
        break 
    fi
done

useradd -m -g users -G wheel -s /bin/bash $_UserName
echo -e "\nSet $_UserName password"
passwd $_UserName

# nvim /etc/sudoers

sed -i "/root ALL=(ALL:ALL) ALL/a $_UserName ALL=(ALL:ALL) ALL" /etc/sudoers

echo -e "Installing internet packages...\n"

pacman -S --needed dhcp dhcpcd networkmanager iwd bluez bluez-utils
systemctl enable dhcpcd NetworkManager
systemctl enable bluetooth

echo -e "Installing and configuring Grub... \n"

pacman -S --needed grub efibootmgr os-prober --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable

# nvim /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"/' /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=false$/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

echo -e "Pacman Config. \n"
# nvim /etc/pacman.conf
sed -i 's/^#Color$/Color/' /etc/pacman.conf
sed -i 's/^#CheckSpace$/CheckSpace/' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 5/' /etc/pacman.conf

sed -i "/#DisableSandbox/a ILoveCandy" /etc/pacman.conf

sed -i 's/^#\[multilib\]$/[multilib]/' /etc/pacman.conf
sed -i '/^\[multilib\]/,/^$/ s|^#Include = /etc/pacman.d/mirrorlist$|Include = /etc/pacman.d/mirrorlist|' /etc/pacman.conf

pacman -Syu --noconfirm

echo -e "Setting Users directories. \n"
pacman -S --needed xdg-user-dirs --noconfirm
xdg-user-dirs-update
su $_UserName -c "xdg-user-dirs-update"

echo -e "Installing Misc. packages (fonts, browser, terminal...). \n"

pacman -S --needed gnu-free-fonts ttf-hack ttf-inconsolata noto-fonts-emoji fastfetch lsb-release git firefox kitty 

systemctl enable fstrim.timer

sudo -u "$_UserName" git clone https://github.com/EhwazM/Installations.git /home/"$_UserName"/Installations
chmod +x /home/"$_UserName"/Installations/System_requirements.sh

echo "you should umount everything with umount -R /mnt"

exit
