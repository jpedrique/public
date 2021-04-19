#!/bin/bash

# PRACTICA DE USO DE SCRIPT
GREEN='\033[0;32m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"

printf "${GREEN}PRUEBAS DE EJECUCION DE COMANDO LINUX${NC}\n"
apt install figlet -y >/dev/null 2>&1
figlet "Lab k8s"

printf "${GREEN}[TAREA 1] CREAR DIRECTORIO Y ARCHIVO${NC}\n"
mkdir -p practica
cd practica
touch archivo1.txt
echo "Solo es una prueba" > archivo1.txt
cat archivo1.txt

printf "${GREEN}[TAREA 2] MOSTRAR IP Y NOMBRE DEL HOST${NC}\n"
ip a|grep inet
hostname

printf "${GREEN}[TAREA 3] MOSTRAR MEMORIA Y CAPACIDAD DE DISCO${NC}\n"
free -h
df -h |grep dev/root
printf "${GREEN}[TAREA 3] Fin del scrip${NC}\n"
