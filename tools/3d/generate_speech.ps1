$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
& python (Join-Path $PSScriptRoot 'make_speech.py')
$lines = Get-Content -Raw -Encoding UTF8 (Join-Path $taskRoot 'godot/content/speech.json') | ConvertFrom-Json
$audioPath = Join-Path $taskRoot 'godot/assets/audio'
New-Item -ItemType Directory -Force $audioPath | Out-Null
$voice = New-Object -ComObject SAPI.SpVoice
$tokens = $voice.GetVoices()
for ($i=0; $i -lt $tokens.Count; $i++) { if ($tokens.Item($i).GetAttribute('Language') -eq '416') { $voice.Voice = $tokens.Item($i); break } }
if ($voice.Voice.GetAttribute('Language') -ne '416') { throw 'Voz pt-BR ausente.' }
$voice.Rate = -1
foreach ($item in $lines.PSObject.Properties) {
    $stream = New-Object -ComObject SAPI.SpFileStream
    try {
        $stream.Format.Type = 34
        $stream.Open((Join-Path $audioPath ($item.Name + '.wav')), 3, $false)
        $voice.AudioOutputStream = $stream
        [void]$voice.Speak($item.Value.text, 0)
    } finally { $stream.Close(); [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($stream) }
}
[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($voice)
& python (Join-Path $PSScriptRoot 'make_speech.py')
if ($LASTEXITCODE -ne 0) { throw 'Falha na conversao OGG.' }
Write-Host '16 narracoes offline preparadas.'
