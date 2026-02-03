$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Log($msg) {
    $ts = (Get-Date).ToString("yyyy.MM.ddDHH:mm:ss.fffffff")
    Write-Host "$ts [INFO]: $msg"
}

Log "Starting cloudparty"

Log "Starting copyparty in a new window ..."
$copyparty = Start-Process `
    -FilePath "cmd.exe" `
    -ArgumentList "/c party.py -c copyparty.conf" `
    -PassThru `
    -WindowStyle Normal

# Port defined in ./copyparty.conf
Log "Starting cloudflared tunnel ..."
$cloudflared = Start-Process `
    -FilePath "cloudflared" `
    -ArgumentList "tunnel --url http://127.0.0.1:3923" `
    -PassThru `
    -NoNewWindow

$script:teardownDone = $false

$cleanup = {
    if ($script:teardownDone) { return }
    $script:teardownDone = $true

    Log "Teardown initiated ..."
    if ($cloudflared -and !$cloudflared.HasExited) {
        Log "Stopping cloudflared tunnel [PID: $($cloudflared.Id)] ..."
        Stop-Process -Id $cloudflared.Id -Force
    } else {
        Log "cloudflared tunnel already stopped"
    }
    if ($copyparty -and !$copyparty.HasExited) {
        Log "Stopping copyparty [PID: $($copyparty.Id)] ..."
        taskkill /PID $copyparty.Id /T /F | Out-Null
    } else {
        Log "copyparty already stopped"
    }
    Log "All processes stopped"
}

# Ctrl-C / Window Close
$null = Register-EngineEvent PowerShell.Exiting -Action $cleanup

# Give cloudflared some time to start up
Start-Sleep -Seconds 10
Log "cloudparty running"

try {
    Wait-Process -Id $copyparty.Id
    Log "copyparty exited"
}
finally {
    & $cleanup
}
