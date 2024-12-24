#!/bin/bash

# Importar la función
source fn/colores.sh

function fn_remove () {

    local VAR_RM="FUNCION REMOVE"

	# Lista de paquetes a desinstalar
    local -a sf_remove=(
        "update-inetd"
        "inetutils-inetd"
        "libcurl3-gnutls"
        "inetutils-telnet"
        "eog"
        "seahorse"
        "gnome-characters"
        "transmission-gtk"
        "openssh-sk-helper"
        "openssh-sftp-server"
        "openssh-client"
        "openssh-known-hosts"
        "openssh-tests"
        "openssh-server"
        "openssh-client-ssh1"
        "libreoffice"
        "cups"
        "cups-common"
        "evolution"
        "cheese"
        "gnome-remote-desktop"
        "gnome-maps"
        "gnome-games"
        "bleachbit"
        "arp-scan"
        "gnome-sushi"
        "gnome-weather"
        "gnome-calendar"
        "gnome-clocks"
        "gnome-music"
        "gnome-sound-recorder"
        "gnome-text-editor"
        "rhythmbox"
        "shotwell"
        "simple-scan"
        "totem"
        "klotski"
        "wget"
    )

    # Forzar desintalacion de Libre Office
    sudo apt-get remove libreoffice* -y > /dev/null 2>&1

    # Impresion de aviso.
    FN_COLOR "RED" "$VAR_RM"

    sudo apt autoremove --purge -y

    # Obtener la lista de paquetes instalados
    local sf_installed=$(dpkg -l --no-pager | awk '/^ii/ {print $2}')

    # Recorrer la lista de paquetes a desinstalar
    for paquete in "${sf_remove[@]}"; do

        # Verificar si el paquete está instalado
        if echo "$sf_installed" | grep -q -x "$paquete"; then

            sudo apt-get remove --purge -y "$paquete"

        else

            echo "removido." >> /dev/null 2>&1;

        fi

    done

        sudo apt-get remove wget -y

        sudo apt-get autoremove --purge -y

}

fn_remove 

exit

