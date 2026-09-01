# install_deps.ps1
# Installs common dependencies for the project.
# Usage: .\scripts\install_deps.ps1

$ErrorActionPreference = 'Stop'
if (Test-Path package.json) {
  if (Get-Command npm -ErrorAction SilentlyContinue) { npm install } else { Write-Warning 'npm not found - please install Node.js/npm' }
}
if (Test-Path requirements.txt) {
  if (Test-Path env) { $pip = Join-Path 'env' 'Scripts\pip.exe' } elseif (Test-Path venv) { $pip = Join-Path 'venv' 'Scripts\pip.exe' } else { $pip = 'pip' }
  if (Get-Command $pip -ErrorAction SilentlyContinue) { & $pip install -r requirements.txt } else { Write-Warning 'pip not found - please install Python/pip' }
}
if (Test-Path package-lock.json -and -not (Test-Path package.json)) { Write-Host 'No package.json found but package-lock.json exists' }
if (Test-Path pyproject.toml) { Write-Host 'pyproject.toml detected - consider using pipx or poetry for install' }
Write-Host 'Install script finished.'
