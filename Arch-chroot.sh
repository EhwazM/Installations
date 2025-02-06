nvim /etc/locale.gen
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

nvim /etc/hosts
# echo 
#     127.0.0.1     localhost
#
#     ::1           localhost
#
#     127.0.1.1     $_PCName.localdomain $PCName > /etc/hosts
#
# passwd

read -p "User Name:" _UserName
useradd -m -g users -G wheel -s /bin/bash $_UserName
passwd $_UserName

nvim /etc/sudoers

pacman -S dhcp dhcpcd networkmanager iwd bluez bluez-utils
systemctl enable dhcpcd NetworkManager
systemctl enable bluetooth

pacman -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable

nvim /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

nvim /etc/pacman.conf
pacman -Syu

pacman -S xdg-user-dirs
xdg-user-dirs-update
su $_UserName -c "xdg-user-dirs-update"
