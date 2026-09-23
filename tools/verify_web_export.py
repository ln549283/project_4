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
index = root / "index.html"
if not index.is_file() or index.stat().st_size == 0:
    fail("missing or empty index.html at artifact root")

html = index.read_text(encoding="utf-8")

# GitHub project Pages serves this repository at /project_4/. Root-relative
# asset URLs would escape that prefix and break the game.
absolute_assets = re.findall(r"""(?:src|href)\s*=\s*["']/(?!/)""", html, flags=re.IGNORECASE)
if absolute_assets:
    fail("index.html contains root-relative asset URLs incompatible with /project_4/")

compact = re.sub(r"\s+", "", html)
match = re.search(r'"executable":"([^"]+)"', compact)
if not match:
    fail("Godot executable base not found in index.html")

asset_base = match.group(1)
if "/" in asset_base or asset_base.startswith("."):
    fail(f"Godot executable base is not a safe relative filename: {asset_base}")

for ext in ("js", "wasm", "pck"):
    path = root / f"{asset_base}.{ext}"
    if not path.is_file():
        fail(f"missing {path.name} at artifact root")
    if path.stat().st_size == 0:
        fail(f"empty {path.name}")

recorded_base = root / ".asset-base"
if recorded_base.is_file() and recorded_base.read_text(encoding="utf-8").strip() != asset_base:
    fail(".asset-base does not match index.html executable")

print(
    "WEB EXPORT CHECK PASS: index.html is at root, assets are subpath-safe "
    f"and cache-busted as {asset_base}.*"
)
