@echo off
goto comment
Install/update copyparty version

Place this script in a directory (recommended: C:\copyparty)
And add this directory to PATH
:comment

set dir=C:\copyparty
set url=https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py
set out=%dir%\party.py

md %dir%
curl -sL %url% -o %out%
