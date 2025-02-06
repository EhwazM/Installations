#!/bin/bash
set -e

read -p "Do you need to connect to wi-fi? (y/n)" _YesNotWIFI

if [ "$_YesNotWIFI" = "y" ]; then
    read -p "Red Name:" _RedName
    read -p "password:" _RedPassword
    nmcli device wifi connect $_RedName password $_RedPassword
fi

systemctl start --now NetworkManager.service

# Installing Stow and dotfiles
if ! pacman -Qs stow; then
    echo "Installing zsh..."
    sudo pacman -S stow
fi

if [ -d "~/EhwazM-dotfiles" ]; then
    cd EhwazM-dotfiles
    ls -lah
    stow .
    cd ~
else
    git clone https://github.com/EhwazM/EhwazM-dotfiles
    cd EhwazM-dotfiles
    ls -lah
    stow .
    cd ~
fi

# Install video drivers:
sudo pacman -S --needed xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon vulkan-tools mesa lib32-mesa libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vdpauinfo clinfo
# Install audio drivers:
sudo pacman -S --needed pipewire pipewire-audio gst-plugin-pipewire pipewire-alsa pipewire-jack pipewire-pulse pipewire-roc wireplumber realtime-privileges

# If you want to use Hyprland:
sudo pacman -S hyprland brightnessctl pavucontrol waybar rofi-wayland cliphist sddm ranger ttf-nerd-fonts-symbols ttf-font-awesome breeze breeze-gtk gnome-keyring nwg-look qt6ct grim slurp xdg-desktop-portal-hyprland wev

# Installing Paru
cd ~
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ~

# Misc Packages
paru -Syu
paru -S --needed `cat ~/Installations/pkglist.txt`

# Hyprsome
git clone https://github.com/sopa0/hyprsome
cd hyprsome
cargo build
sudo cp target/debug/hyprsome /usr/local/bin
cd ~

#Sddm
sudo systemctl enable sddm.service

# ZSH
if ! pacman -Qs zsh; then
    echo "Installing zsh..."
    sudo pacman -S zsh
fi

if ! pacman -Qs curl; then
    echo "Installing curl..."
    sudo pacman -S curl
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

read -p "User Name:" _UserName

chsh -s /bin/zsh $_UserName
sudo chsh -s /bin/zsh root


