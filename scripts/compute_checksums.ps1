# compute_checksums.ps1
# Compute SHA256 checksums for model archives (zip files) in the models/ directory
param(
  [string]$ModelsDir = "models",
  [string]$OutFile = "models.json"
)
if (-not (Test-Path $ModelsDir)) { Write-Error "Models directory '$ModelsDir' not found"; exit 2 }
$entries = @()
Get-ChildItem -Path $ModelsDir -Filter "*.zip" -File -Recurse | ForEach-Object {
  $hash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash.ToLower()
  $name = $_.BaseName
  $url = "" # fill if you have remote URL
  $entries += @{ name = $name; url = $url; sha256 = $hash }
}
$entries | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $OutFile
Write-Host "Wrote $(($entries).Count) entries to $OutFile"
