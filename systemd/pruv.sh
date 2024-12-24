#!/bin/bash

# Account-Daemon
function fn_Systemd_Accounts () {

    local SystemdAccounts=(
        "[Service]"
        "ProtectKernelTunables=yes"
        "ProtectKernelModules=yes"
        "ProtectKernelLogs=yes"

        "# Capacidades necesarias"
        "CapabilityBoundingSet=CAP_CHOWN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_FOWNER CAP_IPC_OWNER CAP_SYS_ADMIN"
        "AmbientCapabilities=CAP_CHOWN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_FOWNER CAP_IPC_OWNER CAP_SYS_ADMIN"
        
        "# Directorios y permisos"
        "ReadWritePaths=-/var/lib/AccountsService -/var/cache/AccountsService -/run/AccountsService -/var/lib/gdm3 -/run"
        "ReadOnlyPaths=-/etc/passwd -/etc/group -/etc/shadow -/etc/gshadow -/etc/login.defs"
        
        "# Filtrado de llamadas al sistema"
        "SystemCallFilter=@system-service @basic-io"
        "SystemCallArchitectures=native"
        
    )

    local vr_account="/run/AccountsService"
    local DirSystemD="/etc/systemd/system/accounts-daemon.service.d/"
    local OverRide="override.conf"

    # Inicializa las variables temporales

    local Tmpaccounts=false

    if [ ! -d "$vr_account" ]; then

        mkdir -p /run/AccountsService

    else

        chown root:root /run/AccountsService
        chmod 755 /run/AccountsService

    fi  

    if [ ! -d "$DirSystemD" ]; then

        mkdir -p "$DirSystemD"

    fi

    if [ -d "$DirSystemD" ]; then

        sudo chmod 644 /etc/systemd/system/accounts-daemon.service.d

        {

            for DataAccounts in "${SystemdAccounts[@]}"; do

                echo "$DataAccounts"

            done

        } | sudo tee "$DirSystemD/$OverRide" > /dev/null

        Tmpaccounts=true

    fi
    

    sudo systemctl daemon-reload

    if [ "$Tmpaccounts" == "true" ]; then

        sudo systemctl restart accounts-daemon

    fi

    # Limpiar cache de memoria.
    sync; echo 3 > /proc/sys/vm/drop_caches

}

fn_Systemd_Accounts

# DBus-Daemon
function dbus () {

    local SystemdDbus=(
        "[Service]"
        "# Restricciones de sistema fundamentales"
        "PrivateDevices=yes"
        "PrivateTmp=yes"
        "ProtectSystem=strict"
        "ProtectHome=yes"
        "ProtectKernelTunables=yes"
        "ProtectKernelModules=yes"
        "ProtectKernelLogs=yes"
        "ProtectControlGroups=yes"
        "ProtectProc=invisible"
        "ProtectClock=yes"

        "# Capacidades (mínimas necesarias para D-Bus)"
        "CapabilityBoundingSet=CAP_AUDIT_WRITE CAP_DAC_OVERRIDE CAP_SETGID CAP_SETUID"
        "AmbientCapabilities=CAP_AUDIT_WRITE CAP_DAC_OVERRIDE CAP_SETGID CAP_SETUID"

        "# Directorios y permisos"
        "ReadWritePaths=/var/run/dbus"
        "ReadOnlyPaths=/etc/dbus-1 /usr/share/dbus-1"
        "InaccessiblePaths=/root /home /media /mnt"

        "# Seguridad de sistema de archivos"
        "NoNewPrivileges=yes"
        "LockPersonality=yes"
        "RemoveIPC=no  # Necesario para D-Bus"
        "MemoryDenyWriteExecute=yes"
        
        "# Filtrado de llamadas al sistema"
        "SystemCallFilter=@system-service @basic-io @io-event @signal"
        "SystemCallArchitectures=native"


        "# Configuración específica D-Bus"
        "DevicePolicy=closed"
        "DeviceAllow=/dev/null rw"
        "DeviceAllow=/dev/urandom r"

        "# Límites de recursos"
        "LimitNOFILE=16384"
        "LimitNPROC=256"
        "TasksMax=256"

        "# Configuración de usuario y grupo"
        "DynamicUser=no"
        "User=messagebus"
        "Group=messagebus"

        "# Restricciones adicionales de seguridad"
        "UMask=0077"
        "StandardOutput=journal"
        "StandardError=journal"
        "SecureBits=keep-caps-locked noroot-locked"

        "# Política de reinicio"
        "Restart=always"
        "RestartSec=1s"
        "StartLimitInterval=30s"
        "StartLimitBurst=3"
        
        "# Sandboxing adicional"
        "SocketBindAllow=tcp:80 tcp:443"
        "SocketBindDeny=any"
        "RestrictFileSystems=~devpts ~proc ~sys"
        
    )

    local DirSystemD="/etc/systemd/system/dbus.service.d/"
    local OverRide="override.conf"

    # Inicializa las variables temporales

    local TmpDbus=false

    if [ ! -d "$DirSystemD" ]; then

        mkdir -p "$DirSystemD"

    fi

    if [ -d "$DirSystemD" ]; then

        {

            for DataDbus in "${SystemdDbus[@]}"; do

                echo "$DataDbus"

            done

        } | sudo tee "$DirSystemD$OverRide" > /dev/null
        
        TmpDbus=true

    fi

    sudo systemctl daemon-reload

    if [ "$Tmpdbus" == "true" ]; then

        sudo systemctl restart dbus.service

    fi

    # Limpiar cache de memoria.
    sync; echo 3 > /proc/sys/vm/drop_caches
}

dbus

# NetworkManager-Daemon
function fn_systemd_networkmanager () {

    local SystemdNetwork=(
        "[Service]"
        "ProtectKernelTunables=yes"
        "ProtectKernelLogs=yes"
        "ProtectControlGroups=yes"
        "ProtectProc=invisible"
        "ProtectClock=yes"
        
        "# Restricciones de red específicas para puertos 80 y 443"
        "IPAddressAllow=any"
        "RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX AF_NETLINK"
        "IPAddressDeny=any"
        "RestrictNamespaces=yes"
        "RestrictRealtime=yes"
        "RestrictSUIDSGID=yes"
        
        "# Reglas de firewall implícitas (documentación)"
        "ExecStartPre=/sbin/iptables -A INPUT -p tcp -s 192.168.0.1 --dport 80 -j ACCEPT"
        "ExecStartPre=/sbin/iptables -A INPUT -p tcp -s 192.168.0.1 --dport 443 -j ACCEPT"
        "ExecStartPre=/sbin/iptables -A INPUT -j DROP"

        "# Capacidades necesarias para NetworkManager"
        "CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE"
        "AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE"

        "# Sistema de archivos y seguridad adicional"
        "NoNewPrivileges=yes"
        "LockPersonality=yes"
        "RemoveIPC=yes"
        "MemoryDenyWriteExecute=yes"
        
        "# Configuración específica para NetworkManager"
        "DevicePolicy=closed"
        "DeviceAllow=/dev/null rw"
        "DeviceAllow=/dev/random r"
        "DeviceAllow=/dev/urandom r"
        "DeviceAllow=char-tun rw"

        "# Restricciones adicionales"
        "UMask=0027"
        "LimitNPROC=1024"
        "LimitNOFILE=65535"
    )

    local TmpNetwork=false

    local DirSystemD="/etc/systemd/system/NetworkManager.service.d/"
    local OverRide="override.conf"

    if [ ! -d "$DirSystemD" ]; then

        mkdir -p "$DirSystemD"

    fi

    if [ -d "$DirSystemD" ]; then

        {

            for DatNetwork in "${SystemdNetwork[@]}"; do

                echo "$DatNetwork"

            done

        } | sudo tee "$DirSystemD/$OverRide" > /dev/null
        
        TmpNetwork=true

    fi


    sudo systemctl daemon-reload

    if [ "$TmpNetwork" == "true" ]; then

        sudo systemctl restart NetworkManager

    fi

    # Limpiar cache de memoria.
    sync; echo 3 > /proc/sys/vm/drop_caches

}

fn_systemd_networkmanager






exit