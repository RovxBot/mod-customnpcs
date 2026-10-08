# Chapter 3: installation and gameplay

Chapter 3, **The Dawnchaser Promise**, implements 12 quests for levels **30–35** using native 3.3.5a content.

[Source gameplay and travel review](source-review.md) records the checked source objectives, current distances, native-client substitutions and remaining acceptance work. Its October 8 controls supersede the earlier marker-based layouts.

## Installation

Apply the current [Chapter 3 base SQL](../../data/sql/db-world/base/broken_seal_chapter3.sql) after the appearance schema and earlier chapters. Reapplication preserves surviving spawn GUIDs, quest IDs/history and spawn appearance overrides. Ownership and dependency failures are intentional; do not import with `mysql --force`.

Existing Chapter 1/2 realms receive the core correction through `2026_10_08_00_broken_seal_source_gameplay.sql`. For installed Chapters 3/4, reapply their current base SQL in chapter order before restarting the rebuilt worldserver. Do not install an optional chapter merely to run the correction.

Enable the module and `ModCustomNPCs.BrokenSeal.Chapter3.Enable`. The ordinary world phase remains unchanged. A rebuilt/restarted binary is required for the new AI; SQL and appearance reloads are insufficient.

## Quests and controls

| Entry | Quest | Current action |
|---:|---|---|
| 900300 | Search Party | Find Chezin at the ruined scouting camp and recover his report. |
| 900301 | Poisoned! | Collect 5 poisoned blades from relic raiders and bring them to Dezco. |
| 900302 | Skitterer Stew | Gather 8 skitterer meat and help prepare food for the weakened camp. |
| 900303 | Blind Them! | Kill the relic raider outrider watching the expedition. |
| 900304 | Threat from the Marsh Ruins | Defeat 8 relic raiders before their next camp attack. |
| 900305 | Herbal Remedies | Collect 12 marsh lotus leaves and help Kang prepare a second treatment. |
| 900306 | The Relic Raiders' Agenda | Kill the relic raider dominator and recover his excavation orders. |
| 900307 | The Pools of Youth | Speak to Na Lek, defeat four bound pool guardians, and bring the purified water to Kang. |
| 900308 | Life | Stay near the medical tent through Leza's delivery and Nala's care for the family. |
| 900309 | A Quiet Vigil | Attend the memorial and accept Leza's keepsake without a combat objective. |
| 900310 | For the Living | Deliver food to 3 refugee groups and speak with Dezco about his sons and remaining expedition. |
| 900311 | Leave a Place Better | Deliver the village introduction letter to Mei at the affected settlement. |

## Story and interactions

Start at Dezco after rewarding the Chapter 2 letter. Chezin is represented by a protected dead-pose native actor with a physical abandoned pack. The poison investigation requires five real poisoned blades from raiders rather than a tent/antidote scene.

The two parallel branches and later three-way ALL join remain intact. The neutral campaign uses a hostile raider outrider in place of the source faction scout. A raider dominator carries the excavation orders, replacing the earlier cache and rune-device clicks.

Na Lek is represented by a native water elemental at an actual pond. Speak to him to fight four bound guardians with healing aid. Earth elementals replace the unavailable quilen art. Success gives the purified sample; full bags or interruption preserve the guardian counter. Speak to Na Lek again to recover the sample after all four victories.

Nala starts the ordered private birth scene. Leza dies during the scene; Redhorn and Cloudhoof must both remain alive before credit. The medical tent is shelter. Dezco starts the memorial vigil; Kang prepares stew from the collected meat. These contacts replace the tent, fire and cooking scene buttons.

The family-delivery continuation uses the three refugee NPCs and consumes distinct food bundles. It ends with Kang's letter to Mei. The shared camp, dwarf representations of Kang/Mei, new vigil and neutral expedition are declared campaign adaptations.

## Recovery and isolation

Scene actors and pool guardians are private and accept only the owner's appropriate interactions and controlled-unit damage. Progress uses native quest counters/history. Nala presents both surviving sons after the recorded birth scene; the boys are not cots acting as credits.

Contacts reissue the letter and missing family-delivery bundles. Na Lek resumes remaining guardians or recovers the earned sample. Unique copies in the bank must be retrieved. The old antidote is reserved compatibility content and is no longer a Poisoned! supply.

Death, logout, abandonment, map/phase change, configuration disable, distance and timeout stop personal scenes. Tent, memorial and camp scenery are unselectable. Native friendly contacts and resting-area guards remain in their camp; no native quests or spawn homes are moved.

## Verification and client acceptance

The source review lists exact offline checks and the required client acceptance scenarios. No full worldserver build, realm deployment or stock-client playthrough is claimed. Terrain/navigation checks do not verify collision with newly spawned models or final clothing/weapon presentation.

```bash
python3 tools/generate_broken_seal_chapter3.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
python3 tools/render_broken_seal_source_review.py --check
```
