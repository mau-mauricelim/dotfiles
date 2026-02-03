@echo off

goto comment
Install/update Windows copyparty and cloudflared
Place this script in a directory (recommended: C:\copyparty)
And add this directory to PATH
:comment

set dir=C:\copyparty
md %dir% 2>nul

call :download "https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py" "%dir%\party.py"
call :download "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" "%dir%\cloudflared.exe"

:: pause

:: Exit the script
exit /b

:download
set url=%~1
set out=%~2
echo Downloading %url% to %out% ...
curl -sL "%url%" -o "%out%"
echo Download complete!
echo.
:: Exit the function
exit /b
