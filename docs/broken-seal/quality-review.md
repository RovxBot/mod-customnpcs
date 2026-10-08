# Broken Seal: implemented-chapter quality review

The [October 8 source-gameplay review](source-review.md) supersedes the earlier
interaction controls below and gives the current upgrade sequence.

Reviewed **7 October 2026**: Chapters **1–4**, levels **20–40**, with **56 quest
records** and six shared hubs. Each faction follows 55 records because Chapter 1
has alternate introductions. Chapters 5–14 remain design work.

Source changes and offline checks are complete. A worldserver build, realm
installation and stock-client playthrough are still needed before accepting the
campaign's visuals and combat pacing as finished.

## Findings and fixes

| Area | Finding | Result |
|---|---|---|
| Quest dialogue | Chapter 2 reused completion lines across unrelated trials, including Jarod's escape. | All 23 turn-ins acknowledge the actual result and lead into the next story beat. |
| Quest guidance | Counter labels exposed internal names such as `Dog A`; completed logs repeated the task. | All 56 records have authored objective labels, an NPC request and a clear return instruction. |
| Quest maps | Chapters 2–4 mapped only the turn-in. Chapter 1's scout objective used a retired population point. | Every required counter and item has its actual interaction location; gathering patches and distinct targets retain separate pins. Item slots use Wrath's indices 4–9. |
| Physical controls | Tablets, lookout crates, supplies and cots shared generic names. Text referred to removed signs. | Props have distinct names matching their role; quest instructions describe the current controls. Agility checkpoints retain their A–D labels. |
| Inventory | Letters/orders used a monster-tail icon. Flowers, gems, hides and the prison key shared a book icon; the blackjack used a gear icon. | Documents, tools and medicine use suitable stock displays with recorded donor IDs. Every item and reward has authored flavor or use instructions. |
| Ordinary enemies | Earth elementals, Smolderos, the matriarch and Chapter 3 enemies lacked incidental loot. Adding quest drops could overwrite an ordinary table. | Ordinary enemies award normal XP and coins. Humanoids roll cloth, supplies and installed stock world-drop references; beasts/elementals drop suitable materials. Orders, hide, meat and insignia remain guaranteed quest-only drops. |
| Combat identity | Most Chapter 2 enemies and marsh beasts shared a melee strike; the fire trial used rank-one player Fireball. | Scouts shoot, cult casters/demons cast shadow bolts, fire creatures use native NPC Fireball, and appropriate beasts use poison. Casts respect an existing cast. Private opponents retain zero XP/loot. |
| Equipment | Chapter 3 ogre enemies lacked held-weapon templates. | Raiders carry melee weapons and hexers carry staves through native equipment templates. |
| Hub residents | Later volunteers had repeated names such as “Camp Camp Volunteer” and no interaction. | Every hub has a distinct work role and local gossip directions, with chapter/configuration and cult-cover checks. Working poses are retained. |
| Story continuity | Refugees were named A/B/C; villagers shared a generic line. Nala still referred to the living patient after Life. | Refugees have distinct identities, villagers describe different troubles, and Nala's later greeting acknowledges the surviving twins. |
| Camp boundaries | A pet fighting outside camp could inherit its resting owner's protection. | Ambient protection and sentry intervention use the controlled unit's own location. |

The compact normal-world layouts, grounded props, textured fallbacks, shared
captives, private trials and native quest populations from the
[world-polish pass](world-polish.md) are retained. No native spawn relocation,
phase layer, imported asset or client patch is added.

The agility adaptation is an ordered, timed, on-foot route; its objective now
describes that challenge. The fire trial is Condenna's separate private encounter.
The blackjack uses a stock wooden-mallet icon and the leash a stock net icon as
recognizable native substitutes for the later quest tools.

## Upgrade an installed realm

Fresh installs use the current chapter bases and full hub base in the
[documented installation order](../../AGENT.md); they already contain these changes.
For an existing realm, complete any outstanding [layout upgrade](world-polish.md),
apply
[2026_10_07_04_broken_seal_campaign_quality.sql](../../data/sql/db-world/updates/2026_10_07_04_broken_seal_campaign_quality.sql),
then rebuild and restart worldserver for the runtime changes.

```bash
mysql -u<user> -p acore_world < data/sql/db-world/updates/2026_10_07_04_broken_seal_campaign_quality.sql
```

The update changes only installed module-owned content. Chapters 3/4 and hubs are
optional; it does not install absent quests/spawns. Reapplication preserves quest
IDs, requirements, branch gates, rewards, spawn GUIDs and outfit overrides. It
does not write character progress or native placements. New hub text/menu IDs and
Nala's text **4001465** have collision guards before campaign changes. A
duplicate-key failure is intentional; do not bypass it with `mysql --force`.

## Verification completed

- **40 campaign Python tests**; **six standalone C++ checks**; warning-clean syntax
  checks against actual core headers; changed-file C++ style; clean diff formatting.
- Native audit: **53 textured fallback models**, **85 grounded quest-prop
  placements**, **65 wardrobe presets**, icon donor/display matches, added weapons,
  loot items and combat spell IDs.
- Navigation: **77 hub positions**, **26 clear corridor segments**, three captive
  routes, and Chapter 2's **80 stored points / 16 routes**. Chapter 3/4 asset,
  tool-targeting and prop-foundation checks also pass.
- Disposable MariaDB: fresh/repeated Chapter 1–4 and hub imports on both
  `creature.id1` and legacy `creature.id`, with dependency/collision rejection.
  The shipped world-polish fixture preserves **154 native NPCs, 155 native objects**
  and their quest links.
- Quality upgrades from revision **3eccb67** pass twice with Chapters 1–2, 1–3 and
  1–4 on both schemas. They verify dialogue, items, map slots, ordinary plus quest
  loot, weapons and hub greetings while preserving spawns, progression definitions
  and outfit overrides. Unowned later-chapter sentinels survive; new text/menu
  collisions reject before changing campaign dialogue.

```bash
python3 tools/generate_campaign_manifest.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
python3 tools/generate_broken_seal_quality.py --check
python3 tools/verify_broken_seal_quality_sql.py --core-root /path/to/core --socket /path/to/disposable/test.sock
git diff --check
```

The quality verifier requires history containing `3eccb67`. Its randomly named
`customnpcs_quality_test_*` databases are removed afterward. Run it against a
disposable database service, never the realm service.

## Remaining client acceptance

Follow each chapter guide's full quest and interruption checks. Also inspect:

1. Objective names/pins on both factions, multiple gathering nodes, the agility
   course, completion instructions and the Hinterlands handoff.
2. Item icons/use instructions, held weapons with appearances enabled/disabled,
   model grounding, infant poses, and cold versus relit hearths.
3. Repeat ordinary kills after turn-in for normal XP/loot, required quest drops,
   private trials for zero farming rewards, and solo combat pacing.
4. Hub directions, cult cover, configuration reloads and pets fighting beyond camp.
5. Two characters at different story stages: Nala and village greetings, private
   scenes, shared captive claims, interrupted/resumed trials, and lost-tool recovery.

Offline navigation cannot verify collision with spawned camp models, visible
weapon/sheath behavior, quest-map rendering or combat feel in the stock client.
