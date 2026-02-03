:: Runs copyparty with cloudflared tunnel
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0cloudparty.ps1" && exit 0 || exit 1
