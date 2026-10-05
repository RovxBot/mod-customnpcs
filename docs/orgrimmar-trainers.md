# Orgrimmar appearance and placement conversion

The 20 later-expansion trainers now use their actual race and gender rather than
an arbitrary trainer of the same profession. Thirteen use the outfit framework;
the seven goblins use legacy Wrath goblin models of the correct gender.

All original held weapons in the source snapshot are available in build 12340
except Ronakada's off-hand item 62373, which is omitted. His main-hand sword 10613
is retained. Source idle/sheath states are copied: Ku'nanji sits, Nohi displays
his ranged weapon, and other NPCs draw or sheath their equipment as recorded.
Source cosmetic auras are not imported by this preset; existing addon auras are preserved.

## Install or upgrade

For a fresh install, apply these world SQL files in this order:

```text
data/sql/db-world/base/custom_npc_appearances.sql
data/sql/db-world/base/later_expansion_trainers.sql
data/sql/db-world/base/later_expansion_appearances.sql
```

For an existing installation, the module DB updater applies
`2026_10_05_01_orgrimmar_appearances.sql` after the outfit schema update. You can
also apply `base/later_expansion_appearances.sql` manually after installing that
schema. Restart worldserver afterwards; an outfit reload alone does not reload
the core's spawn, equipment, model, and addon caches.

The appearance update edits existing Orgrimmar spawns in place. It preserves
their GUIDs, template services, faction, AI, trainer lists, and per-spawn outfit
overrides. Copies of these entries outside Orgrimmar are not relocated.
Intentional spawn overrides still win over the new default outfits; remove one
with `.customnpc outfit clearspawn` if you want that spawn to use its new preset.

## Appearance choices

| NPC | Race / gender | Appearance |
|---|---|---|
| Shalla Whiteleaf | Tauren female | Green robe with red sleeves, original headpiece and staff. |
| Nohi Plainswalker | Tauren male | Brown leather, source facial features, melee weapon and longrifle. |
| Conjurer Mixli | Goblin female | Legacy blue caster dress; original staff. |
| Sunwalker Atohmo | Tauren male | Silver plate, source horns/beard, original polearm. |
| Seer Liwatha | Tauren female | Dark robes, headpiece and original staff. |
| Night-Stalker Ku'nanji | Troll male | Original Horde leather PvP set, dual weapons, seated pose. |
| Sahi Cloudsinger | Tauren female | Orange robe, headpiece and original mace. |
| Unjari Feltongue | Troll female | Black robes and matching hand/lower-arm textures; original staff. |
| Blademaster Ronakada | Orc male | Red plate and original sword; later off-hand/banner effects omitted. |
| Old Umbehto | Troll male | Red torso with brown sleeves, source hair/tusks, original fishing pole. |
| Krenk Choplimb | Goblin male | Legacy headgear/default-tabard costume; original cleaver. |
| "Jack" Pisarek Slamfix | Goblin male | Legacy outfit with the original blue chest texture; original tool. |
| Kark Helmbreaker | Goblin male | Legacy dark work leathers; original tool. |
| Zarbo Porkpatty | Goblin male | Legacy outfit with the original purple crewman chest texture; no later chef hat. |
| Nivi Weavewell | Goblin female | Legacy orange dress, approximating her orange tailoring outfit. |
| Rento | Tauren male | Native equivalents of the source leather outfit; original knife. |
| Gizzik Oregrab | 1529.12, -4133.45, 51.14 | 1530.91, -4141.05, 46.39 | 7.80 m |
| Lugrah | Orc female | Blue robe textures, original headpiece and accessories. |
| Nerog | Orc male | Blue robe, original hair/beard and staff. |
| Muraga | Orc female | Green cloth, matching older boot textures, original staff. |

Goblins retain their race throughout the conversion. Their modern hair, face,
body, and complete costume combinations cannot be reproduced exactly with the
limited legacy goblin assets. The presets choose clothing palette, silhouette,
headgear, and profession cues using existing costumes. They are approximations;
they are not the Cataclysm playable goblin model or a substitute player race.

Most clothing displays can be copied directly. Some later display IDs wrap
textures already present in Wrath. For those, the conversion uses matching older
displays rather than inventing a new ID. For example, Shalla's later shirt 63011
uses the same green torso/red sleeve textures as Wrath display 25264; Nohi's
shirt 61065 matches display 10116. Unjari's newer glove wrapper is split into
native hand display 13392 and lower-arm display 15768. Umbehto's red torso and
brown sleeves are composed from native displays 10874 and 10018.

These texture matches preserve more detail than merely picking a similar item
name or color. Mesh/slot differences can still affect the final client render.
Every substituted slot is recorded in the JSON roster.

## Placement method

The later coordinates are retained as `source_position` in the roster. Target
positions were checked against Orgrimmar's build-12340 navigation mesh from
[AzerothCore's client-data release](https://github.com/wowgaming/client-data/releases/tag/v20.0).
The five relevant tiles were loaded together. Ground polygons were restricted
to the component reachable from the city entrance, excluding isolated surfaces
and water. Selection prioritizes horizontal proximity; moved points are inset
0.5 metres from navigation edges. Stored heights sit 0.10 metres above the
navigation surface to avoid placing the origin underneath it.

Thirteen NPCs retain their original X/Y. Seven move horizontally by less than
18 metres to fit the older layout. Their original facing is retained. This
preserves the later neighborhood groupings without inventing a trainer hub.
Buildings, tents, ponds, and furnishings specific to the rebuilt city are not
ported by these NPC definitions. The old Gizzik coordinates were corrected
against the full source snapshot; he is now near Kark in the goblin industrial area.

The checked positions are listed below. Coordinates use map 1 world units,
not map percentages. An in-game walkthrough is still needed on the deployed
realm: these are stock-map navigation checks, not client screenshots, and local
map modifications can change the result.

| NPC | Later X, Y, Z | Wrath X, Y, Z | Horizontal move |
|---|---|---|---|
| Shalla Whiteleaf | 1888.95, -4285.25, 23.70 | 1888.95, -4285.25, 31.19 | 0.00 m |
| Nohi Plainswalker | 1872.89, -4281.46, 23.91 | 1872.91, -4280.95, 33.99 | 0.51 m |
| Conjurer Mixli | 1558.52, -4209.71, 54.25 | 1558.52, -4209.71, 44.14 | 0.00 m |
| Sunwalker Atohmo | 1863.88, -4292.69, 23.90 | 1863.88, -4292.69, 34.11 | 0.00 m |
| Seer Liwatha | 1863.46, -4297.75, 23.88 | 1863.46, -4297.75, 32.33 | 0.00 m |
| Night-Stalker Ku'nanji | 1758.12, -4069.09, 51.78 | 1758.12, -4069.09, 44.66 | 0.00 m |
| Sahi Cloudsinger | 1884.15, -4282.40, 23.76 | 1884.15, -4282.40, 31.61 | 0.00 m |
| Unjari Feltongue | 1675.61, -4132.10, 51.51 | 1675.61, -4132.10, 38.56 | 0.00 m |
| Blademaster Ronakada | 1960.88, -4788.98, 39.20 | 1960.88, -4788.98, 57.13 | 0.00 m |
| Old Umbehto | 1705.74, -4118.14, 48.36 | 1705.74, -4118.14, 40.46 | 0.00 m |
| Krenk Choplimb | 1472.12, -4148.55, 52.69 | 1475.90, -4148.48, 40.93 | 3.78 m |
| "Jack" Pisarek Slamfix | 1483.09, -4142.57, 52.44 | 1482.48, -4143.12, 43.47 | 0.82 m |
| Kark Helmbreaker | 1526.54, -4130.65, 51.34 | 1529.31, -4141.54, 46.69 | 11.24 m |
| Zarbo Porkpatty | 1487.83, -4187.19, 53.40 | 1477.67, -4201.27, 44.11 | 17.36 m |
| Nivi Weavewell | 1560.91, -4224.63, 54.14 | 1560.91, -4224.63, 47.80 | 0.00 m |
| Rento | 1910.17, -4191.30, 37.27 | 1920.54, -4190.88, 43.73 | 10.38 m |
| Gizzik Oregrab | 1529.12, -4133.45, 51.14 | 1530.91, -4141.05, 46.39 | 7.80 m |
| Lugrah | 2088.80, -4767.27, 28.01 | 2088.80, -4767.27, 23.82 | 0.00 m |
| Nerog | 1838.72, -4464.13, 47.69 | 1838.72, -4464.13, 47.80 | 0.00 m |
| Muraga | 1907.59, -4460.51, 53.39 | 1907.59, -4460.51, 54.50 | 0.00 m |

## Sources and maintenance

Identity, display IDs, held equipment, idle poses, and original placements come
from the [SkyFire 5.4.8 world snapshot, release 24.001](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001).
Clothing and character choices were compared with Cataclysm model-viewer
metadata, for example [Shalla's display 34046](https://wow.zamimg.com/modelviewer/cata/meta/npc/34046.json).
Customization choices were translated using their classic option indices and
checked against Wrath character sections/geosets. Later material names were
resolved through the [verified WoW asset list](https://github.com/wowdev/wow-listfile).
Every shipped fallback display, armor display, player customization, and held
weapon was checked against native build-12340 DBCs. Fallback models were also
checked for matching gender and disabled random-gender alternates.

The authoring source is [the JSON roster](../data/npcs/orgrimmar_trainers.json).
It records source and converted coordinates, appearances, equipment,
substitutions, and limitations. Outfit IDs equal the corresponding custom NPC
entries (`4000005` etc.) and are reserved for these presets.

After editing it, regenerate both installation paths and run the content checks:

```bash
python tools/generate_orgrimmar_appearances.py
python tools/generate_orgrimmar_appearances.py --check
python -m unittest discover -s tests -p 'test_*.py' -v
```

Reapplying the appearance SQL replaces the roster's default outfits and models.
Use separate outfit IDs or spawn overrides for personal variants you want to
keep across preset updates.

The SQL was executed in disposable MariaDB databases with both `creature.id`
and `creature.id1` layouts. Checks covered fresh installation, repeated preset
application, all 20 model/position assignments, unchanged spawn GUIDs and trainer
services, preserved spawn overrides/addon metadata, and protection of copies
outside Orgrimmar. The four repository content tests also pass. Client rendering
and a walkthrough on the deployed realm remain to be checked after restart.
