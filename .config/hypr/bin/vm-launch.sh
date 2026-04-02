#!/bin/bash

VM_NAME="${1:-win11}"
BASE_WS="${2:-5}"
NUM_MON=$(hyprctl monitors -j | jq '. | length')

virsh --connect qemu:///system start "$VM_NAME"
virt-viewer --connect qemu:///system --wait --attach "$VM_NAME" &
PID=$!

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
