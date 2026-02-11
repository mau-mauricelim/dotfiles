:: Windows Install/Update of q config
@echo off

set dir=C:\q
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

call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/q/install.bat" "%dir%\install.bat"
call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/q/q.bat" "%dir%\q.bat"

call :download "https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/q/icons/gemini_q.ico" "%dir%\icons\gemini_q.ico"

set confirm=n
set /P confirm=Do you want to create a Desktop shortcut? [Y/n] 
echo.
if /I "%confirm%" NEQ "Y" goto startmenu

powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\q.lnk'); $s.TargetPath='%dir%\q.bat'; $s.WorkingDirectory='%dir%'; $s.IconLocation='%dir%\icons\gemini_q.ico'; $s.Save()"
echo Created Desktop shortcut for: q
echo.

:startmenu
set confirm=n
set /P confirm=Do you want to create a Start Menu shortcut? [Y/n] 
echo.
if /I "%confirm%" NEQ "Y" goto pathcheck

powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\q.lnk'); $s.TargetPath='%dir%\q.bat'; $s.WorkingDirectory='%dir%'; $s.IconLocation='%dir%\icons\gemini_q.ico'; $s.Save()"
echo Created Start Menu shortcut for: q
echo Pin to Start manually
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

echo Setting QINIT=%dir%\q.q in User Environment Variables
echo.
powershell -Command "[Environment]::SetEnvironmentVariable('QINIT', '%dir%\q.q', 'User')"
set "QINIT=%dir%\q.q"

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
