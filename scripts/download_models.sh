#!/usr/bin/env bash
# download_models.sh
# Bash script to download and verify NeuroTranslator models.
# Usage:
#   ./download_models.sh            # uses built-in list (edit URLs/checksums below)
#   ./download_models.sh models.json
# models.json format: [{"name":"model_en","url":"...","sha256":"..."}, ...]

set -euo pipefail
DEST="models"
INPUT=${1-}

json_to_models() {
  # Requires jq if using JSON input
  if [ -n "$INPUT" ]; then
    if ! command -v jq >/dev/null 2>&1; then
      echo "jq is required to parse JSON input" >&2
      exit 2
    fi
    jq -c '.[]' "$INPUT"
  else
    cat <<EOF
{"name":"model_en","url":"https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip","sha256":""}
{"name":"model_en_large","url":"https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip","sha256":""}
{"name":"model_ru_large","url":"https://alphacephei.com/vosk/models/vosk-model-ru-0.22.zip","sha256":""}
{"name":"model_ru_small","url":"https://alphacephei.com/vosk/models/vosk-model-small-ru-0.22.zip","sha256":""}
EOF
  fi
}

mkdir -p "$DEST"

while read -r item; do
  name=$(echo "$item" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  url=$(echo "$item" | sed -n 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  sha=$(echo "$item" | sed -n 's/.*"sha256"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  zip="$DEST/$name.zip"
  out="$DEST/$name"

  if [ -f "$zip" ] && [ -n "$sha" ]; then
    got=$(sha256sum "$zip" | awk '{print $1}')
    if [ "$got" = "$sha" ]; then
      echo "$name: archive exists and checksum matches — skipping"
      continue
    else
      echo "$name: checksum mismatch, re-downloading"
    fi
  elif [ -f "$zip" ]; then
    echo "$name: archive exists but no checksum provided — skipping (remove $zip to force)"
    continue
  fi

  echo "Downloading $name from $url"
  if command -v curl >/dev/null 2>&1; then
    curl -L --retry 5 -o "$zip" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$zip" "$url"
  else
    echo "curl or wget required" >&2; exit 2
  fi

  if [ -n "$sha" ]; then
    got=$(sha256sum "$zip" | awk '{print $1}')
    if [ "$got" != "$sha" ]; then
      echo "Checksum failed for $zip" >&2; rm -f "$zip"; exit 3
    fi
  else
    echo "No checksum provided for $name — consider verifying manually"
  fi

  if [ ! -d "$out" ]; then
    unzip -q "$zip" -d "$out" || ( echo "Unzip failed" >&2; exit 4 )
  else
    echo "$out already exists — skipping extraction"
  fi

done < <(json_to_models)

echo "All done. Models are in: $(realpath "$DEST")"
