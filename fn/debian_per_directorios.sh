#!/bin/bash

function fn_sudoers () {

    # Importar la función
    source fn/colores.sh
    local VAR_RM="FUNCION PERMISOS DIRECTORIOS DIRECTORIOS"

    sudo find /etc/sudoers.d -type d -exec chmod 755 {} \;
    sudo find /etc/sudoers.d -type f -exec chmod 440 {} \;
    sudo find /etc/sudoers.d -type d -exec chown root:root {} \;
    sudo find /etc/sudoers.d -type f -exec chown root:root {} \;

    sudo sysctl -p

    # Impresion de aviso.
    FN_COLOR "RED" "$VAR_RM"

}

fn_sudoers


function fn_cron () {

    # Importamos funcion.
    source fn/colores.sh

    local VAR_RM="FUNCION DIRECTORIOS CRON"

    local ar_cron=(
        "/etc/cron.d"
        "/etc/cron.daily"
        "/etc/cron.hourly"
        "/etc/cron.weekly"
        "/etc/cron.monthly"
        )

    local f_cron

    for f_cron in ${ar_cron[@]}; do

        chown root:root $f_cron
        chmod 440 $f_cron
        
    done

    # Impresion de aviso.
    FN_COLOR "RED" "$VAR_RM"

}

fn_cron

exit
