# Undercity: later-expansion trainer recreations

5 additions from the same 5.4.8 source snapshot used for Orgrimmar and
Stormwind, with original names/titles, matching Wrath curricula, 5 player-style
outfits and checked placements. Existing stock trainers are retained.

## Installation

Apply `data/sql/db-world/base/undercity_trainers.sql` after
`custom_npc_appearances.sql` for a fresh world database. Existing installs use
`data/sql/db-world/updates/2026_10_05_06_undercity_trainers.sql` through the module updater.
The four city updates run Ironforge → Darnassus → Thunder Bluff → Undercity.
Restart worldserver afterward to reload templates, equipment, addons and spawns.

SQL supports both `creature.id` and `creature.id1`. Reapplication preserves
spawn GUIDs and per-spawn appearance overrides. Placement updates are limited
to this city's reserved entries, map and bounds; copies outside those bounds,
unrelated outfits and previously installed city rosters are preserved.

## Roster

| Custom entry | Source entry | Name | Service | Appearance | Wrath X, Y, Z | X/Y move (m) |
|---|---|---|---|---|---|---|
| 4000500 | 39116 | Apolos | Hunter Trainer | Custom outfit | 1688.030, 398.658, -62.010 | 0.000 |
| 4000501 | 50609 | Nathanos Blightcaller | Hunter Trainer | Custom outfit | 1691.970, 400.474, -62.010 | 0.000 |
| 4000502 | 52317 | Mahala Cloudsong | Shaman Trainer | Custom outfit | 1558.500, 344.363, -62.010 | 0.000 |
| 4000503 | 52319 | Mala Skywatcher | Druid Trainer | Custom outfit | 1556.230, 342.526, -62.010 | 0.000 |
| 4000504 | 52587 | Neller Fayne | Jewelcrafting Trainer | Custom outfit | 1645.460, 331.009, -61.941 | 0.000 |

## Placement checks

All five retain the source X/Y and facing in the underground city. Apolos and Nathanos stay together, Mahala and Mala stay together, and Neller keeps his source trade location. Existing Wrath Nathanos in the Plaguelands remains intact; only the custom Undercity recreation is added.

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

All five use player-style outfits. Nathanos retains his original native display
as fallback and his source weapons. Apolos's dark green hunter armor and the
tauren trainers' shaman/druid clothing are assembled from native equivalents.
Neller's clothing is already native to Wrath.

Adam Hossack is excluded because archaeology has no Wrath training system.

## Sources and validation

Names, source entries, roles, equipment and positions:
[SkyFire 5.4.8 database release 24.001](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001).
Appearance reference:
[ZAM model metadata](https://wow.zamimg.com/modelviewer/cata/meta/npc/31314.json),
with per-NPC display references and original customization in
[`data/npcs/undercity_trainers.json`](../data/npcs/undercity_trainers.json).
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
