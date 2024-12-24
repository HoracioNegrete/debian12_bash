#!/bin/bash

function fn_security() {

    local input_file="/etc/apache2/conf-enabled/security.conf"

    # Configuraciones a modificar
    local configs=(
        "ServerTokens Minimal"
        "ServerTokens OS"
        "ServerTokens Full"
        "ServerSignature Off"
        "ServerSignature On"
        "TraceEnable Off"
        "TraceEnable On"
    )

    local modified=false

    # Archivo temporal para almacenar las líneas modificadas
    local temp_security=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

    # Verificar si el archivo existe
    if [ ! -f "$input_file" ]; then

        echo "El archivo $input_file no existe."
        exit 1

    fi

    sudo chmod 0700 "$input_file"

    while IFS= read -r line_ssl_sec || [ -n "$line_ssl_sec" ]; do

        modified=false

        for config in "${configs[@]}"; do

            if [[ "$line_ssl_sec" == *"$config" ]]; then

                if [[ "$line_ssl_sec" == *"Off" ]]; then

                    line_ssl_sec="$config"
                    echo "$line_ssl_sec" >> "$temp_security"

                elif [[ "$line_ssl_sec" == *"ServerTokens Minimal" ]]; then
                    
                    line_ssl_sec="ServerTokens Prod"
                    echo "$line_ssl_sec" >> "$temp_security"

                else

                    line_ssl_sec="${config/#/# }"
                    echo "$line_ssl_sec" >> "$temp_security"

                fi

                modified=true

                break
            
            fi

        done

        # Si no se modificó la línea, escribirla tal cual
        if [ "$modified" = false ]; then

            echo "$line_ssl_sec" >> "$temp_security"

        fi

    done < "$input_file"

    # Reemplazamos el archivo de origen
    mv "$temp_security" "$input_file"

    # Limpieza: eliminar el archivo temporal
    rm -f "$temp_security"

}

fn_security

echo "Termino fn_security"

function fn_headers() {

    local vr_modulo="headers"
    local input_file="/etc/apache2/conf-enabled/security.conf"
    
    # Verificamos la ejecución del módulo headers
    local vr_headers_ins=$(sudo apache2ctl -M | grep "$vr_modulo")
    
    if [ -z "$vr_headers_ins" ]; then

        sudo a2enmod $vr_modulo

    else

        sudo a2enmod $vr_modulo

    fi

    local modified=false

    local VrLocalSet=(
        "Header set X-Content-Type-Options: \"nosniff\""
        "Header set Content-Security-Policy \"default-src 'self'; script-src 'self'; style-src 'self' ; img-src 'self' data: https://trusted-images.com; connect-src 'self'; font-src 'self';\""
        "Header always set X-Frame-Options \"DENY\""
        "Header set Referrer-Policy \"no-referrer\""
        "Header set X-Download-Options \"noopen\""
        "Header set Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\""
        "Header set X-XSS-Protection \"1; mode=block\""
        "Header edit Set-Cookie ^(.*)\$ \"\$1; HttpOnly; SameSite=Strict\""
        )

    # Archivo temporal para almacenar las líneas modificadas
    local tmp_HeaderS=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

    # Verificar si el archivo existe
    if [ ! -f "$input_file" ]; then

        echo "El archivo $input_file no existe."

        exit 1

    fi

    while IFS= read -r line_HeaderS || [ -n "$line_HeaderS" ]; do

        modified=false

        for HeaderS in "${VrLocalSet[@]}"; do

            if [ "$HeaderS" == "$line_HeaderS" ]; then

                modified=true

                break

            fi

        done

        # Si no se modificó la línea, escribirla tal cual
        if [ "$modified" == false ]; then

            echo "$line_HeaderS" >> "$tmp_HeaderS"

        fi

    done < "$input_file"

    for HeaderS in "${VrLocalSet[@]}"; do

        printf "$HeaderS"'\n' >> "$tmp_HeaderS"

    done

    # Reemplazamos el archivo de origen
    mv "$tmp_HeaderS" "$input_file"

    # Limpieza: eliminar el archivo temporal
    rm -f "$tmp_HeaderS"

    chmod 440 "$input_file"
    ls -la "$input_file"
}

fn_headers #>> log/apach2_security.sh

echo "apache2_security"

systemctl reload apache2

exit