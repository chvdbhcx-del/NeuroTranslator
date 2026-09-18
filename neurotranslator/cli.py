#!/usr/bin/env python3
"""NeuroTranslator command line interface.

Dependency-free (standard library only) port of the model management shell
scripts. Subcommands:

    neurotranslator download [MODELS_JSON] [--dest DIR]
    neurotranslator checksums [--models-dir DIR] [--out FILE]
    neurotranslator list [MODELS_JSON]
    neurotranslator version

``MODELS_JSON`` is an array of objects, for example::

    [
      {"name": "model_ru_small",
       "url": "https://alphacephei.com/vosk/models/vosk-model-small-ru-0.22.zip",
       "sha256": ""}
    ]

Keeping the implementation in pure Python means the same tool works on
Linux, macOS and Windows, and can be frozen into a single ``.exe`` with
PyInstaller.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import urllib.request
import zipfile

from . import __version__

# Built-in default list, mirroring scripts/models.json.sample. Used when no
# models file is supplied on the command line.
DEFAULT_MODELS = [
    {"name": "model_en", "url": "https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip", "sha256": ""},
    {"name": "model_en_large", "url": "https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip", "sha256": ""},
    {"name": "model_ru_large", "url": "https://alphacephei.com/vosk/models/vosk-model-ru-0.22.zip", "sha256": ""},
    {"name": "model_ru_small", "url": "https://alphacephei.com/vosk/models/vosk-model-small-ru-0.22.zip", "sha256": ""},
]

CHUNK = 1024 * 1024  # 1 MiB


def _eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def sha256_file(path: str) -> str:
    """Return the lowercase hex SHA-256 digest of a file."""
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(CHUNK), b""):
            h.update(chunk)
    return h.hexdigest()


def load_models(models_file: str | None) -> list[dict]:
    """Load a model list from a JSON file, or fall back to the built-in list."""
    if models_file:
        if not os.path.isfile(models_file):
            _eprint(f"Models file not found: {models_file}")
            raise SystemExit(2)
        try:
            with open(models_file, "r", encoding="utf-8") as fh:
                data = json.load(fh)
        except (OSError, json.JSONDecodeError) as exc:
            _eprint(f"Failed to parse {models_file}: {exc}")
            raise SystemExit(2)
        if not isinstance(data, list):
            _eprint(f"{models_file} must contain a JSON array of model objects")
            raise SystemExit(2)
        return data
    return list(DEFAULT_MODELS)


def _download(url: str, dest: str) -> None:
    """Stream ``url`` to ``dest`` with a simple progress indicator."""
    req = urllib.request.Request(url, headers={"User-Agent": "NeuroTranslator"})
    with urllib.request.urlopen(req) as resp, open(dest, "wb") as out:  # noqa: S310
        total = resp.headers.get("Content-Length")
        total_i = int(total) if total and total.isdigit() else 0
        done = 0
        while True:
            chunk = resp.read(CHUNK)
            if not chunk:
                break
            out.write(chunk)
            done += len(chunk)
            if total_i:
                pct = done * 100 // total_i
                print(f"\r  {done // (1024 * 1024)} / {total_i // (1024 * 1024)} MiB ({pct}%)", end="")
            else:
                print(f"\r  {done // (1024 * 1024)} MiB", end="")
        print()


def cmd_download(args: argparse.Namespace) -> int:
    models = load_models(args.models_file)
    dest = args.dest
    os.makedirs(dest, exist_ok=True)

    failures = 0
    for m in models:
        name = m.get("name")
        url = m.get("url")
        expected = (m.get("sha256") or "").lower()
        if not name:
            _eprint("Skipping entry without a name")
            continue
        if not url:
            _eprint(f"{name}: no URL, skipping")
            continue

        zip_path = os.path.join(dest, f"{name}.zip")
        out_dir = os.path.join(dest, name)
        need_download = True

        if os.path.isfile(zip_path):
            if expected:
                if sha256_file(zip_path).lower() == expected:
                    print(f"{name}: archive exists and checksum matches — skipping download")
                    need_download = False
                else:
                    print(f"{name}: checksum mismatch, re-downloading")
            else:
                print(f"{name}: archive exists but no checksum provided — skipping (remove {zip_path} to force)")
                need_download = False

        if need_download:
            print(f"Downloading {name} from {url}")
            try:
                _download(url, zip_path)
            except Exception as exc:  # noqa: BLE001 - report and continue
                _eprint(f"{name}: download failed: {exc}")
                failures += 1
                continue
            if expected:
                got = sha256_file(zip_path).lower()
                if got != expected:
                    _eprint(f"{name}: checksum verification failed (expected {expected}, got {got})")
                    try:
                        os.remove(zip_path)
                    except OSError:
                        pass
                    failures += 1
                    continue
                print(f"{name}: checksum OK")
            else:
                _eprint(f"{name}: no expected checksum provided — consider verifying manually")

        if not os.path.isdir(out_dir):
            print(f"Extracting {zip_path} -> {out_dir}")
            try:
                with zipfile.ZipFile(zip_path) as zf:
                    zf.extractall(out_dir)
            except (zipfile.BadZipFile, OSError) as exc:
                _eprint(f"{name}: extraction failed: {exc}")
                failures += 1
                continue
        else:
            print(f"{out_dir} already exists — skipping extraction")

    print(f"All done. Models are in: {os.path.abspath(dest)}")
    return 1 if failures else 0


def cmd_checksums(args: argparse.Namespace) -> int:
    models_dir = args.models_dir
    if not os.path.isdir(models_dir):
        _eprint(f"Models directory '{models_dir}' not found")
        return 2
    entries = []
    for root, _dirs, files in os.walk(models_dir):
        for fn in sorted(files):
            if fn.lower().endswith(".zip"):
                full = os.path.join(root, fn)
                entries.append({
                    "name": os.path.splitext(fn)[0],
                    "url": "",
                    "sha256": sha256_file(full),
                })
    with open(args.out, "w", encoding="utf-8") as fh:
        json.dump(entries, fh, indent=2)
        fh.write("\n")
    print(f"Wrote {len(entries)} entries to {args.out}")
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    models = load_models(args.models_file)
    for m in models:
        name = m.get("name", "<unnamed>")
        url = m.get("url") or "(no url)"
        sha = m.get("sha256") or "(no checksum)"
        print(f"{name}\n  url:    {url}\n  sha256: {sha}")
    print(f"\n{len(models)} model(s).")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="neurotranslator",
        description="NeuroTranslator model toolkit — download, verify and checksum models.",
    )
    parser.add_argument("--version", action="version", version=f"neurotranslator {__version__}")
    sub = parser.add_subparsers(dest="command")

    p_dl = sub.add_parser("download", help="download and verify model archives")
    p_dl.add_argument("models_file", nargs="?", default=None,
                      help="JSON file with the model list (defaults to the built-in list)")
    p_dl.add_argument("--dest", default="models", help="destination directory (default: models)")
    p_dl.set_defaults(func=cmd_download)

    p_cs = sub.add_parser("checksums", help="compute SHA-256 checksums for archives in a directory")
    p_cs.add_argument("--models-dir", default="models", help="directory to scan (default: models)")
    p_cs.add_argument("--out", default="models.json", help="output JSON file (default: models.json)")
    p_cs.set_defaults(func=cmd_checksums)

    p_ls = sub.add_parser("list", help="list the models in a models file")
    p_ls.add_argument("models_file", nargs="?", default=None,
                      help="JSON file with the model list (defaults to the built-in list)")
    p_ls.set_defaults(func=cmd_list)

    p_ver = sub.add_parser("version", help="print the version and exit")
    p_ver.set_defaults(func=lambda _a: (print(f"neurotranslator {__version__}") or 0))

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if not getattr(args, "func", None):
        parser.print_help()
        return 0
    return int(args.func(args) or 0)


if __name__ == "__main__":
    raise SystemExit(main())
