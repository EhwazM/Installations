#!/bin/bash
set -e

read -p "Do you need to connect to wi-fi? (y/n)" _YesNotWIFI

if [ "$_YesNotWIFI" = "y" ]; then
    read -p "Red Name:" _RedName
    read -p "password:" _RedPassword
    nmcli device wifi connect "$_RedName" password "$_RedPassword"
fi

systemctl start --now NetworkManager.service

# Installing Stow and dotfiles
echo -e "Installing Stow and dotfiles... \n"

sudo pacman -S --needed stow rustup

if [ ! -d ~/EhwazM-dotfiles ]; then
    echo -e "Dotfiles are not in the system, cloning... \n"
    git clone https://github.com/EhwazM/EhwazM-dotfiles
fi

cd EhwazM-dotfiles 
ls -lah
stow .
cd ~

# Install video drivers:
echo -e "Installing video drivers (AMD)... \n"

sudo pacman -S --needed xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon vulkan-tools mesa lib32-mesa libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau vdpauinfo clinfo 

# Install audio drivers:
echo -e "Installing audio drivers (Pipewire)... \n"

sudo pacman -S --needed pipewire pipewire-audio gst-plugin-pipewire pipewire-alsa pipewire-jack pipewire-pulse pipewire-roc wireplumber realtime-privileges 

# Deciding WM or DE
echo -e "\nChoose either Hyprland or KDE Plasma:\n"
echo -e "1. Hyprland (default)"
echo -e "2. KDE Plasma"

while true; do
    read -p "Choose: " _Tiling
    if [ "$_Tiling" = "1" ] || [ -z "$_Tiling" ]; then
        echo -e "Installing tiling manager (Hyprland)... \n"
        sudo pacman -S --needed hyprland brightnessctl pavucontrol waybar rofi-wayland cliphist sddm ranger ttf-nerd-fonts-symbols ttf-font-awesome breeze breeze-gtk gnome-keyring nwg-look qt6ct grim slurp xdg-desktop-portal-hyprland wev
        break
    elif [ "$_Tiling" = "2" ]; then
        echo -e "Installing desktop Environment (KDE Plasma)... \n"
        sudo pacman -S plasma ark dolphin kdeconnect kwallet spectacle okular gthub plasma-workspace egl-wayland
        break
    fi
done
echo -e "Installing tiling manager (Hyprland)... \n"

sudo pacman -S --needed hyprland brightnessctl pavucontrol waybar rofi-wayland cliphist sddm ranger ttf-nerd-fonts-symbols ttf-font-awesome breeze breeze-gtk gnome-keyring nwg-look qt6ct grim slurp xdg-desktop-portal-hyprland wev 

# Installing Paru
echo -e "Updating rustup... \n"

rustup install stable
rustup default stable

echo -e "Installing Paru... \n"

cd ~
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ~

# Misc Packages
echo -e "Installing all the packages from the list (pkglist.txt)...\n"

paru -Syu
paru -S --needed `cat ~/Installations/pkglist.txt`

# Hyprsome
echo -e "Installing Hyprsome... \n"

git clone https://github.com/sopa0/hyprsome
cd hyprsome
cargo build
sudo cp target/debug/hyprsome /usr/local/bin
cd ~

#Sddm
echo -e "Configuring sddm... \n"

sudo systemctl enable sddm.service
# sed -i 's/^Current=$/Current=catpuccin-mocha/' /etc/sddm.conf.d
sudo sed -i 's/^Current=$/Current=catppuccin-mocha/' /usr/lib/sddm/sddm.conf.d/default.conf

# ZSH
echo -e "Configuring zsh... \n"
sudo pacman -S --needed zsh curl --noconfirm

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

read -p "User Name:" _UserName

chsh -s /bin/zsh "$_UserName"
sudo chsh -s /bin/zsh root

echo -e "\nInstalling Procces has been SUCCESFUL.\n"
