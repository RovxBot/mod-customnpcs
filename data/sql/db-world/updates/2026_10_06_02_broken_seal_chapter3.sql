-- The Broken Seal, Chapter 3: The Dawnchaser Promise (levels 30-35).
-- Generated from data/quests/broken_seal_chapter3.json. Native 3.3.5a assets only.
-- Requires Chapters 1 and 2, custom_npc_appearances.sql and the rebuilt module.
-- Reapplication preserves GUIDs. Occupied IDs and missing Chapter 2 reject before content DML.
-- See docs/broken-seal/chapter3-implementation.md.
CREATE TABLE IF NOT EXISTS `mod_customnpcs_bs_content` (
  `kind` VARCHAR(16) NOT NULL,
  `entry` INT UNSIGNED NOT NULL,
  `chapter` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_c03_ids`;
CREATE TEMPORARY TABLE `bs_c03_ids` (
  `kind` VARCHAR(16) NOT NULL, `entry` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c03_ids` (`kind`, `entry`) VALUES
  ('creature', 4001400),
  ('creature', 4001401),
  ('creature', 4001402),
  ('creature', 4001403),
  ('creature', 4001404),
  ('creature', 4001405),
  ('creature', 4001406),
  ('creature', 4001407),
  ('creature', 4001408),
  ('creature', 4001409),
  ('creature', 4001410),
  ('creature', 4001411),
  ('creature', 4001412),
  ('creature', 4001413),
  ('creature', 4001414),
  ('creature', 4001415),
  ('creature', 4001416),
  ('creature', 4001450),
  ('creature', 4001451),
  ('creature', 4001452),
  ('creature', 4001453),
  ('creature', 4001454),
  ('creature', 4001455),
  ('creature', 4001456),
  ('creature', 4001457),
  ('creature', 4001458),
  ('creature', 4001459),
  ('creature', 4001460),
  ('creature', 4001461),
  ('creature', 4001462),
  ('creature', 4001463),
  ('gameobject', 4001500),
  ('gameobject', 4001501),
  ('gameobject', 4001502),
  ('gameobject', 4001503),
  ('gameobject', 4001504),
  ('gameobject', 4001505),
  ('gameobject', 4001506),
  ('gameobject', 4001507),
  ('gameobject', 4001508),
  ('gameobject', 4001509),
  ('gameobject', 4001510),
  ('gameobject', 4001511),
  ('gameobject', 4001512),
  ('gameobject', 4001513),
  ('gameobject', 4001514),
  ('gameobject', 4001515),
  ('gameobject', 4001516),
  ('gameobject', 4001517),
  ('quest', 900300),
  ('quest', 900301),
  ('quest', 900302),
  ('quest', 900303),
  ('quest', 900304),
  ('quest', 900305),
  ('quest', 900306),
  ('quest', 900307),
  ('quest', 900308),
  ('quest', 900309),
  ('quest', 900310),
  ('quest', 900311),
  ('item', 900300),
  ('item', 900301),
  ('item', 900302),
  ('item', 900303),
  ('item', 900304),
  ('item', 900305),
  ('item', 900306),
  ('item', 900307),
  ('item', 900308),
  ('item', 900309),
  ('item', 900310),
  ('item', 900311),
  ('item', 900312),
  ('item', 900313),
  ('item', 900314),
  ('outfit', 4001400),
  ('outfit', 4001401),
  ('outfit', 4001402),
  ('outfit', 4001403),
  ('outfit', 4001404),
  ('outfit', 4001405),
  ('outfit', 4001408),
  ('outfit', 4001409),
  ('outfit', 4001410),
  ('outfit', 4001411),
  ('outfit', 4001412),
  ('outfit_entry', 4001400),
  ('outfit_entry', 4001401),
  ('outfit_entry', 4001402),
  ('outfit_entry', 4001403),
  ('outfit_entry', 4001404),
  ('outfit_entry', 4001405),
  ('outfit_entry', 4001408),
  ('outfit_entry', 4001409),
  ('outfit_entry', 4001410),
  ('outfit_entry', 4001411),
  ('outfit_entry', 4001412),
  ('npc_text', 4001400),
  ('npc_text', 4001401),
  ('npc_text', 4001402),
  ('npc_text', 4001405),
  ('npc_text', 4001408),
  ('npc_text', 4001409),
  ('npc_text', 4001410),
  ('gossip_menu', 4001400),
  ('gossip_menu', 4001401),
  ('gossip_menu', 4001402),
  ('gossip_menu', 4001405),
  ('gossip_menu', 4001408),
  ('gossip_menu', 4001409),
  ('gossip_menu', 4001410),
  ('npc_text', 4001464),
  ('gossip_menu', 4001464);
DROP TEMPORARY TABLE IF EXISTS `bs_c03_collision_guard`;
CREATE TEMPORARY TABLE `bs_c03_collision_guard` (`id` TINYINT PRIMARY KEY);
INSERT INTO `bs_c03_collision_guard` VALUES (1);
-- Intentional duplicate-key error if the shared Chapter 2 handoff is absent or unowned.
INSERT INTO `bs_c03_collision_guard`
SELECT 1 WHERE (SELECT COUNT(*) FROM `mod_customnpcs_bs_content`
  WHERE `chapter` = 2 AND ((`kind` = 'creature' AND `entry` = 4001205)
  OR (`kind` = 'quest' AND `entry` = 900222))) <> 2
  OR NOT EXISTS (SELECT 1 FROM `quest_template` WHERE `ID` = 900222)
  OR NOT EXISTS (SELECT 1 FROM `creature_template` WHERE `entry` = 4001205);
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `creature_template` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'creature' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `gameobject_template` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'gameobject' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `quest_template` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'quest' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `item_template` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'item' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `mod_customnpcs_outfit` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'outfit' AND r.`entry` = t.`outfit_id`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `mod_customnpcs_outfit_entry` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'outfit_entry' AND r.`entry` = t.`creature_entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `npc_text` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'npc_text' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c03_collision_guard`
SELECT 1 FROM `gossip_menu` t INNER JOIN `bs_c03_ids` r ON r.`kind` = 'gossip_menu' AND r.`entry` = t.`MenuID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 3
WHERE o.`entry` IS NULL LIMIT 1;
DROP TEMPORARY TABLE `bs_c03_collision_guard`;
START TRANSACTION;
INSERT INTO `mod_customnpcs_bs_content` (`kind`, `entry`, `chapter`)
SELECT `kind`, `entry`, 3 FROM `bs_c03_ids` ON DUPLICATE KEY UPDATE `chapter` = VALUES(`chapter`);
INSERT INTO `creature_template` (`entry`, `name`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `unit_class`, `unit_flags`, `type`, `AIName`, `ScriptName`, `HealthModifier`, `DamageModifier`, `ExperienceModifier`, `lootid`, `flags_extra`) VALUES
  (4001400, 'Kang Bramblestaff', 35, 35, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c03_contact', 1, 1, 0, 0, 2),
  (4001401, 'Kor Bloodtusk', 35, 35, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c03_contact', 1, 1, 0, 0, 2),
  (4001402, 'Nala', 35, 35, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c03_contact', 1, 1, 0, 0, 2),
  (4001403, 'Chezin Dawnchaser', 35, 35, 0, 35, 0, 1, 33555202, 7, '', 'npc_bs_c03_corpse', 1, 1, 0, 0, 2),
  (4001404, 'Leza Farwalker', 35, 35, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c03_actor', 1, 1, 0, 0, 2),
  (4001405, 'Mei Barrelbottom', 35, 35, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c03_contact', 1, 1, 0, 0, 2),
  (4001406, 'Redhorn', 1, 1, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c03_actor', 1, 1, 0, 0, 2),
  (4001407, 'Cloudhoof', 1, 1, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c03_actor', 1, 1, 0, 0, 2),
  (4001408, 'Expedition Refugees: Group A', 35, 35, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c03_contact', 1, 1, 0, 0, 2),
  (4001409, 'Expedition Refugees: Group B', 35, 35, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c03_contact', 1, 1, 0, 0, 2),
  (4001410, 'Expedition Refugees: Group C', 35, 35, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c03_contact', 1, 1, 0, 0, 2),
  (4001411, 'Sunwalker Dezco', 35, 35, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c03_actor', 1, 1, 0, 0, 2),
  (4001412, 'Nala', 35, 35, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c03_actor', 1, 1, 0, 0, 2),
  (4001413, 'Dawnchaser Story Focus', 1, 1, 0, 35, 0, 1, 33555202, 10, '', 'npc_bs_c03_scene', 1, 1, 0, 0, 2),
  (4001414, 'Marsh Relic Raider', 31, 31, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c03_enemy', 1, 1, 1, 4001414, 0),
  (4001415, 'Marsh Raider Hexer', 32, 32, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c03_enemy', 1, 1, 1, 4001415, 0),
  (4001416, 'Marsh Skitterer', 30, 30, 0, 14, 0, 1, 0, 1, '', 'npc_bs_c03_enemy', 1, 1, 1, 4001416, 0),
  (4001450, 'Treated', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001451, 'Stew', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001452, 'Lookout A', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001453, 'Lookout B', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001454, 'Lookout C', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001455, 'Remedy', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001456, 'Agenda', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001457, 'Life', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001458, 'Vigil', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001459, 'Refugee A', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001460, 'Refugee B', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001461, 'Refugee C', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001462, 'Promise', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001463, 'Device', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `exp` = VALUES(`exp`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `AIName` = VALUES(`AIName`), `ScriptName` = VALUES(`ScriptName`), `HealthModifier` = VALUES(`HealthModifier`), `DamageModifier` = VALUES(`DamageModifier`), `ExperienceModifier` = VALUES(`ExperienceModifier`), `lootid` = VALUES(`lootid`), `flags_extra` = VALUES(`flags_extra`);
DELETE FROM `creature_template_model` WHERE `CreatureID` IN (4001400, 4001401, 4001402, 4001403, 4001404, 4001405, 4001406, 4001407, 4001408, 4001409, 4001410, 4001411, 4001412, 4001413, 4001414, 4001415, 4001416, 4001450, 4001451, 4001452, 4001453, 4001454, 4001455, 4001456, 4001457, 4001458, 4001459, 4001460, 4001461, 4001462, 4001463);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
  (4001400, 0, 53, 1, 1),
  (4001401, 0, 51, 1, 1),
  (4001402, 0, 60, 1, 1),
  (4001403, 0, 59, 1, 1),
  (4001404, 0, 60, 1, 1),
  (4001405, 0, 54, 1, 1),
  (4001406, 0, 23783, 1, 1),
  (4001407, 0, 23783, 1, 1),
  (4001408, 0, 59, 1, 1),
  (4001409, 0, 50, 1, 1),
  (4001410, 0, 52, 1, 1),
  (4001411, 0, 59, 1, 1),
  (4001412, 0, 60, 1, 1),
  (4001413, 0, 11686, 1, 1),
  (4001414, 0, 14402, 1, 1),
  (4001415, 0, 1122, 1, 1),
  (4001416, 0, 545, 1, 1),
  (4001450, 0, 11686, 1, 1),
  (4001451, 0, 11686, 1, 1),
  (4001452, 0, 11686, 1, 1),
  (4001453, 0, 11686, 1, 1),
  (4001454, 0, 11686, 1, 1),
  (4001455, 0, 11686, 1, 1),
  (4001456, 0, 11686, 1, 1),
  (4001457, 0, 11686, 1, 1),
  (4001458, 0, 11686, 1, 1),
  (4001459, 0, 11686, 1, 1),
  (4001460, 0, 11686, 1, 1),
  (4001461, 0, 11686, 1, 1),
  (4001462, 0, 11686, 1, 1),
  (4001463, 0, 11686, 1, 1);
INSERT INTO `mod_customnpcs_outfit` (`outfit_id`, `race`, `gender`, `class`, `skin`, `face`, `hair`, `hair_color`, `facial_hair`, `chest`, `shoulders`, `shirt`, `waist`, `legs`, `feet`, `hands`, `mainhand`, `ranged`) VALUES
  (4001400, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001401, 2, 0, 1, 0, 0, 0, 0, 0, 6085, 6597, 0, 6594, 6596, 6573, 0, 0, 0),
  (4001402, 6, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001403, 6, 0, 1, 0, 0, 0, 0, 0, 2317, 0, 0, 6382, 6568, 2315, 4248, 0, 0),
  (4001404, 6, 1, 1, 0, 0, 0, 0, 0, 2317, 0, 0, 6382, 6568, 2315, 4248, 0, 0),
  (4001405, 3, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6382, 10045, 2315, 0, 0, 0),
  (4001408, 6, 0, 1, 0, 0, 0, 0, 0, 2317, 0, 0, 6382, 6568, 2315, 4248, 0, 0),
  (4001409, 1, 1, 1, 0, 0, 0, 0, 0, 2317, 0, 0, 6382, 6568, 2315, 4248, 0, 0),
  (4001410, 2, 1, 1, 0, 0, 0, 0, 0, 2317, 0, 0, 6382, 6568, 2315, 4248, 0, 0),
  (4001411, 6, 0, 1, 0, 0, 0, 0, 0, 6085, 6597, 0, 6594, 6596, 6573, 0, 6631, 0),
  (4001412, 6, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0)
ON DUPLICATE KEY UPDATE
  `race` = VALUES(`race`), `gender` = VALUES(`gender`), `class` = VALUES(`class`), `skin` = VALUES(`skin`), `face` = VALUES(`face`), `hair` = VALUES(`hair`), `hair_color` = VALUES(`hair_color`), `facial_hair` = VALUES(`facial_hair`), `chest` = VALUES(`chest`), `shoulders` = VALUES(`shoulders`), `shirt` = VALUES(`shirt`), `waist` = VALUES(`waist`), `legs` = VALUES(`legs`), `feet` = VALUES(`feet`), `hands` = VALUES(`hands`), `mainhand` = VALUES(`mainhand`), `ranged` = VALUES(`ranged`);
INSERT INTO `mod_customnpcs_outfit_entry` (`creature_entry`, `outfit_id`) VALUES
  (4001400, 4001400),
  (4001401, 4001401),
  (4001402, 4001402),
  (4001403, 4001403),
  (4001404, 4001404),
  (4001405, 4001405),
  (4001408, 4001408),
  (4001409, 4001409),
  (4001410, 4001410),
  (4001411, 4001411),
  (4001412, 4001412)
ON DUPLICATE KEY UPDATE
  `outfit_id` = VALUES(`outfit_id`);
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `bonding`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `description`, `spellid_1`, `spelltrigger_1`, `ScriptName`) VALUES
  (900300, 12, 0, 'Raider Excavation Orders', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900301, 12, 0, 'Marsh Antidote', 2885, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 34665, 0, 'item_bs_c03_antidote'),
  (900302, 12, 0, 'Skitterer Meat', 25466, 1, 0, -1, -1, 1, 0, 8, 8, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900303, 12, 0, 'Relic Raider Insignia', 20984, 1, 0, -1, -1, 1, 0, 8, 8, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900304, 12, 0, 'Marsh Lotus Leaves', 24688, 1, 0, -1, -1, 1, 0, 12, 12, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900305, 12, 0, 'Ward-tainted Water Sample', 18084, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900306, 12, 0, 'Leza''s Memorial Totem', 7299, 1, 0, -1, -1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900307, 12, 0, 'Village Food Supplies', 6399, 1, 0, -1, -1, 1, 0, 3, 3, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900308, 12, 0, 'Village Introduction Letter', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900309, 4, 0, 'The Dawnchaser Promise: Signet of Might', 9846, 2, 11, -1, -1, 35, 30, 1, 1, 1, 4, 6, 7, 5, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900310, 4, 0, 'The Dawnchaser Promise: Signet of Precision', 9846, 2, 11, -1, -1, 35, 30, 1, 1, 1, 3, 6, 7, 5, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900311, 4, 0, 'The Dawnchaser Promise: Signet of Sorcery', 9846, 2, 11, -1, -1, 35, 30, 1, 1, 1, 5, 6, 45, 8, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900312, 4, 0, 'The Dawnchaser Promise: Signet of Restoration', 9846, 2, 11, -1, -1, 35, 30, 1, 1, 1, 6, 6, 43, 2, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900313, 4, 0, 'The Dawnchaser Promise: Signet of Guarding', 9846, 2, 11, -1, -1, 35, 30, 1, 1, 1, 7, 7, 12, 5, 0, 0, 'The Broken Seal: The Dawnchaser Promise', 0, 0, ''),
  (900314, 4, 0, 'The Dawnchaser Promise: Signet of Balance', 9846, 2, 11, -1, -1, 35, 30, 1, 1, 1, 5, 5, 6, 5, 7, 4, 'The Broken Seal: The Dawnchaser Promise', 0, 0, '')
ON DUPLICATE KEY UPDATE
  `class` = VALUES(`class`), `subclass` = VALUES(`subclass`), `name` = VALUES(`name`), `displayid` = VALUES(`displayid`), `Quality` = VALUES(`Quality`), `InventoryType` = VALUES(`InventoryType`), `AllowableClass` = VALUES(`AllowableClass`), `AllowableRace` = VALUES(`AllowableRace`), `ItemLevel` = VALUES(`ItemLevel`), `RequiredLevel` = VALUES(`RequiredLevel`), `maxcount` = VALUES(`maxcount`), `stackable` = VALUES(`stackable`), `bonding` = VALUES(`bonding`), `stat_type1` = VALUES(`stat_type1`), `stat_value1` = VALUES(`stat_value1`), `stat_type2` = VALUES(`stat_type2`), `stat_value2` = VALUES(`stat_value2`), `stat_type3` = VALUES(`stat_type3`), `stat_value3` = VALUES(`stat_value3`), `description` = VALUES(`description`), `spellid_1` = VALUES(`spellid_1`), `spelltrigger_1` = VALUES(`spelltrigger_1`), `ScriptName` = VALUES(`ScriptName`);
DELETE FROM `creature_loot_template` WHERE `Entry` IN (4001414, 4001415, 4001416);
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001416, 900302, 100, 1, 1, 0, 1, 1),
  (4001414, 900303, 100, 1, 1, 0, 1, 1),
  (4001415, 900303, 100, 1, 1, 0, 1, 1);
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `RewardXPDifficulty`, `RewardMoney`, `StartItem`, `Flags`, `AllowableRaces`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`, `RequiredNpcOrGo3`, `RequiredNpcOrGo4`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGoCount4`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`, `RequiredItemId1`, `RequiredItemId2`, `RequiredItemId3`, `RequiredItemId4`, `RequiredItemId5`, `RequiredItemId6`, `RequiredItemCount1`, `RequiredItemCount2`, `RequiredItemCount3`, `RequiredItemCount4`, `RequiredItemCount5`, `RequiredItemCount6`, `RewardChoiceItemID1`, `RewardChoiceItemID2`, `RewardChoiceItemID3`, `RewardChoiceItemID4`, `RewardChoiceItemID5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity1`, `RewardChoiceItemQuantity2`, `RewardChoiceItemQuantity3`, `RewardChoiceItemQuantity4`, `RewardChoiceItemQuantity5`, `RewardChoiceItemQuantity6`, `RewardItem1`, `RewardItem2`, `RewardItem3`, `RewardItem4`, `RewardAmount1`, `RewardAmount2`, `RewardAmount3`, `RewardAmount4`) VALUES
  (900300, 2, 30, 30, 15, 4, 1200, 0, 0, 0, 'Search Party', 'Find Chezin at the ruined scouting camp and recover his report.', 'Jarod trusts you, and that is enough for me. My brother-in-law Chezin went to the scouting camp southeast of us. The camp has fallen silent. Follow the marker and find him. If he has a report, bring it back. Do not promise Leza he is coming home until you know.', 'Find Chezin at the ruined scouting camp and recover his report.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900300, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900301, 2, 30, 30, 15, 4, 1200, 900301, 0, 0, 'Poisoned!', 'Obtain the supplied antidote and administer it to Leza while Nala monitors her.', 'Leza is ill, and the marsh fever has brought her into labor too soon. Kang has prepared an antidote. Ask Nala to prepare Leza inside the medical tent, then target your private patient with the antidote while Nala is beside her. Stay for her response. We need to know whether it helps.', 'Obtain the supplied antidote and administer it to Leza while Nala monitors her.', 4001450, 0, 0, 0, 1, 0, 0, 0, 'Treated', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900302, 2, 30, 30, 15, 5, 1200, 0, 0, 0, 'Skitterer Stew', 'Gather 8 skitterer meat and help prepare food for the weakened camp.', 'People who have not eaten cannot recover. Gather eight pieces of meat from the marsh skitterers south of camp, then use our cooking hearth to help prepare the stew. Keep the ingredients until you return them to me. Nobody here needs a cooking profession to lend a hand.', 'Gather 8 skitterer meat and help prepare food for the weakened camp.', 4001451, 0, 0, 0, 1, 0, 0, 0, 'Stew', '', '', '', 900302, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900303, 2, 31, 30, 15, 5, 1240, 0, 0, 0, 'Blind Them!', 'Disable 3 raider lookout posts and defeat 6 guards watching the expedition.', 'The relic raiders are watching us. Disable each of the three marked lookout posts to the southeast and defeat six Marsh Relic Raiders. Each post needs only one visit; striking the same marker again will not blind another lookout. Keep their attention away from the medical tent.', 'Disable 3 raider lookout posts and defeat 6 guards watching the expedition.', 4001414, 4001452, 4001453, 4001454, 6, 1, 1, 1, 'Npc Raider', 'Lookout A', 'Lookout B', 'Lookout C', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900304, 2, 31, 30, 15, 5, 1240, 0, 0, 0, 'Threat from the Marsh Ruins', 'Defeat 8 relic raiders before their next camp attack.', 'The watchers were only the edge of the force. Defeat relic raiders and hexers at their dig, and bring back eight insignia as proof that their next attack has been broken. This expedition has families in it, and I mean to keep them alive.', 'Defeat 8 relic raiders before their next camp attack.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900303, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900305, 2, 32, 30, 15, 5, 1280, 0, 0, 0, 'Herbal Remedies', 'Collect 12 quest lotus leaves and help Kang prepare a second treatment.', 'The antidote eased the fever, but Leza is still weak. Collect twelve quest lotus leaves among the southern marsh paths. Ask Kang to prepare the treatment when you have them, then return the leaves to me. These are camp supplies, not a test of your herbalism.', 'Collect 12 quest lotus leaves and help Kang prepare a second treatment.', 4001455, 0, 0, 0, 1, 0, 0, 0, 'Remedy', '', '', '', 900304, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900306, 2, 32, 30, 15, 5, 1280, 0, 0, 0, 'The Relic Raiders Agenda', 'Recover excavation orders and compare the raiders focus with the expedition ledger.', 'Chezin saw the raiders excavating stones marked with the same cuts described in Jarod''s ledger. Recover fresh orders from the raider chest, inspect the binding apparatus beside it, then ask me to compare the orders with the ledger. We must learn what is poisoning the water.', 'Recover excavation orders and compare the raiders focus with the expedition ledger.', 4001463, 4001456, 0, 0, 1, 1, 0, 0, 'Device', 'Agenda', '', '', 900300, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900307, 2, 33, 30, 15, 4, 1320, 0, 0, 0, 'The Pools of Youth', 'Collect one water sample from the tainted pool and bring it to Kang for testing.', 'The orders describe a pool that takes strength from one life and feeds it into the buried ward. Collect a sample at the pool focus south of camp and take it to Kang. A promise of youth means little until someone has tested what it costs.', 'Collect one water sample from the tainted pool and bring it to Kang for testing.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900305, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900308, 2, 33, 30, 15, 5, 1320, 0, 0, 0, 'Life', 'Stand by Dezco while Nala tends Leza; witness the birth, Leza''s death and the two surviving sons.', 'Kang has found the same draining mark in the water and in the stones the raiders unearthed. Leza has already been exposed. Nala cannot leave her now. Use the medical tent and stand nearby while we attend to her. Stay with us through the birth and what follows. Your presence is all I can ask.', 'Stand by Dezco while Nala tends Leza; witness the birth, Leza''s death and the two surviving sons.', 4001457, 0, 0, 0, 1, 0, 0, 0, 'Life', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900309, 2, 34, 30, 15, 4, 1360, 0, 0, 0, 'A Quiet Vigil', 'Attend the memorial and accept Leza''s keepsake without a combat objective.', 'Leza led us here because she believed the living could find something better. There must be room to mourn her before we speak of another march. Attend the memorial west of camp. Stay quietly for the vigil, then return to me for a totem in her memory.', 'Attend the memorial and accept Leza''s keepsake without a combat objective.', 4001458, 0, 0, 0, 1, 0, 0, 0, 'Vigil', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 900306, 0, 0, 0, 1, 0, 0, 0),
  (900310, 2, 34, 30, 15, 5, 1360, 900307, 0, 0, 'For the Living', 'Deliver food to 3 refugee groups and speak with Dezco about his sons and remaining expedition.', 'Redhorn and Cloudhoof breathe, and others still need to eat. Take these three food bundles to our three refugee groups. Give each group one bundle, then speak with me about the boys and the people who remain. We will carry our grief; we will not leave the living behind.', 'Deliver food to 3 refugee groups and speak with Dezco about his sons and remaining expedition.', 4001459, 4001460, 4001461, 4001462, 1, 1, 1, 1, 'Refugee A', 'Refugee B', 'Refugee C', 'Promise', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900311, 2, 35, 30, 15, 4, 1400, 900308, 0, 0, 'Leave a Place Better', 'Deliver the village introduction letter to Mei at the affected settlement.', 'The people at the wayside settlement southwest of here have been facing the same raiders, and hope is wearing thin there. Take my introduction to Mei Barrelbottom at the relief station on the Mudsprocket road. Tell her what our camp has learned and what you are willing to do.', 'Deliver the village introduction letter to Mei at the affected settlement.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900308, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 900309, 900310, 900311, 900312, 900313, 900314, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE
  `QuestType` = VALUES(`QuestType`), `QuestLevel` = VALUES(`QuestLevel`), `MinLevel` = VALUES(`MinLevel`), `QuestSortID` = VALUES(`QuestSortID`), `RewardXPDifficulty` = VALUES(`RewardXPDifficulty`), `RewardMoney` = VALUES(`RewardMoney`), `StartItem` = VALUES(`StartItem`), `Flags` = VALUES(`Flags`), `AllowableRaces` = VALUES(`AllowableRaces`), `LogTitle` = VALUES(`LogTitle`), `LogDescription` = VALUES(`LogDescription`), `QuestDescription` = VALUES(`QuestDescription`), `QuestCompletionLog` = VALUES(`QuestCompletionLog`), `RequiredNpcOrGo1` = VALUES(`RequiredNpcOrGo1`), `RequiredNpcOrGo2` = VALUES(`RequiredNpcOrGo2`), `RequiredNpcOrGo3` = VALUES(`RequiredNpcOrGo3`), `RequiredNpcOrGo4` = VALUES(`RequiredNpcOrGo4`), `RequiredNpcOrGoCount1` = VALUES(`RequiredNpcOrGoCount1`), `RequiredNpcOrGoCount2` = VALUES(`RequiredNpcOrGoCount2`), `RequiredNpcOrGoCount3` = VALUES(`RequiredNpcOrGoCount3`), `RequiredNpcOrGoCount4` = VALUES(`RequiredNpcOrGoCount4`), `ObjectiveText1` = VALUES(`ObjectiveText1`), `ObjectiveText2` = VALUES(`ObjectiveText2`), `ObjectiveText3` = VALUES(`ObjectiveText3`), `ObjectiveText4` = VALUES(`ObjectiveText4`), `RequiredItemId1` = VALUES(`RequiredItemId1`), `RequiredItemId2` = VALUES(`RequiredItemId2`), `RequiredItemId3` = VALUES(`RequiredItemId3`), `RequiredItemId4` = VALUES(`RequiredItemId4`), `RequiredItemId5` = VALUES(`RequiredItemId5`), `RequiredItemId6` = VALUES(`RequiredItemId6`), `RequiredItemCount1` = VALUES(`RequiredItemCount1`), `RequiredItemCount2` = VALUES(`RequiredItemCount2`), `RequiredItemCount3` = VALUES(`RequiredItemCount3`), `RequiredItemCount4` = VALUES(`RequiredItemCount4`), `RequiredItemCount5` = VALUES(`RequiredItemCount5`), `RequiredItemCount6` = VALUES(`RequiredItemCount6`), `RewardChoiceItemID1` = VALUES(`RewardChoiceItemID1`), `RewardChoiceItemID2` = VALUES(`RewardChoiceItemID2`), `RewardChoiceItemID3` = VALUES(`RewardChoiceItemID3`), `RewardChoiceItemID4` = VALUES(`RewardChoiceItemID4`), `RewardChoiceItemID5` = VALUES(`RewardChoiceItemID5`), `RewardChoiceItemID6` = VALUES(`RewardChoiceItemID6`), `RewardChoiceItemQuantity1` = VALUES(`RewardChoiceItemQuantity1`), `RewardChoiceItemQuantity2` = VALUES(`RewardChoiceItemQuantity2`), `RewardChoiceItemQuantity3` = VALUES(`RewardChoiceItemQuantity3`), `RewardChoiceItemQuantity4` = VALUES(`RewardChoiceItemQuantity4`), `RewardChoiceItemQuantity5` = VALUES(`RewardChoiceItemQuantity5`), `RewardChoiceItemQuantity6` = VALUES(`RewardChoiceItemQuantity6`), `RewardItem1` = VALUES(`RewardItem1`), `RewardItem2` = VALUES(`RewardItem2`), `RewardItem3` = VALUES(`RewardItem3`), `RewardItem4` = VALUES(`RewardItem4`), `RewardAmount1` = VALUES(`RewardAmount1`), `RewardAmount2` = VALUES(`RewardAmount2`), `RewardAmount3` = VALUES(`RewardAmount3`), `RewardAmount4` = VALUES(`RewardAmount4`);
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`, `ExclusiveGroup`, `ProvidedItemCount`, `SpecialFlags`) VALUES
  (900300, 900222, 0, 0, 0, 256),
  (900301, 900300, 0, 0, 1, 256),
  (900302, 900301, 0, -900304, 0, 256),
  (900303, 900301, 0, -900304, 0, 256),
  (900304, 900302, 0, -900307, 0, 256),
  (900305, 900302, 0, -900307, 0, 256),
  (900306, 900302, 0, -900307, 0, 256),
  (900307, 900304, 0, 0, 0, 256),
  (900308, 900307, 0, 0, 0, 256),
  (900309, 900308, 0, 0, 0, 256),
  (900310, 900309, 0, 0, 3, 256),
  (900311, 900310, 0, 0, 1, 256)
ON DUPLICATE KEY UPDATE
  `PrevQuestID` = VALUES(`PrevQuestID`), `NextQuestID` = VALUES(`NextQuestID`), `ExclusiveGroup` = VALUES(`ExclusiveGroup`), `ProvidedItemCount` = VALUES(`ProvidedItemCount`), `SpecialFlags` = VALUES(`SpecialFlags`);
DELETE FROM `creature_queststarter` WHERE `quest` IN (900300, 900301, 900302, 900303, 900304, 900305, 900306, 900307, 900308, 900309, 900310, 900311);
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
  (4001205, 900300),
  (4001205, 900301),
  (4001400, 900302),
  (4001401, 900303),
  (4001401, 900304),
  (4001205, 900305),
  (4001205, 900306),
  (4001205, 900307),
  (4001205, 900308),
  (4001205, 900309),
  (4001205, 900310),
  (4001400, 900311);
DELETE FROM `creature_questender` WHERE `quest` IN (900300, 900301, 900302, 900303, 900304, 900305, 900306, 900307, 900308, 900309, 900310, 900311);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
  (4001205, 900300),
  (4001205, 900301),
  (4001400, 900302),
  (4001401, 900303),
  (4001401, 900304),
  (4001205, 900305),
  (4001205, 900306),
  (4001400, 900307),
  (4001205, 900308),
  (4001205, 900309),
  (4001205, 900310),
  (4001405, 900311);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) VALUES
  (900300, 'Chezin is gone. I will tell Leza myself. These orders give us something we can still act on.'),
  (900301, 'The fever has eased, but this is not a cure. We will keep looking, and Nala will stay with her.'),
  (900302, 'Hot food will do more for this camp than another empty assurance. Thank you.'),
  (900303, 'Their lookout line is broken. Now we can prepare without their eyes on every movement.'),
  (900304, 'They will have to regroup before they try us again. I will keep the watch.'),
  (900305, 'Kang has prepared what he can from these leaves. We have bought time, not certainty.'),
  (900306, 'The cuts match Jarod''s ledger. Someone is buying relics that should have stayed buried.'),
  (900307, 'This water drains life. I will not give it to Leza as medicine. I can explain the mark, but I cannot undo what she has already suffered.'),
  (900308, 'Leza is gone. Redhorn and Cloudhoof are here. I must be here for them, too.'),
  (900309, 'Keep this totem. Let it remind you that the person who dies is more than the moment of their death.'),
  (900310, 'We will move when the children and the wounded can move. The expedition still has a purpose.'),
  (900311, 'Kang speaks well of you. There is work to do here, and people who have forgotten that help can arrive.')
ON DUPLICATE KEY UPDATE
  `RewardText` = VALUES(`RewardText`);
INSERT INTO `quest_request_items` (`ID`, `CompletionText`) VALUES
  (900300, 'Find Chezin at the ruined scouting camp and recover his report.'),
  (900301, 'Obtain the supplied antidote and administer it to Leza while Nala monitors her.'),
  (900302, 'Gather 8 skitterer meat and help prepare food for the weakened camp.'),
  (900303, 'Disable 3 raider lookout posts and defeat 6 guards watching the expedition.'),
  (900304, 'Defeat 8 relic raiders before their next camp attack.'),
  (900305, 'Collect 12 quest lotus leaves and help Kang prepare a second treatment.'),
  (900306, 'Recover excavation orders and compare the raiders focus with the expedition ledger.'),
  (900307, 'Collect one water sample from the tainted pool and bring it to Kang for testing.'),
  (900308, 'Stand by Dezco while Nala tends Leza; witness the birth, Leza''s death and the two surviving sons.'),
  (900309, 'Attend the memorial and accept Leza''s keepsake without a combat objective.'),
  (900310, 'Deliver food to 3 refugee groups and speak with Dezco about his sons and remaining expedition.'),
  (900311, 'Deliver the village introduction letter to Mei at the affected settlement.')
ON DUPLICATE KEY UPDATE
  `CompletionText` = VALUES(`CompletionText`);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 19 AND `SourceEntry` IN (900300, 900301, 900302, 900303, 900304, 900305, 900306, 900307, 900308, 900309, 900310, 900311);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceEntry`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionValue1`, `Comment`) VALUES
  (19, 900300, 0, 8, 900222, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900301, 0, 8, 900300, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900302, 0, 8, 900301, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900303, 0, 8, 900301, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900304, 0, 8, 900302, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900304, 0, 8, 900303, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900305, 0, 8, 900302, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900305, 0, 8, 900303, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900306, 0, 8, 900302, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900306, 0, 8, 900303, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900307, 0, 8, 900304, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900307, 0, 8, 900305, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900307, 0, 8, 900306, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900308, 0, 8, 900307, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900309, 0, 8, 900308, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900310, 0, 8, 900309, 'Broken Seal C03: every listed predecessor must be rewarded'),
  (19, 900311, 0, 8, 900310, 'Broken Seal C03: every listed predecessor must be rewarded');
DELETE FROM `quest_poi_points` WHERE `QuestID` IN (900300, 900301, 900302, 900303, 900304, 900305, 900306, 900307, 900308, 900309, 900310, 900311);
DELETE FROM `quest_poi` WHERE `QuestID` IN (900300, 900301, 900302, 900303, 900304, 900305, 900306, 900307, 900308, 900309, 900310, 900311);
INSERT INTO `quest_poi` (`QuestID`, `id`, `ObjectiveIndex`, `MapID`, `WorldMapAreaId`, `Floor`, `Priority`, `Flags`) VALUES
  (900300, 0, -1, 1, 141, 0, 0, 0),
  (900301, 0, -1, 1, 141, 0, 0, 0),
  (900302, 0, -1, 1, 141, 0, 0, 0),
  (900303, 0, -1, 1, 141, 0, 0, 0),
  (900304, 0, -1, 1, 141, 0, 0, 0),
  (900305, 0, -1, 1, 141, 0, 0, 0),
  (900306, 0, -1, 1, 141, 0, 0, 0),
  (900307, 0, -1, 1, 141, 0, 0, 0),
  (900308, 0, -1, 1, 141, 0, 0, 0),
  (900309, 0, -1, 1, 141, 0, 0, 0),
  (900310, 0, -1, 1, 141, 0, 0, 0),
  (900311, 0, -1, 1, 141, 0, 0, 0);
INSERT INTO `quest_poi_points` (`QuestID`, `Idx1`, `Idx2`, `X`, `Y`) VALUES
  (900300, 0, 0, -3970, -3350),
  (900301, 0, 0, -3970, -3350),
  (900302, 0, 0, -3955, -3348),
  (900303, 0, 0, -3970, -3328),
  (900304, 0, 0, -3970, -3328),
  (900305, 0, 0, -3970, -3350),
  (900306, 0, 0, -3970, -3350),
  (900307, 0, 0, -3955, -3348),
  (900308, 0, 0, -3970, -3350),
  (900309, 0, 0, -3970, -3350),
  (900310, 0, 0, -3970, -3350),
  (900311, 0, 0, -4535, -3235);
INSERT INTO `npc_text` (`ID`, `text0_0`, `Probability0`) VALUES
  (4001400, 'A meal, a poultice and a careful test. We start with what we can do.', 1),
  (4001401, 'Stay alert. The people at this camp have enough to fear already.', 1),
  (4001402, 'Give Leza privacy. I will tell you when your help is needed.', 1),
  (4001405, 'We still have homes here. Some days it is harder to remember why we keep them.', 1),
  (4001408, 'The expedition still has people who need our help.', 1),
  (4001409, 'The expedition still has people who need our help.', 1),
  (4001410, 'The expedition still has people who need our help.', 1),
  (4001464, 'Jarod sent you to follow the buyers. My people need you here as well.', 1)
ON DUPLICATE KEY UPDATE
  `text0_0` = VALUES(`text0_0`), `Probability0` = VALUES(`Probability0`);
DELETE FROM `gossip_menu` WHERE `MenuID` IN (4001400, 4001401, 4001402, 4001405, 4001408, 4001409, 4001410, 4001464);
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
  (4001400, 4001400),
  (4001401, 4001401),
  (4001402, 4001402),
  (4001405, 4001405),
  (4001408, 4001408),
  (4001409, 4001409),
  (4001410, 4001410),
  (4001464, 4001464);
UPDATE `creature_template` SET `gossip_menu_id` = `entry` WHERE `entry` IN (4001400, 4001401, 4001402, 4001405, 4001408, 4001409, 4001410, 4001464);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data3`, `Data5`, `Data18`, `ScriptName`) VALUES
  (4001500, 10, 22, 'Lost Scouting Camp Marker', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001501, 10, 8698, 'Dawnchaser Medical Tent', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001502, 10, 192, 'Dawnchaser Cooking Hearth', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001503, 10, 22, 'Lookout A', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001504, 10, 22, 'Lookout B', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001505, 10, 22, 'Lookout C', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001506, 10, 269, 'Marsh Lotus Leaves', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001507, 10, 259, 'Raider Excavation Orders', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001508, 10, 235, 'Raider Relic Binding Apparatus', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001509, 10, 235, 'Ward-tainted Pool Focus', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001510, 10, 192, 'Leza''s Memorial', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001511, 10, 335, 'Supply A', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001512, 10, 335, 'Supply B', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001513, 10, 335, 'Supply C', 1, 0, 0, 1, 'go_bs_c03_interaction'),
  (4001514, 5, 5993, 'Cot A', 0.8, 0, 0, 1, ''),
  (4001515, 5, 5993, 'Cot B', 0.8, 0, 0, 1, ''),
  (4001516, 5, 8457, 'Ruined Tent', 1, 0, 0, 1, ''),
  (4001517, 5, 22, 'Village Sign', 1, 0, 0, 1, '')
ON DUPLICATE KEY UPDATE
  `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `size` = VALUES(`size`), `Data3` = VALUES(`Data3`), `Data5` = VALUES(`Data5`), `Data18` = VALUES(`Data18`), `ScriptName` = VALUES(`ScriptName`);
DROP TEMPORARY TABLE IF EXISTS `bs_c03_creature_spawns`;
CREATE TEMPORARY TABLE `bs_c03_creature_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_c03_gameobject_spawns`;
CREATE TEMPORARY TABLE `bs_c03_gameobject_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c03_creature_spawns` (`spawn_key`, `entry`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C03:NPC_KANG:kang', 4001400, 15, -3955.0, -3348.0, 39.26710815177746, 3.14),
  ('BS-C03:NPC_KOR:kor', 4001401, 15, -3970.0, -3328.0, 37.18366264345962, 3.14),
  ('BS-C03:NPC_NALA:nala', 4001402, 15, -3982.0, -3358.0, 40.26248685667625, 3.14),
  ('BS-C03:NPC_CHEZIN:chezin', 4001403, 15, -3785.0, -3488.0, 30.904776469037483, 3.14),
  ('BS-C03:NPC_MEI:mei', 4001405, 15, -4535.0, -3235.0, 31.005721232444824, 3.14),
  ('BS-C03:NPC_REFUGEE_A:refugee_a', 4001408, 15, -3952.0, -3320.0, 37.45147193352007, 3.14),
  ('BS-C03:NPC_REFUGEE_B:refugee_b', 4001409, 15, -3917.0, -3360.0, 34.7054172891271, 3.14),
  ('BS-C03:NPC_REFUGEE_C:refugee_c', 4001410, 15, -3965.0, -3390.0, 34.795068190896316, 3.14),
  ('BS-C03:NPC_RAIDER:raider_0', 4001414, 15, -3817.0, -3510.0, 31.64495918332671, 3.14),
  ('BS-C03:NPC_RAIDER:raider_1', 4001414, 15, -3807.0, -3520.0, 31.190844671336155, 3.14),
  ('BS-C03:NPC_RAIDER:raider_2', 4001414, 15, -3877.0, -3554.0, 39.87576238084944, 3.14),
  ('BS-C03:NPC_RAIDER:raider_3', 4001414, 15, -3898.0, -3550.0, 37.555951501783724, 3.14),
  ('BS-C03:NPC_RAIDER:raider_4', 4001414, 15, -3986.0, -3592.0, 35.14438154908573, 3.14),
  ('BS-C03:NPC_RAIDER:raider_5', 4001414, 15, -4007.0, -3586.0, 30.907599275429448, 3.14),
  ('BS-C03:NPC_RAIDER:raider_6', 4001414, 15, -3913.27, -3606.58, 30.739638721880294, 3.14),
  ('BS-C03:NPC_RAIDER:raider_7', 4001414, 15, -3888.23, -3596.15, 30.84089242987682, 3.14),
  ('BS-C03:NPC_HEXER:hexer_0', 4001415, 15, -3904.8, -3586.93, 30.731849205504968, 3.14),
  ('BS-C03:NPC_HEXER:hexer_1', 4001415, 15, -3860.0, -3615.0, 33.65433282262704, 3.14),
  ('BS-C03:NPC_HEXER:hexer_2', 4001415, 15, -4003.72, -3607.27, 30.854969300844946, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_0', 4001416, 15, -3925.0, -3460.0, 30.728261740164694, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_1', 4001416, 15, -3958.4, -3466.67, 30.358569149087955, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_2', 4001416, 15, -3930.13, -3494.93, 30.86725958548896, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_3', 4001416, 15, -3966.92, -3498.05, 30.695467876224445, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_4', 4001416, 15, -4005.0, -3480.0, 30.58926532410932, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_5', 4001416, 15, -4016.0, -3458.0, 32.2797333044642, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_6', 4001416, 15, -4004.0, -3428.0, 44.80791978377301, 3.14),
  ('BS-C03:NPC_SKITTERER:skitterer_7', 4001416, 15, -3941.74, -3439.96, 30.832398283854484, 3.14);
INSERT INTO `bs_c03_gameobject_spawns` (`spawn_key`, `entry`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C03:GO_TRACK:track', 4001500, 15, -3780.0, -3484.0, 30.66348012003404, 3.14),
  ('BS-C03:GO_TENT:tent', 4001501, 15, -3986.0, -3367.0, 40.62909437048796, 3.14),
  ('BS-C03:GO_HEARTH:hearth', 4001502, 15, -3947.0, -3357.0, 38.161925851368146, 3.14),
  ('BS-C03:GO_LOOKOUT_A:lookout_a', 4001503, 15, -3813.92, -3509.84, 30.14540867615935, 3.14),
  ('BS-C03:GO_LOOKOUT_B:lookout_b', 4001504, 15, -3890.0, -3560.0, 37.41813423270267, 3.14),
  ('BS-C03:GO_LOOKOUT_C:lookout_c', 4001505, 15, -3999.63, -3594.61, 30.769223162146066, 3.14),
  ('BS-C03:GO_HERB:herb_0', 4001506, 15, -3865.42, -3471.61, 30.75097425479255, 3.14),
  ('BS-C03:GO_HERB:herb_1', 4001506, 15, -3869.33, -3490.67, 30.859048434742107, 3.14),
  ('BS-C03:GO_HERB:herb_2', 4001506, 15, -3898.0, -3472.0, 31.896224684021448, 3.14),
  ('BS-C03:GO_HERB:herb_3', 4001506, 15, -3920.0, -3520.0, 36.20807931503754, 3.14),
  ('BS-C03:GO_HERB:herb_4', 4001506, 15, -3939.47, -3548.0, 41.12239014984691, 3.14),
  ('BS-C03:GO_HERB:herb_5', 4001506, 15, -3957.0, -3558.0, 39.25788936634268, 3.14),
  ('BS-C03:GO_HERB:herb_6', 4001506, 15, -3975.0, -3540.0, 40.9578977176704, 3.14),
  ('BS-C03:GO_HERB:herb_7', 4001506, 15, -4002.54, -3530.12, 30.73718180836647, 3.14),
  ('BS-C03:GO_HERB:herb_8', 4001506, 15, -4020.98, -3554.98, 30.920595618990035, 3.14),
  ('BS-C03:GO_HERB:herb_9', 4001506, 15, -4018.0, -3565.0, 31.940067512427504, 3.14),
  ('BS-C03:GO_HERB:herb_10', 4001506, 15, -4025.0, -3505.0, 35.66227719286653, 3.14),
  ('BS-C03:GO_HERB:herb_11', 4001506, 15, -3870.0, -3536.0, 38.85394219834596, 3.14),
  ('BS-C03:GO_ORDERS:orders', 4001507, 15, -3940.0, -3620.0, 35.38285509169608, 3.14),
  ('BS-C03:GO_DEVICE:device', 4001508, 15, -3946.0, -3620.0, 35.839435092815705, 3.14),
  ('BS-C03:GO_POOL:pool', 4001509, 15, -4010.0, -3660.0, 43.261164807370186, 3.14),
  ('BS-C03:GO_MEMORIAL:memorial', 4001510, 15, -4010.0, -3340.0, 37.10976943307338, 3.14),
  ('BS-C03:GO_SUPPLY_A:supply_a', 4001511, 15, -3950.0, -3320.0, 37.802428951127986, 3.14),
  ('BS-C03:GO_SUPPLY_B:supply_b', 4001512, 15, -3915.0, -3360.0, 34.460440572295504, 3.14),
  ('BS-C03:GO_SUPPLY_C:supply_c', 4001513, 15, -3963.0, -3390.0, 34.49506461526585, 3.14),
  ('BS-C03:GO_COT_A:cot_a', 4001514, 15, -3990.0, -3358.0, 40.03269612360333, 3.14),
  ('BS-C03:GO_COT_B:cot_b', 4001515, 15, -3993.0, -3358.0, 39.584477346483204, 3.14),
  ('BS-C03:GO_RUINED_TENT:ruined_tent', 4001516, 15, -3792.0, -3486.94, 31.23072556590791, 3.14),
  ('BS-C03:GO_VILLAGE_SIGN:village_sign', 4001517, 15, -4533.0, -3233.0, 30.085449329220566, 3.14);
SET @BS_C03_ENTRY_COLUMN := (
  SELECT `COLUMN_NAME` FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'creature' AND `COLUMN_NAME` IN ('id1', 'id')
  ORDER BY `COLUMN_NAME` DESC LIMIT 1
);
SET @BS_C03_INSERT := CONCAT(
  'INSERT INTO `creature` (`', @BS_C03_ENTRY_COLUMN, '`, `map`, `zoneId`, `spawnMask`, `phaseMask`, ',
  '`position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `curhealth`, `curmana`, `Comment`) ',
  'SELECT s.`entry`, 1, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, 60, 0, 0, s.`spawn_key` ',
  'FROM `bs_c03_creature_spawns` s LEFT JOIN `creature` c ON c.`Comment` = s.`spawn_key` WHERE c.`guid` IS NULL'
);
PREPARE bs_c03_stmt FROM @BS_C03_INSERT;
EXECUTE bs_c03_stmt;
DEALLOCATE PREPARE bs_c03_stmt;
SET @BS_C03_UPDATE := CONCAT(
  'UPDATE `creature` c INNER JOIN `bs_c03_creature_spawns` s ON c.`Comment` = s.`spawn_key` ',
  'SET c.`', @BS_C03_ENTRY_COLUMN, '` = s.`entry`, c.`zoneId` = s.`zone`, c.`position_x` = s.`x`, ',
  'c.`position_y` = s.`y`, c.`position_z` = s.`z`, c.`orientation` = s.`o`'
);
PREPARE bs_c03_stmt FROM @BS_C03_UPDATE;
EXECUTE bs_c03_stmt;
DEALLOCATE PREPARE bs_c03_stmt;
INSERT INTO `gameobject`
  (`id`, `map`, `zoneId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`,
   `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`)
SELECT s.`entry`, 1, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, SIN(s.`o` / 2), COS(s.`o` / 2), 60, 100, 1, s.`spawn_key`
FROM `bs_c03_gameobject_spawns` s LEFT JOIN `gameobject` g ON g.`Comment` = s.`spawn_key` WHERE g.`guid` IS NULL;
UPDATE `gameobject` g INNER JOIN `bs_c03_gameobject_spawns` s ON g.`Comment` = s.`spawn_key`
SET g.`id` = s.`entry`, g.`position_x` = s.`x`, g.`position_y` = s.`y`, g.`position_z` = s.`z`, g.`orientation` = s.`o`,
  g.`rotation2` = SIN(s.`o` / 2), g.`rotation3` = COS(s.`o` / 2);
DROP TEMPORARY TABLE `bs_c03_creature_spawns`;
DROP TEMPORARY TABLE `bs_c03_gameobject_spawns`;
DROP TEMPORARY TABLE `bs_c03_ids`;
COMMIT;
