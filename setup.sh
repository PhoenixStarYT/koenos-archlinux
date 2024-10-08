#!/bin/bash

# Display a welcome message with ASCII art
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
██╔═██╗ ██║   ██║██╔     ██║╚██ ██║██║   ██║╚════██║
██║  ██╗╚██████╔╝███████╗██║ ╚████║╚██████╔╝███████║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
                                                    

"

# Define the list of AUR helpers
AUR_HELPERS=("yay" "paru" "trizen" "aura" "pikaur")

# Function to display the list and let the user pick an AUR helper
choose_aur_helper() {
    echo "Pick your AUR Helper here (Use this to install packages):"
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
    # Ensure git is installed
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Installing git..."
        sudo pacman -S --noconfirm git
    fi

    # Create wallpaper directory if it doesn't exist
    mkdir -p ~/.wallpaper

    # Clone wallpapers if not already cloned
    if [ ! -d ~/.wallpaper/koenos-wallpapers ]; then
        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper
    else
        echo "Wallpapers already cloned, skipping..."
    fi

    # Clone Nord background
    if [ ! -d ~/.wallpaper/nord-background ]; then
        git clone https://github.com/ChrisTitusTech/nord-background ~/.wallpaper
    else
        echo "Nord background already cloned, skipping..."
    fi

    # Install Firacode Nerd Fonts
    sudo pacman -S --noconfirm ttf-firacode-nerd

    # Clone Tela Circle Icons
    mkdir -p ~/.icons
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme ~/.icons/Tela-circle

    # Clone Nordic theme
    mkdir -p ~/.themes
    git clone https://github.com/EliverLara/Nordic ~/.themes/Nordic

    # Install Layan Cursors
    git clone https://github.com/vinceliuice/Layan-cursors ~/.icons/Layan-cursors

    # Install Breeze Cursors
    sudo pacman -S --noconfirm breeze

    # Configure the desktop environment based on the user's choice
    case $1 in
        1)  # GNOME
            echo "Configuring GNOME..."
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
            gsettings set org.gnome.desktop.interface font-name 'FiraCode Nerd Font 11'
            gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle'
            gsettings set org.gnome.desktop.interface cursor-theme 'breeze'
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm
            ;;
        2)  # KDE Plasma
            echo "Configuring KDE Plasma..."
            kwriteconfig5 --file kdeglobals --group General --key ColorScheme 'BreezeDark'
            kwriteconfig5 --file kdeglobals --group General --key font 'FiraCode Nerd Font,11,-1,5,50,0,0,0,0,0'
            kwriteconfig5 --file kdeglobals --group Icons --key Theme 'Tela-circle'
            kwriteconfig5 --file kdeglobals --group Cursors --key Theme 'breeze'
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm

            # Ensure qdbus is available
            if ! command -v qdbus &> /dev/null; then
                echo "qdbus could not be found, installing qt5-tools..."
                sudo pacman -S --noconfirm qt5-tools
            fi

            # Add widgets to KDE Plasma desktop
            echo "Adding widgets to KDE Plasma desktop..."
            plasmashell --replace &
            sleep 5  # Give plasmashell some time to start
            qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
            var desktop = desktops()[0];
            desktop.addWidget("org.kde.plasma.digitalclock");
            desktop.addWidget("org.kde.plasma.systemmonitor.cpu");
            desktop.addWidget("org.kde.plasma.systemmonitor.memory");
            desktop.addWidget("org.kde.plasma.systemmonitor.network");
            '
            ;;
        3)  # XFCE
            echo "Configuring XFCE..."
            xfconf-query -c xsettings -p /Net/ThemeName -s 'Nordic'
            xfconf-query -c xsettings -p /Net/IconThemeName -s 'Tela-circle'
            xfconf-query -c xsettings -p /Net/CursorThemeName -s 'breeze'
            xfconf-query -c xsettings -p /Gtk/FontName -s 'FiraCode Nerd Font 11'
            mkdir -p ~/.themes
            cp -r ~/koenos-archlinux/themes/* ~/.themes
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm
            ;;
        4)  # Cinnamon
            echo "Configuring Cinnamon..."
            gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark'
            gsettings set org.cinnamon.desktop.interface font-name 'FiraCode Nerd Font 11'
            gsettings set org.cinnamon.desktop.interface icon-theme 'Tela-circle'
            gsettings set org.cinnamon.desktop.interface cursor-theme 'breeze'
            mkdir -p ~/.themes
            cp -r ~/koenos-archlinux/themes/* ~/.themes
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm
            ;;
        5)  # MATE
            echo "Configuring MATE..."
            gsettings set org.mate.interface gtk-theme 'Ambiant-MATE-Dark'
            gsettings set org.mate.interface font-name 'FiraCode Nerd Font 11'
            gsettings set org.mate.interface icon-theme 'Tela-circle'
            gsettings set org.mate.interface cursor-theme 'breeze'
            mkdir -p ~/.themes
            cp -r ~/koenos-archlinux/themes/* ~/.themes
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm
            ;;
        6)  # LXDE
            echo "Configuring LXDE..."
            sed -i 's/window_manager=.*/window_manager=openbox/' ~/.config/lxsession/LXDE/desktop.conf
            echo 'xft: FiraCode Nerd Font 11' >> ~/.config/lxsession/LXDE/desktop.conf
            echo 'sNet/IconThemeName=Tela-circle' >> ~/.config/lxsession/LXDE/desktop.conf
            echo 'sNet/CursorThemeName=breeze' >> ~/.config/lxsession/LXDE/desktop.conf
            mkdir -p ~/.themes
            cp -r ~/koenos-archlinux/themes/* ~/.themes
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm
            ;;
        7)  # LXQt
            echo "Configuring LXQt..."
            lxqt-config-appearance --set-widget-style Fusion
            echo 'xft: FiraCode Nerd Font 11' >> ~/.config/lxqt/session.conf
            echo 'sNet/IconThemeName=Tela-circle' >> ~/.config/lxqt/session.conf
            echo 'sNet/CursorThemeName=breeze' >> ~/.config/lxqt/session.conf
            mkdir -p ~/.themes
            cp -r ~/koenos-archlinux/themes/* ~/.themes
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm
            ;;
        8)  # Budgie
            echo "Configuring Budgie..."
            mkdir -p ~/.themes
            cp -r ~/koenos-archlinux/themes/* ~/.themes
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
            gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle'
            gsettings set org.gnome.desktop.interface cursor-theme 'breeze'
            gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita-dark'
            gsettings set org.gnome.desktop.interface font-name 'FiraCode Nerd Font 11'
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config
            systemctl enable sddm
            ;;
        9)  # i3wm
            echo "Configuring i3wm"
            mkdir -p ~/.config
            cp -r ~/koenos-archlinux/dotconfig-i3 ~/.config
            mkdir -p ~/.themes
            cp -r ~/koenos-archlinux/themes/* ~/.themes
            echo 'font pango:FiraCode Nerd Font 11' >> ~/.config/i3/config
            echo 'bindsym $mod+Shift+i exec "feh --bg-scale ~/.wallpaper/your_wallpaper.jpg"' >> ~/.config/i3/config
            echo 'set_from_resource $theme Nordic' >> ~/.config/i3/config
            echo 'xsetroot -cursor_name breeze' >> ~/.config/i3/config
            # Set pcmanfm as the default file manager
            echo 'bindsym $mod+e exec pcmanfm' >> ~/.config/i3/config
            systemctl enable sddm
            ;;
        10)  # openbox
            echo "Configuring openbox..."
            git clone https://github.com/PhoenixStarYT/dotfiles-openbox-koenos ~
            echo 'theme = "Nordic"' >> ~/.config/openbox/rc.xml
            echo 'xsetroot -cursor_name breeze' >> ~/.config/openbox/rc.xml
            # Set pcmanfm as the default file manager
            echo 'pcmanfm & disown' >> ~/.config/openbox/autostart
            systemctl enable sddm
            ;;
        11)  # bspwm
            echo "Installing bspwm..."
            sudo pacman -S --noconfirm bspwm picom variety thunar polybar
            
            # Install FiraCode font
            echo "Installing FiraCode font..."
            sudo pacman -S --noconfirm ttf-firacode
            
            # Prompt user to choose between dmenu and rofi
            echo "Choose your application launcher:"
            echo "1. dmenu"
            echo "2. rofi"
            read -rp "Enter the number of your choice: " launcher_choice
            
            case $launcher_choice in
                1)
                    echo "Installing dmenu..."
                    sudo pacman -S --noconfirm dmenu
                    ;;
                2)
                    echo "Installing rofi..."
                    sudo pacman -S --noconfirm rofi
                    ;;
                *)
                    echo "Invalid choice. Skipping installation of application launcher."
                    ;;
            esac
            
            # Clone dotfiles for bspwm
            git clone https://github.com/PhoenixStarYT/dotfiles-bspwm-koenos ~/.config/bspwm
            cp -r ~/.config/bspwm/* ~/.config/
            configure_desktop_environment 11
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
        1)  # GNOME
            echo "Installing GNOME..."
            sudo pacman -S --noconfirm gnome gnome-extra firefox variety breeze kitty sddm dialog
            configure_desktop_environment 1
            ;;
        2)  # KDE Plasma
            echo "Installing KDE Plasma..."
            sudo pacman -S --noconfirm plasma kde-applications firefox variety breeze kitty sddm dialog
            configure_desktop_environment 2
            ;;
        3)  # XFCE
            echo "Installing XFCE..."
            sudo pacman -S --noconfirm xfce4 xfce4-goodies firefox variety breeze kitty sddm dialog
            # Install themes and icons
            $AUR_HELPER -S --noconfirm nordic-theme-git tela-icon-theme breeze-cursors
            configure_desktop_environment 3
            ;;
        4)  # Cinnamon
            echo "Installing Cinnamon..."
            sudo pacman -S --noconfirm cinnamon firefox variety breeze kitty sddm dialog
            configure_desktop_environment 4
            ;;
        5)  # MATE
            echo "Installing MATE..."
            sudo pacman -S --noconfirm mate mate-extra firefox variety breeze kitty sddm dialog
            configure_desktop_environment 5
            ;;
        6)  # LXDE
            echo "Installing LXDE..."
            sudo pacman -S --noconfirm lxde firefox variety breeze kitty dialog
            configure_desktop_environment 6
            ;;
        7)  # LXQt
            echo "Installing LXQt..."
            sudo pacman -S --noconfirm lxqt firefox variety breeze kitty dialog
            configure_desktop_environment 7
            ;;
        8)  # Budgie
            echo "Installing Budgie"
            sudo pacman -S --noconfirm budgie firefox variety breeze kitty dialog
            configure_desktop_environment 8
            ;;
        9)  # i3wm
            echo "Installing i3wm..."
            sudo pacman -S --noconfirm i3 firefox variety breeze kitty dialog
            configure_desktop_environment 9
            ;;
        10)  # openbox
            echo "Installing openbox..."
            sudo pacman -S --noconfirm openbox lxpanel 
            configure_desktop_environment 10
            ;;
        11)  # bspwm
            echo "Installing bspwm..."
            sudo pacman -S --noconfirm bspwm picom variety thunar polybar
            
            # Install FiraCode font
            echo "Installing FiraCode font..."
            sudo pacman -S --noconfirm ttf-firacode
            
            # Prompt user to choose between dmenu and rofi
            echo "Choose your application launcher:"
            echo "1. dmenu"
            echo "2. rofi"
            read -rp "Enter the number of your choice: " launcher_choice
            
            case $launcher_choice in
                1)
                    echo "Installing dmenu..."
                    sudo pacman -S --noconfirm dmenu
                    ;;
                2)
                    echo "Installing rofi..."
                    sudo pacman -S --noconfirm rofi
                    ;;
                *)
                    echo "Invalid choice. Skipping installation of application launcher."
                    ;;
            esac
            
            # Clone dotfiles for bspwm
            git clone https://github.com/PhoenixStarYT/dotfiles-bspwm-koenos ~/.config/bspwm
            cp -r ~/.config/bspwm/* ~/.config/
            configure_desktop_environment 11
            ;;
        *)
            echo "Invalid option"
            ;;
    esac

    # Call the function to choose the display manager
    choose_display_manager
}

# Function to choose and install the display manager
choose_display_manager() {
    echo "Choose your preferred display manager:"
    echo "1. SDDM"
    echo "2. GDM"
    echo "3. LightDM"
    echo "4. LXDM"
    echo "5. XDM"

    read -rp "Enter the number of the display manager you want to install: " choice
    case $choice in
        1)
            echo "Installing SDDM..."
            sudo pacman -S --noconfirm sddm
            systemctl enable sddm
            ;;
        2)
            echo "Installing GDM..."
            sudo pacman -S --noconfirm gdm
            systemctl enable gdm
            ;;
        3)
            echo "Installing LightDM..."
            sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
            systemctl enable lightdm
            ;;
        4)
            echo "Installing LXDM..."
            sudo pacman -S --noconfirm lxdm
            systemctl enable lxdm
            ;;
        5)
            echo "Installing XDM..."
            sudo pacman -S --noconfirm xdm
            systemctl enable xdm
            ;;
        *)
            echo "Invalid choice. Please run the script again and select a valid option."
            exit 1
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
    echo "4. Skip installation"

    read -p "Enter your choice [1-4]: " choice

    case $choice in
        1)
            echo "Installing LibreOffice..."
            sudo pacman -S --noconfirm libreoffice-fresh
            ;;
        2)
            echo "Installing OnlyOffice..."
            $AUR_HELPER -S --noconfirm onlyoffice-bin
            ;;
        3)
            echo "Installing WPS Office..."
            $AUR_HELPER -S --noconfirm wps-office
            ;;
        4)
            echo "Skipping office suite installation."
            ;;
        *)
            echo "Invalid choice. Please enter a number from 1 to 4."
            install_office_suite
            ;;
    esac
}

# Function to install Steam
install_steam() {
    echo "Installing Steam..."
    sudo pacman -S --noconfirm steam
}

# Function to install Lutris
install_lutris() {
    echo "Installing Lutris..."
    sudo pacman -S --noconfirm lutris
}

# Function to install Wine
install_wine() {
    echo "Installing Wine..."
    sudo pacman -S --noconfirm wine
}

# Function to install Libretro
install_libretro() {
    echo "Installing Libretro..."
    sudo pacman -S --noconfirm libretro
}

# Function to install Minecraft
install_minecraft() {
    echo "Installing Minecraft..."
    sudo pacman -S --noconfirm jdk-openjdk
    $AUR_HELPER -S --noconfirm minecraft-launcher
    $AUR_HELPER -S --noconfirm multimc-bin
}

# Function to install gaming-related software
install_gaming_software() {
    read -p "Do you want to install gaming-related software? (y/n): " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        PS3="Select an option (enter the number): "
        options=("Steam" "Lutris" "Wine" "Libretro" "Minecraft" "All" "None")
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
                "Minecraft")
                    install_minecraft
                    break
                    ;;
                "All")
                    install_steam
                    install_lutris
                    install_wine
                    install_libretro
                    install_minecraft
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

# Function to install multimedia tools
install_multimedia_tools() {
    read -p "Do you want to install multimedia tools (mpv, Clementine, Kodi)? (y/n): " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "Installing multimedia tools..."
        sudo pacman -S --noconfirm mpv clementine kodi
    else
        echo "Skipping installation of multimedia tools."
    fi
}

# Main script starts here

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

# Choose and install the desktop environment
PS3='Please enter your choice: '
options=("GNOME" "KDE Plasma" "XFCE" "Cinnamon" "MATE" "LXDE" "LXQt" "Budgie" "i3wm" "openbox" "bspwm" "Quit")
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
        "i3wm")
            install_desktop_environment 9
            break
            ;;
        "openbox")
            install_desktop_environment 10
            break
            ;;
        "bspwm")
            install_desktop_environment 11
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done

# Main script continues here
detect_aur_helper

# Choose and install the web browser
choose_web_browser() {
    echo "Choose a web browser to install:"
    echo "1. Google Chrome"
    echo "2. Brave"
    echo "3. Firefox"
    echo "4. Qutebrowser"
    echo "5. Thorium"
    echo "6. Microsoft Edge"
    echo "7. Vivaldi"
    echo "8. Opera"

    read -rp "Enter the number of the web browser you want to install: " choice
    case $choice in
        1)
            echo "Installing Google Chrome..."
            $AUR_HELPER -S --noconfirm google-chrome
            BROWSER="google-chrome"
            ;;
        2)
            echo "Installing Brave..."
            $AUR_HELPER -S --noconfirm brave-bin
            BROWSER="brave"
            ;;
        3)
            echo "Installing Firefox..."
            sudo pacman -S --noconfirm firefox
            BROWSER="firefox"
            ;;
        4)
            echo "Installing Qutebrowser..."
            sudo pacman -S --noconfirm qutebrowser
            BROWSER="qutebrowser"
            ;;
        5)
            echo "Installing Thorium..."
            $AUR_HELPER -S --noconfirm thorium
            BROWSER="thorium"
            ;;
        6)
            echo "Installing Microsoft Edge..."
            $AUR_HELPER -S --noconfirm microsoft-edge-stable-bin
            BROWSER="microsoft-edge-stable"
            ;;
        7)
            echo "Installing Vivaldi..."
            $AUR_HELPER -S --noconfirm vivaldi
            BROWSER="vivaldi"
            ;;
        8)
            echo "Installing Opera..."
            sudo pacman -S --noconfirm opera
            BROWSER="opera"
            ;;
        *)
            echo "Invalid choice. Please run the script again and select a valid option."
            exit 1
            ;;
    esac

    set_default_browser
}

# Function to set the chosen browser as the default
set_default_browser() {
    echo "Setting $BROWSER as the default web browser..."

    # For GNOME-based environments
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.system.proxy mode 'none'
        gsettings set org.gnome.system.proxy.http host ''
        gsettings set org.gnome.system.proxy.http port 0
        gsettings set org.gnome.system.proxy.https host ''
        gsettings set org.gnome.system.proxy.https port 0
        gsettings set org.gnome.system.proxy.ftp host ''
        gsettings set org.gnome.system.proxy.ftp port 0
        gsettings set org.gnome.system.proxy.socks host ''
        gsettings set org.gnome.system.proxy.socks port 0
        gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1']"
        gsettings set org.gnome.desktop.default-applications.browser exec "$BROWSER"
        gsettings set org.gnome.desktop.default-applications.browser exec-arg ""
    fi

    # For KDE-based environments
    if command -v update-alternatives &> /dev/null; then
        sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/$BROWSER 200
        sudo update-alternatives --set x-www-browser /usr/bin/$BROWSER
    fi

    # For XFCE
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -s $BROWSER -a
    fi

    # For other environments (LXDE, LXQt, etc.)
    if [ -f ~/.config/lxsession/LXDE/autostart ]; then
        echo "@$BROWSER" >> ~/.config/lxsession/LXDE/autostart
    fi

    # For i3
    if [ -d ~/.config/i3 ]; then
        echo 'bindsym $mod+Shift+b exec $BROWSER' >> ~/.config/i3/config
    fi

    # For bspwm
    if [ -d ~/.config/bspwm ]; then
        echo 'super + b
	$BROWSER' >> ~/.config/sxhkd/sxhkdrc
    fi

    # For Openbox
    if [ -d ~/.config/openbox ]; then
        if [ ! -f ~/.config/openbox/autostart ]; then
            touch ~/.config/openbox/autostart
        fi
        echo '$BROWSER & disown' >> ~/.config/openbox/autostart
    fi
}

# Main script continues here
choose_web_browser

# Ask user if they want to install pamac
read -p "Do you want to install pamac (graphical package manager)? (y/n): " install_pamac
if [[ $install_pamac =~ ^[Yy]$ ]]; then
    echo "Installing pamac using $AUR_HELPER..."
    $AUR_HELPER -S --noconfirm pamac
else
    echo "Skipping installation of pamac."
fi

# Install office suite
install_office_suite

# Install gaming-related software
install_gaming_software

# Install multimedia tools
install_multimedia_tools

echo "Installation complete."

# Install themes
mkdir -p ~/.themes
mkdir -p ~/.icons
git clone https://github.com/PhoenixStarYT/KoenOS-Themes ~
cp -r ~/KoenOS-Themes/Widgets ~/.themes
cp -r ~/KoenOS-Themes/Icons ~/.icons

# Function to install Starship prompt
install_starship() {
    echo "Installing Starship prompt..."
    sudo pacman -S --noconfirm starship

    # Add Starship initialization to .bashrc
    if ! grep -q 'eval "$(starship init bash)"' ~/.bashrc; then
        echo 'eval "$(starship init bash)"' >> ~/.bashrc
    fi

    echo "Starship prompt installed and configured."
}

# Call the function to install Starship prompt
install_starship

# Function to install development tools
install_development_tools() {
    echo "Installing development tools..."
    sudo pacman -S --noconfirm git vim code docker nodejs npm python python-pip
}

# Function to install utilities
install_utilities() {
    echo "Installing utilities..."
    sudo pacman -S --noconfirm fastfetch htop tmux curl wget zsh ranger
    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# Function to install media tools
install_media_tools() {
    echo "Installing media tools..."
    sudo pacman -S --noconfirm vlc gimp inkscape audacity
}

# Function to install productivity tools
install_productivity_tools() {
    echo "Installing productivity tools..."
    sudo pacman -S --noconfirm thunderbird keepassxc syncthing
}

# Function to install networking tools
install_networking_tools() {
    echo "Installing networking tools..."
    sudo pacman -S --noconfirm openvpn networkmanager
}

# Call the functions to install additional tools
install_development_tools
install_utilities
install_media_tools
install_productivity_tools
install_networking_tools

echo "

███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝███╗  ████║
███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
╚════██║  ╚██╔╝  =════██║   ██║   ██╔══╝  ██║╚██╔╝██║
███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
                                                     
██████╗ ███████╗ █████╗ ██████╗  ██╗   ██╗            
██╔══██╗██╔════╝█╔══██╗██╔══██╗ ╚██╗  ██╔╝            
██████╔╝█████╗  ███████║██║  ██║ ╚████╔╝             
██╔══██╗██╔══╝  ██╔══██║██║  ██║  ╚██╔╝              
██║  ██║███████╗██║  ██║██████╔╝   ██║               
╚═╝  ╚═╝╚═════╝╚═  ╚═╝╚═════╝    ╚═╝               
                                                     

"

GREEN="\e[32m"
RESET="\e[0m"

echo -e "${GREEN}Reboot your system to see the final results${RESET}"
