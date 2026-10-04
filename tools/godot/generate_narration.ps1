[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$targetRoot = Join-Path $projectRoot 'apps/alfabeto-godot'
$audioRoot = Join-Path $targetRoot 'assets/audio'
New-Item -ItemType Directory -Path $audioRoot -Force | Out-Null
$manifest = Get-Content -Encoding UTF8 -Raw -LiteralPath (Join-Path $PSScriptRoot 'narration_manifest.json') | ConvertFrom-Json
$voice = New-Object -ComObject SAPI.SpVoice
$available = $voice.GetVoices()
$selected = $null
for ($index = 0; $index -lt $available.Count; $index++) {
    $candidate = $available.Item($index)
    if ($candidate.GetAttribute('Language') -eq '416') {
        $selected = $candidate
        break
    }
}
if ($null -eq $selected) { throw 'Instale uma voz local pt-BR antes de gerar as narracoes.' }
$voice.Voice = $selected
$voice.Rate = -1
$resourceLines = [System.Collections.Generic.List[string]]::new()
$resourceLines.Add('[gd_resource type="Resource" script_class="NarrationCatalog" load_steps=' + ($manifest.Count + 2) + ' format=3]')
$resourceLines.Add('')
$resourceLines.Add('[ext_resource type="Script" path="res://scripts/narration_catalog.gd" id="catalog"]')
$entries = [System.Collections.Generic.List[string]]::new()
for ($index = 0; $index -lt $manifest.Count; $index++) {
    $item = $manifest[$index]
    $stream = New-Object -ComObject SAPI.SpFileStream
    try {
        $stream.Format.Type = 22
        $stream.Open((Join-Path $audioRoot $item.file), 3, $false)
        $voice.AudioOutputStream = $stream
        [void]$voice.Speak($item.spoken, 0)
    } finally {
        $stream.Close()
        [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($stream)
    }
    $resourceLines.Add('[ext_resource type="AudioStream" path="res://assets/audio/' + $item.file + '" id="audio_' + $index + '"]')
    $jsonText = ConvertTo-Json -InputObject ([string]$item.text) -Compress
    $entries.Add($jsonText + ': ExtResource("audio_' + $index + '")')
}
$resourceLines.Add('')
$resourceLines.Add('[resource]')
$resourceLines.Add('script = ExtResource("catalog")')
$resourceLines.Add('clips = Dictionary[String, AudioStream]({' + [Environment]::NewLine + ($entries -join (',' + [Environment]::NewLine)) + [Environment]::NewLine + '})')
$utf8 = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllLines((Join-Path $targetRoot 'data/narration_catalog.tres'), $resourceLines, $utf8)
$summary = @{ clips = $manifest.Count; voice = $selected.GetDescription(); sample_rate = 22050; channels = 1; offline = $true }
$summary | ConvertTo-Json -Compress
[void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($voice)
