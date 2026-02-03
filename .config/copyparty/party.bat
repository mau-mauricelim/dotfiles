:: Runs copyparty with the [default config](./copyparty.conf)
@echo off
party.py -c "%~dp0copyparty.conf" && exit 0 || exit 1
