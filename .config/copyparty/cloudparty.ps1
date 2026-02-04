$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# Log -msg "This will use the default lvl"
function Log($lvl = "INFO", $msg) {
    $ts = (Get-Date).ToString("yyyy.MM.ddDHH:mm:ss.fffffff")
    $lvl = $lvl.ToUpper()
    # List all possible colors in powershell
    # PS > [enum]::GetValues([System.ConsoleColor]) | ForEach-Object { Write-Host $_ -ForegroundColor $_ }
    $color = switch ($lvl) {
        "ERROR" { "Red" }
        "WARN" { "DarkYellow" }
        "INFO" { "Cyan" }
        "DEBUG" { "Magenta" }
        # Use terminal default text color
        default { $null }
    }
    Write-Host "$ts [$lvl]: $msg" -ForegroundColor $color
}

# NOTE: Cloudflare tunnel starts up slower
Log "INFO" "Starting Cloudparty"

Log "INFO" "Starting Cloudflare tunnel in a new window"

$logName = "cloudflared.tmp"
$logPath = Join-Path $PSScriptRoot $logName
Log "INFO" "Cloudflare tunnel temporary log file: $logPath"

$cloudflared = Start-Process `
    -FilePath "cloudflared" `
    -ArgumentList "tunnel --url http://127.0.0.1:3923 --logfile `"$logPath`"" `
    -PassThru -WindowStyle Normal
Log "INFO" "Cloudflare tunnel started"

Log "INFO" "Starting Copyparty in a new window"
$copyparty = Start-Process `
    -FilePath "cmd.exe" `
    -ArgumentList "/c party.py -c copyparty.conf" `
    -PassThru -WindowStyle Normal
Log "INFO" "Copyparty started"

# Use a thread-safe synchronized wrapper for the flag
$syncHash = [Hashtable]::Synchronized(@{
    TunnelReady = $false
    UrlCopied = $false
})

# Cleanup logic
$global:cpTeardownDone = $false
$cleanup = {
    if ($global:cpTeardownDone) { return }
    $global:cpTeardownDone = $true

    Log "INFO" "Stopping all processes"

    # NOTE: Copyparty stops slower
    if ($copyparty -and !$copyparty.HasExited) {
        Log "INFO" "Stopping Copyparty [PID: $($copyparty.Id)]"
        try {
            taskkill /PID $copyparty.Id /T /F | Out-Null
            Log "INFO" "Copyparty stopped"
        } catch {
            Log "ERROR" "Failed to stop Copyparty"
            Log "ERROR" "$_"
        }
    } else {
        Log "INFO" "Copyparty already stopped"
    }

    if ($cloudflared -and !$cloudflared.HasExited) {
        Log "INFO" "Stopping Cloudflare tunnel [PID: $($cloudflared.Id)]"
        try {
            Stop-Process -Id $cloudflared.Id -Force -ErrorAction SilentlyContinue
            Log "INFO" "Cloudflare tunnel stopped"
        } catch {
            Log "ERROR" "Failed to stop Cloudflare tunnel"
            Log "ERROR" "$_"
        }
    } else {
        Log "INFO" "Cloudflare tunnel already stopped"
    }

    if (Test-Path $logPath) {
        Log "DEBUG" "Removing Cloudflare tunnel temporary log file: $logPath"
        try {
            Remove-Item $logPath -Force -ErrorAction SilentlyContinue
            Log "DEBUG" "Removed Cloudflare tunnel temporary log file"
        } catch {
            Log "WARN" "Failed to remove Cloudflare tunnel temporary log file"
        }
    }

    Log "INFO" "All processes stopped"
}

try {
    # Wait and watch for quick tunnel URL and connection registration with a timeout of 30s
    $timeout = 30
    Log "INFO" "Watching Cloudflare tunnel temporary log file"
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $syncHash.TunnelReady -and $timer.Elapsed.TotalSeconds -lt $timeout) {
        if ($copyparty.HasExited) { throw "Copyparty exited unexpectedly" }
        if ($cloudflared.HasExited) { throw "Cloudflare tunnel exited unexpectedly" }

        # Read log file if it exists
        if (Test-Path $logPath) {
            try {
                $content = Get-Content $logPath -Raw -ErrorAction SilentlyContinue
                if ($content) {
                    # Copy quick tunnel URL to clipboard once
                    if (-not $syncHash.UrlCopied -and $content -match "(https://[\w-]+\.trycloudflare\.com)") {
                        $url = $matches[1]
                        try {
                            Log "INFO" "Your quick Tunnel has been created! Visit it at (it may take some time to be reachable):"
                            Log "INFO" $url
                            Set-Clipboard -Value $url
                            Log "INFO" "URL copied to the clipboard!"
                            $syncHash.UrlCopied = $true
                        } catch {
                            Log "ERROR" "Failed to copy Cloudflare quick tunnel URL to the clipboard"
                            Log "ERROR" "$_"
                        }
                    }
                    # Detect tunnel connection registration
                    if ($content -match "Registered tunnel connection") {
                        $syncHash.TunnelReady = $true
                        Log "INFO" "Registered Cloudflare tunnel connection with Copyparty!"
                        Log "INFO" "Cloudparty UP and running!"
                        break
                    }
                }
            } catch {
                # Ignore transient file access errors
            }
        }
        Start-Sleep -Milliseconds 200
    }

    if (-not $syncHash.TunnelReady) { throw "Cloudflare tunnel connection with Copyparty not registered within $timeout seconds - aborting" }

    # Wait for either process to exit - if one stops, kill everything
    while (-not $copyparty.HasExited -and -not $cloudflared.HasExited) {
        Start-Sleep -Milliseconds 500
    }

    if ($copyparty.HasExited) { Log "INFO" "Copyparty exited" }
    if ($cloudflared.HasExited) { Log "INFO" "Cloudflare tunnel exited" }
}
catch {
    Log "ERROR" "$_"
}
finally {
    & $cleanup
}
