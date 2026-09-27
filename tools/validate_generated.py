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

data_checks = {
    "db/items.lua": '["items"]',
    "db/units.lua": '["units"]',
    "db/objects.lua": '["objects"]',
    "db/quests.lua": '["quests"]',
}

for rel, suffix in data_checks.items():
    text = (root / rel).read_text(encoding="utf-8")
    markers = (
        'pfQuest_db_VMaNGOS_data' + suffix,
        'pfQuest_vMangosDB_data' + suffix,
    )
    if not any(marker in text for marker in markers):
        raise SystemExit("Expected companion namespace marker missing from " + rel)

source = (root / "source.lua").read_text(encoding="utf-8")
if '["generated"] = true' not in source:
    raise SystemExit("Expected generated source marker missing from source.lua")

toc = (root / "pfQuest_db_VMaNGOS.toc").read_text(encoding="utf-8")
for forbidden in ("zones.lua", "minimap.lua", "areatrigger.lua", "professions.lua"):
    if forbidden in toc:
        raise SystemExit("ClassicAPI-owned dataset unexpectedly loaded by TOC: " + forbidden)

print("Generated database validation passed.")
