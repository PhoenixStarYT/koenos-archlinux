#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display ASCII art
display_ascii_art() {
    echo -e "${GREEN}"
    cat << "EOF"


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
                                                    


                                                                        
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}Arch Linux Installation Script${NC}"
    echo -e "${YELLOW}=============================${NC}"
    echo
}

# Function to print colored output
print_message() {
    echo -e "${GREEN}[*] $1${NC}"
}

print_error() {
    echo -e "${RED}[!] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

# Function to list available drives
list_drives() {
    print_message "Available drives:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
}

# Function to format drive
format_drive() {
    local drive=$1
    print_warning "WARNING: This will erase all data on /dev/$drive"
    read -p "Are you sure you want to continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create partition table
        print_message "Creating partition table..."
        sgdisk --zap-all /dev/$drive
        sgdisk --new=1:0:+512M --typecode=1:ef00 /dev/$drive
        sgdisk --new=2:0:0 --typecode=2:8300 /dev/$drive
        sgdisk --clear /dev/$drive

        # Format partitions
        print_message "Formatting partitions..."
        mkfs.fat -F32 /dev/${drive}1
        mkfs.ext4 /dev/${drive}2

        # Mount partitions
        print_message "Mounting partitions..."
        mount /dev/${drive}2 /mnt
        mkdir -p /mnt/boot/efi
        mount /dev/${drive}1 /mnt/boot/efi
    else
        print_error "Installation cancelled"
        exit 1
    fi
}

# Function to install base system
install_base() {
    print_message "Installing base system..."
    pacstrap /mnt base base-devel linux linux-firmware
    genfstab -U /mnt > /mnt/etc/fstab
}

# Function to enable multilib
enable_multilib() {
    print_message "Enabling multilib repository..."
    sed -i '/\[multilib\]/,/^$/ s/^#//' /etc/pacman.conf
    sed -i '/^#Include = \/etc\/pacman.d\/mirrorlist$/ s/^#//' /etc/pacman.conf
    pacman -Sy
}

# Function to install AUR helper
install_aur_helper() {
    print_message "Available AUR helpers:"
    echo "1) yay"
    echo "2) paru"
    echo "3) trizen"
    echo "4) pikaur"
    echo "5) aurutils"
    read -p "Choose an AUR helper (1-5): " aur_choice

    case $aur_choice in
        1) aur_helper="yay" ;;
        2) aur_helper="paru" ;;
        3) aur_helper="trizen" ;;
        4) aur_helper="pikaur" ;;
        5) aur_helper="aurutils" ;;
        *) print_error "Invalid choice"; return 1 ;;
    esac

    print_message "Installing $aur_helper..."
    cd /mnt/root
    git clone https://aur.archlinux.org/$aur_helper.git
    cd $aur_helper
    makepkg -si --noconfirm
    cd /
}

# Function to install web browser
install_web_browser() {
    print_message "Choose web browser:"
    echo "1) Firefox"
    echo "2) qutebrowser"
    echo "3) Brave Browser"
    echo "4) Thorium"
    echo "5) Floorp"
    echo "6) Vivaldi"
    echo "7) Google Chrome"
    echo "8) Microsoft Edge"
    read -p "Enter your choice (1-8): " browser_choice
    
    case $browser_choice in
        1) browser_pkg="firefox" ;;
        2) browser_pkg="qutebrowser" ;;
        3) browser_pkg="brave-browser" ;;
        4) browser_pkg="thorium-browser-bin" ;;
        5) browser_pkg="floorp" ;;
        6) browser_pkg="vivaldi" ;;
        7) browser_pkg="google-chrome" ;;
        8) browser_pkg="microsoft-edge-stable-bin" ;;
        *) print_error "Invalid choice"; return 1 ;;
    esac
    
    if [[ $browser_pkg == *"bin"* ]]; then
        arch-chroot /mnt bash -c "yay -S --noconfirm $browser_pkg"
    else
        pacstrap /mnt $browser_pkg
    fi
}

# Function to install desktop environment
install_desktop_environment() {
    print_message "Choose desktop environment:"
    echo "1) KDE Plasma"
    echo "2) Cinnamon (Beginner Friendly)"
    echo "3) GNOME"
    echo "4) LXDE"
    echo "5) LXQt"
    echo "6) XFCE"
    echo "7) MATE"
    echo "8) i3wm"
    echo "9) AwesomeWM"
    echo "10) Openbox"
    echo "11) Hyprland (Advanced)"
    read -p "Enter your choice (1-11): " de_choice
    
    case $de_choice in
        1) de_pkg="plasma-meta kde-applications" ;;
        2) de_pkg="cinnamon" ;;
        3) de_pkg="gnome gnome-extra" ;;
        4) de_pkg="lxde" ;;
        5) de_pkg="lxqt" ;;
        6) de_pkg="xfce4 xfce4-goodies" ;;
        7) de_pkg="mate mate-extra" ;;
        8) de_pkg="i3" ;;
        9) de_pkg="awesome" ;;
        10) de_pkg="openbox" ;;
        11) de_pkg="hyprland" ;;
        *) print_error "Invalid choice"; return 1 ;;
    esac
    
    pacstrap /mnt $de_pkg
    
    # Install additional packages for tiling window managers
    if [[ $de_choice == "8" ]] || [[ $de_choice == "9" ]] || [[ $de_choice == "10" ]]; then
        pacstrap /mnt pcmanfm rofi
        # Set rofi as default application launcher
        arch-chroot /mnt bash -c "echo 'exec rofi' >> /etc/skel/.xinitrc"
    fi
}

# Function to install terminal
install_terminal() {
    print_message "Choose terminal emulator:"
    echo "1) Alacritty"
    echo "2) Kitty"
    echo "3) lxterminal"
    echo "4) GNOME Terminal"
    echo "5) Terminator"
    echo "6) Konsole"
    read -p "Enter your choice (1-6): " terminal_choice
    
    case $terminal_choice in
        1) terminal_pkg="alacritty" ;;
        2) terminal_pkg="kitty" ;;
        3) terminal_pkg="lxterminal" ;;
        4) terminal_pkg="gnome-terminal" ;;
        5) terminal_pkg="terminator" ;;
        6) terminal_pkg="konsole" ;;
        *) print_error "Invalid choice"; return 1 ;;
    esac
    
    pacstrap /mnt $terminal_pkg
}

# Function to install multimedia apps
install_multimedia() {
    print_message "Install multimedia applications? (y/N)"
    read -p "Enter your choice: " multimedia_choice
    if [[ $multimedia_choice =~ ^[Yy]$ ]]; then
        pacstrap /mnt kodi mpv clementine
    fi
}

# Function to install themes and icons
install_themes() {
    print_message "Installing themes and icons..."
    arch-chroot /mnt bash -c "yay -S --noconfirm breeze-cursor-theme tela-circle-icon-theme nordic-theme"
    
    # Set themes based on desktop environment
    if [[ $de_choice == "1" ]]; then
        # KDE Plasma
        arch-chroot /mnt bash -c "kwriteconfig5 --file ~/.config/kdeglobals --group General --key ColorScheme Nordic"
        arch-chroot /mnt bash -c "kwriteconfig5 --file ~/.config/kdeglobals --group Icons --key Theme Tela-circle-dark"
        arch-chroot /mnt bash -c "kwriteconfig5 --file ~/.config/kdeglobals --group General --key CursorTheme Breeze"
    else
        # GTK-based desktops
        arch-chroot /mnt bash -c "gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'"
        arch-chroot /mnt bash -c "gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dark'"
        arch-chroot /mnt bash -c "gsettings set org.gnome.desktop.interface cursor-theme 'Breeze'"
    fi
}

# Function to install terminal applications
install_terminal_apps() {
    print_message "Installing terminal applications..."
    pacstrap /mnt vim ranger btop cava fastfetch starship
    
    # Configure Starship prompt
    arch-chroot /mnt bash -c "echo 'eval \"\$(starship init bash)\"' >> /etc/bash.bashrc"
}

# Function to setup wallpapers
setup_wallpapers() {
    print_message "Setting up wallpapers..."
    arch-chroot /mnt bash -c "cd /usr/share/wallpapers && git clone https://github.com/phoenixstaryt/koenos-wallpapers"
    pacstrap /mnt variety
    arch-chroot /mnt bash -c "mkdir -p /home/\$SUDO_USER/.config/variety"
    arch-chroot /mnt bash -c "echo '/usr/share/wallpapers/koenos-wallpapers' > /home/\$SUDO_USER/.config/variety/variety.conf"
}

# Function to install utilities
install_utilities() {
    print_message "Installing utilities..."
    pacstrap /mnt pulseaudio pavucontrol networkmanager xarchiver zip unzip
}

# Function to detect and install graphics drivers
install_graphics_drivers() {
    print_message "Detecting graphics card..."
    if lspci | grep -i nvidia > /dev/null; then
        print_message "NVIDIA GPU detected, installing drivers..."
        pacstrap /mnt nvidia nvidia-utils nvidia-settings
    elif lspci | grep -i amd > /dev/null; then
        print_message "AMD GPU detected, installing drivers..."
        pacstrap /mnt xf86-video-amdgpu
    elif lspci | grep -i intel > /dev/null; then
        print_message "Intel GPU detected, installing drivers..."
        pacstrap /mnt xf86-video-intel
    fi
}

# Function to detect VM and set resolution
setup_vm_resolution() {
    if systemd-detect-virt -q; then
        print_message "Virtual machine detected, setting up resolution..."
        pacstrap /mnt xorg-server xorg-xinit
        arch-chroot /mnt bash -c "echo 'xrandr --output \$(xrandr | grep primary | cut -d\" \" -f1) --mode 1920x1080' >> /etc/X11/xinit/xinitrc"
    fi
}

# Function for beginner installation
beginner_install() {
    print_message "Installing beginner setup with Cinnamon desktop..."
    
    # Install desktop environment and basic applications
    pacstrap /mnt cinnamon firefox libreoffice-fresh steam vlc
    
    # Install AUR helper
    install_aur_helper
    
    # Install themes
    print_message "Installing themes..."
    arch-chroot /mnt bash -c "yay -S --noconfirm nordic-theme"
    
    # Configure themes
    arch-chroot /mnt bash -c "gsettings set org.cinnamon.desktop.interface gtk-theme 'Nordic'"
    arch-chroot /mnt bash -c "gsettings set org.cinnamon.desktop.wm.preferences theme 'Nordic'"
    
    # Enable services
    arch-chroot /mnt bash -c "systemctl enable gdm.service"
    arch-chroot /mnt bash -c "systemctl enable NetworkManager.service"
    
    print_message "Beginner installation complete!"
}

# Function to install office suite
install_office_suite() {
    print_message "Choose office suite:"
    echo "1) LibreOffice"
    echo "2) WPS Office"
    echo "3) OnlyOffice"
    echo "4) OpenOffice"
    read -p "Enter your choice (1-4): " office_choice
    
    case $office_choice in
        1) office_pkg="libreoffice-fresh" ;;
        2) office_pkg="wps-office" ;;
        3) office_pkg="onlyoffice-desktopeditors" ;;
        4) office_pkg="openoffice" ;;
        *) print_error "Invalid choice"; return 1 ;;
    esac
    
    pacstrap /mnt $office_pkg
}

# Function to install gaming options
install_gaming_options() {
    print_message "Choose gaming options:"
    echo "1) Lutris"
    echo "2) Steam"
    echo "3) LibRetro"
    echo "4) Wine"
    echo "5) All of the above"
    read -p "Enter your choice (1-5): " gaming_choice
    
    case $gaming_choice in
        1) gaming_pkg="lutris" ;;
        2) gaming_pkg="steam" ;;
        3) gaming_pkg="retroarch" ;;
        4) gaming_pkg="wine" ;;
        5) gaming_pkg="lutris steam retroarch wine" ;;
        *) print_error "Invalid choice"; return 1 ;;
    esac
    
    pacstrap /mnt $gaming_pkg
}

# Function for intermediate installation
intermediate_install() {
    print_message "Starting intermediate installation..."
    
    # Install AUR helper first
    install_aur_helper
    
    # Install office suite
    install_office_suite
    
    # Install gaming options
    install_gaming_options
    
    # Install web browser
    install_web_browser
    
    # Install desktop environment
    install_desktop_environment
    
    # Install terminal
    install_terminal
    
    # Install multimedia apps
    install_multimedia
    
    # Install themes and icons
    install_themes
    
    # Install terminal applications
    install_terminal_apps
    
    # Setup wallpapers
    setup_wallpapers
    
    # Install utilities
    install_utilities
    
    # Install graphics drivers
    install_graphics_drivers
    
    # Setup VM resolution if needed
    setup_vm_resolution
    
    print_message "Intermediate installation complete!"
}

# Function to cleanup on exit
cleanup() {
    print_message "Cleaning up..."
    umount -R /mnt 2>/dev/null || true
    print_message "Cleanup complete"
}

# Function to check internet connection
check_internet() {
    print_message "Checking internet connection..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        print_error "No internet connection. Please check your connection and try again."
        exit 1
    fi
}

# Function to check if running in UEFI mode
check_uefi() {
    if [[ ! -d "/sys/firmware/efi" ]]; then
        print_error "This script requires UEFI mode. Please boot in UEFI mode and try again."
        exit 1
    fi
}

# Function to update system clock
update_clock() {
    print_message "Updating system clock..."
    timedatectl set-ntp true
}

# Function to create user
create_user() {
    print_message "Creating user..."
    read -p "Enter username: " username
    arch-chroot /mnt bash -c "useradd -m -G wheel -s /bin/bash $username"
    arch-chroot /mnt bash -c "echo '$username ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
    print_message "User $username created successfully"
}

# Function to set hostname
set_hostname() {
    print_message "Setting hostname..."
    read -p "Enter hostname: " hostname
    arch-chroot /mnt bash -c "echo $hostname > /etc/hostname"
    arch-chroot /mnt bash -c "echo '127.0.0.1 localhost' > /etc/hosts"
    arch-chroot /mnt bash -c "echo '::1 localhost' >> /etc/hosts"
    arch-chroot /mnt bash -c "echo '127.0.1.1 $hostname.localdomain $hostname' >> /etc/hosts"
}

# Function to set timezone
set_timezone() {
    print_message "Setting timezone..."
    arch-chroot /mnt bash -c "ln -sf /usr/share/zoneinfo/UTC /etc/localtime"
    arch-chroot /mnt bash -c "hwclock --systohc"
}

# Function to set locale
set_locale() {
    print_message "Setting locale..."
    arch-chroot /mnt bash -c "echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen"
    arch-chroot /mnt bash -c "locale-gen"
    arch-chroot /mnt bash -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
}

# Function to install bootloader
install_bootloader() {
    print_message "Installing bootloader..."
    pacstrap /mnt efibootmgr grub
    arch-chroot /mnt bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB"
    arch-chroot /mnt bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
}

# Update main function
main() {
    # Set up trap for cleanup
    trap cleanup EXIT
    
    # Display ASCII art
    display_ascii_art
    
    print_message "Starting Arch Linux installation..."
    
    # Initial checks
    check_internet
    check_uefi
    update_clock
    
    # List available drives
    list_drives
    
    # Get drive selection from user
    read -p "Enter the drive name to install Arch Linux (e.g., sda): " drive
    
    # Format and mount drive
    format_drive $drive
    
    # Enable multilib
    enable_multilib
    
    # Install base system
    install_base
    
    # Set up system configuration
    set_hostname
    set_timezone
    set_locale
    create_user
    
    # Ask for installation type
    print_message "Choose installation type:"
    echo "1) Beginner (Complete desktop with Cinnamon)"
    echo "2) Intermediate (Custom installation)"
    read -p "Enter your choice (1/2): " install_type
    
    if [ "$install_type" = "1" ]; then
        beginner_install
    else
        intermediate_install
    fi
    
    # Install bootloader
    install_bootloader
    
    print_message "Installation complete! You can now reboot your system."
    print_message "After reboot, log in with your user account and enjoy your new Arch Linux installation!"
}

# Run main function
main
