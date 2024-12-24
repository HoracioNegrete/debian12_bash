#!/bin/bash

function fn_envvars () {

    local vr_run_user=$1
    local vr_run_group=$1

    local vr_envvars="/etc/apache2/envvars"
    local vr_env_01="export APACHE_RUN_USER=www-data"
    local vr_env_02="export APACHE_RUN_GROUP=www-data"

    # Archivo temporal para almacenar las líneas modificadas
    local temp_envvars=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

    # Verificar si el archivo existe
    if [ ! -f "$vr_envvars" ]; then

        echo "El archivo $vr_envvars no existe."
        exit 1

    fi

    while IFS= read -r line_envvars || [ -n "$line_envvars" ]; do

        if [[ "$line_envvars" == "$vr_env_01" ]]; then

            line_envvars="export APACHE_RUN_USER=$vr_run_user"
            echo "$line_envvars"  >> "$temp_envvars"

        elif [[ "$line_envvars" == "$vr_env_02" ]]; then

            line_envvars="export APACHE_RUN_GROUP=$vr_run_group"
            echo "$line_envvars"  >> "$temp_envvars"

        else

            echo "$line_envvars"  >> "$temp_envvars"

        fi

    done < "$vr_envvars"

    # Copia el archivo temporal sobre el archivo origen
    mv "$temp_envvars" "$vr_envvars"

    # Limpieza: eliminar el archivo temporal
    rm -f "$temp_envvars"
}

fn_envvars "apache2" >> log/apach2_envvars.txt

echo "apache2_envvars"

exit