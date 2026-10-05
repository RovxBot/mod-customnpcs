-- =========================================================================
-- mod-customNPCs: Cataclysm Orgrimmar trainers
-- =========================================================================
-- This is a recreation of named NPCs added to Cataclysm's rebuilt
-- Orgrimmar.  `source_entry` and the map-1 coordinates below come from a
-- 5.4.8 world database snapshot; the positions are the NPCs' later-game
-- locations, not a custom trainer court.
--
-- The stock 3.3.5a client does not contain Cataclysm models or 1-525 skill
-- ranks. This file seeds fallback models and the matching WotLK curriculum.
-- Apply later_expansion_appearances.sql afterwards for researched outfits,
-- correct race/gender fallbacks, and terrain-checked Wrath placements.
-- It never substitutes a
-- different class or profession for the NPC's original role.
--
-- Mists trainers native to Pandaria are intentionally not placed here:
-- map 870 is absent from an unmodified 3.3.5a client.  Monk trainers are
-- intentionally out of scope.
--
-- Safe to re-run.  Only rows belonging to this module roster are removed.
-- =========================================================================

DROP TEMPORARY TABLE IF EXISTS mod_customnpcs_later_trainer_roster;
CREATE TEMPORARY TABLE mod_customnpcs_later_trainer_roster (
  entry          INT UNSIGNED NOT NULL,
  source_entry   INT UNSIGNED NOT NULL,
  trainer_id     INT UNSIGNED NOT NULL,
  name           VARCHAR(100) NOT NULL,
  subname        VARCHAR(100) NOT NULL,
  npcflag        INT UNSIGNED NOT NULL,
  unit_class     TINYINT UNSIGNED NOT NULL,
  model_source   INT UNSIGNED NOT NULL,
  position_x     FLOAT NOT NULL,
  position_y     FLOAT NOT NULL,
  position_z     FLOAT NOT NULL,
  orientation    FLOAT NOT NULL,
  PRIMARY KEY (entry)
);

-- source_entry is the Cataclysm/Mists-era NPC entry used to verify name,
-- trainer role, and original later-expansion placement.
INSERT INTO mod_customnpcs_later_trainer_roster
  (entry, source_entry, trainer_id, name, subname, npcflag, unit_class, model_source,
   position_x, position_y, position_z, orientation)
VALUES
  -- Class trainers, Cataclysm Orgrimmar
  (4000005, 44726,  33, 'Shalla Whiteleaf',        'Druid Trainer',              48, 11, 3033, 1888.95, -4285.25, 23.7017, 3.83972),
  (4000006, 44743,   7, 'Nohi Plainswalker',       'Hunter Trainer',             48,  3, 3038, 1872.89, -4281.46, 23.9098, 4.92183),
  (4000007, 45714,  16, 'Conjurer Mixli',          'Mage Trainer',               48,  8, 3047, 1558.52, -4209.71, 54.2535, 3.68265),
  (4000008, 44725,   3, 'Sunwalker Atohmo',        'Paladin Trainer',            48,  2,  927, 1863.88, -4292.69, 23.9046, 5.55015),
  (4000009, 44735,  11, 'Seer Liwatha',            'Priest Trainer',             48,  5, 3044, 1863.46, -4297.75, 23.8761, 6.14356),
  (4000010, 45095,   9, 'Night-Stalker Ku''nanji', 'Rogue Trainer',              48,  4, 3170, 1758.12, -4069.09, 51.7798, 1.01229),
  (4000011, 44740,  14, 'Sahi Cloudsinger',        'Shaman Trainer',             48,  7, 3030, 1884.15, -4282.40, 23.7574, 4.67748),
  (4000012, 45138,  31, 'Unjari Feltongue',        'Warlock Trainer',            48,  9, 3172, 1675.61, -4132.10, 51.5051, 3.52556),
  (4000013, 46667,   1, 'Blademaster Ronakada',    'Warrior Trainer',            48,  1, 3169, 1960.88, -4788.98, 39.1959, 1.55334),

  -- Profession trainers, Cataclysm Orgrimmar
  (4000014, 44975,  98, 'Old Umbehto',             'Fishing Trainer & Supplies', 80,  1, 3332, 1705.74, -4118.14, 48.3627, 1.23918),
  (4000015, 45540,  83, 'Krenk Choplimb',          'First Aid Trainer',          80,  1, 3373, 1472.12, -4148.55, 52.6946, 2.67528),
  (4000016, 45545,  92, '"Jack" Pisarek Slamfix',  'Engineering Trainer',        80,  1, 3290, 1483.09, -4142.57, 52.4360, 6.19592),
  (4000017, 45548,  60, 'Kark Helmbreaker',        'Blacksmithing Trainer',      80,  1, 3355, 1526.54, -4130.65, 51.3357, 0.95993),
  (4000018, 45550,  77, 'Zarbo Porkpatty',         'Cooking Trainer',            80,  1, 3399, 1487.83, -4187.19, 53.4039, 1.13446),
  (4000019, 45559,  74, 'Nivi Weavewell',          'Tailoring Trainer',          80,  1, 3363, 1560.91, -4224.63, 54.1431, 1.30900),
  (4000020, 44782, 100, 'Rento',                   'Skinning Trainer',           80,  1, 8144, 1910.17, -4191.30, 37.2747, 5.16617),
  (4000021, 52170,  80, 'Gizzik Oregrab',          'Mining Trainer',             80,  1, 3357, 1529.12, -4133.45, 51.1367, 1.64061),
  (4000022, 46675, 112, 'Lugrah',                  'Jewelcrafting Trainer',      80,  1,19539, 2088.80, -4767.27, 28.0121, 4.15388),
  (4000023, 46716, 121, 'Nerog',                   'Inscription Trainer',        80,  1,30706, 1838.72, -4464.13, 47.6899, 0.00000),
  (4000024, 46741,  69, 'Muraga',                  'Herbalism Trainer',          80,  1, 3013, 1907.59, -4460.51, 53.3852, 4.34104);

-- Normalize the spawn identifier for older (id) and current (id1) AzerothCore.
SET @MOD_CUSTOMNPCS_LATER_ENTRY_COLUMN := (
  SELECT COLUMN_NAME FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'creature'
    AND COLUMN_NAME IN ('id1', 'id')
  ORDER BY COLUMN_NAME DESC LIMIT 1
);
DROP TEMPORARY TABLE IF EXISTS mod_customnpcs_later_existing_spawns;
SET @MOD_CUSTOMNPCS_LATER_SPAWN_QUERY := CONCAT(
  'CREATE TEMPORARY TABLE mod_customnpcs_later_existing_spawns AS ',
  'SELECT c.guid FROM creature c INNER JOIN mod_customnpcs_later_trainer_roster r ON r.entry = c.`',
  @MOD_CUSTOMNPCS_LATER_ENTRY_COLUMN, '`'
);
PREPARE mod_customnpcs_later_read_spawns FROM @MOD_CUSTOMNPCS_LATER_SPAWN_QUERY;
EXECUTE mod_customnpcs_later_read_spawns;
DEALLOCATE PREPARE mod_customnpcs_later_read_spawns;

-- Cleanup children before parents. Only this roster's existing spawn GUIDs are selected.
DELETE ca
FROM creature_addon ca
INNER JOIN mod_customnpcs_later_existing_spawns c ON c.guid = ca.guid;
DELETE c
FROM creature c
INNER JOIN mod_customnpcs_later_existing_spawns old ON old.guid = c.guid;
DELETE m
FROM creature_template_model m
INNER JOIN mod_customnpcs_later_trainer_roster r ON r.entry = m.CreatureID;
-- Remove the pre-1.0 generic trainer implementation if it was previously
-- applied, then attach the current AzerothCore default-trainer menus.
DELETE t FROM npc_trainer t WHERE t.ID BETWEEN 4000005 AND 4000028;
DELETE dt
FROM creature_default_trainer dt
INNER JOIN mod_customnpcs_later_trainer_roster r ON r.entry = dt.CreatureId;
DELETE ct
FROM creature_template ct
INNER JOIN mod_customnpcs_later_trainer_roster r ON r.entry = ct.entry;

-- NPC flags: 48 = trainer + class trainer; 80 = trainer + profession trainer.
-- Faction 35 makes the NPCs usable on a typical cross-faction custom realm.
INSERT INTO creature_template
  (entry, name, subname, gossip_menu_id, minlevel, maxlevel, exp, faction,
   npcflag, speed_walk, speed_run, `rank`, dmgschool, unit_class,
   unit_flags, unit_flags2, dynamicflags, type, type_flags,
   AIName, ScriptName, MovementType, HoverHeight,
   HealthModifier, ManaModifier, ArmorModifier, ExperienceModifier,
   RacialLeader, RegenHealth, flags_extra)
SELECT
  r.entry, r.name, r.subname, 0, 80, 80, 2, 35,
  r.npcflag, 1, 1.14286, 0, 0, r.unit_class,
  2, 0, 0, 7, 0,
  'NullCreatureAI', '', 0, 1,
  1, 1, 1, 1,
  0, 1, 2
FROM mod_customnpcs_later_trainer_roster r;

-- Use models already present in the 3.3.5a client.  The later-era display
-- IDs cannot be sent to an unmodified WotLK client.
INSERT INTO creature_template_model
  (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability)
SELECT r.entry, m.Idx, m.CreatureDisplayID, m.DisplayScale, m.Probability
FROM mod_customnpcs_later_trainer_roster r
INNER JOIN creature_template_model m ON m.CreatureID = r.model_source;

-- The original NPC role determines the menu.  `creature_default_trainer`
-- points to AzerothCore's stock 3.3.5a trainer data (trainer/trainer_spell),
-- so no Cataclysm/Mists spell unknown to the client is inserted.
INSERT INTO creature_default_trainer (CreatureId, TrainerId)
SELECT entry, trainer_id
FROM mod_customnpcs_later_trainer_roster;

SET @MOD_CUSTOMNPCS_LATER_GUID := (SELECT IFNULL(MAX(guid), 0) + 1 FROM creature);

-- Seed recorded later coordinates, then apply later_expansion_appearances.sql
-- to fit the older city geometry before starting worldserver.
SET @MOD_CUSTOMNPCS_LATER_SPAWN_INSERT := CONCAT(
  'INSERT INTO creature (guid, `', @MOD_CUSTOMNPCS_LATER_ENTRY_COLUMN,
  '`, map, zoneId, areaId, spawnMask, phaseMask, equipment_id, ',
  'position_x, position_y, position_z, orientation, spawntimesecs, wander_distance, ',
  'currentwaypoint, curhealth, curmana, MovementType) ',
  'SELECT @MOD_CUSTOMNPCS_LATER_GUID + r.entry - 4000005, r.entry, 1, 1637, 1637, 1, 1, 0, ',
  'r.position_x, r.position_y, r.position_z, r.orientation, 300, 0, 0, 0, 0, 0 ',
  'FROM mod_customnpcs_later_trainer_roster r'
);
PREPARE mod_customnpcs_later_insert_spawns FROM @MOD_CUSTOMNPCS_LATER_SPAWN_INSERT;
EXECUTE mod_customnpcs_later_insert_spawns;
DEALLOCATE PREPARE mod_customnpcs_later_insert_spawns;

DROP TEMPORARY TABLE mod_customnpcs_later_existing_spawns;
DROP TEMPORARY TABLE mod_customnpcs_later_trainer_roster;
