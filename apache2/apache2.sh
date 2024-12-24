#!/bin/bash

function fn_apache2_conf  () {

    local vr_aplication="apache2"
    local package_installed=$(dpkg -l --no-pager | awk '/^ii/ {print $2}' | grep -q "^${vr_aplication}$")

    if [ -n "$package_installed" ]; then

        echo "El paquete $package_installed se encuentra instalado"

    else

        sudo apt-get install apache2 -y > /dev/null 2>&1
        sudo systemctl start apache2
        sudo systemctl enable apache2

    fi

    local vr_local_web="/var/www/html/web/"
    local vr_user=$1
    local vr_group=$1

    # Comprobamos si el directorio existe.
    if [ ! -d "$vr_local_web" ]; then
	
        # Cambiado a -p para evitar errores
        mkdir -p /var/www/html/web
        local vr_dir="true"

    fi

    if [ "$vr_dir" == "true" ]; then

        sudo chmod -R u=rx,g=r,o=r "$vr_local_web"
        
        sudo chown -R "$vr_user:$vr_group" $vr_local_web

    fi

    systemctl restart apache2

    local vr_file_apache2="/etc/apache2/apache2.conf"
    local vr_dir_one="<Directory />"
    local vr_dir_two="<Directory /var/www/>"
    local vr_dir_close="</Directory>"

    local vr_opt_one="Options FollowSymLinks"
    local vr_opt_two="Options Indexes FollowSymLinks"

    local vr_server_name=""
    local vr_apache_localhost="ServerName localhost"
    
    sudo chmod -R u=w,g=-,o=- $vr_file_apache2

    if [ -f "$vr_file_apache2" ]; then
        
        # Archivo temporal para almacenar las líneas modificadas
        local temp_file_apache2conf

        temp_file_apache2conf=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

        # Lee el archivo y procesa cada línea
        while IFS= read -r line_apache2_conf || [ -n "$line_apache2_conf" ]; do

            if [[ "$line_apache2_conf" == "$vr_dir_one" ]]; then
                
                # Cargarmos el campo al archivo temporal
                echo "$line_apache2_conf" >> "$temp_file_apache2conf"

                local vr_dir="true"

            elif [[ "$line_apache2_conf" == *"$vr_opt_one" && "$vr_dir" == "true" ]]; then
                
                line_apache2_conf="${line_apache2_conf/FollowSymLinks/-FollowSymLinks}"

                # Cargarmos el campo al archivo temporal
                echo "$line_apache2_conf" >> "$temp_file_apache2conf"

                var_dir="false"

            elif [[ "$line_apache2_conf" == "$vr_dir_close" ]]; then

                # Cargarmos el campo al archivo temporal
                echo "$line_apache2_conf" >> "$temp_file_apache2conf"

                vr_dir="false"

            elif [[ "$line_apache2_conf" == "$vr_dir_two" ]]; then

                line_apache2_conf="${line_apache2_conf/"/var/www/"/$vr_local_web}"
                
                # Cargarmos el campo al archivo temporal
                echo "$line_apache2_conf" >> "$temp_file_apache2conf"
                
                local vr_dir="true"

            elif [[ "$line_apache2_conf" == *"$vr_opt_two" && "$vr_dir" == "true" ]]; then
                
                line_apache2_conf="${line_apache2_conf/Indexes/-Indexes}"
                line_apache2_conf="${line_apache2_conf/FollowSymLinks/-FollowSymLinks}"

                # Cargarmos el campo al archivo temporal
                echo "$line_apache2_conf" >> "$temp_file_apache2conf"
                printf '\t%s%s\n' "<LimitExcept POST DELETE HEAD PUT>" >> "$temp_file_apache2conf"
                printf '\t%s%s\n' "Deny from all" >> "$temp_file_apache2conf"
                printf '\t%s%s\n' "</LimitExcept>" >> "$temp_file_apache2conf"

                var_dir="false"

            elif [[ "$line_apache2_conf" == "$vr_dir_close" ]]; then

                # Cargarmos el campo al archivo temporal
                echo "$line_apache2_conf" >> "$temp_file_apache2conf"

                vr_dir="false"

            elif [[ "$line_apache2_conf" == "# Agregamos Local Host al final del archivo." || "$line_apache2_conf" == "$vr_apache_localhost" ]]; then

                local vr_server_name="true"

            else

                # Cargarmos el campo al archivo temporal
                echo "$line_apache2_conf" >> "$temp_file_apache2conf"

            fi

        done < "$vr_file_apache2"

        vr_server_name=""

        if [[ ! "$vr_server_name" == "true" ]]; then

            printf "\n# Agregamos Local Host al final del archivo.\n$vr_apache_localhost\n" >> "$temp_file_apache2conf"

        fi

        # Reemplazamos el archivo de origen
        mv "$temp_file_apache2conf" "$vr_file_apache2"

        # Limpieza: eliminar el archivo temporal
        rm -f "$temp_file_apache2conf"

    else

        echo "El archivo $vr_file_apache2 no existe"
        exit 1

    fi

    sudo chmod u=rx,g=r,o=- $vr_file_apache2

    systemctl reload apache2

}

fn_apache2_conf "apache2"

sudo "${PWD}/purge/purge_old.sh"> /dev/null 2>&1

# Limpiar cache de memoria.
sudo sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

echo "apache2"

exit    