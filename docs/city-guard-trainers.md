# City guard directions for additional trainers

City guards can direct players to all 78 trainers added by this module in
Orgrimmar, Stormwind, Ironforge, Darnassus, Thunder Bluff and Undercity.

Ask a guard for a **Class Trainer** or **Profession Trainer**, then choose a named
entry such as **Druid: Shalla Whiteleaf** or **Jewelcrafting: Theresa Denman**.
The guard shows a response and places the usual flag on the map/minimap at that
trainer's converted Wrath X/Y location. Response menus include links back to the
trainer list and the guard's main services menu. All original directions remain.

Stormwind's **Riding: Darlene Stokx**, **Flying: Bralla Cloudwing**, and
**Pet training: Alma Deering** appear directly in the guard's main menu.
Alma's service is Wrath hunter pet training. Directions also cover services absent
from a city's original list, including Darnassus's shaman/warlock trainers and
Undercity's hunter/shaman/druid trainers.

Thunder Bluff responses identify the relevant rise or main bluff. Warlock
directions explicitly say to go **below Spirit Rise**, beneath the shaman
platform; the native POI packet supplies X/Y rather than a floor or Z coordinate.
Undercity responses specify the underground city.

## Installation

Guard menus and their points of interest are server world-database data. A client
MPQ cannot add these directions. The existing `patch-F.MPQ` remains the flight-map
patch and is unchanged; these directions work with the ordinary 3.3.5a client.

For an existing installation, the module updater applies
[`2026_10_06_02_city_guard_trainers.sql`](../data/sql/db-world/updates/2026_10_06_02_city_guard_trainers.sql)
after the trainer updates. Restart worldserver so its gossip, NPC text and POI
caches reload.

For a fresh installation, apply all six trainer rosters and Orgrimmar's
`later_expansion_appearances.sql` first, then:

```bash
mysql -u<user> -p acore_world < data/sql/db-world/base/city_guard_trainers.sql
```

Restart worldserver afterward. No C++ changes or extra client installation are
required for this update.

The update adds options to the existing shared city menus, so guards and
patrollers using those menus receive the same directions. It does not modify
guard templates, combat AI, factions, existing menu options, native POIs or
trainer curricula. Silvermoon and the Exodar have no additional trainer rosters
in this module and receive no changes.

## Maintenance and verification

Names, curricula and marker positions come from the six
[`data/npcs/*_trainers.json`](../data/npcs/) rosters. Marker positions use
`position`, including terrain corrections, rather than `source_position`.
Regenerate after changing trainer placements. If trainers are moved manually in
the world database, update the roster and regenerate the guard SQL to match.

```bash
python3 tools/generate_city_guard_trainers.py
python3 tools/generate_city_guard_trainers.py --check
python3 -m unittest discover -s tests -p 'test_*.py'
```

Direction menus, NPC text and POIs reserve IDs **4100005–4100599**. Each derives
from the trainer entry plus 100000, so reordering rosters preserves references.
New options use slots **100–199** in the affected native menus. Installation
rejects occupied native slots, conflicting leaf-menu text references, missing
native city menus, or additions exceeding the client's 32-option menu limit
before changing persistent data. Reapplication updates the same rows.

The database verifier imports native AzerothCore guard/gossip data into a randomly
named disposable database, checks every guard-to-trainer path, marker and back
link, then verifies reapplication, native-data preservation and conflict rejection:

```bash
python3 tools/verify_city_guard_trainers_sql.py \
  --core-root /path/to/azerothcore-wotlk --socket /path/to/test-mariadb.sock
```

It requires a local test MariaDB/MySQL instance where the user can create and
drop test databases. It never selects the realm's world database.

In game, speak to a guard in each city, select a class and profession addition,
and follow each flag to the named trainer. Check Stormwind's three extra main-menu
services and Thunder Bluff's warlock/shaman levels. Verify that the original
directions and both back links still work. Database checks cannot verify the
client's visual presentation or the deployed realm's map modifications.

Server behavior follows AzerothCore's
[`gossip_menu_option`](https://www.azerothcore.org/wiki/gossip_menu_option)
(`ActionMenuID` / `ActionPoiID`) and
[`points_of_interest`](https://www.azerothcore.org/wiki/points_of_interest) tables.
