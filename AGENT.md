# Agent handoff: mod-customnpcs

Read this file before changing the module. Follow the user's current instructions
when they change the scope or preferences recorded here. Keep this handoff current
when implementation, migrations or validation requirements change.

## Project and current state

This is an AzerothCore C++20 module for World of Warcraft **3.3.5a**. It includes
custom NPC services, recreated later-expansion trainers and flight masters, an NPC
appearance framework, and **The Broken Seal** quest campaign.

The campaign adapts selected Cataclysm/Mists of Pandaria stories into existing
Wrath-era continents. It guides players from level **20 to 80 alongside normal
questing**; it is not intended to supply all leveling XP. Keep the original cast
and story beats where supported. Document native substitutes for unavailable races,
geometry or mechanics. The campaign requires **no asset ports or client patch**.
The separate flight-master feature does have an existing client patch; do not
confuse that feature's requirements with the campaign.

Status as of **7 October 2026**:

| Chapter | Levels | Setting | Quest entries | Implementation |
|---|---|---|---|---|
| 1 | 20–25 | Stonetalon / Charred Vale | 900100–900108 | 9 records; alternate faction entrances, investigation and shared escorts |
| 2 | 25–30 | Charred Vale, then Dustwallow handoff | 900200–900222 | 23 quests; infiltration, training branches and Jarod's escape |
| 3 | 30–35 | Dustwallow | 900300–900311 | 12 quests; Dawnchaser medical story and settlement handoff |
| 4 | 35–40 | Dustwallow, then Hinterlands handoff | 900400–900411 | 12 quests; village recovery and despair finale |
| 5–14 | 40–80 | See campaign inventory | Design IDs only | Designed, not implemented |

The design inventory contains 252 records across 14 chapters. Each faction follows
251 records because Chapter 1 has alternate introductions. Do not describe the
later chapters as playable or installable until their runtime and SQL exist.

## Start here

- [README](README.md): module features, installation and configuration.
- [World polish upgrade](docs/broken-seal/world-polish.md): current layouts,
  appearance defaults, trial/captive controls and existing-realm upgrade steps.
- [Implemented-chapter quality review](docs/broken-seal/quality-review.md): authored
  quests, item icons, enemy rewards, hub dialogue and the optional-chapter upgrade.
- [Campaign inventory](docs/broken-seal/README.md): complete design and source references.
- `docs/broken-seal/chapter{1,2,3,4}-implementation.md`: controls, recovery,
  coordinates, installation and remaining client acceptance checks.
- [Hub guide](docs/broken-seal/hub-implementation.md) and
  [layout](docs/broken-seal/hub-layout.svg): camp footprints and protection.
- [Appearance guide](docs/custom-npc-appearances.md) and
  [outfit repair](docs/broken-seal/outfit-repair.md): assignments and diagnostics.

The world-polish guide takes precedence over historical placement notes. Existing
commits and SQL can contain retired cage, signpost and native-clearance behavior.

## Campaign design rules

### World placement and hubs

- The user explicitly chose **normal-world smaller camps instead of phasing**.
  Do not add a separate campaign phase without a new user instruction.
- Preserve native quests, creature/object placements, services and shared patrols.
  Move and prune campaign-owned placements rather than clearing an existing quest
  area. Current hub policy has `native_spawn_edits=false` and no new relocations.
- Build compact camps with coherent tents, supplies, lighting and working residents.
  Reuse native Silithus Twilight architecture where suitable. Avoid scattered
  contacts or encounter populations that occupy an entire existing quest area.
- Keep important contacts inside their resting footprint and access paths clear.
  Sentries handle ordinary ambient intruders in those areas. Scripted campaign
  encounters remain fightable; cult resting protection requires valid cover.
  Do not make guards interfere with unrelated fights outside their camp.
- Required interactions must have sensible physical props. Do not use floating
  placeholder signposts or tiny empty cages. Invisible controllers are appropriate
  for scripts, not as the only explanation of an interaction players must find.
- Check native terrain height, model bounds/scale, footprint slope and navigation.
  Account for the model's minimum Z when grounding props. A navigation height on a
  stump or canopy is not evidence that the prop sits on the terrain.
- Check native quest objects, routes and spawns before placement. DBC presence alone
  does not prove client compatibility: cached datasets may include Expansion03 assets.
  Use assets actually available to the stock 3.3.5a client.

### Appearance, combat and loot

- Every humanoid needs a valid, textured native NPC fallback. Validate the relevant
  `CreatureDisplayInfoExtra` reference; bare player base models caused textureless NPCs.
- Twilight instructors, scouts, guards and failed supplicants currently use native
  cult skins by default. Entry assignment `outfit_id=0` deliberately keeps the stock
  appearance. A per-spawn assignment takes precedence, including a native override of 0.
- Custom outfits need valid race/gender/class and native item displays. Rendering
  class 0 is invalid; campaign presets use a valid class and explicit leg clothing.
  Zero clothing slots hide those slots. Preserve intentional administrator overrides.
- Populate native `creature_equip_template` rows as well as cosmetic outfit weapons.
  Saved campaign spawns use `equipment_id=-1` to load equipment. Test held/sheath state
  in the client; clothing packets alone do not ensure weapons are visible.
- Public cult NPCs are hostile without cover. Use the existing per-player disguise
  reaction and AI checks for participants and controlled units. Do not globally
  make the cult friendly or change player factions/PvP to implement infiltration.
- Ordinary enemies have regular kill XP, coins and incidental loot. Quest-only
  orders are not an ordinary loot table. Private trial opponents must not offer
  repeatable farming XP/loot.

### Quest progress and scenes

- Save progress in native quest counters/rewarded history. Give distinct locations
  and captives distinct credits. Respect Wrath's objective and reward-choice limits.
- Keep the Chapter 2 ALL-branch joins: negative exclusive groups plus explicit
  rewarded-quest conditions. One completed branch must not unlock graduation.
- Use private actors for personal encounters and explicit ownership checks for
  damage, commands and credit. Chapter 1 captives are intentionally **shared saved
  spawns**: visible and kneeling, one owner per escort, stand/walk after gossip.
- Escort credit requires arrival and a valid nearby living owner. Interrupted
  escorts return home without erasing saved credit. Successful Chapter 1 escorts
  despawn after five seconds and respawn home after a minute; they must not visibly
  walk straight back into captivity.
- Fire and Horrorguard trials have no permanent population. They summon one opponent
  at a time and read the native required count: **8 fire elementals, 10 Horrorguards**.
  Condenna starts fire trials; the holding camp's calling tablet starts Horrorguards.
- Handle death, combat interruptions, distance, logout, abandonment, full bags,
  lost tools and configuration disable. Supply recovery through the existing
  quest contacts. Prevent stale gossip menus from awarding duplicate progress.
- Retain names and story beats while using native gossip/item controls for unsupported
  later-expansion action bars. Document fidelity substitutions in the chapter guide.

## Authoring and code map

| Source of truth | Generated outputs / implementation |
|---|---|
| `data/quests/broken_seal_campaign.json` | `tools/generate_campaign_manifest.py` renders `docs/broken-seal/README.md`, `catalog.md` and `c01.md`–`c14.md` |
| `data/quests/broken_seal_chapterN.json` | `tools/generate_broken_seal_chapterN.py` renders chapter base/update SQL and `src/BrokenSealChapterNData.h` |
| `data/quests/broken_seal_hubs.json` | `tools/generate_broken_seal_hubs.py` renders hub SQL/data; `tools/render_broken_seal_hubs.py` renders the layout SVG |
| `data/quests/broken_seal_legacy_outfits.json` | Frozen original 56-preset input for the historical outfit repair generator |
| Current Chapter 1/2 and hub manifests | `tools/generate_broken_seal_polish.py` renders the compatible existing-realm polish update |
| Current Chapter 1–4 and hub manifests | `tools/generate_broken_seal_quality.py` renders the ownership-gated quality update for installed chapters |

Edit manifests/generators, then regenerate; do not hand-edit generated artifacts.
Changing current manifests must not expand or rewrite the frozen historical outfit
repair. Follow the same approach for the separate `data/npcs/` rosters.

Runtime scripts live in `src/broken_seal_chapterN.cpp`; pure progression/safety
helpers live in `src/BrokenSealChapterN.h`; integration helpers connect chapters.
Hub runtime is `src/broken_seal_hubs.cpp`. Appearance implementation is in
`src/CustomNpcAppearanceMgr.*`, `src/CustomNpcOutfit.h` and
`src/mod_customnpcs_appearance.cpp`.

Register new scripts in `src/mod_customnpcs_loader.cpp` and add documented options
to `conf/mod_customnpcs.conf.dist`. Preserve both loader symbols for compatibility.

Use C++20, four-space indentation, Allman braces, east const and typed NPC flag
helpers. Use `EventMap`/chrono for timed scenes. Store GUIDs, not raw object pointers,
across ticks; resolve objects when needed and check ownership/map/phase/liveness.
Inspect the actual core hook signatures before implementing new integrations.

## SQL and installation contracts

- This module's SQL lives in `data/sql/db-world/base/` and `updates/`. The core's
  own historical SQL has separate restrictions; do not edit core base/archive SQL.
- Preserve module ownership/collision checks in `mod_customnpcs_bs_content`, with
  chapter 0 reserved for hubs. Read manifest allocations before reserving new IDs.
- Keep imports idempotent on both `creature.id1` and legacy `creature.id` schemas.
  Preserve surviving spawn GUIDs and per-spawn outfit overrides. Prune only known
  retired campaign spawn keys with their ownership markers.
- Never bypass intentional dependency/collision errors with `mysql --force`.
  Ownership guards use deliberate duplicate-key failures. Do not replace safe
  upserts with broad DELETEs merely to satisfy a generic SQL style rule.
- Fresh campaign installation order: appearance schema, Chapter 1, Chapter 2,
  Chapter 3, Chapter 4, then full hub SQL. Full hubs require all four chapters.
- Existing Chapter 1/2 realms use
  `2026_10_07_03_broken_seal_world_polish.sql`; it does not require Chapters 3/4.
  For installed Chapters 3/4, also reapply their current base SQL and full hub SQL
  to receive their compact layouts. Follow the world-polish guide for the sequence.
- The polish migration restores only unchanged native homes moved by the old hub
  add-on. Preserve later administrator edits and the native backup records.
- Existing realms then apply `2026_10_07_04_broken_seal_campaign_quality.sql` for
  authored quest text/maps, item presentation, ordinary loot and hub directions.
  Later chapters and hubs are optional; only installed module-owned content is updated.
  Quest requirements, branch gates, spawns and outfit overrides remain intact. New
  hub text/menu IDs and Chapter 3 Nala text 4001465 are collision-guarded.
- Source changes require a rebuilt/restarted worldserver. SQL-only changes and
  appearance reloads do not replace a new runtime binary. Configuration disable
  stops interactions/scenes; it is not a content uninstall.

## Validation workflow

Run relevant checks after changes; avoid a full core configure/build unless the
user explicitly asks. Read the target core's `AGENTS.md` before working there.
The usual local checkout is the sibling `../azerothcore-wotlk-1`, but scripts accept
`--core-root`; do not assume another machine has that path or temporary cached data.

Fast campaign checks:

```bash
python3 tools/generate_campaign_manifest.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
git diff --check
```

The Python suite checks generated chapter/hub/polish/quality SQL, headers, outfits and
progression. For changed behavioral helpers, compile/run the appropriate standalone
test; all six use this form:

```bash
g++ -std=c++20 -Wall -Wextra -Werror -Isrc tests/broken_seal_chapter1_tests.cpp -o /tmp/bs-c01-tests
/tmp/bs-c01-tests
```

Other tests are `broken_seal_chapter2_tests.cpp`, `broken_seal_chapter3_tests.cpp`,
`broken_seal_chapter4_tests.cpp`, `broken_seal_hubs_tests.cpp` and `outfit_tests.cpp`.

Use `tools/check_broken_seal_cpp.py --core-root /path/to/core src/changed.cpp` for
syntax-only checks against actual core headers. `--boost-root` and repeated
`--extra-include` arguments supply installed dependency headers when required.

For placement, appearance or migration changes, use the corresponding asset and
SQL verifiers. Representative commands:

```bash
python3 tools/verify_broken_seal_outfits.py --client-data /path/to/native/data
python3 tools/audit_broken_seal_world_polish.py --client-data /path/to/native/data --core-root /path/to/core --nav-probe /path/to/nav_probe
python3 tools/verify_broken_seal_hub_assets.py --client-data /path/to/native/data --nav-probe /path/to/nav_probe
python3 tools/verify_broken_seal_world_polish_sql.py --core-root /path/to/core --socket /path/to/disposable/test.sock
python3 tools/verify_broken_seal_hub_sql.py --core-root /path/to/core --socket /path/to/disposable/test.sock
python3 tools/verify_broken_seal_quality_sql.py --core-root /path/to/core --socket /path/to/disposable/test.sock
```

SQL fixtures create/drop randomly named test databases; run them against a disposable
MariaDB instance, not the live realm. The polish fixture loads shipped Chapter 1/2
SQL from commit `1f7c966`, so it needs that Git history. The quality fixture needs
the prior implemented revision `3eccb67`. The native navigation probe
source is `tools/broken_seal_nav_probe.cpp`; client-data/MMAP inputs are external.

Latest recorded validation: 40 campaign Python tests; six standalone C++ tests;
runtime syntax checks; native asset/terrain/navigation audits; and SQL imports and
reimports on both creature schemas. Upgrade fixtures preserved 154 native NPCs,
155 native objects and their quest links. Quality upgrades also passed twice with
Chapters 1–2, 1–3 and 1–4 installed, preserving spawns, progression definitions
and outfit overrides while checking text, icons, map slots and ordinary/quest loot.
These results describe the tested revision,
not a permanent guarantee for future edits.

**Still pending:** full worldserver build, realm installation and stock-client
playthrough. Offline navigation does not test collision with newly spawned camp
models. Verify clothing/weapons, ground-level prop alignment, two players with
different disguise states, shared escort claims, interrupted/resumed trials, native
harpy/Gaea quests and full quest-to-reward flow. State exactly which checks ran;
never claim deployment or visual verification from offline tests.

## Handoff and commits

Inspect `git status` and existing changes before editing; preserve unrelated work.
Commit when requested, with a description of the resulting behavior and validation.
Do not push, deploy or write to a live realm solely because a local commit was requested.
Keep guides and this file aligned with source/manifests, especially when a later
chapter becomes playable or in-game verification resolves a listed limitation.
