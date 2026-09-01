#!/usr/bin/env bash
# upload_to_s3.sh
# Usage: ./upload_to_s3.sh <s3-bucket> [models_dir]
if [ $# -lt 1 ]; then echo "Usage: $0 <s3-bucket> [models_dir]" >&2; exit 2; fi
BUCKET=$1
MODELS_DIR=${2:-models}
if ! command -v aws >/dev/null 2>&1; then echo "aws CLI not found" >&2; exit 2; fi
for f in "$MODELS_DIR"/**/*.zip "$MODELS_DIR"/*.zip; do
  [ -f "$f" ] || continue
  echo "Uploading $f to s3://$BUCKET/$(basename "$f")"
  aws s3 cp "$f" "s3://$BUCKET/$(basename "$f")" --only-show-errors
done
