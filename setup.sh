#!/bin/bash

# Install AUR Helper

# Define the list of AUR helpers
AUR_HELPERS=("yay" "paru" "trizen" "aura" "pikaur")

# Function to display the list and let the user pick an AUR helper
choose_aur_helper() {
    echo "Available AUR helpers:"
    for i in "${!AUR_HELPERS[@]}"; do
        echo "$((i+1)). ${AUR_HELPERS[$i]}"
    done

    read -rp "Enter the number of the AUR helper you want to install: " choice
    if [[ $choice -gt 0 && $choice -le ${#AUR_HELPERS[@]} ]]; then
        echo "You chose: ${AUR_HELPERS[$((choice-1))]}"
        AUR_HELPER=${AUR_HELPERS[$((choice-1))]}
    else
        echo "Invalid choice. Please run the script again and select a valid option."
        exit 1
    fi
}

# Function to install the chosen AUR helper
install_aur_helper() {
    echo "Installing $AUR_HELPER..."
    git clone "https://aur.archlinux.org/${AUR_HELPER}.git" || { echo "Failed to clone the repository."; exit 1; }
    cd "$AUR_HELPER" || { echo "Failed to enter the directory."; exit 1; }
    makepkg -si || { echo "Failed to build and install $AUR_HELPER."; exit 1; }
    cd ..
    rm -rf "$AUR_HELPER"
    echo "$AUR_HELPER has been installed successfully."
}

# Check if the script is run as root
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be run as root. Please run it as a regular user."
    exit 1
fi

# Choose and install the AUR helper
choose_aur_helper
install_aur_helper

# Function to configure the chosen desktop environment
configure_desktop_environment() {
    case $1 in
        1)
            echo "Configuring GNOME..."
            # Add GNOME-specific configuration commands here
            # For example:
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper
	    ;;
        2)
            echo "Configuring KDE Plasma..."
            # Add KDE-specific configuration commands here
            # For example:
            kwriteconfig5 --file kdeglobals --group General --key ColorScheme 'BreezeDark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            ;;
        3)
            echo "Configuring XFCE..."
            # Add XFCE-specific configuration commands here
            # For example:
            xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird-dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            ;;
        4)
            echo "Configuring Cinnamon..."
            # Add Cinnamon-specific configuration commands here
            # For example:
            gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            ;;
        5)
            echo "Configuring MATE..."
            # Add MATE-specific configuration commands here
            # For example:
            gsettings set org.mate.interface gtk-theme 'Ambiant-MATE-Dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            ;;
        6)
            echo "Configuring LXDE..."
            # Add LXDE-specific configuration commands here
            # For example:
            sed -i 's/window_manager=.*/window_manager=openbox/' ~/.config/lxsession/LXDE/desktop.conf
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            ;;
        7)
            echo "Configuring LXQt..."
            # Add LXQt-specific configuration commands here
            # For example:
            lxqt-config-appearance --set-widget-style Fusion
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            ;;
	8)
	        echo "Configuring Budgie..."
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
            gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
            gsettings set org.gnome.desktop.interface cursor-theme 'Breeze'
            gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita-dark'

	        ;;
	    9)
	        echo "Configuring i3wm"
	        mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3 ~/.config -r
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes -r
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpaper ~/.wallpaper
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Function to install the chosen desktop environment
install_desktop_environment() {
    case $1 in
        1)
            echo "Installing GNOME..."
            sudo pacman -S gnome gnome-extra firefox variety breeze 
            configure_desktop_environment 1
            ;;
        2)
            echo "Installing KDE Plasma..."
            sudo pacman -S plasma kde-applications firefox variety breeze 
            configure_desktop_environment 2
            ;;
        3)
            echo "Installing XFCE..."
            sudo pacman -S xfce4 xfce4-goodies firefox variety breeze
            configure_desktop_environment 3
            ;;
        4)
            echo "Installing Cinnamon..."
            sudo pacman -S cinnamon firefox variety breeze
            configure_desktop_environment 4
            ;;
        5)
            echo "Installing MATE..."
            sudo pacman -S mate mate-extra firefox variety breeze 
            configure_desktop_environment 5
            ;;
        6)
            echo "Installing LXDE..."
            sudo pacman -S lxde firefox variety breeze
            configure_desktop_environment 6
            ;;
        7)
            echo "Installing LXQt..."
            sudo pacman -S lxqt firefox variety breeze
            configure_desktop_environment 7
            ;;
	8)
	    echo "Installing Budgie"
	    sudo pacman -S budgie firefox variety breeze
	    configure_desktop_environment 8
	    ;;
	9)
	    echo "Installing i3wm"
	    sudo pacman -S vim unzip picom bspwm awesome openbox polybar lxsession lxpanel lightdm rofi kitty terminator thunar flameshot neofetch sxhkd git lxpolkit lxappearance xorg firefox-esr pulseaudio pavucontrol tar papirus-icon-theme nitrogen lxappearance breeze fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 variety
	    configure_desktop_environment 9
	    ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Menu options
PS3='Please enter your choice: '
options=("GNOME" "KDE Plasma" "XFCE" "Cinnamon" "MATE" "LXDE" "LXQt" "Budgie" "Window Managers" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "GNOME")
            install_desktop_environment 1
            break
            ;;
        "KDE Plasma")
            install_desktop_environment 2
            break
            ;;
        "XFCE")
            install_desktop_environment 3
            break
            ;;
        "Cinnamon")
            install_desktop_environment 4
            break
            ;;
        "MATE")
            install_desktop_environment 5
            break
            ;;
        "LXDE")
            install_desktop_environment 6
            break
            ;;
        "LXQt")
            install_desktop_environment 7
            break
            ;;
        "Budgie")
	    install_desktop_environment 8
	    break
	    ;;
	"Window Managers")
	    install_desktop_environment 9
	    break
	    ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done

echo "Desktop installed"

