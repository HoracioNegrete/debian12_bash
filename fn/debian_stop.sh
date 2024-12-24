#!/bin/bash

# Stop Service
function DisableService() {

    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION STOP"

    local services=(

        "bluetooth"
        "ModemManager"
        "avahi-daemon"
        "ModemManager"

    )

    for service in "${services[@]}"; do

        if systemctl is-active --quiet "$service"; then

            echo "Deteniendo y desactivando $service..."
            systemctl stop "$service".service
            systemctl disable "$service".service
            sudo systemctl stop "$service".socket
            sudo systemctl mask "$service".socket

        else

            echo "$service no está en ejecución."

        fi

    done

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"

    sudo systemctl daemon-reload

}

DisableService