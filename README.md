# pfQuest_vMangosDB

A database-only companion addon for [brues-code/pfQuest](https://github.com/brues-code/pfQuest).

It keeps pfQuest itself untouched and replaces only its VMaNGOS-derived Vanilla world database at addon load time. The database is regenerated from the latest VMaNGOS `db_latest` snapshot using brues' current pfQuest extractor.

## Goals

- keep using brues' pfQuest releases normally;
- refresh quests, units, objects, items, loot relations and related metadata from current VMaNGOS data;
- preserve brues' ClassicAPI-derived map/zone/area-trigger behaviour;
- avoid maintaining a pfQuest fork;
- make regeneration repeatable in GitHub Actions.

## Current development scope

The first development build carries the English (`enUS`) entity locale plus the full non-localized Vanilla world data. Other locales can be added after the regeneration/runtime path is proven.

The following pfQuest datasets are intentionally **not** replaced because brues' current ClassicAPI build reads them from the game client:

- zones;
- minimap world sizes;
- area-trigger geometry;
- professions.

## Install

The `dev` branch is not yet a stable release.

When a generated build is ready, the addon layout is:

```text
Interface/AddOns/
  pfQuest/
  pfQuest_vMangosDB/
```

Enable both. `pfQuest_vMangosDB` declares `pfQuest` as a dependency and loads after it.

## Database refresh

The `Update VMaNGOS DB` GitHub Actions workflow:

1. downloads VMaNGOS `db_latest`;
2. clones current VMaNGOS core and current brues pfQuest;
3. imports the VMaNGOS snapshot and pfQuest client data into MariaDB;
4. applies VMaNGOS world migrations;
5. runs brues' extractor in Vanilla-only mode;
6. rewrites generated `pfDB` assignments into the private `pfQuest_vMangosDB_data` namespace;
7. reapplies brues' current `overwrites.lua` to that generated namespace;
8. validates the result;
9. bumps the dev patch version and commits the refreshed DB to `dev` when data changed.

Normal users do not need MariaDB or the extractor toolchain.

## License

GPL-2.0. See `LICENSE`.
