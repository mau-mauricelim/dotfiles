#!/usr/bin/env bash
# Set default q version
q_ver=4.1
win_q_home=/mnt/c/q
q_home=$HOME/q
# TODO: Cannot run l32
ARCH=l64

# Check if WSL
if isWsl; then
    ID=$(awk -F= '$1=="ID" { print $2; }' /etc/os-release)
    case $ID in
        # HACK: For distros that uses musl but does not support gcompat:
        # - The convoluted solution is to run the windows kdb+ binaries
        # - WARN: There may be compatibility issues
        musl|unsupported|distro|names)
            WIN_Q=true
            ;;
        *)
            ;;
    esac

    # Check if kdb+ binaries exist
    if [ -d $win_q_home ]; then
        if [ ! -d "$q_home" ]; then
            echo "🚀 Setting up kdb+ binaries for the first time"
            mkdir $q_home
        elif ! find -L "$q_home" -mindepth 1 -maxdepth 1 -type d -name '[0-9].[0-9]' | grep -q .; then
            echo "🚀 Setting up kdb+ binaries for the first time"
        fi
        if [ -f "$win_q_home/kc.lic" ] && [ ! -f "$q_home/kc.lic" ]; then
            cp $win_q_home/kc.lic $q_home
        fi
        # Check if q versions exists
        if find -L "$win_q_home" -mindepth 1 -maxdepth 1 -type d -name '[0-9].[0-9]' | grep -q .; then
            # Copy q versions programmatically
            for VER in $(/bin/ls -d $win_q_home/[0-9].[0-9]); do
                VER=$(echo $VER|awk -F'/' '{print $NF}')
                if [ ! -d "$q_home/$VER" ]; then
                    mkdir $q_home/$VER
                    cp -r $win_q_home/$VER/{$ARCH,q.k} $q_home/$VER
                fi
                if [ "$WIN_Q" = "true" ]; then
                    # HACK: Need to copy q version q.k file to C:\q
                    # WARN: Do not set windows environment QHOME and QLIC
                    eval "alias $(echo q$VER|tr -d '.')='cp $win_q_home/$VER/q.k $win_q_home && $win_q_home/$VER/w64/q.exe'"
                    # Set default q version
                    if [ "$VER" = "$q_ver" ]; then
                        alias q="cp $win_q_home/$q_ver/q.k $win_q_home && $win_q_home/$q_ver/w64/q.exe"
                    fi
                fi
            done
            [ "$WIN_Q" = "true" ] && return
        fi
    fi
fi

[ -d $q_home ] &&\
    export QLIC=$q_home &&\
    export q_home || return
[ -f $q_home/q.q ] && export QINIT=$q_home/q.q

[ -d $HOME/Qurious ] && [ ! -L $q_home/q.q ] &&\
    echo "🔗 Symlinking q.q and q.test.q to Qurious" &&\
    ln -sf $HOME/Qurious/q.q $q_home/q.q &&\
    ln -sf $HOME/Qurious/q.test.q $q_home/q.test.q

run_q() {
    VER=$1
    export QHOME=$q_home/$VER
    # export LD_LIBRARY_PATH=
    # Add q PATH if it does not exist
    [[ ! "$PATH" =~ "$q_home/*/$ARCH" ]] && addToPath $QHOME/$ARCH
    # Replace q PATH with correct version
    export PATH=$(echo $PATH | sed "s:$q_home/.*/$ARCH:$QHOME/$ARCH:g")
    QCMD="q ${@:2}"
    if command -v rlwrap >/dev/null; then
        QCMD="rlwrap -r "$QCMD
    fi
    eval "$QCMD"
}
# Check if q versions exists
if find -L "$q_home" -mindepth 1 -maxdepth 1 -type d -name '[0-9].[0-9]' | grep -q .; then
    # Set q versions alias programmatically
    for VER in $(/bin/ls -d $q_home/[0-9].[0-9]); do
        VER=$(echo $VER|awk -F'/' '{print $NF}')
        eval "alias $(echo q$VER|tr -d '.')='run_q '$VER"
        # Set default q version
        if [ "$VER" = "$q_ver" ]; then
            alias q="run_q $q_ver"
        fi
    done
fi
# List all available q versions
alias qv="ls -d $q_home/[0-9].[0-9]"
