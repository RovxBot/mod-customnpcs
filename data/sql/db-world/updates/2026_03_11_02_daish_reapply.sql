-- =========================================================================
-- mod-customNPCs: Daish — full cleanup + reapply
-- For existing acore_world databases that may still have older/manual Daish rows.
-- Safe to re-run: children are deleted before parents, then recreated.
-- =========================================================================

-- --------------------------------------------------------------------
-- IDs
-- --------------------------------------------------------------------
SET @ENTRY_DAISH   := 4000001;
SET @ENTRY_HEALER1 := 4000002;
SET @ENTRY_HEALER2 := 4000003;

SET @GUID_DAISH   := 5300513;
SET @GUID_HEALER1 := 5300514;
SET @GUID_HEALER2 := 5300515;

SET @PATH_DAISH := @GUID_DAISH;

-- Display / faction
SET @DISPLAY_HUMAN_PALADIN := 19431;
SET @DISPLAY_HUMAN_PRIEST  := 15219;
SET @FACTION_BLACKROCK_HOSTILE := 14;

-- ====================================================================
-- Cleanup
-- ====================================================================
DELETE FROM smart_scripts        WHERE entryorguid IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2) AND source_type = 0;
DELETE FROM creature_text        WHERE CreatureID  IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);
DELETE FROM creature_formations  WHERE leaderGUID IN (@GUID_DAISH, @GUID_HEALER1, @GUID_HEALER2)
                                 OR memberGUID IN (@GUID_DAISH, @GUID_HEALER1, @GUID_HEALER2);
DELETE FROM creature_addon       WHERE guid       IN (@GUID_DAISH, @GUID_HEALER1, @GUID_HEALER2);
DELETE FROM waypoint_data        WHERE id         =  @PATH_DAISH;
DELETE FROM creature_equip_template WHERE CreatureID IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);
DELETE FROM creature             WHERE id1        IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);
DELETE FROM creature_template_model WHERE CreatureID IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);
DELETE FROM creature_template    WHERE entry      IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);

-- ====================================================================
-- Templates
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
  (@ENTRY_DAISH, 'Daish', 'Wintergrasp Champion', 0,
   83, 83, 2, @FACTION_BLACKROCK_HOSTILE,
   0, 1, 1.14286, 1, 1, 0, 2 /* paladin */,
   0, 0, 0, 7 /* humanoid */, 0,
   'SmartAI', '', 2 /* waypoint */, 1,
   8, 5, 4, 1,
   0, 1, 0, 0, 0),
  (@ENTRY_HEALER1, 'Daish''s Healer', NULL, 0,
   82, 82, 2, @FACTION_BLACKROCK_HOSTILE,
   0, 1, 1.14286, 1, 0, 0, 2 /* paladin */,
   0, 0, 0, 7 /* humanoid */, 0,
   'SmartAI', '', 0, 1,
   2, 8, 2, 1,
   0, 1, 0, 0, 0),
  (@ENTRY_HEALER2, 'Daish''s Healer', NULL, 0,
   82, 82, 2, @FACTION_BLACKROCK_HOSTILE,
   0, 1, 1.14286, 1, 0, 0, 2 /* paladin */,
   0, 0, 0, 7 /* humanoid */, 0,
   'SmartAI', '', 0, 1,
   2, 8, 2, 1,
   0, 1, 0, 0, 0);

INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability)
VALUES
  (@ENTRY_DAISH,   0, @DISPLAY_HUMAN_PALADIN, 1, 1),
  (@ENTRY_HEALER1, 0, @DISPLAY_HUMAN_PRIEST,  1, 1),
  (@ENTRY_HEALER2, 0, @DISPLAY_HUMAN_PRIEST,  1, 1);

-- ====================================================================
-- Equipment
-- ====================================================================
INSERT INTO creature_equip_template (CreatureID, ID, ItemID1, ItemID2, ItemID3)
VALUES (@ENTRY_DAISH, 1, 19334, 0, 0);

-- ====================================================================
-- Spawns
-- ====================================================================
INSERT INTO creature
  (guid, id1, map, zoneId, areaId, spawnMask, phaseMask, equipment_id,
   position_x, position_y, position_z, orientation,
   spawntimesecs, wander_distance, currentwaypoint,
   curhealth, curmana, MovementType)
VALUES
  (@GUID_DAISH,   @ENTRY_DAISH,   0, 25, 25, 1, 1, 1,
   -7692.57, -1087.04, 217.714, 1.19093,
   300, 0, 0, 0, 0, 2),
  (@GUID_HEALER1, @ENTRY_HEALER1, 0, 25, 25, 1, 1, 0,
   -7692.57, -1087.04, 217.714, 1.19093,
   300, 0, 0, 0, 0, 0),
  (@GUID_HEALER2, @ENTRY_HEALER2, 0, 25, 25, 1, 1, 0,
   -7692.57, -1087.04, 217.714, 1.19093,
   300, 0, 0, 0, 0, 0);

-- ====================================================================
-- Waypoints / addon / formation
-- ====================================================================
INSERT INTO waypoint_data
  (id, point, position_x, position_y, position_z, orientation, delay, move_type, action, action_chance, wpguid)
VALUES
  (@PATH_DAISH, 1,  -7692.57, -1087.04, 217.714, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 2,  -7662.74, -1041.40, 225.620, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 3,  -7609.16, -1017.90, 240.538, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 4,  -7546.75, -1027.62, 255.448, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 5,  -7498.72, -1081.65, 264.926, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 6,  -7490.68, -1143.76, 264.803, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 7,  -7521.42, -1186.59, 256.979, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 8,  -7568.83, -1217.53, 244.408, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 9,  -7617.33, -1217.76, 232.177, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 10, -7668.89, -1183.12, 218.799, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 11, -7696.60, -1128.01, 215.458, NULL, 0, 0, 0, 100, 0),
  (@PATH_DAISH, 12, -7693.81, -1090.00, 217.533, NULL, 0, 0, 0, 100, 0);

INSERT INTO creature_addon
  (guid, path_id, mount, bytes1, bytes2, emote, visibilityDistanceType, auras)
VALUES
  (@GUID_DAISH, @PATH_DAISH, 0, 0, 0, 0, 0, '');

INSERT INTO creature_formations
  (leaderGUID, memberGUID, dist, angle, groupAI, point_1, point_2)
VALUES
  (@GUID_DAISH, @GUID_DAISH,   0,   0.0, 3, 0, 0),
  (@GUID_DAISH, @GUID_HEALER1, 3,   2.2, 3, 0, 0),
  (@GUID_DAISH, @GUID_HEALER2, 3,   4.1, 3, 0, 0);

-- ====================================================================
-- creature_text
-- ====================================================================
INSERT INTO creature_text
  (CreatureID, GroupID, ID, Text, Type, Language, Probability,
   Emote, Duration, Sound, BroadcastTextId, TextRange, comment)
VALUES
  (@ENTRY_DAISH, 0, 0, 'Daish! Daish! Daish!',
   14, 0, 100, 0, 0, 0, 0, 0, 'Daish loop yell');

-- ====================================================================
-- SmartAI
-- ====================================================================
INSERT INTO smart_scripts
  (entryorguid, source_type, id, link,
   event_type, event_phase_mask, event_chance, event_flags,
   event_param1, event_param2, event_param3, event_param4, event_param5, event_param6,
   action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6,
   target_type, target_param1, target_param2, target_param3, target_param4,
   target_x, target_y, target_z, target_o, comment)
VALUES
  (@ENTRY_DAISH, 0, 0, 0, 1, 0, 100, 0,
   10000, 20000, 45000, 75000, 0, 0,
   1, 0, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - OOC - Yell line 0'),
  (@ENTRY_DAISH, 0, 1, 0, 4, 0, 100, 0,
   0, 0, 0, 0, 0, 0,
   11, 20375, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - On Aggro - Cast Seal of Command'),
  (@ENTRY_DAISH, 0, 2, 0, 0, 0, 100, 0,
   5000, 7000, 8000, 12000, 0, 0,
   11, 20271, 0, 0, 0, 0, 0,
   2, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - IC - Cast Judgement'),
  (@ENTRY_DAISH, 0, 3, 0, 0, 0, 100, 0,
   8000, 12000, 12000, 16000, 0, 0,
   11, 48819, 0, 0, 0, 0, 0,
   2, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - IC - Cast Consecration'),
  (@ENTRY_DAISH, 0, 4, 0, 0, 0, 100, 0,
   12000, 18000, 15000, 22000, 0, 0,
   11, 10308, 0, 0, 0, 0, 0,
   2, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - IC - Cast Hammer of Justice'),
  (@ENTRY_DAISH, 0, 5, 0, 2, 0, 100, 1,
   0, 20, 0, 0, 0, 0,
   11, 642, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - HP 20% - Cast Divine Shield (once)'),

  (@ENTRY_HEALER1, 0, 0, 0, 74, 0, 100, 0,
   0, 0, 5000, 9000, 0, 0,
   11, 48066, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 1 - Friendly Missing Aura - Cast PW:S'),
  (@ENTRY_HEALER2, 0, 0, 0, 74, 0, 100, 0,
   0, 0, 5000, 9000, 0, 0,
   11, 48066, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 2 - Friendly Missing Aura - Cast PW:S'),
  (@ENTRY_HEALER1, 0, 1, 0, 2, 0, 100, 0,
   0, 60, 4000, 7000, 0, 0,
   11, 48071, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 1 - Friendly Missing HP - Cast Flash Heal'),
  (@ENTRY_HEALER2, 0, 1, 0, 2, 0, 100, 0,
   0, 60, 4000, 7000, 0, 0,
   11, 48071, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 2 - Friendly Missing HP - Cast Flash Heal');
