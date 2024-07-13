#!/bin/bash

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
	    ;;
        2)
            echo "Configuring KDE Plasma..."
            # Add KDE-specific configuration commands here
            # For example:
            kwriteconfig5 --file kdeglobals --group General --key ColorScheme 'BreezeDark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            ;;
        3)
            echo "Configuring XFCE..."
            # Add XFCE-specific configuration commands here
            # For example:
            xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird-dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            ;;
        4)
            echo "Configuring Cinnamon..."
            # Add Cinnamon-specific configuration commands here
            # For example:
            gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            ;;
        5)
            echo "Configuring MATE..."
            # Add MATE-specific configuration commands here
            # For example:
            gsettings set org.mate.interface gtk-theme 'Ambiant-MATE-Dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            ;;
        6)
            echo "Configuring LXDE..."
            # Add LXDE-specific configuration commands here
            # For example:
            sed -i 's/window_manager=.*/window_manager=openbox/' ~/.config/lxsession/LXDE/desktop.conf
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            ;;
        7)
            echo "Configuring LXQt..."
            # Add LXQt-specific configuration commands here
            # For example:
            lxqt-config-appearance --set-widget-style Fusion
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            ;;
	    8)
	        echo "Configuring Budgie..."
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
            gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
            gsettings set org.gnome.desktop.interface cursor-theme 'Breeze'
            gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita-dark'
	        ;;
	    9)
	        echo "Configuring i3wm"
	        mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3 ~/.config
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
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
            pacman -S gnome gnome-extra firefox variety breeze 
            configure_desktop_environment 1
            ;;
        2)
            echo "Installing KDE Plasma..."
            pacman -S plasma kde-applications firefox variety breeze 
            configure_desktop_environment 2
            ;;
        3)
            echo "Installing XFCE..."
            pacman -S xfce4 xfce4-goodies firefox variety breeze
            configure_desktop_environment 3
            ;;
        4)
            echo "Installing Cinnamon..."
            pacman -S cinnamon firefox variety breeze
            configure_desktop_environment 4
            ;;
        5)
            echo "Installing MATE..."
            pacman -S mate mate-extra firefox variety breeze 
            configure_desktop_environment 5
            ;;
        6)
            echo "Installing LXDE..."
            pacman -S lxde firefox variety breeze
            configure_desktop_environment 6
            ;;
        7)
            echo "Installing LXQt..."
            pacman -S lxqt firefox variety breeze
            configure_desktop_environment 7
            ;;
	8)
	    echo "Installing Budgie"
	    pacman -S budgie firefox variety breeze
	    configure_desktop_environment 8
	    ;;
	9)
	    echo "Installing i3wm"
	    pacman -S vim unzip picom bspwm awesome openbox polybar lxsession lxpanel lightdm rofi kitty terminator thunar flameshot neofetch sxhkd git lxpolkit lxappearance xorg firefox-esr pulseaudio pavucontrol tar papirus-icon-theme nitrogen lxappearance breeze fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 variety
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

