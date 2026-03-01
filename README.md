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

4. Apply the SQL files to your **world** database:

```bash
mysql -u<user> -p acore_world < data/sql/db-world/base/nubmage.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/daish.sql
```

5. Restart the worldserver.

## Configuration

| Setting                              | Default | Description                                            |
|--------------------------------------|---------|--------------------------------------------------------|
| `ModCustomNPCs.Enable`               | `1`     | Master toggle — disables all module NPC scripts        |
| `ModCustomNPCs.Announce`             | `1`     | Show module-loaded message on player login             |
| `ModCustomNPCs.Nubmage.PortalPriceGold` | `10` | Portal price in gold (SQL BoxMoney must match)         |

## Project Structure

```
mod-customNPCs/
├── CMakeLists.txt
├── conf/
│   └── mod_customnpcs.conf.dist
├── data/sql/db-world/base/
│   ├── nubmage.sql          ← Nubmage template, spawn, gossip, texts, SmartAI
│   └── daish.sql            ← Daish + healers: templates, spawns, formations,
│                               waypoints, texts, SmartAI combat
├── src/
│   ├── mod_customnpcs_pch.h
│   ├── mod_customnpcs_loader.cpp   ← Script registration
│   ├── mod_customnpcs_world.cpp    ← WorldScript + PlayerScript (config, announce)
│   └── npc_nubmage.cpp             ← Nubmage gossip / teleport (C++)
├── README.md
└── LICENSE
```

## Adding More NPCs

1. Create a new `.cpp` in `src/` with your `CreatureScript`.
2. Add a registration function (e.g. `void AddMyNpcScripts();`) and call it from `mod_customnpcs_loader.cpp`.
3. Add matching SQL in `data/sql/db-world/base/`.

## License

GNU AGPL v3 — see [LICENSE](LICENSE).
