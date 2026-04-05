param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$releaseRoot = Join-Path $repoRoot "release"
$packageRoot = Join-Path $releaseRoot "package"
$pluginRoot = Join-Path $packageRoot "Plugin"
$zipPath = Join-Path $releaseRoot "SaveAliasOld-v$Version.au2pkg.zip"
$artifactPath = Join-Path $repoRoot "build\\Release\\SaveAliasOld.aux2"

if (Test-Path $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $pluginRoot | Out-Null

if (-not (Test-Path $artifactPath)) {
    throw "Built artifact not found: $artifactPath"
}

Copy-Item -LiteralPath $artifactPath -Destination (Join-Path $pluginRoot "SaveAliasOld.aux2") -Force

$releaseNotesTemplate = Get-Content -LiteralPath (Join-Path $repoRoot "release.md") -Raw
$releaseNotes = $releaseNotesTemplate.Replace("{{version}}", $Version)
Set-Content -LiteralPath (Join-Path $releaseRoot "README.md") -Value $releaseNotes -Encoding utf8

if (Test-Path $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $zipPath -Force
Write-Host "Created package: $zipPath"
