-- =========================================================================
-- mod-customNPCs: Nubmage — full cleanup + reapply
-- For existing acore_world databases that still have older/manual Nubmage rows.
-- Safe to re-run: children are deleted before parents, then recreated.
-- =========================================================================

-- --------------------------------------------------------------------
-- IDs
-- --------------------------------------------------------------------
SET @ENTRY_NUBMAGE       := 4000000;
SET @GOSSIP_MENU_NUBMAGE := @ENTRY_NUBMAGE;
SET @NPC_TEXT_NUBMAGE    := 4000000;

-- Display / faction
SET @DISPLAY_UNDERCITY_MAGE := 18454;
SET @FACTION_HORDE_CITY     := 1759;

-- ====================================================================
-- Cleanup (order matters — children before parents)
-- ====================================================================
DELETE FROM smart_scripts           WHERE entryorguid = @ENTRY_NUBMAGE AND source_type = 0;
DELETE FROM creature_text           WHERE CreatureID  = @ENTRY_NUBMAGE;
DELETE FROM creature_equip_template WHERE CreatureID  = @ENTRY_NUBMAGE;
DELETE FROM conditions              WHERE SourceTypeOrReferenceId = 15 AND SourceGroup = @GOSSIP_MENU_NUBMAGE;
DELETE FROM gossip_menu_option      WHERE MenuID = @GOSSIP_MENU_NUBMAGE;
DELETE FROM gossip_menu             WHERE MenuID = @GOSSIP_MENU_NUBMAGE;
DELETE FROM npc_text                WHERE ID     = @NPC_TEXT_NUBMAGE;
DELETE FROM creature                WHERE id1    = @ENTRY_NUBMAGE;
DELETE FROM creature_template_model WHERE CreatureID = @ENTRY_NUBMAGE;
DELETE FROM creature_template       WHERE entry  = @ENTRY_NUBMAGE;

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
  (@ENTRY_NUBMAGE, 'Nubmage', 'Portal Service', @GOSSIP_MENU_NUBMAGE,
   80, 80, 2, @FACTION_HORDE_CITY,
   1 /* gossip */, 1, 1.14286, 1, 0, 0, 8 /* mage */,
   0, 0, 0, 7 /* humanoid */, 0,
   'SmartAI', 'npc_nubmage', 0, 1,
   1, 1, 1, 1,
   0, 1, 0, 0, 0);

INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability)
VALUES (@ENTRY_NUBMAGE, 0, @DISPLAY_UNDERCITY_MAGE, 1, 1);

-- ====================================================================
-- Equipment
-- ====================================================================
INSERT INTO creature_equip_template (CreatureID, ID, ItemID1, ItemID2, ItemID3)
VALUES (@ENTRY_NUBMAGE, 1, 22799, 0, 0);

-- ====================================================================
-- Spawn
-- ====================================================================
SET @GUID_NUBMAGE := (SELECT IFNULL(MAX(guid), 0) + 1 FROM creature);

INSERT INTO creature
  (guid, id1, map, zoneId, areaId, spawnMask, phaseMask, equipment_id,
   position_x, position_y, position_z, orientation,
   spawntimesecs, wander_distance, currentwaypoint,
   curhealth, curmana, MovementType)
VALUES
  (@GUID_NUBMAGE, @ENTRY_NUBMAGE, 1, 1637, 1637, 1, 1, 1,
   1611.2494, -4388.4680, 10.524337, 3.6819048,
   300, 0, 0, 0, 0, 0);

-- ====================================================================
-- Gossip menu + options
-- Gossip selection is handled in C++; the player is teleported by spell cast.
-- ====================================================================
INSERT INTO npc_text (ID, text0_0, BroadcastTextID0, lang0, Probability0)
VALUES (@NPC_TEXT_NUBMAGE,
  'Yes what is it? Nubmage has many portals to make and very little time!',
  0, 0, 1);

INSERT INTO gossip_menu (MenuID, TextID)
VALUES (@GOSSIP_MENU_NUBMAGE, @NPC_TEXT_NUBMAGE);

INSERT INTO gossip_menu_option
  (MenuID, OptionID, OptionIcon, OptionText, OptionBroadcastTextID,
   OptionType, OptionNpcFlag, ActionMenuID, ActionPoiID,
   BoxCoded, BoxMoney, BoxText)
VALUES
  (@GOSSIP_MENU_NUBMAGE, 1, 6,
   'Portal to Thunder Bluff [10g]', 0, 1, 1, 0, 0, 0, 100000,
   'No 10 gold, no portal. Nubmage laughs at your poverty.'),
  (@GOSSIP_MENU_NUBMAGE, 2, 6,
   'Portal to Undercity [10g]', 0, 1, 1, 0, 0, 0, 100000,
   'No 10 gold, no portal. Nubmage laughs at your poverty.'),
  (@GOSSIP_MENU_NUBMAGE, 3, 6,
   'Portal to Silvermoon [10g]', 0, 1, 1, 0, 0, 0, 100000,
   'No 10 gold, no portal. Nubmage laughs at your poverty.');

-- ====================================================================
-- creature_text
-- ====================================================================
INSERT INTO creature_text
  (CreatureID, GroupID, ID, Text, Type, Language, Probability,
   Emote, Duration, Sound, BroadcastTextId, TextRange, comment)
VALUES
  (@ENTRY_NUBMAGE, 0, 0,
   'Nubmage portal service! Best portal service for you!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage ad'),
  (@ENTRY_NUBMAGE, 0, 1,
   'Nubmage portal service! Step right up! Ten gold only!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage ad'),
  (@ENTRY_NUBMAGE, 0, 2,
   'Nubmage takes you anywhere! Thunder Bluff! Undercity! Silvermoon!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage ad'),

  (@ENTRY_NUBMAGE, 1, 0,
   'Nubmage sees you. Nubmage is not impressed.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage trash'),
  (@ENTRY_NUBMAGE, 1, 1,
   'Nubmage offers portals, and you offer... nothing.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage trash'),
  (@ENTRY_NUBMAGE, 1, 2,
   'Nubmage waits. Nubmage grows bored. Nubmage judges you.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage trash'),
  (@ENTRY_NUBMAGE, 1, 3,
   'Nubmage could port you far away. Nubmage chooses not to.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage trash'),
  (@ENTRY_NUBMAGE, 1, 4,
   'Nubmage hears your footsteps. Nubmage hears your indecision.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage trash'),
  (@ENTRY_NUBMAGE, 1, 5,
   'Nubmage is a master of space and time. You are a master of wasting it.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage trash'),
  (@ENTRY_NUBMAGE, 1, 6,
   'Nubmage has many portals. You have many excuses.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage trash'),

  (@ENTRY_NUBMAGE, 2, 0,
   'Nubmage does not accept poverty as payment!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage no gold'),
  (@ENTRY_NUBMAGE, 2, 1,
   'Nubmage laughs at your empty pockets! Come back with gold!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage no gold'),
  (@ENTRY_NUBMAGE, 2, 2,
   'You want portal? Nubmage wants GOLD! Ten gold! You have... nothing!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage no gold'),
  (@ENTRY_NUBMAGE, 2, 3,
   'Nubmage is not a charity! Go farm some gold, peasant!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage no gold'),
  (@ENTRY_NUBMAGE, 2, 4,
   'Nubmage smells broke. Is that you? Yes, that is you.',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage no gold'),

  (@ENTRY_NUBMAGE, 3, 0,
   'Another satisfied customer! Nubmage is the best!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage success'),
  (@ENTRY_NUBMAGE, 3, 1,
   'Nubmage thanks you for your gold! Safe travels!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage success'),
  (@ENTRY_NUBMAGE, 3, 2,
   'Whoooosh! Nubmage sends you away! Bye bye!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Nubmage success');

-- ====================================================================
-- SmartAI — OOC ambient yells only
-- ====================================================================
INSERT INTO smart_scripts
  (entryorguid, source_type, id, link,
   event_type, event_phase_mask, event_chance, event_flags,
   event_param1, event_param2, event_param3, event_param4, event_param5, event_param6,
   action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6,
   target_type, target_param1, target_param2, target_param3, target_param4,
   target_x, target_y, target_z, target_o, comment)
VALUES
  (@ENTRY_NUBMAGE, 0, 0, 0, 1, 0, 100, 0,
   15000, 30000, 60000, 120000, 0, 0,
   1, 0, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Nubmage - OOC - Yell ad lines (group 0)'),
  (@ENTRY_NUBMAGE, 0, 1, 0, 1, 0, 100, 0,
   60000, 90000, 180000, 360000, 0, 0,
   1, 1, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Nubmage - OOC - Yell trash lines (group 1)');
