#!/bin/bash

function deb_modprobe () {

    # Importar la función
    source fn/colores.sh
    
    local VAR_RM="FUNCION LSMOD"

    local file_black="/etc/modprobe.d/blacklist.conf"
    local control_in=true

    sudo modprobe -r firewire_ohci

    FN_COLOR "RED" "$VAR_RM" "FUNCION MODPROBE"

    # Verificar archivo.
        if [[ -f "$file_black" && "$control_in" == true ]]; then

            # Eliminamos el archivo viejo.
            rm -f "$file_black"

        fi

        if [[ ! -f "$file_black" && "$control_in" == true ]]; then

            # Creamos nuevamente el archivo
            touch "$file_black"

            # Modificamos los permisos
            chown root:root "$file_black"

            # Cambiamos los permisos del archivo
            chmod 644 "$file_black"


            echo "blacklist firewire_ohci" >> "$file_black"
            echo "blacklist firewire_core" >> "$file_black"

        fi

        sudo update-initramfs -u

}

deb_modprobe

exit 
