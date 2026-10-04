[CmdletBinding()]
param(
    [string]$Godot = 'D:\desenvolvimento\Godot\Godot_v4.7.2-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$workspace = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$project = Join-Path $workspace 'apps/alfabeto-godot'
$output = Join-Path $workspace 'builds/android'
$evidence = Join-Path $workspace 'tests/evidence/godot'
New-Item -ItemType Directory -Path $output, $evidence -Force | Out-Null
$template = 'D:\desenvolvimento\Godot\export_templates\4.7.2.stable\android_debug.apk'
if (-not (Test-Path -LiteralPath $template)) { throw "Template Android ausente: $template" }
& (Join-Path $PSScriptRoot 'configure_android.ps1') > (Join-Path $evidence 'configure-android.log')
$apk = Join-Path $output 'alfabeto-divertido-debug.apk'
& $Godot --headless --path $project --export-debug Android $apk > (Join-Path $evidence 'export.log')
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $apk)) { throw 'A exportacao Android falhou.' }
$manifest = [ordered]@{
    artifact = $apk
    version = '0.1.0'
    engine = ((& $Godot --version) | Out-String).Trim()
    package = 'com.romulopenha.alfabetodivertido'
    orientation = 'landscape'
    fullscreen = $true
    build = 'debug'
    bytes = (Get-Item -LiteralPath $apk).Length
    sha256 = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
}
$manifest | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $output 'manifest.json')
$manifest | ConvertTo-Json -Compress
