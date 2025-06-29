#!/bin/bash
clear

LISTA=$1
LOG_FILE="/var/log/status_url.log"

if [[ -z "$LISTA" || ! -f "$LISTA" ]]; then
  echo "❌ Archivo no especificado o no encontrado."
  echo "Uso: $0 lista_URL.txt"
  exit 1
fi

sudo mkdir -p "$(dirname "$LOG_FILE")"
sudo touch "$LOG_FILE"
sudo chmod 664 "$LOG_FILE"

ANT_IFS=$IFS
IFS=$'\n'

echo "��� Verificando URLs con alias desde $LISTA..."

for linea in $(cat "$LISTA"); do
  [[ -z "$linea" || "$linea" == \#* ]] && continue

  dominio=$(echo "$linea" | awk '{print $1}')
  url=$(echo "$linea" | awk '{print $2}')

  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}' -s "$url")
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  LOG_LINE="$TIMESTAMP - $dominio - Code:$STATUS_CODE - URL:$url"

  echo "$LOG_LINE" | sudo tee -a "$LOG_FILE" > /dev/null

  if [[ "$STATUS_CODE" == "200" ]]; then
    echo "✅ [$STATUS_CODE] $dominio → $url accesible"
  else
    echo "⚠️  [$STATUS_CODE] $dominio → $url con problemas"
  fi
done

IFS=$ANT_IFS
