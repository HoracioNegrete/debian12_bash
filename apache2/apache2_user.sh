#!/bin/bash

function fn_apache () {

    # Iniciamos la creacion de usuarios asignando el valor a las variables
    local vr_group_name=$1
    local vr_user_name=$1

    # Verificamos si el usuario o grupo existen
    local group_exists=$(getent group "$vr_group_name" > /dev/null 2>&1; echo $?)
    local user_exists=$(getent passwd "$vr_user_name" > /dev/null 2>&1; echo $?)

    # Verificamos si el usuario o grupo estan en uso
    local group_in_use=$(pgrep -g "$vr_group_name" > /dev/null 2>&1; echo $?)
    local user_in_use=$(pgrep -u "$vr_user_name" > /dev/null 2>&1; echo $?)

    # Creamos el usuario y el grupo si no existen.
    if [ $group_exists -ne 0 ] && [ $user_exists -ne 0 ]; then

        sudo adduser --system --no-create-home --group "$vr_user_name"
        echo "Se ha creado el usuario $vr_user_name, y el grupo $vr_group_name"

    # Si no estan en uso y existe el usuario o grupo los elimina y los vuelve a crear
    elif [ $group_exists -eq 0 ] && [ $user_exists -eq 0 ]; then

        if [ $user_in_use -ne 0 ] || [ $group_in_use -ne 0 ]; then

            echo "El usuario o grupo se encuentran en uso y no se pueden borrar"

        else

            if [ $user_exists -eq 0 ]; then

                sudo deluser --remove-home "$vr_user_name"

            fi

            if [ $group_exists -eq 0 ]; then

                sudo delgroup "$vr_group_name"

            fi

            sudo adduser --system --no-create-home --group "$vr_user_name"
           # echo "Se ha creado el usuario $vr_user_name, y el grupo $vr_group_name"

        fi

    fi

}

fn_apache "apache2" # >> log/apache_user.txt

echo "apache2_users"

exit
