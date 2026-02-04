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

Log "INFO" "Starting Cloudflare Tunnel"
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

# Event Handler: captures and parses output
$outputAction = {
    param($sender, $e)
    if ($e.Data) {
        # TODO: Is there any way to stream output the console while keeping its colors?
        # Steam output to console
        [Console]::WriteLine($e.Data)
        # Strip ANSI color codes for reliable regex matching
        $cleanLine = $e.Data -replace '\x1b\[[0-9;]*m',''
        # Copy quick Tunnel URL
        if ($cleanLine -match "(https://[\w-]+\.trycloudflare\.com)") {
            $url = $matches[1]
            try {
                Set-Clipboard -Value $url
                Log "INFO" "Quick Tunnel URL has been copied to the clipboard!"
            } catch {
                Log "ERROR" "Failed to copy quick Tunnel URL to the clipboard"
                Log "ERROR" "$_"
            }
        }
        # Detect Tunnel connection registration
        if ($cleanLine -match "Registered Tunnel connection") { $Event.MessageData.TunnelReady = $true }
    }
}

# Register events passing the synchronized hash as MessageData
Register-ObjectEvent -InputObject $cloudflared -EventName "ErrorDataReceived" -Action $outputAction -MessageData $syncHash | Out-Null
Register-ObjectEvent -InputObject $cloudflared -EventName "OutputDataReceived" -Action $outputAction -MessageData $syncHash | Out-Null

$cloudflared.Start() | Out-Null
$cloudflared.BeginErrorReadLine()
$cloudflared.BeginOutputReadLine()

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
    Log "INFO" "All processes stopped"
}

try {
    # Wait for Tunnel connection registration or timeout (30s)
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $syncHash.TunnelReady -and $timer.Elapsed.TotalSeconds -lt 30) {
        # If copyparty crashes early, stop waiting
        if ($copyparty.HasExited) { throw "Copyparty exited unexpectedly" }
        Start-Sleep -Milliseconds 100
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
