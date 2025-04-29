#!/bin/bash

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
██╔═██╗ ██║   ██║██╔     ██║╚██ ██║██║   ██║╚════██║
██║  ██╗╚██████╔╝███████╗██║ ╚████║╚██████╔╝███████║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
"
    echo "Welcome to the Arch Linux Installation Script"
    echo "This script will guide you through the installation process."
    echo "Press Enter to continue..."
    read
}

# Function to list available drives
list_drives() {
    echo "Available drives:"
    lsblk -d -o NAME,SIZE,MODEL
    echo
}

# Function to get drive selection from user
get_drive_selection() {
    local drive
    while true; do
        list_drives
        read -rp "Enter the drive name to install Arch Linux (e.g., /dev/sda): " drive
        if [ -b "$drive" ]; then
            echo "Selected drive: $drive"
            read -rp "WARNING: This will erase all data on $drive. Continue? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                DRIVE="$drive"
                break
            fi
        else
            echo "Invalid drive. Please try again."
        fi
    done
}

# Function to partition the drive
partition_drive() {
    echo "Partitioning drive $DRIVE..."
    
    # Create GPT partition table
    sgdisk --zap-all "$DRIVE"
    sgdisk --clear "$DRIVE"
    
    # Create partitions
    # EFI partition (512MB)
    sgdisk --new=1:0:+512M --typecode=1:EF00 "$DRIVE"
    # Root partition (rest of the drive)
    sgdisk --new=2:0:0 --typecode=2:8300 "$DRIVE"
    
    # Format partitions
    mkfs.fat -F32 "${DRIVE}1"
    mkfs.ext4 "${DRIVE}2"
    
    # Mount partitions
    mount "${DRIVE}2" /mnt
    mkdir -p /mnt/boot/efi
    mount "${DRIVE}1" /mnt/boot/efi
}

# Function to get user input
get_user_input() {
    echo "Please enter the following information:"
    
    # Get hostname
    while true; do
        read -rp "Enter hostname: " HOSTNAME
        if [[ $HOSTNAME =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]]; then
            break
        else
            echo "Invalid hostname. Use only letters, numbers, and hyphens."
        fi
    done
    
    # Get username
    while true; do
        read -rp "Enter username: " USERNAME
        if [[ $USERNAME =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            break
        else
            echo "Invalid username. Use only lowercase letters, numbers, underscores, and hyphens."
        fi
    done
    
    # Get password
    while true; do
        read -rsp "Enter password: " PASSWORD
        echo
        read -rsp "Confirm password: " PASSWORD2
        echo
        if [ "$PASSWORD" = "$PASSWORD2" ]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
}

# Function to install base system
install_base_system() {
    echo "Installing base system..."
    pacstrap /mnt base base-devel linux linux-firmware
    
    # Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab
    
    # Set timezone
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    arch-chroot /mnt hwclock --systohc
    
    # Set locale
    echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen
    echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
    
    # Set hostname
    echo "$HOSTNAME" > /mnt/etc/hostname
    echo "127.0.0.1 localhost" >> /mnt/etc/hosts
    echo "::1 localhost" >> /mnt/etc/hosts
    echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /mnt/etc/hosts
    
    # Create user
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | arch-chroot /mnt chpasswd
    
    # Configure sudo
    echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers
    
    # Install bootloader
    arch-chroot /mnt bootctl install
    cat > /mnt/boot/loader/entries/arch.conf << EOF
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value "${DRIVE}2") rw
EOF
}

# Main installation process
main() {
    show_welcome
    get_drive_selection
    get_user_input
    partition_drive
    install_base_system
    
    # Copy the setup script to the new system
    cp setup.sh /mnt/home/$USERNAME/
    chmod +x /mnt/home/$USERNAME/setup.sh
    
    echo "Base system installation complete!"
    echo "After reboot, login as $USERNAME and run ./setup.sh to continue with the installation."
    echo "Press Enter to reboot..."
    read
    reboot
}

# Run the main function
main 