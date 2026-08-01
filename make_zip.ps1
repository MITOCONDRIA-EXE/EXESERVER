param(
    [string]$CommitFrom = "HEAD~1",
    [string]$CommitTo = "HEAD",
    [string]$OutputName = "update"
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path

$dest = [Environment]::GetFolderPath("Desktop") + "\$OutputName.zip"

if (Test-Path $dest) { Remove-Item $dest -Force }

$changes = git diff --name-only $CommitFrom $CommitTo
if (-not $changes) {
    Write-Host "No hay cambios entre $CommitFrom y $CommitTo"
    exit
}

$tmp = Join-Path $env:TEMP "tcadmin_upload"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

foreach ($file in $changes) {
    $src = Join-Path $repo $file
    if (Test-Path $src) {
        $dir = Split-Path $file
        if ($dir) {
            $fullDir = Join-Path $tmp $dir
            if (-not (Test-Path $fullDir)) { New-Item -ItemType Directory -Path $fullDir -Force | Out-Null }
        }
        Copy-Item $src (Join-Path $tmp $file) -Force
        Write-Host "  + $file"
    } else {
        Write-Host "  (borrado) $file"
    }
}

Compress-Archive -Path "$tmp\*" -DestinationPath $dest -CompressionLevel Optimal -Force
Remove-Item $tmp -Recurse -Force

$size = [math]::Round((Get-Item $dest).Length / 1KB, 1)
Write-Host "`nZIP creado: $dest ($size KB)"
Write-Host "Subilo al File Manager de TCAdmin y extraelo en la raiz."
