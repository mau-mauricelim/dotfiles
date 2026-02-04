$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Log($msg) {
    $ts = (Get-Date).ToString("yyyy.MM.ddDHH:mm:ss.fffffff")
    Write-Host "$ts [INFO]: $msg" -ForegroundColor Cyan
}

Log "Starting Cloudparty"

Log "Starting Copyparty in a new window"
$copyparty = Start-Process `
    -FilePath "cmd.exe" `
    -ArgumentList "/c party.py -c copyparty.conf" `
    -PassThru `
    -WindowStyle Normal
Log "Copyparty started"

Log "Starting Cloudflare Tunnel"
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "cloudflared"
$pinfo.Arguments = "tunnel --url http://127.0.0.1:3923"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true
$cloudflared = New-Object System.Diagnostics.Process
$cloudflared.StartInfo = $pinfo

# Use a thread-safe synchronized wrapper for the flag
$syncHash = [Hashtable]::Synchronized(@{ TunnelReady = $false })

# Event Handler: parses output
$outputAction = {
    param($sender, $e)
    if ($e.Data) {
        # Print exact output to console
        [Console]::WriteLine($e.Data)
        # Strip ANSI color codes for reliable regex matching
        $cleanLine = $e.Data -replace '\x1b\[[0-9;]*m',''
        # Copy quick Tunnel URL
        if ($cleanLine -match "(https://[\w-]+\.trycloudflare\.com)") {
            $url = $matches[1]
            try {
                Set-Clipboard -Value $url
                Log "Quick Tunnel URL has been copied to the clipboard!"
            } catch {
                Write-Host "$ts [ERROR]: $_" -ForegroundColor Red
            }
        }
        # Detect Ready Signal
        if ($cleanLine -match "Registered tunnel connection") {
            $Event.MessageData.TunnelReady = $true
        }
    }
}

# Register events passing the synchronized hash as MessageData
Register-ObjectEvent -InputObject $cloudflared -EventName "ErrorDataReceived" -Action $outputAction -MessageData $syncHash | Out-Null
Register-ObjectEvent -InputObject $cloudflared -EventName "OutputDataReceived" -Action $outputAction -MessageData $syncHash | Out-Null

$cloudflared.Start() | Out-Null
$cloudflared.BeginErrorReadLine()
$cloudflared.BeginOutputReadLine()

# Teardown logic
$global:cpTeardownDone = $false
$cleanup = {
    if ($global:cpTeardownDone) { return }
    $global:cpTeardownDone = $true
    Log "Stopping all processes"
    if ($cloudflared -and !$cloudflared.HasExited) {
        Log "Stopping Cloudflare Tunnel [PID: $($cloudflared.Id)]"
        try {
            Stop-Process -Id $cloudflared.Id -Force -ErrorAction SilentlyContinue
            Log "Cloudflare Tunnel stopped"
        } catch {
            Write-Host "$ts [ERROR]: $_" -ForegroundColor Red
        }
    } else {
        Log "Cloudflare Tunnel already stopped"
    }
    if ($copyparty -and !$copyparty.HasExited) {
        Log "Stopping Copyparty [PID: $($copyparty.Id)]"
        try {
            taskkill /PID $copyparty.Id /T /F | Out-Null
            Log "Copyparty stopped"
        } catch {
            Write-Host "$ts [ERROR]: $_" -ForegroundColor Red
        }
    } else {
        Log "Copyparty already stopped"
    }
    Log "All processes stopped"
}

try {
    # Wait for tunnel connection registration or timeout (30s)
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $syncHash.TunnelReady -and $timer.Elapsed.TotalSeconds -lt 30) {
        # If copyparty crashes early, stop waiting
        if ($copyparty.HasExited) { throw "Copyparty exited unexpectedly" }
        Start-Sleep -Milliseconds 100
    }
    Log "Cloudparty running"

    # Robust wait for Copyparty
    if (-not $copyparty.HasExited) { Wait-Process -Id $copyparty.Id }
    Log "Copyparty exited"
}
catch {
    Write-Host "$ts [ERROR]: $_" -ForegroundColor Red
}
finally {
    & $cleanup
}
