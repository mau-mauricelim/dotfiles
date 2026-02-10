:: Installs and update copyparty and cloudflared
@echo off

set dir=C:\copyparty
set /P dir="Enter install path (%dir%): "
echo.

:: Normalize path
set "dir=%dir:/=\%"
:strip_double
set "oldDir=%dir%"
set "dir=%dir:\\=\%"
if not "%dir%"=="%oldDir%" goto :strip_double
if "%dir:~-1%"=="\" set "dir=%dir:~0,-1%"

echo Install path: %dir%
echo.
md %dir% 2>nul
md %dir%\icons 2>nul

call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/cloudparty.bat" "%dir%\cloudparty.bat"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/cloudparty.ps1" "%dir%\cloudparty.ps1"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/copyparty.conf" "%dir%\copyparty.conf"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/install.bat" "%dir%\install.bat"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/party.bat" "%dir%\party.bat"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/READMD.md" "%dir%\READMD.md"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/windows.md" "%dir%\windows.md"

call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/icons/gemini_cloudparty.ico" "%dir%\icons\gemini_cloudparty.ico"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/copyparty/icons/gemini_copyparty.ico" "%dir%\icons\gemini_copyparty.ico"

:: Runs copyparty from any directory
call :download "https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py" "%dir%\party.py"
call :download "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" "%dir%\cloudflared.exe"

set confirm=n
set /P confirm=Do you want to create Desktop shortcuts? [Y/n] 
echo.
if /I "%confirm%" NEQ "Y" goto pathcheck

powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\cloudparty.lnk'); $s.TargetPath='%dir%\cloudparty.bat'; $s.WorkingDirectory='%dir%'; $s.IconLocation='%dir%\icons\gemini_cloudparty.ico'; $s.Save()"
echo Created Desktop shortcut for: cloudparty
echo.
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\party.lnk'); $s.TargetPath='%dir%\party.bat'; $s.WorkingDirectory='%dir%'; $s.IconLocation='%dir%\icons\gemini_copyparty.ico'; $s.Save()"
echo Created Desktop shortcut for: party
echo.

:pathcheck
powershell -Command "$p = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User'); $found = $p.Split(';') | ForEach-Object { $_.TrimEnd('\') } | Where-Object { $_ -ieq '%dir%' }; if ($found) { exit 0 } else { exit 1 }"

if %errorlevel% equ 0 (
    echo [OK] %dir% found in User PATH
    echo.
) else (
    echo [!!] %dir% not found in User PATH
    echo.
    set confirm=n
    set /P confirm=Do you want to add %dir% to User PATH? [Y/n] 
    echo.
    if /I "%confirm%" NEQ "Y" goto end

    :: Add directory to User PATH
    powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%dir%', 'User')"
    :: Add directory to current session PATH
    set "PATH=%PATH%;%dir%"
    echo [OK] %dir% added to User PATH
    echo.
)

:end
echo Install complete!
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
