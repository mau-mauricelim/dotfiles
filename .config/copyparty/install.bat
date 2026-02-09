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

set confirm=n
set /P confirm=Do you want to create desktop shortcuts? [Y/n] 
if /I "%confirm%" NEQ "Y" goto end

powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\cloudparty.lnk'); $s.TargetPath='%dir%\cloudparty.bat'; $s.WorkingDirectory='%dir%'; $s.Save()"
echo "Created desktop shortcut for: cloudparty"
echo.
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\party.lnk'); $s.TargetPath='%dir%\party.bat'; $s.WorkingDirectory='%dir%'; $s.Save()"
echo "Created desktop shortcut for: party"
echo.

:end

:: TODO: Check if PATH is set
:: TODO: Add desktop shortcuts icons

echo "Install complete!"
pause
:: Exit the script
exit /b

:download
set url=%~1
set out=%~2
echo Downloading %url% to %out% ...
:: Add a Cache-Busting Query Parameter to fetch the latest version from source
curl -sL "%url%?v=%RANDOM%" -o "%out%"
echo Download complete!
echo.
:: Exit the function
exit /b
