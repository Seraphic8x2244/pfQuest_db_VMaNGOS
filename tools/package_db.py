#!/usr/bin/env python3
from pathlib import Path
import argparse
import datetime

CORE_FILES = [
    "items.lua",
    "units.lua",
    "objects.lua",
    "refloot.lua",
    "quests-itemreq.lua",
    "quests.lua",
    "meta.lua",
]

ENUS_FILES = ["items.lua", "units.lua", "objects.lua", "quests.lua"]

def rewrite(text):
    return text.replace("pfDB", "pfQuest_db_VMaNGOS_data")

def lua_quote(value):
    value = value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
    return '"' + value + '"'

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True)
    parser.add_argument("--repo-root", required=True)
    parser.add_argument("--overwrites", required=True)
    parser.add_argument("--vmangos-release", required=True)
    parser.add_argument("--vmangos-asset", required=True)
    parser.add_argument("--vmangos-snapshot", required=True)
    parser.add_argument("--vmangos-core", required=True)
    parser.add_argument("--pfquest-commit", required=True)
    args = parser.parse_args()

    source = Path(args.source)
    root = Path(args.repo_root)
    db = root / "db"
    enus = db / "enUS"
    db.mkdir(parents=True, exist_ok=True)
    enus.mkdir(parents=True, exist_ok=True)

    (db / "init.lua").write_text(
        """pfQuest_db_VMaNGOS_data = {
  ["items"] = {},
  ["units"] = {},
  ["objects"] = {},
  ["quests"] = {},
  ["quests-itemreq"] = {},
  ["refloot"] = {},
  ["meta"] = {},
}
""",
        encoding="utf-8",
    )

    for name in CORE_FILES:
        src = source / name
        if not src.exists():
            raise SystemExit("Missing extractor output: " + str(src))
        (db / name).write_text(
            rewrite(src.read_text(encoding="utf-8")),
            encoding="utf-8",
        )

    for name in ENUS_FILES:
        src = source / "enUS" / name
        if not src.exists():
            raise SystemExit("Missing enUS extractor output: " + str(src))
        (enus / name).write_text(
            rewrite(src.read_text(encoding="utf-8")),
            encoding="utf-8",
        )

    overwrites = Path(args.overwrites).read_text(encoding="utf-8")
    (db / "overwrites.lua").write_text(
        rewrite(overwrites),
        encoding="utf-8",
    )

    generated = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat()
    fields = [
        ("schema", "1"),
        ("generated", "true"),
        ("generated_utc", lua_quote(generated)),
        ("vmangos_release", lua_quote(args.vmangos_release)),
        ("vmangos_asset", lua_quote(args.vmangos_asset)),
        ("vmangos_snapshot", lua_quote(args.vmangos_snapshot)),
        ("vmangos_core_commit", lua_quote(args.vmangos_core)),
        ("pfquest_commit", lua_quote(args.pfquest_commit)),
    ]

    lines = ["pfQuest_db_VMaNGOS_source = {"]
    for key, value in fields:
        lines.append('  ["' + key + '"] = ' + value + ",")
    lines.append("}")
    lines.append("")

    (root / "source.lua").write_text("\n".join(lines), encoding="utf-8")

if __name__ == "__main__":
    main()
