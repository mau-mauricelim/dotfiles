#!/usr/bin/env bash
main() {
    # NOTE: If `ONE_TIME_SETUP` is set to true
    #       kdb+ binaries will only be installed the first time if:
    #           1. Directory "$LIN_Q_HOME" does not exist OR
    #           2. Directory "$LIN_Q_HOME" does not contain any kdb+ binaries (x or [3-4].[0-9]) directories
    #       To always check for updated license file or kdb+ binaries, unset `ONE_TIME_SETUP` (or set it to anything other than true)
    #       However, this will slow down the startup shell significantly.
    #       Personal startup times:
    #           1. ONE_TIME_SETUP=true                 |  .142742216 seconds ⚡
    #           2. ONE_TIME_SETUP= with `fd` installed |  .297109394 seconds 🚀 (recommended)
    #           3. ONE_TIME_SETUP= with default `find` | 1.039979396 seconds 🐢
    local ONE_TIME_SETUP=true

    local DEFAULT_Q_VER=4.1
    # local DEFAULT_Q_VER=x
    WIN_Q_HOME=/mnt/c/q
    LIN_Q_HOME=$HOME/q
    local INIT_FILE=q.q
    local LIN_Q_INIT="$LIN_Q_HOME/$INIT_FILE"
    local BIT=64
    WIN_OS=w$BIT
    LIN_OS=l$BIT
    local GREP=grep
    command -v rg >/dev/null && local GREP=rg
    local Q_REPO=qoolbox

    # Check if WSL
    if isWsl; then wsl_kdb_setup; fi

    [ -d "$LIN_Q_HOME" ] &&\
        export LIN_Q_HOME || exit

    [ ! -d "$HOME/$Q_REPO" ] && echo "💡 Clone $Q_REPO (cool q toolbox) to home directory"
    [ -d "$HOME/$Q_REPO" ] && broken_symlink "$LIN_Q_HOME/q.q" &&\
        echo "🔗 Symlinking q.q to $Q_REPO" &&\
        ln -sf "$HOME/$Q_REPO/q.q" "$LIN_Q_HOME/q.q"

    [ -f "$HOME/$Q_REPO/lib/rlwrap/rlwrap_completion" ] && broken_symlink "$LIN_Q_HOME/rlwrap_completion" &&\
        echo "🔗 Symlinking rlwrap_completion to $Q_REPO" &&\
        ln -sf "$HOME/$Q_REPO/lib/rlwrap/rlwrap_completion" "$LIN_Q_HOME/rlwrap_completion"

    [ -f "$LIN_Q_INIT" ] && export QINIT="$LIN_Q_INIT"

    local q_ver_installed
    for q_ver_path in $(get_q_ver_path "$LIN_Q_HOME" "$LIN_OS"); do
        q_ver_installed=$(get_q_ver "$q_ver_path")
        alias_setup "$q_ver_installed" "$LIN_OS"
    done
}

broken_symlink() { [ ! -L "$1" ] || [ ! -e "$1" ]; }
first_setup() { echo "🚀 Setting up kdb+ binaries for the first time"; mkdir -pv "$LIN_Q_HOME"; }
get_q_ver_path() {
    if command -v fd >/dev/null; then
        fd -L --glob "{q,q.exe}" --exact-depth 3 --type f "$1" | $GREP "$2/q"
    else
        find -L "$1" -mindepth 3 -maxdepth 3 -type f -name 'q' -o -name 'q.exe' | $GREP "$2/q"
    fi
    }
get_q_ver() { echo "$1" | rev | cut -d'/' -f3 | rev; }
install_q_ver() { echo "⚡ Installing kdb+ version: $1"; cp -r "$WIN_Q_HOME/$1" "$LIN_Q_HOME"; }
# shellcheck disable=SC2139
alias_setup() {
    local stripped_version
    stripped_version=$(echo "$1" | tr -d '.') # 4.1 becomes 41
    if [[ "$WIN_Q" == "true" ]] && [[ "$2" == "$WIN_OS" ]]; then
        local q_alias="cp $WIN_Q_HOME/$1/q.k $WIN_Q_HOME && $WIN_Q_HOME/$1/$WIN_OS/q.exe"
    else
        local q_alias="run_q $1"
    fi
    alias "q$stripped_version"="$q_alias"
    # Set default q version
    if [[ "$1" == "$DEFAULT_Q_VER" ]]; then alias q="$q_alias"; fi
    LIN_Q_VERSIONS+=("$LIN_Q_HOME/$1")
}

wsl_kdb_setup() {
    local ID
    ID=$(awk -F= '$1=="ID" { print $2; }' /etc/os-release)
    case "$ID" in
        # HACK: For distros that uses musl but does not support gcompat:
        # - The convoluted solution is to run the windows kdb+ binaries
        # - WARN: There may be compatibility issues
        musl|unsupported|distro|names)
            local WIN_Q=true
            ;;
        *)
            ;;
    esac

    # Check if kdb+ binaries exist
    if [ -d "$WIN_Q_HOME" ]; then
        if [ ! -d "$LIN_Q_HOME" ];                                                                                     then first_setup
        elif ! find "$LIN_Q_HOME" -mindepth 1 -maxdepth 1 -type d \( -name "x" -o -name "[3-4].[0-9]" \) | $GREP -q .; then first_setup
        elif [[ "$ONE_TIME_SETUP" == "true" ]]; then return
        fi

        local win_q_ver_avail q_ver_installed
        for win_q_ver_path in $(get_q_ver_path "$WIN_Q_HOME" "$LIN_OS"); do
            win_q_ver_avail=$(get_q_ver "$win_q_ver_path")
            for q_ver_path in $(get_q_ver_path "$LIN_Q_HOME" "$LIN_OS"); do
                q_ver_installed=$(get_q_ver "$q_ver_path")
                if [[ "$q_ver_installed" == "$win_q_ver_avail" ]]; then
                    if ! cmp -s "$win_q_ver_path" "$q_ver_path"; then install_q_ver "$win_q_ver_avail"; fi
                        continue 2
                fi
            done
            install_q_ver "$win_q_ver_avail"
        done

        if [[ "$WIN_Q" == "true" ]]; then
            local win_q_ver_avail
            for win_q_ver_path in $(get_q_ver_path "$WIN_Q_HOME" "$WIN_OS"); do
                win_q_ver_avail=$(get_q_ver "$win_q_ver_path")
                alias_setup "$win_q_ver_avail" "$WIN_OS"
            done
            exit
        fi
    fi
}

main

unset -f main broken_symlink first_setup get_q_ver_path get_q_ver install_q_ver alias_setup wsl_kdb_setup

run_q() {
    export QHOME="$LIN_Q_HOME/$1"
    # export LD_LIBRARY_PATH=
    # Add q PATH if it does not exist
    [[ ! "$PATH" =~ $LIN_Q_HOME/*/$LIN_OS ]] && addToPath "$QHOME/$LIN_OS"
    # Replace q PATH with correct version
    # shellcheck disable=SC2001
    PATH=$(echo "$PATH" | sed "s:$LIN_Q_HOME/.*/$LIN_OS:$QHOME/$LIN_OS:g")
    export PATH
    # shellcheck disable=SC2124
    QCMD="q ${@:2}"
    if command -v rlwrap >/dev/null; then
        RLWRAP="rlwrap -r";
        if [ -f "$LIN_Q_HOME/rlwrap_completion" ]; then RLWRAP+=" -f $LIN_Q_HOME/rlwrap_completion"; fi
        QCMD="$RLWRAP $QCMD"
    fi
    eval "$QCMD"
}

# List all available q versions
qv() { printf "%s\\n" "${LIN_Q_VERSIONS[@]}"; }
