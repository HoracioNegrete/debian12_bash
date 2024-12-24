#!/bin/bash

function fn_mods (){

    local -a vr_mods=(
        "libapache2-mod-evasive"
        "libapache2-mod-security2"
    )

    # Comprobamos si los mods de Apache2 estan instaldos, sino los instala
    for mods in "${vr_mods[@]}"; do

        # Verificamos si el paquete se encuentra instalado
        if dpkg -l --no-pager | awk '/^ii/ {print $2}' | grep "^${mods}$"; then

            if [ "$mods" = "libapache2-mod-evasive" ]; then

                sudo a2enmod evasive

            elif [ "$mods" = "libapache2-mod-security2" ]; then

                sudo a2enmod security2

            fi

        else

            echo "$mods no esta instalado"

            if [ "$mods" = "libapache2-mod-evasive" ]; then

                sudo apt-get install libapache2-mod-evasive -y
                sudo a2enmod evasive

            elif [ "$mods" = "libapache2-mod-security2" ]; then

                sudo apt-get install libapache2-mod-security2 -y
                sudo a2enmod security2

            fi

        fi

    done

    sudo a2enmod http2

    systemctl reload apache2

}

fn_mods #>> log/apach2_mods.sh

echo "apache2_mods"

exit
