#!/usr/bin/env python3
"""Verify the Godot Web export layout expected by GitHub Pages."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"WEB EXPORT CHECK FAILED: {message}", file=sys.stderr)
    raise SystemExit(1)


root = Path(sys.argv[1] if len(sys.argv) > 1 else "build/web")
required = ("index.html", "index.js", "index.wasm", "index.pck")

for name in required:
    path = root / name
    if not path.is_file():
        fail(f"missing {name} at artifact root")
    if path.stat().st_size == 0:
        fail(f"empty {name}")

html = (root / "index.html").read_text(encoding="utf-8")

# GitHub project Pages serves this repository at /project_4/. Root-relative
# asset URLs would escape that prefix and break the game.
absolute_assets = re.findall(r"""(?:src|href)\s*=\s*["']/(?!/)""", html, flags=re.IGNORECASE)
if absolute_assets:
    fail("index.html contains root-relative asset URLs incompatible with /project_4/")

# Standard Godot shell must resolve its executable beside index.html.
if '"executable":"index"' not in html.replace(" ", ""):
    fail("Godot executable base is not relative 'index'")

print("WEB EXPORT CHECK PASS: index.html is at root and assets are subpath-safe")
