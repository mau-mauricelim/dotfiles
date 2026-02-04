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

Log "INFO" "Starting Cloudparty"

Log "INFO" "Starting Copyparty in a new window"
$copyparty = Start-Process `
    -FilePath "cmd.exe" `
    -ArgumentList "/c party.py -c copyparty.conf" `
    -PassThru `
    -WindowStyle Normal
Log "INFO" "Copyparty started"

Log "INFO" "Starting Cloudflare Tunnel in a new window"
$logPath = Join-Path $PSScriptRoot "cloudflared.log"

# Remove old log file if it exists
if (Test-Path $logPath) {
    Remove-Item $logPath -Force
    Log "DEBUG" "Removed old cloudflared.log"
}

$cloudflared = Start-Process `
    -FilePath "cloudflared" `
    -ArgumentList "tunnel --url http://127.0.0.1:3923 --logfile `"$logPath`"" `
    -PassThru `
    -WindowStyle Normal
Log "INFO" "Cloudflare Tunnel started in new window with logging"

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
    if ($cloudflared -and !$cloudflared.HasExited) {
        Log "INFO" "Stopping Cloudflare Tunnel [PID: $($cloudflared.Id)]"
        try {
            Stop-Process -Id $cloudflared.Id -Force -ErrorAction SilentlyContinue
            Log "INFO" "Cloudflare Tunnel stopped"
        } catch {
            Log "ERROR" "Failed to stop Cloudflare Tunnel"
            Log "ERROR" "$_"
        }
    } else {
        Log "INFO" "Cloudflare Tunnel already stopped"
    }
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
    # Clean up log file
    if (Test-Path $logPath) {
        try {
            Remove-Item $logPath -Force -ErrorAction SilentlyContinue
            Log "DEBUG" "Cleaned up cloudflared.log"
        } catch {
            Log "WARN" "Could not remove cloudflared.log"
        }
    }
    Log "INFO" "All processes stopped"
}

try {
    # Wait for Tunnel connection registration or timeout (30s)
    Log "INFO" "Monitoring cloudflared.log for tunnel URL and ready state..."
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $syncHash.TunnelReady -and $timer.Elapsed.TotalSeconds -lt 30) {
        # If copyparty crashes early, stop waiting
        if ($copyparty.HasExited) { throw "Copyparty exited unexpectedly" }

        # If cloudflared crashes early, stop waiting
        if ($cloudflared.HasExited) { throw "Cloudflared exited unexpectedly" }

        # Check if log file exists and read it
        if (Test-Path $logPath) {
            try {
                $content = Get-Content $logPath -Raw -ErrorAction SilentlyContinue

                if ($content) {
                    # Strip ANSI color codes for reliable regex matching
                    $cleanContent = $content -replace '\x1b\[[0-9;]*m',''

                    # Extract and copy URL (only once)
                    if (-not $syncHash.UrlCopied -and $cleanContent -match "(https://[\w-]+\.trycloudflare\.com)") {
                        $url = $matches[1]
                        try {
                            Set-Clipboard -Value $url
                            Log "INFO" "Quick Tunnel URL has been copied to the clipboard!"
                            Log "INFO" "Tunnel URL: $url"
                            $syncHash.UrlCopied = $true
                        } catch {
                            Log "ERROR" "Failed to copy quick Tunnel URL to the clipboard"
                            Log "ERROR" "$_"
                        }
                    }

                    # Detect Tunnel connection registration
                    if ($cleanContent -match "Registered tunnel connection") {
                        $syncHash.TunnelReady = $true
                        Log "INFO" "Tunnel connection registered successfully"
                    }
                }
            } catch {
                # Ignore transient file access errors
            }
        }

        Start-Sleep -Milliseconds 200
    }

    if (-not $syncHash.TunnelReady) {
        Log "WARN" "Tunnel did not register within 30 seconds"
    }

    Log "INFO" "Cloudparty running"

    # Robust wait for Copyparty
    if (-not $copyparty.HasExited) { Wait-Process -Id $copyparty.Id }
    Log "INFO" "Copyparty exited"
}
catch {
    Log "ERROR" "$_"
}
finally {
    & $cleanup
}
