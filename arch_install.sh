#!/bin/bash

# Global variable to store the selected AUR helper
AUR_HELPER=""

# Function to display a welcome message with ASCII art
show_welcome() {
    clear
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
██╔═██╗ ██║   ██║██╔══╝  ██║╚██╗██║██║   ██║╚════██║
██║  ██╗╚██████╔╝███████╗██║ ╚████║╚██████╔╝███████║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
                                                    


   Arch Linux Installation Script
"
    echo "Welcome to the Arch Linux Installation Script"
    echo "This script will help you install and configure Arch Linux."
    echo "Press Enter to continue..."
    read
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Function to list available drives
list_drives() {
    echo "Available drives:"
    lsblk -f
    echo ""
    read -p "Enter the drive to install Arch Linux on (e.g., /dev/sda): " DRIVE
}

# Function to format and mount drive
format_and_mount() {
    # Unmount any existing partitions
    umount -R /mnt 2>/dev/null || true
    
    # Create partition table
    parted -s "$DRIVE" mklabel gpt
    
    # Create partitions
    parted -s "$DRIVE" mkpart primary fat32 1MiB 513MiB
    parted -s "$DRIVE" set 1 esp on
    parted -s "$DRIVE" mkpart primary ext4 513MiB 100%
    
    # Format partitions
    mkfs.fat -F32 "${DRIVE}1"
    mkfs.ext4 "${DRIVE}2"
    
    # Mount partitions
    mount "${DRIVE}2" /mnt
    mkdir -p /mnt/boot/efi
    mount "${DRIVE}1" /mnt/boot/efi
}

# Function to make drive bootable
make_bootable() {
    echo "Setting up bootloader..."
    
    # Install bootloader and related packages
    pacstrap /mnt grub efibootmgr os-prober
    
    # Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    
    # Install GRUB
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    
    # Configure GRUB
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    
    # Enable os-prober if it exists
    if [ -f /mnt/etc/default/grub ]; then
        sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /mnt/etc/default/grub
        arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    fi
    
    echo "Bootloader setup complete."
}

# Function to enable multilib
enable_multilib() {
    # Check if multilib is already enabled
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo "Enabling multilib repository..."
        # Add multilib section if it doesn't exist
        echo "[multilib]" >> /etc/pacman.conf
        echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
    elif grep -q "^#\[multilib\]" /etc/pacman.conf; then
        echo "Enabling multilib repository..."
        # Uncomment multilib section if it's commented out
        sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    else
        echo "Multilib repository is already enabled."
    fi
    
    # Sync repositories
    pacman -Sy
}

# Function to install base system
install_base() {
    pacstrap /mnt base base-devel linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Function to detect graphics card and install drivers
install_graphics_drivers() {
    if lspci | grep -i "nvidia" > /dev/null; then
        pacstrap /mnt nvidia nvidia-utils
    elif lspci | grep -i "amd" > /dev/null; then
        pacstrap /mnt xf86-video-amdgpu
    elif lspci | grep -i "intel" > /dev/null; then
        pacstrap /mnt xf86-video-intel
    fi
}

# Function to detect VM and set resolution
setup_vm_resolution() {
    if systemd-detect-virt; then
        pacstrap /mnt xorg-server xorg-xrandr
        cat > /mnt/etc/X11/xorg.conf.d/10-vm.conf << EOF
Section "Monitor"
    Identifier "Virtual1"
    Modeline "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
    Option "PreferredMode" "1920x1080_60.00"
EndSection

Section "Screen"
    Identifier "Screen0"
    Monitor "Virtual1"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080_60.00"
    EndSubSection
EndSection
EOF
    fi
}

# Function to install AUR helper
install_aur_helper() {
    echo "Choose your AUR helper:"
    echo "1. yay"
    echo "2. paru"
    echo "3. trizen"
    echo "4. pikaur"
    echo "5. aurman"
    
    read -p "Enter your choice (1-5): " aur_choice
    
    case $aur_choice in
        1)
            AUR_HELPER="yay"
            pacstrap /mnt git base-devel
            arch-chroot /mnt bash -c "cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"
            ;;
        2)
            AUR_HELPER="paru"
            pacstrap /mnt git base-devel
            arch-chroot /mnt bash -c "cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm"
            ;;
        3)
            AUR_HELPER="trizen"
            pacstrap /mnt git base-devel
            arch-chroot /mnt bash -c "cd /tmp && git clone https://aur.archlinux.org/trizen.git && cd trizen && makepkg -si --noconfirm"
            ;;
        4)
            AUR_HELPER="pikaur"
            pacstrap /mnt git base-devel
            arch-chroot /mnt bash -c "cd /tmp && git clone https://aur.archlinux.org/pikaur.git && cd pikaur && makepkg -si --noconfirm"
            ;;
        5)
            AUR_HELPER="aurman"
            pacstrap /mnt git base-devel
            arch-chroot /mnt bash -c "cd /tmp && git clone https://aur.archlinux.org/aurman.git && cd aurman && makepkg -si --noconfirm"
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install AUR packages
install_aur_package() {
    local package=$1
    arch-chroot /mnt bash -c "$AUR_HELPER -S --noconfirm $package"
}

# Function to select display manager
select_display_manager() {
    echo "Choose your display manager:"
    echo "1. SDDM (Modern and feature-rich)"
    echo "2. LightDM (Lightweight and flexible)"
    echo "3. LXDM (Lightweight X11 Display Manager)"
    echo "4. Entrance (Enlightenment Display Manager)"
    
    read -p "Enter your choice (1-4): " dm_choice
    
    case $dm_choice in
        1)
            pacstrap /mnt sddm
            arch-chroot /mnt systemctl enable sddm
            ;;
        2)
            pacstrap /mnt lightdm lightdm-gtk-greeter
            arch-chroot /mnt systemctl enable lightdm
            ;;
        3)
            pacstrap /mnt lxdm
            arch-chroot /mnt systemctl enable lxdm
            ;;
        4)
            pacstrap /mnt entrance
            arch-chroot /mnt systemctl enable entrance
            ;;
        *)
            echo "Invalid choice, defaulting to LightDM"
            pacstrap /mnt lightdm lightdm-gtk-greeter
            arch-chroot /mnt systemctl enable lightdm
            ;;
    esac
}

# Function to install desktop environment
install_desktop_environment() {
    echo "Choose your desktop environment:"
    echo "1. KDE Plasma (Highly customizable)"
    echo "2. Cinnamon (Beginner Friendly)"
    echo "3. GNOME (Popular and feature-rich)"
    echo "4. LXDE (Lightweight and simple)"
    echo "5. LXQt (Minimalist and lightweight)"
    echo "6. XFCE (Modular and flexible)"
    echo "7. MATE (Classic and user-friendly)"
    echo "8. i3wm (Powerful tiling window manager)"
    echo "9. AwesomeWM (Powerful and flexible)"
    echo "10. Openbox (Lightweight and configurable)"
    echo "11. Hyprland (Advanced)"
    
    read -p "Enter your choice (1-11): " de_choice
    
    case $de_choice in
        1)
            pacstrap /mnt plasma kde-applications
            ;;
        2)
            pacstrap /mnt cinnamon
            ;;
        3)
            pacstrap /mnt gnome gnome-extra
            ;;
        4)
            pacstrap /mnt lxde
            ;;
        5)
            pacstrap /mnt lxqt
            ;;
        6)
            pacstrap /mnt xfce4 xfce4-goodies
            ;;
        7)
            pacstrap /mnt mate mate-extra
            ;;
        8)
            pacstrap /mnt i3
            install_rofi
            ;;
        9)
            pacstrap /mnt awesome
            install_rofi
            ;;
        10)
            pacstrap /mnt openbox
            install_rofi
            ;;
        11)
            pacstrap /mnt hyprland
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
    
    # Let user select display manager after DE installation
    select_display_manager
}

# Function to install rofi
install_rofi() {
    pacstrap /mnt rofi
}

# Function to install web browser
install_web_browser() {
    echo "Choose your web browser:"
    echo "1. Firefox"
    echo "2. qutebrowser"
    echo "3. Brave Browser"
    echo "4. Thorium"
    echo "5. Floorp"
    echo "6. Vivaldi"
    echo "7. Google Chrome"
    echo "8. Microsoft Edge"
    
    read -p "Enter your choice (1-8): " browser_choice
    
    case $browser_choice in
        1)
            pacstrap /mnt firefox
            ;;
        2)
            pacstrap /mnt qutebrowser
            ;;
        3)
            pacstrap /mnt brave
            ;;
        4)
            pacstrap /mnt thorium-browser
            ;;
        5)
            pacstrap /mnt floorp
            ;;
        6)
            pacstrap /mnt vivaldi
            ;;
        7)
            pacstrap /mnt google-chrome
            ;;
        8)
            pacstrap /mnt microsoft-edge-stable-bin
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
    echo "2. WPS Office"
    echo "3. OnlyOffice"
    echo "4. OpenOffice"
    
    read -p "Enter your choice (1-4): " office_choice
    
    case $office_choice in
        1)
            pacstrap /mnt libreoffice-fresh
            ;;
        2)
            pacstrap /mnt wps-office
            ;;
        3)
            pacstrap /mnt onlyoffice-bin
            ;;
        4)
            pacstrap /mnt openoffice
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install gaming software
install_gaming_software() {
    echo "Choose gaming software to install:"
    echo "1. Lutris"
    echo "2. Steam"
    echo "3. LibRetro"
    echo "4. Wine"
    echo "5. All of the above"
    
    read -p "Enter your choice (1-5): " gaming_choice
    
    case $gaming_choice in
        1)
            pacstrap /mnt lutris
            ;;
        2)
            pacstrap /mnt steam
            ;;
        3)
            pacstrap /mnt retroarch
            ;;
        4)
            pacstrap /mnt wine winetricks
            ;;
        5)
            pacstrap /mnt lutris steam retroarch wine winetricks
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install terminal
install_terminal() {
    echo "Choose your terminal:"
    echo "1. Alacritty"
    echo "2. Kitty"
    echo "3. lxterminal"
    echo "4. GNOME Terminal"
    echo "5. Terminator"
    echo "6. Konsole"
    
    read -p "Enter your choice (1-6): " terminal_choice
    
    case $terminal_choice in
        1)
            pacstrap /mnt alacritty
            ;;
        2)
            pacstrap /mnt kitty
            ;;
        3)
            pacstrap /mnt lxterminal
            ;;
        4)
            pacstrap /mnt gnome-terminal
            ;;
        5)
            pacstrap /mnt terminator
            ;;
        6)
            pacstrap /mnt konsole
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Function to install multimedia apps
install_multimedia() {
    echo "Do you want to install multimedia apps? (y/n)"
    read -p "Enter your choice: " multimedia_choice
    
    if [[ $multimedia_choice =~ ^[Yy]$ ]]; then
        pacstrap /mnt kodi mpv clementine
    fi
}

# Function to install themes and utilities
install_themes_and_utilities() {
    # Install themes via git clone
    mkdir -p /mnt/usr/share/themes
    mkdir -p /mnt/usr/share/icons
    mkdir -p /mnt/usr/share/backgrounds
    
    # Clone themes
    arch-chroot /mnt bash -c "cd /usr/share/themes && git clone https://github.com/EliverLara/Nordic.git"
    arch-chroot /mnt bash -c "cd /usr/share/icons && git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git"
    arch-chroot /mnt bash -c "cd /usr/share/backgrounds && git clone https://github.com/phoenixstaryt/koenos-wallpapers"
    
    # Install utilities
    pacstrap /mnt breeze-cursor-theme pulseaudio pavucontrol networkmanager xarchiver zip unzip
    
    # Install terminal applications
    pacstrap /mnt vim ranger btop cava fastfetch starship variety
}

# Function to configure starship
configure_starship() {
    arch-chroot /mnt bash -c "echo 'eval \"\$(starship init bash)\"' >> /etc/bash.bashrc"
}

# Main function
main() {
    check_root
    show_welcome
    
    # Enable multilib at the start
    enable_multilib
    
    echo "Choose installation type:"
    echo "1. Beginner (Complete Desktop)"
    echo "2. Intermediate (Custom Installation)"
    
    read -p "Enter your choice (1-2): " install_type
    
    if [ "$install_type" == "1" ]; then
        # Beginner installation
        list_drives
        format_and_mount
        install_base
        install_graphics_drivers
        setup_vm_resolution
        make_bootable
        
        # Install complete desktop
        pacstrap /mnt cinnamon firefox libreoffice-fresh steam vlc
        arch-chroot /mnt systemctl enable lightdm
        
        # Install themes and utilities
        install_themes_and_utilities
        configure_starship
        
    else
        # Intermediate installation
        list_drives
        format_and_mount
        install_base
        install_graphics_drivers
        setup_vm_resolution
        make_bootable
        install_aur_helper
        install_desktop_environment
        install_web_browser
        install_office_suite
        install_gaming_software
        install_terminal
        install_multimedia
        install_themes_and_utilities
        configure_starship
    fi
    
    echo "Installation complete! Please reboot your system."
    echo "Press Enter to reboot..."
    read
    reboot
}

# Run the main function
main 