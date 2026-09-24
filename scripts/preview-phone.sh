#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
preview_dir="$script_dir/../design/reference"
preview_port=${1:-4173}

case "$preview_port" in
  *[!0-9]*|'') printf 'Porta non valida: %s\n' "$preview_port" >&2; exit 2 ;;
esac

preview_ip=$(ipconfig getifaddr en0 2>/dev/null || true)
if [ -z "$preview_ip" ]; then preview_ip=$(ipconfig getifaddr en1 2>/dev/null || true); fi

printf 'Riferimento grafico locale: http://127.0.0.1:%s/\n' "$preview_port"
if [ -n "$preview_ip" ]; then
  printf 'Sul telefono, nella stessa Wi-Fi: http://%s:%s/\n' "$preview_ip" "$preview_port"
else
  printf 'Connetti il Mac al Wi-Fi e usa il suo indirizzo IP locale.\n'
fi
printf 'Tieni aperta questa finestra mentre usi la prova. Ctrl+C per fermarla.\n'
exec python3 -m http.server "$preview_port" --bind 0.0.0.0 --directory "$preview_dir"
