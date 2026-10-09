[CmdletBinding()]
param([switch]$Capture)
$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$godot=(Get-ChildItem 'D:\desenvolvimento\Godot' -Filter '*console.exe' | Select-Object -First 1).FullName
if (-not $godot) { throw 'Godot ausente.' }
& python -m unittest discover -s (Join-Path $taskRoot '.agents/skills/alfabeto-nano-banana/tests')
if ($LASTEXITCODE -ne 0) { throw 'Testes Python falharam.' }
& $godot --headless --editor --path (Join-Path $taskRoot 'godot') --import > (Join-Path $taskRoot 'docs/evidence/import-3d.log') 2>&1
if ($LASTEXITCODE -ne 0) { throw 'Importacao falhou.' }
$ErrorActionPreference='Continue'
& $godot --headless --path (Join-Path $taskRoot 'godot') --script ../tests/3d/runtime_test.gd > (Join-Path $taskRoot 'docs/evidence/runtime-test.log') 2>&1
$ErrorActionPreference='Stop'
if ($LASTEXITCODE -ne 0) { throw 'Integracao falhou.' }
Get-Content (Join-Path $taskRoot 'docs/evidence/runtime-test.log')
if ($Capture) {
    $p=Start-Process $godot -ArgumentList @('--path',(Join-Path $taskRoot 'godot'),'--windowed','--script','../tests/3d/visual_test.gd') -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $taskRoot 'docs/evidence/visual-test.log') -RedirectStandardError (Join-Path $taskRoot 'docs/evidence/visual-test.stderr.log')
    $handle=$p.Handle
    if (-not $p.WaitForExit(60000)) { throw 'Captura excedeu60s.' }
    $p.Refresh()
    if ($p.ExitCode -ne 0) { throw 'Captura falhou.' }
}
