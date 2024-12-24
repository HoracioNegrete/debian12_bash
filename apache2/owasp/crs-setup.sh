#!/bin/bash
# nmap -p- -sS -sC -sV --min-rate 5000 -n -vvv -Pn 10.10.10.10
# "SecDefaultAction \"phase:1,log,auditlog,pass\""
# "SecDefaultAction \"phase:1,log,auditlog,deny,status:403\""

function CRS-SETUP() {

    local VAR_FILE_CRS="/media/$USER/sandisk/Debian/apache2/owasp/coreruleset-4.0.0/crs-setup.conf.example"
    local DES_FILE_CRS="/usr/share/modsecurity-crs/coreruleset-4.0.0/crs-setup.conf"

    cp -rf "$VAR_FILE_CRS" "$DES_FILE_CRS" 2>/dev/null

    local INPUT_FILE="/usr/share/modsecurity-crs/coreruleset-4.0.0/crs-setup.conf"
    local MOD_LOG="SecDefaultAction \"phase:2,log,auditlog,pass\""
    local MOD_DENY="SecDefaultAction \"phase:2,log,auditlog,deny,status:403\""
    local cut_int
    local cut_control=false

    # Verificar si el archivo de entrada existe y es legible

    if [[ ! -f "$INPUT_FILE" || ! -r "$INPUT_FILE" ]]; then

        echo "Error: No se puede leer el archivo $INPUT_FILE"

        exit 1

    fi

    local TMP_CRS=$(mktemp) || { echo "Error al copiar $INPUT_FILE"; exit 1; }

    while IFS= read -r line_crs || [ -n "$line_crs" ]; do

        cut_int=false

        if [ "$line_crs" == "#SecAction \\" ]; then

            line_crs="${line_crs/"#"/}"

            echo -e "$line_crs" >> "$TMP_CRS"

            cut_control=true

        elif [[ "$cut_control" == "true" ]]; then
            
            if [[ "$line_crs" != \#*setvar:*\" ]]; then

                line_crs="${line_crs/"#"/}"

                echo -e "$line_crs" >> "$TMP_CRS"

            elif [[ "$line_crs" == \#*setvar:*\" ]]; then

                line_crs="${line_crs/"#"/}"

                echo -e "$line_crs" >> "$TMP_CRS"

                if [[ "$line_crs" != "setvar:"* ]]; then

                    cut_control=false

                fi

            fi

        elif [[ "$cut_int" == "false" && "$cut_control" == "false" ]]; then

            if [ "$line_crs" == "$MOD_LOG" ]; then

                echo -e "# $line_crs" >> "$TMP_CRS"

            elif [ "$line_crs" == "# $MOD_DENY" ]; then

                line_crs="${line_crs/"#"/}"
                echo -e "$MOD_DENY" >> "$TMP_CRS"

            else

                echo -e "$line_crs" >> "$TMP_CRS"

            fi

        fi

    done < "$INPUT_FILE"

    # Mover el archivo temporal al original
    mv "$TMP_CRS" "$INPUT_FILE"

    rm -f "$TMP_CRS"

}

CRS-SETUP

exit 0
