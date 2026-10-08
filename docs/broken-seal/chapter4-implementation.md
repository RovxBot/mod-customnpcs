# Chapter 4: installation and gameplay

Chapter 4, **The Village That Gave Up**, implements 12 quests for levels **35–40** using native 3.3.5a content.

[Source gameplay and travel review](source-review.md) records the checked source objectives, current distances, native-client substitutions and remaining acceptance work. Its October 8 controls supersede the earlier marker-based layouts.

## Installation

Apply the current [Chapter 4 base SQL](../../data/sql/db-world/base/broken_seal_chapter4.sql) after the appearance schema and earlier chapters. Reapplication preserves surviving spawn GUIDs, quest IDs/history and spawn appearance overrides. Ownership and dependency failures are intentional; do not import with `mysql --force`.

Existing Chapter 1/2 realms receive the core correction through `2026_10_08_00_broken_seal_source_gameplay.sql`. For installed Chapters 3/4, reapply their current base SQL in chapter order before restarting the rebuilt worldserver. Do not install an optional chapter merely to run the correction.

Enable the module and `ModCustomNPCs.BrokenSeal.Chapter4.Enable`. The ordinary world phase remains unchanged. A rebuilt/restarted binary is required for the new AI; SQL and appearance reloads are insufficient.

## Quests and controls

| Entry | Quest | Current action |
|---:|---|---|
| 900400 | Ken-Ken | Find Ken-Ken and inspect the village together. |
| 900401 | What's Eating the Village? | Question the three despondent residents about what is wrong with the village. |
| 900402 | Finding Yi-Mo | Find Yi-Mo on the marsh trail east of the village. |
| 900403 | Cheer Up, Yi-Mo | Speak to Yi-Mo and bring him back to the village. |
| 900404 | Materia Medica | Gather 4 chunks of honeycomb, 4 mudfish and 4 salty cores for Ken-Ken's remedy. |
| 900405 | Why So Serious? | Collect 18 panther fangs and the jar of pigment from the eastern marsh. |
| 900406 | Apply Directly to the Forehead | Treat 8 villagers with the mask and defeat the released lesser manifestations. |
| 900407 | The Well Beneath the Ward | Take a sample of the tainted water collected beside the old village well. |
| 900408 | Zhu's Despair | Defeat 8 lesser manifestations, treat Yi-Mo, then defeat the Quintessence of Despair with Ken-Ken's help. |
| 900409 | Hands Back to Work | Relight 3 hearths and help 3 recovered villagers restart the village services. |
| 900410 | When You Need Us | Accept the village's pledge of aid and nominate Mei as its future supply liaison. |
| 900411 | The Families in the Hills | Deliver the Wildhammer introduction letter to Iain at the neutral Hinterlands gathering. |

## Contacts, materials and stages

Start at Mei after rewarding the Chapter 3 letter. Ken-Ken remains a native gorilla representation; Yi-Mo, Mei and Kang use the documented native humanoid representations. The eight resident targets and ordered despair fight are retained.

Finding Yi-Mo is now a visit to the person on the eastern marsh trail. The next quest starts his guided walk home, with a predator encounter. His private contact appears at the trail before return, while the saved village contact becomes visible after return progress; there is no simultaneously abandoned village copy or pack acting as an escort button. Native walking replaces the source's later rolling/kicking controls.

Materia Medica collects four honeycomb pieces from native hives, four fish from a fishing hamper and four cores from weeping marsh horrors. The hamper is the explicit native-setting replacement for catchable fish. Why So Serious? then collects eighteen panther fangs and a pigment jar. The mask is supplied for the subsequent treatment quest, rather than tested before its materials exist.

Treat the eight distinct residents with the mask and defeat their private manifestations. A water sample by the actual village well identifies the remaining influence. The finale party appears when the owner approaches the well: eight lesser victories precede Yi-Mo's treatment and the boss. No well/stone scene-start marker is required.

The rebuilding continuation uses the three real hearths and resident service conversations. Restored services, the liaison/pledge and the neutral Hinterlands handoff remain authored campaign steps. Scenery does not globally transform for other players.

## Recovery and isolation

Native counters preserve the return, eight residents, services, hearths and finale milestones. Private enemies require the owner and appropriate controlled units; Ken-Ken can help in the finale. The newly added ordinary panthers and horrors instead use normal public combat, XP, coins and conditional material loot.

Lost masks and the letter are reissued through contact gossip. Materials must be acquired from their actual world objectives. Full bags preserve achieved combat progress; a unique mask or letter held in the bank must be retrieved.

Death, logout, abandonment, map/phase change, mounted/flying state, distance, timeout and configuration disable clean up private actors. The phase remains the normal world phase. Yi-Mo's saved receiving contact keeps its GUID and appearance override; native visibility follows return/finale progress after relog.

## Verification and client acceptance

The source review lists exact offline checks and the required client acceptance scenarios. No full worldserver build, realm deployment or stock-client playthrough is claimed. Terrain/navigation checks do not verify collision with newly spawned models or final clothing/weapon presentation.

```bash
python3 tools/generate_broken_seal_chapter4.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
python3 tools/render_broken_seal_source_review.py --check
```
