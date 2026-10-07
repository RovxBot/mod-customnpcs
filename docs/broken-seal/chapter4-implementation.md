# Chapter 4: installation and gameplay

Current layouts, appearance defaults and captive/trial controls are described in the
[world polish upgrade](world-polish.md). Its install and recovery instructions take precedence over older placement notes.

**The Village That Gave Up** implements the accepted **12 quests**, levels **35–40**,
continuing through Chapter 3's existing Mei Barrelbottom. The story follows Ken-Ken's
village investigation, Yi-Mo's rescue, medicine and mask treatment, the well encounter,
rebuilding and a letter to Iain Firebeard in the Hinterlands. Ordinary questing supplies
additional leveling XP.

The [accepted design](c04.md) and [implementation manifest](../../data/quests/broken_seal_chapter4.json)
list the full route. The donor finale requires eight lesser manifestations before
Yi-Mo's mask treatment and the released Quintessence; those beats remain in this
adaptation. [Zhu's Despair source](https://www.wowhead.com/mop-classic/quest=30090/zhus-despair).

Implementation and offline checks are complete. **A full worldserver build, realm
installation and stock-client playthrough remain pending.** All models and spells
are native 3.3.5a assets; no client patch or character database migration is required.

## Install and start

1. Rebuild the module with `AddBrokenSealChapter4Scripts`, the shared Mei gossip
   integration and the updated hub runtime.
2. Install the appearance schema and Chapters 1–3, then apply
   [broken_seal_chapter4.sql](../../data/sql/db-world/base/broken_seal_chapter4.sql).
   The matching [2026_10_07_01 update](../../data/sql/db-world/updates/2026_10_07_01_broken_seal_chapter4.sql)
   contains identical content; use the base file or the update.
3. Apply the current [hub base](../../data/sql/db-world/base/broken_seal_hubs.sql)
   or [2026_10_07_02 hub expansion](../../data/sql/db-world/updates/2026_10_07_02_broken_seal_chapter4_hubs.sql)
   **after Chapter 4**. Existing three-chapter hubs upgrade without replacing GUIDs.
   The earlier `2026_10_06_03` update remains available for installations through Chapter 3.
4. Enable `ModCustomNPCs.Enable`, `ModCustomNPCs.Appearance.Enable`, all four chapter
   options and `ModCustomNPCs.BrokenSeal.Hubs.Enable`, then restart worldserver.
5. At level **35**, after rewarding **900311**, speak to Mei **4001405** at her
   Mudsprocket relief station. She offers **900400: Ken-Ken**.

```bash
mysql -u<user> -p acore_world < data/sql/db-world/base/broken_seal_chapter4.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/broken_seal_hubs.sql
```

The import requires the owned Chapter 3 handoff, checks occupied resource IDs before
content changes, and preserves existing chapter relations, GUIDs and spawn outfit
overrides. Intentional duplicate-key errors indicate a failed dependency or ownership
check; do not bypass them with `mysql --force`. Both `creature.id1` and legacy
`creature.id` schemas are supported. Reimport retains shared Mei's Chapter 3 template,
outfit, quest relations and ownership.

Disabling Chapter 4 stops its scripted interactions, hides its quests in Mei's
shared gossip menu and removes gossip/quest flags from its other contacts. The two
new resting areas require Chapter 4's enabled option; earlier hubs keep their own
activation requirements. Installed scenery and templates remain in the database.

## Quests and controls

| ID | Title | Required rewarded predecessors | Interaction |
|---:|---|---|---|
| 900400 | Ken-Ken | 900311 | Ask Ken-Ken to inspect the village; remain nearby for the 12-second observation. |
| 900401 | What's Eating the Village? | 900400 | Gather six safe food bundles; question the provisioner, herbalist and toolkeeper separately. |
| 900402 | Finding Yi-Mo | 900400 | Use the marked trail sign, stay beside private Yi-Mo, defeat the stalker and escort him through five path points. |
| 900403 | Cheer Up, Yi-Mo | 900402 | Recover three food bundles at the trail crate; encourage Yi-Mo at the relief camp. |
| 900404 | Materia Medica | 900401, 900403 | Gather eight herb sprigs, then ask Kang to prepare the medicine at his hearth. |
| 900405 | Why So Serious? | 900404 | Target each of the three questioned residents with the mask; ask Ken-Ken to bottle the shared residue. |
| 900406 | Apply Directly to the Forehead | 900405 | Treat eight different residents in Ken-Ken's indicated order; defeat each privately released manifestation before continuing. |
| 900407 | The Well Beneath the Ward | 900406 | Inspect the old well, then obtain the ward rubbing beside it. |
| 900408 | Zhu's Despair | 900407 | Use the well to begin: defeat eight manifestations, mask private Yi-Mo, defeat the Quintessence, then witness the short recovery. Ken-Ken assists in combat. |
| 900409 | Hands Back to Work | 900408 | Relight three separate hearths; help the provisioner, herbalist and toolkeeper restart their services in that order. |
| 900410 | When You Need Us | 900409 | Accept Yi-Mo's written pledge and ask Mei to become the supply liaison. |
| 900411 | The Families in the Hills | 900410 | Deliver Maruut's introduction to neutral Iain in the Hinterlands; choose one of six level-40 signets. |

The food and rescue branches are parallel. Both **900401 and 900403 must be rewarded**
before medicine opens. Their negative exclusive group supplies the core's native ALL
join; explicit rewarded-predecessor conditions reinforce it. The group permits both
branches to be accepted. The final quest has `NextQuestID = 0`; Chapter 5 remains a
design inventory, with only its receiving contact staged here.

## Contacts, hubs and native substitutions

The village relief compound sits on Mudsprocket's southern edge, with three canvas
shelters, bedding, stores, lanterns, a work table and equipment rack. Its **11 scenery
placements, two sentries and working volunteer** connect it to the existing settlement.
Mei's earlier station remains nearby, with a clear approach around its tent. The
neutral Wildhammer gathering has **10 props, two sentries and a volunteer**.

Camp protection repels ordinary ambient roamers and suppresses their damage inside
registered resting areas. It excludes private summoned quest encounters, so treatment
fights remain active. Native homes, roam envelopes, opposing-faction guard access and
scene corridors were audited. The full [hub guide](hub-implementation.md) explains
eligibility, conditional clearances and restoration.

| Contact | Entry | Map | World X | World Y |
|---|---:|---:|---:|---:|
| Shared Mei Barrelbottom | 4001405 | 1 | -4535 | -3235 |
| Ken-Ken | 4001600 | 1 | -4580 | -3250 |
| Yi-Mo Longbrow | 4001601 | 1 | -4588 | -3252 |
| Kang Bramblestaff | 4001602 | 1 | -4575 | -3255 |
| Maruut Stonebinder | 4001603 | 1 | -4582 | -3260 |
| Iain Firebeard | 4001604 | 0 | 80 | -2050 |

Kang and Yi-Mo are native dwarves; Mei retains her existing dwarf recreation. Maruut
retains his tauren recreation. Ken-Ken uses native gorilla display **843**, openly
approximating the hozen. The despair creatures use native shadowfiend display **19110**.
These recreate the accepted cast without importing their later race models.

Eight distinct village residents perform the provisioner, herbalist, toolkeeper,
cook, laborer, wardkeeper, tailor and scout roles. Their greetings and instructions
reflect each player's progress; one player's treatment does not change everyone
else's NPC state. After the finale, Yi-Mo and the residents offer recovered greetings.

The hearth interactables are unlit wood piles. Relighting adds owner-visible native
small-fire creatures for two minutes. Saved hearth objectives remain credited after
logout or visual expiry; speaking to a chapter contact or using a hearth restores
that player's completed fire effects. The same native fire can show Kang's cooking.

Iain stands outside Aerie Peak's faction guards, receives both factions, and has a
verified ground approach from the western Hinterlands. The nearest faction-hostile
native home is approximately **127.5 m** away. Existing Aerie Peak NPCs and services
are untouched; the delivery requires ordinary intercontinental travel.

## Recovery and isolation

- Native quest counters preserve the treatment round, each of the three tests and
  questions, herb gathering, hearths, service sequence and finale milestones.
  No hidden progress quests or custom character tables are added.
- Each treatment selects the next distinct resident from the saved count. The
  released enemy belongs to that player; its defeat is required before credit or
  the next treatment. Repeated, stale or out-of-order mask use grants no extra credit.
- The finale cannot release its boss before eight lesser defeats. Yi-Mo treatment
  precedes boss credit. Retrying after a failed boss preserves lesser-manifestation
  progress and lets the player treat private Yi-Mo again to release a new boss.
- The trail sign retries a failed escort. Escort credit arrives only at the final
  waypoint after the stalker encounter. Yi-Mo's fixed receiving contact remains at camp.
- Death, logout, abandonment, map/phase change, leaving the scene or its eight-minute
  limit clean up private encounters. Mounted/flying players cannot run scenes.
  Ken-Ken, enemies and controllers use GUIDs and check their owner regularly.
- Private enemies accept damage from their owner, controlled units and their private
  Ken-Ken ally. They grant no loot or XP; quest credits go to the owner.
- Contact gossip replaces lost masks and the Wildhammer letter. Crates replenish
  missing food; Kang, Ken-Ken, the ward and Yi-Mo can replace their earned medicine,
  sample, rubbing and pledge while the corresponding quest is held. Inventory
  failures do not consume inputs or award missing item objectives. Unique items
  count banked copies; retrieve a banked mask or letter before using it.

The source camera/fade cinematic and exact sha/hozen/pandaren art are not reproduced.
The native combat, dialogue and per-character recovery preserve the implemented
story beats; shared scenery does not globally transform when one player finishes.

## Verification and live acceptance

Offline checks cover the accepted graph, level gates and ALL join; the eight-resident
sequence, saved-count retries, service order and boss gates; generated SQL/header
consistency; native model paths, icon donors and clothing slots; **49 ground points,
12 travel connections and every quest prop's foundation**. Shared hub checks cover
77 prop/staff ground positions and 26 clear corridor segments. All **65** campaign
and hub outfits have explicit trousers and valid rendering classes.

Disposable MariaDB fixtures pass native/legacy imports, reimports, occupied-ID and
missing-dependency rejection, shared Mei, both maps, earlier chapter GUID retention,
old hub upgrades and backup/restoration. The stock SQL style checker flags the
intentional UPSERT/guard statements and multiline SQL; the executable MariaDB fixtures verify their behavior. Repository-wide
C++ style checks report two existing qualifier issues in `npc_nubmage.cpp`; the
modified runtime sources pass those rules. The historical 56-preset outfit repair stays
unchanged as Chapter 4 is added. Modified runtime sources pass syntax checks against
the current core. Standalone tests exercise progression and hub protection policy.

```bash
python3 tools/generate_broken_seal_chapter4.py --check
python3 tools/generate_broken_seal_hubs.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
clang++ -std=c++20 -Wall -Wextra -Werror -Isrc tests/broken_seal_chapter4_tests.cpp -o /tmp/bs-c04-tests
/tmp/bs-c04-tests
python3 tools/verify_broken_seal_chapter4_assets.py --client-data /path/to/data --core-root /path/to/core --ground-probe /path/to/nav_probe --travel-probe /path/to/nav_probe
python3 tools/verify_broken_seal_chapter4_sql.py --core-root /path/to/core --socket /path/to/disposable/test.sock
```

Before deployment, play both factions with a stock client:

1. Follow all 12 quests from Mei without GM completion. Check parallel acceptance,
   turn-in order, level gates, normal XP/money and all six reward choices.
2. Inspect clothing, gorilla scale/animation, household prop foundations, the well,
   rune, herbs, lamps, fire effects and collisions from ground-level camera angles.
3. Run two players together: verify personal combat, tests, treatment order, hearth
   fire visibility, recovered greetings and credit isolation. Check a caster's
   Ken-Ken assistance as well as melee and pet classes.
4. Interrupt every scene through death, logout, abandonment, distance, phase/map
   changes and config reload. Retry at each partial treatment count and after eight
   lesser kills with a failed/despawned boss. Try duplicate and premature mask uses.
5. Fill bags, destroy or bank each quest item and retry its recovery interaction.
   Complete both food turn-ins and verify the separate Chapter 3 food item is unchanged.
6. Wait for roamers at both new hubs, enter with an existing attack/DoT, and confirm
   private fights remain active. Travel to Iain as Horde without entering Aerie Peak.
7. Tune solo combat, timing, server navigation around spawned collision models and
   any realm-specific spawns or patrols. Reapply updates on staging before live use.
