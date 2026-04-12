-- =========================================================================
-- mod-customNPCs: Kappa — Guild Leader of Maxiboomers
-- =========================================================================
-- Orc female warrior walking around Orgrimmar with Thunderfury and the
-- off-hand Warglaive of Azzinoth.
-- Uses Kor'kron General's built-in display for a female Horde warrior look.
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
SET @GOSSIP_MENU_KAPPA := 4000004;
SET @NPC_TEXT_KAPPA := 4000004;

-- Display / faction
SET @DISPLAY_ORC_FEMALE := 30752;   -- Kor'kron General / Kor'kron Reaver
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
DELETE FROM gossip_menu            WHERE MenuID = @GOSSIP_MENU_KAPPA;
DELETE FROM npc_text               WHERE ID = @NPC_TEXT_KAPPA;
DELETE FROM creature_template       WHERE entry = @ENTRY_KAPPA;

-- ====================================================================
-- Template
-- ====================================================================
INSERT INTO creature_template
  (entry, name, subname, gossip_menu_id, minlevel, maxlevel, exp, faction,
   npcflag, speed_walk, speed_run, `rank`, dmgschool, unit_class,
   unit_flags, unit_flags2, dynamicflags, type, type_flags,
   AIName, ScriptName, MovementType, HoverHeight,
   HealthModifier, ManaModifier, ArmorModifier, ExperienceModifier,
   RacialLeader, RegenHealth, flags_extra)
VALUES
  (@ENTRY_KAPPA, 'Kappa', 'of the single glave', @GOSSIP_MENU_KAPPA,
   80, 80, 2, @FACTION_HORDE_CITY,
   1 /* gossip */, 1, 1.14286, 0, 0, 1 /* warrior */,
   0, 0, 0, 7 /* humanoid */, 0,
   'NullCreatureAI', '', 1 /* random */, 1,
   1, 1, 1, 1,
   0, 1, 0);

INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability)
VALUES (@ENTRY_KAPPA, 0, @DISPLAY_ORC_FEMALE, 1, 1);

INSERT INTO npc_text (ID, text0_0, BroadcastTextID0, lang0, Probability0)
VALUES (@NPC_TEXT_KAPPA,
  'Quick glave run? In and out, 10 min, easy.',
  0, 0, 1);

INSERT INTO gossip_menu (MenuID, TextID)
VALUES (@GOSSIP_MENU_KAPPA, @NPC_TEXT_KAPPA);

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
