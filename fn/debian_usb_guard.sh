#!/bin/bash

function usb_guard () {

    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION USB_GUARD"

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"

    local vr_consulta="usbguard"
    local vr_daemon="/etc/usbguard/usbguard-daemon.conf"
    local package_installed=$(dpkg-query -W -f='${binary:Package}\n' | grep -E "^${vr_consulta}$")

    if [ -n "$package_installed" ]; then

        echo "El paquete $package_installed se encuentra instalado"

         # Verificar si el archivo existe
        if [ ! -f "$vr_daemon" ]; then

            echo "El archivo $vr_daemon no existe."
            exit 1

        else

            local usb_array=(
                "PresentDevicePolicy"
                "PresentControllerPolicy"
                "InsertedDevicePolicy"
                "ImplicitPolicyTarget"
                "DeviceManagerBackend"
                )

            # Archivo temporal para almacenar las líneas modificadas
            local temp_filex_usb=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

                while IFS= read -r line_usb || [ -n "$line_usb" ]; do

                    # Extraer la primera columna 
                    vr_pdp=$(echo "$line_usb" | awk -F "=" '{print $1}')

                    case "$vr_pdp" in
                        "PresentDevicePolicy")
                            
                            echo "PresentDevicePolicy=apply-policy" >> "$temp_filex_usb"
                            
                        ;;
                        
                        "PresentControllerPolicy")
                            
                            echo "PresentControllerPolicy=apply-policy" >> "$temp_filex_usb"
                            
                        ;;

                        "InsertedDevicePolicy")
                            
                            echo "InsertedDevicePolicy=block" >> "$temp_filex_usb"
                            
                        ;;

                        "ImplicitPolicyTarget")
                            
                            echo "ImplicitPolicyTarget=block" >> "$temp_filex_usb"
                            
                        ;;

                        "DeviceManagerBackend")
                            
                            echo "DeviceManagerBackend=uevent" >> "$temp_filex_usb"
                            
                        ;;

                        *)                            
                                                    
                            echo "$line_usb" >> "$temp_filex_usb"

                    esac

                done < "$vr_daemon"

                mv "$temp_filex_usb" "$vr_daemon"
                chmod 600 /etc/usbguard/usbguard-daemon.conf

        fi

    fi

    # Limpieza: eliminar el archivo temporal
    rm -f "$temp_filex_usb"       

}

usb_guard

# Limpiar cache de memoria.
sync; echo 3 > /proc/sys/vm/drop_caches

exit
