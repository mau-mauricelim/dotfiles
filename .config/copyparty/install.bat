:: Installs and update copyparty and cloudflared
@echo off

:: NOTE: Add this directory to PATH
set dir=C:\copyparty
set /P dir="Enter install path (%dir%): "
echo "Install path: %dir%"
md %dir% 2>nul

call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/cloudparty.bat" "%dir%\cloudparty.bat"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/cloudparty.ps1" "%dir%\cloudparty.ps1"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/copyparty.conf" "%dir%\copyparty.conf"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/install.bat" "%dir%\install.bat"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/party.bat" "%dir%\party.bat"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/READMD.md" "%dir%\READMD.md"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/windows.md" "%dir%\windows.md"

:: Runs copyparty from any directory
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
