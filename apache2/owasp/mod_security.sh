#!/bin/bash

#   /etc/modsecurity/modsecurity.conf-recommended
#   /etc/modsecurity/active_rule/modsecurity.conf

function fn_active_base() {

    local vr_dir_active_rule="/etc/modsecurity/active_rule/"
    local vr_dir_base_rule="/etc/modsecurity/base_rule/"

    local vr_mod_sec_unicode="/etc/modsecurity/unicode.mapping"
    local vr_mod_sec_one="/etc/modsecurity/modsecurity.conf-recommended"
    local vr_mod_sec_conf="/etc/modsecurity/active_rule/modsecurity.conf"

    local vr_sec_rule="SecRuleEngine DetectionOnly"
    local vr_sec_audit="SecAuditLogParts ABDEFHIJZ"

    if [ ! -d "$vr_dir_active_rule" ];then

        mkdir "$vr_dir_active_rule"
        local vr_temp_dir="true"

    fi

    if [ -f "$vr_mod_sec_one" ]; then

        cp "$vr_mod_sec_one" "$vr_mod_sec_conf"
        cp "$vr_mod_sec_unicode" "$vr_dir_active_rule"

    else

        echo "El archivo $vr_mod_sec_one no existe"
        exit 1

    fi
    
    # Creamos archivo temporal
    local tmp_sec_mod=$(mktemp) || { echo "Error al copiar $vr_mod_sec_one"; exit 1; }

    while IFS= read -r line_sec_mod || [ -n "$line_sec_mod" ]; do

        if [ "$line_sec_mod" == "$vr_sec_rule" ]; then

            line_sec_mod="${line_sec_mod/"DetectionOnly"/"On"}"

        elif [ "$line_sec_mod" == "$vr_sec_audit" ]; then

            line_sec_mod="${line_sec_mod/"ABDEFHIJZ"/"ABCEFHJKZ"}"

        fi

        echo "${line_sec_mod}" >> "$tmp_sec_mod"

    done < "$vr_mod_sec_conf"

    # Reemplazar el archivo de origen con el temporal
    mv "$tmp_sec_mod" "$vr_mod_sec_conf" || { echo "Error al mover archivo temporal"; exit 1; }

    # Limpieza: eliminar el archivo temporal
    rm -f "$tmp_sec_mod"

}

fn_active_base
echo "fn_active_base"


#   /etc/apache2/mods-enabled/security2.conf

function fn_security2_conf (){

    local vr_mods_enabled="/etc/apache2/mods-enabled/security2.conf"

    local vr_value_src="IncludeOptional /etc/modsecurity/*.conf"
    local vr_value_rp="IncludeOptional /etc/modsecurity/active_rule/*.conf"

    local tmp_mods_enabled=$(mktemp) || { echo "Error al copiar $vr_mods_enabled"; exit 1; }

    if [ -f "$vr_mods_enabled" ]; then

        while IFS= read -r line_mods_enabled || [ -n "$line_mods_enabled" ]; do

            if [[ "$line_mods_enabled" == *"$vr_value_src" ]]; then

                line_mods_enabled="${vr_value_rp}"
                printf '\t%s%s'"$line_mods_enabled"'\n' >> "$tmp_mods_enabled"
            
            else

                echo "$line_mods_enabled" >> "$tmp_mods_enabled"

            fi

        done < "$vr_mods_enabled"

        # Reemplazar el archivo de origen con el temporal
        mv "$tmp_mods_enabled" "$vr_mods_enabled" || { echo "Error al mover archivo temporal"; exit 1; }

        # Limpieza: eliminar el archivo temporal
        rm -f "$tmp_mods_enabled"

    else

        echo "El archivo $vr_mods_enabled"

    fi

}

fn_security2_conf
echo "fn_security2_conf"

# coreruleset-4.0.0

function fn_coreruleset (){

    local vr_dir_coreruleset="$PWD""/apache2/owasp/coreruleset-4.0.0"
    local vr_dir_share="/usr/share/modsecurity-crs/"

    local vr_file_crs="/usr/share/modsecurity-crs/coreruleset-4.0.0/crs-setup.conf.example"

    if [ -d "$vr_dir_share" ]; then

        cp -rf "$vr_dir_coreruleset" "$vr_dir_share" 2>/dev/null

    fi

    if [ -f "$vr_file_crs" ]; then

        cp -rf "$vr_file_crs" "${vr_file_crs/".example"/}"

    fi

}

fn_coreruleset

echo "fn_coreruleset"

echo "MoD_Security"

sudo systemctl restart apache2

exit 1