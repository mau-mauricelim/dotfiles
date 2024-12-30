#!/usr/bin/env bash
# Check if WSL
if isWsl; then
    # alias q='~/q/w64/./q.exe'
    alias q='/mnt/c/q/w64/q.exe'
else
    if command -v rlwrap >/dev/null; then
        alias q35='QHOME=~/q/3.5/2016.10.03 rlwrap -r ~/q/3.5/2016.10.03/l32/q'
        alias q36='QHOME=~/q/3.6/2019.04.02 rlwrap -r ~/q/3.6/2019.04.02/l32/q'
        alias q='q36'
    else
        alias q35='QHOME=~/q/3.5/2016.10.03 ~/q/3.5/2016.10.03/l32/q'
        alias q36='QHOME=~/q/3.6/2019.04.02 ~/q/3.6/2019.04.02/l32/q'
        alias q='q36'
    fi
fi
