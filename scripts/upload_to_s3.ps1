# upload_to_s3.ps1
# Upload model archives (zip files) from models/ to an S3 bucket using aws cli.
param(
  [string]$ModelsDir = "models",
  [string]$Bucket = $(throw "Provide S3 bucket like: my-bucket/path"),
  [switch]$PublicRead = $false
)
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) { Write-Error 'aws CLI not found. Configure AWS CLI before running.'; exit 2 }
Get-ChildItem -Path $ModelsDir -Filter "*.zip" -File -Recurse | ForEach-Object {
  $key = "$($_.Name)"
  $s3uri = "s3://$Bucket/$key"
  Write-Host "Uploading $($_.FullName) -> $s3uri"
  & aws s3 cp $_.FullName $s3uri --only-show-errors
  if ($PublicRead) { & aws s3api put-object-acl --bucket ($Bucket -split '/')[0] --key $key --acl public-read }
}
Write-Host 'Upload complete.'
