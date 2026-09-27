# Development Progress

## Current
- Branch: `dev`
- Version: `0.1.3-dev`
- Development head: `77c418b49d5c1f2049a7ee10df311790cb7e2326`
- Stable baseline: None.
- Repository/addon identity: `pfQuest_db_VMaNGOS`.
- Goal: Build a database-only companion for brues' pfQuest that regenerates Vanilla world data from current VMaNGOS sources.
- Current scope boundary: current VMaNGOS DB only. No SoloCraft-specific historical DB, Turtle support, pfQuest fork, or UI/gameplay features.

## Current Design / Development Contract

### Architecture / Ownership
- `pfQuest` remains wholly owned/updated by brues; this repository never modifies or redistributes a pfQuest fork.
- This addon loads after `pfQuest` via `## Dependencies: pfQuest`.
- Public generated namespace: `pfQuest_db_VMaNGOS_data`.
- Source metadata: `pfQuest_db_VMaNGOS_source`.
- `loader.lua` replaces relevant existing pfQuest tables in place, preserving table identity for pfQuest modules that cached references during startup.
- After replacement, the loader calls `pfDatabase:Reload()`, then rebuilds name/static-reject indexes when those hooks exist.
- Heavy extraction is performed by GitHub Actions/MariaDB; local MariaDB is not required for normal users.
- The current validated `13b49dc` payload is reused unchanged. Its generated files still target the former `pfQuest_vMangosDB_data` symbol, so `db/init.lua` supplies a compatibility alias to the new namespace. The next real DB regeneration will emit `pfQuest_db_VMaNGOS_data` directly and naturally remove that transitional dependency.

### Invariants
- Never replace brues' ClassicAPI-owned zone, minimap-size, or area-trigger geometry data.
- Never add Turtle-specific data to this repository.
- Never require a modified pfQuest install.
- Preserve brues' current `overwrites.lua` corrections after extraction.
- If no generated DB is present, the addon no-ops rather than clearing pfQuest data.

### Protocol / Data Model
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
- Addon list/chat branding follows pfQuest's teal/white `pf` / `Quest` colouring.

## Recent Relevant Commits
- `77c418b` — renamed addon identity to `pfQuest_db_VMaNGOS`, bumped to `0.1.3-dev`, updated regeneration tooling/validator, and applied pfQuest-style title/chat colours without regenerating DB content.
- `7e2d14d` — documentation-only checkpoint for the previous SoloCraft test build.
- `22e7c4a` — fixed VMaNGOS snapshot-id parsing, corrected current source metadata, bumped to `0.1.2-dev`, and added `DB_DIFF_REPORT.md`.
- `6498480` — generated and committed the first VMaNGOS DB refresh; bumped to `0.1.1-dev`.
- `4ace485` — added automated VMaNGOS regeneration.
- `4f62a3b` — added safe pfQuest database overlay runtime scaffold.
- `d8d78ea` — added canonical development rulebook.

## Completed / User-Verified
- Architecture agreed: one current-VMaNGOS database companion; Turtle explicitly excluded.
- On SoloCraft, user verified the previous `0.1.2-dev` / `22e7c4a` build loaded successfully:
  - `pfQuest_vMangosDB_source ~= nil` returned `true`.
  - source snapshot reported `13b49dc`.
- User then removed that addon from the local WoW installation; the broader six-point runtime checklist was not completed.

## Implemented / Awaiting Runtime Test
- Safe in-place runtime DB overlay.
- VMaNGOS snapshot download/import and migration application.
- Current brues pfQuest extractor execution in Vanilla-only mode.
- Generated-data namespace rewrite and brues overwrite reapplication.
- Generated DB validation and automatic dev patch bump on DB refresh.
- First successful full GitHub Actions regeneration:
  - Run: `36321208408`
  - Generated at: `2026-09-27T13:24:16+00:00`
  - DB commit: `64984801331bf589fe63651efd66790a3a093c36`
- Snapshot parser fixed: `db-13b49dc.zip` parses as `13b49dc`.
- Generated-vs-bundled DB review recorded in `DB_DIFF_REPORT.md`.
- Rename build prepared: `0.1.3-dev` / `77c418b49d5c1f2049a7ee10df311790cb7e2326`.

## Static / Automated Checks
- Underlying `13b49dc` DB payload previously passed the full remote MariaDB import/extractor pipeline and generated-DB validation.
- Rename commit intentionally used `[skip ci]`; no redundant full VMaNGOS extraction was run because record payload content is unchanged.
- Diff inspection confirms generated record files were not rewritten; only `db/init.lua` adds the compatibility alias around the existing validated payload.
- Updated Python regeneration/validation scripts pass Python syntax compilation.
- TOC/source/loader/tooling changes were inspected against the committed diff.
- A fresh repository-backed Lua/compiler run was not available in this chat environment: the execution container could not resolve GitHub for checkout, and no system Lua interpreter is installed there. Do not treat the rename build as having received a new Lua 5.0.3 compiler pass.

## Current Issues
- `0.1.3-dev` has not yet been tested in game.
- The fixed snapshot parser has not yet been exercised by a fresh full regeneration run.
- Only enUS locale data is packaged.
- Transitional legacy generated-data alias remains until the next real regeneration.
- SoloCraft runtime does not fully match current VMaNGOS data. Confirmed example: item 20023 (Encoded Fragment) is Forest Ooze-only in current VMaNGOS/pfQuest data, while SoloCraft drops it from additional Azshara beasts. Upstream VMaNGOS commit `38d7360` (2023-03-14) introduced the removal of several broader drops. This is evidence for a separate SoloCraft-specific historical-data project, not a change to this repository's current-VMaNGOS contract.

## Testing

### Last Runtime Test
- Version/commit: `0.1.2-dev` / `22e7c4a63536abedc2533a4033b0dfdf9b3b5ecf` (partial).
- Passed: addon loaded; source metadata was present; snapshot was `13b49dc`.
- Observed data mismatch: Encoded Fragment source mapping differs from SoloCraft live loot behaviour.
- Not completed: full login/error, browser/search, NPC/object coverage, active quest tracking, and ClassicAPI map checklist.
- Test stopped when the user removed the old-named addon from the local installation.

### Next Runtime Test
1. Install exact `0.1.3-dev` / `77c418b49d5c1f2049a7ee10df311790cb7e2326` as folder `pfQuest_db_VMaNGOS` beside current brues pfQuest.
2. Confirm the AddOns list shows the new pfQuest-coloured `pfQuest_db_VMaNGOS` title and version `0.1.3-dev`.
3. Log in and confirm there are no Lua errors.
4. Confirm `pfQuest_db_VMaNGOS_loaded` is true and `pfQuest_db_VMaNGOS_source.vmangos_snapshot` is `13b49dc`.
5. Confirm pfQuest browser/search works normally.
6. Check several NPC and object locations, prioritizing objects.
7. Confirm at least one active quest displays/tracks normally.
8. Confirm ClassicAPI map/zone behaviour is unchanged.
9. Bind the result to this exact version/commit before promotion.

## Planned / Next Work
- Runtime-test `0.1.3-dev`.
- Exercise the fixed snapshot parser in the next real regeneration; that regeneration will also rewrite generated files directly to the new namespace.
- Add other locales after the regeneration/runtime path is proven.
- Promote `0.1.3` to `main` under the explicitly accepted validation debt above.

## Deferred / Out of Scope
- SoloCraft-specific historical VMaNGOS baseline/override database (candidate separate `pfQuest_SoloCraft` project).
- TurtleWoW database support.
- Learner/observation database.
- pfQuest UI/features.
- Changes to brues' pfQuest repository.

## Release / Promotion Notes
- Main-only or release-only content to preserve: stable README/addon files once first release is accepted.
- Known validation debt accepted for `0.1.3` promotion: the renamed `0.1.3-dev` identity has not received a fresh in-game runtime pass or fresh Lua 5.0.3 compiler pass. The underlying `13b49dc` DB payload was previously validated in CI and the preceding `0.1.2-dev` identity was partially confirmed loading on SoloCraft. User explicitly authorized promotion to `main` with this debt.
- External/runtime prerequisites: brues-code/pfQuest and its required ClassicAPI setup.

## Exact Next Step
Promote `0.1.3-dev` to stable `0.1.3` on `main` without regenerating the `13b49dc` DB payload, using a simple README that identifies VMaNGOS DB snapshot `13b49dc`; then record the resulting stable commit and runtime-test that stable tree.
