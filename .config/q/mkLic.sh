#!/usr/bin/env bash

# The reverse is simply base64 < kc.lic

LICENSE_CONTENT="$1"

error() { echo "$1"; exit 0; }

[ -z "$LICENSE_CONTENT" ] && error "No license content provided"

[ -e "kc.lic" ] && error "Existing kc.lic found. Not replacing file."

if echo "$LICENSE_CONTENT" | base64 -d > kc.lic 2>/dev/null; then
    echo "Written license to kc.lic"
else
    rm kc.lic
    error "Failed to decode license"
fi
