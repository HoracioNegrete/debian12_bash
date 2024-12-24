#!/bin/bash

echo "Indicar usuario del sistema"

read -r usuario

# Filtrar la entrada del usuario para solo aceptar caracteres de a-z

if [[ $usuario =~ ^[exit]+$ ]]; then

    echo "Exit"
    exit 1

elif [[ $usuario =~ ^[a-z]+$ ]]; then

    echo "Usuario válido: $usuario"

    sudo "$PWD"/fn/debian_rm.sh "$usuario"
    sudo "$PWD"/fn/debian_sys_ctl.sh
    sudo "$PWD"/fn/debian_stop.sh
    sudo "$PWD"/fn/debian_per_directorios.sh
    sudo "$PWD"/fn/debian_lsmod.sh
    sudo "$PWD"/fn/debian_iptable.sh
    sudo "$PWD"/fn/debian_bashrc.sh "$usuario"
    sudo "$PWD"/fn/debian_repo.sh
    sudo "$PWD"/fn/debian_ins_soft.sh
    sudo "$PWD"/fn/debian_ufw.sh
    sudo "$PWD"/fn/debian_usb_guard.sh
    sudo "$PWD"/fn/debian_rm_user.sh

    sudo "$PWD""/apache2/apache2_user.sh"
    sudo "$PWD""/apache2/apache2.sh"
    sudo "$PWD""/apache2/apache2_site.sh"
    sudo "$PWD""/apache2/apache2_envvars.sh"
    sudo "$PWD""/apache2/apache2_mods.sh"
    sudo "$PWD""/apache2/apache2_security.sh"

    sudo "$PWD""/apache2/owasp/mod_security.sh"
    sudo "$PWD""/apache2/owasp/core_ruleset.sh"
    sudo "$PWD""/apache2/owasp/crs-setup.sh"
    
	sudo "$PWD""/systemd/pruv.sh"
	sudo "$PWD""/systemd/systemd_apache2.sh"
    sudo "$PWD""systemd/systemd_clean.sh Blue"
	
else

    echo "Error: el usuario solo debe contener caracteres de a-z"

    sudo ./start_menu.sh

fi

# Limpiar cache de memoria.
sudo sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

sudo systemctl stop apache2
sudo systemctl disable apache2

exit

# Modificar Grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash ipv6.disable=1"
sudo update-grub
