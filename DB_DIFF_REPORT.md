# DB Diff Report

Comparison target:

- Regenerated DB: VMaNGOS snapshot `db-13b49dc.zip` (`13b49dc`), generated in commit `64984801331bf589fe63651efd66790a3a093c36`.
- Bundled baseline: brues-code/pfQuest commit `6b2283f7a53ba92c83c21a13eb7f7b9ca3b53658`.
- Method: record-by-record comparison of the generated datasets that this companion replaces. Namespace-only `pfDB` -> `pfQuest_vMangosDB_data` differences are ignored conceptually.
- brues' `overwrites.lua` is preserved exactly apart from that namespace rewrite.

## Record summary

| Dataset | Generated | Bundled | Added | Missing vs bundled | Changed same ID |
| --- | ---: | ---: | ---: | ---: | ---: |
| items | 17,707 | 17,712 | 0 | 5 | 1,782 |
| units | 10,382 | 10,385 | 0 | 3 | 1,102 |
| objects | 9,368 | 8,985 | 536 | 153 | 326 |
| quests | 4,433 | 4,433 | 0 | 0 | 84 |
| quests-itemreq | 180 | 180 | 0 | 0 | 18 |
| refloot | 601 | 601 | 0 | 0 | 6 |
| enUS items | 17,707 | 17,712 | 0 | 5 | 14 |
| enUS units | 10,382 | 10,385 | 0 | 3 | 11 |
| enUS objects | 9,327 | 8,944 | 536 | 153 | 27 |
| enUS quests | 4,433 | 4,433 | 0 | 0 | 1 |

## Where the changes are concentrated

- Items: 1,698 changed object-source mappings (`O`), 83 unit-source mappings (`U`), and 1 vendor mapping (`V`).
- Units: 1,022 changed coordinate sets, 71 rank changes, 13 faction changes, and 8 level changes.
- Objects: 209 changed coordinate sets and 117 faction changes.
- Quests: 74 prerequisite changes, 6 start-source changes, 2 objective changes, and 2 race-mask changes.
- Refloot: 5 object-source changes and 1 unit-source change.
- Meta still has 16 top-level categories. Notable regenerated changes include 63 flight entries where the bundled DB has none, plus additional chest/mine/mailbox metadata.

## Stock-only examples

The five bundled item IDs absent from the regenerated Vanilla set are:

- 20470 — Solanian's Scrying Orb
- 20472 — Solanian's Journal
- 20474 — Sunstrider Book Satchel
- 20482 — Arcane Sliver
- 20483 — Tainted Arcane Sliver

The three bundled unit IDs absent from the regenerated set are 15547 (Vam), 21000 (Ragnaros Submerged Visual), and 21010 (AQ War Cenarion Hold Wave Trigger).

Object churn is materially larger: 536 generated-only object IDs and 153 bundled-only IDs. That is the main area to exercise in-game.

## Review outcome

- Quest ID coverage is unchanged at 4,433.
- The dominant delta is world-object coverage, coordinates, and loot/source relationships rather than wholesale quest loss.
- ClassicAPI-owned zones, minimap sizes, and area-trigger geometry are not part of this replacement and are therefore outside this diff.
- The first SoloCraft runtime test should focus on login/load safety, pfQuest search/browser behaviour, several NPC/object/quest location checks, and unchanged ClassicAPI map behaviour.
