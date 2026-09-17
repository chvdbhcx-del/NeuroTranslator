<#
install.ps1 — one-line installer for NeuroTranslator (Windows PowerShell).

  irm https://raw.githubusercontent.com/chvdbhcx-del/NeuroTranslator/main/install.ps1 | iex

When run via irm|iex it clones the repository into .\NeuroTranslator.
When run from inside an existing checkout it installs in place.

It creates a virtual environment and installs the `neurotranslator` CLI so
you can run `neurotranslator --help` afterwards.

Prefer a ready-made binary? Download neurotranslator.exe from the Releases page:
  https://github.com/chvdbhcx-del/NeuroTranslator/releases
#>
$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

$RepoUrl   = if ($env:NEUROTRANSLATOR_REPO) { $env:NEUROTRANSLATOR_REPO } else { 'https://github.com/chvdbhcx-del/NeuroTranslator.git' }
$TargetDir = if ($env:NEUROTRANSLATOR_DIR)  { $env:NEUROTRANSLATOR_DIR }  else { 'NeuroTranslator' }

# Locate (or obtain) a checkout to install from.
if ((Test-Path 'pyproject.toml') -and (Test-Path 'neurotranslator')) {
  Write-Info 'Installing from the current checkout'
  $SrcDir = (Get-Location).Path
} else {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git is required to clone the repository.'
  }
  if (Test-Path (Join-Path $TargetDir '.git')) {
    Write-Info "Updating existing checkout in $TargetDir"
    git -C $TargetDir pull --ff-only
  } else {
    Write-Info "Cloning $RepoUrl into $TargetDir"
    git clone --depth 1 $RepoUrl $TargetDir
  }
  $SrcDir = (Resolve-Path $TargetDir).Path
}

Set-Location $SrcDir

# Pick a Python interpreter.
$py = $null
foreach ($cand in @('python', 'python3')) {
  if (Get-Command $cand -ErrorAction SilentlyContinue) { $py = $cand; break }
}
if (-not $py) { Write-Error 'Python 3.8+ is required but was not found.' }

Write-Info 'Creating virtual environment in .venv'
& $py -m venv .venv

$pip = Join-Path '.venv' 'Scripts\pip.exe'
Write-Info 'Installing the neurotranslator CLI'
& $pip install --upgrade pip | Out-Null
& $pip install .

Write-Info "Done. The 'neurotranslator' CLI is installed in $SrcDir\.venv"
Write-Host @"

Try it:
  cd "$SrcDir"
  .\.venv\Scripts\Activate.ps1
  neurotranslator --help
  neurotranslator download scripts\models.json.sample

"@
