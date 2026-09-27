#!/usr/bin/env python3
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

match = re.search(
    r"^## Version: (\d+)\.(\d+)\.(\d+)-dev$",
    text,
    re.MULTILINE,
)
if not match:
    raise SystemExit("Development version line not found")

major, minor, patch = (int(match.group(i)) for i in range(1, 4))
new_version = f"{major}.{minor}.{patch + 1}-dev"

text = text[:match.start()] + "## Version: " + new_version + text[match.end():]
path.write_text(text, encoding="utf-8")
print(new_version)
