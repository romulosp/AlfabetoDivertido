[CmdletBinding()]
param(
    [string]$Sdk = 'D:\desenvolvimento\ferramentas_android\Sdk',
    [string]$Jdk = 'D:\desenvolvimento\ferramentas_android\Nova pasta\AndroidStudio\jbr'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath (Join-Path $Sdk 'platform-tools/adb.exe'))) { throw 'SDK Android invalido.' }
if (-not (Test-Path -LiteralPath (Join-Path $Jdk 'bin/java.exe'))) { throw 'JDK invalido.' }
$settings = Join-Path $env:APPDATA 'Godot/editor_settings-4.7.tres'
if (-not (Test-Path -LiteralPath $settings)) { throw 'Abra o Godot 4.7 uma vez para criar as configuracoes do editor.' }
$content = [System.IO.File]::ReadAllText($settings)
$values = [ordered]@{
    'export/android/android_sdk_path' = $Sdk.Replace('\', '/')
    'export/android/java_sdk_path' = $Jdk.Replace('\', '/')
}
foreach ($key in $values.Keys) {
    $line = $key + ' = "' + $values[$key] + '"'
    $pattern = '(?m)^' + [regex]::Escape($key) + ' = .*\r?$'
    if ([regex]::IsMatch($content, $pattern)) {
        $content = [regex]::Replace($content, $pattern, $line)
    } else {
        $content = $content.Replace('[resource]', '[resource]' + [Environment]::NewLine + $line)
    }
}
[System.IO.File]::WriteAllText($settings, $content, [System.Text.UTF8Encoding]::new($false))
Write-Output '{"android_sdk_configured":true,"java_sdk_configured":true}'
