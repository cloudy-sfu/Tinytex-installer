# Ref: https://github.com/rstudio/tinytex
# Script to uninstall TinyTeX from Windows

$ErrorActionPreference = "Stop"

# Locate the installation directory
$InstallDir = Join-Path ([Environment]::GetFolderPath("ApplicationData")) "TinyTeX"
$TlmgrPath = Join-Path $InstallDir "bin\windows\tlmgr.bat"

if (-Not (Test-Path $InstallDir)) {
    Write-Warning "TinyTeX does not seem to be installed at $InstallDir."
    exit
}

Write-Host "Removing TinyTeX from system PATH..."
if (Test-Path $TlmgrPath) {
    # Remove executables from PATH via TeX Live Manager
    & $TlmgrPath path remove
} else {
    Write-Warning "tlmgr.bat not found. Skipping PATH variable cleanup (you may need to check environment variables manually)."
}

Write-Host "Deleting directory $InstallDir..."
# Forcibly recursively delete the TinyTeX folder structure
Remove-Item -Path $InstallDir -Recurse -Force

Write-Host "TinyTeX uninstalled successfully."