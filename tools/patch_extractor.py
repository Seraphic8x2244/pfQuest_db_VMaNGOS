#!/usr/bin/env python3
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

pattern = re.compile(
    r'\n\s*\{\s*\n\s*name\s*=\s*"tbc",.*?\n\s*\},',
    re.DOTALL,
)
updated, count = pattern.subn("", text, count=1)

if count != 1:
    raise SystemExit("Could not locate the TBC expansion block in pfQuest extractor.lua")

path.write_text(updated, encoding="utf-8")
print("Patched pfQuest extractor to Vanilla-only mode.")
