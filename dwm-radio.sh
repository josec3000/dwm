#!/bin/bash

RADIO_FILE="$HOME/.config/dwm/radios.txt"
STATE_FILE="/tmp/dwm_radio_index"

# Si el archivo de estado no existe, empezamos en la línea 1
[ ! -f "$STATE_FILE" ] && echo 1 > "$STATE_FILE"

current_index=$(cat "$STATE_FILE")
total_radios=$(wc -l < "$RADIO_FILE")

play_radio() {
    index=$1
    # Extraer nombre y URL de la línea específica
    line=$(sed -n "${index}p" "$RADIO_FILE")
    name=$(echo "$line" | cut -d'|' -f1)
    url=$(echo "$line" | cut -d'|' -f2)

    pkill -f "mpv --no-video"
    mpv --no-video "$url" > /dev/null 2>&1 &
    notify-send "📻 Radio" "Sonando: $name"
    echo "$index" > "$STATE_FILE"
}

case $1 in
    toggle)
        if pgrep -f "mpv --no-video" > /dev/null; then
            pkill -f "mpv --no-video"
            notify-send "📻 Radio" "Apagada"
        else
            play_radio "$current_index"
        fi
        ;;
    next)
        new_index=$((current_index + 1))
        [ "$new_index" -gt "$total_radios" ] && new_index=1
        play_radio "$new_index"
        ;;
    prev)
        new_index=$((current_index - 1))
        [ "$new_index" -lt 1 ] && new_index="$total_radios"
        play_radio "$new_index"
        ;;
esac
