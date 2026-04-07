#!/bin/bash

VM_NAME="${1:-win11}"
BASE_WS="${2:-5}"
EXECUTE="$3"

# Get current day (1=Mon, 7=Sun) and hour (00-23)
DAY=$(date +%u)
HOUR=$(date +%H)
# Check if today is a weekday (1-5) and specific timing (e.g., 8 AM to 6 PM)
if ! [[ "$DAY" -le 5 ]] && [[ "$HOUR" -ge 8 && "$HOUR" -lt 18 ]]; then
    if ! [[ "$EXECUTE" == "now" ]]; then
        exit 0
    fi
fi

virsh --connect qemu:///system start "$VM_NAME" && sleep 10
virt-viewer --connect qemu:///system --wait --attach "$VM_NAME" &
PID=$!
NUM_MON=$(hyprctl monitors -j | jq '. | length')

for i in {1..30}; do
    mapfile -t ADDRS < <(hyprctl clients -j | jq -r --arg n "$VM_NAME" --arg p "$PID" \
        '[.[] | select(.title | test($n + " \\(\\d+\\)")) | select(.pid == ($p | tonumber))] | sort_by(.title) | .[].address')
    if [[ ${#ADDRS[@]} -ge $NUM_MON ]]; then
        for I in "${!ADDRS[@]}"; do
            hyprctl dispatch movetoworkspacesilent "$((BASE_WS + I)),address:${ADDRS[$I]}"
        done
        duration=$SECONDS
        echo "Total elapsed time: $duration seconds"
        break
    fi
    sleep 1
done
