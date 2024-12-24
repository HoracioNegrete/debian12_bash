#!/bin/bash
sudo chmod ug-s /usr/bin/pkexec

function fn_bashrc (){
    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION BASHRC"

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"

    local USER=$1
    local USER_HOME="/home/$USER"
    local vr_file=".bashrc"

    if [ -f "$USER_HOME/$vr_file" ]; then

        local VR_BASHRC="$USER_HOME"/"$vr_file"

        # Archivo temporal para almacenar las líneas modificadas

            local tmp_file_bashrc

            tmp_file_bashrc=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

            # Lee el archivo y procesa cada línea
            while IFS= read -r line_bashrc || [ -n "$line_bashrc" ]; do

                if [[ "$line_bashrc" == "HISTSIZE="* ]]; then

                    line_bashrc="${line_bashrc/=*/=0}"
                    echo "$line_bashrc" >> "$tmp_file_bashrc"

                elif [[ "$line_bashrc" == "HISTFILESIZE="* ]]; then

                    line_bashrc="${line_bashrc/=*/=0}"
                    echo "$line_bashrc" >> "$tmp_file_bashrc"

                else

                    echo "$line_bashrc" >> "$tmp_file_bashrc"

                fi

            done < "$VR_BASHRC"

            # Reemplazamos el archivo de origen
            mv "$tmp_file_bashrc" "$VR_BASHRC"

            sudo chown "$USER":"$USER" "$VR_BASHRC"

            # Limpieza: eliminar el archivo temporal
            rm -f "$tmp_file_bashrc"

    fi

}

fn_bashrc "$1"

function fn_bash_logout (){

    local USER=$1
    local VR_BASH_LOGOUT="/home/$USER/.bash_logout"
    local vr_local_value="echo \"\" >~/.bash_logout: && history -c && exit"
    local vr_control="false"

    if [ -f "$VR_BASH_LOGOUT" ]; then

        # Archivo temporal para procesar las lineas
        local tmp_bash_logout

        tmp_bash_logout=$(mktemp) || { echo "Error al crear archivo temporal"; exit 1; }

        while IFS= read -r line_bash_logout || [ -n "$line_bash_logout" ]; do

            if [[ "$line_bash_logout" == "$vr_local_value" ]]; then

                local vr_control="true"

            else

                echo "$line_bash_logout" >> "$tmp_bash_logout"

            fi

        done < "$VR_BASH_LOGOUT"

        if [[ "$vr_control" == "false" ]]; then

            printf "\n# Eliminamos las entradas del bash\n$vr_local_value\n" >> "$tmp_bash_logout"

        fi

        # Reemplazamos el archivo de origen
        mv "$tmp_bash_logout" "$VR_BASH_LOGOUT"

        # Limpieza: eliminar el archivo temporal
        rm -f "$tmp_bash_logout"

    fi



}

fn_bash_logout "$1"  >> log/debian_bashrc.sh


# Purgar arcnhivos del sistema
sudo "${PWD}/purge/purge_old.sh"> /dev/null 2>&1

# Limpiar cache de memoria.
sudo sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'


exit
