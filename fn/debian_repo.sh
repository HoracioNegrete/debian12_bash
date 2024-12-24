#!/bin/bash

function fn_repo () {

    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION STOP"

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"

    local current_dir=$(pwd)

    sudo find /etc/apt/sources.list -type f -exec chmod 700 {} \;
    sudo find /etc/apt/sources.list -type f -exec chown root:root {} \;

    echo "#Repo Debian 12" >/etc/apt/sources.list
    echo "deb http://deb.debian.org/debian bookworm main non-free-firmware" >>/etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian bookworm main non-free-firmware" >>/etc/apt/sources.list

    echo "deb http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware" >>/etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware" >>/etc/apt/sources.list

    echo "deb http://deb.debian.org/debian bookworm-updates main non-free-firmware" >>/etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian bookworm-updates main non-free-firmware" >>/etc/apt/sources.list

    sudo find /etc/apt/sources.list -type f -exec chmod 640 {} \;

    sudo apt-get update -y # 2>>"${current_dir}/log/error_repo.txt" 
	sudo apt-get upgrade -y # 2>>"${current_dir}/log/error_repo.txt" 
    sudo apt autoremove --purge -y
    
}

fn_repo #>> log/debian_repo.txt
