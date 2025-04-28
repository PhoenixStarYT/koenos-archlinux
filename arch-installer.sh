#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Install required packages for the installer
pacman -S --noconfirm dialog git base-devel

# Function to get user input with dialog
get_user_input() {
    local prompt="$1"
    local default="$2"
    local result
    dialog --inputbox "$prompt" 10 60 "$default" 2> /tmp/input
    result=$(cat /tmp/input)
    rm /tmp/input
    echo "$result"
}

# Function to show menu and get selection
show_menu() {
    local title="$1"
    local message="$2"
    shift 2
    local options=("$@")
    local result
    dialog --menu "$title" 20 60 10 "${options[@]}" 2> /tmp/selection
    result=$(cat /tmp/selection)
    rm /tmp/selection
    echo "$result"
}

# Function to show checklist and get selections
show_checklist() {
    local title="$1"
    local message="$2"
    shift 2
    local options=("$@")
    local result
    dialog --checklist "$title" 20 60 10 "${options[@]}" 2> /tmp/checklist
    result=$(cat /tmp/checklist)
    rm /tmp/checklist
    echo "$result"
}

# Function to show yes/no dialog
show_yesno() {
    local title="$1"
    local message="$2"
    dialog --yesno "$title" 10 60
    return $?
}

# Get basic system information
HOSTNAME=$(get_user_input "Enter hostname:" "archlinux")
USERNAME=$(get_user_input "Enter username:" "archuser")
USER_PASSWORD=$(get_user_input "Enter user password:" "" --insecure)
ROOT_PASSWORD=$(get_user_input "Enter root password (Leave empty to disable root password):" "" --insecure)

# Choose AUR helper
AUR_HELPER_OPTIONS=(
    "1" "yay - Popular and well-maintained"
    "2" "paru - Written in Rust, very fast"
    "3" "trizen - Lightweight and simple"
    "4" "aura - Written in Rust, secure"
    "5" "pikaur - Written in Python, user-friendly"
)

AUR_HELPER_CHOICE=$(show_menu "Choose AUR Helper" "Select your preferred AUR helper:" "${AUR_HELPER_OPTIONS[@]}")

case $AUR_HELPER_CHOICE in
    1) AUR_HELPER="yay";;
    2) AUR_HELPER="paru";;
    3) AUR_HELPER="trizen";;
    4) AUR_HELPER="aura";;
    5) AUR_HELPER="pikaur";;
esac

# Choose desktop environment
DE_OPTIONS=(
    "1" "GNOME - Modern and user-friendly"
    "2" "KDE Plasma - Highly customizable"
    "3" "XFCE - Lightweight and stable"
    "4" "Cinnamon - Beginner friendly desktop"
    "5" "MATE - Classic desktop experience"
    "6" "LXDE - Very lightweight"
    "7" "LXQt - Modern lightweight"
    "8" "Budgie - Elegant and simple"
    "9" "i3wm - Tiling window manager"
    "10" "openbox - Lightweight window manager"
    "11" "bspwm - Modern tiling window manager (Advanced)"
)

DE_CHOICE=$(show_menu "Choose Desktop Environment" "Select your preferred desktop environment:" "${DE_OPTIONS[@]}")

# Choose display manager
DM_OPTIONS=(
    "1" "SDDM - Modern and customizable"
    "2" "GDM - GNOME's display manager"
    "3" "LightDM - Lightweight and fast"
    "4" "LXDM - Lightweight display manager"
    "5" "XDM - Basic display manager"
)

DM_CHOICE=$(show_menu "Choose Display Manager" "Select your preferred display manager:" "${DM_OPTIONS[@]}")

# Choose office suite
OFFICE_OPTIONS=(
    "1" "LibreOffice - Full-featured office suite"
    "2" "OnlyOffice - Modern office suite"
    "3" "WPS Office - Microsoft Office compatible"
    "4" "None - Skip office suite installation"
)

OFFICE_CHOICE=$(show_menu "Choose Office Suite" "Select your preferred office suite:" "${OFFICE_OPTIONS[@]}")

# Choose gaming software
GAMING_OPTIONS=(
    "1" "Steam - Game platform and store"
    "2" "Lutris - Game manager"
    "3" "Wine - Windows compatibility layer"
    "4" "Libretro - Retro game emulation"
    "5" "Minecraft - Java Edition"
    "6" "All - Install everything"
    "7" "None - Skip gaming software"
)

GAMING_CHOICE=$(show_menu "Choose Gaming Software" "Select gaming software to install:" "${GAMING_OPTIONS[@]}")

# Choose multimedia tools
MULTIMEDIA_OPTIONS=(
    "1" "mpv - Video player"
    "2" "Clementine - Music player"
    "3" "Kodi - Media center"
    "4" "All - Install everything"
    "5" "None - Skip multimedia tools"
)

MULTIMEDIA_CHOICE=$(show_menu "Choose Multimedia Tools" "Select multimedia tools to install:" "${MULTIMEDIA_OPTIONS[@]}")

# Function to install AUR helper
install_aur_helper() {
    local helper=$1
    git clone "https://aur.archlinux.org/${helper}.git"
    cd "${helper}"
    makepkg -si --noconfirm
    cd ..
    rm -rf "${helper}"
}

# Function to install desktop environment
install_desktop_environment() {
    local de=$1
    case $de in
        1) # GNOME
            pacman -S --noconfirm gnome gnome-extra
            ;;
        2) # KDE Plasma
            pacman -S --noconfirm plasma kde-applications
            ;;
        3) # XFCE
            pacman -S --noconfirm xfce4 xfce4-goodies
            ;;
        4) # Cinnamon
            pacman -S --noconfirm cinnamon
            ;;
        5) # MATE
            pacman -S --noconfirm mate mate-extra
            ;;
        6) # LXDE
            pacman -S --noconfirm lxde
            ;;
        7) # LXQt
            pacman -S --noconfirm lxqt
            ;;
        8) # Budgie
            pacman -S --noconfirm budgie
            ;;
        9) # i3wm
            pacman -S --noconfirm i3
            ;;
        10) # openbox
            pacman -S --noconfirm openbox lxpanel
            ;;
        11) # bspwm
            pacman -S --noconfirm bspwm picom
            ;;
    esac
}

# Function to install display manager
install_display_manager() {
    local dm=$1
    case $dm in
        1) # SDDM
            pacman -S --noconfirm sddm
            systemctl enable sddm
            ;;
        2) # GDM
            pacman -S --noconfirm gdm
            systemctl enable gdm
            ;;
        3) # LightDM
            pacman -S --noconfirm lightdm lightdm-gtk-greeter
            systemctl enable lightdm
            ;;
        4) # LXDM
            pacman -S --noconfirm lxdm
            systemctl enable lxdm
            ;;
        5) # XDM
            pacman -S --noconfirm xdm
            systemctl enable xdm
            ;;
    esac
}

# Function to install office suite
install_office_suite() {
    local office=$1
    case $office in
        1) # LibreOffice
            pacman -S --noconfirm libreoffice-fresh
            ;;
        2) # OnlyOffice
            $AUR_HELPER -S --noconfirm onlyoffice-bin
            ;;
        3) # WPS Office
            $AUR_HELPER -S --noconfirm wps-office
            ;;
    esac
}

# Function to install gaming software
install_gaming_software() {
    local gaming=$1
    case $gaming in
        1) # Steam
            pacman -S --noconfirm steam steam-native-runtime
            ;;
        2) # Lutris
            pacman -S --noconfirm lutris
            ;;
        3) # Wine
            pacman -S --noconfirm wine winetricks
            ;;
        4) # Libretro
            pacman -S --noconfirm libretro-core-info libretro-common
            ;;
        5) # Minecraft
            pacman -S --noconfirm jdk-openjdk
            $AUR_HELPER -S --noconfirm minecraft-launcher
            ;;
        6) # All
            pacman -S --noconfirm steam steam-native-runtime lutris wine winetricks libretro-core-info libretro-common jdk-openjdk
            $AUR_HELPER -S --noconfirm minecraft-launcher
            ;;
    esac
}

# Function to install multimedia tools
install_multimedia_tools() {
    local multimedia=$1
    case $multimedia in
        1) # mpv
            pacman -S --noconfirm mpv
            ;;
        2) # Clementine
            pacman -S --noconfirm clementine
            ;;
        3) # Kodi
            pacman -S --noconfirm kodi kodi-addons
            ;;
        4) # All
            pacman -S --noconfirm mpv clementine kodi kodi-addons
            ;;
    esac
}

# Main installation process
dialog --infobox "Starting installation process..." 10 60
sleep 2

# Create user and set password
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd
echo "root:$ROOT_PASSWORD" | chpasswd

# Set hostname
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Install AUR helper
dialog --infobox "Installing AUR helper..." 10 60
install_aur_helper "$AUR_HELPER"

# Install desktop environment
dialog --infobox "Installing desktop environment..." 10 60
install_desktop_environment "$DE_CHOICE"

# Install display manager
dialog --infobox "Installing display manager..." 10 60
install_display_manager "$DM_CHOICE"

# Install office suite
if [ "$OFFICE_CHOICE" != "4" ]; then
    dialog --infobox "Installing office suite..." 10 60
    install_office_suite "$OFFICE_CHOICE"
fi

# Install gaming software
if [ "$GAMING_CHOICE" != "7" ]; then
    dialog --infobox "Installing gaming software..." 10 60
    install_gaming_software "$GAMING_CHOICE"
fi

# Install multimedia tools
if [ "$MULTIMEDIA_CHOICE" != "5" ]; then
    dialog --infobox "Installing multimedia tools..." 10 60
    install_multimedia_tools "$MULTIMEDIA_CHOICE"
fi

# Final message
dialog --msgbox "Installation complete! Please reboot your system to apply all changes." 10 60

# Reboot prompt
if show_yesno "Reboot" "Would you like to reboot now?"; then
    reboot
fi 