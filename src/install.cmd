@echo off
@SET distro_name=ubuntu-latest
@SET dir=%cd%
@SET CONFIRM=n
@echo Importing WSL distribution: [%distro_name%]
@echo from current directory: [%dir%]

setlocal
@echo(
@echo This action will overwrite any existing WSL distribution with the same name: [%distro_name%].
:PROMPT
SET /P CONFIRM=Do you want to continue? [Y/n]
IF /I "%CONFIRM%" NEQ "Y" GOTO END

@powershell -Command "if((wsl -l -v | Where {$_.Replace(\"`0\",\"\") -match \" %distro_name% \"}).count -gt 0) {wsl --unregister %distro_name%}"
@powershell -Command "$InstallLocation='%USERPROFILE%\AppData\Local\Packages\WslCustomDistro\%distro_name%'; if(-not(Test-Path -PathType container $InstallLocation)) {$null = new-item $InstallLocation -ItemType Directory}; wsl --import %distro_name% $InstallLocation $(ls .\*.tar.gz)"
@REM set default?

:END
endlocal
@pause
