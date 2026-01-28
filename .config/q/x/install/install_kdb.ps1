<#
.SYNOPSIS
    KDB-X Installation Script for Windows PowerShell

.DESCRIPTION
    KDB-X Installation Script for Windows PowerShell

.PARAMETER offline
    Run the script in offline mode (switch).

.PARAMETER b64lic
    Base64-encoded license string.

.PARAMETER y
    Non-interactive mode - accepts all defaults (switch).

.EXAMPLE
    .\install_kdb.ps1 -offline -b64lic "dGVzdA=="

.EXAMPLE
    .\install_kdb.ps1 -y -b64lic "dGVzdA=="
    .\install_kdb.ps1 -NonInteractive -b64lic "dGVzdA=="
#>

[CmdletBinding()]

param(
    [Parameter(Position=-1)]
    [switch]$offline,

    [Parameter(Position=-1)]
    [string]$b64lic,

    [Parameter(Position=-1)]
    [Alias("y")]
    [switch]$NonInteractive
)

$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$BLUE = [System.ConsoleColor]::Blue

$DTM = Get-Date -Format "yyyyMMdd_HHmmss"
$INSTALL_DIR = Join-Path $env:USERPROFILE ".kx"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$TEMP_DIR = ""

$ROLLBACK_REQUIRED = $false
$ARCHIVE_REQUIRED = $false
$INSTALL_DIR_CREATED = $false
$ARCHIVE_FILE = ""
$CONFIG_FILE_MODIFIED = ""
$QTEL_ENABLED = ""

$ACCEPT_DEFAULTS = $NonInteractive

$ErrorActionPreference = "Stop"

function check_args {
    if ($offline) {
        print_info "You have chosen an offline installation."
    }
    if ($b64lic) {
        print_info "You have passed a base64 encoded license."
    }

    if ($ACCEPT_DEFAULTS -and -not $b64lic) {
        print_error "License is required when using -y (non-interactive mode)"
        print_info "Usage: .\install_kdb.ps1 -y -b64lic BASE64_LIC"
        exit 1
    }
}

function print_header {
    param([string]$message)
    Write-Host "`n-------- $message --------`n"
}

function print_success {
    param([string]$message)
    Write-Host "Success: " -ForegroundColor $GREEN -NoNewline
    Write-Host $message -ForegroundColor $GREEN
}

function print_blue {
    param([string]$message)
    Write-Host $message -ForegroundColor $BLUE
}

function print_green {
    param([string]$message)
    Write-Host $message -ForegroundColor $GREEN
}

function print_warning {
    param([string]$message)
    Write-Host "Warning: " -ForegroundColor $YELLOW -NoNewline
    Write-Host $message
}

function print_error {
    param([string]$message)
    Write-Host "Error: " -ForegroundColor $RED -NoNewline
    Write-Host $message -ForegroundColor $RED
}

function print_info {
    param([string]$message)
    Write-Host $message
}

function show_menu {
    param([array]$options)

    if ($ACCEPT_DEFAULTS) {
        print_info "Auto-selecting: $($options[0])"
        return 0
    }

    while ($true) {
        Write-Host
        print_info "Options:"
        for ($i = 0; $i -lt $options.Length; $i++) {
            print_info "  $($i + 1). $($options[$i])"
        }
        Write-Host

        $choice = Read-Host "Please select an option [1-$($options.Length)]"

        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $options.Length) {
            return ([int]$choice - 1)
        }
        else {
            Write-Host
            print_error "Invalid option"
        }
    }
}

function perform_rollback {
    print_header "Installation failed - Rolling back changes"

    if ($TEMP_DIR -and (Test-Path $TEMP_DIR)) {
        print_info "  Removing temporary directory: $TEMP_DIR"
        Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($INSTALL_DIR_CREATED -and (Test-Path $INSTALL_DIR)) {
        print_info "  Removing installation directory: $INSTALL_DIR"
        Remove-Item -Path $INSTALL_DIR -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($ARCHIVE_FILE -and (Test-Path $ARCHIVE_FILE)) {
        print_info "  Restoring previous installation from archive"
        try {
            Expand-Archive -Path $ARCHIVE_FILE -DestinationPath (Split-Path $INSTALL_DIR -Parent) -Force
        }
        catch {
            print_warning "Failed to restore from archive, but archive file preserved: $ARCHIVE_FILE"
        }
    }

    if ($CONFIG_FILE_MODIFIED -and (Test-Path "$CONFIG_FILE_MODIFIED.kdb_backup.$DTM")) {
        print_info "  Restoring configuration file: $CONFIG_FILE_MODIFIED"
        Copy-Item -Path "$CONFIG_FILE_MODIFIED.kdb_backup.$DTM" -Destination $CONFIG_FILE_MODIFIED -Force -ErrorAction SilentlyContinue
    }

    print_success "Rollback completed - System returned to previous state"
    exit 1
}

function setup_error_trap {
    trap {
        handle_error $_
        break
    }
}

function handle_error {
    param([object]$ErrorRecord)

    if ($ROLLBACK_REQUIRED) {
        print_error "Error detected during installation: $($ErrorRecord.Exception.Message)"
        perform_rollback
    }
}

function cleanup {
    if ($LASTEXITCODE -eq 0) {
        if ($TEMP_DIR -and (Test-Path $TEMP_DIR)) {
            Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
        }
        if ($CONFIG_FILE_MODIFIED -and (Test-Path "$CONFIG_FILE_MODIFIED.kdb_backup.$DTM")) {
            Remove-Item -Path "$CONFIG_FILE_MODIFIED.kdb_backup.$DTM" -Force -ErrorAction SilentlyContinue
        }
    }
}

function check_prerequisites {
    $MISSING_PREREQS = @()

    if (-not $offline) {
        try {
            Invoke-WebRequest -Uri "http://www.google.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop | Out-Null
        }
        catch {
            $MISSING_PREREQS += "Internet connection"
        }
    }

    # Check PS5+ for Expand-Archive
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        $MISSING_PREREQS += "PowerShell 5.0 or later"
    }

    if ($MISSING_PREREQS.Length -gt 0) {
        print_error "Missing prerequisites: $($MISSING_PREREQS -join ', ')"
        print_info "Please install the required components and try again"
        exit 1
    }
}

function check_if_kdb_q {
    param([string]$qPath)

    try {
        "'`err" | & $qPath 2>&1 | Select-Object -First 1
        return $false
    }
    catch {
        return $_.Exception.Message -match "^'[0-9]{4}\.[0-9]{2}\.[0-9]{2}T"
    }
}

function existing_q_on_system_PATH {
    $systemPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $dirs = $systemPath -split ';'

    $qSystem = $null
    foreach ($d in $dirs) {
        if ([string]::IsNullOrWhiteSpace($d)) { continue }
        $candidate = Join-Path $d "q.exe"
        if (Test-Path $candidate) {
            $qSystem = $candidate
            break
        }
    }

    if ($qSystem) {
        return $true
    } else {
        return $false
    }
}

function check_existing_installation {
    $script:EXISTING_ISSUES = @()

    $QCMD = Get-Command "q" -ErrorAction SilentlyContinue
    if ($QCMD) {
        if (check_if_kdb_q $QCMD.Source) {
            $script:EXISTING_ISSUES += "Existing q command found: `"$($QCMD.Source)`""
        }
        else {
            print_info "Found 'q' command at $($QCMD.Source) but it's not KX"
        }
    }

    foreach ($var in @("QHOME", "QLIC", "QINIT")) {
        $userValue = [Environment]::GetEnvironmentVariable($var, "User")
        $processValue = [Environment]::GetEnvironmentVariable($var, "Process")

        if ($userValue) {
            $script:EXISTING_ISSUES += "Existing `$$var environment variable found: `"$userValue`""
            print_warning "Unsetting existing $var variable for this installation"
            [Environment]::SetEnvironmentVariable($var, $null, "Process")
        }
        if ($processValue) {
            [Environment]::SetEnvironmentVariable($var, $null, "Process")
        }
    }
}

function set_install_dir {
    print_header "Setting install location"
    $choice = show_menu @("Use default location ($INSTALL_DIR)", "Provide custom location")

    switch ($choice) {
        0 { check_install_dir }
        1 { set_custom_install_location }
    }
}

function check_install_dir {
    if ($INSTALL_DIR) {
        print_info "Checking installation location: $INSTALL_DIR"
    }

    if (-not $INSTALL_DIR) {
        print_warning "No installation location provided"
        if ($ACCEPT_DEFAULTS) {
            print_error "Cannot proceed in non-interactive mode: no installation location provided"
            exit 1
        }
        $choice = show_menu @("Provide an installation location", "Abort installation")
        switch ($choice) {
            0 { set_custom_install_location }
            1 {
                print_info "Installation aborted by user"
                exit 0
            }
        }
    }
    elseif ((Test-Path $INSTALL_DIR) -and -not (Get-Item $INSTALL_DIR).PSIsContainer) {
        print_warning "File found at installation target: $INSTALL_DIR"
        if ($ACCEPT_DEFAULTS) {
            print_error "Cannot proceed in non-interactive mode: file exists at installation location"
            print_info "Please remove the file and try again: $INSTALL_DIR"
            exit 1
        }
        $choice = show_menu @("Install to a different location", "Abort installation (you can move/delete file and try again)")
        switch ($choice) {
            0 { set_custom_install_location }
            1 {
                print_info "Installation aborted by user"
                exit 0
            }
        }
    }
    elseif ((Test-Path $INSTALL_DIR) -and (Get-ChildItem $INSTALL_DIR -ErrorAction SilentlyContinue).Count -gt 0) {
        print_warning "Target installation directory exists and is not empty: $INSTALL_DIR"
        if ($ACCEPT_DEFAULTS) {
            print_info "Auto-archiving existing directory and continuing with installation"
            $script:ARCHIVE_REQUIRED = $true
        }
        else {
            $choice = show_menu @("Archive existing directory and continue with installation", "Install to a different location", "Abort installation")
            switch ($choice) {
                0 {
                    print_info "Will install to: $INSTALL_DIR (existing directory will be archived)"
                    $script:ARCHIVE_REQUIRED = $true
                }
                1 { set_custom_install_location }
                2 {
                    print_info "Installation aborted by user"
                    exit 0
                }
            }
        }
    }
    elseif (-not (Test-Path $INSTALL_DIR)) {
        $parentDir = Split-Path $INSTALL_DIR -Parent
        if ((Test-Path $parentDir)) {
            try {
                $testFile = Join-Path $parentDir "test_write_$DTM.tmp"
                New-Item -Path $testFile -ItemType File -Force | Out-Null
                Remove-Item -Path $testFile -Force
                print_green "Will install to: $INSTALL_DIR"
            }
            catch {
                print_warning "Cannot create directory: $INSTALL_DIR"
                if ($ACCEPT_DEFAULTS) {
                    print_error "Cannot proceed in non-interactive mode: insufficient permissions to create directory"
                    print_info "Please check permissions for: $parentDir"
                    exit 1
                }
                $choice = show_menu @("Install to a different location", "Abort installation (you can check/change permissions and try again)")
                switch ($choice) {
                    0 { set_custom_install_location }
                    1 {
                        print_info "Installation aborted by user"
                        exit 0
                    }
                }
            }
        }
        else {
            print_warning "Cannot create directory: $INSTALL_DIR"
            if ($ACCEPT_DEFAULTS) {
                print_error "Cannot proceed in non-interactive mode: insufficient permissions to create directory"
                print_info "Please check permissions for: $parentDir"
                exit 1
            }
            $choice = show_menu @("Install to a different location", "Abort installation (you can check/change permissions and try again)")
            switch ($choice) {
                0 { set_custom_install_location }
                1 {
                    print_info "Installation aborted by user"
                    exit 0
                }
            }
        }
    }
    else {
        try {
            $testFile = Join-Path $INSTALL_DIR "test_write_$DTM.tmp"
            New-Item -Path $testFile -ItemType File -Force | Out-Null
            Remove-Item -Path $testFile -Force
            print_green "Will install to: $INSTALL_DIR"
        }
        catch {
            print_warning "Cannot write to directory: $INSTALL_DIR"
            if ($ACCEPT_DEFAULTS) {
                print_error "Cannot proceed in non-interactive mode: insufficient permissions to write to directory"
                print_info "Please check permissions for: $INSTALL_DIR"
                exit 1
            }
            $choice = show_menu @("Install to a different location", "Abort installation (you can check/change permissions and try again)")
            switch ($choice) {
                0 { set_custom_install_location }
                1 {
                    print_info "Installation aborted by user"
                    exit 0
                }
            }
        }
    }
}

function archive_existing_installation {
    if (-not (Test-Path $INSTALL_DIR)) {
        print_info "No directory to archive at $INSTALL_DIR"
        return
    }

    $script:ARCHIVE_FILE = Join-Path $env:USERPROFILE "kdb_backup.$DTM.zip"
    print_info "Archiving existing installation to $ARCHIVE_FILE"

    try {
        Compress-Archive -Path $INSTALL_DIR -DestinationPath $ARCHIVE_FILE -Force
        print_green "Existing installation archived to $ARCHIVE_FILE"

        Remove-Item -Path $INSTALL_DIR -Recurse -Force
        print_green "Old installation directory removed"
    }
    catch {
        print_error "Failed to create archive - you may want to manually backup your existing installation"
        $script:ARCHIVE_FILE = ""
        throw
    }
}

function set_custom_install_location {
    $newLocation = Read-Host "Please specify a new installation directory"

    if ($newLocation) {
        $newLocation = $ExecutionContext.InvokeCommand.ExpandString($newLocation)
        if (-not [System.IO.Path]::IsPathRooted($newLocation)) {
            $newLocation = Join-Path (Get-Location) $newLocation
        }
        $script:INSTALL_DIR = $newLocation
    }
    check_install_dir
}

function check_platform {
    print_header "Detecting platform"

    $OS = "Windows"
    $ARCH = $env:PROCESSOR_ARCHITECTURE

    switch ($ARCH) {
        "AMD64" { $ARCH = "x86_64" }
        "ARM64" { $ARCH = "arm64" }
        "x86" { $ARCH = "i386" }
    }

    if ($ARCH -eq "x86_64") {
        $script:PREFIX = "w64"
    }
    else {
        print_error "Unsupported OS+Architecture combination: $OS+$ARCH"
        exit 1
    }

    print_info "Detected system: $OS ($ARCH)"
    print_info "Using platform prefix: $PREFIX"
}

function get_offline_component {
    param([string]$componentName)

    if ($componentName -eq "ai") {
        print_header "AI module - Offline installation"
        $expectedFilename = "$PREFIX-ai.zip"
    }
    elseif ($componentName -eq "kurl") {
        print_header "kurl module - Offline installation"
        $expectedFilename = "$PREFIX-kurl.zip"
    }
    elseif ($componentName -eq "objstor") {
        print_header "objstor module - Offline installation"
        $expectedFilename = "$PREFIX-objstor.zip"
    }
    elseif ($componentName -eq "pq") {
        print_header "Parquet module - Offline installation"
        $expectedFilename = "pq.zip"
    }
    elseif ($componentName -eq "rest") {
        print_header "REST server module - Offline installation"
        $expectedFilename = "rest.q_"
    }
    elseif ($componentName -eq "dashboards") {
        print_header "Dashboards - Offline installation"
        $expectedFilename = "KXDashboards.zip"
    }
    else {
        print_header "KDB-X - Offline installation"
        $expectedFilename = "$PREFIX.zip"
    }

    $scriptFilename = if ($SCRIPT_DIR) { Join-Path $SCRIPT_DIR $expectedFilename } else { $expectedFilename }
    $script:COMPONENT_PATH = ""
    $attempt = $null

    while ($true) {
        if (-not $attempt) {
            $attempt = 1
        }
        else {
            if ($ACCEPT_DEFAULTS) {
                if ($componentName -eq "ai" -or $componentName -eq "kurl" -or $componentName -eq "objstor" -or $componentName -eq "pq" -or $componentName -eq "rest" -or $componentName -eq "dashboards") {
                    print_warning "File not found, skipping optional component: $expectedFilename"
                    $script:ZIP_PATH = ""
                    break
                }
                else {
                    print_error "Cannot proceed in non-interactive mode: required file not found: $expectedFilename"
                    print_info "Please ensure the file is in: $SCRIPT_DIR"
                    exit 1
                }
            }
            if ($componentName -eq "ai" -or $componentName -eq "kurl" -or $componentName -eq "objstor" -or $componentName -eq "pq" -or $componentName -eq "rest" -or $componentName -eq "dashboards") {
                $choice = show_menu @("Try again", "Skip")
                if ($choice -eq 1) {
                    $script:ZIP_PATH = ""
                    break
                }
            }
            else {
                $choice = show_menu @("Try again", "Abort installation")
                if ($choice -eq 1) {
                    $script:ZIP_PATH = ""
                    break
                }
            }
        }

        if ($SCRIPT_DIR -and (Test-Path $scriptFilename)) {
            print_green "File detected: $scriptFilename"
            $script:ZIP_PATH = $scriptFilename
            break
        }
        else {
            $actualPath = Read-Host "Enter path to $expectedFilename"
        }

        $actualPath = $actualPath.Trim()
        if ($actualPath) {
            $actualPath = $ExecutionContext.InvokeCommand.ExpandString($actualPath)
        }

        if (-not $actualPath) {
            print_error "No path provided"
            continue
        }

        if (Test-Path $actualPath -PathType Container) {
            $targetDir = $actualPath
            $zipPath = Join-Path $targetDir $expectedFilename

            if (-not (Test-Path $zipPath)) {
                print_error "File $expectedFilename not found in directory: $targetDir"
                continue
            }
            $script:ZIP_PATH = $zipPath
            break
        }
        elseif (Test-Path $actualPath -PathType Leaf) {
            $actualName = Split-Path $actualPath -Leaf

            if ($actualName -ne $expectedFilename) {
                print_error "Filename mismatch: expected $expectedFilename, got $actualName"
                continue
            }
            $script:ZIP_PATH = $actualPath
            break
        }
        else {
            print_error "Invalid path: $actualPath"
            print_info "Path does not exist or is not accessible"
            continue
        }
    }

    if ($COMPONENT_PATH) {
        print_green "Using file: $COMPONENT_PATH"
        # xattr equivalent
        try {
            Unblock-File -Path $COMPONENT_PATH -ErrorAction SilentlyContinue
        }
        catch {
            # Ignore errors from Unblock-File
        }
    }
}

function extract_component {
    param(
        [string]$zipFile,
        [string]$targetDir,
        [string]$componentName
    )

    $tempExtract = Join-Path $TEMP_DIR "$componentName_extract"
    try {
        Expand-Archive -Path $zipFile -DestinationPath $tempExtract -Force
    }
    catch {
        print_warning "Failed to extract $componentName. Continuing without $componentName"
        return $false
    }

    $sourceDir = $tempExtract
    $extractedItems = Get-ChildItem -Path $tempExtract

    if ($extractedItems.Count -eq 1 -and $extractedItems[0].PSIsContainer) {
        $sourceDir = $extractedItems[0].FullName
    }

    try {
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        Copy-Item -Path "$sourceDir\*" -Destination $targetDir -Recurse -Force
    }
    catch {
        print_warning "Failed to install $componentName. Continuing without $componentName"
        Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
        return $false
    }

    Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    return $true
}

function download_kdb {
    if ($offline) {
        get_offline_component "kdb"
        if (-not $COMPONENT_PATH) {
            print_info "Installation aborted by user"
            exit 1
        }

        $script:TEMP_DIR = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
        New-Item -ItemType Directory -Path $script:TEMP_DIR -Force | Out-Null

        $FILENAME = "$PREFIX.zip"
        Copy-Item -Path $COMPONENT_PATH -Destination (Join-Path $TEMP_DIR $FILENAME) -Force

        print_success "Using offline KDB-X file successfully!"
    }
    else {
        print_header "Downloading KDB-X"
        print_info "Fetching the latest stable version"

        $script:TEMP_DIR = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
        New-Item -ItemType Directory -Path $script:TEMP_DIR -Force | Out-Null

        $FILENAME = "$PREFIX.zip"
        $FILEURL = "https://portal.dl.kx.com/assets/raw/kdb-x/kdb-x/~latest~/$FILENAME"

        print_info "From: $FILEURL"

        try {
            $filePath = Join-Path $TEMP_DIR $FILENAME
            Invoke-WebRequest -Uri $FILEURL -OutFile $filePath -UseBasicParsing
            print_success "Downloaded successfully!"
        }
        catch {
            print_error "Download failed. Please check your internet connection or permissions"
            throw
        }
    }
}

function install_kdb {
    print_header "Installing KDB-X"

    $installPath = Join-Path $TEMP_DIR "install"
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $installPath "bin") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $installPath "q") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $installPath "lib") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $installPath "mod") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $installPath "mod\kx") -Force | Out-Null

    print_info "Installing to temporary location: $installPath"

    print_info "Extracting files"
    $extractPath = Join-Path $TEMP_DIR "extracted"
    try {
        Expand-Archive -Path (Join-Path $TEMP_DIR "$PREFIX.zip") -DestinationPath $extractPath -Force
    }
    catch {
        print_error "Failed to extract ZIP file. Please check if the file is valid"
        throw
    }

    $Q_BINARY = Get-ChildItem -Path $extractPath -Name "q.exe" -Recurse -File | Select-Object -First 1

    if (-not $Q_BINARY) {
        print_error "Could not find q.exe binary in the extracted files"
        exit 1
    }

    $sourcePath = Join-Path $extractPath $Q_BINARY
    $destPath = Join-Path $installPath "bin\q.exe"
    Copy-Item -Path $sourcePath -Destination $destPath -Force

    # Copy .q files
    Get-ChildItem -Path $extractPath -Filter "*.q" -Recurse -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $installPath "q") -Force -ErrorAction SilentlyContinue
    }

    print_success "Installed successfully!"
}

function test_license {
    [Environment]::SetEnvironmentVariable("QHOME", $null, "Process")
    [Environment]::SetEnvironmentVariable("QLIC", $null, "Process")

    try {
        $qPath = Join-Path $TEMP_DIR "install\bin\q.exe"
        # Use PowerShell equivalent of: echo "exit 0" | q -q
        $exitCode = ("exit 0" | & $qPath -q) 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function setup_license {
    print_header "License setup"
    print_info "A license file is required to run KDB-X"
    $LIC_ATTEMPT = $null

    while ($true) {
        if (-not $LIC_ATTEMPT) {
            $LIC_ATTEMPT = 1
        }
        else {
            if ($ACCEPT_DEFAULTS) {
                print_error "Cannot proceed in non-interactive mode: license validation failed"
                print_info "Please check your license and try again"
                exit 1
            }
            $choice = show_menu @("Try again", "Abort installation")
            if ($choice -eq 1) {
                print_info "Installation aborted by user"
                exit 0
            }
        }

        if ($b64lic) {
            print_green "Using -b64lic option:"
            print_info $b64lic
            $LICENSE_CONTENT = $b64lic
            $script:b64lic = ""
        }
        else {
            print_blue "Paste your base64 encoded license and press Enter:"
            $LICENSE_CONTENT = Read-Host
        }

        if ($LICENSE_CONTENT) {
            try {
                $LICENSE_CONTENT = $LICENSE_CONTENT.Trim() -replace "`r`n", "" -replace "`n", "" -replace "`r", ""

                if (-not ($LICENSE_CONTENT -match "^[A-Za-z0-9+/]*={0,2}$")) {
                    throw "Invalid base64 format"
                }

                $licenseBytes = [System.Convert]::FromBase64String($LICENSE_CONTENT)
                $licenseFile = Join-Path $TEMP_DIR "install\kc.lic"
                [System.IO.File]::WriteAllBytes($licenseFile, $licenseBytes)

                if (test_license) {
                    print_success "License file valid and working"
                    break
                }
                else {
                    print_error "License validation failed"
                    Remove-Item -Path $licenseFile -Force -ErrorAction SilentlyContinue
                    continue
                }
            }
            catch {
                print_error "Failed to decode license"
                continue
            }
        }
        else {
            print_error "No license content provided"
            continue
        }
    }
}

function Update-ConfigKey {
    param(
        [string]$ConfigFile,
        [string]$Key,
        [string]$Value,
        [string]$Description = $Key # Optional description
    )

    if (-not $Key -or -not $Value) {
        print_error "Update-ConfigKey: key and value are required"
        return $false
    }

    if (-not (Test-Path $ConfigFile)) {
        print_error "Config file does not exist: $ConfigFile"
        return $false
    }

    $content = Get-Content $ConfigFile -ErrorAction SilentlyContinue
    $keyPattern = "^${Key}="
    $keyLine = $content | Where-Object { $_ -match $keyPattern }

    if ($keyLine) {
        $newContent = $content | ForEach-Object {
            if ($_ -match $keyPattern) {
                "${Key}=${Value}"
            } else {
                $_
            }
        }
        $newContent | Set-Content $ConfigFile
        print_info "Updated $Description setting in config file"
    } else {
        Add-Content -Path $ConfigFile -Value "${Key}=${Value}"
        print_info "Added $Description setting to config file"
    }

    return $true
}

function Setup-KdbConfigFile {
    $configDir = $INSTALL_DIR
    $configFile = Join-Path $configDir "config"

    if (-not (Test-Path $configDir)) {
        try {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        } catch {
            print_error "Failed to create config directory: $configDir"
            return $false
        }
    }

    if (-not (Test-Path $configFile)) {
        try {
            New-Item -ItemType File -Path $configFile -Force | Out-Null
            print_info "Created config file: $configFile"
        } catch {
            print_error "Failed to create config file: $configFile"
            return $false
        }
    } else {
        print_info "Config file already exists: $configFile"
        $backupFile = "${configFile}.kdb_backup.${DTM}"
        try {
            Copy-Item $configFile $backupFile
            print_info "Created backup: $backupFile"
            $script:CONFIG_FILE_MODIFIED = $configFile
        } catch {
            print_warning "Failed to create backup of config file"
        }
    }

    # Add/Update KX_UPLOAD_TELEMETRY
    if ($QTEL_ENABLED) {
        Update-ConfigKey -ConfigFile $configFile -Key "KX_UPLOAD_TELEMETRY" -Value $QTEL_ENABLED -Description "telemetry"
        print_success "Telemetry setting saved to: $configFile"
    }

    return $true
}

function setup_telemetry {
    print_header "Telemetry Configuration"

    if ($ACCEPT_DEFAULTS) {
        $script:QTEL_ENABLED = "NO"
        print_info "Non-interactive mode: Telemetry disabled by default"
        return
    }

    Write-Host ("You will be given the option to opt-in or out of usage telemetry when you install " +
                 "the Software. If you opt-in, we will collect telemetry data relating to the " +
                 "operation and usage of the Software, including performance metrics, configuration " +
                 "and settings, and diagnostics relating to any issues encountered. This may include " +
                 "personal data (as defined under applicable data protection laws). You acknowledge " +
                 "and agree that we may use such data to operate, support, improve, and optimize the " +
                 "Software and related services, and to ensure compliance with the License Agreement. " +
                 "You may turn off telemetry at any point by following the instructions in our " +
                 "Software documentation: https://code.kx.com/kdbx/releases/telemetry.html " +
                 "For more information on how we handle personal data, please refer to our Privacy " +
                 "Policy: https://kx.com/privacy-policy/")

    Write-Host
    print_info "Would you like to enable usage telemetry?"

    $TELEMETRY_CHOICE = Read-Host "Enable telemetry? (Y/N)"

    switch -Regex ($TELEMETRY_CHOICE) {
        "^[Yy]$|^[Yy][Ee][Ss]$" {
            $script:QTEL_ENABLED = "YES"
            print_success "Telemetry enabled - Thank you for helping us improve KDB-X!"
        }
        default {
            $script:QTEL_ENABLED = "NO"
            print_info "Telemetry disabled"
        }
    }
}

function Install-ModuleGeneric {
    param(
        [string]$ComponentId,      # "ai", "kurl", "rest", "dashboards"
        [string]$DisplayName,      # "AI module", "REST server module", "KX Dashboards"
        [string]$UrlPath,          # "modules/ai", "modules/rest-server", "dash"
        [string]$Filename,         # "$PREFIX-ai.zip", "rest.q_", "KXDashboards.zip"
        [string]$InstallType,      # "extract" or "copy"
        [string]$TargetPath        # "$TEMP_DIR\install\mod\kx\ai"
    )

    if ($offline) {
        get_offline_component $ComponentId
        if (-not $COMPONENT_PATH) {
            print_warning "Continuing without $DisplayName"
            return
        }

        if ($InstallType -eq "extract") {
            print_info "Extracting $DisplayName"
            if (extract_component $COMPONENT_PATH $TargetPath $ComponentId) {
                print_success "Installed successfully!"
            }
            else {
                return
            }
        }
        else {
            try {
                Copy-Item -Path $COMPONENT_PATH -Destination $TargetPath -Force
                print_success "Installed successfully!"
            }
            catch {
                print_warning "Failed to copy $DisplayName. Continuing without $DisplayName"
            }
        }
    }
    else {
        $fileurl = "https://portal.dl.kx.com/assets/raw/kdb-x/$UrlPath/~latest~/$Filename"
        print_header "Downloading $DisplayName"
        print_info "Fetching the latest stable version"
        print_info "From: $fileurl"

        if ($InstallType -eq "extract") {
            try {
                $tempFile = Join-Path $TEMP_DIR "${ComponentId}_${Filename}"
                Invoke-WebRequest -Uri $fileurl -OutFile $tempFile -UseBasicParsing

                print_header "Installing $DisplayName"
                print_info "Extracting files"
                if (extract_component $tempFile $TargetPath $ComponentId) {
                    print_success "Installed successfully!"
                }
                else {
                    return
                }
            }
            catch {
                print_warning "Failed to download $DisplayName. Continuing without $DisplayName"
                return
            }
        }
        else {
            try {
                Invoke-WebRequest -Uri $fileurl -OutFile $TargetPath -UseBasicParsing
                print_success "Installed successfully!"
            }
            catch {
                print_warning "Failed to download $DisplayName. Continuing without $DisplayName"
            }
        }
    }
}

function install_ai_module {
    $targetPath = Join-Path $TEMP_DIR "install\mod\kx\ai"
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Install-ModuleGeneric -ComponentId "ai" -DisplayName "AI module" -UrlPath "modules/ai" -Filename "$PREFIX-ai.zip" -InstallType "extract" -TargetPath $targetPath
}

function install_kurl_module {
    $targetPath = Join-Path $TEMP_DIR "install\mod\kx\kurl"
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Install-ModuleGeneric -ComponentId "kurl" -DisplayName "kurl module" -UrlPath "modules/kurl" -Filename "$PREFIX-kurl.zip" -InstallType "extract" -TargetPath $targetPath
}

function install_objstor_module {
    $targetPath = Join-Path $TEMP_DIR "install\mod\kx\objstor"
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Install-ModuleGeneric -ComponentId "objstor" -DisplayName "objstor module" -UrlPath "modules/objstor" -Filename "$PREFIX-objstor.zip" -InstallType "extract" -TargetPath $targetPath
}

function install_pq_module {
    $targetPath = Join-Path $TEMP_DIR "install\mod\kx\pq"
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    Install-ModuleGeneric -ComponentId "pq" -DisplayName "parquet module" -UrlPath "modules/pq" -Filename "pq.zip" -InstallType "extract" -TargetPath $targetPath
}

function install_pq_module {
    $pqModulePath = Join-Path $TEMP_DIR "install\mod\kx\pq"
    New-Item -ItemType Directory -Path $pqModulePath -Force | Out-Null

    if ($offline) {
        get_offline_component "pq"
        if (-not $COMPONENT_PATH) {
            print_warning "Continuing without parquet module"
            return
        }

        print_info "Extracting parquet module"
        if (extract_component $COMPONENT_PATH $pqModulePath "pq") {
            print_success "Installed successfully!"
        }
        else {
            return
        }
    }
    else {
        $PQ_FILENAME = "pq.zip"
        $PQ_FILEURL = "https://dev.downloads.kx.com/assets/raw/kdb-x/modules/pq/~latest~/pq.zip"

        print_header "Downloading parquet module"
        print_info "Fetching the latest stable version"
        print_info "From: $PQ_FILEURL"

        try {
            $pqZipPath = Join-Path $TEMP_DIR "pq_$PQ_FILENAME"
            Invoke-WebRequest -Uri $PQ_FILEURL -OutFile $pqZipPath -UseBasicParsing

            print_header "Installing parquet module"
            print_info "Extracting files"
            if (extract_component $pqZipPath $pqModulePath "pq") {
                print_success "Installed successfully!"
            }
            else {
                return
            }
        }
        catch {
            print_warning "Failed to download parquet module. Continuing without parquet module"
        }
    }
}

function install_rest_module {
    $targetPath = Join-Path $TEMP_DIR "install\mod\kx\rest.q_"
    Install-ModuleGeneric -ComponentId "rest" -DisplayName "REST server module" -UrlPath "modules/rest-server" -Filename "rest.q_" -InstallType "copy" -TargetPath $targetPath
}

function install_postgres_module {
    $binPath = Join-Path $TEMP_DIR "install\bin"
    Install-ModuleGeneric -ComponentId "postgres" -DisplayName "postgres module" -UrlPath "modules/postgres" -Filename "$PREFIX-postgres.zip" -InstallType "extract" -TargetPath $binPath
}

function install_dashboards {
    $dashboardsPath = Join-Path $TEMP_DIR "install\dashboards"
    New-Item -ItemType Directory -Path $dashboardsPath -Force | Out-Null
    Install-ModuleGeneric -ComponentId "dashboards" -DisplayName "KX Dashboards" -UrlPath "dash" -Filename "KXDashboards.zip" -InstallType "extract" -TargetPath $dashboardsPath
}

function setup_environment {
    print_header "Setting up environment"

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $binPath = Join-Path $INSTALL_DIR "bin"

    if (-not $userPath) {
        $userPath = ""
    }

    if ($userPath -notlike "*$binPath*") {
        if ($userPath) {
            $newPath = "$binPath;$userPath"
        }
        else {
            $newPath = $binPath
        }
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        print_info "Added $binPath to user PATH"
    }
    else {
        print_info "User PATH already contains KDB-X installation directory"
    }

    $script:ENVIRONMENT_ISSUES = @()
    if (existing_q_on_system_PATH) {
        $script:ENVIRONMENT_ISSUES += "q executable on system PATH. You need to remove this manually."

    }

    # Clean up any existing Q*
    foreach ($var in @("QHOME", "QLIC", "QINIT")) {
        $existing = [Environment]::GetEnvironmentVariable($var, "User")
        if ($existing) {
            [Environment]::SetEnvironmentVariable($var, $null, "User")
            print_info "Removed existing $var user environment variable"
        }
    }

    foreach ($var in @("QHOME", "QLIC", "QINIT")) {
        $existing = [Environment]::GetEnvironmentVariable($var, "Machine")
        if ($existing) {
            $script:ENVIRONMENT_ISSUES +="$var system environment variable. You need to remove this manually."
        }
    }

    if ($ENVIRONMENT_ISSUES.Length -gt 0) {
        print_warning "Environment configured with warnings:"
        foreach ($issue in $ENVIRONMENT_ISSUES) {
            print_info "  - $issue"
        }
    }
    else {
        print_success "Environment configured successfully!"
    }
}

function verify_installation {
    print_header "Verifying installation"

    $script:INSTALLED_LICENSE = $false
    $script:INSTALLED_AI = $false
    $script:INSTALLED_KURL = $false
    $script:INSTALLED_OBJSTOR = $false
    $script:INSTALLED_PQ = $false
    $script:INSTALLED_REST = $false
    $script:INSTALLED_DASHBOARDS = $false

    $qBinary = Join-Path $TEMP_DIR "install\bin\q.exe"
    if (-not (Test-Path $qBinary)) {
        print_error "Installation verification failed: q.exe binary missing or not executable"
        return $false
    }

    $licenseFile = Join-Path $TEMP_DIR "install\kc.lic"
    if (Test-Path $licenseFile) {
        print_info "License file found"
        if (-not (test_license)) {
            print_warning "License file exists but may not be working properly"
        }
        else {
            print_info "License file valid and working"
            $script:INSTALLED_LICENSE = $true
        }
    }
    else {
        print_warning "No license file found - you will need to add kc.lic before using KDB-X"
    }

    $aiLibsPath = Join-Path $TEMP_DIR "install\mod\kx\ai"
    if ((Test-Path $aiLibsPath) -and (Get-ChildItem $aiLibsPath -ErrorAction SilentlyContinue).Count -gt 0) {
        print_info "AI module installed"
        $script:INSTALLED_AI = $true
    }

    $kurlModulePath = Join-Path $TEMP_DIR "install\mod\kx\kurl"
    if ((Test-Path $kurlModulePath) -and (Get-ChildItem $kurlModulePath -ErrorAction SilentlyContinue).Count -gt 0) {
        print_info "kurl module installed"
        $script:INSTALLED_KURL = $true
    }

    $objstorModulePath = Join-Path $TEMP_DIR "install\mod\kx\objstor"
    if ((Test-Path $objstorModulePath) -and (Get-ChildItem $objstorModulePath -ErrorAction SilentlyContinue).Count -gt 0) {
        print_info "objstor module installed"
        $script:INSTALLED_OBJSTOR = $true
    }

    $pqModulePath = Join-Path $TEMP_DIR "install\mod\kx\pq"
    if ((Test-Path $pqModulePath) -and (Get-ChildItem $pqModulePath -ErrorAction SilentlyContinue).Count -gt 0) {
        print_info "parquet module installed"
        $script:INSTALLED_PQ = $true
    }

    $pqModulePath = Join-Path $TEMP_DIR "install\mod\kx\pq"
    if ((Test-Path $pqModulePath) -and (Get-ChildItem $pqModulePath -ErrorAction SilentlyContinue).Count -gt 0) {
        print_info "parquet module installed"
    }

    $restModuleFile = Join-Path $TEMP_DIR "install\mod\kx\rest.q_"
    if (Test-Path $restModuleFile) {
        print_info "REST server module installed"
        $script:INSTALLED_REST = $true
    }

    $dashboardsPath = Join-Path $TEMP_DIR "install\dashboards"
    if ((Test-Path $dashboardsPath) -and (Get-ChildItem $dashboardsPath -ErrorAction SilentlyContinue).Count -gt 0) {
        print_info "KX Dashboards installed"
        $script:INSTALLED_DASHBOARDS = $true
    }

    print_success "Installation verified successfully!"
    return $true
}

function finalize_installation {
    print_header "Finalizing installation"

    if ($ARCHIVE_REQUIRED) {
        archive_existing_installation
    }

    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
        $script:INSTALL_DIR_CREATED = $true
    }

    print_info "Moving installation files to final location"

    $sourcePath = Join-Path $TEMP_DIR "install\*"
    Copy-Item -Path $sourcePath -Destination $INSTALL_DIR -Recurse -Force

    print_success "Installation finalized successfully!"
}

function print_next_steps {
    print_header "Installation complete"
    print_info "KDB-X has been installed to $INSTALL_DIR with the following structure:"
    print_info "  - $INSTALL_DIR\bin\              executable files (q.exe)"
    print_info "  - $INSTALL_DIR\q\                code"
    print_info "  - $INSTALL_DIR\lib\              dynamic libraries (empty, for future use)"
    print_info "  - $INSTALL_DIR\mod\              modules directory"

    if ($INSTALLED_AI) {
        print_info "  - $INSTALL_DIR\mod\kx\ai\        AI module"
    }
    if ($INSTALLED_KURL) {
        print_info "  - $INSTALL_DIR\mod\kx\kurl\      kurl module"
    }
    if ($INSTALLED_OBJSTOR) {
        print_info "  - $INSTALL_DIR\mod\kx\objstor\   objstor module"
    }
    if ($INSTALLED_PQ) {
        print_info "  - $INSTALL_DIR\mod\kx\pq\        parquet module"
    }
    if ($INSTALLED_REST) {
        print_info "  - $INSTALL_DIR\mod\kx\rest.q_    REST server module"
    }
    if ($INSTALLED_DASHBOARDS) {
        print_info "  - $INSTALL_DIR\dashboards\       KX Dashboards"
    }
    if ($INSTALLED_LICENSE) {
        print_info "  - $INSTALL_DIR\kc.lic            license file"
    }

    print_header "Next steps"
    print_info "To start using KDB-X:"
    if ($ENVIRONMENT_ISSUES.Length -gt 0) {
        print_info ""
        print_warning "1. Address the environment configuration warnings above."
        print_info "         2. Restart your PowerShell session or open a new command prompt"
        print_info "         3. Run 'q' to start KDB-X"
    }
    else {
        print_info ""
        print_info "1. Restart your PowerShell session or open a new command prompt"
        print_info "2. Run 'q' to start KDB-X"
    }

    $NEED_TO_UNSET = @()
    foreach ($issue in $EXISTING_ISSUES) {
        if ($issue -like "*QHOME*") {
            $NEED_TO_UNSET += "QHOME"
        }
        elseif ($issue -like "*QLIC*") {
            $NEED_TO_UNSET += "QLIC"
        }
        elseif ($issue -like "*QINIT*") {
            $NEED_TO_UNSET += "QINIT"
        }
    }

    if ($NEED_TO_UNSET.Length -gt 0) {
        print_warning "Important: You had existing environment variables that need to be unset:"
        print_info "In your current terminal session, run:"
        foreach ($var in $NEED_TO_UNSET) {
            print_blue "    `$env:$var = `$null"
        }
        print_info ""
        print_info "These variables are not set in your user environment"
        print_info "However, they may still be set in your current session"
        print_info ""
    }

    if (Test-Path (Join-Path $INSTALL_DIR "kc.lic")) {
        print_info "To run your first q program (`"Hello, World!`"):"
        print_blue "    q"
        print_blue '    q)"Hello, World!"'
    }
    else {
        print_warning "Before using KDB-X, add your license file as: $INSTALL_DIR\kc.lic"
    }

    print_header "Resources"
    print_info "Documentation: https://code.kx.com/q/"
    print_info "Tutorials: https://code.kx.com/q/learn/"
    print_info "VS Code Plugin: https://marketplace.visualstudio.com/items?itemName=kx.kdb"
    print_info ""
    print_info "Stuck? Ask the Community: https://community.kx.com/"
}

function main {
    setup_error_trap
    Clear-Host
    print_header "Welcome to the KDB-X installer for Windows"
    check_args
    check_prerequisites
    check_existing_installation
    check_platform
    set_install_dir
    $script:ROLLBACK_REQUIRED = $true
    download_kdb
    install_kdb
    setup_license
    setup_telemetry
    install_ai_module
    install_kurl_module
    install_objstor_module
    install_pq_module
    install_rest_module
    install_postgres_module
    install_dashboards
    verify_installation | Out-Null
    finalize_installation
    Setup-KdbConfigFile
    setup_environment
    $script:ROLLBACK_REQUIRED = $false
    print_next_steps
}

try {
    main
}
catch {
    handle_error $_
}
finally {
    if (-not $ROLLBACK_REQUIRED) {
        cleanup
    }
}
