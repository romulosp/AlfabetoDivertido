[CmdletBinding()]
param(
    [string]$Godot = 'D:\desenvolvimento\Godot\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$Capture
)

$ErrorActionPreference = 'Stop'
$workspace = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$project = Join-Path $workspace 'apps/alfabeto-godot'
$evidence = Join-Path $workspace 'tests/evidence/godot'
New-Item -ItemType Directory -Path $evidence -Force | Out-Null
& $Godot --headless --path $project --editor --import > (Join-Path $evidence 'import.log')
if ($LASTEXITCODE -ne 0) { throw 'A importacao do projeto falhou.' }
$suites = @('rules_test.gd', 'integration_test.gd', 'audio_test.gd', 'layout_test.gd')
foreach ($suite in $suites) {
    $script = Join-Path $workspace ('tests/godot/' + $suite)
    $result = & $Godot --headless --path $project --script $script
    $exit = $LASTEXITCODE
    $result | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $evidence ($suite + '.log'))
    $result | Write-Output
    if ($exit -ne 0) { throw "Teste falhou: $suite" }
}
if ($Capture) {
    $output = Join-Path $evidence 'visual.stdout.log'
    $errors = Join-Path $evidence 'visual.stderr.log'
    $arguments = @('--windowed', '--path', ('"' + $project + '"'), '--script', '"../../tests/godot/layout_test.gd"', '--', '--capture')
    $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WindowStyle Hidden -RedirectStandardOutput $output -RedirectStandardError $errors -PassThru
    $handle = $process.Handle
    $finished = $process.WaitForExit(60000)
    if (-not $finished) {
        $process.Kill()
        throw 'A captura nao terminou em 60 segundos.'
    }
    $process.Refresh()
    if ($process.ExitCode -ne 0) { throw "Captura falhou: consulte $errors" }
    Get-Content -LiteralPath $output | Write-Output
}
