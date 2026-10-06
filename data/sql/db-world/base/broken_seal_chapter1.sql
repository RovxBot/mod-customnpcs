-- mod-customNPCs: The Broken Seal, Chapter 1 (levels 20-25).
-- Generated from data/quests/broken_seal_chapter1.json. Native 3.3.5a assets only.
-- Requires custom_npc_appearances.sql and the rebuilt C++ module.
-- Ownership checks reject occupied custom IDs on first installation.
-- Reapplication preserves spawn GUIDs and unrelated world/character content.
-- See docs/broken-seal/chapter1-implementation.md before installation.

CREATE TABLE IF NOT EXISTS `mod_customnpcs_bs_content` (
  `kind` VARCHAR(16) NOT NULL,
  `entry` INT UNSIGNED NOT NULL,
  `chapter` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TEMPORARY TABLE IF EXISTS `bs_c01_ids`;
CREATE TEMPORARY TABLE `bs_c01_ids` (
  `kind` VARCHAR(16) NOT NULL,
  `entry` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c01_ids` (`kind`, `entry`) VALUES
  ('creature', 4001000),
  ('creature', 4001001),
  ('creature', 4001002),
  ('creature', 4001003),
  ('creature', 4001005),
  ('creature', 4001006),
  ('creature', 4001007),
  ('creature', 4001004),
  ('creature', 4001008),
  ('creature', 4001009),
  ('creature', 4001010),
  ('creature', 4001011),
  ('creature', 4001012),
  ('creature', 4001013),
  ('creature', 4001050),
  ('creature', 4001051),
  ('creature', 4001052),
  ('creature', 4001053),
  ('creature', 4001054),
  ('creature', 4001055),
  ('creature', 4001056),
  ('creature', 4001057),
  ('creature', 4001058),
  ('creature', 4001059),
  ('creature', 4001060),
  ('creature', 4001061),
  ('creature', 4001062),
  ('gameobject', 4001100),
  ('gameobject', 4001101),
  ('gameobject', 4001102),
  ('gameobject', 4001103),
  ('gameobject', 4001104),
  ('gameobject', 4001105),
  ('gameobject', 4001106),
  ('gameobject', 4001107),
  ('gameobject', 4001108),
  ('gameobject', 4001109),
  ('gameobject', 4001110),
  ('gameobject', 4001111),
  ('gameobject', 4001112),
  ('gameobject', 4001113),
  ('quest', 900100),
  ('quest', 900101),
  ('quest', 900102),
  ('quest', 900103),
  ('quest', 900104),
  ('quest', 900105),
  ('quest', 900106),
  ('quest', 900107),
  ('quest', 900108),
  ('item', 900100),
  ('item', 900101),
  ('item', 900102),
  ('item', 900103),
  ('item', 900104),
  ('item', 900110),
  ('item', 900111),
  ('item', 900112),
  ('item', 900113),
  ('item', 900114),
  ('item', 900115),
  ('outfit', 4001000),
  ('outfit', 4001001),
  ('outfit', 4001002),
  ('outfit', 4001003),
  ('outfit', 4001005),
  ('outfit', 4001006),
  ('outfit', 4001007),
  ('outfit', 4001004),
  ('outfit', 4001008),
  ('outfit', 4001009),
  ('outfit', 4001010),
  ('outfit', 4001011),
  ('npc_text', 4001000),
  ('npc_text', 4001001),
  ('npc_text', 4001005),
  ('npc_text', 4001006),
  ('npc_text', 4001007),
  ('gossip_menu', 4001000),
  ('gossip_menu', 4001001),
  ('gossip_menu', 4001005),
  ('gossip_menu', 4001006),
  ('gossip_menu', 4001007),
  ('page', 4001000),
  ('page', 4001001),
  ('page', 4001002),
  ('page', 4001003);

-- Duplicate-primary-key errors are intentional when an unowned ID is occupied.
-- This guard works without stored-procedure privileges and with permissive SQL modes.
DROP TEMPORARY TABLE IF EXISTS `bs_c01_collision_guard`;
CREATE TEMPORARY TABLE `bs_c01_collision_guard` (`id` TINYINT PRIMARY KEY);
INSERT INTO `bs_c01_collision_guard` VALUES (1);
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `creature_template` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'creature' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `gameobject_template` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'gameobject' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `quest_template` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'quest' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `item_template` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'item' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `mod_customnpcs_outfit` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'outfit' AND r.`entry` = t.`outfit_id`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `npc_text` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'npc_text' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `gossip_menu` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'gossip_menu' AND r.`entry` = t.`MenuID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c01_collision_guard`
SELECT 1 FROM `page_text` t
INNER JOIN `bs_c01_ids` r ON r.`kind` = 'page' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 1
WHERE o.`entry` IS NULL LIMIT 1;

DROP TEMPORARY TABLE `bs_c01_collision_guard`;
START TRANSACTION;
INSERT INTO `mod_customnpcs_bs_content` (`kind`, `entry`, `chapter`)
SELECT `kind`, `entry`, 1 FROM `bs_c01_ids`
ON DUPLICATE KEY UPDATE `chapter` = VALUES(`chapter`);

INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `unit_class`, `unit_flags`, `type`, `AIName`, `ScriptName`, `HealthModifier`, `DamageModifier`, `ExperienceModifier`, `lootid`, `flags_extra`) VALUES
  (4001000, 'Maruut Stonebinder', 'The Vale Expedition', 25, 25, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c01_contact', 1, 1, 0, 0, 2),
  (4001001, 'Elementalist Ortell', 'The Vale Expedition', 25, 25, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c01_contact', 1, 1, 0, 0, 2),
  (4001002, 'Commander Jarod Shadowsong', 'The Vale Expedition', 25, 25, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c01_contact', 1, 1, 0, 0, 2),
  (4001003, 'Twilight Recruit', '', 25, 25, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c01_recruit', 1, 1, 0, 0, 2),
  (4001005, 'Expedition Scout', 'The Vale Expedition', 25, 25, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c01_contact', 1, 1, 0, 0, 2),
  (4001006, 'Alliance Expedition Courier', 'The Vale Expedition', 25, 25, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c01_contact', 1, 1, 0, 0, 2),
  (4001007, 'Horde Expedition Courier', 'The Vale Expedition', 25, 25, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c01_contact', 1, 1, 0, 0, 2),
  (4001004, 'Mira Ashwood', '', 25, 25, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c01_captive', 1, 1, 0, 0, 2),
  (4001008, 'Dorn Stonehoof', '', 25, 25, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c01_captive', 1, 1, 0, 0, 2),
  (4001009, 'Teren Valeguard', '', 25, 25, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c01_captive', 1, 1, 0, 0, 2),
  (4001010, 'Twilight Scout', '', 20, 22, 0, 14, 0, 1, 0, 7, 'SmartAI', '', 1, 1, 1, 4001010, 0),
  (4001011, 'Twilight Guard', '', 22, 23, 0, 14, 0, 1, 0, 7, 'SmartAI', '', 1, 1, 1, 0, 0),
  (4001012, 'Unbound Earth Elemental', '', 22, 23, 0, 14, 0, 1, 0, 4, 'SmartAI', '', 1, 1, 1, 0, 0),
  (4001013, 'Expedition Observation Focus', '', 1, 1, 0, 35, 0, 1, 33555202, 10, '', 'npc_bs_c01_observation', 1, 1, 0, 0, 2),
  (4001050, 'Trail A', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001051, 'Trail B', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001052, 'Trail C', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001053, 'Captive A', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001054, 'Captive B', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001055, 'Captive C', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001056, 'Ward A', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001057, 'Ward B', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001058, 'Ward C', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001059, 'Compare', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001060, 'Commander', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001061, 'Recruit', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001062, 'Signal', '', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `subname` = VALUES(`subname`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `exp` = VALUES(`exp`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `AIName` = VALUES(`AIName`), `ScriptName` = VALUES(`ScriptName`), `HealthModifier` = VALUES(`HealthModifier`), `DamageModifier` = VALUES(`DamageModifier`), `ExperienceModifier` = VALUES(`ExperienceModifier`), `lootid` = VALUES(`lootid`), `flags_extra` = VALUES(`flags_extra`);
DELETE FROM `creature_template_model` WHERE `CreatureID` IN (4001000, 4001001, 4001002, 4001003, 4001005, 4001006, 4001007, 4001004, 4001008, 4001009, 4001010, 4001011, 4001012, 4001013, 4001050, 4001051, 4001052, 4001053, 4001054, 4001055, 4001056, 4001057, 4001058, 4001059, 4001060, 4001061, 4001062);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
  (4001000, 0, 59, 1, 1),
  (4001001, 0, 49, 1, 1),
  (4001002, 0, 55, 1, 1),
  (4001003, 0, 49, 1, 1),
  (4001005, 0, 56, 1, 1),
  (4001006, 0, 50, 1, 1),
  (4001007, 0, 51, 1, 1),
  (4001004, 0, 50, 1, 1),
  (4001008, 0, 59, 1, 1),
  (4001009, 0, 55, 1, 1),
  (4001010, 0, 49, 1, 1),
  (4001011, 0, 49, 1, 1),
  (4001012, 0, 453, 1, 1),
  (4001013, 0, 11686, 1, 1),
  (4001050, 0, 11686, 1, 1),
  (4001051, 0, 11686, 1, 1),
  (4001052, 0, 11686, 1, 1),
  (4001053, 0, 11686, 1, 1),
  (4001054, 0, 11686, 1, 1),
  (4001055, 0, 11686, 1, 1),
  (4001056, 0, 11686, 1, 1),
  (4001057, 0, 11686, 1, 1),
  (4001058, 0, 11686, 1, 1),
  (4001059, 0, 11686, 1, 1),
  (4001060, 0, 11686, 1, 1),
  (4001061, 0, 11686, 1, 1),
  (4001062, 0, 11686, 1, 1);
INSERT INTO `mod_customnpcs_outfit` (`outfit_id`, `race`, `gender`, `class`, `skin`, `face`, `hair`, `hair_color`, `facial_hair`, `chest`, `shoulders`, `shirt`, `waist`, `legs`, `feet`, `hands`, `mainhand`, `ranged`) VALUES
  (4001000, 6, 0, 1, 0, 0, 0, 0, 0, 6569, 0, 0, 6570, 6568, 0, 14089, 6631, 0),
  (4001001, 1, 0, 1, 0, 0, 0, 0, 0, 9748, 0, 0, 0, 0, 0, 0, 4575, 0),
  (4001002, 4, 0, 1, 0, 0, 0, 0, 0, 6085, 6597, 0, 6594, 6596, 6573, 0, 0, 0),
  (4001003, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 0, 0, 0, 0, 0),
  (4001005, 4, 1, 1, 0, 0, 0, 0, 0, 2317, 0, 0, 6382, 0, 2315, 4248, 0, 0),
  (4001006, 1, 1, 1, 0, 0, 0, 0, 0, 1433, 0, 2576, 0, 0, 0, 0, 0, 0),
  (4001007, 2, 0, 1, 0, 0, 0, 0, 0, 85, 0, 38, 0, 0, 0, 0, 0, 0),
  (4001004, 1, 1, 1, 0, 0, 0, 0, 0, 1433, 0, 0, 0, 0, 0, 0, 0, 0),
  (4001008, 6, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 0, 0, 0, 0, 0),
  (4001009, 4, 0, 1, 0, 0, 0, 0, 0, 85, 0, 0, 0, 0, 0, 0, 0, 0),
  (4001010, 1, 0, 1, 0, 0, 0, 0, 0, 2317, 0, 0, 0, 0, 2315, 4248, 0, 2504),
  (4001011, 1, 0, 1, 0, 0, 0, 0, 0, 6085, 6597, 0, 6594, 6596, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE
  `race` = VALUES(`race`), `gender` = VALUES(`gender`), `class` = VALUES(`class`), `skin` = VALUES(`skin`), `face` = VALUES(`face`), `hair` = VALUES(`hair`), `hair_color` = VALUES(`hair_color`), `facial_hair` = VALUES(`facial_hair`), `chest` = VALUES(`chest`), `shoulders` = VALUES(`shoulders`), `shirt` = VALUES(`shirt`), `waist` = VALUES(`waist`), `legs` = VALUES(`legs`), `feet` = VALUES(`feet`), `hands` = VALUES(`hands`), `mainhand` = VALUES(`mainhand`), `ranged` = VALUES(`ranged`);
INSERT INTO `mod_customnpcs_outfit_entry` (`creature_entry`, `outfit_id`) VALUES
  (4001000, 4001000),
  (4001001, 4001001),
  (4001002, 4001002),
  (4001003, 4001003),
  (4001005, 4001005),
  (4001006, 4001006),
  (4001007, 4001007),
  (4001004, 4001004),
  (4001008, 4001008),
  (4001009, 4001009),
  (4001010, 4001010),
  (4001011, 4001011)
ON DUPLICATE KEY UPDATE
  `outfit_id` = VALUES(`outfit_id`);
DELETE FROM `creature_template_addon` WHERE `entry` = 4001002;
INSERT INTO `creature_template_addon` (`entry`, `emote`) VALUES
  (4001002, 68);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` IN (4001010, 4001011, 4001012);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `comment`) VALUES
  (4001010, 0, 0, 0, 0, 0, 100, 0, 2500, 4000, 7000, 10000, 11, 6660, 0, 0, 0, 0, 0, 2, 0, 0, 0, 'Broken Seal C01: Twilight Scout - native combat spell'),
  (4001011, 0, 0, 0, 0, 0, 100, 0, 2500, 4000, 7000, 10000, 11, 11976, 0, 0, 0, 0, 0, 2, 0, 0, 0, 'Broken Seal C01: Twilight Guard - native combat spell'),
  (4001012, 0, 0, 0, 0, 0, 100, 0, 2500, 4000, 7000, 10000, 11, 8078, 0, 0, 0, 0, 0, 2, 0, 0, 0, 'Broken Seal C01: Unbound Earth Elemental - native combat spell');
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `bonding`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `PageText`, `description`, `spellid_1`, `spelltrigger_1`, `ScriptName`) VALUES
  (900100, 12, 0, 'Expedition Invitation', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 4001000, 'The Vale Expedition', 0, 0, ''),
  (900101, 12, 0, 'Missing Travelers Log', 1143, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 4001001, 'The Vale Expedition', 0, 0, ''),
  (900102, 12, 0, 'Coded Twilight Orders', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 4001002, 'The Vale Expedition', 0, 0, ''),
  (900103, 12, 0, 'Damaged Ward Rubbing', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 4001003, 'The Vale Expedition', 0, 0, ''),
  (900104, 12, 0, 'Ward Tracing Kit', 7411, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 0, 'Use on a ward stone. Maruut can replace a lost kit.', 3365, 0, 'item_bs_c01_tracing_kit'),
  (900110, 4, 0, 'Vale Expedition Signet of Might', 9846, 2, 11, -1, -1, 25, 20, 1, 1, 1, 4, 4, 7, 3, 0, 0, 0, 'The Vale Expedition', 0, 0, ''),
  (900111, 4, 0, 'Vale Expedition Signet of Precision', 9846, 2, 11, -1, -1, 25, 20, 1, 1, 1, 3, 4, 7, 3, 0, 0, 0, 'The Vale Expedition', 0, 0, ''),
  (900112, 4, 0, 'Vale Expedition Signet of Sorcery', 9846, 2, 11, -1, -1, 25, 20, 1, 1, 1, 5, 4, 7, 3, 45, 3, 0, 'The Vale Expedition', 0, 0, ''),
  (900113, 4, 0, 'Vale Expedition Signet of Restoration', 9846, 2, 11, -1, -1, 25, 20, 1, 1, 1, 5, 3, 6, 4, 45, 4, 0, 'The Vale Expedition', 0, 0, ''),
  (900114, 4, 0, 'Vale Expedition Signet of Guarding', 9846, 2, 11, -1, -1, 25, 20, 1, 1, 1, 7, 6, 4, 2, 12, 2, 0, 'The Vale Expedition', 0, 0, ''),
  (900115, 4, 0, 'Vale Expedition Signet of Balance', 9846, 2, 11, -1, -1, 25, 20, 1, 1, 1, 5, 3, 7, 3, 43, 2, 0, 'The Vale Expedition', 0, 0, '')
ON DUPLICATE KEY UPDATE
  `class` = VALUES(`class`), `subclass` = VALUES(`subclass`), `name` = VALUES(`name`), `displayid` = VALUES(`displayid`), `Quality` = VALUES(`Quality`), `InventoryType` = VALUES(`InventoryType`), `AllowableClass` = VALUES(`AllowableClass`), `AllowableRace` = VALUES(`AllowableRace`), `ItemLevel` = VALUES(`ItemLevel`), `RequiredLevel` = VALUES(`RequiredLevel`), `maxcount` = VALUES(`maxcount`), `stackable` = VALUES(`stackable`), `bonding` = VALUES(`bonding`), `stat_type1` = VALUES(`stat_type1`), `stat_value1` = VALUES(`stat_value1`), `stat_type2` = VALUES(`stat_type2`), `stat_value2` = VALUES(`stat_value2`), `stat_type3` = VALUES(`stat_type3`), `stat_value3` = VALUES(`stat_value3`), `PageText` = VALUES(`PageText`), `description` = VALUES(`description`), `spellid_1` = VALUES(`spellid_1`), `spelltrigger_1` = VALUES(`spelltrigger_1`), `ScriptName` = VALUES(`ScriptName`);
INSERT INTO `page_text` (`ID`, `Text`, `NextPageID`) VALUES
  (4001000, 'To the bearer: report to Maruut Stonebinder at the expedition camp on the eastern approach to the Charred Vale. We need someone who can look beyond uniforms. Our people are missing, and the stones have begun to speak.', 0),
  (4001001, 'Mira, Dorn and Teren departed with surveying tools. Their final note describes fresh ash beside intact trees, bootprints moving toward the old valley, and a stone marker scratched with a spiral. They did not return.', 0),
  (4001002, 'Collect the surveyors alive. Keep the commander apart from the other prisoners. The buyer has no use for broken tools. Rotate the watch at the marked post. The spiral is our sign.', 0),
  (4001003, 'Three impressions reveal the same spiral cut across older runes. The fractures are too regular to be weathering. Someone is teaching the stone a different command.', 0)
ON DUPLICATE KEY UPDATE
  `Text` = VALUES(`Text`), `NextPageID` = VALUES(`NextPageID`);
DELETE FROM `creature_loot_template` WHERE `Entry` = 4001010;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001010, 900102, 0, 100, 1, 1, 0, 1, 1);
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `RewardXPDifficulty`, `RewardMoney`, `StartItem`, `Flags`, `AllowableRaces`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`, `RequiredNpcOrGo3`, `RequiredNpcOrGo4`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGoCount4`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`, `RequiredItemId1`, `RequiredItemId2`, `RequiredItemId3`, `RequiredItemId4`, `RequiredItemId5`, `RequiredItemId6`, `RequiredItemCount1`, `RequiredItemCount2`, `RequiredItemCount3`, `RequiredItemCount4`, `RequiredItemCount5`, `RequiredItemCount6`, `RewardChoiceItemID1`, `RewardChoiceItemID2`, `RewardChoiceItemID3`, `RewardChoiceItemID4`, `RewardChoiceItemID5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity1`, `RewardChoiceItemQuantity2`, `RewardChoiceItemQuantity3`, `RewardChoiceItemQuantity4`, `RewardChoiceItemQuantity5`, `RewardChoiceItemQuantity6`) VALUES
  (900100, 2, 20, 20, 406, 2, 300, 900100, 0, 1101, 'An Unusual Commission', 'Follow the old road toward the Charred Vale and look for the expedition''s blue-clad stonebinder.', 'The expedition in Stonetalon is accepting help from anyone willing to put missing travelers before old quarrels. Take this invitation to Maruut Stonebinder. His camp is on the eastern approach to the Charred Vale.', 'Follow the old road toward the Charred Vale and look for the expedition''s blue-clad stonebinder.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900101, 2, 20, 20, 406, 2, 300, 900100, 0, 690, 'An Unusual Commission', 'Look for the expedition camp above the Charred Vale. Maruut will recognize the invitation.', 'Maruut Stonebinder needs help in Stonetalon. Three surveyors have vanished near the Charred Vale. This is an expedition, not a border dispute. Take this invitation to his neutral camp on the valley''s eastern approach.', 'Look for the expedition camp above the Charred Vale. Maruut will recognize the invitation.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900102, 2, 21, 20, 406, 4, 600, 0, 0, 0, 'Travelers Who Never Arrived', 'Inspect the abandoned wagon above camp and recover its log.', 'Mira, Dorn and Teren were inspecting old trail stones. Their wagon was left uphill from our camp, near the first ash-marked sign. Search it for the travelers'' log. Leave what supplies remain for the survivors.', 'Inspect the abandoned wagon above camp and recover its log.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900101, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900103, 2, 21, 20, 406, 4, 600, 0, 0, 0, 'Follow the Ash', 'Inspect all three distinct signs, defeat six Twilight Scouts and recover their coded orders.', 'Follow the three ash-marked signs from the expedition approach into the Charred Vale. Inspect each one and defeat six Twilight scouts on that route. Recover a copy of their orders as well. We need evidence, not guesses.', 'Inspect all three distinct signs, defeat six Twilight Scouts and recover their coded orders.', 4001010, 4001050, 4001051, 4001052, 6, 1, 1, 1, 'Twilight Scouts defeated', 'Trail A completed', 'Trail B completed', 'Trail C completed', 900102, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900104, 2, 22, 20, 406, 4, 600, 0, 0, 0, 'Bring Them Home', 'Open each surveyor''s cage and accompany them until they reach the marked refuge.', 'The scouts are holding Mira, Dorn and Teren in three cages below the last trail marker. Free each of them and stay nearby while they reach the expedition refuge marker. Clear trouble from the route; nobody gets left behind.', 'Open each surveyor''s cage and accompany them until they reach the marked refuge.', 4001053, 4001054, 4001055, 0, 1, 1, 1, 0, 'Captive A completed', 'Captive B completed', 'Captive C completed', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900105, 2, 23, 20, 406, 4, 600, 900104, 0, 0, 'A Stone That Should Be Quiet', 'Trace all three ward stones and recover a complete rubbing. I can replace a lost kit.', 'Our workers saw the cult cutting older runes. Take this tracing kit to the three ward stones west of the prison site. Use it on each distinct stone, then bring me the complete rubbing. Be careful: the stones are already disturbing the earth around them.', 'Trace all three ward stones and recover a complete rubbing. I can replace a lost kit.', 4001056, 4001057, 4001058, 0, 1, 1, 1, 0, 'Ward A completed', 'Ward B completed', 'Ward C completed', '', 900103, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900106, 2, 23, 20, 406, 2, 600, 0, 0, 0, 'The Same Hand', 'Ask Ortell to compare the orders and the rubbing.', 'Ortell once knew the Twilight''s Hammer from the inside. He is helping us now. Speak with him here in camp and compare the deposited orders with the ward rubbing. You do not need to carry those papers back and forth; I have sent him copies.', 'Ask Ortell to compare the orders and the rubbing.', 4001059, 0, 0, 0, 1, 0, 0, 0, 'Orders and rubbing compared', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900107, 2, 24, 20, 406, 4, 600, 0, 0, 0, 'A Captive Commander', 'Remain at the concealed observation point until you can confirm Jarod is alive.', 'The rescued surveyors recognized the commander''s name: Jarod Shadowsong. The cult is holding him at an altar beyond their cages. Observe it from the concealed stone marker to the west. Remain quiet and out of combat. Do not charge the altar; we need to know he is alive before we plan a rescue.', 'Remain at the concealed observation point until you can confirm Jarod is alive.', 4001060, 0, 0, 0, 1, 0, 0, 0, 'Jarod observed safely', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900108, 2, 25, 20, 406, 2, 600, 0, 0, 0, 'The Name on the Papers', 'Watch the recruit''s change from the dead drop, then agree the extraction signal with me.', 'There is a recruit moving between the watch posts beside the prison site. Use my dead drop south of the observation point and watch a full change of position without entering combat. Then return and agree the signal with me. We will need papers and patience to get inside.', 'Watch the recruit''s change from the dead drop, then agree the extraction signal with me.', 4001061, 4001062, 0, 0, 1, 1, 0, 0, 'Recruit watch change observed', 'Extraction signal agreed', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 900110, 900111, 900112, 900113, 900114, 900115, 1, 1, 1, 1, 1, 1)
ON DUPLICATE KEY UPDATE
  `QuestType` = VALUES(`QuestType`), `QuestLevel` = VALUES(`QuestLevel`), `MinLevel` = VALUES(`MinLevel`), `QuestSortID` = VALUES(`QuestSortID`), `RewardXPDifficulty` = VALUES(`RewardXPDifficulty`), `RewardMoney` = VALUES(`RewardMoney`), `StartItem` = VALUES(`StartItem`), `Flags` = VALUES(`Flags`), `AllowableRaces` = VALUES(`AllowableRaces`), `LogTitle` = VALUES(`LogTitle`), `LogDescription` = VALUES(`LogDescription`), `QuestDescription` = VALUES(`QuestDescription`), `QuestCompletionLog` = VALUES(`QuestCompletionLog`), `RequiredNpcOrGo1` = VALUES(`RequiredNpcOrGo1`), `RequiredNpcOrGo2` = VALUES(`RequiredNpcOrGo2`), `RequiredNpcOrGo3` = VALUES(`RequiredNpcOrGo3`), `RequiredNpcOrGo4` = VALUES(`RequiredNpcOrGo4`), `RequiredNpcOrGoCount1` = VALUES(`RequiredNpcOrGoCount1`), `RequiredNpcOrGoCount2` = VALUES(`RequiredNpcOrGoCount2`), `RequiredNpcOrGoCount3` = VALUES(`RequiredNpcOrGoCount3`), `RequiredNpcOrGoCount4` = VALUES(`RequiredNpcOrGoCount4`), `ObjectiveText1` = VALUES(`ObjectiveText1`), `ObjectiveText2` = VALUES(`ObjectiveText2`), `ObjectiveText3` = VALUES(`ObjectiveText3`), `ObjectiveText4` = VALUES(`ObjectiveText4`), `RequiredItemId1` = VALUES(`RequiredItemId1`), `RequiredItemId2` = VALUES(`RequiredItemId2`), `RequiredItemId3` = VALUES(`RequiredItemId3`), `RequiredItemId4` = VALUES(`RequiredItemId4`), `RequiredItemId5` = VALUES(`RequiredItemId5`), `RequiredItemId6` = VALUES(`RequiredItemId6`), `RequiredItemCount1` = VALUES(`RequiredItemCount1`), `RequiredItemCount2` = VALUES(`RequiredItemCount2`), `RequiredItemCount3` = VALUES(`RequiredItemCount3`), `RequiredItemCount4` = VALUES(`RequiredItemCount4`), `RequiredItemCount5` = VALUES(`RequiredItemCount5`), `RequiredItemCount6` = VALUES(`RequiredItemCount6`), `RewardChoiceItemID1` = VALUES(`RewardChoiceItemID1`), `RewardChoiceItemID2` = VALUES(`RewardChoiceItemID2`), `RewardChoiceItemID3` = VALUES(`RewardChoiceItemID3`), `RewardChoiceItemID4` = VALUES(`RewardChoiceItemID4`), `RewardChoiceItemID5` = VALUES(`RewardChoiceItemID5`), `RewardChoiceItemID6` = VALUES(`RewardChoiceItemID6`), `RewardChoiceItemQuantity1` = VALUES(`RewardChoiceItemQuantity1`), `RewardChoiceItemQuantity2` = VALUES(`RewardChoiceItemQuantity2`), `RewardChoiceItemQuantity3` = VALUES(`RewardChoiceItemQuantity3`), `RewardChoiceItemQuantity4` = VALUES(`RewardChoiceItemQuantity4`), `RewardChoiceItemQuantity5` = VALUES(`RewardChoiceItemQuantity5`), `RewardChoiceItemQuantity6` = VALUES(`RewardChoiceItemQuantity6`);
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`, `ExclusiveGroup`, `ProvidedItemCount`, `SpecialFlags`) VALUES
  (900100, 0, 900102, 900100, 1, 256),
  (900101, 0, 900102, 900100, 1, 256),
  (900102, 0, 0, 0, 0, 256),
  (900103, 900102, 0, 0, 0, 256),
  (900104, 900103, 0, 0, 0, 256),
  (900105, 900104, 0, 0, 1, 256),
  (900106, 900105, 0, 0, 0, 256),
  (900107, 900106, 0, 0, 0, 256),
  (900108, 900107, 0, 0, 0, 256)
ON DUPLICATE KEY UPDATE
  `PrevQuestID` = VALUES(`PrevQuestID`), `NextQuestID` = VALUES(`NextQuestID`), `ExclusiveGroup` = VALUES(`ExclusiveGroup`), `ProvidedItemCount` = VALUES(`ProvidedItemCount`), `SpecialFlags` = VALUES(`SpecialFlags`);
DELETE FROM `creature_queststarter` WHERE `quest` IN (900100, 900101, 900102, 900103, 900104, 900105, 900106, 900107, 900108);
DELETE FROM `creature_questender` WHERE `quest` IN (900100, 900101, 900102, 900103, 900104, 900105, 900106, 900107, 900108);
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
  (4001006, 900100),
  (4001007, 900101),
  (4001000, 900102),
  (4001005, 900103),
  (4001005, 900104),
  (4001000, 900105),
  (4001000, 900106),
  (4001001, 900107),
  (4001001, 900108);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
  (4001000, 900100),
  (4001000, 900101),
  (4001000, 900102),
  (4001005, 900103),
  (4001005, 900104),
  (4001000, 900105),
  (4001001, 900106),
  (4001001, 900107),
  (4001001, 900108);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) VALUES
  (900100, 'You came. Good. Three of our people are overdue, and the trail is beginning to give answers I do not like.'),
  (900101, 'You came. Good. Three of our people are overdue, and the trail is beginning to give answers I do not like.'),
  (900102, 'The spiral again. It was carved into stone that had stood quietly for generations. Our scout has found fresh tracks leading into the valley.'),
  (900103, 'Prisoners, a separate commander, and a watch rotation. Those were not bandits taking whatever they could carry. Someone organized this.'),
  (900104, 'All three are safe. They remember a spiral carved into the ward stones and a prisoner called Shadowsong. Maruut needs to hear this.'),
  (900105, 'Those are deliberate cuts. The new spiral interrupts the old pattern at exactly the points it needs. Ortell knows the people who use that sign.'),
  (900106, 'The hand that wrote the orders also marked the stone. That spiral is an instruction, not a decoration. We must find out what else they intend to break.'),
  (900107, 'Alive, guarded, and kept apart from the workers. They are preparing something public. A direct assault would give them time to kill him.'),
  (900108, 'Two short knocks, then a pause. If the wrong person answers, you walk away. You have earned this signet, and the expedition''s trust. We will enter the cult when the next assignment is ready; be at least level twenty-five before attempting that training.')
ON DUPLICATE KEY UPDATE
  `RewardText` = VALUES(`RewardText`);
INSERT INTO `quest_request_items` (`ID`, `CompletionText`) VALUES
  (900100, 'Follow the old road toward the Charred Vale and look for the expedition''s blue-clad stonebinder.'),
  (900101, 'Look for the expedition camp above the Charred Vale. Maruut will recognize the invitation.'),
  (900102, 'Inspect the abandoned wagon above camp and recover its log.'),
  (900103, 'Inspect all three distinct signs, defeat six Twilight Scouts and recover their coded orders.'),
  (900104, 'Open each surveyor''s cage and accompany them until they reach the marked refuge.'),
  (900105, 'Trace all three ward stones and recover a complete rubbing. I can replace a lost kit.'),
  (900106, 'Ask Ortell to compare the orders and the rubbing.'),
  (900107, 'Remain at the concealed observation point until you can confirm Jarod is alive.'),
  (900108, 'Watch the recruit''s change from the dead drop, then agree the extraction signal with me.')
ON DUPLICATE KEY UPDATE
  `CompletionText` = VALUES(`CompletionText`);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 19 AND `SourceEntry` IN (900100, 900101, 900102, 900103, 900104, 900105, 900106, 900107, 900108);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceEntry`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionValue1`, `Comment`) VALUES
  (19, 900102, 0, 8, 900100, 'Broken Seal C01: either faction invitation must be rewarded'),
  (19, 900102, 1, 8, 900101, 'Broken Seal C01: either faction invitation must be rewarded');
DELETE FROM `quest_poi_points` WHERE `QuestID` IN (900100, 900101, 900102, 900103, 900104, 900105, 900106, 900107, 900108);
DELETE FROM `quest_poi` WHERE `QuestID` IN (900100, 900101, 900102, 900103, 900104, 900105, 900106, 900107, 900108);
INSERT INTO `quest_poi` (`QuestID`, `id`, `ObjectiveIndex`, `MapID`, `WorldMapAreaId`, `Floor`, `Priority`, `Flags`) VALUES
  (900100, 0, -1, 1, 81, 0, 0, 0),
  (900101, 0, -1, 1, 81, 0, 0, 0),
  (900102, 0, -1, 1, 81, 0, 0, 0),
  (900102, 1, 0, 1, 81, 0, 0, 0),
  (900103, 0, -1, 1, 81, 0, 0, 0),
  (900103, 1, 0, 1, 81, 0, 0, 0),
  (900103, 2, 1, 1, 81, 0, 0, 0),
  (900103, 3, 2, 1, 81, 0, 0, 0),
  (900103, 4, 3, 1, 81, 0, 0, 0),
  (900104, 0, -1, 1, 81, 0, 0, 0),
  (900104, 1, 0, 1, 81, 0, 0, 0),
  (900104, 2, 1, 1, 81, 0, 0, 0),
  (900104, 3, 2, 1, 81, 0, 0, 0),
  (900105, 0, -1, 1, 81, 0, 0, 0),
  (900105, 1, 0, 1, 81, 0, 0, 0),
  (900105, 2, 1, 1, 81, 0, 0, 0),
  (900105, 3, 2, 1, 81, 0, 0, 0),
  (900106, 0, -1, 1, 81, 0, 0, 0),
  (900106, 1, 0, 1, 81, 0, 0, 0),
  (900107, 0, -1, 1, 81, 0, 0, 0),
  (900107, 1, 0, 1, 81, 0, 0, 0),
  (900108, 0, -1, 1, 81, 0, 0, 0),
  (900108, 1, 0, 1, 81, 0, 0, 0),
  (900108, 2, 1, 1, 81, 0, 0, 0);
INSERT INTO `quest_poi_points` (`QuestID`, `Idx1`, `Idx2`, `X`, `Y`) VALUES
  (900100, 0, 0, 1124, 1546),
  (900101, 0, 0, 1124, 1546),
  (900102, 0, 0, 1124, 1546),
  (900102, 1, 0, 1152, 1516),
  (900103, 0, 0, 1118, 1551),
  (900103, 1, 0, 1004, 1648),
  (900103, 2, 0, 1150, 1510),
  (900103, 3, 0, 1100, 1550),
  (900103, 4, 0, 1010, 1660),
  (900104, 0, 0, 1118, 1551),
  (900104, 1, 0, 985, 1685),
  (900104, 2, 0, 971, 1694),
  (900104, 3, 0, 952, 1690),
  (900105, 0, 0, 1124, 1546),
  (900105, 1, 0, 935, 1690),
  (900105, 2, 0, 925, 1710),
  (900105, 3, 0, 930, 1730),
  (900106, 0, 0, 1120, 1550),
  (900106, 1, 0, 1120, 1550),
  (900107, 0, 0, 1120, 1550),
  (900107, 1, 0, 958, 1700),
  (900108, 0, 0, 1120, 1550),
  (900108, 1, 0, 958, 1690),
  (900108, 2, 0, 1120, 1550);
INSERT INTO `npc_text` (`ID`, `text0_0`, `Probability0`) VALUES
  (4001000, 'Old stones do not start speaking without a reason. Help us find our missing people, and we will learn who disturbed them.', 1),
  (4001001, 'The Twilight''s Hammer rewards certainty. Inside their camps, doubt is best kept behind your teeth.', 1),
  (4001005, 'Fresh ash, bootprints, and a trail nobody wants to explain. Stay alert on the descent.', 1),
  (4001006, 'A neutral expedition needs someone who can see past the color of a banner.', 1),
  (4001007, 'The invitation is for a willing traveler. The missing people need help, not another argument about borders.', 1)
ON DUPLICATE KEY UPDATE
  `text0_0` = VALUES(`text0_0`), `Probability0` = VALUES(`Probability0`);
DELETE FROM `gossip_menu` WHERE `MenuID` IN (4001000, 4001001, 4001005, 4001006, 4001007);
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
  (4001000, 4001000),
  (4001001, 4001001),
  (4001005, 4001005),
  (4001006, 4001006),
  (4001007, 4001007);
UPDATE `creature_template` SET `gossip_menu_id` = `entry` WHERE `entry` IN (4001000, 4001001, 4001005, 4001006, 4001007);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data1`, `Data3`, `Data5`, `Data18`, `ScriptName`) VALUES
  (4001100, 10, 3678, 'Abandoned Expedition Wagon', 1.0, 900102, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001101, 10, 22, 'First Ash-marked Trail Sign', 1.0, 900103, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001102, 10, 22, 'Second Ash-marked Trail Sign', 1.0, 900103, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001103, 10, 22, 'Third Ash-marked Trail Sign', 1.0, 900103, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001104, 10, 676, 'Mira''s Holding Cage', 0.8, 900104, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001105, 10, 676, 'Dorn''s Holding Cage', 0.8, 900104, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001106, 10, 676, 'Teren''s Holding Cage', 0.8, 900104, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001107, 10, 235, 'Western Ward Stone', 1.0, 900105, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001108, 10, 235, 'Central Ward Stone', 1.0, 900105, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001109, 10, 235, 'Eastern Ward Stone', 1.0, 900105, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001110, 10, 236, 'Concealed Observation Point', 1.0, 900107, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001111, 10, 3332, 'Ortell''s Dead Drop', 1.0, 900108, 0, 0, 1, 'go_bs_c01_interaction'),
  (4001112, 5, 227, 'Twilight Sacrificial Altar', 1.0, 0, 0, 0, 1, ''),
  (4001113, 5, 22, 'Expedition Refuge Marker', 1.0, 0, 0, 0, 1, '')
ON DUPLICATE KEY UPDATE
  `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `size` = VALUES(`size`), `Data1` = VALUES(`Data1`), `Data3` = VALUES(`Data3`), `Data5` = VALUES(`Data5`), `Data18` = VALUES(`Data18`), `ScriptName` = VALUES(`ScriptName`);
DROP TEMPORARY TABLE IF EXISTS `bs_c01_creature_spawns`;
CREATE TEMPORARY TABLE `bs_c01_creature_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_c01_gameobject_spawns`;
CREATE TEMPORARY TABLE `bs_c01_gameobject_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c01_creature_spawns` (`spawn_key`, `entry`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C01:NPC_MARUUT:maruut', 4001000, 1124.0, 1546.0, 33.2028, 3.14),
  ('BS-C01:NPC_ORTELL:ortell', 4001001, 1120.0, 1550.0, 34.5478, 3.14),
  ('BS-C01:NPC_JAROD:jarod', 4001002, 990.0, 1730.0, -9.6758, 3.14),
  ('BS-C01:NPC_RECRUIT:recruit_1', 4001003, 997.0, 1710.0, -7.759, 3.14),
  ('BS-C01:NPC_SCOUT:scout', 4001005, 1118.0, 1551.0, 35.0452, 3.14),
  ('BS-C01:NPC_COURIER_A:courier_a', 4001006, 746.0, 322.0, 63.3356, 3.14),
  ('BS-C01:NPC_COURIER_H:courier_h', 4001007, 956.106, 1005.78, 102.5642, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_1', 4001010, 1000.0, 1660.0, 6.3648, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_2', 4001010, 990.0, 1645.0, 12.4221, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_3', 4001010, 1020.0, 1640.0, 19.7295, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_4', 4001010, 1040.0, 1646.13, 11.7481, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_5', 4001010, 1004.0, 1648.0, 9.2767, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_6', 4001010, 983.0, 1668.0, -6.5765, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_7', 4001010, 963.0, 1672.0, -8.5886, 3.14),
  ('BS-C01:NPC_CULT_SCOUT:scout_8', 4001010, 942.0, 1655.0, -12.6257, 3.14),
  ('BS-C01:NPC_CULT_GUARD:guard_1', 4001011, 981.0, 1723.0, -9.2015, 3.14),
  ('BS-C01:NPC_CULT_GUARD:guard_2', 4001011, 999.0, 1721.0, -9.9455, 3.14),
  ('BS-C01:NPC_CULT_GUARD:guard_3', 4001011, 992.0, 1742.0, -7.2726, 3.14),
  ('BS-C01:NPC_CULT_GUARD:cage_guard_1', 4001011, 979.0, 1682.0, -7.026, 3.14),
  ('BS-C01:NPC_CULT_GUARD:cage_guard_2', 4001011, 965.0, 1691.0, -9.2075, 3.14),
  ('BS-C01:NPC_CULT_GUARD:cage_guard_3', 4001011, 946.0, 1687.0, -13.6669, 3.14),
  ('BS-C01:NPC_EARTH:earth_1', 4001012, 917.0, 1698.0, -16.2688, 3.14),
  ('BS-C01:NPC_EARTH:earth_2', 4001012, 912.0, 1720.0, -15.0397, 3.14),
  ('BS-C01:NPC_EARTH:earth_3', 4001012, 940.0, 1735.0, -10.6019, 3.14);
INSERT INTO `bs_c01_gameobject_spawns` (`spawn_key`, `entry`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C01:GO_WAGON', 4001100, 1152.0, 1516.0, 47.4284, 3.14),
  ('BS-C01:GO_TRAIL_A', 4001101, 1150.0, 1510.0, 47.5968, 3.14),
  ('BS-C01:GO_TRAIL_B', 4001102, 1100.0, 1550.0, 28.5585, 3.14),
  ('BS-C01:GO_TRAIL_C', 4001103, 1010.0, 1660.0, 0.0815, 3.14),
  ('BS-C01:GO_CAGE_A', 4001104, 985.0, 1685.0, -6.814, 3.14),
  ('BS-C01:GO_CAGE_B', 4001105, 971.0, 1694.0, -8.5529, 3.14),
  ('BS-C01:GO_CAGE_C', 4001106, 952.0, 1690.0, -12.7174, 3.14),
  ('BS-C01:GO_WARD_A', 4001107, 935.0, 1690.0, -16.0457, 3.14),
  ('BS-C01:GO_WARD_B', 4001108, 925.0, 1710.0, -15.1322, 3.14),
  ('BS-C01:GO_WARD_C', 4001109, 930.0, 1730.0, -11.9326, 3.14),
  ('BS-C01:GO_COVER', 4001110, 958.0, 1700.0, -13.0579, 3.14),
  ('BS-C01:GO_DEAD_DROP', 4001111, 958.0, 1690.0, -10.9006, 3.14),
  ('BS-C01:GO_ALTAR', 4001112, 990.0, 1734.0, -9.1447, 3.14),
  ('BS-C01:GO_RALLY', 4001113, 1012.0, 1655.0, 0.6661, 3.14);

SET @BS_C01_ENTRY_COLUMN := (
  SELECT `COLUMN_NAME` FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'creature' AND `COLUMN_NAME` IN ('id1', 'id')
  ORDER BY `COLUMN_NAME` DESC LIMIT 1
);
SET @BS_C01_INSERT := CONCAT(
  'INSERT INTO `creature` (`', @BS_C01_ENTRY_COLUMN, '`, `map`, `zoneId`, `spawnMask`, `phaseMask`, ',
  '`position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `curhealth`, `curmana`, `Comment`) ',
  'SELECT s.`entry`, 1, 406, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, 90, 0, 0, s.`spawn_key` ',
  'FROM `bs_c01_creature_spawns` s LEFT JOIN `creature` c ON c.`Comment` = s.`spawn_key` WHERE c.`guid` IS NULL'
);
PREPARE bs_c01_stmt FROM @BS_C01_INSERT;
EXECUTE bs_c01_stmt;
DEALLOCATE PREPARE bs_c01_stmt;
SET @BS_C01_UPDATE := CONCAT(
  'UPDATE `creature` c INNER JOIN `bs_c01_creature_spawns` s ON c.`Comment` = s.`spawn_key` ',
  'SET c.`', @BS_C01_ENTRY_COLUMN, '` = s.`entry`, c.`position_x` = s.`x`, c.`position_y` = s.`y`, ',
  'c.`position_z` = s.`z`, c.`orientation` = s.`o`'
);
PREPARE bs_c01_stmt FROM @BS_C01_UPDATE;
EXECUTE bs_c01_stmt;
DEALLOCATE PREPARE bs_c01_stmt;
INSERT INTO `gameobject`
  (`id`, `map`, `zoneId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`,
   `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`)
SELECT s.`entry`, 1, 406, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, SIN(s.`o` / 2), COS(s.`o` / 2), 90, 100, 1, s.`spawn_key`
FROM `bs_c01_gameobject_spawns` s LEFT JOIN `gameobject` g ON g.`Comment` = s.`spawn_key` WHERE g.`guid` IS NULL;
UPDATE `gameobject` g INNER JOIN `bs_c01_gameobject_spawns` s ON g.`Comment` = s.`spawn_key`
SET g.`id` = s.`entry`, g.`position_x` = s.`x`, g.`position_y` = s.`y`, g.`position_z` = s.`z`, g.`orientation` = s.`o`,
  g.`rotation2` = SIN(s.`o` / 2), g.`rotation3` = COS(s.`o` / 2);
DROP TEMPORARY TABLE `bs_c01_creature_spawns`;
DROP TEMPORARY TABLE `bs_c01_gameobject_spawns`;
DROP TEMPORARY TABLE `bs_c01_ids`;
COMMIT;
