#!/bin/bash

# Importar la función
source fn/colores.sh

function fn_sysctl () {

    local VAR_RM="FUNCION SYSCTL"

    # Definir la lista de filtros sysctl
    local -a filtro_sysctl=(
        "fs.suid_dumpable = 0"
        "kernel.core_uses_pid = 1"
        "kernel.exec-shield = 1"
        "kernel.kptr_restrict = 1"
        "kernel.randomize_va_space = 2"
        "net.ipv4.conf.all.accept_redirects = 0"
        "net.ipv4.conf.all.accept_source_route = 0"
        "net.ipv4.conf.all.bootp_relay = 0"
        "net.ipv4.conf.all.forwarding = 0"
        "net.ipv4.conf.all.proxy_arp = 0"
        "net.ipv4.conf.all.rp_filter = 1"
        "net.ipv4.conf.all.secure_redirects = 0"
        "net.ipv4.conf.all.send_redirects = 0"
        "net.ipv4.conf.default.accept_redirects = 0"
        "net.ipv4.conf.default.accept_source_route = 0"
        "net.ipv4.conf.default.forwarding = 0"
        "net.ipv4.conf.default.rp_filter = 1"
        "net.ipv4.conf.default.secure_redirects = 0"
        "net.ipv4.conf.default.send_redirects = 0"
        "net.ipv4.icmp_echo_ignore_all = 1"
        "net.ipv4.icmp_echo_ignore_broadcasts = 1"
        "net.ipv4.ip_forward = 0"
        "net.ipv4.neigh.default.age_timeout=60"
        "net.ipv4.neigh.default.gc_interval=300"
        "net.ipv4.neigh.default.gc_stale=60"
        "net.ipv4.neigh.default.gc_thresh3 = 2048"
        "net.ipv4.tcp_congestion_control = htcp"
        "net.ipv4.tcp_dsack = 1"
        "net.ipv4.tcp_max_syn_backlog = 4096"
        "net.ipv4.tcp_moderate_rcvbuf = 1"
        "net.ipv4.tcp_no_metrics_save = 1"
        "net.ipv4.tcp_sack = 1"
        "net.ipv4.tcp_synack_retries = 2"
        "net.ipv4.tcp_syncookies = 1"
        "net.ipv4.tcp_syn_retries = 2"
        "net.ipv6.conf.all.accept_redirects = 0"
        "net.ipv6.conf.all.accept_source_route = 0"
        "net.ipv6.conf.all.forwarding = 0"
        "net.ipv6.conf.default.accept_redirects = 0"
        "net.ipv6.conf.default.accept_source_route = 0"
        "net.ipv6.conf.default.forwarding = 0"
        "vm.overcommit_memory = 0"
        "vm.overcommit_ratio = 0"
        "# Desactivar IPv6"
        "net.ipv6.conf.all.disable_ipv6 = 1"
        "net.ipv6.conf.default.disable_ipv6 = 1"
        "net.ipv6.conf.lo.disable_ipv6 = 1"
    )

    local file_in="/etc/sysctl.d/local.conf"
    # Impresion de aviso.
    FN_COLOR "RED" "$VAR_RM"
    local control_in="true"

        # Verificar archivo.
        if [[ -f "$file_in" && "$control_in" == true ]]; then

            # Eliminamos el archivo viejo.
            rm -f "$file_in"

            # Creamos nuevamente el archivo
            touch "$file_in"

            # Modificamos los permisos
            chown root:root "$file_in"

            # Cambiamos los permisos del archivo
            chmod 600 "$file_in"

            # cambiamos el valor de la variable de control
            control_in="false"

        elif [[ ! -f "$file_in" ]]; then

            # Creamos nuevamente el archivo
            touch "$file_in"

            # Modificamos los permisos
            chown root:root "$file_in"

            # Cambiamos los permisos del archivo
            chmod 600 "$file_in"

            # cambiamos el valor de la variable de control
            control_in="false"
            
        fi

    if [ "$control_in" == "false" ]; then

        # Recorrer la lista de filtros sysctl
        for datos in "${filtro_sysctl[@]}"; do

            echo -e "$datos" | awk '{print $0}' >>"$file_in"

        done

        chmod u=r,g=r,o=- "$file_in"

    fi

    sudo sysctl -p

    # Limpiar cache de memoria.
    sync; echo 3 > /proc/sys/vm/drop_caches

}

fn_sysctl #>> log/debian_sys_ctl.txt

exit
