#!/usr/bin/env bash
# install_deps.sh
# Installs common dependencies for the project.
# Usage: ./scripts/install_deps.sh
set -euo pipefail
if [ -f package.json ]; then
  if command -v npm >/dev/null 2>&1; then
    npm install
  else
    echo "npm not found - please install Node.js/npm" >&2
  fi
fi
if [ -f requirements.txt ]; then
  if [ -d env ]; then
    pip="env/bin/pip"
  elif [ -d venv ]; then
    pip="venv/bin/pip"
  else
    pip="pip"
  fi
  if command -v "$pip" >/dev/null 2>&1; then
    "$pip" install -r requirements.txt
  else
    echo "pip not found - please install Python/pip" >&2
  fi
fi
if [ -f pyproject.toml ]; then
  echo "pyproject.toml present - consider using poetry or pip to install" 
fi

echo "Install script finished."
