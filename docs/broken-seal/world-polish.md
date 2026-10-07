# Broken Seal: world polish and the Charred Vale upgrade

This pass addresses the Chapter 1/2 playtest feedback and applies the same placement
rules to the four implemented chapters. **The campaign stays in the normal world.**
Native quests, spawns, objects and shared patrols keep their original definitions
and locations. Campaign-owned placements are reorganized instead of clearing native
quest content.

A stock-client visual/playthrough pass is still pending. The SQL and source have been
checked offline; this work has not been installed on the realm by the coding agent.

## What changed

- **Floating signs:** all placeholder signpost models in Chapters 1–4 are replaced
  with physical evidence crates, carved tablets, supplies or camp banners. Required
  interactions keep their objective IDs. Props are anchored using native terrain
  height and model bounds, with checked foundations rather than stump-top navigation
  surfaces. The wagon is relocated to **1098, 1538**, beside the expedition, and uses
  a smaller native wagon with a checked footprint.
- **Captives:** Mira, Dorn and Teren are visible, kneeling NPCs under guard. Speak to
  each to begin an escort. That NPC stands and walks to the expedition; the empty
  cage interactions are removed. One owner can escort a given captive at a time.
  Arrival grants that player's distinct credit. The survivor rests at camp briefly,
  then despawns and respawns at home after a minute. Interrupted escorts walk home
  for another attempt. No duplicate private captive appears.
- **Textures:** every campaign humanoid has a texture-bearing native NPC fallback.
  Twilight instructors, guards, scouts and failed supplicants default to native
  Silithus cult skins rather than bare player base displays. These use explicit
  native appearance assignments and remain textured without the custom outfit
  response. Names and quest roles are retained. The rest of the cast keeps its
  custom wardrobe with a safe native fallback.
- **Weapons:** humanoid equipment templates are populated, saved spawns load their
  equipment, and custom outfits show main-hand weapons in the melee sheath state.
  Cult guards carry swords; instructors carry staves; scouts have visible weapons.
  Captives and bound Jarod remain unarmed.
- **Loot:** ordinary cult scouts, guards and failed supplicants award coin on every
  kill and roll cloth/consumables. Installed stock world-loot references supply
  appropriate incidental drops. The scout orders remain a unique quest-only item;
  their one-time delivery no longer makes later corpses empty. Private summoned
  trial enemies keep no farmable XP/loot.
- **Hostility:** public cult contacts and camp staff use hostile factions. The cult
  accepts a player's valid disguise through a per-player reaction rule; that player's
  controlled units receive the same treatment. Other players remain enemies.
  Private arena opponents, beasts and failed supplicants retain their intended
  combat behavior. Player factions and PvP flags are unchanged.
- **Fire and demon crowds:** the fire trial and Horrorguard challenge summon one
  opponent at a time for their participant. No permanent fire-trial or Horrorguard
  population remains. Saved native counters resume the eight-fire and ten-Horrorguard rounds.
- **Camp layout:** the four scattered instructors share one small recruiting
  compound on the western verge. The prisoners and ritual occupy a second compact
  camp. The expedition and rescue refuge share one site. Flame blossoms remain
  scattered gathering nodes. Later chapters have smaller hospital/village hubs and
  a compact raider pocket.
- **Architecture:** native Silithus Twilight tablets and camp crates are reused,
  with stock supported cult canvas, banners, torches and equipment. No imported
  architecture or client patch is required.

## Locations and footprint

| Site | Map | Center X / Y | Scope |
|---|---:|---|---|
| Expedition and refuge | 1 | 1100 / 1540 | Small friendly camp, wagon, three contacts and escort destination. |
| Twilight recruiting compound | 1 | 640 / 1626 | Four instructors, limited armed staff, two shelters and shared training lanes. |
| Twilight holding/ritual camp | 1 | 891 / 1680 | Three kneeling captives, Jarod, a small guard group, altar and ritual supplies. |
| Failed supplicant pocket | 1 | 600 / 1651 | Two ordinary enemies away from the quest contacts. |
| Dawnchaser hospital | 1 | -3970 / -3350 | 23 m resting radius; contacts and families grouped around the medical area. |
| Village relief compound | 1 | -4580 / -3250 | 20 m resting radius; existing Mudsprocket services remain outside it. |

The recruiting footprint is **19 m**, instead of four separate stations occupying
much of the Vale. The holding camp is a deliberate encounter area. Cult resting
protection requires a valid disguise; it does not neutralize campaign enemies.
Sentries leave fights outside a resting area alone and repel eligible ordinary
intruders or attackers targeting protected players. Scripted campaign encounters
are excluded from ambient protection.

The [layout plan](hub-layout.svg) and [implementation manifest](../../data/quests/broken_seal_hubs.json)
record props, footprints, corridors and retired campaign spawn keys. Props cannot
overlay native quest objects. No new native spawn relocation is authored; the
upgrade restores unchanged homes moved by the earlier hub add-on, while retaining
later administrator edits and the original backups.

## Install on an existing Chapter 1/2 realm

1. Back up the world database through the realm's usual process and rebuild with
   the updated module. The disguise reaction, shared escorts and private trial
   rounds require the new binary.
2. Apply [2026_10_07_03_broken_seal_world_polish.sql](../../data/sql/db-world/updates/2026_10_07_03_broken_seal_world_polish.sql)
   through the module updater or manually to the **world** database. It can upgrade
   the shipped Chapters 1/2 without requiring Chapters 3/4. Existing earlier update
   names and the historical 56-preset outfit repair are retained.
3. If Chapters 3/4 are installed, apply their current base SQL and then the current
   [full hub base](../../data/sql/db-world/base/broken_seal_hubs.sql) to install the
   later compact layouts. The dated polish update also fixes their existing native
   fallback and prop definitions when present.
4. Restart worldserver. Keep the module, relevant chapter options and hub option
   enabled. There is no phasing setup or character database migration.

```bash
mysql -u<user> -p acore_world < data/sql/db-world/updates/2026_10_07_03_broken_seal_world_polish.sql
```

Reapplication retains surviving campaign spawn GUIDs. Only obsolete campaign-owned
placements are retired; it does not delete native spawns or change their quests.
An intentional duplicate-key error indicates a failed dependency/ownership guard;
do not import using `mysql --force`.

Outfit assignment **0** at a creature entry now explicitly preserves the stock
model, matching the existing per-spawn native override. A custom spawn override
still takes precedence. Use `.customnpc outfit info` to inspect an NPC whose look
differs from the authored defaults. Native cult skins do not require an outfit
packet, while the other cast's custom wardrobes still use the appearance module.

## Gameplay controls and recovery

Enter the cult compound with your altered papers/disguise active. Recover papers
and renew cover at Ortell; carried papers also apply the disguise. Expired cover
makes public cult NPCs hostile again and prevents their ordinary gossip interaction.

Condenna starts or resumes **Trial By Fire** through gossip. Mylva directs the
Horrorguard challenge to the calling tablet at the holding camp. Each round reads
its existing quest count, summons one opponent, credits its defeat and calls the
next. Death, distance, logout or lost cover ends that attempt; prior kills remain
saved. Other players cannot see or damage the private opponents.

Use a captive's gossip after clearing its guards. Stay nearby, protect your own
route and reach the expedition. A busy or returning captive must finish its current
escort before another player claims it. Failure does not erase earlier distinct
rescues. Jarod's riot can be started through his gossip after obtaining the key.

## Verification

The upgrade fixtures import the shipped Chapter 1/2 SQL, apply the polish twice on
both `creature.id1` and legacy `creature.id`, and compare **154 native NPC placements,
155 native object placements and native quest/object links** before and after.
They also check surviving GUIDs, native texture bindings, weapons, normal loot,
retired permanent trial/cage spawns and three visible captives.

The native audit checks **53 textured fallback models**, **85 grounded quest-prop
placements**, model footprint slopes, absence of placeholder signs/cages, three
complete escort paths, and zero fresh native-spawn moves. Wardrobe audits include
65 current actor/staff presets. The old 56-preset repair stays byte-for-byte current.
Runtime sources receive syntax checks against the current core; no full worldserver
build or live-client inspection is claimed.

```bash
python3 tools/generate_broken_seal_polish.py --check
python3 tools/audit_broken_seal_world_polish.py --client-data /path/to/native/data --core-root /path/to/core --nav-probe /path/to/nav_probe
python3 tools/verify_broken_seal_world_polish_sql.py --core-root /path/to/core --socket /path/to/disposable/test.sock
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
```

In the client, check the wagon and tablets from ground-level angles; clothing with
and without appearance rendering; staff/sword visibility; repeated ordinary kills
for coin and cloth; two players with different disguise states; concurrent captive
claims, abandonment and return-home; resumed trial counts; native Gaea mounds and
harpy quests; and navigation around the spawned camp models. Inspect any additional
realm-specific quest objects or patrols before deployment.
