#!/bin/bash

# PRACTICA DE USO DE SCRIPT

echo "PRUEBAS DE EJECUCION DE COMANDO LINUX"
apt install figlet -y
figlet "Lab k8s"

echo "[TAREA 1] Crear directorio y archivo"
sudo su
mkdir practica
cd practica
touch archivo.txt
echo "Solo es una prueba" > archivo.txt
cat archivo.txt

echo "[TAREA 2] Mostrar IP, nombrede Host"
ip a|grep inet
hostname

echo "[TAREA 3] Mostrar memoria y capacidad de disco"
free -h
df -h |grep dev
echo "[TAREA 3] Fin del scrip"
