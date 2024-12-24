#!/bin/bash

function FN_COLOR () {

    RED='\033[0;31m'    # Rojo

    GREEN='\033[0;32m'  # Verde

    YELLOW='\033[0;33m' # Amarillo

    BLUE='\033[0;34m'   # Azul

    BLACK="\033[0;30m" # Negro

    PURPLE="\033[0;35m" # Purpura

    CIAN="\033[0;36m"   # Cian

    WHITE="\033[0;37m"  # Blanco

    NC='\033[0m'        # Sin color (reset)

    # Usamos ${!1} para obtener el color basado en el nombre 
    # pasado como argumento
    echo -e "${!1}${2}${NC}"

    # Imprimir la variable en color rojo
    # echo -e "${RED}$VAR_RM${NC} texto en color normal"
    # echo -e "${RED}$VAR_RM${NC} texto en color normal"

}