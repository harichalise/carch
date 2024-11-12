#!/bin/bash

tput init
tput clear

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "${BLUE}"
cat <<"EOF"
-----------------------------------------------------------------------------
 
██╗  ████████╗███████╗    ██╗  ██╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗     
██║  ╚══██╔══╝██╔════╝    ██║ ██╔╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║     
██║     ██║   ███████╗    █████╔╝ █████╗  ██████╔╝██╔██╗ ██║███████║██║     
██║     ██║   ╚════██║    ██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║     
███████╗██║   ███████║    ██║  ██╗███████╗██║  ██║██║ ╚████║██║  ██║███████╗
╚══════╝╚═╝   ╚══════╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
                                                                 
------------------------------------------------------------------------------
EOF
echo -e "${ENDCOLOR}"

check_current_kernel() {
    CURRENT_KERNEL=$(uname -r)
    echo -e "${BLUE}Current kernel version: ${GREEN}$CURRENT_KERNEL${ENDCOLOR}"
    if [[ "$CURRENT_KERNEL" == *"lts"* ]]; then
        echo -e "${GREEN}You are already using the LTS kernel. Skipping the installation.${ENDCOLOR}"
        exit 0
    fi
}

install_lts_kernel() {
    echo -e "${GREEN}Installing LTS kernel and headers...${ENDCOLOR}"
    sudo pacman -S --needed linux-lts linux-lts-docs linux-lts-headers
}

configure_grub() {
    echo -e "${GREEN}Updating GRUB configuration...${ENDCOLOR}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

check_exit() {
    if [[ "$1" =~ ^[Ee]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
}

echo -e "${RED}Warning: If you are using systemd or EFI boot and not GRUB, you will need to manually select or set up the LTS kernel after installation.${ENDCOLOR}"
echo -e "${RED}If you don't know about kernel changes, it's recommended to [E] exit the script.${ENDCOLOR}"

read -p "Do you want to continue with the kernel installation? [Y/N/E] " continue_install
continue_install=${continue_install:-Y}
check_exit "$continue_install"

if [[ ! $continue_install =~ ^[Yy]$ ]]; then
    echo "Exiting..."
    exit 0
fi

check_current_kernel

read -p "Do you want to remove the current kernel and install LTS? [Y/n/e] " remove_kernel
remove_kernel=${remove_kernel:-N}
check_exit "$remove_kernel"

if [[ $remove_kernel =~ ^[Yy]$ ]]; then
    install_lts_kernel
    echo -e "${GREEN}Removing the current kernel...${ENDCOLOR}"
    
    CURRENT_KERNEL_NAME=$(uname -r | sed 's/-[^-]*$//')  
    if [[ "$CURRENT_KERNEL_NAME" != "linux" ]]; then
        echo -e "${RED}Current kernel name does not match expected 'linux'. Cannot remove kernel.${ENDCOLOR}"
        exit 1
    fi

    sudo pacman -Rns --noconfirm "$CURRENT_KERNEL_NAME"
    echo -e "${GREEN}Removed the current kernel.${ENDCOLOR}"
    
    configure_grub

else
    read -p "Do you want to install LTS kernel only without removing the current kernel? [Y/n/e] " install_only
    install_only=${install_only:-Y}
    check_exit "$install_only"

    if [[ $install_only =~ ^[Yy]$ ]]; then
        install_lts_kernel
        
        configure_grub
    else
        echo "Exiting..."
        exit 0
    fi
fi

echo -e "${GREEN}LTS kernel setup completed. Please check GRUB or select the LTS kernel from the GRUB menu.${ENDCOLOR}"

