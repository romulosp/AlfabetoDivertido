[CmdletBinding()]
param(
    [string]$Sdk = 'D:\desenvolvimento\ferramentas_android\Sdk',
    [string]$ApkPath = '',
    [string]$Package = 'com.romulopenha.alfabetodivertido',
    [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
trap {
    Write-Host ("Deploy interrompido: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
$workspace = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$apk = Join-Path $workspace 'builds/android/alfabeto-divertido-debug.apk'
if (-not [string]::IsNullOrWhiteSpace($ApkPath)) { $apk = $ApkPath }
if ($Package -notmatch '^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$') { throw 'Pacote Android invalido.' }
$adb = Join-Path $Sdk 'platform-tools/adb.exe'
# Read saved Windows settings first: VS Code may inherit an outdated value.
$target = [Environment]::GetEnvironmentVariable('PORTA_CELULAR', 'User')
$targetSource = 'variavel de usuario do Windows'
if ([string]::IsNullOrWhiteSpace($target)) {
    $target = [Environment]::GetEnvironmentVariable('PORTA_CELULAR', 'Machine')
    $targetSource = 'variavel de sistema do Windows'
}
if ([string]::IsNullOrWhiteSpace($target)) {
    $target = $env:PORTA_CELULAR
    $targetSource = 'ambiente do processo'
}
if ([string]::IsNullOrWhiteSpace($target)) {
    throw 'Defina PORTA_CELULAR com o serial USB mostrado por adb devices ou com IP:porta da depuracao sem fio.'
}
$target = $target.Trim()
Write-Host "PORTA_CELULAR=$target (origem: $targetSource)"
if ($target -match '^COM\d+$') { throw 'Use o identificador ADB do celular em PORTA_CELULAR, por exemplo RQCT504WC1W. Portas COM nao sao destinos ADB.' }
if ($target -match '^\d+$') {
    $phoneIp = $env:IP_CELULAR
    if ([string]::IsNullOrWhiteSpace($phoneIp)) {
        throw 'PORTA_CELULAR contem somente a porta TCP. Defina tambem IP_CELULAR ou use IP:porta em PORTA_CELULAR.'
    }
    $target = '{0}:{1}' -f $phoneIp.Trim(), $target
}
if ($target -match '^emulator-' -or $target -match '\s' -or $target.StartsWith('-')) {
    throw 'PORTA_CELULAR deve identificar um celular fisico, sem espacos.'
}
if ($target.Contains(':') -and $target -notmatch '^([a-zA-Z0-9_.-]+|\[[0-9a-fA-F:]+\]):\d{1,5}$') {
    throw 'Endereco invalido. Use IP:porta da conexao ADB (nao a porta de pareamento).'
}
if ($target.Contains(':')) {
    $tcpPort = [int]($target.Substring($target.LastIndexOf(':') + 1))
    if ($tcpPort -lt 1 -or $tcpPort -gt 65535) { throw 'Porta TCP fora do intervalo 1-65535.' }
}
foreach ($required in @($adb, $apk)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Arquivo ausente: $required" }
}
if ($CheckOnly) {
    Write-Host "Configuracao valida: PORTA_CELULAR=$target; APK=$apk"
    return
}
& $adb start-server
if ($LASTEXITCODE -ne 0) { throw 'Falha ao iniciar ADB.' }
if ($target.Contains(':')) {
    & $adb connect $target
    if ($LASTEXITCODE -ne 0) { throw "Falha ao conectar a $target." }
}
$escapedTarget = [regex]::Escape($target)
$deadline = (Get-Date).AddSeconds(15)
do {
    $devices = (& $adb devices | Out-String)
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao consultar dispositivos ADB.' }
    if ($devices -match "(?m)^$escapedTarget\s+(device|unauthorized)\s*$") { break }
    Start-Sleep -Milliseconds 500
} while ((Get-Date) -lt $deadline)
if ($devices -notmatch "(?m)^$escapedTarget\s+device\s*$") {
    if ($devices -match "(?m)^$escapedTarget\s+unauthorized") {
        throw 'Celular nao autorizado. Aceite a depuracao USB na tela do celular e execute novamente.'
    }
    throw "Celular '$target' nao esta conectado ao ADB. Confira cabo, depuracao USB ou pareamento Wi-Fi. Execute adb devices para conferir o identificador."
}
Write-Host "Instalando APK no celular $target..."
& $adb -s $target install -r $apk
if ($LASTEXITCODE -ne 0) { throw 'Falha ao instalar o APK no celular.' }
& $adb -s $target shell am force-stop $Package
if ($LASTEXITCODE -ne 0) { throw 'Falha ao reiniciar o aplicativo no celular.' }
$launch = (& $adb -s $target shell am start -W -n "$Package/com.godot.game.GodotAppLauncher" | Out-String)
Write-Host $launch
if ($LASTEXITCODE -ne 0 -or $launch -match '(?m)^Error') { throw 'Falha ao abrir o aplicativo no celular.' }
Write-Host "Deploy concluido: aplicativo aberto no celular $target."
