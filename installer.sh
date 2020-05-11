#!/bin/bash

# A script to apply settings at https://github.com/joestandring/dotfiles and various other changes to a fresh Arch Linux install
# Joe Standring <git@joestandring.com>
# GNU GPLv3

echo -e "\e[31mChecking permissions...\e[0m"

if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root (e.g. using sudo)"
    exit
fi

echo -e "\e[31mUpdating and installing packages...\e[0m"

sudo pacman -Syu
sudo pacman -S git dbus neovim neofetch curl wget xorg-server xorg-xinit dunst networkmanager network-manager-applet networkmanager-openvpn python-pywal feh fontconfig libxinerama libx11 libxft ncurses zsh picom pulseaudio mpv newsboat transmission-cli make xdg-user-dirs zathura-pdf-poppler zsh-syntax-highlighting

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

yay --noconfirm -S lf nerd-fonts-hack python2-pynvim python-pynvim


echo -e "\e[31mCloning dotfiles...\e[0m"

git clone https://github.com/joestandring/dotfiles
mv dotfiles ~/.dot

echo -e "\e[31mMoving files...\e[0m"

cp ~/.dot/.zprofile ~
cp -r ~/.dot/.config ~

echo -e "\e[31mConfiguring services...\e[0m"

sudo systemctl stop dhcpcd
sudo systemctl disable dhcpcd
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable dbus
sudo systemctl start dbus

echo -e "\e[31mFirst time color setup...\n[0m"

wal -i ~/.dot/arch.png
~/.config/dunst/wal.sh

echo -e "\e[31mBuilding packages...\e[0m"

cd ~/.config/st || exit
sudo make clean install
cd ~/.config/dwm || exit
sudo make clean install
cd ~/.config/dmenu || exit
sudo make clean install

echo -e "\e[31mGetting scripts...\e[0m"

cd || exit
git clone https://github.com/joestandring/countdown
chmod +x ~/countdown/countdown.sh
sudo mv ~/countdown/countdown.sh /bin/countdown
rm -rf ~/countdown
git clone https://github.com/joestandring/dwm-bar
chmod +x ~/dwm-bar/dwm_bar.sh
sudo mkdir /bin/dwm-bar
sudo mv ~/dwm-bar/dwm_bar.sh /bin/dwm-bar/dwm-bar
sudo mv ~/dwm-bar/bar-functions /bin/dwm-bar/bar-functions
rm -rf ~/dwm-bar

echo -e "\e[31mConfiguring Neovim...\e[0m"

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PluginInstall +qall

echo -e "\e[31mChanging shells\e[0m"

chsh -s $(which zsh)
sudo chsh -s $(which zsh)
zsh

echo -e "\e[31mFinished!\nJust startx to jump right in\e[0m"
echo -e "Report bugs to https://github.com/joestandring/arch-config-installer"
