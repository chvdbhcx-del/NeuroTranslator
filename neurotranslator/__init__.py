"""NeuroTranslator model toolkit.

A small, dependency-free command line interface that wraps the model
management scripts shipped in this repository: downloading and verifying
Vosk model archives (SHA-256) and computing checksums.

The CLI intentionally uses only the Python standard library so it can be
packaged into a single self-contained executable (``.exe``) with PyInstaller.
"""

__version__ = "0.1.0"
