# Additional flight masters in existing Wrath settlements

29 flight masters (12 in Kalimdor and 17 in the Eastern Kingdoms), using existing
3.3.5a town/settlement footprints. The roster includes existing ruined towns;
Andorhal, Moonbrook, Strahnbrad and Hearthglen keep their original Wrath occupants.
Later rebuilding, occupation forces, quests and phase changes are not imported.

All 29 use researched player-style outfits with native race/gender/customization,
clothing equivalents and held weapons. Existing flight masters and the earlier
city trainer rosters are preserved. The Wrath event Handler Marnlek remains
unchanged; a separate entry supplies his later permanent Sen'jin flight service.

## Install the client patch and world update

1. Close the game and copy
   [`patch-F.MPQ`](../data/client/flight-masters/patch-F.MPQ) into each 3.3.5a client's
   `Data` directory. It contains the three taxi DBCs, so the new stops appear on
   the normal flight map. The archive is built against unmodified build-12340
   enUS taxi data; existing records and localized strings are preserved. Other
   taxi DBC modifications require an explicit merge against this baseline.
2. For a fresh world database, apply the appearance schema and then
   `data/sql/db-world/base/flight_masters.sql`. Existing installs use
   `data/sql/db-world/updates/2026_10_05_07_flight_masters.sql` through the module updater.
3. Restart worldserver and the client. Server nodes, routes and waypoints load
   from the standard `taxinodes_dbc`, `taxipath_dbc` and `taxipathnode_dbc` overrides;
   the server's original DBC files remain usable. No new C++ build is needed for
   this addition if the appearance framework is already installed.
4. Discover new stops by speaking to their flight masters. Normal Wrath rules
   for visited destinations, faction mounts, fares, reputation discounts and
   character restrictions apply.

SQL supports `creature.id` and `creature.id1`. Reapplication preserves GUIDs,
spawn outfit overrides, unrelated taxi overrides and earlier city content.
Ownership tables track this module's node/path IDs. Inserts reject collisions
with unowned overrides; only registered overrides belonging to this roster
are removed during reapplication.

## Roster and locations

| Entry | Flight master | Existing settlement | Faction | Taxi node | Map | Wrath X, Y, Z | X/Y move (m) |
|---|---|---|---|---|---|---|---|
| 4000600 | Delanea | Grove of the Ancients | Alliance | 338 | 1 | 4969.770, 145.836, 53.672 | 0.000 |
| 4000601 | Gort Goreflight | Mor'shan Rampart | Horde | 339 | 1 | 1202.190, -2210.240, 101.447 | 0.000 |
| 4000602 | Wind Tamer Shoshok | Silverwind Refuge | Horde | 343 | 1 | 2164.840, -1142.430, 99.692 | 0.000 |
| 4000603 | Zillane | Malaka'jin | Horde | 344 | 1 | -114.644, -263.901, 24.323 | 0.000 |
| 4000604 | John Johnson | Honor's Stand | Alliance | 345 | 1 | -333.434, -1529.570, 94.079 | 0.000 |
| 4000605 | Bill Williamson | Northwatch Hold | Alliance | 346 | 1 | -2124.940, -3562.170, 102.745 | 2.200 |
| 4000606 | Leora | Darnassus | Alliance | 347 | 1 | 9973.320, 2623.920, 1316.890 | 0.000 |
| 4000607 | Fidelio | Dolanaar | Alliance | 349 | 1 | 9873.030, 976.488, 1310.240 | 0.000 |
| 4000608 | Tak | Bloodhoof Village | Horde | 350 | 1 | -2299.890, -378.293, -8.928 | 3.335 |
| 4000609 | Burok | Razor Hill | Horde | 351 | 1 | 271.359, -4769.610, 12.704 | 0.848 |
| 4000610 | Handler Marnlek | Sen'jin Village | Horde | 354 | 1 | -775.776, -4890.740, 20.097 | 0.000 |
| 4000611 | Caleb Baelor | Dun Modr | Alliance | 355 | 0 | -2659.590, -2453.150, 79.842 | 0.000 |
| 4000612 | Eeryven Grayer | Farstrider Lodge | Alliance | 356 | 0 | -5670.810, -4250.310, 407.354 | 4.999 |
| 4000613 | Hoboair | Furlbrow's Pumpkin Farm | Alliance | 360 | 0 | -9836.030, 1273.860, 41.017 | 0.000 |
| 4000614 | Tina Skyden | Moonbrook | Alliance | 361 | 0 | -10876.500, 1543.660, 50.687 | 0.000 |
| 4000615 | Bartlett the Brave | Goldshire | Alliance | 362 | 0 | -9435.710, 87.611, 57.440 | 0.000 |
| 4000616 | Goss the Swift | Eastvale Logging Camp | Alliance | 363 | 0 | -9480.080, -1304.790, 42.291 | 0.000 |
| 4000617 | Yedrin | The Harborage | Alliance | 364 | 0 | -10114.000, -2854.000, 23.546 | 0.707 |
| 4000618 | Anette Williams | Brill | Horde | 365 | 0 | 2272.850, 374.516, 35.179 | 0.000 |
| 4000619 | John Shelby | Raven Hill | Alliance | 366 | 0 | -10732.700, 264.283, 43.785 | 0.000 |
| 4000620 | Brolan Galebeard | Kharanos | Alliance | 367 | 0 | -5664.080, -497.684, 399.139 | 0.000 |
| 4000621 | Dominic Galebeard | Gol'Bolar Quarry | Alliance | 368 | 0 | -5718.930, -1578.470, 383.507 | 0.000 |
| 4000622 | Zaldaan | Azure Watch | Alliance | 369 | 530 | -4126.640, -12523.800, 44.623 | 0.000 |
| 4000623 | Skymaster Brightdawn | Fairbreeze Village | Horde | 370 | 530 | 8743.850, -6651.690, 70.545 | 0.000 |
| 4000624 | Skymaster Skyles | Falconwing Square | Horde | 371 | 530 | 9505.310, -6765.010, 16.921 | 0.000 |
| 4000625 | Rhonda Molver | Andorhal | Horde | 372 | 0 | 1511.600, -1583.940, 65.022 | 0.000 |
| 4000626 | Ginny Goodwin | Andorhal | Alliance | 373 | 0 | 1373.050, -1278.890, 58.792 | 0.000 |
| 4000627 | Phillip Harding | Strahnbrad | Horde | 374 | 0 | 622.903, -981.286, 169.876 | 0.000 |
| 4000628 | William Henderson | Hearthglen | Neutral | 378 | 0 | 2837.170, -1503.590, 146.536 | 0.000 |

Azure Watch, Fairbreeze Village and Falconwing Square are included: they belong
to the requested continents even though the client stores them on map 530.
Stock Outland, Northrend and Quel'Danas services are unchanged.

## Appearances and placements

24 retain source X/Y. Bill, Tak, Burok and Yedrin move less than four metres onto
reachable Wrath ground. Eeryven moves five metres outside the old lodge roof.
Every NPC has a separately checked open landing point roughly two metres away;
heights follow Wrath navigation surfaces +0.10 m. The source facing is retained.
Navigation proves connected ground and checks covered surfaces, but it does not
replace an in-game visual inspection of buildings and flight splines.

Clothing already present in Wrath is retained. John and Bill's later shirt layers,
Hoboair's trousers/boots, Ginny's rusty plate, Phillip's purple mail and William's
shirt have documented native substitutions. Held weapons are checked native
`Item.dbc` entries. Armor uses checked native item-display IDs. Complete source
customization, original/converted coordinates, settlement evidence and per-slot
substitutions are in [`flight_masters.json`](../data/npcs/flight_masters.json).

## Network and routes

110 directed routes create 55 local connections with return flights. They join
nearby stock Wrath hubs using existing flight corridors. These are adaptations
for the older terrain, rather than imported Cataclysm route geometry. The original
Wrath network records, paths and waypoints are retained. New connector sections
are sampled against Wrath terrain with at least 60 metres of clearance; native
hub approaches are retained, including the Ironforge gate and Undercity entrance.
The approach reverses for return flights. New events and delays are zero.

Fares scale the reused native corridor's fare by travel distance, with a minimum
of 25 copper. Reputation discounts and normal taxi charging remain core behavior.
Only faction-compatible mounts/destinations are connected. All new node IDs
occupy unused native slots within the 448-node Wrath mask; existing IDs and
spell/quest transport nodes are preserved. The route definitions and baseline
hashes are in [`later_flight_network.json`](../data/taxi/later_flight_network.json).

The patch adds flight-map stops without new town geometry. Locations such as
Bilgewater Harbor, Fort Triumph, Fuselight, Bogpaddle, Bootlegger Outpost,
Krom'gar Fortress, Lor'danel and Vashj'ir are excluded. Existing service replacements
such as James Stillair/Nizzle and Darla Harris/Southshore are excluded as well.
The source-candidate exclusions are listed in the NPC manifest.

## Sources

Primary names, identities, equipment and source positions:
[SkyFire 5.4.8 release 24.001](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001).
The missing Fairbreeze/Falconwing placements come from the primary
[Cataclysm Preservation Project database TDB434.22011](https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/releases/tag/TDB434.22011).
Appearances use per-NPC
[ZAM game model metadata](https://wow.zamimg.com/modelviewer/cata/meta/npc/33205.json).
Settlement membership was cross-checked against the
[flight-master roster](https://warcraft.wiki.gg/wiki/Flight_masters), native
`AreaTable.dbc`, and existing AzerothCore creature spawns/inhabitants recorded in
`wrath_settlement_proof`. Native assets and navigation use
[AzerothCore data v20](https://github.com/wowgaming/client-data/releases/tag/v20.0).
Taxi behavior follows the
[core taxi handlers](https://github.com/azerothcore/azerothcore-wotlk/blob/master/src/server/game/Handlers/TaxiHandler.cpp).
The portable MPQ writer uses the documented
[StormLib hash/table format](https://github.com/ladislav-zezula/StormLib).

## Validation and regeneration

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tools/generate_flight_masters.py --check
python3 tools/build_flight_patch.py --dbc-dir /path/to/unmodified/12340/dbc --check
```

The generators have no third-party Python dependencies. Change the JSON first,
regenerate base/update SQL, then rebuild the client patch from the checked native
baseline. The patch builder rejects incompatible baselines, node collisions,
mask overflow, broken endpoints, incompatible factions and waypoint collisions.

Native race/gender, skin/face/hair, facial features, armor, weapons and faction IDs
were checked against build 12340. Both SQL schemas passed fresh-install and
reapplication fixtures, including existing taxi overrides, older city content,
GUIDs, addon fields and spawn outfit overrides. The archive was independently
opened/extracted with StormLib, and all three DBC hashes matched the builder.

Live realm/client validation remains pending. Visit the new stops, check discovery
and normal flight-map labels, and fly return routes on both factions. Check
Darnassus/Dolanaar descents, the old city gate/entrance corridors and ruined-town
landing areas. Inspect appearances with the outfit system enabled and disabled.
