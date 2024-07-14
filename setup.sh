#!/bin/bash

echo "

██████╗ ███████╗██╗   ██╗████████╗                  
██╔══██╗██╔════╝╚██╗ ██╔╝╚══██╔══╝                  
██████╔╝███████╗ ╚████╔╝    ██║                     
██╔═══╝ ╚════██║  ╚██╔╝     ██║                     
██║     ███████║   ██║      ██║                     
╚═╝     ╚══════╝   ╚═╝      ╚═╝                     
                                                    
██╗  ██╗ ██████╗ ███████╗███╗   ██╗ ██████╗ ███████╗
██║ ██╔╝██╔═══██╗██╔════╝████╗  ██║██╔═══██╗██╔════╝
█████╔╝ ██║   ██║█████╗  ██╔██╗ ██║██║   ██║███████╗
██╔═██╗ ██║   ██║██╔═��╝  ██║╚██╗██║██║   ██║╚════██║
██║  ██╗╚██████╔╝███████╗██║ ╚████║╚██████╔╝███████║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
                                                    

"
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
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
	    ;;
        2)
            echo "Configuring KDE Plasma..."
            # Add KDE-specific configuration commands here
            # For example:
            kwriteconfig5 --file kdeglobals --group General --key ColorScheme 'BreezeDark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r 
            systemctl enable sddm
            ;;
        3)
            echo "Configuring XFCE..."
            # Add XFCE-specific configuration commands here
            # For example:
            xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird-dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
            ;;
        4)
            echo "Configuring Cinnamon..."
            # Add Cinnamon-specific configuration commands here
            # For example:
            gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
            ;;
        5)
            echo "Configuring MATE..."
            # Add MATE-specific configuration commands here
            # For example:
            gsettings set org.mate.interface gtk-theme 'Ambiant-MATE-Dark'
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
            ;;
        6)
            echo "Configuring LXDE..."
            # Add LXDE-specific configuration commands here
            # For example:
            sed -i 's/window_manager=.*/window_manager=openbox/' ~/.config/lxsession/LXDE/desktop.conf
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
            ;;
        7)
            echo "Configuring LXQt..."
            # Add LXQt-specific configuration commands here
            # For example:
            lxqt-config-appearance --set-widget-style Fusion
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
            ;;
	8)
	        echo "Configuring Budgie..."
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes
            mkdir ~/.wallpaper
	        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
            gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
            gsettings set org.gnome.desktop.interface cursor-theme 'Breeze'
            gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita-dark'
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
	        ;;
	    9)
	        echo "Configuring i3wm"
	        mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3 ~/.config -r
            mkdir ~/.themes
	        cp ~/koenos-archlinux/themes/* ~/.themes -r
            mkdir ~/.wallpaper
	        git clone https://github.com/PhoenixStarYT/koenos-wallpapers.git ~/.wallpaper
            mkdir ~/.config
            cp ~/koenos-archlinux/dotconfig-i3/* ~/.config -r
            systemctl enable sddm
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Function to configure kitty as the default terminal
configure_kitty_as_default() {
    echo "Setting kitty as the default terminal emulator..."
    
    # For GNOME-based environments
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
        gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
    fi

    # For KDE-based environments
    if command -v update-alternatives &> /dev/null; then
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
        sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty
    fi

    # For XFCE
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -s kitty -a
        xfconf-query -c xfce4-session -p /sessions/Failsafe/Client1_Command -t string -s "--login"
    fi

    # For other environments (LXDE, LXQt, etc.)
    if [ -f ~/.config/lxsession/LXDE/autostart ]; then
        echo "@kitty" >> ~/.config/lxsession/LXDE/autostart
    fi

    # For i3
    if [ -d ~/.config/i3 ]; then
        echo 'bindsym $mod+Return exec kitty' >> ~/.config/i3/config
    fi

    # For bspwm
    if [ -d ~/.config/bspwm ]; then
        echo 'super + Return
	kitty' >> ~/.config/sxhkd/sxhkdrc
    fi

    # For Openbox
    if [ -d ~/.config/openbox ]; then
        if [ ! -f ~/.config/openbox/autostart ]; then
            touch ~/.config/openbox/autostart
        fi
        echo 'kitty & disown' >> ~/.config/openbox/autostart
    fi
}
# Function to install the chosen desktop environment
install_desktop_environment() {
    case $1 in
        1)
            echo "Installing GNOME..."
            sudo pacman -S gnome gnome-extra firefox variety breeze kitty sddm
            configure_desktop_environment 1
            ;;
        2)
            echo "Installing KDE Plasma..."
            sudo pacman -S plasma kde-applications firefox variety breeze kitty sddm
            configure_desktop_environment 2
            ;;
        3)
            echo "Installing XFCE..."
            sudo pacman -S xfce4 xfce4-goodies firefox variety breeze kitty sddm
            configure_desktop_environment 3
            ;;
        4)
            echo "Installing Cinnamon..."
            sudo pacman -S cinnamon firefox variety breeze kitty sddm
            configure_desktop_environment 4
            ;;
        5)
            echo "Installing MATE..."
            sudo pacman -S mate mate-extra firefox variety breeze kitty sddm
            configure_desktop_environment 5
            ;;
        6)
            echo "Installing LXDE..."
            sudo pacman -S lxde firefox variety breeze kitty sddm
            configure_desktop_environment 6
            ;;
        7)
            echo "Installing LXQt..."
            sudo pacman -S lxqt firefox variety breeze kitty sddm
            configure_desktop_environment 7
            ;;
	8)
	    echo "Installing Budgie"
	    sudo pacman -S budgie firefox variety breeze kitty sddm
	    configure_desktop_environment 8
	    ;;
	9)
	    echo "Installing Window Managers"
	    sudo pacman -S vim unzip picom bspwm i3 awesome openbox polybar lxsession lxpanel sddm rofi kitty terminator thunar flameshot fastfetch sxhkd git lxpolkit lxappearance xorg firefox pulseaudio pavucontrol tar papirus-icon-theme nitrogen lxappearance breeze fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 variety
	    configure_desktop_environment 9
	    ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Function to install the chosen office suite
install_office_suite() {
    clear
    echo "Choose an office suite to install:"
    echo "1. LibreOffice"
    echo "2. OnlyOffice"
    echo "3. WPS Office"
    echo "4. Calligra Suite"
    echo "5. SoftMaker Office"
    echo "6. Skip installation"

    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1)
            echo "Installing LibreOffice..."
            sudo pacman -S --noconfirm libreoffice-fresh
            ;;
        2)
            echo "Installing OnlyOffice..."
            $AUR_HELPER -S --noconfirm onlyoffice-desktopeditors-bin
            ;;
        3)
            echo "Installing WPS Office..."
            $AUR_HELPER -S --noconfirm wps-office
            ;;
        4)
            echo "Installing Calligra Suite..."
            sudo pacman -S --noconfirm calligra
            ;;
        5)
            echo "Installing SoftMaker Office..."
            $AUR_HELPER -S --noconfirm softmaker-office
            ;;
        6)
            echo "Skipping office suite installation."
            ;;
        *)
            echo "Invalid choice. Please enter a number from 1 to 6."
            install_office_suite
            ;;
    esac
}

# Function to install gaming-related software
install_gaming_software() {
    read -p "Do you want to install gaming-related software? (y/n): " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        PS3="Select an option (enter the number): "
        options=("Steam" "Lutris" "Wine" "Libretro" "All" "None")
        select opt in "${options[@]}"; do
            case $opt in
                "Steam")
                    install_steam
                    break
                    ;;
                "Lutris")
                    install_lutris
                    break
                    ;;
                "Wine")
                    install_wine
                    break
                    ;;
                "Libretro")
                    install_libretro
                    break
                    ;;
                "All")
                    install_steam
                    install_lutris
                    install_wine
                    install_libretro
                    break
                    ;;
                "None")
                    echo "Skipping installation."
                    break
                    ;;
                *)
                    echo "Invalid option. Please select again."
                    ;;
            esac
        done
    else
        echo "Skipping installation of gaming-related software."
    fi
}

# Main script starts here
detect_aur_helper

# Choose and install the desktop environment
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

# Install office suite
install_office_suite

# Install gaming-related software
install_gaming_software

echo "Installation complete."

# Function to detect available AUR helper
detect_aur_helper() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    elif command -v trizen &>/dev/null; then
        AUR_HELPER="trizen"
    elif command -v yay-bin &>/dev/null; then
        AUR_HELPER="yay-bin"
    else
        echo "Error: No supported AUR helper found. Please install yay, paru, trizen, or yay-bin."
        exit 1
    fi
}

# Function to install additional packages (Add more that you would like to have on your system)
install_additional_packages() {
    echo "Installing additional packages..."

    # Install fastfetch
    sudo pacman -S --noconfirm fastfetch

    # Install ranger
    sudo pacman -S --noconfirm ranger

    # Install htop
    sudo pacman -S --noconfirm htop

    # Install cmatrix
    sudo pacman -S --noconfirm cmatrix

    echo "Additional packages installed."
}

# Call the function to install additional packages
install_additional_packages

# Install themes
mkdir ~/.themes
mkdir ~/.icons
git clone https://github.com/PhoenixStarYT/KoenOS-Themes ~
cp ~/KoenOS-Themes/themes ~/.themes -r
cp ~/KoenOS-Themes/icons ~/.icons -r

echo "Desktop installed"
echo "

███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
╚════██║  ╚██╔╝  ��════██║   ██║   ██╔══╝  ██║╚██╔╝██║
███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
                                                     
██████╗ ███████╗ █████╗ ██████╗ ██╗   ██╗            
██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝            
██████╔╝█████╗  ███████║██║  ██║ ╚████╔╝             
██╔══██╗██╔══╝  ██╔══██║██║  ██║  ╚██╔╝              
██║  ██║███████╗██║  ██║██████╔╝   ██║               
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝               
                                                     

"

GREEN="\e[32m"
RESET="\e[0m"

echo -e "${GREEN}Reboot your system to see the final results${RESET}"