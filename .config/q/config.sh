#!/usr/bin/env bash
# Set default q version
q_ver=4.1
win_q_home=/mnt/c/q
q_home=$HOME/q

# Check if WSL
if isWsl; then
    # Check if kdb+ binaries exist
    if [ -d $win_q_home ] && [ ! -d $q_home ]; then
        echo "Setting up kdb+ binaries for the first time"
        mkdir $q_home
        cp $win_q_home/kc.lic $q_home
        # Copy q version programmatically
        if ls "$win_q_home"/[0-9].[0-9] >/dev/null 2>&1; then
            for VER in $(ls -d $win_q_home/[0-9].[0-9]); do
                VER=$(echo $VER|awk -F'/' '{print $NF}')
                mkdir $q_home/$VER
                cp -r $win_q_home/$VER/{l64,q.k} $q_home/$VER
            done
        fi
    fi
    ID=$(awk -F= '$1=="ID" { print $2; }' /etc/os-release)
    case $ID in
        # HACK: For distros that uses musl but does not support gcompat:
        # - The convoluted solution is to run the windows kdb+ binaries
        # - WARN: There may be compatibility issues
        muslDistro)
        # Set q version alias programmatically
        if ls "$win_q_home"/[0-9].[0-9] >/dev/null 2>&1; then
            for VER in $(ls -d $win_q_home/[0-9].[0-9]); do
                VER=$(echo $VER|awk -F'/' '{print $NF}')
                # HACK: Need to copy q version q.k file to C:\q
                # WARN: Do not set windows environment QHOME and QLIC
                eval "alias $(echo q$VER|tr -d '.')='cp $win_q_home/$VER/q.k $win_q_home && $win_q_home/$VER/w64/q.exe'"
            done
        fi
        # Set default q version
        [ -d $win_q_home/$q_ver ] && alias q="cp $win_q_home/$q_ver/q.k $win_q_home && $win_q_home/$q_ver/w64/q.exe"
        return
        ;;
    *)
        ;;
esac
fi

q_home=$HOME/q
[ -d $q_home ] &&\
    export QLIC=$q_home &&\
    export q_home || return
[ -f $q_home/q.q ] && export QINIT=$q_home/q.q
run_q() {
    VER=$1
    export QHOME=$q_home/$VER
    # export LD_LIBRARY_PATH=
    # Add q PATH if it does not exist
    [[ ! "$PATH" =~ "$q_home/*/l64" ]] && addToPath $QHOME/l64
    # Replace q PATH with correct version
    export PATH=$(echo $PATH | sed "s:$q_home/.*/l64:$QHOME/l64:g")
    QCMD="q ${@:2}"
    if command -v rlwrap >/dev/null; then
        QCMD="rlwrap -r "$QCMD
    fi
    eval "$QCMD"
}
# Set q version alias programmatically
if ls "$q_home"/[0-9].[0-9] >/dev/null 2>&1; then
    for VER in $(ls -d $q_home/[0-9].[0-9]); do
        VER=$(echo $VER|awk -F'/' '{print $NF}')
        eval "alias $(echo q$VER|tr -d '.')='run_q '$VER"
    done
fi
# Set default q version
[ -d $q_home/$q_ver ] && alias q="run_q $q_ver"
# List all available q versions
alias qv="ls -d $q_home/[0-9].[0-9]"
