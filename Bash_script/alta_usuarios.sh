#!/bin/bash
clear

###############################
# Rol R3 - Alta de Usuarios
# Crea usuarios desde lista CSV, usando la contraseña de un usuario base.
###############################

LISTA="$1"
CLONE_USER="$2"

if [[ ! -f "$LISTA" ]]; then
    echo "❌ Archivo no encontrado: $LISTA"
    exit 1
fi

if ! id "$CLONE_USER" &>/dev/null; then
    echo "❌ El usuario '$CLONE_USER' no existe"
    exit 1
fi

PASS_HASH=$(sudo getent shadow "$CLONE_USER" | cut -d ':' -f 2)

IFS=$'\n'
for LINEA in $(grep -v '^#' "$LISTA"); do
    USUARIO=$(echo "$LINEA" | cut -d ',' -f1)
    GRUPO=$(echo "$LINEA"  | cut -d ',' -f2)
    HOME=$(echo "$LINEA"   | cut -d ',' -f3)

    echo "Usuario: $USUARIO | Grupo: $GRUPO | Home: $HOME"

    getent group "$GRUPO" >/dev/null || sudo groupadd "$GRUPO"

    if ! id "$USUARIO" &>/dev/null; then
        sudo useradd -m -d "$HOME" -g "$GRUPO" -s /bin/bash "$USUARIO"
        sudo usermod -p "$PASS_HASH" "$USUARIO"
        echo "Usuario $USUARIO creado"
    else
        echo "a existía $USUARIO"
    fi
done

unset IFS

