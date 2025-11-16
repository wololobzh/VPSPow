#!/bin/bash

# Définir des couleurs
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
WHITE='\e[97m'
RESET='\e[0m'

# Dessiner la fusée
printf "${RED}     /\\\n"
printf "    /  \\\n"
printf "   |${WHITE}****${RED}|\n"
printf "   |${WHITE}****${RED}|\n"
printf "   |${CYAN}####${RED}|\n"
printf "  /|${CYAN}####${RED}|\\\n"
printf " / |${CYAN}####${RED}| \\\n"
printf "/  |${CYAN}####${RED}|  \\\n"
printf "${BLUE}~~~~~~~~~~~~~~~\n"
printf " ${YELLOW} GO GO PNO !\n"
printf "${RESET}\n"
