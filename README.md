# mod-customNPCs

AzerothCore 3.3.5a module — Custom NPCs.

## Requirements

- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) with the latest `master` branch

## Installation

1. Clone this repository into your AzerothCore `modules` directory:

```bash
cd <azerothcore-root>/modules
git clone https://github.com/<your-user>/mod-customNPCs.git
```

2. Re-run CMake and rebuild.

3. Copy `conf/mod_customnpcs.conf.dist` to your server's config directory (next to `worldserver.conf`) and rename it to `mod_customnpcs.conf`.

4. Apply any SQL files from `data/sql/db-world/base/` to your **world** database.

5. Restart the worldserver.

## Configuration

| Setting                  | Default | Description                         |
|--------------------------|---------|-------------------------------------|
| `ModCustomNPCs.Enable`   | `1`     | Enable / disable the module         |
| `ModCustomNPCs.Announce` | `1`     | Announce module on player login     |

## Adding Custom NPCs

1. Create your `CreatureScript` class in `src/`.
2. Register it in `src/mod_customnpcs_loader.cpp` inside `AddModCustomNPCsScripts()`.
3. Add the SQL for `creature_template` and spawn data in `data/sql/db-world/`.

## License

This module is released under the [GNU AGPL v3](LICENSE).
