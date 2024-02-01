@echo off
@SET distro_name=SET_DISTRO_NAME
@SET dir=%cd%
@echo Importing WSL distribution: [%distro_name%]
@echo from current directory: [%dir%]

setlocal
@echo(
@echo This action will overwrite any existing WSL distribution with the same name: [%distro_name%].
@SET CONFIRM=n
:PROMPT
SET /P CONFIRM=Do you want to continue? [Y/n] 
IF /I "%CONFIRM%" NEQ "Y" GOTO END
@powershell -Command "if((wsl -l -v | Where {$_.Replace(\"`0\",\"\") -match \" %distro_name% \"}).count -gt 0) {wsl --unregister %distro_name%}; $InstallLocation='%USERPROFILE%\AppData\Local\Packages\WslCustomDistro\%distro_name%'; if(-not(Test-Path -PathType container $InstallLocation)) {$null = new-item $InstallLocation -ItemType Directory}; wsl --import %distro_name% $InstallLocation $(ls .\*.tar.gz)"

@echo(
@SET CONFIRM=n
:PROMPT
SET /P CONFIRM=Set WSL distribution [%distro_name%] as default? [Y/n] 
IF /I "%CONFIRM%" NEQ "Y" GOTO END
@powershell -Command "wsl -s %distro_name%"

:END
@echo(
@powershell -Command "wsl -l -v"
endlocal
@pause
