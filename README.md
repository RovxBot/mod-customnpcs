# mod-customNPCs

AzerothCore 3.3.5a module — custom NPCs for a private server.

## NPCs

### Nubmage (entry 4000000)
Portal Service NPC stationed in Orgrimmar bank.
- Gossip menu with portals to Thunder Bluff, Undercity, and Silvermoon (10 g each).
- Gossip/teleport logic handled in C++ (`npc_nubmage`); OOC advertising & trash-talk yells via SmartAI.
- `creature_text` groups: ads (0), trash talk (1), no-gold (2), success (3).

### Daish (entry 4000001)
Wintergrasp Champion — Alliance ret-paladin elite patrolling Blackrock Mountain.
- 12-point waypoint loop with two pocket healers in formation.
- Combat AI: Seal of Command, Judgement, Consecration, Hammer of Justice, Divine Shield at 20 %.
- Healers cast Power Word: Shield and Flash Heal on friendly targets.
- Periodically yells "Daish! Daish! Daish!" while patrolling.

### Cataclysm Orgrimmar trainers (entries 4000005–4000024)

Named NPC recreations from Cataclysm's rebuilt Orgrimmar, retaining their trainer
titles and specialisms. Their placements follow the later city as closely as
Wrath geometry allows: 13 retain the original X/Y, and seven move less than 18 metres
to reachable ground. Heights are corrected for the older city.

Thirteen NPCs use researched player-style outfits with their actual race, gender,
customization, and WotLK equivalents of their original clothing. Seven goblins
use matching-gender legacy goblin costumes. Native held weapons and idle poses
are reproduced where supported. See [the roster and placement guide](docs/orgrimmar-trainers.md).

| Original NPC | Teaches |
|---|---|
| Shalla Whiteleaf | Druid |
| Nohi Plainswalker | Hunter |
| Conjurer Mixli | Mage |
| Sunwalker Atohmo | Paladin |
| Seer Liwatha | Priest |
| Night-Stalker Ku'nanji | Rogue |
| Sahi Cloudsinger | Shaman |
| Unjari Feltongue | Warlock |
| Blademaster Ronakada | Warrior |
| Old Umbehto | Fishing |
| Krenk Choplimb | First Aid |
| "Jack" Pisarek Slamfix | Engineering |
| Kark Helmbreaker | Blacksmithing |
| Zarbo Porkpatty | Cooking |
| Nivi Weavewell | Tailoring |
| Rento | Skinning |
| Gizzik Oregrab | Mining |
| Lugrah | Jewelcrafting |
| Nerog | Inscription |
| Muraga | Herbalism |

Their names, titles, roles, and placements are taken from a 5.4.8 world
database snapshot. Each NPC is connected only to the matching AzerothCore
WotLK trainer list; it is not a generic all-professions trainer. Cataclysm's
new 1–525 ranks and recipes are not inserted because the 3.3.5a client has no
corresponding skill/spell data.

### Cataclysm/MoP Stormwind trainers (entries 4000100–4000113)

Fourteen later-expansion additions are recreated in Stormwind with their original
names, titles, and matching Wrath services. Eleven use custom outfits; three
Wildhammer dwarfs retain tattooed native NPC appearances. Celestine uses her
canonical human form in the Wrath Park because her later lake-side grove is absent.

The roster includes Don Omar, Wulf Hansreim, Sarisse Jume, Alma Deering,
Darlene Stokx, Bralla Cloudwing, Bolner and Dalga Hammerbeak, Celestine of the
Harvest, Theresa Denman, Chief Surgeon Gashweld, Arthur Huwe, Jordan Smith,
and Angela Leifeld. Jordan also sells his compatible Wrath supplies.

Existing stock Stormwind trainers are retained. Unsupported archaeology,
battle-pet, monk, and pandaren additions are documented rather than assigned an
unrelated training service. See [the Stormwind guide](docs/stormwind-trainers.md).

## Custom NPC appearances

The module includes a player-style appearance framework: choose a WotLK race,
gender, facial features, armor, and weapons for ordinary NPCs without a client
patch. Reuse outfits across NPC entries or override individual spawns.

Create an outfit in game, select an NPC, and assign it:

```text
.customnpc outfit create 100 6 1
.customnpc outfit set 100 mainhand 19019
.customnpc outfit apply 100
```

Or use `.customnpc outfit capture 100` to copy your equipped GM character.
Commands require administrator security (level 3). Outfits affect appearance;
the NPC keeps its existing AI, stats, faction, and trainer/gossip services.

See [the appearance guide](docs/custom-npc-appearances.md) for equipment fields,
spawn overrides, SQL definitions, reloads, client limits, and verification.

## Requirements

- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) latest `master` branch

## Installation

1. Clone into your AzerothCore `modules` directory:

```bash
cd <azerothcore-root>/modules
git clone https://github.com/<your-user>/mod-customNPCs.git
```

2. Re-run CMake and rebuild the worldserver.

3. Copy `conf/mod_customnpcs.conf.dist` next to your `worldserver.conf` and rename to `mod_customnpcs.conf`.

4. For a fresh install, apply the SQL files in `data/sql/db-world/base/` to your
   **world** database:

```bash
mysql -u<user> -p acore_world < data/sql/db-world/base/nubmage.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/daish.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/kappa.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/custom_npc_appearances.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/later_expansion_trainers.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/later_expansion_appearances.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/stormwind_trainers.sql
```

5. Rebuild and restart the worldserver.

For an existing world database, incremental changes should go in
`data/sql/db-world/updates/`. AzerothCore's DB updater will apply those
automatically on startup when the module is present in the source tree.

## Configuration

| Setting                              | Default | Description                                            |
|--------------------------------------|---------|--------------------------------------------------------|
| `ModCustomNPCs.Enable`               | `1`     | Master toggle — disables all module NPC scripts        |
| `ModCustomNPCs.Announce`             | `1`     | Show module-loaded message on player login             |
| `ModCustomNPCs.Nubmage.PortalPriceGold` | `10` | Portal price in gold                                   |
| `ModCustomNPCs.Appearance.Enable` | `1` | Enable assigned player-style NPC outfits |

## Project Structure

```
mod-customNPCs/
├── CMakeLists.txt
├── conf/
│   └── mod_customnpcs.conf.dist
├── data/sql/db-world/base/
│   ├── nubmage.sql          ← Nubmage template, spawn, gossip, texts, SmartAI
│   ├── daish.sql            ← Daish + healers: templates, spawns, formations,
│                               waypoints, texts, SmartAI combat
│   ├── kappa.sql            ← Kappa template, spawn, display, gossip text
│   ├── custom_npc_appearances.sql ← Outfit schema (no automatic assignments)
│   ├── later_expansion_appearances.sql ← Researched Orgrimmar looks and Wrath placements
│   ├── stormwind_trainers.sql ← Later Stormwind additions, looks and placements
│   └── later_expansion_trainers.sql
│                            ← Named Cataclysm Orgrimmar trainer recreations
├── data/sql/db-world/updates/
│   ├── 2026_03_11_00_kappa.sql ← Auto-applied world update for Kappa
│   ├── 2026_10_05_00_custom_npc_appearances.sql ← Outfit schema update
│   ├── 2026_10_05_01_orgrimmar_appearances.sql ← Orgrimmar outfit/placement update
│   ├── 2026_10_05_02_stormwind_trainers.sql ← Stormwind roster update
│   └── 2026_09_29_00_later_expansion_trainers.sql
│                            ← Auto-applied Cataclysm trainer update
├── src/
│   ├── mod_customnpcs_pch.h
│   ├── mod_customnpcs_loader.cpp   ← Script registration
│   ├── mod_customnpcs_world.cpp    ← WorldScript + PlayerScript (config, announce)
│   ├── CustomNpcOutfit.h           ← Outfit data and mirror-image protocol
│   ├── CustomNpcAppearanceMgr.*    ← Catalog loading and creature appearance lifecycle
│   ├── mod_customnpcs_appearance.cpp ← Appearance hooks and GM commands
│   └── npc_nubmage.cpp             ← Nubmage gossip / teleport (C++)
├── docs/custom-npc-appearances.md  ← Outfit authoring and client limits
├── docs/orgrimmar-trainers.md      ← NPC matching notes and location changes
├── docs/stormwind-trainers.md      ← Stormwind roles, appearances and location changes
├── data/npcs/orgrimmar_trainers.json ← Source and converted appearances/coordinates
├── data/npcs/stormwind_trainers.json ← Stormwind source/conversion definitions
├── tools/generate_orgrimmar_appearances.py ← Generate matching base/update SQL
├── tools/generate_stormwind_trainers.py ← Generate Stormwind installation/update SQL
├── tests/outfit_tests.cpp          ← Standalone protocol and assignment tests
├── README.md
└── LICENSE
```

## Adding More NPCs

1. Create a new `.cpp` in `src/` with your `CreatureScript`.
2. Add a registration function (e.g. `void AddMyNpcScripts();`) and call it from `mod_customnpcs_loader.cpp`.
3. Add matching SQL in `data/sql/db-world/base/` for fresh installs.
4. Add a timestamped SQL update in `data/sql/db-world/updates/` for existing databases.

## 3.3.5a Compatibility

This module can recreate a later NPC's server-side identity, title, location,
and trainer role, but an unmodified 3.3.5a client cannot render Cataclysm/Mists
models or learn their new skills, spells, and profession ranks. The included
Cataclysm NPCs therefore combine native WotLK assets with their matching WotLK
curricula. The appearance presets reproduce clothing textures and customization
where possible, with legacy goblin approximations and documented substitutions.

Custom outfits can compose additional appearances from WotLK player models and
gear. Exact Cataclysm/Mists races and assets still require client ports; the
framework does not add newer models, maps, or playable races to the client.

Pandaria is map 870 in Mists and is not present in a stock 3.3.5a client, so
Mists trainers that only existed in Pandaria are deliberately not relocated to
an arbitrary WotLK city. Monk trainers are intentionally excluded. Adding
those NPCs faithfully requires a client/map port, or an explicit custom
placement chosen for this server.

## License

GNU AGPL v3 — see [LICENSE](LICENSE).
