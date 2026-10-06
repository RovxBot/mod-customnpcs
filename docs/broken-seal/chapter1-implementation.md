# Chapter 1: installation and gameplay

Chapter 1 implements the nine design records in [the quest list](c01.md): one
Alliance or Horde introduction followed by seven shared quests. It uses normal
Wrath quest progress, native items and models, and the module's NPC outfit system.
Install [Chapter 2](chapter2-implementation.md) separately to continue from Ortell at level 25.

The [shared hub add-on](hub-implementation.md) provides native camp dressing and
ambient-mob safety. Its manifest records the corresponding public-enemy clearances.

See the [outfit repair](outfit-repair.md) for missing courier trousers and the
installed-preset migration.

## Install

1. Include this module in the AzerothCore build and rebuild worldserver so the
   new `AddBrokenSealChapter1Scripts` registration is present.
2. For a fresh installation, apply
   [custom_npc_appearances.sql](../../data/sql/db-world/base/custom_npc_appearances.sql)
   before [broken_seal_chapter1.sql](../../data/sql/db-world/base/broken_seal_chapter1.sql)
   to the world database. An existing module installation receives the matching
   [2026_10_06_00 update](../../data/sql/db-world/updates/2026_10_06_00_broken_seal_chapter1.sql)
   through the module updater. Use either the base file or the incremental update.
3. Keep `ModCustomNPCs.Enable`, `ModCustomNPCs.Appearance.Enable`, and
   `ModCustomNPCs.BrokenSeal.Chapter1.Enable` enabled, then restart worldserver.

There is no client patch. The appearance toggle supplies the dressed looks;
every actor also has a valid native fallback display.

The SQL rejects occupied custom IDs that this module does not own. It keeps
ownership in `mod_customnpcs_bs_content`. On reapplication it updates its own
templates and placements, preserves spawn GUIDs, and leaves spawn-specific outfit
overrides in place. Installation does not modify the characters database.

## Where to start

All positions are on Kalimdor, map **1**, in Stonetalon Mountains. Quests have a
minimum level of **20**. The two couriers offer race/faction-specific alternatives;
either invitation opens the shared route after it has been turned in.

| Location | World X | World Y | World Z | Purpose |
|---|---:|---:|---:|---|
| Alliance courier, beside the Kaela Shadowspear camp | 746.0000 | 322.0000 | 63.3356 | Alliance introduction |
| Horde courier, Sun Rock Retreat | 956.1060 | 1005.7800 | 102.5642 | Horde introduction |
| Maruut's camp, eastern Charred Vale approach | 1124.0000 | 1546.0000 | 33.2028 | Investigation and tracing |
| Expedition scout | 1118.0000 | 1551.0000 | 35.0452 | Trail and captive quests |
| Ortell | 1120.0000 | 1550.0000 | 34.5478 | Evidence, observation and finale |
| Captive refuge marker | 1012.0000 | 1655.0000 | 0.6661 | Escort completion point |

The table gives the final ground-adjusted values used by SQL. For example:

```text
.go xyz 1124.0 1546.0 33.2028 1
```

The full placements, model evidence and navigation checks are in
[the implementation manifest](../../data/quests/broken_seal_chapter1.json).

## Quest IDs and interactions

| Server ID | Design record | Playable step |
|---:|---|---|
| 900100 | BS-C01-01 | Alliance: take the invitation to Maruut |
| 900101 | BS-C01-02 | Horde: take the invitation to Maruut |
| 900102 | BS-C01-03 | Inspect the abandoned wagon uphill from camp; obtain the log |
| 900103 | BS-C01-04 | Inspect all three distinct signs, defeat six Twilight Scouts, loot one orders document |
| 900104 | BS-C01-05 | Open Mira's, Dorn's and Teren's cages; accompany each to the refuge |
| 900105 | BS-C01-06 | Use the supplied tracing kit on all three distinct ward stones; obtain the rubbing |
| 900106 | BS-C01-07 | Ask Ortell to compare the deposited evidence |
| 900107 | BS-C01-08 | Use the concealed observation stone west of the altar and watch Jarod quietly |
| 900108 | BS-C01-09 | Watch the moving recruit from the dead drop, then agree the extraction signal with Ortell |

Normal quest POIs identify the objectives and turn-in locations. Friendly contacts
also have a “Where should I go next?” gossip option. The final reward is one of
six level-appropriate expedition signets, usable from level 20.

## Progress and recovery

- Each sign, ward and captive has a separate persistent native quest objective.
  Repeating one location cannot complete another objective.
- Cages summon a player-private captive. The brief door-opening animation is
  shared, but it does not consume the cage, lock another player out, or grant credit.
- Captives are protected scene actors. They wait while their owner fights and
  resume afterward. Credit requires arrival at the refuge, a living nearby owner,
  the active quest, and matching map/phase.
- Captives time out after three minutes. Death, logout, abandonment, leaving the
  map/phase or moving more than 80 metres away ends the current actor. Open the
  relevant cage again to retry. Previously rescued people remain credited.
- Each observation is a private timed controller. Remain within eight metres,
  alive, out of combat, and able to see the subject. Commander observation lasts
  at least five seconds. Recruit observation additionally waits for an actual
  completed patrol movement; clicking the point alone does not give credit.
- Observation times out after 45 seconds. Click the point again after an
  interruption. Watching the recruit and agreeing the signal are separate goals.
- Maruut can replace a deleted tracing kit while its quest is active. If there
  is no bag space for the rubbing, the three tracing credits remain; make room
  and use the kit on any ward again. The wagon similarly permits recovering a
  missing log. Native uniqueness rules still apply to copies kept in the bank.
- Evidence already turned in is remembered through rewarded quest history.
  Comparison does not require carrying old documents.

The chapter toggle stops scripted interactions and personal scenes and removes
quest/gossip flags from expedition contacts within two seconds of a config reload.
It is not an uninstall command: the SQL-defined world content remains present.

## Content and reserved IDs

| Kind | Allocated IDs / contents |
|---|---|
| Quests | 900100–900108 |
| Friendly actors | 4001000–4001009; three captives are temporary rather than static spawns |
| Enemy actors | 4001010–4001012: Twilight Scout, Twilight Guard, Unbound Earth Elemental |
| Private observation controller | 4001013, invisible native display |
| Objective credit templates | 4001050–4001062, never statically spawned |
| Objects | 4001100–4001113: wagon, signs, cages, wards, observation/dead drop, altar and refuge marker |
| Quest items | 900100–900104: invitation, log, orders, rubbing and tracing kit |
| Rewards | 900110–900115: Might, Precision, Sorcery, Restoration, Guarding and Balance signets |
| Appearance presets | The corresponding dressed creature entry IDs |

These are the campaign's own recreations. Maruut remains a male tauren, Ortell a
male human, and Jarod a male night elf. Clothing uses native Wrath pieces, not an
exact claim about later costumes. Ortell's original identity is documented by
[his character reference](https://warcraft.wiki.gg/wiki/Elementalist_Ortell).

## Validation performed

- Generated base/update SQL and C++ identifiers checked for consistency.
- Both faction prerequisite paths and the four-objective/six-reward client limits checked.
- C++ syntax checked against the local AzerothCore headers with warnings treated as errors.
- Standalone behavioral checks cover repeated-location attempts and interrupted/invalid scene completion.
- SQL imported into disposable MariaDB databases using actual AzerothCore schemas.
  Fresh/repeated imports passed for both `creature.id1` and legacy `creature.id`.
  Spawn GUIDs and unrelated sentinel content survived reapplication. An occupied
  quest ID was rejected before gameplay content was mutated.
- Native client tables checked for all creature/object fallback displays, outfit
  item entries, item displays and used spells. Terrain/navigation checks cover
  all 42 stored positions, all three escort connections and the recruit patrol.
  Reference data comes from [AzerothCore client-data v20](https://github.com/wowgaming/client-data/releases/tag/v20.0).

No full worldserver build, realm installation or live client playthrough was run.
The following in-game checks remain necessary: model presentation, clickable
object alignment, sight lines from the observation points, native quest POIs,
combat pacing and the full quest-to-reward flow.

## Reproduce the checks

```bash
python3 tools/generate_broken_seal_chapter1.py --check
python3 -m unittest discover -s tests -p test_broken_seal_chapter1.py -v
g++ -std=c++20 -Wall -Wextra -Werror -I src tests/broken_seal_chapter1_tests.cpp -o /tmp/bs-c01-tests
/tmp/bs-c01-tests
```

For SQL validation, use a local test server socket and an account with permissions
to create/drop disposable databases:

```bash
python3 tools/verify_broken_seal_chapter1_sql.py --core-root /path/to/azerothcore-wotlk --socket /path/to/test.sock
```

The verifier creates only randomly named `customnpcs_c01_test_*` databases and
removes them on completion. It does not accept a world database name.

## Live playthrough checklist

1. Start once as an Alliance level-20 character and once as a Horde level-20 character.
   Confirm the other faction's introduction is not offered and the shared route
   stays locked until the invitation is rewarded.
2. Delete/recover the wagon log; inspect one sign repeatedly; complete all three
   signs and six scout kills; verify the guaranteed quest-only orders loot.
3. Run two players through the same cages. Verify private captive visibility,
   independent credit, no credit on opening, combat pause/resume, and successful
   arrival. Retry after death/logout/abandonment; confirm prior rescues persist.
4. Delete the tracing kit and replace it from Maruut. Repeat one ward, then trace
   all three. Fill bags before the final rubbing and recover it after freeing space.
5. Compare evidence with Ortell without holding old documents. Interrupt both
   observations with combat, distance and logout. Finish quietly with line of
   sight; verify that the signal remains locked until the recruit was watched.
6. Choose a signet and relog. Verify no repeated reward. With Chapter 2 installed,
   Signed in Blood appears at Ortell only after level 25 and reward of 900108. Check `.reload config` with the chapter disabled and enabled.
