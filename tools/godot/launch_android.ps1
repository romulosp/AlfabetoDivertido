[CmdletBinding()]
param(
    [string]$Sdk = 'D:\desenvolvimento\ferramentas_android\Sdk',
    [string]$Avd = 'Medium_Tablet',
    [int]$Port = 5584,
    [int]$TimeoutSeconds = 180
)

$ErrorActionPreference = 'Stop'
$workspace = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$apk = Join-Path $workspace 'builds/android/alfabeto-divertido-debug.apk'
$adb = Join-Path $Sdk 'platform-tools/adb.exe'
$emulator = Join-Path $Sdk 'emulator/emulator.exe'
foreach ($required in @($apk, $adb, $emulator)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Arquivo ausente: $required" }
}
$avds = @(& $emulator -list-avds)
if ($LASTEXITCODE -ne 0 -or $Avd -notin $avds) { throw "AVD '$Avd' ausente. Disponiveis: $($avds -join ', ')" }
& $adb start-server
if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel iniciar o adb.' }
$serial = "emulator-$Port"
$devices = (& $adb devices | Out-String)
if ($devices -notmatch "(?m)^$serial\s") {
    Write-Host "Iniciando $Avd ($serial)..."
    $logs = Join-Path $workspace 'tests/evidence/godot'
    New-Item -ItemType Directory -Path $logs -Force | Out-Null
    Start-Process -FilePath $emulator -ArgumentList @('-avd', $Avd, '-port', $Port, '-read-only', '-no-snapshot', '-gpu', 'auto') -WindowStyle Hidden -RedirectStandardOutput (Join-Path $logs 'launch-emulator.stdout.log') -RedirectStandardError (Join-Path $logs 'launch-emulator.stderr.log') | Out-Null
}
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$booted = $false
while ((Get-Date) -lt $deadline) {
    $devices = (& $adb devices | Out-String)
    if ($devices -match "(?m)^$serial\s+device\s*$") {
        $boot = (& $adb -s $serial shell getprop sys.boot_completed 2>$null | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and $boot -eq '1') { $booted = $true; break }
    }
    Start-Sleep -Seconds 2
}
if (-not $booted) { throw "Emulador nao iniciou em $TimeoutSeconds segundos. Consulte tests/evidence/godot/launch-emulator.stderr.log." }
Write-Host 'Instalando APK...'
& $adb -s $serial install -r $apk
if ($LASTEXITCODE -ne 0) { throw 'Falha ao instalar o APK.' }
& $adb -s $serial shell am force-stop com.romulopenha.alfabetodivertido
if ($LASTEXITCODE -ne 0) { throw 'Falha ao reiniciar o aplicativo.' }
& $adb -s $serial shell am start -W -n com.romulopenha.alfabetodivertido/com.godot.game.GodotAppLauncher
if ($LASTEXITCODE -ne 0) { throw 'Falha ao abrir o aplicativo.' }
Write-Host "APK aberto em $serial. A janela do emulador pode ser acessada pela barra de tarefas."
