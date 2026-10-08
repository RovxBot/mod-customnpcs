[Current source-gameplay review and upgrade](source-review.md) takes precedence over older recorded checks below.

# Chapter 1: installation and gameplay

Current layouts, appearance defaults and captive/trial controls are described in the
[world polish upgrade](world-polish.md). Its install and recovery instructions take precedence over older placement notes.
The October 7 route revision below separates the rescue, ward investigation and observation.

Chapter 1 implements the nine design records in [the quest list](c01.md): one
Alliance or Horde introduction followed by six shared quests. Entry 900108 is a retired compatibility briefing. It uses normal
Wrath quest progress, native items and models, and the module's NPC outfit system.
Install [Chapter 2](chapter2-implementation.md) separately to continue from Ortell at level 25.

The [shared hub add-on](hub-implementation.md) provides native camp dressing and
ambient-mob safety. Campaign encounters remain outside that protection; native
spawns are not relocated.

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

Existing Chapter 1/2 realms apply
[2026_10_08_00_broken_seal_source_gameplay.sql](../../data/sql/db-world/updates/2026_10_08_00_broken_seal_source_gameplay.sql)
after the world-polish and quality updates, then restart with the rebuilt module.
This new update name delivers the changes even when the earlier updates are already
recorded as applied. Chapter 1-only realms can reapply the current Chapter 1 base SQL
instead; the combined upgrade requires Chapters 1 and 2. Characters already on an
observation quest can obtain the new spyglass from Ortell without abandoning it.

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
| Maruut's camp, eastern Charred Vale approach | 1102.0000 | 1542.0000 | 27.0862 | Investigation and tracing |
| Expedition scout | 1102.0000 | 1538.0000 | 26.9476 | Trail and captive quests |
| Ortell | 1100.0000 | 1540.0000 | 26.6937 | Evidence, observation and finale |
| Roadside rescue camp | 950.0000 | 1503.0000 | -6.0385 | Three surveyors and guards; separate from the ritual compound |
| Northwestern ward | 820.0000 | 1830.0000 | -7.6930 | Two Twilight defenders |
| Southwestern ward | 600.0000 | 1770.0000 | -9.9168 | Two Twilight defenders |
| Eastern ward | 730.0000 | 1410.0000 | -10.9772 | Two Twilight defenders |
| Spyglass lookout banner | 952.0000 | 1763.0000 | 9.8547 | Observe the ritual compound from the rise northwest of the altar |
| Captive refuge banner | 1098.0000 | 1540.0000 | 26.3195 | Escort completion point |

The table gives the final ground-adjusted values used by SQL. For example:

```text
.go xyz 1102.0 1542.0 27.086243166456008 1
```

The full placements, model evidence and navigation checks are in
[the implementation manifest](../../data/quests/broken_seal_chapter1.json).

## Quest IDs and interactions

| Server ID | Design record | Playable step |
|---:|---|---|
| 900100 | BS-C01-01 | Alliance: take the invitation to Maruut |
| 900101 | BS-C01-02 | Horde: take the invitation to Maruut |
| 900102 | BS-C01-03 | Inspect the abandoned wagon beside camp; obtain the log |
| 900103 | BS-C01-04 | Inspect the discarded supplies, survey journal and scorched map, defeat six Twilight Scouts, loot one orders document |
| 900104 | BS-C01-05 | Speak to Mira, Dorn and Teren at the roadside guard camp; accompany each to the expedition |
| 900105 | BS-C01-06 | Clear the two Twilight defenders at each of three widely separated wards, then use the tracing kit; obtain the rubbing |
| 900106 | BS-C01-07 | Ask Ortell to compare the deposited evidence |
| 900107 | BS-C01-08 | Use the supplied spyglass beside the lookout banner northwest of the ritual compound and watch Jarod quietly |
| 900108 | BS-C01-09 | Retired compatibility briefing; existing holders finish with Ortell at camp |

Decorative camp objects and the lookout banner are unselectable scenery.
Interactive investigation props highlight for their active quest; unrelated clicks
give a short direction instead of silently doing nothing. Observations use the
spyglass in the player's inventory, with no clickable stone scene starter.

Normal quest POIs identify the objectives and turn-in locations. Friendly contacts
also have a “Where should I go next?” gossip option. Commander observation gives one of
six level-appropriate expedition signets, usable from level 20.

## Progress and recovery

- Each clue, ward and captive has a separate persistent native quest objective.
  Repeating one location cannot complete another objective.
- Captives are visible, kneeling saved spawns. Gossip reserves that NPC for one
  escort at a time; speaking alone grants no credit.
- Captives are protected scene actors. They wait while their owner fights and
  resume afterward. Credit requires arrival at the refuge, a living nearby owner,
  the active quest, and matching map/phase.
- Captives time out after three minutes. Death, logout, abandonment, leaving the
  map/phase or moving more than 80 metres away returns the NPC to its guard post.
  Speak to it again once it is home to retry. Successful escorts remain at camp
  for five seconds, then despawn and respawn at the roadside camp after five minutes.
  Shared spawns remain available to later players; the next quests lead elsewhere. Previously rescued
  people remain credited.
- Each observation is a private timed controller. Remain within eight metres,
  alive, out of combat, and able to see the subject. Commander observation lasts
  at least five seconds. The chapter ends after commander observation; the recruit is contacted directly
  in Signed in Blood. The earlier second lookout trip is no longer offered.
- Observation times out after 45 seconds. Use the spyglass again after an
  interruption. Existing holders of the retired briefing settle both credits locally with Ortell.
- Ortell can replace a deleted spyglass during commander observation. Jarod and
  the ambient recruit have extended creature visibility so they can be seen from
  the roughly 100-metre lookout without changing realm-wide visibility settings.
- Maruut can replace a deleted tracing kit while its quest is active. If there
  is no bag space for the rubbing, the three tracing credits remain; make room
  and use the kit on any ward again. The wagon similarly permits recovering a
  missing log. Native uniqueness rules still apply to copies kept in the bank.
- Evidence already turned in is remembered through rewarded quest history.
  Comparison does not require carrying old documents.

Rescued surveyors are hidden from the player with saved rescue credit/history, while
remaining shared spawns for players who still need them. The world phase is unchanged.

The chapter toggle stops scripted interactions and personal scenes and removes
quest/gossip flags from expedition contacts within two seconds of a config reload.
It is not an uninstall command: the SQL-defined world content remains present.

## Content and reserved IDs

| Kind | Allocated IDs / contents |
|---|---|
| Quests | 900100–900108 |
| Friendly actors | 4001000–4001009; includes three visible, saved captive spawns |
| Enemy actors | 4001010–4001012: Twilight Scout, Twilight Guard, Unbound Earth Elemental |
| Private observation controller | 4001013, invisible native display |
| Objective credit templates | 4001050–4001062, never statically spawned |
| Objects | 4001100–4001116: wagon, discarded clues, wards, lookout scenery, altar, refuge banner and roadside camp props; former cage IDs are reserved |
| Quest items | 900100–900105: invitation, log, orders, rubbing, tracing kit and spyglass |
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
  item entries, item displays and used spells. The route revision checks 49 current Vale positions, all three escort connections
  and the recruit patrol; the two unchanged couriers retain their earlier evidence.
  Ward/lookout/camp props pass native grounding and footprint checks.
  Reference data comes from [AzerothCore client-data v20](https://github.com/wowgaming/client-data/releases/tag/v20.0).

No full worldserver build, realm installation or live client playthrough was run.
The following in-game checks remain necessary: model presentation, clickable
object alignment, sight lines from the observation points, native quest POIs,
combat pacing and the full quest-to-reward flow.

## Reproduce the checks

```bash
python3 tools/generate_broken_seal_chapter1.py --check
python3 tools/generate_broken_seal_flow.py --check
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

For the installed-route upgrade fixture, use the revision before this change as
`--baseline-ref` (the pre-change revision in this checkout was `cbd5fc1`):

```bash
python3 tools/verify_broken_seal_world_polish_sql.py --core-root /path/to/azerothcore-wotlk --socket /path/to/test.sock --upgrade data/sql/db-world/updates/2026_10_07_05_broken_seal_chapter1_flow.sql --baseline-ref cbd5fc1 --baseline-polish
```

The fixture upgrades/reimports both creature schemas, preserves native content,
checks saved captive/ward/course GUIDs and a captive appearance override, verifies
spyglass supplies and unselectable props, and rejects a foreign spyglass item ID
before gameplay changes. Use the actual pre-change revision available in Git.

## Live playthrough checklist

1. Start once as an Alliance level-20 character and once as a Horde level-20 character.
   Confirm the other faction's introduction is not offered and the shared route
   stays locked until the invitation is rewarded.
2. Delete/recover the wagon log; inspect one clue repeatedly; complete all three
   clues and six scout kills; verify the guaranteed quest-only orders loot.
3. Run two players through the same captives. Verify visible kneeling NPCs and one
   owner per escort, independent credit, no credit on speaking, combat pause/resume,
   successful arrival, a five-minute shared respawn, and hidden captives for the rescuer.
   Follow the next quests and verify they do not route through the rescued prisoners. Retry after death/logout/abandonment;
   confirm prior rescues persist.
4. Visit the three separate ward locations and clear their two Twilight defenders.
   Delete the tracing kit and replace it from Maruut. Repeat one ward, then trace
   all three. Fill bags before the final rubbing and recover it after freeing space.
5. Confirm the trail, rescue and ward objectives never require entering Jarod's compound before observation. Compare evidence with Ortell without holding old documents. Delete and replace the spyglass; use it away from the lookout and verify no credit.
   Interrupt both observations with combat, distance and logout. Finish quietly with line of
   sight; verify that the fresh handoff is Signed in Blood after rewarding commander observation.
6. Choose a signet and relog. Verify no repeated reward. With Chapter 2 installed,
   Signed in Blood appears at Ortell only after level 25 and reward of 900107. Check `.reload config` with the chapter disabled and enabled.
