#!/usr/bin/env bash
# upload_to_gdrive.sh
# Upload models using rclone. Configure rclone remote first (e.g., 'gdrive')
if [ $# -lt 2 ]; then echo "Usage: $0 <rclone-remote-name> <remote-path> [models_dir]" >&2; exit 2; fi
REMOTE=$1
REMOTE_PATH=$2
MODELS_DIR=${3:-models}
if ! command -v rclone >/dev/null 2>&1; then echo "rclone not found" >&2; exit 2; fi
rclone copy "$MODELS_DIR" "${REMOTE}:$REMOTE_PATH" --progress
