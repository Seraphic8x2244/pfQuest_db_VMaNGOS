# pfQuest_db_VMaNGOS

Database-only companion addon for [brues-code/pfQuest](https://github.com/brues-code/pfQuest).

It replaces pfQuest's VMaNGOS-derived Vanilla world data at load time while leaving pfQuest itself untouched.

## Database

- VMaNGOS DB snapshot: `13b49dc`
- Snapshot asset: `db-13b49dc.zip`
- VMaNGOS core commit: `4b350a09fca8b5797975e343ae6300fbb5f9937b`
- pfQuest extractor baseline: `6b2283f7a53ba92c83c21a13eb7f7b9ca3b53658`
- Locale: `enUS`

## Install

Install beside pfQuest:

```text
Interface/AddOns/
  pfQuest/
  pfQuest_db_VMaNGOS/
```

Enable both addons. `pfQuest_db_VMaNGOS` depends on pfQuest and loads after it.

The companion updates items, units, objects, quests, quest item requirements, reference loot and related metadata. It does not replace pfQuest/ClassicAPI zone, minimap-size or area-trigger geometry.

This repository tracks current upstream VMaNGOS data. Individual private servers may use older or customized world data.

## License

GPL-2.0. See `LICENSE`.
