# Development Progress

## Current
- Branch: `dev`
- Version: `0.1.2-dev`
- Development head: `22e7c4a63536abedc2533a4033b0dfdf9b3b5ecf`
- Stable baseline: None.
- Goal: Build a database-only companion for brues' pfQuest that regenerates Vanilla world data from current VMaNGOS sources.
- Current scope boundary: VMaNGOS DB only. No Turtle support, no pfQuest fork, no UI/gameplay features.

## Current Design / Development Contract

### Architecture / Ownership
- `pfQuest` remains wholly owned/updated by brues; this repository never modifies or redistributes a pfQuest fork.
- This addon loads after `pfQuest` via `## Dependencies: pfQuest`.
- Generated DB files write into `pfQuest_vMangosDB_data`, never directly into `pfDB`.
- `loader.lua` replaces relevant existing pfQuest tables in place, preserving table identity for pfQuest modules that cached references during startup.
- After replacement, the loader calls `pfDatabase:Reload()`, then rebuilds name/static-reject indexes when those hooks exist.
- Heavy extraction is performed by GitHub Actions/MariaDB; local MariaDB is not required for normal users.

### Invariants
- Never replace brues' ClassicAPI-owned zone, minimap-size, or area-trigger geometry data.
- Never add Turtle-specific data to this repository.
- Never require a modified pfQuest install.
- Preserve brues' current `overwrites.lua` corrections after extraction.
- If no generated DB is present, the addon no-ops rather than clearing pfQuest data.

### Protocol / Data Model
- Generated namespace: `pfQuest_vMangosDB_data`.
- Source metadata: `pfQuest_vMangosDB_source`.
- Schema version: 1.
- Replaced datasets: items, units, objects, quests, quests-itemreq, refloot, meta.
- Current packaged locale: enUS.
- Excluded generated datasets: zones, minimap, areatrigger, professions.

### Active Decisions
- VMaNGOS snapshot source: GitHub release tag `db_latest`.
- Generated source snapshot: `Development Database Snapshot (2026-09-06)`, asset `db-13b49dc.zip`, snapshot id `13b49dc`.
- Generated VMaNGOS core commit: `4b350a09fca8b5797975e343ae6300fbb5f9937b`.
- Generated brues pfQuest commit: `6b2283f7a53ba92c83c21a13eb7f7b9ca3b53658`.
- brues' extractor is patched only inside the temporary CI clone to disable its TBC expansion entry.
- Current CI uses Lua 5.3 for the extractor because the current pfQuest extractor requires language/runtime behaviour beyond the original Lua 5.1 setup.
- Only currently valid extractor-performance indexes are created; obsolete VMaNGOS spawn-entry indexes are not used.

## Recent Relevant Commits
- `22e7c4a` — fixed VMaNGOS snapshot-id parsing, corrected current source metadata, bumped to `0.1.2-dev`, and added `DB_DIFF_REPORT.md`.
- `6498480` — generated and committed the first VMaNGOS DB refresh; bumped to `0.1.1-dev`.
- `7350bfb` — started the optimized regeneration path independently.
- `1a331b6` — applied valid current extractor performance indexes.
- `3acf071` / `71cd6d9` — switched extractor execution to Lua 5.3.
- `2fba2c5` — removed obsolete extractor-only indexes.
- `161b26b` — added MariaDB client compatibility library.
- `4ace485` — added automated VMaNGOS regeneration.
- `4f62a3b` — added safe pfQuest database overlay runtime scaffold.
- `2062ab3` — established development handoff state.
- `d8d78ea` — added canonical development rulebook.
- `30a839c` — initialized main repository.

## Completed / User-Verified
- Architecture agreed: one `pfQuest_vMangosDB` companion repository; Turtle explicitly excluded.
- All regeneration/runtime tooling from this development session is persisted on the `dev` branch; it does not depend on chat context.

## Implemented / Awaiting Runtime Test
- Safe in-place runtime DB overlay.
- VMaNGOS snapshot download/import.
- Current VMaNGOS migrations.
- Current brues pfQuest extractor execution.
- Vanilla-only extractor patching in the temporary CI clone.
- Generated-data namespace rewrite and brues overwrite reapplication.
- Generated DB validation.
- Automatic dev patch version bump on DB refresh.
- Automatic commit of generated DB back to `dev`.
- First successful full GitHub Actions regeneration:
  - Run: `36321208408`
  - Result: success.
  - Generated at: `2026-09-27T13:24:16+00:00`
  - DB commit: `64984801331bf589fe63651efd66790a3a093c36`
- Snapshot metadata parser fixed:
  - `db-13b49dc.zip` now parses as `13b49dc`.
  - Current `source.lua` metadata corrected without regenerating unchanged DB content.
- Generated-vs-bundled DB review completed and recorded in `DB_DIFF_REPORT.md`.
- Exact first SoloCraft test build prepared: `0.1.2-dev` / `22e7c4a63536abedc2533a4033b0dfdf9b3b5ecf`.

## Static / Automated Checks
- Full remote MariaDB import/extractor pipeline completed successfully for the underlying generated DB.
- Generated DB validation completed successfully in CI.
- Loader/source Lua syntax smoke tests completed in the successful regeneration workflow.
- Source inspection confirmed brues' database reload/index rebuild hooks and ClassicAPI-owned geometry paths.
- Snapshot parser expression independently checked against `db-13b49dc.zip` and returns `13b49dc`.
- Diff review confirms quest ID coverage is unchanged at 4,433; the largest delta is object coverage plus coordinate/source mappings.
- No redundant full regeneration was run for `0.1.2-dev`; the DB payload is the already-validated `6498480` output and this revision changes parser/source metadata plus documentation only.

## Current Issues
- No in-game runtime test has occurred.
- The fixed snapshot parser has not yet been exercised by a fresh full regeneration run; the current metadata value was corrected directly from the known asset name.
- Only enUS locale data is packaged in the initial development build.

## Testing

### Last Runtime Test
- Version/commit: None.
- Passed: None.
- Failed: None.
- Not tested: All in-game behaviour.

### Next Runtime Test
1. Install exact `0.1.2-dev` / `22e7c4a63536abedc2533a4033b0dfdf9b3b5ecf` as folder `pfQuest_vMangosDB` beside current brues pfQuest on SoloCraft.
2. Confirm login completes with no Lua errors.
3. Confirm pfQuest browser/search still works.
4. Check several NPC/object/quest locations, prioritizing objects because that is the largest DB delta.
5. Confirm quest display/tracking still works on at least one active quest.
6. Confirm ClassicAPI map/zone behaviour is unchanged.
7. Record the result against this exact version/commit before any further addon-affecting revision.

## Planned / Next Work
- Runtime-test `0.1.2-dev` on SoloCraft.
- Exercise the fixed snapshot parser in the next real regeneration.
- Add other locales after the regeneration/runtime path is proven.
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
Install and test exact `0.1.2-dev` / `22e7c4a63536abedc2533a4033b0dfdf9b3b5ecf` on SoloCraft, then record the point-by-point runtime result before any promotion to `main`.
