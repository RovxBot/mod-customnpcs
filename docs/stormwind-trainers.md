# Later-expansion Stormwind trainers

This roster adds 14 Cataclysm/MoP trainers that were absent from Wrath Stormwind.
It keeps their identities and supported services, uses the closest native
appearances, and adjusts placements for the older city. Existing stock trainers
are retained.

New entries are `4000100–4000113`. Eleven NPCs use the outfit framework. Three
Wildhammer dwarfs use pre-made native NPC displays: their tattooed NPC-only skins
exist in Wrath, but the mirror-image technique cannot render those skins as
player customization. The native models retain their race, gender, and skin;
hair and costume combinations are approximations.

## Installation

Install the outfit schema first, then apply:

```text
data/sql/db-world/base/custom_npc_appearances.sql
data/sql/db-world/base/stormwind_trainers.sql
```

Existing module installations receive the equivalent
`2026_10_05_02_stormwind_trainers.sql` through the DB updater. Restart worldserver
after importing it; outfit reload alone does not refresh the core's NPC template,
trainer, gossip, vendor, addon, and spawn caches.

The script creates missing Stormwind spawns and updates existing ones in place.
Reapplying it preserves their GUIDs and spawn-specific outfit overrides. It does
not relocate outside-city copies or edit the existing stock Stormwind NPCs.

## Roster and services

| Entry | NPC | Appearance | Wrath service |
|---|---|---|---|
| 4000100 | Don Omar | Human male; matching leather and source weapons | Hunter |
| 4000101 | Darlene Stokx | Human female; source customization and riding attire | Ground riding |
| 4000102 | Bralla Cloudwing | Tattooed native Wildhammer dwarf female | Wrath riding/flying |
| 4000103 | Wulf Hansreim | Human male; source hunter attire and weapons | Hunter |
| 4000104 | Sarisse Jume | Human female; source outfit and a Wrath rifle equivalent | Hunter |
| 4000105 | Alma Deering | Human female; matching green leather | Hunter pet trainer |
| 4000106 | Bolner Hammerbeak | Tattooed native Wildhammer dwarf male | Shaman |
| 4000107 | Dalga Hammerbeak | Tattooed native Wildhammer dwarf female | Shaman |
| 4000108 | Celestine of the Harvest | Canonical human form; brown robes, hood and staff | Druid |
| 4000109 | Theresa Denman | Human female; source jewelry-shop attire | Jewelcrafting |
| 4000110 | Chief Surgeon Gashweld | Gnome female; white medical robes and matching older head model | Priest |
| 4000111 | Arthur Huwe | Human male; source rogue armor and weapons | Rogue |
| 4000112 | Jordan Smith | Human male; source smithing clothes and tool | Blacksmithing and supplies |
| 4000113 | Angela Leifeld | Human female; source white first-aid attire | First Aid |

Class trainer IDs match the corresponding AzerothCore class curricula. Alma uses
the stock **pet** trainer/menu, not the player hunter spell list. Bralla uses
Wrath riding/flying skills; no Cataclysm Flight Master's License or Azeroth flying
unlock is added. Darlene teaches native ground riding. Profession trainers use
matching full Wrath curricula, including the Northrend ranks where applicable.

Jordan retains the six compatible source supplies: Mining Pick, Blacksmith
Hammer, Weak Flux, Strong Flux, Coal, and Elemental Flux. His separate training
and shopping options are available through an owned gossip menu. Later recipes
and currencies are omitted.

## Appearance matching and exceptions

Clothing displays, facial choices, and equipped items were compared against
native build-12340 data. Older displays are used where later display wrappers
refer to existing textures. Alma's green sleeves/torso and hand/lower-arm layers
are rebuilt with matching native displays. Gashweld's medical headpiece uses the
same older head-model family; its later display ID is not sent to the client.

Sarisse's source NPC rifle item 57240 is absent from Wrath's `Item.dbc`; she uses
the native Gnomish Assault Rifle, item 23748. Other source weapon item entries
are retained. The client still needs an in-game comparison to assess mesh/slot
differences and the known mirror-image portrait limitations.

Celestine is a Gilnean worgen whose human form is part of her in-game identity.
Her human appearance is sourced separately from display 29961, rather than
invented by converting her worgen customization indices. This recreation stays
in human form; her modern worgen model and night-time transformation need a
client port. [Celestine's human-form appearance metadata](https://wow.zamimg.com/modelviewer/cata/meta/npc/29961.json)
provides the clothing and customization reference.

## Placement conversion

Stormwind's build-12340 navigation tiles were loaded together and queried using
the ground component reached from the native Dwarven District trainer area.
Selected locations are on connected, dry, walkable surfaces. Selection uses
three-dimensional proximity so NPCs do not land on a different floor merely to
keep exact X/Y. Moved positions are inset from navigation edges; stored heights
are 0.10 metres above the navigation surface.

The hunter group remains on the same floor of the Command Center. The paired
Hammerbeak shamans stay together rather than collapsing onto the same point
where their later training-room positions are obstructed in Wrath. Apart from
Celestine, horizontal adjustments are under 14 metres.

Celestine's new lake-side grove lies beyond usable ground in the old city.
She is placed in the existing Park druid enclave instead. This is a documented
functional alternative to that missing neighborhood, approximately 624 metres
from her later spot. Her human identity, druid role, facing and appearance are
retained. No new city buildings or terrain are imported.

| NPC | Later X, Y, Z | Wrath X, Y, Z | Horizontal move |
|---|---|---|---|
| Don Omar | -8820.93, 345.45, 107.13 | -8820.20, 346.05, 109.85 | 0.94 m |
| Darlene Stokx | -8779.65, 376.72, 100.88 | -8776.60, 375.56, 101.92 | 3.26 m |
| Bralla Cloudwing | -8845.40, 502.65, 109.70 | -8845.44, 502.14, 109.77 | 0.51 m |
| Wulf Hansreim | -8821.79, 350.35, 107.13 | -8821.98, 351.43, 109.75 | 1.10 m |
| Sarisse Jume | -8818.38, 348.66, 107.13 | -8818.38, 348.66, 110.16 | 0.00 m |
| Alma Deering | -8813.79, 336.30, 107.13 | -8811.93, 337.39, 111.19 | 2.16 m |
| Bolner Hammerbeak | -8356.36, 576.53, 104.36 | -8347.68, 567.38, 100.72 | 12.61 m |
| Dalga Hammerbeak | -8359.01, 574.23, 104.36 | -8349.36, 565.48, 101.11 | 13.03 m |
| Celestine of the Harvest | -8284.26, 724.35, 75.37 | -8773.65, 1110.91, 91.03 | 623.64 m |
| Theresa Denman | -8712.15, 620.00, 101.59 | -8712.15, 620.00, 101.94 | 0.00 m |
| Chief Surgeon Gashweld | -8390.44, 628.44, 95.31 | -8390.44, 628.44, 95.69 | 0.00 m |
| Arthur Huwe | -8702.29, 340.64, 108.38 | -8700.56, 344.70, 102.73 | 4.42 m |
| Jordan Smith | -8557.13, 593.65, 104.68 | -8557.13, 593.65, 105.17 | 0.00 m |
| Angela Leifeld | -8521.53, 816.26, 106.60 | -8521.53, 816.26, 106.98 | 0.00 m |

The checks use stock client geometry. A walkthrough on the deployed realm is
still needed, especially around the Command Center, stables, shaman corner, and
Park. Local map edits may require additional adjustments.

## Scope exclusions

| NPC | Reason |
|---|---|
| Harrison Jones | Archaeology has no corresponding Wrath training system. |
| Aysa Cloudsinger | Monk class and pandaren appearance are unavailable. |
| Audrey Burnhep | The battle-pet training system is unavailable. |
| Mei Lin | Her pandaren model is unavailable; no unrelated race is substituted. |
| Benjamin Foxworthy | His source spawn is in Goldshire/Elwynn Forest, not Stormwind. |

Ordinary trainers already present in Wrath are not duplicated or reassigned.
This is a supported later-trainer conversion, not a port of every Stormwind
quest, event, merchant, or newer gameplay system.

## Sources, maintenance and checks

Source identity, positions, held weapons, poses, and supplies come from
[SkyFire's 5.4.8 world snapshot](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001).
Appearances were compared with Cataclysm model-viewer metadata and native
Wrath DBCs. Locations were checked against
[AzerothCore client-data v20.0](https://github.com/wowgaming/client-data/releases/tag/v20.0).

The [JSON roster](../data/npcs/stormwind_trainers.json) records source and target
positions, rendering choices, equipment, services, substitutions and exclusions.
Outfit IDs equal the corresponding NPC entries and are reserved for these
defaults. Use separate outfit IDs or per-spawn overrides for personal variants.

```bash
python tools/generate_stormwind_trainers.py
python tools/generate_stormwind_trainers.py --check
python -m unittest discover -s tests -p 'test_*.py' -v
```

The migration is checked in disposable MariaDB databases with both `creature.id`
and `creature.id1` schemas, including fresh installation, repeat application,
preserved GUIDs/overrides, outside-city copies, stock NPC protection, the training
and supplies menu, and unchanged Orgrimmar definitions. Nine repository content
tests cover both city rosters.
