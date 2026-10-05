# Darnassus: later-expansion trainer recreations

18 additions from the same 5.4.8 source snapshot used for Orgrimmar and
Stormwind, with original names/titles, matching Wrath curricula, 18 player-style
outfits and checked placements. Existing stock trainers are retained.

## Installation

Apply `data/sql/db-world/base/darnassus_trainers.sql` after
`custom_npc_appearances.sql` for a fresh world database. Existing installs use
`data/sql/db-world/updates/2026_10_05_04_darnassus_trainers.sql` through the module updater.
The four city updates run Ironforge → Darnassus → Thunder Bluff → Undercity.
Restart worldserver afterward to reload templates, equipment, addons and spawns.

SQL supports both `creature.id` and `creature.id1`. Reapplication preserves
spawn GUIDs and per-spawn appearance overrides. Placement updates are limited
to this city's reserved entries, map and bounds; copies outside those bounds,
unrelated outfits and previously installed city rosters are preserved.

## Roster

| Custom entry | Source entry | Name | Service | Appearance | Wrath X, Y, Z | X/Y move (m) |
|---|---|---|---|---|---|---|
| 4000300 | 50497 | Huntsman Blake | Hunter Trainer | Custom outfit | 10272.400, 2437.890, 1336.310 | 0.000 |
| 4000301 | 50498 | Loren the Fence | Rogue Trainer | Custom outfit | 10307.400, 2455.990, 1337.070 | 0.000 |
| 4000302 | 50499 | Myriam Spellwaker | Mage Trainer | Custom outfit | 10298.900, 2418.190, 1336.350 | 0.000 |
| 4000303 | 50500 | Sergeant Cleese | Warrior Trainer | Custom outfit | 10275.800, 2440.530, 1336.180 | 0.000 |
| 4000304 | 50501 | Sister Almyra | Priest Trainer | Custom outfit | 10284.100, 2449.100, 1336.340 | 0.000 |
| 4000305 | 50502 | Vitus Darkwalker | Warlock Trainer | Custom outfit | 10301.800, 2418.080, 1335.830 | 0.000 |
| 4000306 | 50504 | Belysra Starbreeze | Priestess of the Moon | Custom outfit | 10282.200, 2446.660, 1336.370 | 0.918 |
| 4000307 | 50505 | Lyros Swiftwind | Druid Trainer | Custom outfit | 10280.300, 2428.950, 1337.680 | 1.480 |
| 4000308 | 50506 | Talran of the Wild | Druid Trainer | Custom outfit | 10286.100, 2412.170, 1335.790 | 0.000 |
| 4000309 | 50507 | Vassandra Stormclaw | Druid Trainer | Custom outfit | 10282.300, 2424.130, 1337.530 | 2.620 |
| 4000310 | 50690 | Tarelvir | Mage Trainer | Custom outfit | 9638.500, 2608.040, 1338.210 | 0.000 |
| 4000311 | 50714 | Dyrhara | Mage Trainer | Custom outfit | 9629.120, 2609.460, 1337.590 | 0.000 |
| 4000312 | 50715 | Maelir | Mage Trainer | Custom outfit | 9631.830, 2605.410, 1337.640 | 0.000 |
| 4000313 | 52292 | Droha | Shaman Trainer | Custom outfit | 9654.440, 2510.810, 1332.030 | 0.000 |
| 4000314 | 52636 | Tana Lentner | Engineering Trainer | Human approximation | 10132.000, 2423.560, 1332.580 | 0.000 |
| 4000315 | 52640 | Rolf Karner | Blacksmithing Trainer | Human approximation | 9923.400, 2309.810, 1331.380 | 0.000 |
| 4000316 | 52642 | Foreman Pernic | Mining Trainer | Human approximation | 10119.800, 2416.360, 1322.000 | 0.000 |
| 4000317 | 52645 | Aessa Silverdew | Jewelcrafting Trainer | Custom outfit | 10145.000, 2356.480, 1332.240 | 0.000 |

## Placement checks

The Howling Oak itself is absent from Wrath. Its trainer group remains together on reachable ground at the same city footprint, with heights corrected to the older terrain. Belysra, Lyros and Vassandra move less than 3 m; all other NPCs retain source X/Y. Source facing is retained. The mage group, Droha and profession trainers keep their original neighborhoods.

Coordinates were checked against Wrath dry-ground navigation data, including a
complete path from a stock city trainer on the same connected ground. Moved
points are inset from navigation edges. Stored Z is navigation height +0.10 m.
This checks geometry and reachability; an in-game visual walkthrough is still needed.

## Appearance and service limits

Armor uses native build-12340 item display IDs. Held weapons use native
`Item.dbc` item entries. Clothing textures and customization are retained where
available; each substitution is recorded in the JSON roster. Modern cosmetics,
source spell auras and newer profession spells are not imported. Profession
trainers use the matching full Wrath curricula through skill 450. Class trainers
use the relevant native class curriculum and gossip, including class restrictions.

Tana, Rolf and Foreman Pernic use human-form approximations because their modern
worgen models are absent. The source has no separate human displays for them;
human face/hair choices are explicitly approximate. Tana retains an engineering
monocle shape with native red lenses. Gilnean clothing is approximated with
native formal wear and coordinated red/brown/black robes. Huntsman Blake uses
a Pilgrim hat and native rifle 25270 in place of his later top hat and rifle 52052.
Sergeant Cleese wears native blue mail; the unavailable Gilneas tabard is omitted.
Droha's purple belt and glove layers have documented native approximations.
Belysra remains a priest trainer despite her Priestess of the Moon title.

Hammon the Jaded is excluded because archaeology has no Wrath training system.

## Sources and validation

Names, source entries, roles, equipment and positions:
[SkyFire 5.4.8 database release 24.001](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001).
Appearance reference:
[ZAM model metadata](https://wow.zamimg.com/modelviewer/cata/meta/npc/29960.json),
with per-NPC display references and original customization in
[`data/npcs/darnassus_trainers.json`](../data/npcs/darnassus_trainers.json).
Assets were matched using [verified asset filenames](https://github.com/wowdev/wow-listfile)
and native DBCs/navigation from [AzerothCore data v20](https://github.com/wowgaming/client-data/releases/tag/v20.0).

[Belysra’s documented priest role](https://warcraft.wiki.gg/wiki/Belysra_Starbreeze) resolves her generic source trainer class.

```bash
python3 tools/generate_city_trainers.py --check
python3 -m unittest discover -s tests -p 'test_*.py'
```

Native race, gender, player customization, NPC-only skin, armor and weapon IDs
were checked against build 12340. SQL installation/reapplication was tested in
isolated MariaDB fixtures for both creature-entry schemas, including previously
installed cities, spawn overrides and outside-city copies.

In game, visit the listed coordinates, inspect appearances with outfits enabled
and disabled, and test training on matching/non-matching classes. Inspect the
Howling Oak footprint, platform levels and native Dark Iron costumes where relevant.
