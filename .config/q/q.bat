@echo off
goto comment
Running multiple versions of kdb+

Place this script in a directory (recommended: C:\q)
And add this directory to PATH (echo %PATH% | find /i "C:\q" > nul || set PATH=%PATH%;"C:\q")

Usage:
q
q <version>
q 4.0
q 4.1
:comment

:: Script starts here
:: Windows variables are not case-sensitive
:: Set default q version
set q_ver=4.1
set q_home=C:\q
set "args="

:: No arguments
IF "%~1"=="" (
    set QVER=%q_ver%
    goto :run_q
)

:: First argument is a version number
echo %1| findstr /r "^[0-9]\.[0-9]$" >nul
IF %errorlevel%==0 (
    :: Check if the q version exists
    IF exist "%q_home%\%1" (
        set QVER=%1
        :: Shift the first argument
        shift
    ) ELSE (
        echo [ERROR]: q version: %1 not found: %q_home%\%1
        echo [INFO]: Using default set q version: %q_ver%
        set QVER=%q_ver%
    )
) ELSE (
    set QVER=%q_ver%
)

:: Get remaining arguments
set "args="
:loop
if "%~1"=="" goto :done
set "args=%args% %1"
shift
goto :loop
:done

:run_q
set QHOME=%q_home%\%QVER%
IF exist "%QHOME%\w64" (
    %QHOME%\w64\q %args%
) ELSE (
    %QHOME%\w32\q %args%
)
