-- =========================================================================
-- mod-customNPCs: Daish — Wintergrasp Champion + Pocket Healers
-- =========================================================================
-- Patrols Blackrock Mountain with two healer escorts in formation.
-- Fully SmartAI-driven (combat spells, yells, healer behaviour).
--
-- Safe to re-run: every section starts with a cleanup DELETE.
-- =========================================================================

-- --------------------------------------------------------------------
-- IDs
-- --------------------------------------------------------------------
SET @ENTRY_DAISH   := 4000001;
SET @ENTRY_HEALER1 := 4000002;
SET @ENTRY_HEALER2 := 4000003;

-- Display
SET @DISPLAY_STORMWIND_GUARD := 19431;   -- male human paladin
SET @DISPLAY_FEMALE_PRIEST   := 3344;    -- female human priest

-- Factions
SET @FACTION_ALLIANCE := 11;

-- ====================================================================
-- Cleanup  (children → parents)
-- ====================================================================
DELETE FROM creature_formations
 WHERE leaderGUID IN (SELECT guid FROM creature WHERE id1 IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2))
    OR memberGUID IN (SELECT guid FROM creature WHERE id1 IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2));

DELETE FROM creature_addon
 WHERE guid IN (SELECT guid FROM creature WHERE id1 IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2));

DELETE FROM waypoint_data
 WHERE id IN (SELECT guid FROM creature WHERE id1 = @ENTRY_DAISH);

DELETE FROM smart_scripts
 WHERE entryorguid IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2) AND source_type = 0;

DELETE FROM creature_text       WHERE CreatureID IN (@ENTRY_DAISH);
DELETE FROM creature_equip_template WHERE CreatureID IN (@ENTRY_DAISH);
DELETE FROM creature             WHERE id1 IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);
DELETE FROM creature_template_model WHERE CreatureID IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);
DELETE FROM creature_template    WHERE entry IN (@ENTRY_DAISH, @ENTRY_HEALER1, @ENTRY_HEALER2);

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
   60, 60, 1, @FACTION_ALLIANCE,
   0, 1, 1.14286, 1, 1 /*elite*/, 0, 2 /*paladin*/,
   0, 0, 0, 7, 0,
   'SmartAI', '', 2 /*waypoint*/, 1,
   1, 1, 1, 1,
   0, 1, 0, 0, 0),

  (@ENTRY_HEALER1, 'Daish''s Healer', NULL, 0,
   60, 60, 1, @FACTION_ALLIANCE,
   0, 1, 1.14286, 1, 0, 1 /*holy*/, 8 /*mage/caster*/,
   0, 0, 0, 7, 0,
   'SmartAI', '', 0 /*idle — formation handles movement*/, 1,
   1, 1, 1, 1,
   0, 1, 0, 0, 0),

  (@ENTRY_HEALER2, 'Daish''s Healer', NULL, 0,
   60, 60, 1, @FACTION_ALLIANCE,
   0, 1, 1.14286, 1, 0, 1, 8,
   0, 0, 0, 7, 0,
   'SmartAI', '', 0 /*idle — formation handles movement*/, 1,
   1, 1, 1, 1,
   0, 1, 0, 0, 0);

INSERT INTO creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability)
VALUES
  (@ENTRY_DAISH,   0, @DISPLAY_STORMWIND_GUARD, 1, 1),
  (@ENTRY_HEALER1, 0, @DISPLAY_FEMALE_PRIEST,   1, 1),
  (@ENTRY_HEALER2, 0, @DISPLAY_FEMALE_PRIEST,   1, 1);

-- ====================================================================
-- Equipment  (Daish wields The Untamed Blade — item 19334)
-- ====================================================================
INSERT INTO creature_equip_template (CreatureID, ID, ItemID1, ItemID2, ItemID3)
VALUES (@ENTRY_DAISH, 1, 19334, 0, 0);

-- ====================================================================
-- Spawns  (Blackrock Mountain — Eastern Kingdoms map 0, zone 25)
-- ====================================================================
SET @GUID_BASE   := (SELECT IFNULL(MAX(guid), 0) + 1 FROM creature);
SET @GUID_DAISH  := @GUID_BASE;
SET @GUID_HEAL1  := @GUID_BASE + 1;
SET @GUID_HEAL2  := @GUID_BASE + 2;

INSERT INTO creature
  (guid, id1, map, zoneId, areaId, spawnMask, phaseMask, equipment_id,
   position_x, position_y, position_z, orientation,
   spawntimesecs, wander_distance, currentwaypoint,
   curhealth, curmana, MovementType)
VALUES
  (@GUID_DAISH, @ENTRY_DAISH, 0, 25, 25, 1, 1, 1,
   -7692.5690, -1087.0372, 217.71353, 1.1909260,
   300, 0, 0, 0, 0, 2 /*waypoint*/),
  (@GUID_HEAL1, @ENTRY_HEALER1, 0, 25, 25, 1, 1, 0,
   -7692.5690, -1087.0372, 217.71353, 1.1909260,
   300, 0, 0, 0, 0, 0 /*idle — formation handles movement*/),
  (@GUID_HEAL2, @ENTRY_HEALER2, 0, 25, 25, 1, 1, 0,
   -7692.5690, -1087.0372, 217.71353, 1.1909260,
   300, 0, 0, 0, 0, 0 /*idle — formation handles movement*/);

-- ====================================================================
-- creature_addon  (bind waypoint path to Daish only)
-- Healers do NOT get creature_addon rows — they have MovementType=0
-- and follow Daish purely through creature_formations.
-- ====================================================================
INSERT INTO creature_addon (guid, path_id, mount, bytes1, bytes2, emote, visibilityDistanceType, auras)
VALUES
  (@GUID_DAISH, @GUID_DAISH, 0, 0, 0, 0, 0, '');

-- ====================================================================
-- Formation: healers flank Daish
-- AzerothCore stores follow angles in degrees.
-- Register only the escorts as members of the leader's formation.
-- ====================================================================
INSERT INTO creature_formations (leaderGUID, memberGUID, dist, angle, groupAI, point_1, point_2)
VALUES
  (@GUID_DAISH, @GUID_HEAL1, 3.0,  90.0, 0, 0, 0), -- left flank
  (@GUID_DAISH, @GUID_HEAL2, 3.0, 270.0, 0, 0, 0); -- right flank

-- ====================================================================
-- Waypoints: Blackrock Mountain patrol loop (12-point circuit)
-- move_type 1 = run
-- ====================================================================
INSERT INTO waypoint_data
  (id, point, position_x, position_y, position_z, orientation,
   delay, move_type, action, action_chance, wpguid)
VALUES
  (@GUID_DAISH,  1, -7692.5690, -1087.0372, 217.71353, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  2, -7662.7380, -1041.3998, 225.61966, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  3, -7609.1570, -1017.9013, 240.53793, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  4, -7546.7495, -1027.6194, 255.44817, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  5, -7498.7217, -1081.6483, 264.92593, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  6, -7490.6772, -1143.7604, 264.80300, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  7, -7521.4220, -1186.5950, 256.97855, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  8, -7568.8290, -1217.5265, 244.40808, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH,  9, -7617.3340, -1217.7589, 232.17680, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH, 10, -7668.8916, -1183.1165, 218.79893, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH, 11, -7696.5960, -1128.0096, 215.45802, NULL, 1, 1, 0, 100, 0),
  (@GUID_DAISH, 12, -7693.8057, -1089.9984, 217.53280, NULL, 1, 1, 0, 100, 0);

-- ====================================================================
-- creature_text  (Daish patrol yell)
-- ====================================================================
INSERT INTO creature_text
  (CreatureID, GroupID, ID, Text, Type, Language, Probability,
   Emote, Duration, Sound, BroadcastTextId, TextRange, comment)
VALUES
  (@ENTRY_DAISH, 0, 0, 'Daish! Daish! Daish!',
   14 /*yell*/, 0, 100, 0, 0, 0, 0, 0, 'Daish loop yell');

-- ====================================================================
-- SmartAI — Daish (OOC yell + combat rotation)
-- ====================================================================
INSERT INTO smart_scripts
  (entryorguid, source_type, id, link,
   event_type, event_phase_mask, event_chance, event_flags,
   event_param1, event_param2, event_param3, event_param4, event_param5, event_param6,
   action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6,
   target_type, target_param1, target_param2, target_param3, target_param4,
   target_x, target_y, target_z, target_o, comment)
VALUES
  -- OOC: yell periodically while patrolling
  (@ENTRY_DAISH, 0, 0, 0, 1, 0, 100, 0,
   15000, 30000, 45000, 90000, 0, 0,
   1, 0, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - OOC - Yell line 0'),

  -- On Aggro: Seal of Command (20165)
  (@ENTRY_DAISH, 0, 1, 0, 4, 0, 100, 0,
   0, 0, 0, 0, 0, 0,
   11, 20165, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - On Aggro - Cast Seal of Command'),

  -- IC: Judgement of Command (20271) every 8-12 s
  (@ENTRY_DAISH, 0, 2, 0, 0, 0, 100, 0,
   3000, 5000, 8000, 12000, 0, 0,
   11, 20271, 0, 0, 0, 0, 0,
   2, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - IC - Cast Judgement'),

  -- IC: Consecration Rank 6 (27173) every 12-15 s
  (@ENTRY_DAISH, 0, 3, 0, 0, 0, 100, 0,
   5000, 8000, 12000, 15000, 0, 0,
   11, 27173, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - IC - Cast Consecration'),

  -- IC: Hammer of Justice Rank 4 (10308) every 25-30 s
  (@ENTRY_DAISH, 0, 4, 0, 0, 0, 100, 0,
   10000, 15000, 25000, 30000, 0, 0,
   11, 10308, 0, 0, 0, 0, 0,
   2, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - IC - Cast Hammer of Justice'),

  -- HP <= 20%: Divine Shield (642) — once per fight
  (@ENTRY_DAISH, 0, 5, 0, 2, 0, 100, 1,
   0, 20, 0, 0, 0, 0,
   11, 642, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish - HP 20% - Cast Divine Shield (once)');

-- ====================================================================
-- SmartAI — Pocket Healers
--   Power Word: Shield (17139) when ally missing aura
--   Flash Heal (17843)        when ally missing HP
-- ====================================================================
INSERT INTO smart_scripts
  (entryorguid, source_type, id, link,
   event_type, event_phase_mask, event_chance, event_flags,
   event_param1, event_param2, event_param3, event_param4, event_param5, event_param6,
   action_type, action_param1, action_param2, action_param3, action_param4, action_param5, action_param6,
   target_type, target_param1, target_param2, target_param3, target_param4,
   target_x, target_y, target_z, target_o, comment)
VALUES
  -- Healer 1: PW:S when ally missing aura (event_flags 2 = normal mode, 6 s CD)
  (@ENTRY_HEALER1, 0, 0, 0, 16, 0, 100, 2,
   17139, 40, 6000, 6000, 0, 0,
   11, 17139, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 1 - Friendly Missing Aura - Cast PW:S'),

  -- Healer 2: PW:S
  (@ENTRY_HEALER2, 0, 0, 0, 16, 0, 100, 2,
   17139, 40, 6000, 6000, 0, 0,
   11, 17139, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 2 - Friendly Missing Aura - Cast PW:S'),

  -- Healer 1: Flash Heal when ally <= 80% HP, missing >= 1500
  (@ENTRY_HEALER1, 0, 1, 0, 14, 0, 100, 2,
   1500, 80, 3000, 3000, 0, 0,
   11, 17843, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 1 - Friendly Missing HP - Cast Flash Heal'),

  -- Healer 2: Flash Heal
  (@ENTRY_HEALER2, 0, 1, 0, 14, 0, 100, 2,
   1500, 80, 3000, 3000, 0, 0,
   11, 17843, 0, 0, 0, 0, 0,
   7, 0, 0, 0, 0, 0, 0, 0, 0,
   'Daish Healer 2 - Friendly Missing HP - Cast Flash Heal');
