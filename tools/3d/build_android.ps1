[CmdletBinding()]
param([switch]$RequireApproved)
$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$godot=(Get-ChildItem 'D:\desenvolvimento\Godot' -Filter '*console.exe' | Select-Object -First 1).FullName
if (-not $godot) { throw 'Godot ausente.' }
$version=(& $godot --version | Out-String).Trim()
if ($version -notmatch '^4\.7\.2\.') { throw "Motor nao validado: $version" }
$template='D:\desenvolvimento\Godot\export_templates\4.7.2.stable\android_debug.apk'
if (-not (Test-Path $template)) { throw 'Template compativel ausente.' }
if ($RequireApproved) {
    & python (Join-Path $taskRoot '.agents/skills/alfabeto-nano-banana/scripts/approve_images.py') --verify-runtime
    if ($LASTEXITCODE -ne 0) { throw 'Imagens aprovadas incompletas ou invalidas.' }
}
& (Join-Path $taskRoot 'tools/godot/configure_android.ps1') | Out-Null
$output=Join-Path $taskRoot 'build/android/debug'
New-Item -ItemType Directory -Force $output | Out-Null
$apk=Join-Path $output 'alfabeto-3d-debug.apk'
& $godot --headless --path (Join-Path $taskRoot 'godot') --export-debug Android $apk > (Join-Path $taskRoot 'docs/evidence/export-3d.log')
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $apk)) { throw 'Exportacao Android falhou.' }
$manifest=@{version='0.2.1';engine=$version;package='com.romulopenha.alfabeto3d';build='debug';imagesApprovedRequired=[bool]$RequireApproved;sha256=(Get-FileHash $apk -Algorithm SHA256).Hash.ToLowerInvariant();bytes=(Get-Item $apk).Length}
$manifest | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $output 'manifest.json')
$manifest | ConvertTo-Json -Compress
