param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Engine,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$TexPath,

    [Parameter(Mandatory = $false)]
    [string]$ReqPath = "requirements.txt"
)

if (-not (Test-Path $TexPath)) {
    Write-Error "TeX file not found: $TexPath"
    exit 1
}

# Derive expected .fls file path (current directory or TeX file directory)
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($TexPath)
$flsInCurrentDir = "$baseName.fls"
$flsInTexDir = [System.IO.Path]::ChangeExtension($TexPath, ".fls")

# Remove any stale .fls files from previous compilations
if (Test-Path $flsInCurrentDir) { Remove-Item $flsInCurrentDir -Force }
if (($flsInCurrentDir -ne $flsInTexDir) -and (Test-Path $flsInTexDir)) { Remove-Item $flsInTexDir -Force }

# Ref: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators#call-operator-
Write-Host "Running LaTeX engine: $Engine -recorder $TexPath"
& $Engine -recorder $TexPath

# Locate the newly generated .fls file
if (Test-Path $flsInCurrentDir) {
    $FlsPath = $flsInCurrentDir
} elseif (Test-Path $flsInTexDir) {
    $FlsPath = $flsInTexDir
} else {
    Write-Error "Failed to locate generated .fls file ($flsInCurrentDir or $flsInTexDir)."
    exit 1
}

# 1. Locate texlive.tlpdb using kpsewhich
Write-Host "Locating TeX Live database..."
$texmfRoot = (& kpsewhich -var-value=TEXMFROOT).Trim()
$tlpdbPath = Join-Path $texmfRoot "tlpkg\texlive.tlpdb"

if (-not (Test-Path $tlpdbPath)) {
    Write-Error "Could not locate texlive.tlpdb at: $tlpdbPath"
    exit 1
}

Write-Host "Parsing TeX Live database: $tlpdbPath"
$fileToPkg = @{}
$currentPkg = $null

# Use .NET streaming for high performance on large tlpdb files
$tlpdbReader = [System.IO.File]::ReadLines($tlpdbPath)
foreach ($line in $tlpdbReader) {
    $trimmed = $line.Trim()
    if ($trimmed.StartsWith("name ")) {
        $currentPkg = $trimmed.Split(" ")[1]
    }
    elseif ($trimmed.StartsWith("texmf-dist/") -and $currentPkg) {
        # Store path relative to texmf-dist/ using forward slashes
        $relPath = $trimmed.Substring("texmf-dist/".Length)
        $fileToPkg[$relPath] = $currentPkg
    }
}

# 2. Parse INPUT lines from the .fls file
Write-Host "Analyzing dependencies from: $FlsPath"
$requiredPackages = [System.Collections.Generic.HashSet[string]]::new()

$flsLines = [System.IO.File]::ReadLines($FlsPath)
foreach ($line in $flsLines) {
    if (-not $line.StartsWith("INPUT ")) { continue }

    # Extract path and normalize slashes to forward slashes
    $rawPath = $line.Substring(6).Trim().Replace("\", "/")

    $marker = "texmf-dist/"
    $idx = $rawPath.IndexOf($marker)
    if ($idx -ge 0) {
        $relPath = $rawPath.Substring($idx + $marker.Length)

        if ($fileToPkg.ContainsKey($relPath)) {
            $pkg = $fileToPkg[$relPath]
            # Skip binary / platform architecture packages
            if (-not ($pkg.EndsWith(".win32") -or $pkg.EndsWith(".windows") -or $pkg.EndsWith(".x86_64-linux"))) {
                [void]$requiredPackages.Add($pkg)
            }
        }
    }
}

# 3. Output sorted results to requirements file
$sortedPackages = $requiredPackages | Sort-Object
$sortedPackages | Set-Content -Path $ReqPath -Encoding UTF8

Write-Host "Successfully generated '$ReqPath' with $($sortedPackages.Count) packages."