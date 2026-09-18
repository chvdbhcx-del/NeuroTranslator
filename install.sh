#!/usr/bin/env bash
# install.sh — one-line installer for NeuroTranslator (Linux / macOS).
#
#   curl -fsSL https://raw.githubusercontent.com/chvdbhcx-del/NeuroTranslator/main/install.sh | bash
#
# When run via curl|bash it clones the repository into ./NeuroTranslator.
# When run from inside an existing checkout it installs in place.
#
# It creates a virtual environment and installs the `neurotranslator` CLI so
# you can run `neurotranslator --help` afterwards.
set -euo pipefail

REPO_URL="${NEUROTRANSLATOR_REPO:-https://github.com/chvdbhcx-del/NeuroTranslator.git}"
TARGET_DIR="${NEUROTRANSLATOR_DIR:-NeuroTranslator}"

info() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; }

# Locate (or obtain) a checkout to install from.
if [ -f "pyproject.toml" ] && [ -d "neurotranslator" ]; then
  info "Installing from the current checkout"
  SRC_DIR="$(pwd)"
else
  if ! command -v git >/dev/null 2>&1; then
    err "git is required to clone the repository."
    exit 1
  fi
  if [ -d "$TARGET_DIR/.git" ]; then
    info "Updating existing checkout in $TARGET_DIR"
    git -C "$TARGET_DIR" pull --ff-only
  else
    info "Cloning $REPO_URL into $TARGET_DIR"
    git clone --depth 1 "$REPO_URL" "$TARGET_DIR"
  fi
  SRC_DIR="$(cd "$TARGET_DIR" && pwd)"
fi

cd "$SRC_DIR"

# Pick a Python interpreter.
PY=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1; then PY="$cand"; break; fi
done
if [ -z "$PY" ]; then
  err "Python 3.8+ is required but was not found."
  exit 1
fi

info "Creating virtual environment in .venv"
"$PY" -m venv .venv
# shellcheck disable=SC1091
. .venv/bin/activate

info "Installing the neurotranslator CLI"
python -m pip install --upgrade pip >/dev/null
python -m pip install .

info "Done. The 'neurotranslator' CLI is installed in $SRC_DIR/.venv"
cat <<EOF

Try it:
  cd "$SRC_DIR"
  source .venv/bin/activate
  neurotranslator --help
  neurotranslator download scripts/models.json.sample

EOF
