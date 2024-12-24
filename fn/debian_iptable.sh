#!/bin/bash
# sudo iptables -L -v -n

function fn_IpTable () {

    # Importar la función
    source fn/colores.sh

    local VAR_RM="FUNCION IPTABLES"

    local BLOCK_IP="95.214.55.138"

    local ARR_IPTABLE=(
        "sudo iptables -F"
        "sudo iptables -X"
        "sudo iptables -P INPUT DROP"
        "sudo iptables -P FORWARD DROP"
        "sudo iptables -P OUTPUT DROP"
        "sudo iptables -A INPUT -i lo -j ACCEPT"
        "sudo iptables -A OUTPUT -o lo -j ACCEPT"
        "sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
        "sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT"
    )

    # 5. Permitir tráfico de salida en puertos específicos
    local ARR_BLOQUE=(
        "sudo iptables -A OUTPUT -p tcp --dport 21 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 22 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 23 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 25 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 110 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 137 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 138 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 139 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 143 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 445 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 631 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 1900 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 2213 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 4500 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 5222 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 6666 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 6667 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 8080 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 8000 -j DROP"
        "sudo iptables -A OUTPUT -p tcp --dport 9000 -j DROP"
    )

    # 1. Limpiar reglas existentes
    for DAT_IPTABLE in "${ARR_IPTABLE[@]}"; do

        eval "$DAT_IPTABLE" || { echo "Error ejecutando: $DAT_IPTABLE"; exit 1; }

    done

    # 5. Permitir tráfico de salida en puertos específicos
    for NEW_IpTable in "${ARR_BLOQUE[@]}"; do

        eval "$NEW_IpTable" || { echo "Error ejecutando: $NEW_IpTable"; exit 1; }

    done

    # 6. Bloquear puertos UDP específicos
    for port in 1234 2216 4444 5004 5353 5454 6881; do
       
        sudo iptables -A INPUT -p udp --dport $port -j DROP
        sudo iptables -A OUTPUT -p udp --dport $port -j DROP
        
    done

    # 7. Bloquear una dirección IP específica
        sudo iptables -A INPUT -s "$BLOCK_IP" -j DROP
        sudo iptables -A OUTPUT -d "$BLOCK_IP" -j DROP

    # 8. Guardar las reglas
        sudo iptables-save | sudo tee /etc/iptables/rules.v4

    # Limpiar cache de memoria.
        sync; echo 3 > /proc/sys/vm/drop_caches

    # Impresion de aviso.
    FN_COLOR "GREEN" "$VAR_RM"
    
}

fn_IpTable