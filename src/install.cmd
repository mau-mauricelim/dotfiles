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
@SET WslCustomDistro=%USERPROFILE%\AppData\Local\Packages\WslCustomDistro
@powershell -Command "if((wsl -l -v | Where {$_.Replace(\"`0\",\"\") -match \" %distro_name% \"}).count -gt 0) {wsl --unregister %distro_name%}; $InstallLocation='%WslCustomDistro%\%distro_name%'; if(-not(Test-Path -PathType container $InstallLocation)) {$null = new-item $InstallLocation -ItemType Directory}; echo \"Installing to [$InstallLocation]\";wsl --import %distro_name% $InstallLocation $(ls .\*.tar.gz)"
@REM Clean up WslCustomDistro path
@powershell -Command "gci '%WslCustomDistro%' -directory -recurse | Where { (gci $_.fullName).count -eq 0 } | select -expandproperty FullName | Foreach-Object { Remove-Item $_ }"

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