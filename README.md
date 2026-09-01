NeuroTranslator — quickstart

This repository contains scripts and instructions to work with NeuroTranslator.

Quickstart
1) Clone this repo and create a virtual env:
   python -m venv venv
   venv\Scripts\Activate.ps1   # Windows PowerShell
   source venv/bin/activate     # macOS/Linux
2) Install runtime deps (if any):
   ./scripts/install_deps.ps1    # or ./scripts/install_deps.sh
3) Download models (example):
   ./scripts/download_models.ps1 -ModelsFile scripts/models.json.sample
   ./scripts/compute_checksums.ps1 models models.json  # compute checksums locally

Model management
- Compute checksums for local archives: scripts/compute_checksums.(ps1|sh)
- Upload archives to S3: scripts/upload_to_s3.(ps1|sh)
- Upload archives to Google Drive via rclone: scripts/upload_to_gdrive.(ps1|sh)

Notes
- For S3 upload, configure AWS CLI and provide a bucket name.
- For Google Drive, configure rclone remote first (see rclone docs).
