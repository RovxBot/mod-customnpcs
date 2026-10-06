# The Broken Seal: full quest and asset inventory

Design inventory, 2026-10-06. **252 quest records; 251 required quests per character** (Alliance and Horde entry quests are alternatives). **14 chapters, levels 20–80.**

**Sources:** 185 source-adapted quest records and 67 new connecting/story quests. Split vision wrappers and renamed counterpart quests count as adaptations, not as additional original Blizzard quests.

**Inventory:** 86 NPC/friendly-actor roles, 69 hostile/training-creature roles, 107 quest items, 2 keepsakes, 84 chapter reward choices, and 44 interactables.

[Complete entity catalog](catalog.md) · [Machine-readable manifest](../../data/quests/broken_seal_campaign.json) · [Campaign proposal](../level-20-80-campaign-proposal.md)

**Chapter 1 now has runtime code and installation SQL.** See [its implementation guide](chapter1-implementation.md). Other chapters remain design inventories.

This expands the accepted proposal into a complete required path. Full training, earthen-warfront, council and vision branches make the inventory larger than the earlier 140–180 estimate. Chapter 1 implementation is present in the repository; no realm deployment or client patch was performed.

## Chapters

| Levels | Chapter | Quest records | Full quest list |
|---|---|---:|---|
| 20–25 | A Job in the Vale | 9 | [C01](c01.md) |
| 25–30 | Inside the Twilight | 23 | [C02](c02.md) |
| 30–35 | The Dawnchaser Promise | 12 | [C03](c03.md) |
| 35–40 | The Village That Gave Up | 12 | [C04](c04.md) |
| 40–45 | A Wildhammer Wedding | 15 | [C05](c05.md) |
| 45–50 | The Stonefather's Son | 32 | [C06](c06.md) |
| 50–55 | An Accord of Stone | 37 | [C07](c07.md) |
| 55–60 | The Settlement at the Edge | 12 | [C08](c08.md) |
| 60–65 | The Road Through Outland | 12 | [C09](c09.md) |
| 65–70 | The Cost of Waiting | 21 | [C10](c10.md) |
| 70–75 | Three Lives in the Tide | 32 | [C11](c11.md) |
| 75–77 | The Northern Trail | 8 | [C12](c12.md) |
| 77–79 | The Binding | 13 | [C13](c13.md) |
| 79–80 | The People Who Remember | 14 | [C14](c14.md) |

## Reading the quest lists

Every quest names the giver and turn-in actor, target/minimum level, faction, ALL/ANY prerequisites, objective, friendly actors, enemies, objects, provided items, acquired evidence and reward choices. Source IDs are only recorded when verified; otherwise the donor title and branch reference are provided. Objective counts, giver changes and local item names are proposed for this adaptation.

The required path is shared after the two alternate entrances. Source zone-opening quests, reputation grinds, dailies, raids and unrelated branches are replaced by expedition handoffs. The full-list claim refers to this adaptation, not every quest in the original expansion zones.

## Required implementation contracts

- All entries and scenes are campaign-owned clones; no stock quest/NPC/AI replacements.
- Original source zone-entry chains, dailies, reputation gates and raids are not imported.
- Parallel branches use explicit all/any prerequisites, not the preceding table row alone.
- Shared reusable mob roles require separate level/stat variants for each band.
- No later spell IDs or display IDs are inserted without native data validation.
- Scene ownership, retry and logout/death/abandon recovery must be implemented for every staged objective.
- All item pickups are quest-owned, with deterministic credit/drop supply and no profession gate.
- Earlier relics/pledges persist as completed quest history; tools and component copies are reissued when needed.
- Reward item names and stat archetypes are fully enumerated; numeric budgets and exact native icons are implementation audits.
- Every chapter ends in one of six native-display ring choices. Two named readable/visual keepsakes supplement them.
- Creature donor IDs describe verified stock appearance candidates only; they are not final custom entries.
- Npc services/faction state and normal city guards are not globally modified.

## Specific fidelity changes

- Native humanoid outfits recreate later cast members; exact race/outfit is still audited where explicitly marked.
- Yi-Mo, Mei, Kang and the Suna-party pandaren are openly recast into native races. Ken-Ken uses a native animal approximation.
- The World Pillar becomes a new local ward network, and Therazanes visible role becomes a council emissary.
- Mogu/yaungol/mantid become named native raider/Silithid counterparts; later sha visuals become a local shadow curse.
- Source vehicle/action-bar interactions use native controls or specified item/gossip equivalents. The final colossus uses timed ground weak-point attacks.
- The native North Sea Kraken represents Ozumat during the last vision; no exact Ozumat or QuelDormir geometry is claimed.

## Implementation audits still required

Final custom database allocations, individual spawn quantities/coordinates, reachable paths, exact native item/gameobject displays, outfits, spell IDs, AI, loot tables, numeric item/XP budgets, and scene recovery are not production-ready. The manifest supplies the complete named design inventory; these are build details to resolve before importing content. Generic crowd/mob roles need multiple spawns and, where specified, multiple level/state templates.

Ordinary quests supply additional leveling XP. Chapter openings are level-gated; the final record quest requires level 80. All required encounters are designed for solo completion with scripted allies, with difficulty still to tune.

## Validation and regeneration

```bash
python3 tools/generate_campaign_manifest.py --check
python3 tools/generate_campaign_manifest.py --check --core-root /path/to/azerothcore-wotlk
```

The generator checks unique IDs, valid catalog references, dependency cycles, faction reachability, chapter level continuity, six-choice reward groups, dead-character availability and catalog usage. The optional read-only core check verifies that each specified stock appearance donor exists with a model. It does not validate client animation or in-game placement.

Edit the JSON manifest, then run the generator without `--check` to update the documents. New connecting quests and proposed objective counts are original design work. Some source pages were accessible through indexed excerpts; individual donor-ID and behavior verification continues during implementation.

## Source references

- [Hyjal cult infiltration](https://warcraft.wiki.gg/wiki/Mount_Hyjal_quests)
- [Hyjal cast](https://warcraft.wiki.gg/wiki/Mount_Hyjal_NPCs)
- [Orb mental training](https://warcraft.wiki.gg/wiki/Mental_Training%3A_Speaking_the_Truth_to_Power)
- [Basilisk collar task](https://warcraft.wiki.gg/wiki/A_Champion%27s_Collar)
- [Replacing the ogre speaker](https://warcraft.wiki.gg/wiki/Speech_Writing_for_Dummies)
- [Horrorguard territory task](https://warcraft.wiki.gg/wiki/Twilight_Territory)
- [Krasarang Thunder Cleft](https://warcraft.wiki.gg/wiki/Krasarang_Wilds_storyline)
- [Life](https://www.wowhead.com/mop-classic/quest=30131/life)
- [Zhu's Watch](https://warcraft.wiki.gg/wiki/Zhu%27s_Despair)
- [Wildhammer wedding](https://warcraft.wiki.gg/wiki/Wild%2C_Wild%2C_Wildhammer_Wedding)
- [Middle World Pillar branch](https://warcraft.wiki.gg/wiki/Template%3AMiddle_World_Pillar_Fragment_quests)
- [Deepholm cast](https://warcraft.wiki.gg/wiki/Deepholm_NPCs)
- [Lower World Pillar branch](https://warcraft.wiki.gg/wiki/Template%3ALower_World_Pillar_Fragment_quests)
- [Fire Camp Osul and Hatreds Vice](https://warcraft.wiki.gg/wiki/Townlong_Steppes_storyline)
- [The Point of No Return](https://www.wowhead.com/quest=30784/the-point-of-no-return)
- [Battlemaiden vision progression](https://warcraft.wiki.gg/wiki/Shimmering_Expanse_quests)
- [First battlemaiden vision](https://warcraft.wiki.gg/wiki/Visions_of_the_Past%3A_The_Invasion_of_Vashj%27ir)
- [Final Judgment](https://warcraft.wiki.gg/wiki/Final_Judgment)
- [The Binding](https://www.wowhead.com/cata/quest=26971/the-binding)
- [Stoneplow convergence](https://warcraft.wiki.gg/wiki/Valley_of_the_Four_Winds_storyline)
- [The Savior of Stoneplow](https://www.wowhead.com/mop-classic/quest=30627/the-savior-of-stoneplow)
