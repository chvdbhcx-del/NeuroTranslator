# upload_to_gdrive.ps1
param(
  [string]$Remote = $(throw 'Provide rclone remote name (e.g. gdrive)'),
  [string]$RemotePath = $(throw 'Provide remote path (e.g. NeuroTranslator/models)'),
  [string]$ModelsDir = "models"
)
if (-not (Get-Command rclone -ErrorAction SilentlyContinue)) { Write-Error 'rclone not found. Install and configure rclone before running.'; exit 2 }
& rclone copy $ModelsDir "$Remote:`$RemotePath" --progress
