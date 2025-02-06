#!/bin/bash
set -e

read -p "Do you need to connect to wi-fi? (y/n)" _YesNotWIFI

if [ "$_YesNotWIFI" = "y" ]; then
    read -p "Red Name:" _RedName
    read -p "password:" _RedPassword
    systemctl start --now NetworkManager.service
    nmcli device wifi connect $_RedName password $_RedPassword
fi

git clone https://github.com/EhwazM/EhwazM-dotfiles
cd EhwazM-dotfiles
ls -lah
stow .
cd ~

#Install video drivers:
sudo pacman -S --needed xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon vulkan-tools mesa lib32-mesa libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vdpauinfo clinfo
#Install audio drivers:
sudo pacman -S --needed pipewire pipewire-audio gst-plugin-pipewire pipewire-alsa pipewire-jack pipewire-pulse pipewire-roc wireplumber realtime-privileges

#If you want to use Hyprland:
sudo pacman -S hyprland brightnessctl pavucontrol waybar rofi-wayland cliphist sddm ranger ttf-nerd-fonts-symbols ttf-font-awesome breeze breeze-gtk gnome-keyring nwg-look qt6ct grim slurp xdg-desktop-portal-hyprland wev
