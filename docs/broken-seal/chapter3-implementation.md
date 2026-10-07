# Chapter 3: installation and gameplay

Current layouts, appearance defaults and captive/trial controls are described in the
[world polish upgrade](world-polish.md). Its install and recovery instructions take precedence over older placement notes.

The Dawnchaser Promise implements all **12 quests**, for levels **30–35**, in
[the accepted Chapter 3 design](c03.md). It continues through Chapter 2's existing
Dezco in Dustwallow, keeps both parallel quest groups, and ends with Kang's letter
to Mei. This is a story route alongside normal leveling, with ordinary XP and money.

Chezin is found dead. Leza's treatment, the birth of Redhorn and Cloudhoof, her death,
and the vigil are staged with native assets. Both sons survive this campaign.
Kang and Mei retain their names and roles as the accepted native dwarf recreations.
No client patch, imported model or cinematic file is used.

Implementation and offline validation are complete. **A full worldserver build,
realm deployment and stock-client playthrough have not been performed.** The live
checks below remain necessary, especially for tent occlusion, infant poses, loot,
combat tuning and interference from the existing marsh population.

## Install and start

1. Rebuild AzerothCore with this module so `AddBrokenSealChapter3Scripts` and the
   shared Dezco gossip integration are included.
2. Apply the appearance schema, Chapter 1 and Chapter 2 before
   [broken_seal_chapter3.sql](../../data/sql/db-world/base/broken_seal_chapter3.sql).
   Existing installs can use the identical
   [2026_10_06_02 update](../../data/sql/db-world/updates/2026_10_06_02_broken_seal_chapter3.sql)
   through the module updater. Use the base file or the matching update.
3. Enable `ModCustomNPCs.Enable`, `ModCustomNPCs.Appearance.Enable` and all three
   `ModCustomNPCs.BrokenSeal.ChapterN.Enable` options, then restart worldserver.
4. At level **30**, after rewarding Chapter 2's **900222**, speak to Dezco
   **4001205** at the same neutral field camp. He offers **900300: Search Party**.

```bash
mysql -u<user> -p acore_world < data/sql/db-world/base/custom_npc_appearances.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/broken_seal_chapter1.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/broken_seal_chapter2.sql
mysql -u<user> -p acore_world < data/sql/db-world/base/broken_seal_chapter3.sql
```

The SQL requires the Chapter 2 ownership markers, Dezco template and final quest.
It rejects unowned occupied IDs before content DML. Intentional duplicate-key
errors mean a dependency or ownership check failed; do not bypass them with
`mysql --force`. Reapplication preserves spawn GUIDs, earlier quest relations,
unrelated content and spawn-specific outfits. Both native `creature.id1` and legacy
`creature.id` schemas are supported. No character database migration is required.

Chapter 3 adds its own greeting and actions to the shared Dezco without replacing
his Chapter 2 template or appearance. Disabling Chapter 3 hides its entries in his
gossip quest menu and stops its scripted interactions; its other contacts lose
quest/gossip flags. Installed world objects and templates remain in the database.

The [shared hub add-on](hub-implementation.md) supplies camp scenery, sentries and
local ambient-mob protection for this chapter. For Chapters 1–3 only, use the historical `2026_10_06_03` hub update.
The current full hub base and expansion update follow Chapter 4.

## Locations

All positions are on map **1**, in Dustwallow. The main camp sits beside the Tabetha
road; the raider dig and pool are south/southeast. Mei's relief station is
southwest, on the Mudsprocket approach, moved out of the original Firemane spawn pocket. Chapter 4's full settlement story
is now implemented in [its installation guide](chapter4-implementation.md).

| Contact/marker | Entry | World X | World Y | World Z |
|---|---:|---:|---:|---:|
| Dezco | 4001205 | -3970.0000 | -3350.0000 | 39.3428 |
| Kang | 4001400 | -3960.0000 | -3347.0000 | 39.3213 |
| Kor | 4001401 | -3965.0000 | -3359.0000 | 37.7857 |
| Nala | 4001402 | -3977.0000 | -3348.0000 | 40.3156 |
| Chezin | 4001403 | -3785.0000 | -3488.0000 | 30.9048 |
| Tent | 4001501 | -3980.0000 | -3358.0000 | 39.9213 |
| Memorial | 4001510 | -3973.0000 | -3338.0000 | 40.6141 |
| Mei | 4001405 | -4535.0000 | -3235.0000 | 31.0057 |

The [implementation manifest](../../data/quests/broken_seal_chapter3.json) lists
all 62 placements, appearances, loot, objective IDs and navigation evidence. Scene
and NPC/object positions were checked on dry ground. Ten travel connections pass
with native ground/water navigation enabled; normal marsh wading/swimming may be
needed, and the route does not require flight or a scripted teleport.

## Quests and controls

Both initial branches must be rewarded before the next group opens. All three
later branches must be rewarded before Pools of Youth. Negative exclusive groups
provide the core's native ALL behavior for visibility and acceptance, supplemented
by explicit rewarded-predecessor conditions. These groups do not make sibling
quests mutually exclusive.

| ID | Title | Required rewarded predecessors | Interaction |
|---:|---|---|---|
| 900300 | Search Party | 900222 | Inspect the lost-camp marker beside Chezin's staged corpse; recover the report/orders. |
| 900301 | Poisoned! | 900300 | Ask Nala or use the medical tent to prepare private Leza; target her with the antidote and remain for 5 seconds. |
| 900302 | Skitterer Stew | 900301 | Loot 8 meat from skitterers, use the cooking hearth with all ingredients, then return to Kang. |
| 900303 | Blind Them! | 900301 | Defeat 6 raiders and disable each of the 3 separate lookout markers. |
| 900304 | Threat from the Marsh Ruins | 900302, 900303 | Loot 8 guaranteed quest insignia from raiders/hexers; return to Kor. |
| 900305 | Herbal Remedies | 900302, 900303 | Gather 12 quest leaves, ask Kang to prepare the remedy, then return the leaves to Dezco. |
| 900306 | The Relic Raiders Agenda | 900302, 900303 | Collect fresh orders, inspect the binding device, then ask Dezco to compare the deposited ledger. |
| 900307 | The Pools of Youth | 900304, 900305, 900306 | Collect the sample at the pool focus and take it to Kang for testing. |
| 900308 | Life | 900307 | Use the tent or Nala's gossip; witness the complete private birth, loss and surviving-twins vignette. |
| 900309 | A Quiet Vigil | 900308 | Use Leza's memorial and remain quietly for 20 seconds; Dezco awards the keepsake at turn-in. |
| 900310 | For the Living | 900309 | Deliver one bundle to each refugee group or its supply crate, then speak with Dezco about the expedition. |
| 900311 | Leave a Place Better | 900310 | Take Kang's letter to Mei and choose one of six signets. |

Gathering and cooking require no profession. Meat, leaves and orders stay in your
bags until the native quest turn-in consumes them. The first orders are consumed
by Search Party; Agenda recovers a fresh copy. The earlier expedition ledger is
already deposited, so its comparison does not require recovering a consumed item.

The pool sample is **tested**, following this campaign's accepted adaptation.
Kang identifies its draining effect and refuses it as medicine. Leza was already
exposed; the sample is not silently administered as a cure.

## Private scenes and recovery

- Leza has no shared world spawn. Preparing the patient creates private Leza and
  Nala; the antidote requires the owner's living patient, nearby nurse, active quest,
  quiet on-foot observer and the item still present after five seconds. Credit and
  consumption occur after that observation, not on clicking the tool.
- Life lasts about **57 seconds**. The delivery occurs behind the tent, then both
  private babies are presented. Dezco attempts to heal Leza, she dies, Nala confirms
  both sons are stable, and Dezco commits to caring for them. Native credit is awarded
  only at the conclusion with the mother dead and both infants alive.
- Interrupted Life attempts award no partial credit and replay the vignette on retry.
  Completing or rewarding Life prevents another living Leza scene. Deliberately
  abandoning an unturned-in quest resets its native progress, as with other quests.
  All quests after Life require its reward, so later story stages cannot spawn her alive.
- Nala can present the living twins again after Life is complete/rewarded, including
  after relogging. Their private appearances expire naturally and can be recalled;
  they are never killed by scene cleanup. No later Cloudhoof death is inserted.
- A Quiet Vigil has no combat objective. Its totem is a fixed native quest reward,
  with normal bag-space checks at turn-in, rather than a repeatable scene item grant.
- Each refugee group has a separate persistent credit. Repeating one group/crate
  consumes no extra food. Recovery at Dezco, Nala or Kang supplies only the bundles
  needed for unfinished groups, counting banked copies toward the total.
- Those contacts also replace a lost antidote or introduction letter. Retrieve a
  banked unique copy first. Meat, leaves, reports, insignia and water samples remain
  recoverable from their original sources. Item-use scripts acknowledge the client
  packet so the targeted antidote does not remain gray.
- Herb patches have per-character 60-second regrowth, recorded only after a successful
  item grant. A full bag does not consume that opportunity or complete an objective.
- Each player can run one story scene at a time. GUID ownership, map/phase and range
  checks prevent another player from using a private patient or receiving its credit.
  Dialogue is whispered to the owner. Death, combat, mounting, flight, leaving the
  scene, abandonment, logout, phase/map changes or disabling the chapter end it.
- Temporary actors use summoner-only visibility and damage protection. Scene cleanup
  despawns them; it does not change the shared Dezco, Nala, camp or another player's
  progress. Mutable node state lives in `Player::CustomData`, not a global player map.

## Entities and native substitutions

| Namespace | IDs | Contents |
|---|---|---|
| Quests | 900300–900311 | All 12 records; both factions |
| Creatures | 4001400–4001416 | 17 templates: contacts, corpse, private family, refugees and enemies |
| Credit creatures | 4001450–4001463 | 14 invisible objective templates; no static spawns |
| Objects | 4001500–4001517 | 18 templates, including 12 herb placements |
| Quest items/keepsake | 900300–900308 | Nine items, including antidote, bundles and memorial totem |
| Reward choices | 900309–900314 | Six level-35 signets, usable from level 30 |
| Shared Dezco | 4001205 | Chapter 2 template retained |
| Chapter 3 Dezco text/menu | 4001464 | Separately owned greeting; native original text remains intact |

Leza and Nala use native female tauren appearances, Chezin and Dezco male tauren,
and Kor a male orc. Kang and Mei use the accepted male/female dwarf recreations of
pandaren roles. Clothing uses the existing outfit system and native item displays;
fallback race displays remain valid with appearances disabled. Raiders and hexers
use native ogres, and skitterers a native marsh spider. Kor remains alive in this
relocation, as the campaign plan specifies.

Redhorn and Cloudhoof use **display 23783**, native model
`World\GENERIC\PASSIVEDOODADS\BABIES\Baby_Ta.mdx`, used by native creature
**26365: Taunka Orphan**. The DBC model link and filename were checked. Their exact
pose, scale, cloth/basket framing and visibility still need stock-client QA; this
is a Wrath substitute for the later infant presentation.

Native baskets frame the children, a human canvas tent screens the delivery, and
ordinary campfire/ruined-tent/rune/chest models supply the camp and dig. Chezin uses
an unselectable, protected dead-pose actor; his report comes from the nearby marker,
and he has no rescue or living dialogue. The antidote's **34665** definition supplies
an any-unit target cursor; its item script owns the treatment. Healing visual **635**
is native Holy Light. Icon donors include Anti-Venom, meat, lotus, water, bread and
Earth Totem; their native abilities are not copied onto these custom quest items.

## Verification and remaining live checks

Passed: 15 chapter content/progression tests; standalone Chapter 3 safety, sequence
and food-recovery checks; warning-clean syntax checks of changed C++ files against
local AzerothCore headers; changed-file C++ style; native asset/target/model auditing;
62 dry positions and 10 ground/water travel routes. Disposable MariaDB checks passed
on both creature schemas: all branch gates, fixed keepsake, three-bundle provision,
quest-only loot, no shared Leza/baby spawns, prior-chapter coexistence and GUID-preserving
reimports, eight collision guards and missing-Chapter-2 rejection.

```bash
python3 tools/generate_campaign_manifest.py --check
python3 tools/generate_broken_seal_chapter3.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal_chapter*.py'
clang++ -std=c++20 -Wall -Wextra -Werror -Isrc tests/broken_seal_chapter3_tests.cpp -o /tmp/bs-c03-policy
/tmp/bs-c03-policy
python3 tools/verify_broken_seal_chapter3_assets.py --client-data /path/to/extracted/data
python3 tools/verify_broken_seal_chapter3_sql.py --core-root /path/to/azerothcore-wotlk --socket /path/to/test.sock
```

For route checks, add `--ground-probe` and `--travel-probe` executables that accept
`p x y z` or `r x y z x y z` commands against map-1 mmaps. They must use filters 1
and 9 respectively. The SQL verifier only creates randomly named
`customnpcs_c03_test_*` databases and removes them on completion; it does not accept
a realm world database name. No realm was updated during implementation.

The core's repository-wide C++ checker has two existing west-const findings in
`npc_nubmage.cpp`; changed files pass independently. The older SQL formatter's
semicolon/backtick heuristics do not handle the valid multiline UPSERT/alias/function
patterns used here; executable MariaDB checks verify their syntax and reapplication.

Before deployment, complete this stock-client run:

1. Test Alliance and Horde characters. Confirm Search Party cannot be accepted before
   level 30 and reward of 900222, and the Chapter 2 letter remains usable normally.
2. Inspect Chezin and his marker, delete/recover the report, then reward Search Party.
   Verify the corpse cannot be healed, recruited or mistaken for a survivor.
3. Prepare Leza on two players simultaneously; target the wrong player's patient,
   delete the antidote mid-observation, fill bags before replacement, then retry.
   Verify no early credit, one successful consumption and independently hidden actors.
4. Finish Stew/Blind in either order. Repeat one lookout; test native party kill credit
   and quest-only meat/insignia loot. Confirm the next three quests require both rewards.
5. Gather leaves without Herbalism, repeat a node and fill bags before a grant. Prepare
   the remedy with Kang. Inspect the apparatus and compare orders in both orders; the
   comparison must wait for the device credit and a held document.
6. Complete Threat/Herbs/Agenda in different orders. Confirm Pools stays locked until
   all three rewards, then test the sample and Kang's diagnosis.
7. Play Life with two characters at different stages. Inspect birth privacy, infant
   models/poses, healing attempts, actual mother death and both surviving sons. Move,
   fight, mount, logout, abandon or change phase mid-scene; confirm no partial credit.
8. Complete/reward Life and relog. Confirm Nala can recall the twins, and Leza has no
   living appearance during Vigil, Living or the settlement handoff.
9. Interrupt/retry the 20-second vigil. Fill bags before the fixed keepsake reward,
   free space and turn in; verify only one totem and no extra scene item grants.
10. Deliver food to one group repeatedly, use its matching crate, bank/delete remaining
    bundles, relog after two deliveries and recover only the outstanding supplies.
    Confirm Dezco's final conversation waits for all three distinct groups.
11. Recover Kang's letter, reach Mei on the native route and choose one signet. Verify
    no unsupported Chapter 4 quest is offered. Check `.reload config` and restoration.

## Source and adaptation boundaries

The [Life reference](https://warcraft.wiki.gg/wiki/Life_%28quest%29) supports the two
parallel quest groups, childbirth/loss scene and draining-water theme.
[Leza](https://warcraft.wiki.gg/wiki/Leza_Farwalker) identifies her relationship to
Chezin and both surviving newborn sons; [Nala](https://warcraft.wiki.gg/wiki/Nala)
supports the female tauren midwife role. [Kor](https://warcraft.wiki.gg/wiki/Kor_Bloodtusk)
is a male orc in the donor story; his later death is deliberately omitted by this
campaign's accepted relocation. The neutral camp, ogre enemies, quest counts, tested
sample, dwarf recasts, new dialogue, vigil and food continuation are campaign choices,
rather than claims to copy every original Pandaria implementation detail.
