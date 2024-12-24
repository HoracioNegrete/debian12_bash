#!/bin/bash

function fn_ufw () {

    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION UFW"

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"

    local vr_ufw="false"

    # Verificar la instalcion de ufw
    if dpkg -l | awk '/^ii/ {print $2}' | grep "ufw" > /dev/null 2>&1; then
        
        sudo /lib/systemd/systemd-sysv-install enable ufw
        sudo ufw enable
        sudo systemctl start ufw
        vr_ufw="true"

    else 

        sudo apt-get install ufw -y
        sudo /lib/systemd/systemd-sysv-install enable ufw
        sudo ufw enable
        sudo systemctl start ufw
        vr_ufw="true"

    fi

    # Definir la lista de filtros tcp
    local -a filtro_tcp=(
        "/usr/sbin/ufw deny out log from any port 21 to any port 21"
        "/usr/sbin/ufw deny in log from any port 21 to any port 21"
        "/usr/sbin/ufw deny out from any port 22 to any port 22"
        "/usr/sbin/ufw deny in log from any port 22 to any port 22"
        "/usr/sbin/ufw deny out proto tcp from any to any port 23"
        "/usr/sbin/ufw deny in log from any port 23 to any port 23"
        "/usr/sbin/ufw deny out from any port 25 to any port 25"
        "/usr/sbin/ufw deny in log from any port 25 to any port 25"
        "/usr/sbin/ufw deny out from any port 110 to any port 110"
        "/usr/sbin/ufw deny in log from any port 110 to any port 110 "
        "/usr/sbin/ufw deny out from any port 137 to any port 137"
        "/usr/sbin/ufw deny in log from any port 137 to any port 137 "
        "/usr/sbin/ufw deny out from any port 138 to any port 138"
        "/usr/sbin/ufw deny in log from any port 138 to any port 138"
        "/usr/sbin/ufw deny out from any port 139 to any port 139"
        "/usr/sbin/ufw deny in log from any port 139 to any port 139"
        "/usr/sbin/ufw deny out proto tcp from any to any port 143"
        "/usr/sbin/ufw deny in log from any port 143 to any port 143"
        "/usr/sbin/ufw deny out from any port 445 to any port 445"
        "/usr/sbin/ufw deny in log from any port 445 to any port 445"
        "/usr/sbin/ufw deny out from any port 631 to any port 631"
        "/usr/sbin/ufw deny in log from any port 631 to any port 631"
        "/usr/sbin/ufw deny out from any port 1900 to any port 1900"
        "/usr/sbin/ufw deny in log from any port 1900 to any port 1900"
        "/usr/sbin/ufw deny out from any port 2213 to any port 2213"
        "/usr/sbin/ufw deny in log from any port 2213 to any port 2213"
        "/usr/sbin/ufw deny out from any port 4500 to any port 4500"
        "/usr/sbin/ufw deny in log from any port 4500 to any port 4500"
        "/usr/sbin/ufw deny out from any port 5222 to any port 5222"
        "/usr/sbin/ufw deny in log from any port 5222 to any port 5222"
        "/usr/sbin/ufw deny out from any port 6666 to any port 6666"
        "/usr/sbin/ufw deny in log from any port 6666 to any port 6666"
        "/usr/sbin/ufw deny out from any port 6667 to any port 6667"
        "/usr/sbin/ufw deny in log from any port 6667 to any port 6667"
        "/usr/sbin/ufw deny out from any port 8080 to any port 8080"
        "/usr/sbin/ufw deny in log from any port 8080 to any port 8080"
        "/usr/sbin/ufw deny out from any port 9000 to any port 9000"
        "/usr/sbin/ufw deny in log from any port 9000 to any port 9000"
        "/usr/sbin/ufw deny 1234,2213,4444,5004,6881/udp"
        "/usr/sbin/ufw deny in 1234,2213,4444,5004,6881/udp"
        "/usr/sbin/ufw allow in proto tcp from any to any port 80"
    )

    local -a IP_BLOCK=(
        "34.107.243.93"
        "194.50.16.198"
        "222.138.179.242"
        "113.53.185.208"
    )

    if [ "$vr_ufw" == "true" ]; then

        # Recorrer la lista de filtros tcp
        for filtro in "${filtro_tcp[@]}"; do

            sudo $filtro

        done

        # Recorrer las direciones ip bloqueadas

        for IP_B in "${IP_BLOCK[@]}"; do

            echo "Bloqueando IP: $IP_B"

            sudo ufw deny from "$IP_B"

            sudo ufw deny to "$IP_B"

        done

    fi

    sudo ufw logging on

    systemctl restart ufw

    # Limpiar cache de memoria.
    sync; echo 3 > /proc/sys/vm/drop_caches

}

fn_ufw

exit