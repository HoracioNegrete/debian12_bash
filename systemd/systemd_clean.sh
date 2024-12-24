#!/bin/bash

# Importar la función
    source fn/colores.sh

function fn_SystemDClean () {

    local SystemClean=(
        "/etc/systemd/system/apache2.service.d/override.conf"
        "/etc/systemd/system/dbus.service.d/override.conf"
        "/etc/systemd/system/fail2ban.service.d/override.conf"
        "/etc/systemd/system/NetworkManager.service.d/override.conf"
        "/etc/systemd/system/accounts-daemon.service.d/override.conf"
        "/etc/systemd/system/avahi-daemon.service.d/override.conf"
    )

    for SysClean in "${SystemClean[@]}"; do

        if [ -f "$SysClean" ]; then

            sudo rm "$SysClean"

        fi

    done

    sudo systemctl daemon-reload
    exit
}

# Avahi-Daemon
function fn_SysAvahiOut () {

    local File_Avahi="/etc/systemd/system/avahi-daemon.service.d"

    if [ ! -d "$File_Avahi" ]; then

        sudo mkdir -p "$File_Avahi"

    fi

    {

        echo -e "[Service]\n""ExecStart=\n"

    } | sudo tee "$File_Avahi/override.conf" > /dev/null

    sudo systemctl disable avahi-daemon
    sudo systemctl stop avahi-daemon
    sudo systemctl daemon-reload

    exit

}

# BlueTooth
function DisableService() {

    local VAR_RM="FUNCION SYSTEM CLEAN"

    local services=(

        "bluetooth"
        "ModemManager"
        "avahi-daemon"

    )

    for service in "${services[@]}"; do

        if systemctl is-active --quiet "$service"; then

            echo "Deteniendo y desactivando $service..."
            systemctl stop "$service".service
            systemctl disable "$service".service
            sudo systemctl stop "$service".socket
            sudo systemctl mask "$service".socket

        else

            echo "$service no está en ejecución."

        fi

    done

    sudo systemctl daemon-reload
}

#
function fn_SystemAnalize (){

    sudo systemctl daemon-reload
    clear
    sudo systemd-analyze security

}

#
function fn_ServiceRunning (){

    clear
    sudo systemctl list-units --type=service --state=running
    exit

}

# Apache-Daemon-RM
function fn_apache_clean () {

    sudo rm "/etc/systemd/system/apache2.service.d/override.conf"

}

SystemRun=$1


        if [ "$SystemRun" == "Clean" ]; then

            fn_SystemDClean

        elif [ "$SystemRun" == "Run" ]; then

            ./systemd_Apache2.sh

        elif [ "$SystemRun" == "Avahi" ]; then

            fn_SysAvahiOut

        elif [ "$SystemRun" == "Blue" ]; then

            DisableService

        elif [ "$SystemRun" == "Security" ]; then

            fn_SystemAnalize

        elif [ "$SystemRun" == "Service" ]; then

            fn_ServiceRunning

        elif [ "$SystemRun" == "Apache" ]; then

            fn_apache_clean

        fi

sudo systemctl daemon-reload

exit
