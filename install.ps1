# Ref: https://github.com/rstudio/tinytex
# Script to install TinyTeX on Windows

param(
    [string]$Version = "daily",
    [string]$Bundle = "TinyTeX-1"
)

$ErrorActionPreference = "Stop"

# Default TinyTeX installation directory (%APPDATA%\TinyTeX)
$AppDir = [Environment]::GetFolderPath("ApplicationData")
$InstallDir = Join-Path $AppDir "TinyTeX"
$TlmgrPath = Join-Path $InstallDir "bin\windows\tlmgr.bat"

if (Test-Path $InstallDir) {
    Write-Warning "TinyTeX directory already exists at $InstallDir. Skipping installation. To reinstall, please remove this directory first."
    exit
}

# Determine filename based on TinyTeX's release naming convention scheme
$isNewNaming = ($Version -eq 'daily') -or ($Version -gt '2026.03.02')

if ($isNewNaming) {
    # New convention uses .exe self-extracting archives for all Windows bundles
    $verSuffix = if ($Version -eq 'daily') { "" } else { "-v$Version" }
    $fileName = "$Bundle-windows$verSuffix.exe"
} else {
    # Old convention used .zip (except for TinyTeX-2)
    $verSuffix = if ($Version -eq 'daily') { "" } else { "-v$Version" }
    $fileName = "$Bundle$verSuffix.zip"
    if ($Bundle -eq 'TinyTeX-2') {
        $fileName = [System.IO.Path]::ChangeExtension($fileName, ".exe")
    }
}

$urlVersion = if ($Version -eq 'daily') { 'daily' } else { "v$Version" }
$url = "https://github.com/rstudio/tinytex-releases/releases/download/$urlVersion/$fileName"
$downloadPath = Join-Path $env:TEMP $fileName

Write-Host "Downloading $Bundle from $url..."
Invoke-WebRequest -Uri $url -OutFile $downloadPath

Write-Host "Extracting to $AppDir..."
if ($fileName -match '\.exe$') {
    # Use the call operator (&) instead of Start-Process to avoid pipeline deadlocks
    $extractArgs = @("-y", "-o$AppDir")
    & $downloadPath $extractArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Extraction failed with exit code $LASTEXITCODE."
    }
} else {
    Expand-Archive -Path $downloadPath -DestinationPath $AppDir -Force
}

Remove-Item -Path $downloadPath -Force

Write-Host "Configuring paths and TeX Live manager..."
if (Test-Path $TlmgrPath) {
    # Add executables to system PATH
    & $TlmgrPath path add
    
    # Disable LaTeX log line wrapping (prevents parsing issues in log files)
    & $TlmgrPath conf texmf max_print_line 10000 | Out-Null
    
    Write-Host "TinyTeX installed successfully to $InstallDir."
} else {
    Write-Error "tlmgr.bat not found at $TlmgrPath. Installation may have failed or the bundle structure changed."
}