# Quest hubs: camp safety and compact layouts

The four implemented chapters have **six protected resting areas**, **59 resting-area
props**, **six holding-camp props**, **12 sentries** and **six working residents**.
The Charred Vale uses one friendly expedition/refuge and two compact cult compounds.
The campaign stays in the normal world; native spawns, quests and objects are retained.

[World polish upgrade and controls](world-polish.md) · [Layout plan](hub-layout.svg)
· [Implementation manifest](../../data/quests/broken_seal_hubs.json)

![Hub layout plan](hub-layout.svg)

This is a placement plan. Realm installation, in-game model rendering, collision and
terrain contact still require a stock-client playthrough.

## Registered resting areas

| Area | Activation | Resting radius | Sentry screen | Props |
|---|---|---:|---:|---:|
| Vale Expedition and Refuge | Chapter 1 | 14 m | 22 m | 7 |
| Twilight Recruiting Compound | Chapter 2 | 19 m | 24 m | 11 |
| Dawnchaser Field Camp | Chapter 2 | 23 m | 31 m | 10 |
| Mei's Mudsprocket Relief Station | Chapter 3 | 18 m | 36 m | 10 |
| Southern Village Relief Camp | Chapter 4 | 20 m | 28 m | 11 |
| Neutral Wildhammer Gathering | Chapter 4 | 22 m | 40 m | 10 |

The guarded holding camp is a deliberate encounter area, with six additional cult
props. Its captives, Jarod and guards are not a friendly resting hub. Each real hub
has shelter, supplies, lighting and a work/medical/equipment area. Small footprints,
reserved movement lanes and checked prop foundations keep it coherent.

## Protection and hostility

Eligible ordinary ambient NPCs cannot damage PCs or controlled units while the
player rests inside a registered circle or a scenery access margin. Outside fights
remain normal. Scripted campaign enemies, private summons, bosses, service NPCs,
PvP and pets are excluded from ambient protection.

Sentries repel physical intruders or NPCs attacking protected players. They leave
ordinary quest fights outside camp alone. They do not kill native enemies for
players. Matching map and phase and a vertical tolerance bound the protection.

The cult compound's protection requires valid player cover. Its public cult NPCs
are hostile to uncovered players and accept disguised players through a pairwise
reaction rule. Player factions are unchanged. Cult sentries are ordinary armed,
killable enemies when hostile; fixed trial actors retain their intended combat
rules. Native stock templates and patrol paths are never rewritten.

## Installation

For the existing Chapter 1/2 realm, rebuild and apply the
[world polish update](../../data/sql/db-world/updates/2026_10_07_03_broken_seal_world_polish.sql).
It installs the compact Vale hubs and restores unchanged stock homes moved by the
previous add-on. Backups and later administrator edits are retained.

With all four chapters installed, apply their current base SQL followed by
[broken_seal_hubs.sql](../../data/sql/db-world/base/broken_seal_hubs.sql). The current
base and `2026_10_07_02` update are identical. The earlier `2026_10_06_03` is historical;
use the polish upgrade instead of reinstalling its former camp layout.

Enable the module, chapter options and `ModCustomNPCs.BrokenSeal.Hubs.Enable`, then
restart worldserver. Native cult skins and equipment work without an outfit packet;
custom wardrobe NPCs use `ModCustomNPCs.Appearance.Enable`.

Imports reject unowned custom-ID collisions before content changes and keep surviving
campaign spawn GUIDs. Only recorded obsolete campaign placements are retired. No
fresh native spawn relocation is authored, and no character migration or client
patch is required. The optional
[restore support SQL](../../data/sql/support/restore_broken_seal_hub_native_spawns.sql)
remains outside automatic import folders.

## Verification and future camps

The upgrade fixture verifies normal-world noninterference on both creature schemas.
Native asset checks cover model IDs, footprint slopes, contact access, ground points
and scene/escort/trial corridors. The standalone policy test verifies that outside
quest fights cannot be repelled. Run:

```bash
python3 tools/generate_broken_seal_hubs.py --check
python3 tools/generate_broken_seal_polish.py --check
python3 tools/audit_broken_seal_world_polish.py --client-data /path/to/data --core-root /path/to/core --nav-probe /path/to/nav_probe
python3 tools/verify_broken_seal_hub_assets.py --client-data /path/to/data --nav-probe /path/to/nav_probe
```

Apply the same standard to every future chapter: compact camps with a purpose,
texture-bearing native fallbacks, visible appropriate equipment, real grounded
interactables, native quest/object/patrol audits and reserved movement lanes.
Preserve native content rather than clear it to make space. Put burst training
encounters in owned temporary scenes. Any hostile resting area must define its
access policy; it must not make cult NPCs globally friendly.

Before deployment, walk each camp as both factions, test disguise expiry and two
players with different cover, ordinary roamers/DoTs, pets and outside quest fights.
Inspect tents and prop contact from ground-level angles. Run every escort, trial,
Dawnchaser scene and village treatment, check realm-specific additions, and reapply
SQL on staging before the live realm.
