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

@powershell -Command "wsl --import %distro_name% '%USERPROFILE%\AppData\Local\Packages' .\zsh-nvim.tar.gz"

:END
endlocal
@pause
