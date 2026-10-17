$sampleRate = 44100
$beepFreq = 1000.0
$beepOnMs = 300
$beepOffMs = 200
$totalMs = 3000

$totalSamples = [int]($sampleRate * $totalMs / 1000)
$bytesPerSample = 2
$dataSize = $totalSamples * $bytesPerSample

$outPath = "C:\Users\Sucharith\Documents\Tracker app\alarm_test\assets\alarm.wav"
New-Item -ItemType Directory -Force -Path (Split-Path $outPath) | Out-Null

$fs = [System.IO.File]::Open($outPath, [System.IO.FileMode]::Create)
$bw = New-Object System.IO.BinaryWriter($fs)

# RIFF header
$bw.Write([byte[]][char[]]"RIFF")
$bw.Write([int32](36 + $dataSize))
$bw.Write([byte[]][char[]]"WAVE")

# fmt chunk
$bw.Write([byte[]][char[]]"fmt ")
$bw.Write([int32]16)
$bw.Write([int16]1)                      # PCM
$bw.Write([int16]1)                      # mono
$bw.Write([int32]$sampleRate)
$bw.Write([int32]($sampleRate * $bytesPerSample))
$bw.Write([int16]$bytesPerSample)
$bw.Write([int16]16)                     # bits per sample

# data chunk
$bw.Write([byte[]][char[]]"data")
$bw.Write([int32]$dataSize)

$cycleMs = $beepOnMs + $beepOffMs
for ($i = 0; $i -lt $totalSamples; $i++) {
  $tMs = $i * 1000.0 / $sampleRate
  $posInCycle = $tMs % $cycleMs
  if ($posInCycle -lt $beepOnMs) {
    $t = $i / $sampleRate
    $sample = [Math]::Sin(2 * [Math]::PI * $beepFreq * $t) * 0.9
    $val = [int16]([Math]::Round($sample * 32767))
  } else {
    $val = [int16]0
  }
  $bw.Write($val)
}

$bw.Flush()
$bw.Close()
$fs.Close()

Write-Output "Wrote $outPath ($((Get-Item $outPath).Length) bytes)"
