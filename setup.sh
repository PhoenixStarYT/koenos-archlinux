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

# Prompt user for experience level
echo "Are you a beginner or an intermediate Linux user?"
echo "1. Beginner"
echo "2. Intermediate"
read -rp "Enter your choice (1 or 2): " user_choice

if [[ $user_choice -eq 1 ]]; then
    # Clone and install Yay AUR helper
    echo "Installing Yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git
    cd yay || { echo "Failed to enter yay directory."; exit 1; }
    makepkg -si --noconfirm || { echo "Failed to install Yay."; exit 1; }
    cd ..  # Go back to the previous directory
    rm -rf yay  # Clean up the cloned directory

    # Install packages for beginners
    echo "Installing beginner packages..."
    yay -S --noconfirm onlyoffice-bin firefox nordic-theme mpv clementine spotify gnome-software cinnamon
    # Set Nordic as the default theme in Cinnamon
    gsettings set org.cinnamon.desktop.interface gtk-theme 'Nordic'
    exit 0  # Exit after installing beginner packages
elif [[ $user_choice -eq 2 ]]; then
    # Skip installing beginner packages and proceed with the rest of the script
    echo "Proceeding with the rest of the script..."
else
    echo "Invalid choice. Please run the script again and select a valid option."
    exit 1
fi

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
        sudo pacman -S --noconfirm git || { echo "Failed to install git."; exit 1; }
    fi

    # Create wallpaper directory if it doesn't exist
    mkdir -p ~/.wallpaper || { echo "Failed to create wallpaper directory."; exit 1; }

    # Clone wallpapers if not already cloned
    if [ ! -d ~/.wallpaper/koenos-wallpapers ]; then
        git clone https://github.com/phoenixstaryt/koenos-wallpapers ~/.wallpaper || { echo "Failed to clone wallpapers."; exit 1; }
    else
        echo "Wallpapers already cloned, skipping..."
    fi

    # Clone Nord background
    if [ ! -d ~/.wallpaper/nord-background ]; then
        git clone https://github.com/ChrisTitusTech/nord-background ~/.wallpaper || { echo "Failed to clone Nord background."; exit 1; }
    else
        echo "Nord background already cloned, skipping..."
    fi

    # Install Firacode Nerd Fonts
    sudo pacman -S --noconfirm ttf-firacode-nerd || { echo "Failed to install Firacode Nerd Fonts."; exit 1; }

    # Clone Tela Circle Icons
    mkdir -p ~/.icons || { echo "Failed to create icons directory."; exit 1; }
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme ~/.icons/Tela-circle || { echo "Failed to clone Tela Circle Icons."; exit 1; }

    # Clone Nordic theme
    mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
    git clone https://github.com/EliverLara/Nordic ~/.themes/Nordic || { echo "Failed to clone Nordic theme."; exit 1; }

    # Install Layan Cursors
    git clone https://github.com/vinceliuice/Layan-cursors ~/.icons/Layan-cursors || { echo "Failed to clone Layan Cursors."; exit 1; }

    # Install Breeze Cursors
    sudo pacman -S --noconfirm breeze || { echo "Failed to install Breeze Cursors."; exit 1; }

    # Configure the desktop environment based on the user's choice
    case $1 in
        1)  # GNOME
            echo "Configuring GNOME..."
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || { echo "Failed to set GNOME theme."; exit 1; }
            gsettings set org.gnome.desktop.interface font-name 'FiraCode Nerd Font 11' || { echo "Failed to set GNOME font."; exit 1; }
            gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle' || { echo "Failed to set GNOME icon theme."; exit 1; }
            gsettings set org.gnome.desktop.interface cursor-theme 'breeze' || { echo "Failed to set GNOME cursor theme."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        2)  # KDE Plasma
            echo "Configuring KDE Plasma..."
            kwriteconfig5 --file kdeglobals --group General --key ColorScheme 'BreezeDark' || { echo "Failed to set KDE color scheme."; exit 1; }
            kwriteconfig5 --file kdeglobals --group General --key font 'FiraCode Nerd Font,11,-1,5,50,0,0,0,0,0' || { echo "Failed to set KDE font."; exit 1; }
            kwriteconfig5 --file kdeglobals --group Icons --key Theme 'Tela-circle' || { echo "Failed to set KDE icon theme."; exit 1; }
            kwriteconfig5 --file kdeglobals --group Cursors --key Theme 'breeze' || { echo "Failed to set KDE cursor theme."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }

            # Ensure qdbus is available
            if ! command -v qdbus &> /dev/null; then
                echo "qdbus could not be found, installing qt5-tools..."
                sudo pacman -S --noconfirm qt5-tools || { echo "Failed to install qt5-tools."; exit 1; }
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
            ' || { echo "Failed to add KDE widgets."; exit 1; }
            ;;
        3)  # XFCE
            echo "Configuring XFCE..."
            xfconf-query -c xsettings -p /Net/ThemeName -s 'Nordic' || { echo "Failed to set XFCE theme."; exit 1; }
            xfconf-query -c xsettings -p /Net/IconThemeName -s 'Tela-circle' || { echo "Failed to set XFCE icon theme."; exit 1; }
            xfconf-query -c xsettings -p /Net/CursorThemeName -s 'breeze' || { echo "Failed to set XFCE cursor theme."; exit 1; }
            xfconf-query -c xsettings -p /Gtk/FontName -s 'FiraCode Nerd Font 11' || { echo "Failed to set XFCE font."; exit 1; }
            mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
            cp -r ~/koenos-archlinux/themes/* ~/.themes || { echo "Failed to copy themes."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        4)  # Cinnamon
            echo "Configuring Cinnamon..."
            gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark' || { echo "Failed to set Cinnamon theme."; exit 1; }
            gsettings set org.cinnamon.desktop.interface font-name 'FiraCode Nerd Font 11' || { echo "Failed to set Cinnamon font."; exit 1; }
            gsettings set org.cinnamon.desktop.interface icon-theme 'Tela-circle' || { echo "Failed to set Cinnamon icon theme."; exit 1; }
            gsettings set org.cinnamon.desktop.interface cursor-theme 'breeze' || { echo "Failed to set Cinnamon cursor theme."; exit 1; }
            mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
            cp -r ~/koenos-archlinux/themes/* ~/.themes || { echo "Failed to copy themes."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        5)  # MATE
            echo "Configuring MATE..."
            gsettings set org.mate.interface gtk-theme 'Ambiant-MATE-Dark' || { echo "Failed to set MATE theme."; exit 1; }
            gsettings set org.mate.interface font-name 'FiraCode Nerd Font 11' || { echo "Failed to set MATE font."; exit 1; }
            gsettings set org.mate.interface icon-theme 'Tela-circle' || { echo "Failed to set MATE icon theme."; exit 1; }
            gsettings set org.mate.interface cursor-theme 'breeze' || { echo "Failed to set MATE cursor theme."; exit 1; }
            mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
            cp -r ~/koenos-archlinux/themes/* ~/.themes || { echo "Failed to copy themes."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        6)  # LXDE
            echo "Configuring LXDE..."
            sed -i 's/window_manager=.*/window_manager=openbox/' ~/.config/lxsession/LXDE/desktop.conf || { echo "Failed to set LXDE window manager."; exit 1; }
            echo 'xft: FiraCode Nerd Font 11' >> ~/.config/lxsession/LXDE/desktop.conf || { echo "Failed to set LXDE font."; exit 1; }
            echo 'sNet/IconThemeName=Tela-circle' >> ~/.config/lxsession/LXDE/desktop.conf || { echo "Failed to set LXDE icon theme."; exit 1; }
            echo 'sNet/CursorThemeName=breeze' >> ~/.config/lxsession/LXDE/desktop.conf || { echo "Failed to set LXDE cursor theme."; exit 1; }
            mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
            cp -r ~/koenos-archlinux/themes/* ~/.themes || { echo "Failed to copy themes."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        7)  # LXQt
            echo "Configuring LXQt..."
            lxqt-config-appearance --set-widget-style Fusion || { echo "Failed to set LXQt widget style."; exit 1; }
            echo 'xft: FiraCode Nerd Font 11' >> ~/.config/lxqt/session.conf || { echo "Failed to set LXQt font."; exit 1; }
            echo 'sNet/IconThemeName=Tela-circle' >> ~/.config/lxqt/session.conf || { echo "Failed to set LXQt icon theme."; exit 1; }
            echo 'sNet/CursorThemeName=breeze' >> ~/.config/lxqt/session.conf || { echo "Failed to set LXQt cursor theme."; exit 1; }
            mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
            cp -r ~/koenos-archlinux/themes/* ~/.themes || { echo "Failed to copy themes."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        8)  # Budgie
            echo "Configuring Budgie..."
            mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
            cp -r ~/koenos-archlinux/themes/* ~/.themes || { echo "Failed to copy themes."; exit 1; }
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || { echo "Failed to set Budgie theme."; exit 1; }
            gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle' || { echo "Failed to set Budgie icon theme."; exit 1; }
            gsettings set org.gnome.desktop.interface cursor-theme 'breeze' || { echo "Failed to set Budgie cursor theme."; exit 1; }
            gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita-dark' || { echo "Failed to set Budgie WM theme."; exit 1; }
            gsettings set org.gnome.desktop.interface font-name 'FiraCode Nerd Font 11' || { echo "Failed to set Budgie font."; exit 1; }
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3/* ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        9)  # i3wm
            echo "Configuring i3wm"
            mkdir -p ~/.config || { echo "Failed to create config directory."; exit 1; }
            cp -r ~/koenos-archlinux/dotconfig-i3 ~/.config || { echo "Failed to copy i3 config."; exit 1; }
            mkdir -p ~/.themes || { echo "Failed to create themes directory."; exit 1; }
            cp -r ~/koenos-archlinux/themes/* ~/.themes || { echo "Failed to copy themes."; exit 1; }
            echo 'font pango:FiraCode Nerd Font 11' >> ~/.config/i3/config || { echo "Failed to set i3 font."; exit 1; }
            echo 'bindsym $mod+Shift+i exec "feh --bg-scale ~/.wallpaper/your_wallpaper.jpg"' >> ~/.config/i3/config || { echo "Failed to set i3 wallpaper binding."; exit 1; }
            echo 'set_from_resource $theme Nordic' >> ~/.config/i3/config || { echo "Failed to set i3 theme."; exit 1; }
            echo 'xsetroot -cursor_name breeze' >> ~/.config/i3/config || { echo "Failed to set i3 cursor."; exit 1; }
            # Set pcmanfm as the default file manager
            echo 'bindsym $mod+e exec pcmanfm' >> ~/.config/i3/config || { echo "Failed to set i3 file manager."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        10)  # openbox
            echo "Configuring openbox..."
            git clone https://github.com/PhoenixStarYT/dotfiles-openbox-koenos ~ || { echo "Failed to clone openbox config."; exit 1; }
            echo 'theme = "Nordic"' >> ~/.config/openbox/rc.xml || { echo "Failed to set openbox theme."; exit 1; }
            echo 'xsetroot -cursor_name breeze' >> ~/.config/openbox/rc.xml || { echo "Failed to set openbox cursor."; exit 1; }
            # Set pcmanfm as the default file manager
            echo 'pcmanfm & disown' >> ~/.config/openbox/autostart || { echo "Failed to set openbox file manager."; exit 1; }
            systemctl enable sddm || { echo "Failed to enable SDDM."; exit 1; }
            ;;
        11)  # bspwm
            echo "Installing bspwm..."
            sudo pacman -S --noconfirm bspwm picom variety thunar polybar || { echo "Failed to install bspwm packages."; exit 1; }
            
            # Prompt user to choose between dmenu and rofi
            echo "Choose your application launcher:"
            echo "1. dmenu"
            echo "2. rofi"
            read -rp "Enter the number of your choice: " launcher_choice
            
            case $launcher_choice in
                1)
                    echo "Installing dmenu..."
                    sudo pacman -S --noconfirm dmenu || { echo "Failed to install dmenu."; exit 1; }
                    ;;
                2)
                    echo "Installing rofi..."
                    sudo pacman -S --noconfirm rofi || { echo "Failed to install rofi."; exit 1; }
                    ;;
                *)
                    echo "Invalid choice. Skipping installation of application launcher."
                    ;;
            esac
            
            # Clone dotfiles for bspwm
            git clone https://github.com/PhoenixStarYT/dotfiles-bspwm-koenos ~/.config/bspwm || { echo "Failed to clone bspwm config."; exit 1; }
            cp -r ~/.config/bspwm/* ~/.config/ || { echo "Failed to copy bspwm config."; exit 1; }
            ;;
        *)
            echo "Invalid option"
            exit 1
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
    # Prompt user to choose a terminal
    echo "Choose a terminal to install:"
    echo "1. Konsole"
    echo "2. GNOME Terminal"
    echo "3. XFCE Terminal"
    echo "4. Cool Retro Term"
    echo "5. LXTerminal"
    echo "6. Alacritty"
    echo "7. Kitty"
    read -rp "Enter the number of the terminal you want to install: " terminal_choice

    case $terminal_choice in
        1)
            echo "Installing Konsole..."
            sudo pacman -S --noconfirm konsole
            TERMINAL="konsole"
            ;;
        2)
            echo "Installing GNOME Terminal..."
            sudo pacman -S --noconfirm gnome-terminal
            TERMINAL="gnome-terminal"
            ;;
        3)
            echo "Installing XFCE Terminal..."
            sudo pacman -S --noconfirm xfce4-terminal
            TERMINAL="xfce4-terminal"
            ;;
        4)
            echo "Installing Cool Retro Term..."
            sudo pacman -S --noconfirm cool-retro-term
            TERMINAL="cool-retro-term"
            ;;
        5)
            echo "Installing LXTerminal..."
            sudo pacman -S --noconfirm lxterminal
            TERMINAL="lxterminal"
            ;;
        6)
            echo "Installing Alacritty..."
            sudo pacman -S --noconfirm alacritty
            TERMINAL="alacritty"
            ;;
        7)
            echo "Installing Kitty..."
            sudo pacman -S --noconfirm kitty
            TERMINAL="kitty"
            ;;
        *)
            echo "Invalid choice. Skipping terminal installation."
            TERMINAL=""
            ;;
    esac

    # Proceed with the installation of the desktop environment
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
            git clone https://github.com/PhoenixStarYT/dotfiles-openbox-koenos ~/dotfiles-openbox-koenos
            mkdir -p ~/.config
            cp -r ~/dotfiles-openbox-koenos/.config/* ~/.config/
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
            
            # Ensure to break out of the loop after processing the choice
            break  # Add this line to exit the loop
            
            # Clone dotfiles for bspwm
            git clone https://github.com/PhoenixStarYT/dotfiles-bspwm-koenos ~/.config/bspwm
            cp -r ~/.config/bspwm/* ~/.config/
            configure_desktop_environment 11
            ;;
        *)
            echo "Invalid option"
            ;;
    esac

    # Set the chosen terminal as the default
    configure_kitty_as_default
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

# Function to check if a package is installed
check_package() {
    pacman -Qi "$1" &>/dev/null
    return $?
}

# Function to install a package with error handling
install_package() {
    local package=$1
    local source=$2  # 'pacman' or 'aur'
    
    if check_package "$package"; then
        echo "$package is already installed."
        return 0
    fi
    
    echo "Installing $package..."
    if [ "$source" = "pacman" ]; then
        sudo pacman -S --noconfirm "$package" || { echo "Failed to install $package."; return 1; }
    else
        $AUR_HELPER -S --noconfirm "$package" || { echo "Failed to install $package from AUR."; return 1; }
    fi
}

# Function to install Steam
install_steam() {
    echo "Installing Steam..."
    install_package "steam" "pacman" || return 1
    install_package "steam-native-runtime" "pacman" || return 1
    install_package "lib32-vulkan-icd-loader" "pacman" || return 1
    install_package "lib32-vulkan-intel" "pacman" || return 1
    install_package "lib32-vulkan-radeon" "pacman" || return 1
}

# Function to install Lutris
install_lutris() {
    echo "Installing Lutris..."
    install_package "lutris" "pacman" || return 1
    install_package "wine" "pacman" || return 1
    install_package "winetricks" "pacman" || return 1
}

# Function to install Wine
install_wine() {
    echo "Installing Wine..."
    install_package "wine" "pacman" || return 1
    install_package "winetricks" "pacman" || return 1
    install_package "wine-mono" "pacman" || return 1
    install_package "wine-gecko" "pacman" || return 1
}

# Function to install Libretro
install_libretro() {
    echo "Installing Libretro..."
    install_package "libretro-core-info" "pacman" || return 1
    install_package "libretro-common" "pacman" || return 1
    install_package "libretro-beetle-psx" "pacman" || return 1
    install_package "libretro-snes9x" "pacman" || return 1
    install_package "libretro-mgba" "pacman" || return 1
}

# Function to install Minecraft
install_minecraft() {
    echo "Installing Minecraft..."
    install_package "jdk-openjdk" "pacman" || return 1
    install_package "minecraft-launcher" "aur" || return 1
    install_package "multimc-bin" "aur" || return 1
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
                    install_steam || { echo "Failed to install Steam."; return 1; }
                    break
                    ;;
                "Lutris")
                    install_lutris || { echo "Failed to install Lutris."; return 1; }
                    break
                    ;;
                "Wine")
                    install_wine || { echo "Failed to install Wine."; return 1; }
                    break
                    ;;
                "Libretro")
                    install_libretro || { echo "Failed to install Libretro."; return 1; }
                    break
                    ;;
                "Minecraft")
                    install_minecraft || { echo "Failed to install Minecraft."; return 1; }
                    break
                    ;;
                "All")
                    install_steam || { echo "Failed to install Steam."; return 1; }
                    install_lutris || { echo "Failed to install Lutris."; return 1; }
                    install_wine || { echo "Failed to install Wine."; return 1; }
                    install_libretro || { echo "Failed to install Libretro."; return 1; }
                    install_minecraft || { echo "Failed to install Minecraft."; return 1; }
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
        install_package "mpv" "pacman" || { echo "Failed to install mpv."; return 1; }
        install_package "clementine" "pacman" || { echo "Failed to install Clementine."; return 1; }
        install_package "kodi" "pacman" || { echo "Failed to install Kodi."; return 1; }
        install_package "kodi-addons" "pacman" || { echo "Failed to install Kodi addons."; return 1; }
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

# Function to install packages for beginners
install_beginners_packages() {
    echo "Installing packages for beginners..."
    # Install required packages using Yay
    yay -S --noconfirm onlyoffice firefox nordic-theme mpv clementine spotify gnome-software
    # Set Nordic as the default theme
    gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'
}

# Prompt user for experience level
echo "Are you a beginner or an intermediate Linux user?"
echo "1. Beginner"
echo "2. Intermediate"
read -rp "Enter your choice (1 or 2): " user_choice

if [[ $user_choice -eq 1 ]]; then
    install_beginners_packages
    exit 0  # Exit after installing beginner packages
fi

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
        gsettings set org.gnome.system.proxy mode 'none' || { echo "Failed to set GNOME proxy mode."; exit 1; }
        gsettings set org.gnome.system.proxy.http host '' || { echo "Failed to set GNOME HTTP proxy."; exit 1; }
        gsettings set org.gnome.system.proxy.http port 0 || { echo "Failed to set GNOME HTTP proxy port."; exit 1; }
        gsettings set org.gnome.system.proxy.https host '' || { echo "Failed to set GNOME HTTPS proxy."; exit 1; }
        gsettings set org.gnome.system.proxy.https port 0 || { echo "Failed to set GNOME HTTPS proxy port."; exit 1; }
        gsettings set org.gnome.system.proxy.ftp host '' || { echo "Failed to set GNOME FTP proxy."; exit 1; }
        gsettings set org.gnome.system.proxy.ftp port 0 || { echo "Failed to set GNOME FTP proxy port."; exit 1; }
        gsettings set org.gnome.system.proxy.socks host '' || { echo "Failed to set GNOME SOCKS proxy."; exit 1; }
        gsettings set org.gnome.system.proxy.socks port 0 || { echo "Failed to set GNOME SOCKS proxy port."; exit 1; }
        gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1']" || { echo "Failed to set GNOME proxy ignore hosts."; exit 1; }
        gsettings set org.gnome.desktop.default-applications.browser exec "$BROWSER" || { echo "Failed to set GNOME default browser."; exit 1; }
        gsettings set org.gnome.desktop.default-applications.browser exec-arg "" || { echo "Failed to set GNOME browser arguments."; exit 1; }
    fi

    # For KDE-based environments
    if command -v update-alternatives &> /dev/null; then
        sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser "/usr/bin/$BROWSER" 200 || { echo "Failed to install browser alternative."; exit 1; }
        sudo update-alternatives --set x-www-browser "/usr/bin/$BROWSER" || { echo "Failed to set browser alternative."; exit 1; }
    fi

    # For XFCE
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -s "$BROWSER" -a || { echo "Failed to set XFCE default browser."; exit 1; }
    fi

    # For other environments (LXDE, LXQt, etc.)
    if [ -f ~/.config/lxsession/LXDE/autostart ]; then
        echo "@$BROWSER" >> ~/.config/lxsession/LXDE/autostart || { echo "Failed to set LXDE default browser."; exit 1; }
    fi

    # For i3
    if [ -d ~/.config/i3 ]; then
        echo "bindsym \$mod+Shift+b exec $BROWSER" >> ~/.config/i3/config || { echo "Failed to set i3 browser shortcut."; exit 1; }
    fi

    # For bspwm
    if [ -d ~/.config/bspwm ]; then
        echo "super + b
	$BROWSER" >> ~/.config/sxhkd/sxhkdrc || { echo "Failed to set bspwm browser shortcut."; exit 1; }
    fi

    # For Openbox
    if [ -d ~/.config/openbox ]; then
        if [ ! -f ~/.config/openbox/autostart ]; then
            touch ~/.config/openbox/autostart || { echo "Failed to create Openbox autostart file."; exit 1; }
        fi
        echo "$BROWSER & disown" >> ~/.config/openbox/autostart || { echo "Failed to set Openbox default browser."; exit 1; }
    fi

    # Set default browser using xdg-utils
    if command -v xdg-settings &> /dev/null; then
        xdg-settings set default-web-browser "$BROWSER.desktop" || { echo "Failed to set system-wide default browser."; exit 1; }
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
    
    # Core development tools
    local dev_packages=(
        "git"
        "vim"
        "code"
        "docker"
        "nodejs"
        "npm"
        "python"
        "python-pip"
        "base-devel"
        "cmake"
        "gcc"
        "make"
        "pkg-config"
    )
    
    for package in "${dev_packages[@]}"; do
        install_package "$package" "pacman" || { echo "Failed to install $package."; return 1; }
    done
    
    # Install Docker service
    if ! systemctl is-active --quiet docker; then
        sudo systemctl enable docker || { echo "Failed to enable Docker service."; return 1; }
        sudo systemctl start docker || { echo "Failed to start Docker service."; return 1; }
        sudo usermod -aG docker "$USER" || { echo "Failed to add user to docker group."; return 1; }
    fi
    
    # Install VS Code extensions
    if command -v code &> /dev/null; then
        local vscode_extensions=(
            "ms-python.python"
            "ms-vscode.cpptools"
            "dbaeumer.vscode-eslint"
            "esbenp.prettier-vscode"
            "ms-azuretools.vscode-docker"
            "golang.go"
            "rust-lang.rust"
        )
        
        for extension in "${vscode_extensions[@]}"; do
            code --install-extension "$extension" || { echo "Failed to install VS Code extension: $extension"; }
        done
    fi
    
    # Configure Git
    if ! git config --global user.name &> /dev/null; then
        read -rp "Enter your Git username: " git_username
        git config --global user.name "$git_username" || { echo "Failed to set Git username."; return 1; }
    fi
    
    if ! git config --global user.email &> /dev/null; then
        read -rp "Enter your Git email: " git_email
        git config --global user.email "$git_email" || { echo "Failed to set Git email."; return 1; }
    fi
    
    # Install Python packages
    local python_packages=(
        "pytest"
        "black"
        "flake8"
        "mypy"
        "isort"
        "pipenv"
        "poetry"
    )
    
    for package in "${python_packages[@]}"; do
        pip install --user "$package" || { echo "Failed to install Python package: $package"; }
    done
    
    # Install Node.js packages
    local node_packages=(
        "typescript"
        "eslint"
        "prettier"
        "nodemon"
        "yarn"
    )
    
    for package in "${node_packages[@]}"; do
        npm install -g "$package" || { echo "Failed to install Node.js package: $package"; }
    done
    
    echo "Development tools installation completed."
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
    
    # Define arrays for different categories of productivity tools
    local communication_tools=(
        "thunderbird"
        "signal-desktop"
        "slack-desktop"
        "discord"
    )
    
    local security_tools=(
        "keepassxc"
        "gnupg"
        "yubikey-manager"
        "pass"
    )
    
    local sync_tools=(
        "syncthing"
        "nextcloud-client"
        "rclone"
    )
    
    local note_tools=(
        "obsidian"
        "joplin-desktop"
        "xournalpp"
    )
    
    local time_tools=(
        "gnome-pomodoro"
        "todoist"
        "calendar-cli"
    )

    # Check for dependencies
    local dependencies=(
        "base-devel"
        "git"
        "curl"
        "wget"
    )

    echo "Checking and installing dependencies..."
    for dep in "${dependencies[@]}"; do
        if ! pacman -Qi "$dep" &>/dev/null; then
            echo "Installing dependency: $dep"
            sudo pacman -S --noconfirm "$dep" || { echo "Failed to install dependency: $dep"; return 1; }
        fi
    done

    # Function to install packages with error handling
    install_package_with_retry() {
        local package=$1
        local source=$2
        local max_retries=3
        local retry_count=0

        while [ $retry_count -lt $max_retries ]; do
            echo "Installing $package (attempt $((retry_count + 1))/$max_retries)..."
            
            if [ "$source" = "pacman" ]; then
                if sudo pacman -S --noconfirm "$package"; then
                    echo "$package installed successfully"
                    return 0
                fi
            elif [ "$source" = "aur" ]; then
                if $AUR_HELPER -S --noconfirm "$package"; then
                    echo "$package installed successfully"
                    return 0
                fi
            fi
            
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                echo "Retrying installation of $package in 5 seconds..."
                sleep 5
            fi
        done
        
        echo "Failed to install $package after $max_retries attempts"
        return 1
    }

    # Install communication tools
    echo "Installing communication tools..."
    for tool in "${communication_tools[@]}"; do
        case $tool in
            "signal-desktop"|"slack-desktop"|"discord")
                install_package_with_retry "$tool" "aur" || continue
                ;;
            *)
                install_package_with_retry "$tool" "pacman" || continue
                ;;
        esac
    done

    # Install security tools
    echo "Installing security tools..."
    for tool in "${security_tools[@]}"; do
        install_package_with_retry "$tool" "pacman" || continue
    done

    # Install sync tools
    echo "Installing sync tools..."
    for tool in "${sync_tools[@]}"; do
        install_package_with_retry "$tool" "pacman" || continue
    done

    # Install note-taking tools
    echo "Installing note-taking tools..."
    for tool in "${note_tools[@]}"; do
        case $tool in
            "obsidian"|"joplin-desktop")
                install_package_with_retry "$tool" "aur" || continue
                ;;
            *)
                install_package_with_retry "$tool" "pacman" || continue
                ;;
        esac
    done

    # Install time management tools
    echo "Installing time management tools..."
    for tool in "${time_tools[@]}"; do
        case $tool in
            "todoist")
                install_package_with_retry "$tool" "aur" || continue
                ;;
            *)
                install_package_with_retry "$tool" "pacman" || continue
                ;;
        esac
    done

    # Configure Syncthing
    if pacman -Qi "syncthing" &>/dev/null; then
        echo "Configuring Syncthing..."
        systemctl --user enable syncthing.service || echo "Failed to enable Syncthing service"
        systemctl --user start syncthing.service || echo "Failed to start Syncthing service"
    fi

    # Configure GPG
    if pacman -Qi "gnupg" &>/dev/null; then
        echo "Configuring GPG..."
        mkdir -p ~/.gnupg
        chmod 700 ~/.gnupg
        echo "default-cache-ttl 3600" > ~/.gnupg/gpg-agent.conf
        echo "max-cache-ttl 7200" >> ~/.gnupg/gpg-agent.conf
        gpg-connect-agent reloadagent /bye
    fi

    # Configure KeePassXC browser integration
    if pacman -Qi "keepassxc" &>/dev/null; then
        echo "Configuring KeePassXC browser integration..."
        mkdir -p ~/.config/keepassxc
        cat > ~/.config/keepassxc/keepassxc.ini <<EOL
[Browser]
Enabled=true
AlwaysAllowAccess=false
CustomProxyLocation=
ShowNotifications=true
UpdateBinaryPath=true
EOL
    fi

    echo "Productivity tools installation completed."
    echo "Note: Some tools may require additional configuration. Please check their documentation."
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

# --- VM Resolution Script Generation ---
if systemd-detect-virt --quiet; then
    echo "Detected Virtual Machine. Setting up 1920x1080 resolution script for startup."
    mkdir -p ~/.config
    cat > ~/.config/set-vm-resolution.sh <<'EOF'
#!/bin/bash
# Set display to 1920x1080 if possible
export DISPLAY=:0
xrandr --output $(xrandr | awk '/ connected/ {print $1; exit}') --mode 1920x1080
EOF
    chmod +x ~/.config/set-vm-resolution.sh
    # Add to .xprofile for most DEs
    if ! grep -q 'set-vm-resolution.sh' ~/.xprofile 2>/dev/null; then
        echo '~/.config/set-vm-resolution.sh' >> ~/.xprofile
    fi
    # Add to LXDE autostart if present
    if [ -f ~/.config/lxsession/LXDE/autostart ] && ! grep -q 'set-vm-resolution.sh' ~/.config/lxsession/LXDE/autostart; then
        echo '@~/.config/set-vm-resolution.sh' >> ~/.config/lxsession/LXDE/autostart
    fi
    # Add to XFCE autostart if present
    if [ -d ~/.config/autostart ]; then
        cat > ~/.config/autostart/set-vm-resolution.desktop <<EOL
[Desktop Entry]
Type=Application
Exec=/home/$USER/.config/set-vm-resolution.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Set VM Resolution
Comment=Set screen resolution to 1920x1080 in VM
EOL
    fi
fi
# --- End VM Resolution Script Generation ---

echo "

███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
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
