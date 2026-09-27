#!/usr/bin/env python3
from pathlib import Path
import sys

root = Path(sys.argv[1])

required = [
    "db/items.lua",
    "db/units.lua",
    "db/objects.lua",
    "db/refloot.lua",
    "db/quests-itemreq.lua",
    "db/quests.lua",
    "db/meta.lua",
    "db/enUS/items.lua",
    "db/enUS/units.lua",
    "db/enUS/objects.lua",
    "source.lua",
]

for rel in required:
    path = root / rel
    if not path.exists() or path.stat().st_size == 0:
        raise SystemExit("Missing or empty generated file: " + rel)

checks = {
    "db/items.lua": 'pfQuest_vMangosDB_data["items"]',
    "db/units.lua": 'pfQuest_vMangosDB_data["units"]',
    "db/objects.lua": 'pfQuest_vMangosDB_data["objects"]',
    "db/quests.lua": 'pfQuest_vMangosDB_data["quests"]',
    "source.lua": '["generated"] = true',
}

for rel, marker in checks.items():
    text = (root / rel).read_text(encoding="utf-8")
    if marker not in text:
        raise SystemExit("Expected marker missing from " + rel + ": " + marker)

toc = (root / "pfQuest_vMangosDB.toc").read_text(encoding="utf-8")
for forbidden in ("zones.lua", "minimap.lua", "areatrigger.lua", "professions.lua"):
    if forbidden in toc:
        raise SystemExit("ClassicAPI-owned dataset unexpectedly loaded by TOC: " + forbidden)

print("Generated database validation passed.")
