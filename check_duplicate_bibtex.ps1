# Ref: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/group-object
# Ref: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content

[CmdletBinding()]
param (
    [string]$BibPath = "references.bib"
)

if (-not (Test-Path -LiteralPath $BibPath)) {
    Write-Error "File not found: $BibPath"
    return
}

$refPattern = '^@\w+\s*\{\s*([^,]+),'
$lines = Get-Content -LiteralPath $BibPath

$refs = [System.Collections.Generic.List[PSCustomObject]]::new()

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match $refPattern) {
        # Extract citation key and remove internal/surrounding whitespace
        $refName = $Matches[1] -replace '\s+', ''
        $refs.Add([PSCustomObject]@{
            RefName    = $refName
            LineNumber = $i + 1
        })
    }
}

# Group entries by RefName and filter for duplicates (Count > 1)
# Note: -CaseSensitive is used to match R's default case-sensitive duplicated() behavior
$duplicates = $refs | Group-Object -Property RefName -CaseSensitive | Where-Object { $_.Count -gt 1 }

foreach ($group in $duplicates) {
    $lineList = ($group.Group.LineNumber) -join ', '
    Write-Host "Reference '$($group.Name)' at lines: $lineList"
}

Write-Host "Done."
