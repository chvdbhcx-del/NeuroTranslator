<#
download_models.ps1
PowerShell script to download and verify NeuroTranslator models.

Usage:
  ./download_models.ps1                # use built-in list (edit URLs/checksums below)
  ./download_models.ps1 -ModelsFile models.json  # provide JSON file with list

models.json format (array of objects):
[
  {"name":"model_en","url":"https://.../vosk-model-en-us-0.22.zip","sha256":"<hex>"},
  {"name":"model_ru_large","url":"https://.../vosk-model-ru-0.22.zip","sha256":"<hex>"}
]
#>
param(
    [string]$ModelsFile = "",
    [string]$Dest = "models"
)

function Get-ModelList {
    param($ModelsFile)
    if ($ModelsFile -and (Test-Path $ModelsFile)) {
        try { return (Get-Content $ModelsFile -Raw | ConvertFrom-Json) }
        catch { Write-Error "Failed to parse $ModelsFile"; exit 2 }
    }
    # Default list (edit URLs and sha256 if you have them)
    return @(
        @{ name = 'model_en'; url = 'https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip'; sha256 = '' },
        @{ name = 'model_en_large'; url = 'https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip'; sha256 = '' },
        @{ name = 'model_ru_large'; url = 'https://alphacephei.com/vosk/models/vosk-model-ru-0.22.zip'; sha256 = '' },
        @{ name = 'model_ru_small'; url = 'https://alphacephei.com/vosk/models/vosk-model-small-ru-0.22.zip'; sha256 = '' }
    )
}

$models = Get-ModelList -ModelsFile $ModelsFile
if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest | Out-Null }

foreach ($m in $models) {
    $name = $m.name
    $url = $m.url
    $expected = $m.sha256
    if (-not $url) { Write-Warning "Model $name has no URL, skipping"; continue }

    $zipPath = Join-Path $Dest ($name + '.zip')
    $outDir = Join-Path $Dest $name

    $needDownload = $true
    if (Test-Path $zipPath) {
        if ($expected) {
            $h = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash.ToLower()
            if ($h -eq $expected.ToLower()) { Write-Host "$name: archive exists and checksum matches — skipping download"; $needDownload = $false }
            else { Write-Host "$name: checksum mismatch, will re-download" }
        } else { Write-Host "$name: archive exists but no checksum provided — skipping download (remove $zipPath to force)"; $needDownload = $false }
    }

    if ($needDownload) {
        Write-Host "Downloading $name from $url..."
        try {
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -TimeoutSec 1200
        } catch {
            Write-Error "Failed to download $url : $_"; continue
        }
        if ($expected) {
            $h = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash.ToLower()
            if ($h -ne $expected.ToLower()) { Write-Error "$name: checksum verification failed (expected $expected, got $h)"; continue }
            else { Write-Host "$name: checksum OK" }
        } else { Write-Warning "$name: no expected checksum provided — consider verifying manually" }
    }

    if (-not (Test-Path $outDir)) {
        Write-Host "Extracting $zipPath -> $outDir"
        try { Expand-Archive -Path $zipPath -DestinationPath $outDir -Force } catch { Write-Error "Failed to extract $zipPath : $_"; continue }
    } else { Write-Host "$outDir already exists — skipping extraction" }
}

Write-Host "All done. Models are in: $(Resolve-Path $Dest)"
