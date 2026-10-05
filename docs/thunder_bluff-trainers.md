# Thunder Bluff: later-expansion trainer recreations

13 additions from the same 5.4.8 source snapshot used for Orgrimmar and
Stormwind, with original names/titles, matching Wrath curricula, 13 player-style
outfits and checked placements. Existing stock trainers are retained.

## Installation

Apply `data/sql/db-world/base/thunder_bluff_trainers.sql` after
`custom_npc_appearances.sql` for a fresh world database. Existing installs use
`data/sql/db-world/updates/2026_10_05_05_thunder_bluff_trainers.sql` through the module updater.
The four city updates run Ironforge → Darnassus → Thunder Bluff → Undercity.
Restart worldserver afterward to reload templates, equipment, addons and spawns.

SQL supports both `creature.id` and `creature.id1`. Reapplication preserves
spawn GUIDs and per-spawn appearance overrides. Placement updates are limited
to this city's reserved entries, map and bounds; copies outside those bounds,
unrelated outfits and previously installed city rosters are preserved.

## Roster

| Custom entry | Source entry | Name | Service | Appearance | Wrath X, Y, Z | X/Y move (m) |
|---|---|---|---|---|---|---|
| 4000400 | 43001 | Sunwalker Reha | Paladin Trainer | Custom outfit | -1402.110, -142.964, 159.665 | 0.000 |
| 4000401 | 43004 | Seer Kaya | Priest Trainer | Custom outfit | -1036.790, -302.023, 159.380 | 0.000 |
| 4000402 | 43795 | Aponi Brightmane | Paladin Trainer | Custom outfit | -1405.440, -146.394, 159.608 | 0.000 |
| 4000403 | 43796 | Tahu Sagewind | Priest Trainer | Custom outfit | -1068.490, -295.332, 159.235 | 0.000 |
| 4000404 | 43870 | Seer Beryl | Priest Trainer | Custom outfit | -1042.560, -269.509, 159.380 | 0.000 |
| 4000405 | 43881 | Delano Morisett | Warlock Trainer | Custom outfit | -945.639, 253.208, 97.589 | 0.000 |
| 4000406 | 43883 | Jensen Thomasson | Warlock Trainer | Custom outfit | -954.092, 247.661, 98.075 | 0.000 |
| 4000407 | 43892 | Morairania Horton | Warlock Trainer | Custom outfit | -953.965, 255.233, 97.857 | 0.000 |
| 4000408 | 51638 | Garn Cloudsong | Shaman Trainer | Custom outfit | -980.775, 269.899, 137.822 | 0.000 |
| 4000409 | 51639 | Kador Cloudsong | Shaman Trainer | Custom outfit | -980.841, 287.174, 137.822 | 0.000 |
| 4000410 | 51640 | Lama Cloudsong | Shaman Trainer | Custom outfit | -996.925, 278.464, 137.822 | 0.000 |
| 4000411 | 52651 | Engineer Palehoof | Engineering Trainer | Custom outfit | -1264.730, 140.592, 132.770 | 0.000 |
| 4000412 | 52657 | Nahari Cloudchaser | Jewelcrafting Trainer | Custom outfit | -1225.760, 153.337, 133.570 | 0.000 |

## Placement checks

All thirteen retain the source X/Y and facing. Paladins remain on Hunter Rise, priests on Elder Rise, the Forsaken warlocks below Spirit Rise, shamans on Spirit Rise, and profession trainers on the main bluff. Heights are corrected to their original levels; the warlocks are not lifted onto the shaman platform.

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

All thirteen use player-style outfits with source race/gender and native
customization. Aponi's later hammer 58164 is replaced by native Northrend
hammer 35724. Existing Wrath Aponi elsewhere remains intact. Tahu's gloves,
Lama's white boots/gloves, Palehoof's tunic and Nahari's blue robe use native
texture equivalents where available.

Otoh Greyhide is excluded because archaeology has no Wrath training system.

## Sources and validation

Names, source entries, roles, equipment and positions:
[SkyFire 5.4.8 database release 24.001](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001).
Appearance reference:
[ZAM model metadata](https://wow.zamimg.com/modelviewer/cata/meta/npc/33524.json),
with per-NPC display references and original customization in
[`data/npcs/thunder_bluff_trainers.json`](../data/npcs/thunder_bluff_trainers.json).
Assets were matched using [verified asset filenames](https://github.com/wowdev/wow-listfile)
and native DBCs/navigation from [AzerothCore data v20](https://github.com/wowgaming/client-data/releases/tag/v20.0).

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
