# Build Bundle Script for KDB-X
# Creates platform-specific offline installation bundles

param(
    [string]$platform = "",
    [string]$versions = ""
)

$ErrorActionPreference = "Stop"

$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$BLUE = [System.ConsoleColor]::Blue

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$VERSIONS_CSV = if ($versions) { $versions } else { Join-Path $SCRIPT_DIR "versions.csv" }
$PLATFORM = $platform
$PREFIX = ""
$EXT = "sh"
$TEMP_DIR = ""

function print_header {
    param([string]$message)
    Write-Host "`n-------- $message --------`n"
}

function print_success {
    param([string]$message)
    Write-Host "Success: " -ForegroundColor $GREEN -NoNewline
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

function Show-Usage {
    Write-Host @"
Usage: .\bundle.ps1 -platform <platform> [-versions <csv_file>]

Arguments:
  -platform     Target platform (required)
                Valid platforms: l64 (Linux), l64arm (Linux ARM), m64 (macOS)
  -versions     Path to versions CSV file (optional)
                Default: $SCRIPT_DIR\versions.csv

Example:
  .\bundle.ps1 -platform l64
  .\bundle.ps1 -platform m64 -versions custom_versions.csv
"@
}

function Test-Args {
    if (-not $PLATFORM) {
        print_error "Platform is required"
        Show-Usage
        exit 1
    }

    switch ($PLATFORM) {
        { $_ -in "l64", "l64arm", "m64" } {
            $script:PREFIX = $PLATFORM
        }
        # "w64" {
        #     $script:PREFIX = "w64"
        #     $script:EXT = "ps1"
        # }
        default {
            print_error "Invalid platform: $PLATFORM"
            print_error "Valid platforms: l64, l64arm, m64"
            exit 1
        }
    }

    if (-not (Test-Path $VERSIONS_CSV)) {
        print_error "Versions CSV file not found: $VERSIONS_CSV"
        exit 1
    }
}

function Get-File {
    param(
        [string]$url,
        [string]$outputFile
    )

    print_info "Downloading: $(Split-Path -Leaf $outputFile)"
    print_info "From: $url"

    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $url -OutFile $outputFile -UseBasicParsing
        return $true
    } catch {
        return $false
    }
}

function Read-VersionsCsv {
    param([string]$csvFile)

    print_header "Reading versions from CSV"
    print_info "CSV file: $csvFile"

    $csv = Import-Csv -Path $csvFile
    foreach ($row in $csv) {
        print_info "  - $($row.component): $($row.version)"
    }
}

function Get-Component {
    param(
        [string]$component,
        [string]$version,
        [string]$urlTemplate,
        [string]$outputFile
    )

    $url = $urlTemplate -replace "PREFIX", $PREFIX
    $url = $url -replace "EXT", $EXT

    if ($version -eq "latest") {
        $url = $url -replace "VERSION", "~latest~"
    } else {
        $url = $url -replace "VERSION", $version
    }

    if (Get-File $url $outputFile) {
        print_success "Downloaded $component successfully"
        return $true
    } else {
        print_warning "Failed to download $component"
        return $false
    }
}

function Remove-TempDirectory {
    [Console]::ResetColor()
    if ($script:TEMP_DIR -and (Test-Path $script:TEMP_DIR)) {
        Remove-Item -Path $script:TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Build-Bundle {
    print_header "Building bundle for platform: $PLATFORM"

    $tempDirObj = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "build_bundle_$(Get-Random)")
    $script:TEMP_DIR = $tempDirObj.FullName

    print_info "Temporary directory: $TEMP_DIR"

    try {
        print_header "Downloading components"

        $failedComponents = @()

        $csv = Import-Csv -Path $VERSIONS_CSV
        foreach ($row in $csv) {
            $component = $row.component.Trim()
            $version = $row.version.Trim()
            $urlTemplate = $row.url_template.Trim()

            if (-not $component) {
                continue
            }

            $filename = Split-Path -Leaf $urlTemplate
            $filename = $filename -replace "PREFIX", $PREFIX
            $filename = $filename -replace "EXT", $EXT

            print_header "Downloading $component"
            if (-not (Get-Component $component $version $urlTemplate (Join-Path $TEMP_DIR $filename))) {
                $failedComponents += $component
            }
        }

        if ($failedComponents.Count -gt 0) {
            print_warning "Some components failed to download:"
            foreach ($comp in $failedComponents) {
                print_warning "  - $comp"
            }
            Write-Host ""
            $response = Read-Host "Continue creating bundle with available components? (y/n)"
            if ($response -notmatch "^[Yy]$") {
                print_info "Bundle creation cancelled"
                Remove-TempDirectory
                exit 1
            }
        }

        print_header "Creating bundle archive"

        $bundleName = "$PREFIX-bundle.zip"
        $bundlePath = Join-Path (Get-Location) $bundleName

        print_info "Compressing files..."

        if (Test-Path $bundlePath) {
            Remove-Item $bundlePath -Force
        }

        Compress-Archive -Path "$TEMP_DIR\*" -DestinationPath $bundlePath -CompressionLevel Optimal

        $bundleSize = "{0:N2} MB" -f ((Get-Item $bundlePath).Length / 1MB)

        print_success "Bundle created successfully!"
        print_info ""
        print_info "Bundle details:"
        print_info "  Platform: $PLATFORM"
        print_info "  File: $bundlePath"
        print_info "  Size: $bundleSize"
        print_info ""
        print_info "Contents:"

        # List archive contents
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($bundlePath)
        foreach ($entry in $zip.Entries) {
            $size = "{0,10}" -f $entry.Length
            print_info "  $size  $($entry.FullName)"
        }
        $zip.Dispose()
    }
    finally {
        Remove-TempDirectory
    }
}

function Main {
    Test-Args

    Read-VersionsCsv $VERSIONS_CSV
    Build-Bundle

    print_header "Bundle build complete"
    print_success "Ready for offline installation!"
}

if ($platform -eq "") {
    Show-Usage
    exit 1
}

Main
