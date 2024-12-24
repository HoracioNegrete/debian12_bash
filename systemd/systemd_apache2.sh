#!/bin/bash

function fn_SystemDApache2 () {

    # Función para verificar errores
    check_error() {

        if [ $? -ne 0 ]; then

            echo "Error: $1"
            exit 1

        fi
    }

    # Verificar que se ejecuta como root
    if [ "$EUID" -ne 0 ]; then

        echo "Este script debe ejecutarse como root"
        exit 1

    fi

    # Directorio donde se creará el archivo
    local OVERRIDE_DIR="/etc/systemd/system/apache2.service.d"
    local OVERRIDE_FILE="${OVERRIDE_DIR}/override.conf"

    # Obtener usuario y grupo de Apache
    local APACHE_USER=$(awk -F= '/^export APACHE_RUN_USER=/{print $2}' /etc/apache2/envvars)
    local APACHE_GROUP=$(awk -F= '/^export APACHE_RUN_GROUP=/{print $2}' /etc/apache2/envvars)
    
    echo $APACHE_USER
    echo $APACHE_GROUP

    local ARR_APACHE2=(
        "[Service]"
        "# Restricciones de dispositivos y sistema"
        "DeviceAllow=/dev/null rw"
        "DeviceAllow=/dev/random r"
        "DeviceAllow=/dev/urandom r"
        
        "# Restricciones de espacio de nombres"
        "RestrictNamespaces=no"
        "RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX"
        "RestrictRealtime=true"
        "RestrictSUIDSGID=no"

        "# Llamadas al sistema (solo las necesarias)"
        "SystemCallFilter=@system-service @network-io @file-system"
        "SystemCallArchitectures=native"

        "ProtectKernelTunables=yes"
        "ProtectKernelModules=yes"
        "ProtectControlGroups=yes"
        "ProtectKernelLogs=yes"
        "ProtectProc=invisible"

    )

    # Inicializa las variables temporales
    local TmpApache2=false

    if [ ! -d "$OVERRIDE_DIR" ]; then

        # Crear directorio si no existe
        mkdir -p "${OVERRIDE_DIR}"

    fi

    if [ -d "$OVERRIDE_DIR" ]; then

        {

            for SysApache2 in "${ARR_APACHE2[@]}"; do

                echo "$SysApache2"

            done

        } | sudo tee "$OVERRIDE_FILE" > /dev/null

            TmpApache2=true

    fi

    if [ -f "$OVERRIDE_FILE" ]; then
        # Establecer permisos correctos
        chmod 644 "${OVERRIDE_FILE}"

    else

        echo "Error: No se pudo crear el archivo override.conf"
        exit 1

    fi

    sudo systemctl daemon-reload

    if [ "$TmpApache2" == "true" ]; then

        sudo systemctl restart apache2

    fi

    # Limpiar cache de memoria.
    sync; echo 3 > /proc/sys/vm/drop_caches

}

fn_SystemDApache2

function fn_Conf_SysD_apache2 () {

    # Obtener usuario y grupo de Apache
    local APACHE_USER=$(awk -F= '/^export APACHE_RUN_USER=/{print $2}' /etc/apache2/envvars)
    local APACHE_GROUP=$(awk -F= '/^export APACHE_RUN_GROUP=/{print $2}' /etc/apache2/envvars)

    local TmpApache2=true

    # Ajustar permisos de manera segura
    sudo find /var/log/apache2/ -type f -exec chmod 755 {} \;        # Archivos
    sudo find /var/run/apache2/ -type f -exec chmod 755 {} \;        # Archivos
    sudo find /var/www/html -type f -exec chmod 544 {} \;
    sudo find /var/www/html -type d -exec chmod 555 {} \;
    sudo find /etc/apache2 -type f -exec chmod 744 {} \;
    sudo find /etc/apache2 -type d -exec chmod 755 {} \;

    # Asegurar que el usuario no tenga shell
    sudo usermod -s /usr/sbin/nologin "$APACHE_USER"

    # Asegurar que no tenga directorio home
    sudo usermod -d /nonexistent "$APACHE_USER"

    if [ "$TmpApache2" == "true" ]; then

        sudo systemctl restart apache2

    fi

    # Limpiar cache de memoria.
    sync; echo 3 > /proc/sys/vm/drop_caches

}

fn_Conf_SysD_apache2

ps aux | grep apache2



exit


chown



# Directorios esenciales y sus permisos
/var/log/apache2    -> 755 (apache2:apache2) # Necesita escribir logs
/var/run/apache2    -> 755 (apache2:apache2) # Para archivos PID
/etc/apache2        -> 755 (root:root)       # Solo lectura para configuraciones
/var/www           -> 755 (root:root)        # Solo lectura para archivos web

# Ajustar permisos de manera segura
sudo find /var/log/apache2/ -type f -exec chmod 755 {} \;        # Archivos
sudo find /var/run/apache2/ -type f -exec chmod 755 {} \;        # Archivos
sudo find /var/www -type f -exec chmod 644 {} \;        # Archivos
sudo find /var/www -type d -exec chmod 755 {} \;        # Directorios
sudo find /etc/apache2 -type f -exec chmod 644 {} \;    # Archivos de configuración
sudo find /etc/apache2 -type d -exec chmod 755 {} \;    # Directorios de configuración

sudo find /var/run/apache2 -type d -exec chown "$APACHE_USER":"$APACHE_USER" {} \;
sudo find /var/run/apache2 -type d -exec chown apache2:apache2

# Asegurar que el usuario no tenga shell
sudo usermod -s /usr/sbin/nologin apache2

# Asegurar que no tenga directorio home
sudo usermod -d /nonexistent apache2

# Remover el usuario de todos los grupos innecesarios
sudo usermod -G apache2 apache2

# Verificar que el usuario no puede hacer login
sudo su - apache2

# Verificar permisos de directorios
ls -la /var/log/apache2
ls -la /var/run/apache2
ls -la /etc/apache2
ls -la /var/www

# Verificar capacidades
getcap -r /usr/sbin/apache2



el archivo /etc/apache2/envvars posee los siguientes campos.
export APACHE_RUN_USER=apache2
export APACHE_RUN_GROUP=apache2
los cuales cuentan con el usuario que corre el programa.
(el servicio apache2 corre bajo el puerto 80, lo cual supongo que el puerto es
abierto con permisos de administrador)
en bash script como puedo leer el valor del campo APACHE_RUN_USER=apache2 y asignarlo
al paramtro que se introducira en el archivo override.conf.

        "[Service]"
        "# Usuario y grupo"
        "#User=$APACHE_USER"
        "#Group=$APACHE_GROUP"

        
        

        "# Capacidades (mínimo absoluto)"
        "CapabilityBoundingSet=CAP_NET_BIND_SERVICE"
        "AmbientCapabilities=CAP_NET_BIND_SERVICE"

        "# Seguridad adicional"
        "# NoNewPrivileges=yes"
        "# LockPersonality=yes"
        "# RemoveIPC=yes"
        "MemoryDenyWriteExecute=yes"

        "# Restricciones críticas de sistema"
        "PrivateDevices=yes"
        "#PrivateTmp=no"
        "ProtectHome=yes"
        
        "ProtectClock=yes"
        "#ProtectSystem=strict"

        "# Restricciones de red (solo lo necesario)"
        "RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX"
        "RestrictNamespaces=no"
        "RestrictRealtime=yes"
        "RestrictSUIDSGID=yes"

        
        
        "# Usuario y grupo"
        "#User=$APACHE_USER"
        "#Group=$APACHE_GROUP"

        "# Configuraciones de seguridad"
        "SystemCallFilter=@system-service"
        "SystemCallFilter=~@privileged @resources"
        "NoNewPrivileges=true"
        "LockPersonality=true"
        "MemoryDenyWriteExecute=true"
        "UMask=0027"













Key Components of the Configuration

1 - Inaccessible Paths
        Directive: InaccessiblePaths=/root /home /opt /mnt /media
        Purpose: This directive restricts access to the specified directories for the service. It prevents the service from accessing sensitive areas of the filesystem, enhancing security by limiting exposure to user data and system files.

2 - Additional Security Measures

        NoNewPrivileges: NoNewPrivileges=yes
            Purpose: Prevents the service from gaining new privileges, even if it executes a binary that has the setuid or setgid bit set. This is crucial for maintaining a secure environment.
        
        LockPersonality: LockPersonality=yes
            Purpose: Locks the process's personality, which can prevent certain types of attacks that exploit the personality feature in Linux.
        
        RemoveIPC: RemoveIPC=yes
            Purpose: Ensures that all System V IPC objects (like message queues, semaphores, and shared memory) are removed when the service stops. This helps in cleaning up resources and preventing unauthorized access.
        
        MemoryDenyWriteExecute: MemoryDenyWriteExecute=yes
            Purpose: Prevents memory pages from being both writable and executable, which mitigates certain types of attacks, such as code injection.

3 - System Call Restrictions

        SystemCallFilter: SystemCallFilter=@system-service @network-io @file-system
            Purpose: This directive allows only a predefined set of system calls that are necessary for the service to function. It restricts the service from making arbitrary system calls, which can reduce the attack surface.

        SystemCallArchitectures: SystemCallArchitectures=native
            Purpose: Specifies the architectures for which the system call filter applies. Using native means it will apply to the architecture of the host system.

