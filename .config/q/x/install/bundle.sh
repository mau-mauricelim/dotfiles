#!/bin/bash -e

# Build Bundle Script for KDB-X
# Creates platform-specific offline installation bundles

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
NC=$(tput sgr0)

SCRIPT_DIR="$(dirname "$0")"
VERSIONS_CSV="$SCRIPT_DIR/versions.csv"
PLATFORM=""
PREFIX=""
EXT="sh"
TEMP_DIR=""

print_header()  { printf "\n-------- %s --------\n" "$1"; }
print_success() { printf "%s%sSuccess: %s%s%s%s\n" "$BOLD" "$GREEN" "$NC" "$GREEN" "$1" "$NC"; }
print_warning() { printf "%sWarning: %s%s\n" "$BOLD" "$NC" "$1"; }
print_error()   { printf "%s%sError: %s%s%s%s\n" "$BOLD" "$RED" "$NC" "$RED" "$1" "$NC"; }
print_info()    { printf "%s\n" "$1"; }

print_usage() {
    cat << EOF
Usage: $0 --platform <platform> [--versions <csv_file>]

Arguments:
  --platform    Target platform (required)
                Valid platforms: l64 (Linux), l64arm (Linux ARM), m64 (macOS)
  --versions    Path to versions CSV file (optional)
                Default: $SCRIPT_DIR/versions.csv

Example:
  $0 --platform l64
  $0 --platform m64 --versions custom_versions.csv
EOF
}

parse_args() {
    if [ $# -eq 0 ]; then
        print_usage
        exit 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --platform)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    print_error "Missing value for --platform"
                    print_usage
                    exit 1
                fi
                PLATFORM="$2"
                shift 2
                ;;
            --versions)
                if [ -z "$2" ] || [[ "$2" == --* ]]; then
                    print_error "Missing value for --versions"
                    print_usage
                    exit 1
                fi
                VERSIONS_CSV="$2"
                shift 2
                ;;
            *)
                print_error "Unknown argument: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    if [ -z "$PLATFORM" ]; then
        print_error "Platform is required"
        print_usage
        exit 1
    fi

    case "$PLATFORM" in
        l64|l64arm|m64)
            PREFIX="$PLATFORM"
            ;;
        # w64)
        #     PREFIX="w64"
        #     EXT="ps1"
        #     ;;
        *)
            print_error "Invalid platform: $PLATFORM"
            print_error "Valid platforms: l64, l64arm, m64"
            exit 1
            ;;
    esac

    if [ ! -f "$VERSIONS_CSV" ]; then
        print_error "Versions CSV file not found: $VERSIONS_CSV"
        exit 1
    fi
}

download_file() {
    local url="$1"
    local output_file="$2"

    print_info "Downloading: $(basename "$output_file")"
    print_info "From: $url"

    if [ -t 1 ]; then
        curl --fail --progress-bar -Lo "$output_file" "$url"
    else
        curl --fail -Lo "$output_file" "$url"
    fi

    return $?
}

read_versions_csv() {
    local csv_file="$1"

    print_header "Reading versions from CSV"
    print_info "CSV file: $csv_file"

    tail -n +2 "$csv_file" | while IFS=, read -r component version url_template; do
        component=$(echo "$component" | xargs)
        version=$(echo "$version" | xargs)
        url_template=$(echo "$url_template" | xargs)

        print_info "  - $component: $version"
    done
}

download_component() {
    local component="$1"
    local version="$2"
    local url_template="$3"
    local output_file="$4"

    local url="${url_template//PREFIX/$PREFIX}"
    url="${url//EXT/$EXT}"

    if [ "$version" = "latest" ]; then
        url="${url//VERSION/~latest~}"
    else
        url="${url//VERSION/$version}"
    fi

    if download_file "$url" "$output_file"; then
        print_success "Downloaded $component successfully"
        return 0
    else
        print_warning "Failed to download $component"
        return 1
    fi
}

cleanup() {
    printf "$NC"
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

build_bundle() {
    print_header "Building bundle for platform: $PLATFORM"

    TEMP_DIR=$(mktemp -d -t build_bundle.XXXXXXXXXX)
    trap cleanup EXIT

    print_info "Temporary directory: $TEMP_DIR"

    print_header "Downloading components"

    local failed_components=()

    while IFS=, read -r component version url_template; do
        if [ "$component" = "component" ] || [ -z "$component" ]; then
            continue
        fi

        component=$(echo "$component" | xargs)
        version=$(echo "$version" | xargs)
        url_template=$(echo "$url_template" | xargs)

        local filename=$(basename "$url_template")
        filename="${filename//PREFIX/$PREFIX}"
        filename="${filename//EXT/$EXT}"

        print_header "Downloading $component"
        if ! download_component "$component" "$version" "$url_template" "$TEMP_DIR/$filename"; then
            failed_components+=("$component")
        fi

    done < "$VERSIONS_CSV"

    if [ ${#failed_components[@]} -gt 0 ]; then
        print_warning "Some components failed to download:"
        for comp in "${failed_components[@]}"; do
            print_warning "  - $comp"
        done
        echo
        read -p "${YELLOW}Continue creating bundle with available components? (y/n): ${NC}" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Bundle creation cancelled"
            exit 1
        fi
    fi

    print_header "Creating bundle archive"

    local bundle_name="${PREFIX}-bundle.zip"
    local bundle_path="$(pwd)/$bundle_name"

    print_info "Compressing files..."

    cd "$TEMP_DIR"
    zip -q -r "$bundle_path" .
    local zip_result=$?
    cd - > /dev/null

    if [ $zip_result -ne 0 ]; then
        print_error "Failed to create bundle archive (exit code: $zip_result)"
        exit 1
    fi

    local bundle_size=$(du -h "$bundle_path" | cut -f1)

    print_success "Bundle created successfully!"
    print_info ""
    print_info "Bundle details:"
    print_info "  Platform: $PLATFORM"
    print_info "  File: $bundle_path"
    print_info "  Size: $bundle_size"
    print_info ""
    print_info "Contents:"
    unzip -l "$bundle_path" | awk 'NR>3' | sed '$d' | sed '$d'
}

main() {
    parse_args "$@"
    read_versions_csv "$VERSIONS_CSV"
    build_bundle

    print_header "Bundle build complete"
    print_success "Ready for offline installation!"
}

main "$@"
