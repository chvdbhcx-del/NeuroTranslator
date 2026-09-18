"""PyInstaller entry point.

PyInstaller freezes a single script into an executable. This thin wrapper
calls into the ``neurotranslator`` package so the packaged binary behaves
exactly like ``python -m neurotranslator`` / the ``neurotranslator`` console
script.
"""

import sys

from neurotranslator.cli import main

if __name__ == "__main__":
    sys.exit(main())
