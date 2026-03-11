-- =========================================================================
-- mod-customNPCs: Kappa — Guild Leader of Maxiboomers
-- =========================================================================
-- Orc female warrior walking around Orgrimmar with Thunderfury and the
-- off-hand Warglaive of Azzinoth.
--
-- NOTE:
-- AzerothCore's base creature_equip_template supports visible weapon slots.
-- Full player-style armor appearance such as exact Tier 8 visuals typically
-- requires an outfit-capable schema/module beyond this repo's current SQL.
--
-- Safe to re-run: every section starts with a cleanup DELETE.
-- =========================================================================

-- --------------------------------------------------------------------
-- IDs
-- --------------------------------------------------------------------
SET @ENTRY_KAPPA := 4000004;

-- Display / faction
SET @DISPLAY_ORC_FEMALE := 20316;   -- inferred female orc player display
SET @FACTION_HORDE_CITY := 1759;

-- Weapons
SET @ITEM_THUNDERFURY      := 19019;
SET @ITEM_WARGLAIVE_OFFHAND := 32838;

-- ====================================================================
-- Cleanup
-- ====================================================================
DELETE FROM creature_addon          WHERE guid IN (SELECT guid FROM creature WHERE id1 = @ENTRY_KAPPA);
DELETE FROM creature_equip_template WHERE CreatureID = @ENTRY_KAPPA;
DELETE FROM creature                WHERE id1 = @ENTRY_KAPPA;
DELETE FROM creature_template_model WHERE CreatureID = @ENTRY_KAPPA;
DELETE FROM creature_template       WHERE entry = @ENTRY_KAPPA;

-- ====================================================================
-- Template
-- ====================================================================
INSERT INTO creature_template
  (entry, name, subname, gossip_menu_id, minlevel, maxlevel, exp, faction,
   npcflag, speed_walk, speed_run, scale, `rank`, dmgschool, unit_class,
   unit_flags, unit_flags2, dynamicflags, type, type_flags,
   AIName, ScriptName, MovementType, HoverHeight,
   HealthModifier, ManaModifier, ArmorModifier, ExperienceModifier,
   RacialLeader, RegenHealth, mechanic_immune_mask,
   spell_school_immune_mask, flags_extra)
VALUES
  (@ENTRY_KAPPA, 'Kappa', 'Guild Leader of Maxiboomers', 0,
   80, 80, 2, @FACTION_HORDE_CITY,
   0, 1, 1.14286, 1, 0, 0, 1 /* warrior */,
   0, 0, 0, 7 /* humanoid */, 0,
   'NullCreatureAI', '', 1 /* random */, 1,
   1, 1, 1, 1,
   0, 1, 0, 0, 0);

INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability)
VALUES (@ENTRY_KAPPA, 0, @DISPLAY_ORC_FEMALE, 1, 1);

-- ====================================================================
-- Equipment
-- ====================================================================
INSERT INTO creature_equip_template (CreatureID, ID, ItemID1, ItemID2, ItemID3)
VALUES (@ENTRY_KAPPA, 1, @ITEM_THUNDERFURY, @ITEM_WARGLAIVE_OFFHAND, 0);

-- ====================================================================
-- Spawn  (Orgrimmar bank / Valley of Strength area)
-- Random movement keeps her roaming around this part of Org.
-- ====================================================================
SET @GUID_KAPPA := (SELECT IFNULL(MAX(guid), 0) + 1 FROM creature);

INSERT INTO creature
  (guid, id1, map, zoneId, areaId, spawnMask, phaseMask, equipment_id,
   position_x, position_y, position_z, orientation,
   spawntimesecs, wander_distance, currentwaypoint,
   curhealth, curmana, MovementType)
VALUES
  (@GUID_KAPPA, @ENTRY_KAPPA, 1, 1637, 1637, 1, 1, 1,
   1606.2500, -4380.7500, 10.5200, 3.6800,
   300, 18, 0, 0, 0, 1 /* random */);
