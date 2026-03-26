#!/usr/bin/env bash
set -euo pipefail

# Configuration
MAX_PARALLEL=10

# Check dependencies
for cmd in jq unzip curl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Load token
if [[ ! -f ~/.kx.token ]]; then
    echo "Error: Token file ~/.kx.token not found" >&2
    exit 1
fi
BEARER=$(cat ~/.kx.token)

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TEMP_DIR"

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        echo "Cleaning up temporary directory..."
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Function to download a single asset
download_asset() {
    local dir="$1"
    local url="$2"
    local asset="$3"
    local bearer="$4"

    [[ "$asset" == "verify.zip" ]] && return 0

    echo "Downloading asset: $asset"

    if curl -sSfL --oauth2-bearer "$bearer" "$url/$asset" -o "$dir/$asset"; then
        if [[ "$asset" == *.zip ]]; then
            if unzip -oq "$dir/$asset" -d "$dir" 2>/dev/null; then
                rm "$dir/$asset"
                echo "✓ Completed (extracted): $asset"
            else
                echo "✗ Failed to unzip: $asset" >&2
                return 1
            fi
        else
            echo "✓ Completed (kept): $asset"
        fi
    else
        echo "✗ Failed to download: $asset" >&2
        return 1
    fi
}

export -f download_asset
export BEARER

cd "$TEMP_DIR"

echo "=========================================="
echo "Downloading kdb+ versions"
echo "=========================================="

KDBP_URL=https://portal.dl.kx.com/assets/raw/kdb+

versions_json=$(curl -sSfL --oauth2-bearer "$BEARER" "$KDBP_URL")
if [[ -z "$versions_json" ]]; then
    echo "Error: Failed to fetch kdb+ versions list" >&2
    exit 1
fi

while IFS= read -r version; do
    version="${version//\//}"
    [[ -z "$version" ]] && continue

    echo "Processing kdb+ version: $version"
    mkdir -p "$version"

    date_json=$(curl -sSfL --oauth2-bearer "$BEARER" "$KDBP_URL/$version")
    date=$(echo "$date_json" | jq -r '.assets[0].path // empty')

    if [[ -z "$date" ]]; then
        echo "Warning: No date found for version $version" >&2
        continue
    fi

    date="${date//\//}"
    touch "$version/$date"
    echo "Latest version date: $date"

    assets_json=$(curl -sSfL --oauth2-bearer "$BEARER" "$KDBP_URL/$version/$date")
    assets=$(echo "$assets_json" | jq -r '.assets[].path // empty' | grep -v '^$')

    if [[ -z "$assets" ]]; then
        echo "Warning: No assets found for $version/$date" >&2
        continue
    fi

    echo "$assets" | xargs -P "$MAX_PARALLEL" -I {} bash -c "download_asset '$version' '$KDBP_URL/$version/$date' '{}' \"\$BEARER\""

done < <(echo "$versions_json" | jq -r '.assets[].path // empty')

echo ""
echo "=========================================="
echo "Downloading kdb-x"
echo "=========================================="

# Get latest kdb-x version
KDBX_BASE="https://portal.dl.kx.com/assets/raw/kdb-x/kdb-x"
kdbx_versions=$(curl -sSfL --oauth2-bearer "$BEARER" "$KDBX_BASE")
kdbx_latest=$(echo "$kdbx_versions" | jq -r '.assets[0].path // empty' | sed 's/\///g')

if [[ -n "$kdbx_latest" ]]; then
    echo "Processing kdb-x version: $kdbx_latest"
    mkdir -p "x"

    # Create version marker file
    touch "x/$kdbx_latest"

    kdbx_assets=$(curl -sSfL --oauth2-bearer "$BEARER" "$KDBX_BASE/$kdbx_latest" | jq -r '.assets[].path // empty' | grep -v '^$')

    echo "$kdbx_assets" | xargs -P "$MAX_PARALLEL" -I {} bash -c "download_asset 'x' '$KDBX_BASE/$kdbx_latest' '{}' \"\$BEARER\""
else
    echo "Warning: No kdb-x versions found" >&2
fi

echo ""
echo "=========================================="
echo "Downloading install_kdb"
echo "=========================================="

# Get latest install_kdb version
INSTALL_BASE="https://portal.dl.kx.com/assets/raw/kdb-x/install_kdb"
install_versions=$(curl -sSfL --oauth2-bearer "$BEARER" "$INSTALL_BASE")
install_latest=$(echo "$install_versions" | jq -r '.assets[0].path // empty' | sed 's/\///g')

if [[ -n "$install_latest" ]]; then
    echo "Processing install_kdb version: $install_latest"
    mkdir -p "x/install"

    # Create version marker file
    touch "x/install/$install_latest"

    install_assets=$(curl -sSfL --oauth2-bearer "$BEARER" "$INSTALL_BASE/$install_latest" | jq -r '.assets[].path // empty' | grep -v '^$')

    echo "$install_assets" | xargs -P "$MAX_PARALLEL" -I {} bash -c "download_asset 'x/install' '$INSTALL_BASE/$install_latest' '{}' \"\$BEARER\""
else
    echo "Warning: No install_kdb versions found" >&2
fi

echo ""
echo "=========================================="
echo "Moving files to destination"
echo "=========================================="

# Go back to original directory
cd "$OLDPWD"

# Create q directory if it doesn't exist
mkdir -p q

# Move all downloaded content to q/
echo "Moving downloaded files to q/..."
for item in "$TEMP_DIR"/*; do
    if [[ -e "$item" ]]; then
        item_name=$(basename "$item")
        if [[ -e "q/$item_name" ]]; then
            echo "Removing existing q/$item_name"
            rm -rf "q/$item_name"
        fi
        mv "$item" q/
        echo "✓ Moved $item_name to q/"
    fi
done

echo ""
echo "✓ All downloads complete!"
echo "Files are located in: $(pwd)/q/"
