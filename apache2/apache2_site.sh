#!/bin/bash

function fn_site_e() {

    local input_file_site_en="/etc/apache2/sites-enabled/000-default.conf"

    local input_file_ssl="/etc/apache2/sites-available/default-ssl.conf"

    local searched_value="DocumentRoot /var/www/html"

    local replacement_value="/web/"

    # Archivo temporal para almacenar las líneas modificadas default
    local temp_file_default=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

    # Archivo temporal para almacenar las líneas modificadas SSL
    local temp_file_ssl=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

    echo "iniciamos la rutina para el archivo 000-default"
    # Verificar si el archivo existe
    if [ -f "$input_file_site_en" ]; then

        while IFS= read -r file_site_en || [ -n "$file_site_en" ]; do

            if [[ "$file_site_en" == *"$searched_value"* ]]; then
		        
                #file_site_en="${file_site_en/searched_value*/replacement_value}"
                file_site_en="${searched_value/"/html"/"/html/web/"}"
                printf '\t%s%s\n' "$file_site_en" >> "$temp_file_default"

            else

                echo "$file_site_en" >> "$temp_file_default"

            fi

        done < "$input_file_site_en"

        mv "$temp_file_default" "$input_file_site_en"

        # Limpieza: eliminar el archivo temporal
        rm -f "$temp_file_default"



    else

        echo "El archivo $input_file_site_en no existe."

    fi

    # Verificar si el archivo SSL existe
    if [ -f "$input_file_ssl" ]; then

        while IFS= read -r line_ssl || [ -n "$line_ssl" ]; do

            if [[ "$line_ssl" == *"$searched_value"* && "$var_dir" == "true" ]]; then

                printf '\t%s%s\n' "$searched_value" "$replacement_value" >> "$temp_file_ssl"

            else

                echo "$line_ssl" >> "$temp_file_ssl"

            fi

        done < "$input_file_ssl"

        mv "$temp_file_ssl" "$input_file_ssl"

        # Limpieza: eliminar el archivo temporal
        rm -f "$temp_file_ssl"

    else

        echo "El archivo $input_file_ssl no existe."

    fi

    chmod -R u=rx,g=rx,o=r /var/www/html/web/
    
    systemctl reload apache2
}

fn_site_e "apache2" #>> log/apach2_site.sh

# Limpiar cache de memoria.
sync; echo 3 > /proc/sys/vm/drop_caches

echo "apache2_site"

exit