# Development Progress

## Current
- Branch: `dev`
- Version: `0.1.0-dev`
- Development head: `d8d78eaeb284f9986a0d2702269f7ab89260560f`
- Stable baseline: None.
- Goal: Build a database-only companion for brues' pfQuest that regenerates Vanilla world data from current VMaNGOS sources.
- Current scope boundary: VMaNGOS DB only. No Turtle support, no pfQuest fork, no UI/gameplay features.

## Current Design / Development Contract

### Architecture / Ownership
- `pfQuest` remains wholly owned/updated by brues; this repository never modifies or redistributes a pfQuest fork.
- This addon loads after `pfQuest` via `## Dependencies: pfQuest`.
- Generated DB files write into `pfQuest_vMangosDB_data`, never directly into `pfDB`.
- Runtime application replaces relevant existing pfQuest tables in place, preserving table identity for pfQuest modules that cached references during startup.
- After replacement, rebuild pfQuest's DB shortcuts and derived indexes.
- Heavy extraction is performed by GitHub Actions/MariaDB; local MariaDB is not required for normal users.

### Invariants
- Never replace brues' ClassicAPI-owned zone, minimap-size, or area-trigger geometry data.
- Never add Turtle-specific data to this repository.
- Never require a modified pfQuest install.
- Preserve brues' current `overwrites.lua` corrections after extraction.
- If no generated DB is present, the development addon must no-op rather than clearing pfQuest data.

### Protocol / Data Model
- Generated namespace: `pfQuest_vMangosDB_data`.
- Source metadata: `pfQuest_vMangosDB_source`.
- Schema version: 1.
- Replaced datasets: items, units, objects, quests, quests-itemreq, refloot, meta.
- Localized entity/quest text comes from extractor locale outputs.
- Excluded generated datasets: zones, minimap, areatrigger, professions.

### Active Decisions
- VMaNGOS snapshot source: GitHub release tag `db_latest`.
- Current observed snapshot: `Development Database Snapshot (2026-09-06)`, asset `db-13b49dc.zip`.
- Current observed brues pfQuest head: `6b2283f7a53ba92c83c21a13eb7f7b9ca3b53658` (2026-09-08).
- Current observed VMaNGOS development head: `4b350a09fca8b5797975e343ae6300fbb5f9937b` (2026-09-15).
- brues' extractor will be patched only inside the temporary CI clone to disable its TBC expansion entry.

## Recent Relevant Commits
- `30a839c` — initialize main repository.
- `d8d78ea` — add canonical development rulebook.

## Completed / User-Verified
- Architecture agreed: one `pfQuest_vMangosDB` companion repository; Turtle explicitly excluded.

## Implemented / Awaiting Runtime Test
- Development workflow documentation only.
- Runtime loader and updater tooling not yet committed.

## Static / Automated Checks
- Source inspection confirmed brues' database reload/index rebuild hooks and ClassicAPI-owned geometry paths.
- Local full extractor run unavailable in the chat environment because MariaDB/LuaSQL packages could not be installed from blocked Debian mirrors.

## Current Issues
- First CI extraction may expose dependency/schema drift.
- No generated DB exists yet.
- No in-game runtime test has occurred.

## Testing

### Last Runtime Test
- Version/commit: None.
- Passed: None.
- Failed: None.
- Not tested: All runtime behaviour.

### Next Runtime Test
1. Produce a non-empty generated DB on `dev`.
2. Install exact generated `dev` build beside current brues pfQuest.
3. Confirm login has no Lua errors.
4. Confirm pfQuest browser/search still works.
5. Compare known NPC/object/quest locations against stock brues DB.
6. Confirm ClassicAPI map/zone behaviour is unchanged.

## Planned / Next Work
- Commit runtime scaffold and safe in-place DB loader.
- Commit reproducible VMaNGOS extraction/package tooling.
- Add GitHub Actions updater and inspect its first run.
- Produce a DB diff summary against brues' bundled database.
- Runtime-test on SoloCraft.
- Promote a tested build to `main`.

## Deferred / Out of Scope
- TurtleWoW database support.
- Learner/observation database.
- pfQuest UI/features.
- Changes to brues' pfQuest repository.

## Release / Promotion Notes
- Main-only or release-only content to preserve: stable README/addon files once first release is accepted.
- Known validation debt accepted for release: None.
- External/runtime prerequisites: brues-code/pfQuest and its required ClassicAPI setup.

## Exact Next Step
Commit the runtime scaffold and loader, then add the automated VMaNGOS regeneration pipeline.
