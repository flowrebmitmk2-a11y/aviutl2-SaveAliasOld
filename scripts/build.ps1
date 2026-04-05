param(
    [string]$Configuration = "Release",
    [string]$Generator = "",
    [string]$Architecture = "x64"
)

$ErrorActionPreference = "Stop"

function Resolve-CMakeGenerator {
    param([string]$Requested)

    if ($Requested) {
        return $Requested
    }

    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (Test-Path $vswhere) {
        $vs18 = & $vswhere -version '[18.0,19.0)' -products * -latest -property installationPath
        if ($LASTEXITCODE -eq 0 -and $vs18) {
            return 'Visual Studio 18 2026'
        }

        $vs17 = & $vswhere -version '[17.0,18.0)' -products * -latest -property installationPath
        if ($LASTEXITCODE -eq 0 -and $vs17) {
            return 'Visual Studio 17 2022'
        }
    }

    throw 'No supported Visual Studio generator was detected. Pass -Generator explicitly.'
}

function Invoke-Native {
    param([scriptblock]$Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE"
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $repoRoot 'build'
$resolvedGenerator = Resolve-CMakeGenerator -Requested $Generator

if (-not (Test-Path (Join-Path $buildDir 'CMakeCache.txt'))) {
    Invoke-Native { cmake -S $repoRoot -B $buildDir -G $resolvedGenerator -A $Architecture }
}

Invoke-Native { cmake --build $buildDir --config $Configuration }
