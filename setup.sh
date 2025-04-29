#!/bin/bash

# Function to display a welcome message with ASCII art
show_welcome() {
    clear
    echo "
███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
"
    echo "Welcome to the Post-Installation Setup Script"
    echo "This script will help you configure your Arch Linux system."
    echo "Press Enter to continue..."
    read
}

# Function to install and configure network
setup_network() {
    echo "Setting up network..."
    sudo pacman -S --noconfirm networkmanager
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
}

# Function to install and configure AUR helper
install_aur_helper() {
    echo "Installing AUR helper..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

# Function to install desktop environment
install_desktop_environment() {
    echo "Choose your desktop environment:"
    echo "1. GNOME"
    echo "2. KDE Plasma"
    echo "3. XFCE"
    echo "4. Cinnamon"
    echo "5. MATE"
    echo "6. LXDE"
    echo "7. LXQt"
    echo "8. Budgie"
    echo "9. i3wm"
    echo "10. openbox"
    echo "11. bspwm"
    
    read -rp "Enter your choice (1-11): " de_choice
    
    case $de_choice in
        1)
            sudo pacman -S --noconfirm gnome gnome-extra
            sudo systemctl enable gdm
            ;;
        2)
            sudo pacman -S --noconfirm plasma kde-applications
            sudo systemctl enable sddm
            ;;
        3)
            sudo pacman -S --noconfirm xfce4 xfce4-goodies
            sudo systemctl enable lightdm
            ;;
        4)
            sudo pacman -S --noconfirm cinnamon
            sudo systemctl enable lightdm
            ;;
        5)
            sudo pacman -S --noconfirm mate mate-extra
            sudo systemctl enable lightdm
            ;;
        6)
            sudo pacman -S --noconfirm lxde
            sudo systemctl enable lxdm
            ;;
        7)
            sudo pacman -S --noconfirm lxqt
            sudo systemctl enable sddm
            ;;
        8)
            sudo pacman -S --noconfirm budgie
            sudo systemctl enable lightdm
            ;;
        9)
            sudo pacman -S --noconfirm i3
            sudo systemctl enable lightdm
            ;;
        10)
            sudo pacman -S --noconfirm openbox
            sudo systemctl enable lightdm
            ;;
        11)
            sudo pacman -S --noconfirm bspwm sxhkd
            sudo systemctl enable lightdm
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install web browser
install_web_browser() {
    echo "Choose your web browser:"
    echo "1. Firefox"
    echo "2. Google Chrome"
    echo "3. Brave"
    echo "4. Vivaldi"
    
    read -rp "Enter your choice (1-4): " browser_choice
    
    case $browser_choice in
        1)
            sudo pacman -S --noconfirm firefox
            ;;
        2)
            yay -S --noconfirm google-chrome
            ;;
        3)
            yay -S --noconfirm brave-bin
            ;;
        4)
            yay -S --noconfirm vivaldi
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install office suite
install_office_suite() {
    echo "Choose your office suite:"
    echo "1. LibreOffice"
    echo "2. OnlyOffice"
    echo "3. WPS Office"
    echo "4. Skip"
    
    read -rp "Enter your choice (1-4): " office_choice
    
    case $office_choice in
        1)
            sudo pacman -S --noconfirm libreoffice-fresh
            ;;
        2)
            yay -S --noconfirm onlyoffice-bin
            ;;
        3)
            yay -S --noconfirm wps-office
            ;;
        4)
            echo "Skipping office suite installation"
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install gaming software
install_gaming_software() {
    echo "Do you want to install gaming software? (y/n)"
    read -rp "Enter your choice: " gaming_choice
    
    if [[ $gaming_choice =~ ^[Yy]$ ]]; then
        echo "Installing gaming software..."
        sudo pacman -S --noconfirm steam
        yay -S --noconfirm lutris
        sudo pacman -S --noconfirm wine winetricks
    fi
}

# Function to install multimedia software
install_multimedia() {
    echo "Do you want to install multimedia software? (y/n)"
    read -rp "Enter your choice: " multimedia_choice
    
    if [[ $multimedia_choice =~ ^[Yy]$ ]]; then
        echo "Installing multimedia software..."
        sudo pacman -S --noconfirm vlc mpv
        yay -S --noconfirm spotify
    fi
}

# Main function
main() {
    show_welcome
    setup_network
    install_aur_helper
    install_desktop_environment
    install_web_browser
    install_office_suite
    install_gaming_software
    install_multimedia
    
    echo "Setup complete! Please reboot your system."
    echo "Press Enter to reboot..."
    read
    sudo reboot
}

# Run the main function
main
