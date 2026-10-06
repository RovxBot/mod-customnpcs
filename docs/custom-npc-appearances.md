# Player-style NPC appearances

The appearance framework renders ordinary creatures as equipped WotLK player
characters. You can choose race, gender, skin, face, hair, facial hair, eleven
armor slots, and three weapon slots. It uses the client's mirror-image protocol;
no MPQ patch, custom display ID, or core modification is needed for WotLK assets.

The NPC remains a creature. Its template, spawn, trainer lists, gossip, SmartAI,
faction, level, spells, and combat stats still control its behavior. Outfit `class`
is a **rendering** choice (for example, death knight appearances), independent of
`creature_template.unit_class`. Equipment is cosmetic and adds no item stats.

## Install

1. Rebuild AzerothCore with this module.
2. Apply `data/sql/db-world/base/custom_npc_appearances.sql` to the world database
   for a fresh installation. Existing installations receive the equivalent
   `2026_10_05_00_custom_npc_appearances.sql` through the module DB updater.
3. Leave `ModCustomNPCs.Enable = 1` and `ModCustomNPCs.Appearance.Enable = 1` enabled.
4. Restart worldserver. After that, outfit changes need only a reload.

The schema installation creates empty tables. The separate
[Orgrimmar preset migration](orgrimmar-trainers.md) assigns researched appearances
to this module's 20 later-expansion trainers.
The [Stormwind presets](stormwind-trainers.md) add another 14 trainers, with
custom outfits and native-model alternatives where NPC-only skins require them.

## Create and edit in game

These commands require administrator security (level 3). Select the NPC before
using commands that assign, clear, or inspect an appearance.

For example, make a female tauren outfit and give it a weapon:

```text
.customnpc outfit create 100 6 1
.customnpc outfit set 100 skin 0
.customnpc outfit set 100 face 0
.customnpc outfit set 100 mainhand 19019
.customnpc outfit apply 100
```

Use `set 100 chest <item entry>` and the other armor fields to dress the NPC.
All slots initially contain zero, so a new outfit has no visible armor or weapons.
A tunic does not supply trousers: configure the `legs` slot explicitly. A robe
can cover the leg region, but campaign presets still define trousers underneath.
An outfit replaces all visible equipment while assigned.

Alternatively, equip your GM character and capture its look:

```text
.customnpc outfit capture 100
.customnpc outfit apply 100
```

`capture` creates or **overwrites** that outfit. It copies your race, gender,
customization, visible armor (including hide-helm/hide-cloak and the core's
mirror-image transmog hook), guild ID, and equipped weapon item entries. Temporary
morphs and weapon transmog appearances are not captured.

| Command | Result |
|---|---|
| `.customnpc outfit create <id> <race> <gender>` | Create an unused, nonzero outfit ID. |
| `.customnpc outfit capture <id>` | Save your character's appearance to that ID. |
| `.customnpc outfit set <id> <field> <value>` | Edit one field and refresh assigned NPCs. |
| `.customnpc outfit apply <id>` | Assign to every spawn of the selected NPC entry, including future spawns. |
| `.customnpc outfit spawn <id>` | Override the selected saved spawn only. |
| `.customnpc outfit spawn 0` | Keep this spawn's original look despite an entry assignment. |
| `.customnpc outfit clear` | Remove the selected entry's assignment. Spawn overrides remain. |
| `.customnpc outfit clearspawn` | Remove this spawn's override; its entry assignment takes effect again. |
| `.customnpc outfit info` | Show the selected NPC's effective outfit and customization. |
| `.customnpc outfit reload` | Reload records edited through SQL. |

`create`, `set`, and `reload` also work from the server console (without the dot).
Changes refresh loaded NPCs on their next map update and apply to unloaded NPCs
when they spawn. Reload recreates affected client objects to clear cached armor;
nearby players may see a brief visual refresh. No restart is needed.

Supported `set` fields:

```text
race gender class skin face hair hair_color facial_hair guild_id
head shoulders shirt chest waist legs feet wrists hands back tabard
mainhand offhand ranged
```

## IDs and equipment

| Race ID | Race | Race ID | Race |
|---|---|---|---|
| 1 | Human | 6 | Tauren |
| 2 | Orc | 7 | Gnome |
| 3 | Dwarf | 8 | Troll |
| 4 | Night elf | 10 | Blood elf |
| 5 | Undead | 11 | Draenei |

Gender is `0` for male and `1` for female. Class accepts WotLK player class IDs
`1–9` and `11`; `6` selects death knight rendering. Skin, face, hair, hair color,
and facial hair are zero-based customization indices for the chosen race/gender,
not display IDs. Choose combinations available to that character in 3.3.5a;
capturing a character is the easiest way to get a known-valid combination.
The loader checks byte ranges through the SQL schema but does not validate every
combination of customization indices against character sections.

Armor values mean:

- `0`: hide this slot.
- Positive: an item entry, resolved through `item_template` or `Item.dbc`.
- Negative: the negated **ItemDisplayInfo.dbc** ID, not a creature display ID.

For example, `set 100 head -12345` selects item display 12345 if it exists in
the server DBCs. Main hand, off hand, and ranged accept **item entries only**;
zero hides them. Weapons must exist in the client's `Item.dbc`. Item and display
IDs are checked when loading or editing an outfit. A bad outfit is rejected as a
whole and logged, rather than partly applied. Use armor suitable for the slot;
the loader verifies the display's existence, not its inventory type.

For the expedition courier and campaign preset corrections, see the
[outfit repair guide](broken-seal/outfit-repair.md). The expanded `info` command
prints configured armor values and their resolved native display IDs.

## Database and reusable definitions

- `mod_customnpcs_outfit`: one appearance per `outfit_id`.
- `mod_customnpcs_outfit_entry`: `creature_entry` → `outfit_id`.
- `mod_customnpcs_outfit_spawn`: `creature.guid` → `outfit_id`, overriding the entry.

Spawn overrides use the **database spawn GUID**, not the runtime object GUID.
Outfit IDs are ordinary nonzero IDs in this module's table; never put them into
`creature_template_model.CreatureDisplayID` or `.npc set model`.
Keep a valid stock fallback model on the NPC template. It is used before an
outfit is assigned, when the framework is disabled, and after an assignment is
removed. Dressing preserves the NPC's scale and melee reach. Clearing an applied
appearance restores the model, gender, scale, and weapons saved when the outfit
was first applied.

For an example using your existing Nubmage entry:

```sql
INSERT INTO mod_customnpcs_outfit
    (outfit_id, race, gender, class, mainhand)
VALUES (100, 8, 0, 8, 19019)
ON DUPLICATE KEY UPDATE race = VALUES(race), gender = VALUES(gender),
    class = VALUES(class), mainhand = VALUES(mainhand);

INSERT INTO mod_customnpcs_outfit_entry (creature_entry, outfit_id)
VALUES (4000000, 100)
ON DUPLICATE KEY UPDATE outfit_id = VALUES(outfit_id);
```

This example deliberately changes Nubmage's appearance only when you execute it.
Use a separate SQL file per later-expansion recreation to keep its identity,
placement, outfit, and role reviewable together. Several NPCs may share one outfit.
Deleting an outfit or assignment in SQL requires `.customnpc outfit reload`.
Stale references are logged and ignored; foreign keys are omitted to support
existing AzerothCore content import workflows.

## Behavior and client limits

Respawns reapply the assigned outfit. Spell transforms, shapeshifts, real mirror
images, and script morphs suspend outfit rendering; restoring the normal model
allows the outfit to resume. Changing the NPC entry selects its new assignment.
Config reloads disabling appearances restore loaded dressed creatures on their
next update. Catalog reloads publish immutable data so parallel map updates do
not read containers being modified by the world thread.

This builds new combinations of **assets already in the 3.3.5a client**. It can
approximate Cata/MoP NPCs using WotLK player races and gear. Worgen, playable
goblins, pandaren, later armor meshes, and later maps need client ports and remain
outside this stock-client framework. Goblin NPC models existing in Wrath do not
make the Cataclysm playable goblin customization system available.

The mirror-image technique has client limitations: NPC portraits can be
inconsistent, NPC-only skins may not render, and automatic greeting sounds can
be absent. Creature text and scripted sounds continue to work. Do not assign the
same NPCs through another dressing module that handles mirror-image requests.

Protocol background: [Rochet2's Dress NPCs](https://rochet2.github.io/Dress-NPCs.html)
and [AzerothCore's module port](https://github.com/azerothcore/mod-dress-npc).

## Verification

The standalone protocol/lookup tests need only a C++17 compiler:

```bash
g++ -std=c++17 -Wall -Wextra -Werror -pedantic -Isrc tests/outfit_tests.cpp -o /tmp/customnpcs-outfit-tests
/tmp/customnpcs-outfit-tests
```

On a test realm, create and apply an outfit, change an armor slot without changing
race/gender, leave and reenter visibility, and relog. Check a second spawn, a
spawn override, `spawn 0`, and `clearspawn`. Kill/respawn a dressed NPC, exercise
a temporary transform, then clear the entry assignment and reload config with
the appearance toggle disabled. Verify restored model/weapons and unchanged
trainer/gossip/AI behavior. Confirm ordinary mage mirror images still render.
