#!/bin/bash

function fn_group_del (){

    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION REMOVER USUARIOS"

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"

    local vr_group=(
        "fax"
        "voice"
        "floppy"
        "tape"
        "irc"
        "cdrom"
        "_ssh"
        "www-data"
        "scanner"
        "lpadmin"
        "bluetooth"
    )

    local vr_user=(
        "irc"
    )

    for group_name in "${vr_group[@]}"; do

      local group_exists=$(getent group "$group_name" > /dev/null 2>&1; echo $?)

      if [ $group_exists -eq 0 ]; then

        sudo groupdel "$group_name" > /dev/null 2>&1
        echo "$group_name"

      fi

    done

    for user in "${vr_user[@]}"; do

      local user_exists=$(getent passwd "$user" > /dev/null 2>&1; echo $?)

      if [ $user_exists -eq 0 ]; then
      
        sudo userdel -r "$user" > /dev/null 2>&1

      fi

    done

}

fn_group_del 
