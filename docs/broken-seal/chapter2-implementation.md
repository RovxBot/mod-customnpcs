# Chapter 2: installation and gameplay

Chapter 2 implements all **23 quests** in [Inside the Twilight](c02.md), for levels
**25–30**. The three training branches remain parallel and all are required.
The campaign continues from Chapter 1's existing Ortell and bound Jarod, with
private trials, native Wrath quest progress and six final signet choices.
No client patch or imported Cataclysm/Pandaria assets are required.

Implementation is present in the repository. A full worldserver build, deployment
and stock-client playthrough have **not** been performed. Balance, visibility,
item targeting and scene presentation still need the acceptance run below.

The [shared hub add-on](hub-implementation.md) provides native camp dressing and
ambient-mob safety. Its manifest records the corresponding public-enemy clearances.

## Install

1. Rebuild AzerothCore with this module, including `AddBrokenSealChapter2Scripts`
   in the existing module loader.
2. Apply the appearance schema, then Chapter 1, then
   [broken_seal_chapter2.sql](../../data/sql/db-world/base/broken_seal_chapter2.sql)
   to the **world** database. For an existing installation the matching
   [2026_10_06_01 update](../../data/sql/db-world/updates/2026_10_06_01_broken_seal_chapter2.sql)
   follows Chapter 1's update through the module updater. Use the base file or its
   identical update; both support reapplication.
3. Enable `ModCustomNPCs.Enable`, `ModCustomNPCs.Appearance.Enable`,
   `ModCustomNPCs.BrokenSeal.Chapter1.Enable` and
   `ModCustomNPCs.BrokenSeal.Chapter2.Enable`, then restart worldserver.

```bash
mysql -u<user> -p acore_world < data/sql/db-world/base/custom_npc_appearances.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/broken_seal_chapter1.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/broken_seal_chapter2.sql
```

The SQL checks ownership in `mod_customnpcs_bs_content`, rejecting missing Chapter 1
or unowned occupied IDs before content changes. An intentional duplicate-key error
means that check failed; do not bypass it with `mysql --force`. Spawn GUIDs and
spawn-specific outfit overrides survive reapplication. Both `creature.id1` and
legacy `creature.id` schemas are supported. No character database migration is used.

## Start and locations

Reward Chapter 1's **900108**, reach level **25**, then speak to the same Ortell
at the eastern Charred Vale camp. He offers **900200: Signed in Blood**. The cult
instructors stand farther west in the valley. All positions are native map **1**.

| Contact | Entry | World X | World Y | World Z |
|---|---:|---:|---:|---:|
| Ortell | 4001001 | 1120.0000 | 1550.0000 | 34.5478 |
| Condenna | 4001200 | 892.0000 | 1610.0000 | -20.9751 |
| Cargall | 4001201 | 894.0000 | 1643.0000 | -12.0580 |
| Mylva | 4001202 | 862.0000 | 1592.0000 | -24.1901 |
| Devoran | 4001203 | 915.0000 | 1600.0000 | -15.9102 |
| Prisoner | 4001002 | 990.0000 | 1730.0000 | -9.6758 |
| Jarod Free | 4001204 | 1110.0000 | 1545.0000 | 29.1725 |
| Dezco | 4001205 | -3970.0000 | -3350.0000 | 39.3928 |

The freed Jarod is personal. After rewarding Twilight Riot, ask Ortell to call him
at the refuge. This remains available after relogging and replaces an expired actor.
Dezco's neutral field camp is beside the Tabetha road in Dustwallow; he accepts the
letter from either faction. Install [Chapter 3](chapter3-implementation.md) to continue with Dezco at level 30
after rewarding 900222. Chapter 3 uses an explicit prerequisite; Chapter 2 keeps
its standalone `NextQuestID` at zero.

The [implementation manifest](../../data/quests/broken_seal_chapter2.json) records
all coordinates, outfits, IDs, native asset choices and navigation results.

## Quest IDs and controls

Each ALL join uses the core's **negative exclusive groups**, which also control
quest visibility, and explicit rewarded-quest conditions for acceptance. Completing
one branch never opens the graduation stage by itself.

| Server ID | Title | Required rewarded predecessors | Interaction |
|---:|---|---|---|
| 900200 | Signed in Blood | 900108 | Use Recruit Rendezvous; wait for the private recruit to reach cover, then target him with the blackjack. |
| 900201 | Your New Identity | 900200 | Present altered papers through Condenna gossip. Renew cover with the papers or a handler. |
| 900202 | Trial By Fire | 900201 | Defeat 8 Trial Fire Elementals while disguised; ordinary hostile combat. |
| 900203 | In Bloom | 900201 | Gather 8 blossom items from the western grove. Each patch regrows for that player after 60 seconds. |
| 900204 | Waste of Flesh | 900201 | Ask Cargall to start; target each of 3 distinct burning recruits with the gem within 45 seconds. |
| 900205 | Twilight Training | 900202, 900203, 900204 | Ask Mylva and Devoran for their introductions, then return to Condenna. |
| 900206 | Physical Training: Forced Labor | 900205 | Pick up one load from the stone pile and deliver it on foot; repeat 5 times. |
| 900207 | Agility Training: Run Like Hell! | 900206 | Use course start, then click checkpoints A/B/C/D in order within 60 seconds. |
| 900208 | Mental Training: Speaking the Truth to Power | 900207 | Use the orb near Mylva; answer 10 yes/no questions through private gossip, 5 seconds each. |
| 900209 | Spiritual Training: Mercy is for the Weak | 900208 | Defeat 5 Failed Supplicants while disguised; the cult trial retains its lethal story beat. |
| 900210 | Walking the Dog | 900205 | Use the leash near Devoran; lead the personal hound to A/B/C and command feeding in order. |
| 900211 | A Champion's Collar | 900210 | Defeat the matriarch and loot the guaranteed quest hide. |
| 900212 | Grudge Match | 900211 | Call the collared hound; command attack/pounce on Butcher, then defeat Gromm'ko with the hound alive nearby. |
| 900213 | Gather the Intelligence | 900205 | Gather both documents from separate caches and check the dedicated dead drop. |
| 900214 | Seeds of Discord | 900213 | Use Discord marker, distract private Karr'gonn through gossip, then defeat Azennios within 60 seconds. |
| 900215 | The Greater of Two Evils | 900209, 900212, 900214 | Use the talisman beside Garnoth's marker; defeat the private opponent while in fire form. |
| 900216 | Twilight Territory | 900209, 900212, 900214 | Defeat 10 Horrorguards at the contested Legion approach. |
| 900217 | Speech Writing for Dummies | 900215, 900216 | Use Okrog's marker, defeat him, receive cue cards; Ortell replaces cards after the recorded kill. |
| 900218 | Head of the Class | 900217 | Ask Ortell for final instruction, then report to Mylva. |
| 900219 | Graduation Speech | 900218 | Use podium; match 10 crowd moods with Inspire/Incite/Pander, then speak to Jarod at the altar. |
| 900220 | Twilight Riot | 900219 | Ask bound Jarod to challenge the guard. Recover key, use restraints, defeat 3 pairs of enforcers, escort Jarod to refuge. |
| 900221 | The Buyers Behind the Banner | 900220 | Recover the ledger from its own cache south of the document chest. |
| 900222 | A Letter Through the Marsh | 900221 | Call freed Jarod through Ortell; accept his letter and deliver it to Dezco. Choose one of 6 signets. |

Speech responses allow ten seconds; successful responses are separated by a
nine-second pause. Correct orb answers and crowd responses are native persistent
counts, so an interrupted attempt retains them. Answer menus carry an offer ticket:
replaying an old menu cannot answer a new prompt. Wrong or late answers end that
attempt. New yes/no prompts use original short questions written for this adaptation.

## Entities and assets

| Namespace | Reserved IDs | Contents |
|---|---|---|
| Quests | 900200–900222 | All 23 records |
| Creatures | 4001200–4001229 | Instructors, private scene actors and combat mobs |
| Credit creatures | 4001250–4001274 | 25 invisible objective records; no static spawns |
| Gameobjects | 4001300–4001320 | 21 templates, including eight flower patches |
| Items | 900200–900215 | 16 quest items and tools |
| Reward items | 900216–900221 | Six level-30 signets, usable from level 25 |
| Outfits/text/menus | Corresponding actor entry | Chapter-owned resources; bound Jarod also gets text/menu 4001002 |

Ortell **4001001** and bound Jarod **4001002** keep their Chapter 1 templates and
scripts. Chapter 2 adds quest relations and separate gossip integration, and upgrades the
Chapter 1 cult scouts/guards to a disguise-aware SmartAI wrapper; later
freed Jarod uses a personal clone so another player's prisoner stays in place.

Condenna and Mylva use native female humans; Devoran a native male human; Jarod a
male night elf; Dezco a male tauren. Cargall uses a human instructor reconstruction:
his exact source race/outfit remains unverified. Native cult outfits reproduce the
roles and silhouettes rather than claim exact expansion costumes. Gromm'ko uses a
native ogre mage, Butcher a native raptor, hounds a scaled native core hound,
Spinescale a native basilisk and Garnoth a scaled native pit lord.

The disguise uses **4329**, a native cosmetic transform to creature **32293**,
display **27889**. Fire form uses **4933**, transforming to native Burning Exile
**2760**, display **2172**. Neither changes player faction, phase or class abilities.
Supplicants use cosmetic immolation **42726** with a separate 45-second rescue timer.
Blackjack **39865** and gem **34665** supply native any-unit target cursors; their item scripts handle
the chapter actions and acknowledge the native item-use packet.

The hound's attack/pounce/return/feeding controls use ordinary gossip. Its damage,
health and the player's own combat abilities replace the later pet action bar.
The talisman exits an existing shapeshift; taking another form ends its trial.
Fire form uses the player's ordinary abilities, rather than importing
the original trial's spell/action set. These are deliberate stock-client adaptations.

All displays, outfit items, object models, item displays, spells and map-area IDs
were checked against native 3.3.5a DBCs. All **80 ground points** and **16 route
segments** passed the native map/navigation checks. This verifies asset presence
and reachability, not appearance quality, line of sight, stock mob interference or
combat tuning in a running realm.

## Recovery and multiplayer behavior

- Ortell and Condenna replace active quest tools. Mylva and Devoran also replace
  active training tools. Supplies are unique; retrieve a banked copy before requesting
  another. Quest loot and cache documents are recoverable from their normal sources.
- Grudge Match supplies both leash and collar through recovery gossip. Notes are
  replaced only after Okrog's kill is recorded. Failed restraint encounters can be
  repeated to recover a key, including after a full-bag failure.
- Each player runs one private trial at a time. Private fights award quest progress
  and quest rewards; public combat mobs retain ordinary kill XP. Actors use summoner visibility and
  explicit owner checks for commands, damage, kill credit and scene safety. Shared
  markers/caches never consume another player's scene or progress.
- Public combat credit follows the tagged player and nearby living group members in
  the same map/phase. Each member must have the active quest, and public trial
  fire/supplicant kills require that member's disguise for credit. The two chapters' custom
  cult scouts and guards suppress their own aggro against a disguised player; Smolderos,
  elemental trials, rival demons and the existing world retain their normal behavior.
- Combat, mounting, flight, death, departure, quest abandonment, logout or a disabled
  chapter end incompatible trials. Completed native counters survive. The course
  resets its current route; a dropped stone load must be picked up again.
- The disguise and fire form are removed on death, logout, abandonment, disable or
  leaving the valley or changing phase. Login clears campaign cosmetics saved during an unexpected stop.
  Player-owned transient state lives in `Player::CustomData` and is not shared globally.
- Jarod pauses when the owner enters combat and resumes afterwards. Each escape wave
  must be defeated before movement resumes. Escape credit requires all three waves,
  Jarod at the refuge and the living owner close beside him, out of combat.

## Verification

The implementation has passed content/progression tests, standalone C++ trial-policy
checks, warning-clean C++ syntax checks against the local AzerothCore headers, and
native asset/navigation validation. MariaDB fixtures passed on both creature schemas:
23 quest rows, all branch conditions, shared Chapter 1 relations, GUID-preserving
reimports, unrelated-content preservation, eight collision guards and missing-Chapter-1
rejection. The changed C++ files pass the core style checker; the repository-wide
checker reports two existing west-const declarations in `npc_nubmage.cpp`. The
core SQL formatter passes whitespace, basic syntax style and engine checks; its
semicolon/backtick heuristics report valid multiline UPSERTs, aliases and SQL
functions. Executable MariaDB fixtures provide syntax and reapplication validation.

```bash
python3 tools/generate_campaign_manifest.py --check
python3 tools/generate_broken_seal_chapter1.py --check
python3 tools/generate_broken_seal_chapter2.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal_chapter*.py'
clang++ -std=c++20 -Wall -Wextra -Werror -Isrc tests/broken_seal_chapter2_tests.cpp -o /tmp/bs-c02-policy
/tmp/bs-c02-policy
python3 tools/verify_broken_seal_chapter2_assets.py --client-data /path/to/extracted/data --nav-probe /path/to/nav_probe
python3 tools/verify_broken_seal_chapter2_sql.py --core-root /path/to/azerothcore-wotlk --socket /path/to/test.sock
```

The SQL verifier only creates randomly named `customnpcs_c02_test_*` databases and
removes them afterwards. Use a disposable MariaDB instance. The asset verifier's
optional probe reads `p x y z` and `r x y z x y z` commands against native map-1 mmaps;
the DBC audit can run independently without that probe.

## In-game acceptance run still required

1. Use Alliance and Horde characters. At level 24 or without reward of 900108, verify
   no 900200 offer. At level 25 with the reward, begin through existing Ortell.
2. Run two players together through the recruit knockout and burning recruits.
   Verify personal visibility, targeted-item cursors, unlocked item icons, distinct
   credit, timed deaths and retry after saving only one or two recruits.
3. Pass identity, cancel/reapply the disguise, gather blossoms and fight the trial
   elementals. Verify guards ignore covered players but Smolderos remains hostile.
4. Finish the first trials in different orders. Verify Training requires all three,
   then verify both instructor introductions. Complete the three training branches
   in different orders; Greater/Territory must require all three terminal quests.
5. Repeat pickup or delivery clicks, mount with a load, and relog while carrying.
   Verify five real deliveries. Try course markers out of order, let the timer expire,
   enter combat and leave the course. Complete A/B/C/D on foot within sixty seconds.
6. Answer orb questions correctly, incorrectly and after the deadline. Reopen/replay
   menus. Verify one credit per offer and ten total; relog after partial progress.
7. Feed a hound at a repeated station and at the wrong station. Relog after one feed,
   call a replacement and finish the other stations. Delete and recover leash/collar.
8. Challenge Butcher, use attack/pounce/return controls, let the hound die, then retry.
   Verify Gromm'ko follows the raptor and credit requires a living nearby hound.
9. Fill bags before hide/documents/key/notes/ledger grants. Free space and use the
   documented source/recovery action; verify there is no permanent progression block.
10. Distract Karr'gonn, try attacking Azennios early, exceed the distraction timer,
    then finish quietly. Test Garnoth in fire form on a druid and a non-shapeshifting
    class; verify native appearance restoration after death, logout and completion.
11. Test all three speech moods, wrong/late choices, cooldowns and partial-progress
    relog. Verify speech alone does not finish the quest until Jarod is approached.
12. Defeat the restraint guard, free private Jarod and complete three two-enforcer
    waves. Interrupt movement with unrelated combat; verify pause/resume and no
    escape credit before the refuge. Fail mid-route, recover the key and retry.
13. Reward Riot, relog, ask Ortell to call Jarod, recover ledger and deliver the letter
    to Dezco. Confirm both factions can use the neutral camp and choose one signet.
14. Abandon/reaccept each scripted quest, change map/phase, disable/re-enable the
    config and relog. Verify no remaining personal actors, cosmetics or carrying state.

## Source checks and adaptation boundaries

The donor progression retains the three complete branches and ALL joins described
in [Mental Training](https://warcraft.wiki.gg/wiki/Mental_Training:_Speaking_the_Truth_to_Power).
That source also identifies ten timed yes/no successes; the questions here are newly
written. The [Graduation Speech reference](https://wowpedia.fandom.com/wiki/Graduation_Speech)
identifies the Inspire/Incite/Pander mood controls retained through gossip.
[Gromm'ko's source](https://warcraft.wiki.gg/wiki/Gromm%27ko) confirms the raptor
round preceding his own attack. [Devoran](https://warcraft.wiki.gg/wiki/Instructor_Devoran),
[Mylva](https://wowpedia.fandom.com/wiki/Instructor_Mylva) and
[Condenna](https://wowpedia.fandom.com/wiki/Condenna_the_Pitiless) support the native
human cast choices. Counts, locations, new dialogue, loot/reward budgets and escape
waves follow this campaign's accepted adaptation rather than reproduce every original
Blizzard implementation detail.
