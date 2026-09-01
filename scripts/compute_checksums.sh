#!/usr/bin/env bash
# compute_checksums.sh
# Requires: sha256sum, jq
MODELS_DIR=${1:-models}
OUT=${2:-models.json}
if [ ! -d "$MODELS_DIR" ]; then echo "Models dir $MODELS_DIR not found" >&2; exit 2; fi
items=()
for f in "$MODELS_DIR"/**/*.zip "$MODELS_DIR"/*.zip; do
  [ -f "$f" ] || continue
  name=$(basename "$f" .zip)
  sha=$(sha256sum "$f" | awk '{print $1}')
  items+=("{\"name\": \"$name\", \"url\": \"\", \"sha256\": \"$sha\"}")
done
printf "%s\n" "[${items[*]}]" | jq '.' > "$OUT"
echo "Wrote $(jq length $OUT) entries to $OUT"
