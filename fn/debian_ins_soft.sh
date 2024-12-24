#!/bin/bash

function fn_install (){

    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION INSTALL"

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"

	local current_dir=$(pwd)
	
# Definir la lista de paquetes a instalar
    local -a sf_install=(
        "rsyslog" 
        "libpam-apparmor" 
        "libpam-cgroup" 
        "libpam-passwdqc" 
        "libpam-shield" 
        "libpam-tmpdir" 
        "passwdqc" 
        "fail2ban" 
        "debsums" 
        "apache2" 
        "apparmor" 
        "gnome-shell-extension-dashtodock" 
        "ufw" 
        "rkhunter" 
        "gufw" 
        "usbguard"
        "vlc"
        "apt-listbugs"
        "lynis"
        "python3 python3-dev"
        "nvme-cli"
    )

    for INS_TAL in "${sf_install[@]}"; do

        if ! dpkg -l --no-pager | awk '/^ii/ {print $2}' | grep -q "^${INS_TAL}$"; then

            sudo apt-get install -y "$INS_TAL"

        fi

    done
    
    sudo apt-get install "${current_dir}/soft/visual_code.deb" -y

    apt-get remove --purge vlc-plugin-samba -y
    apt-get remove --purge vlc-plugin-access-extra -y
    apt-get remove --purge -y "libvncclient1" -y
    
    apt-get purge `dpkg --list | grep ^rc | awk '{ print $2; }'` -y

}

fn_install
