# Ironforge: later-expansion trainer recreations

8 additions from the same 5.4.8 source snapshot used for Orgrimmar and
Stormwind, with original names/titles, matching Wrath curricula, 4 player-style
outfits and checked placements. Existing stock trainers are retained.

## Installation

Apply `data/sql/db-world/base/ironforge_trainers.sql` after
`custom_npc_appearances.sql` for a fresh world database. Existing installs use
`data/sql/db-world/updates/2026_10_05_03_ironforge_trainers.sql` through the module updater.
The four city updates run Ironforge → Darnassus → Thunder Bluff → Undercity.
Restart worldserver afterward to reload templates, equipment, addons and spawns.

SQL supports both `creature.id` and `creature.id1`. Reapplication preserves
spawn GUIDs and per-spawn appearance overrides. Placement updates are limited
to this city's reserved entries, map and bounds; copies outside those bounds,
unrelated outfits and previously installed city rosters are preserved.

## Roster

| Custom entry | Source entry | Name | Service | Appearance | Wrath X, Y, Z | X/Y move (m) |
|---|---|---|---|---|---|---|
| 4000200 | 50716 | Pyromancer Scorchbrew | Mage Trainer | Native Dark Iron skin | -4627.830, -913.788, 525.484 | 0.000 |
| 4000201 | 50717 | Flarna Flametongue | Mage Trainer | Native Dark Iron skin | -4630.790, -914.106, 524.991 | 0.000 |
| 4000202 | 50720 | Lainda Gemgold | Mage Trainer | Custom outfit | -4628.880, -916.180, 525.097 | 0.000 |
| 4000203 | 50723 | Keric Smolderblade | Warlock Trainer | Native Dark Iron skin | -4605.770, -1115.430, 505.268 | 0.000 |
| 4000204 | 50729 | Darba the Crone | Warlock Trainer | Native Dark Iron skin | -4599.310, -1107.490, 505.268 | 0.000 |
| 4000205 | 50732 | Larn Caverndeep | Warlock Trainer | Custom outfit | -4602.150, -1107.760, 505.268 | 0.000 |
| 4000206 | 52335 | Dareth | Druid Trainer | Human approximation | -5081.380, -780.411, 495.671 | 0.000 |
| 4000207 | 52586 | Hanner Gembold | Jewelcrafting Trainer | Custom outfit | -4706.710, -1110.230, 504.735 | 0.000 |

## Placement checks

All eight retain the source X/Y and facing. Mage trainers stay in the upper Mystic Ward, warlocks in the Forlorn Cavern, Hanner at his source trade location, and Dareth at the gates. Ground heights change by less than 0.71 m.

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

Pyromancer Scorchbrew, Flarna Flametongue, Keric Smolderblade and Darba the Crone
have NPC-only Dark Iron skins. Player-style rendering cannot retain these skins,
so fixed native Dark Iron displays approximate their costumes and faces. Their
source held weapons are preserved. Dareth uses a human-form approximation;
the source provides no separate human display, so his face/hair are selected
approximations. His clothing uses native white leather and yellow sleeve layers.

Doktor Professor Ironpants is excluded because archaeology has no Wrath training system.

## Sources and validation

Names, source entries, roles, equipment and positions:
[SkyFire 5.4.8 database release 24.001](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001).
Appearance reference:
[ZAM model metadata](https://wow.zamimg.com/modelviewer/cata/meta/npc/36937.json),
with per-NPC display references and original customization in
[`data/npcs/ironforge_trainers.json`](../data/npcs/ironforge_trainers.json).
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
