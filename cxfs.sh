#!/bin/bash

export RED='\033[0;31m'  
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

last_main_menu_index=0  
last_submenu_index=0    

display_main_menu() {
    while true; do
        choice=$(whiptail --title "Linux System Arch Setup" \
                          --menu "Choose an option" 15 60 4 \
                          --default-item "$((last_main_menu_index + 1))" \
                          "1" "Arch Setup" \
                          "2" "Help & Info" \
                          "3" "Exit" 3>&1 1>&2 2>&3)

        case $choice in
            1) last_main_menu_index=0; display_submenu ;;
            2) last_main_menu_index=1; display_help ;;
            3) last_main_menu_index=2; clear; exit 0 ;;
        esac
    done
}

load_scripts() {
    local script_dir="./scripts"
    scripts=()
    while IFS= read -r -d '' file; do
        script_name=$(basename "${file}" .sh)
        scripts+=("$script_name")
    done < <(find "$script_dir" -maxdepth 1 -name '*.sh' -print0)
}

display_submenu() {
    load_scripts

    while true; do
        script_list=()
        for i in "${!scripts[@]}"; do
            script_list+=("$((i + 1))" "${scripts[i]}")
        done
        script_list+=("$(( ${#scripts[@]} + 1 ))" "Exit")

        num_scripts=${#scripts[@]}
        menu_height=$((num_scripts + 7))

        ((menu_height > 20)) && menu_height=20

        CHOICE=$(dialog --default-item "$((last_submenu_index + 1))" \
                        --title "Arch Setup Options" --menu "Select a script to run" \
                        "$menu_height" 60 ${#script_list[@]} "${script_list[@]}" 3>&1 1>&2 2>&3)

        EXIT_STATUS=$?

        if [ $EXIT_STATUS -eq 1 ]; then
            break
        fi

        selected=$((CHOICE - 1))

        if [[ $selected -lt ${#scripts[@]} ]]; then
            last_submenu_index=$selected  
            run_script "${scripts[selected]}"
        else
            break
        fi
    done
}

run_script() {
    local script_name="$1"

    if [ "$script_name" = "Exit" ] || [ "$script_name" = "0" ]; then
        echo "Script aborted. Press Enter to return to the menu."
        read -r
        return 1  
    fi

    echo "Running ${script_name}..."

    if bash "./scripts/${script_name}.sh"; then
        echo "${script_name} completed successfully. Press Enter to return to the menu."
    else
        echo "${script_name} failed to complete. Press Enter to return to the menu."
    fi

    read -r  
}

display_help() {
    whiptail --msgbox "This tool helps to automate Arch Linux setup.\n\nSelect 'Arch Setup' to install packages and configure the system.\nFor more information, visit: https://harilvfs.github.io/carch/" 15 60
}

display_main_menu

