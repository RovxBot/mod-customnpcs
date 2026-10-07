-- The Broken Seal, Chapter 2: Inside the Twilight (levels 25-30).
-- Generated from data/quests/broken_seal_chapter2.json. Native 3.3.5a assets only.
-- Requires Chapter 1, custom_npc_appearances.sql and the rebuilt module.
-- Reapplication preserves GUIDs. Occupied IDs and missing Chapter 1 reject before content DML.
-- See docs/broken-seal/chapter2-implementation.md.
CREATE TABLE IF NOT EXISTS `mod_customnpcs_bs_content` (
  `kind` VARCHAR(16) NOT NULL,
  `entry` INT UNSIGNED NOT NULL,
  `chapter` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_c02_ids`;
CREATE TEMPORARY TABLE `bs_c02_ids` (
  `kind` VARCHAR(16) NOT NULL, `entry` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c02_ids` (`kind`, `entry`) VALUES
  ('creature', 4001200),
  ('creature', 4001201),
  ('creature', 4001202),
  ('creature', 4001203),
  ('creature', 4001204),
  ('creature', 4001205),
  ('creature', 4001206),
  ('creature', 4001207),
  ('creature', 4001208),
  ('creature', 4001209),
  ('creature', 4001210),
  ('creature', 4001211),
  ('creature', 4001212),
  ('creature', 4001213),
  ('creature', 4001214),
  ('creature', 4001215),
  ('creature', 4001216),
  ('creature', 4001217),
  ('creature', 4001218),
  ('creature', 4001219),
  ('creature', 4001220),
  ('creature', 4001221),
  ('creature', 4001222),
  ('creature', 4001223),
  ('creature', 4001224),
  ('creature', 4001225),
  ('creature', 4001226),
  ('creature', 4001227),
  ('creature', 4001228),
  ('creature', 4001229),
  ('creature', 4001250),
  ('creature', 4001251),
  ('creature', 4001252),
  ('creature', 4001253),
  ('creature', 4001254),
  ('creature', 4001255),
  ('creature', 4001256),
  ('creature', 4001257),
  ('creature', 4001258),
  ('creature', 4001259),
  ('creature', 4001260),
  ('creature', 4001261),
  ('creature', 4001262),
  ('creature', 4001263),
  ('creature', 4001264),
  ('creature', 4001265),
  ('creature', 4001266),
  ('creature', 4001267),
  ('creature', 4001268),
  ('creature', 4001269),
  ('creature', 4001270),
  ('creature', 4001271),
  ('creature', 4001272),
  ('creature', 4001273),
  ('creature', 4001274),
  ('gameobject', 4001300),
  ('gameobject', 4001301),
  ('gameobject', 4001302),
  ('gameobject', 4001303),
  ('gameobject', 4001304),
  ('gameobject', 4001305),
  ('gameobject', 4001306),
  ('gameobject', 4001307),
  ('gameobject', 4001308),
  ('gameobject', 4001309),
  ('gameobject', 4001310),
  ('gameobject', 4001311),
  ('gameobject', 4001312),
  ('gameobject', 4001313),
  ('gameobject', 4001314),
  ('gameobject', 4001315),
  ('gameobject', 4001316),
  ('gameobject', 4001317),
  ('gameobject', 4001318),
  ('gameobject', 4001319),
  ('gameobject', 4001320),
  ('gameobject', 4001321),
  ('quest', 900200),
  ('quest', 900201),
  ('quest', 900202),
  ('quest', 900203),
  ('quest', 900204),
  ('quest', 900205),
  ('quest', 900206),
  ('quest', 900207),
  ('quest', 900208),
  ('quest', 900209),
  ('quest', 900210),
  ('quest', 900211),
  ('quest', 900212),
  ('quest', 900213),
  ('quest', 900214),
  ('quest', 900215),
  ('quest', 900216),
  ('quest', 900217),
  ('quest', 900218),
  ('quest', 900219),
  ('quest', 900220),
  ('quest', 900221),
  ('quest', 900222),
  ('item', 900200),
  ('item', 900201),
  ('item', 900202),
  ('item', 900203),
  ('item', 900204),
  ('item', 900205),
  ('item', 900206),
  ('item', 900207),
  ('item', 900208),
  ('item', 900209),
  ('item', 900210),
  ('item', 900211),
  ('item', 900212),
  ('item', 900213),
  ('item', 900214),
  ('item', 900215),
  ('item', 900216),
  ('item', 900217),
  ('item', 900218),
  ('item', 900219),
  ('item', 900220),
  ('item', 900221),
  ('outfit', 4001200),
  ('outfit', 4001201),
  ('outfit', 4001202),
  ('outfit', 4001203),
  ('outfit', 4001204),
  ('outfit', 4001205),
  ('outfit', 4001206),
  ('outfit', 4001207),
  ('outfit', 4001208),
  ('outfit', 4001209),
  ('outfit', 4001212),
  ('outfit', 4001215),
  ('outfit', 4001219),
  ('outfit', 4001220),
  ('outfit', 4001225),
  ('outfit', 4001227),
  ('outfit', 4001228),
  ('outfit_entry', 4001200),
  ('outfit_entry', 4001201),
  ('outfit_entry', 4001202),
  ('outfit_entry', 4001203),
  ('outfit_entry', 4001204),
  ('outfit_entry', 4001205),
  ('outfit_entry', 4001206),
  ('outfit_entry', 4001207),
  ('outfit_entry', 4001208),
  ('outfit_entry', 4001209),
  ('outfit_entry', 4001212),
  ('outfit_entry', 4001215),
  ('outfit_entry', 4001219),
  ('outfit_entry', 4001220),
  ('outfit_entry', 4001225),
  ('outfit_entry', 4001227),
  ('outfit_entry', 4001228),
  ('npc_text', 4001200),
  ('npc_text', 4001201),
  ('npc_text', 4001202),
  ('npc_text', 4001203),
  ('npc_text', 4001204),
  ('npc_text', 4001205),
  ('npc_text', 4001206),
  ('npc_text', 4001207),
  ('npc_text', 4001208),
  ('npc_text', 4001209),
  ('npc_text', 4001210),
  ('npc_text', 4001211),
  ('npc_text', 4001212),
  ('gossip_menu', 4001200),
  ('gossip_menu', 4001201),
  ('gossip_menu', 4001202),
  ('gossip_menu', 4001203),
  ('gossip_menu', 4001204),
  ('gossip_menu', 4001205),
  ('gossip_menu', 4001206),
  ('gossip_menu', 4001207),
  ('gossip_menu', 4001208),
  ('gossip_menu', 4001209),
  ('gossip_menu', 4001210),
  ('gossip_menu', 4001211),
  ('gossip_menu', 4001212),
  ('npc_text', 4001002),
  ('gossip_menu', 4001002);
DROP TEMPORARY TABLE IF EXISTS `bs_c02_collision_guard`;
CREATE TEMPORARY TABLE `bs_c02_collision_guard` (`id` TINYINT PRIMARY KEY);
INSERT INTO `bs_c02_collision_guard` VALUES (1);
-- Intentional duplicate-key error if the shared Chapter 1 entries are absent or unowned.
INSERT INTO `bs_c02_collision_guard`
SELECT 1 WHERE (SELECT COUNT(*) FROM `mod_customnpcs_bs_content`
  WHERE `chapter` = 1 AND ((`kind` = 'creature' AND `entry` IN (4001001, 4001002))
  OR (`kind` = 'quest' AND `entry` = 900108))) <> 3
  OR NOT EXISTS (SELECT 1 FROM `quest_template` WHERE `ID` = 900108)
  OR (SELECT COUNT(*) FROM `creature_template` WHERE `entry` IN (4001001, 4001002)) <> 2;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `creature_template` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'creature' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `gameobject_template` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'gameobject' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `quest_template` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'quest' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `item_template` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'item' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `mod_customnpcs_outfit` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'outfit' AND r.`entry` = t.`outfit_id`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `mod_customnpcs_outfit_entry` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'outfit_entry' AND r.`entry` = t.`creature_entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `npc_text` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'npc_text' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c02_collision_guard`
SELECT 1 FROM `gossip_menu` t INNER JOIN `bs_c02_ids` r ON r.`kind` = 'gossip_menu' AND r.`entry` = t.`MenuID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 2
WHERE o.`entry` IS NULL LIMIT 1;
DROP TEMPORARY TABLE `bs_c02_collision_guard`;
START TRANSACTION;
INSERT INTO `mod_customnpcs_bs_content` (`kind`, `entry`, `chapter`)
SELECT `kind`, `entry`, 2 FROM `bs_c02_ids` ON DUPLICATE KEY UPDATE `chapter` = VALUES(`chapter`);
INSERT INTO `creature_template` (`entry`, `name`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `unit_class`, `unit_flags`, `type`, `AIName`, `ScriptName`, `HealthModifier`, `DamageModifier`, `ExperienceModifier`, `lootid`, `flags_extra`) VALUES
  (4001200, 'Condenna the Pitiless', 30, 30, 0, 14, 3, 1, 770, 7, '', 'npc_bs_c02_contact', 1, 1, 0, 0, 0),
  (4001201, 'Instructor Cargall', 30, 30, 0, 14, 3, 1, 770, 7, '', 'npc_bs_c02_contact', 1, 1, 0, 0, 0),
  (4001202, 'Instructor Mylva', 30, 30, 0, 14, 3, 1, 770, 7, '', 'npc_bs_c02_contact', 1, 1, 0, 0, 0),
  (4001203, 'Instructor Devoran', 30, 30, 0, 14, 3, 1, 770, 7, '', 'npc_bs_c02_contact', 1, 1, 0, 0, 0),
  (4001204, 'Commander Jarod Shadowsong', 30, 30, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c02_contact', 1, 1, 0, 0, 2),
  (4001205, 'Sunwalker Dezco', 30, 30, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c02_contact', 1, 1, 0, 0, 2),
  (4001206, 'Isolated Twilight Recruit', 27, 27, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c02_actor', 1, 1, 0, 0, 2),
  (4001207, 'Immolated Supplicant', 27, 27, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c02_actor', 1, 1, 0, 0, 2),
  (4001208, 'Immolated Supplicant', 27, 27, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c02_actor', 1, 1, 0, 0, 2),
  (4001209, 'Immolated Supplicant', 27, 27, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c02_actor', 1, 1, 0, 0, 2),
  (4001210, 'Training Core Hound', 27, 27, 0, 35, 1, 1, 770, 1, '', 'npc_bs_c02_actor', 1, 1, 0, 0, 2),
  (4001211, 'Orb of Ascension', 27, 27, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c02_scene', 1, 1, 0, 0, 2),
  (4001212, 'Twilight Initiate', 27, 27, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c02_scene', 1, 1, 0, 0, 2),
  (4001213, 'Twilight Ogre Initiate', 27, 27, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c02_actor', 1, 1, 0, 0, 2),
  (4001214, 'Karr''gonn', 27, 27, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1, 1, 0, 0, 0),
  (4001215, 'High Cultist Azennios', 27, 27, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1, 1, 0, 0, 0),
  (4001216, 'Garnoth, Fist of the Legion', 27, 27, 0, 14, 0, 1, 0, 3, '', 'npc_bs_c02_enemy', 1.3, 1, 0, 0, 0),
  (4001217, 'Gromm''ko', 27, 27, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1.3, 1, 0, 0, 0),
  (4001218, 'Okrog', 27, 27, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1.3, 1, 0, 0, 0),
  (4001219, 'Twilight Restraint Guard', 27, 27, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1, 1, 0, 0, 0),
  (4001220, 'Twilight Enforcer', 27, 27, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1, 1, 0, 0, 0),
  (4001221, 'Twilight Trial Focus', 27, 27, 0, 35, 0, 1, 33555202, 10, '', 'npc_bs_c02_scene', 1, 1, 0, 0, 2),
  (4001222, 'Trial Fire Elemental', 25, 25, 0, 14, 0, 1, 0, 4, '', 'npc_bs_c02_enemy', 1, 1, 0, 0, 0),
  (4001223, 'Smolderos', 29, 29, 0, 14, 0, 1, 0, 1, '', 'npc_bs_c02_enemy', 1, 1, 1, 4001223, 0),
  (4001224, 'Spinescale Matriarch', 27, 27, 0, 14, 0, 1, 0, 1, '', 'npc_bs_c02_enemy', 1, 1, 1, 4001224, 0),
  (4001225, 'Failed Supplicant', 26, 26, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1, 1, 1, 4001225, 0),
  (4001226, 'Horrorguard', 28, 28, 0, 14, 0, 1, 0, 3, '', 'npc_bs_c02_enemy', 1, 1, 0, 0, 0),
  (4001227, 'Twilight Guard', 27, 27, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1, 1, 1, 4001227, 0),
  (4001228, 'Twilight Scout', 26, 26, 0, 14, 0, 1, 0, 7, '', 'npc_bs_c02_enemy', 1, 1, 1, 4001228, 0),
  (4001229, 'Butcher', 27, 27, 0, 14, 0, 1, 0, 1, '', 'npc_bs_c02_enemy', 1, 1, 0, 0, 0),
  (4001250, 'Knockout', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001251, 'Identity', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001252, 'Fire', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001253, 'Supplicant A', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001254, 'Supplicant B', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001255, 'Supplicant C', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001256, 'Mylva', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001257, 'Devoran', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001258, 'Loads', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001259, 'Course', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001260, 'Mental', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001261, 'Mercy', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001262, 'Dog A', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001263, 'Dog B', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001264, 'Dog C', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001265, 'Grudge', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001266, 'Drop', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001267, 'Discord', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001268, 'Garnoth', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001269, 'Territory', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001270, 'Okrog', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001271, 'Head', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001272, 'Speech', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001273, 'Altar', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001274, 'Riot', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `exp` = VALUES(`exp`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `AIName` = VALUES(`AIName`), `ScriptName` = VALUES(`ScriptName`), `HealthModifier` = VALUES(`HealthModifier`), `DamageModifier` = VALUES(`DamageModifier`), `ExperienceModifier` = VALUES(`ExperienceModifier`), `lootid` = VALUES(`lootid`), `flags_extra` = VALUES(`flags_extra`);
DELETE FROM `creature_template_model` WHERE `CreatureID` IN (4001200, 4001201, 4001202, 4001203, 4001204, 4001205, 4001206, 4001207, 4001208, 4001209, 4001210, 4001211, 4001212, 4001213, 4001214, 4001215, 4001216, 4001217, 4001218, 4001219, 4001220, 4001221, 4001222, 4001223, 4001224, 4001225, 4001226, 4001227, 4001228, 4001229, 4001250, 4001251, 4001252, 4001253, 4001254, 4001255, 4001256, 4001257, 4001258, 4001259, 4001260, 4001261, 4001262, 4001263, 4001264, 4001265, 4001266, 4001267, 4001268, 4001269, 4001270, 4001271, 4001272, 4001273, 4001274);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
  (4001200, 0, 11815, 1, 1),
  (4001201, 0, 11811, 1, 1),
  (4001202, 0, 11815, 1, 1),
  (4001203, 0, 11824, 1, 1),
  (4001204, 0, 5070, 1, 1),
  (4001205, 0, 3770, 1, 1),
  (4001206, 0, 11824, 1, 1),
  (4001207, 0, 11824, 1, 1),
  (4001208, 0, 11824, 1, 1),
  (4001209, 0, 11824, 1, 1),
  (4001210, 0, 12168, 0.45, 1),
  (4001211, 0, 24813, 1, 1),
  (4001212, 0, 11824, 1, 1),
  (4001213, 0, 11584, 1, 1),
  (4001214, 0, 11584, 1, 1),
  (4001215, 0, 11824, 1, 1),
  (4001216, 0, 16632, 0.6, 1),
  (4001217, 0, 11542, 1, 1),
  (4001218, 0, 11584, 1, 1),
  (4001219, 0, 11824, 1, 1),
  (4001220, 0, 11812, 1, 1),
  (4001221, 0, 11686, 1, 1),
  (4001222, 0, 2172, 1, 1),
  (4001223, 0, 12168, 0.6, 1),
  (4001224, 0, 141, 1, 1),
  (4001225, 0, 11824, 1, 1),
  (4001226, 0, 18621, 1, 1),
  (4001227, 0, 11812, 1, 1),
  (4001228, 0, 11816, 1, 1),
  (4001229, 0, 2571, 1, 1),
  (4001250, 0, 11686, 1, 1),
  (4001251, 0, 11686, 1, 1),
  (4001252, 0, 11686, 1, 1),
  (4001253, 0, 11686, 1, 1),
  (4001254, 0, 11686, 1, 1),
  (4001255, 0, 11686, 1, 1),
  (4001256, 0, 11686, 1, 1),
  (4001257, 0, 11686, 1, 1),
  (4001258, 0, 11686, 1, 1),
  (4001259, 0, 11686, 1, 1),
  (4001260, 0, 11686, 1, 1),
  (4001261, 0, 11686, 1, 1),
  (4001262, 0, 11686, 1, 1),
  (4001263, 0, 11686, 1, 1),
  (4001264, 0, 11686, 1, 1),
  (4001265, 0, 11686, 1, 1),
  (4001266, 0, 11686, 1, 1),
  (4001267, 0, 11686, 1, 1),
  (4001268, 0, 11686, 1, 1),
  (4001269, 0, 11686, 1, 1),
  (4001270, 0, 11686, 1, 1),
  (4001271, 0, 11686, 1, 1),
  (4001272, 0, 11686, 1, 1),
  (4001273, 0, 11686, 1, 1),
  (4001274, 0, 11686, 1, 1);
INSERT INTO `mod_customnpcs_outfit` (`outfit_id`, `race`, `gender`, `class`, `skin`, `face`, `hair`, `hair_color`, `facial_hair`, `chest`, `shoulders`, `shirt`, `waist`, `legs`, `feet`, `hands`, `mainhand`, `ranged`) VALUES
  (4001200, 1, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001201, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001202, 1, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001203, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001204, 4, 0, 1, 0, 0, 0, 0, 0, 6085, 6597, 0, 6594, 6596, 6573, 0, 6631, 0),
  (4001205, 6, 0, 1, 0, 0, 0, 0, 0, 6085, 6597, 0, 6594, 6596, 6573, 0, 6631, 0),
  (4001206, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001207, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001208, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001209, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001212, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001215, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001219, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 12282, 0),
  (4001220, 2, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 12282, 0),
  (4001225, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001227, 2, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 12282, 0),
  (4001228, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 12282, 2504)
ON DUPLICATE KEY UPDATE
  `race` = VALUES(`race`), `gender` = VALUES(`gender`), `class` = VALUES(`class`), `skin` = VALUES(`skin`), `face` = VALUES(`face`), `hair` = VALUES(`hair`), `hair_color` = VALUES(`hair_color`), `facial_hair` = VALUES(`facial_hair`), `chest` = VALUES(`chest`), `shoulders` = VALUES(`shoulders`), `shirt` = VALUES(`shirt`), `waist` = VALUES(`waist`), `legs` = VALUES(`legs`), `feet` = VALUES(`feet`), `hands` = VALUES(`hands`), `mainhand` = VALUES(`mainhand`), `ranged` = VALUES(`ranged`);
INSERT INTO `mod_customnpcs_outfit_entry` (`creature_entry`, `outfit_id`) VALUES
  (4001200, 0),
  (4001201, 0),
  (4001202, 0),
  (4001203, 0),
  (4001204, 4001204),
  (4001205, 4001205),
  (4001206, 0),
  (4001207, 0),
  (4001208, 0),
  (4001209, 0),
  (4001212, 0),
  (4001215, 0),
  (4001219, 0),
  (4001220, 0),
  (4001225, 0),
  (4001227, 0),
  (4001228, 0)
ON DUPLICATE KEY UPDATE
  `outfit_id` = VALUES(`outfit_id`);
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`) VALUES
  (4001200, 1, 4575, 0, 0),
  (4001201, 1, 4575, 0, 0),
  (4001202, 1, 4575, 0, 0),
  (4001203, 1, 4575, 0, 0),
  (4001204, 1, 6631, 0, 0),
  (4001205, 1, 6631, 0, 0),
  (4001206, 1, 4575, 0, 0),
  (4001207, 1, 4575, 0, 0),
  (4001208, 1, 4575, 0, 0),
  (4001209, 1, 4575, 0, 0),
  (4001212, 1, 4575, 0, 0),
  (4001215, 1, 4575, 0, 0),
  (4001219, 1, 12282, 0, 0),
  (4001220, 1, 12282, 0, 0),
  (4001225, 1, 4575, 0, 0),
  (4001227, 1, 12282, 0, 0),
  (4001228, 1, 12282, 0, 2504)
ON DUPLICATE KEY UPDATE
  `ItemID1` = VALUES(`ItemID1`), `ItemID2` = VALUES(`ItemID2`), `ItemID3` = VALUES(`ItemID3`);
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `bonding`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `description`, `spellid_1`, `spelltrigger_1`, `ScriptName`) VALUES
  (900200, 12, 0, 'Ortell''s Blackjack', 22121, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Use on the isolated recruit after he reaches cover. Ortell can replace it.', 39865, 0, 'item_bs_c02_tool'),
  (900201, 12, 0, 'Twilight Recruitment Papers', 4110, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'A watch roster and sponsor seal identify the missing recruit.', 0, 0, ''),
  (900202, 12, 0, 'Altered Recruitment Papers', 4110, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Use outside combat in the Charred Vale to renew your cult disguise.', 4329, 0, 'item_bs_c02_tool'),
  (900203, 12, 0, 'Flame Blossoms', 19495, 1, 0, -1, -1, 1, 0, 8, 8, 4, 0, 0, 0, 0, 0, 0, 'Their petals stay warm even after they are plucked.', 0, 0, ''),
  (900204, 12, 0, 'Supplicant Binding Gem', 7257, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Use on each burning supplicant during Cargall''s preservation trial.', 34665, 0, 'item_bs_c02_tool'),
  (900205, 12, 0, 'Training Hound Leash', 1007, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Use beside Devoran to call your hound. Speak to it to feed or command it.', 4329, 0, 'item_bs_c02_tool'),
  (900206, 12, 0, 'Champion''s Collar', 224, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Devoran has fitted the matriarch''s hide for a champion''s hound.', 0, 0, ''),
  (900207, 12, 0, 'Spiked Basilisk Hide', 7399, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Tough scales that will hold through a hound''s strongest lunge.', 0, 0, ''),
  (900208, 12, 0, 'Twilight Communique', 7233, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Prisoner transfers share a seal with shipments of unearthed relics.', 0, 0, ''),
  (900209, 12, 0, 'Charred Vale Battleplans', 4110, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Supply routes are marked in soot and red ink.', 0, 0, ''),
  (900210, 12, 0, 'Talisman of Flame Ascendancy', 6484, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Use at Garnoth''s Challenge Stone to borrow the flame for your duel.', 4329, 0, 'item_bs_c02_tool'),
  (900211, 12, 0, 'Orb of Ascension', 6014, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Use near Mylva, then answer the questioner before each prompt expires.', 4329, 0, 'item_bs_c02_tool'),
  (900212, 12, 0, 'Initiation Speech Notes', 4110, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Ortell''s careful cues leave room for a speaker to watch the prisoner altar.', 0, 0, ''),
  (900213, 12, 0, 'Cult Prison Key', 6708, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Taken from the restraint guard. Jarod''s bindings bear its matching lock.', 0, 0, ''),
  (900214, 12, 0, 'Relic Buyers Ledger', 1134, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The buyers paid for relics from excavations in Dustwallow.', 0, 0, ''),
  (900215, 12, 0, 'Letter to the Dawnchasers', 7233, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'Jarod vouches for the bearer to Sunwalker Dezco.', 0, 0, ''),
  (900216, 4, 0, 'Inside the Twilight: Signet of Might', 9846, 2, 11, -1, -1, 30, 25, 1, 1, 1, 4, 5, 7, 4, 0, 0, 'Given in gratitude for freeing Jarod and uncovering the cult''s buyers.', 0, 0, ''),
  (900217, 4, 0, 'Inside the Twilight: Signet of Precision', 9846, 2, 11, -1, -1, 30, 25, 1, 1, 1, 3, 5, 7, 4, 0, 0, 'Given in gratitude for freeing Jarod and uncovering the cult''s buyers.', 0, 0, ''),
  (900218, 4, 0, 'Inside the Twilight: Signet of Sorcery', 9846, 2, 11, -1, -1, 30, 25, 1, 1, 1, 5, 5, 45, 6, 0, 0, 'Given in gratitude for freeing Jarod and uncovering the cult''s buyers.', 0, 0, ''),
  (900219, 4, 0, 'Inside the Twilight: Signet of Restoration', 9846, 2, 11, -1, -1, 30, 25, 1, 1, 1, 6, 5, 43, 2, 0, 0, 'Given in gratitude for freeing Jarod and uncovering the cult''s buyers.', 0, 0, ''),
  (900220, 4, 0, 'Inside the Twilight: Signet of Guarding', 9846, 2, 11, -1, -1, 30, 25, 1, 1, 1, 7, 6, 12, 4, 0, 0, 'Given in gratitude for freeing Jarod and uncovering the cult''s buyers.', 0, 0, ''),
  (900221, 4, 0, 'Inside the Twilight: Signet of Balance', 9846, 2, 11, -1, -1, 30, 25, 1, 1, 1, 5, 4, 6, 4, 7, 4, 'Given in gratitude for freeing Jarod and uncovering the cult''s buyers.', 0, 0, '')
ON DUPLICATE KEY UPDATE
  `class` = VALUES(`class`), `subclass` = VALUES(`subclass`), `name` = VALUES(`name`), `displayid` = VALUES(`displayid`), `Quality` = VALUES(`Quality`), `InventoryType` = VALUES(`InventoryType`), `AllowableClass` = VALUES(`AllowableClass`), `AllowableRace` = VALUES(`AllowableRace`), `ItemLevel` = VALUES(`ItemLevel`), `RequiredLevel` = VALUES(`RequiredLevel`), `maxcount` = VALUES(`maxcount`), `stackable` = VALUES(`stackable`), `bonding` = VALUES(`bonding`), `stat_type1` = VALUES(`stat_type1`), `stat_value1` = VALUES(`stat_value1`), `stat_type2` = VALUES(`stat_type2`), `stat_value2` = VALUES(`stat_value2`), `stat_type3` = VALUES(`stat_type3`), `stat_value3` = VALUES(`stat_value3`), `description` = VALUES(`description`), `spellid_1` = VALUES(`spellid_1`), `spelltrigger_1` = VALUES(`spelltrigger_1`), `ScriptName` = VALUES(`ScriptName`);
DELETE FROM `creature_loot_template` WHERE `Entry` = 4001224;
UPDATE `creature_template` SET `mingold`=28,`maxgold`=94,`lootid`=4001223 WHERE `entry`=4001223;
DELETE FROM `creature_loot_template` WHERE `Entry`=4001223;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001223, 7068, 0, 65, 0, 1, 0, 1, 2),
  (4001223, 2772, 0, 15, 0, 1, 0, 1, 1);
UPDATE `creature_template` SET `mingold`=28,`maxgold`=94,`lootid`=4001224 WHERE `entry`=4001224;
DELETE FROM `creature_loot_template` WHERE `Entry`=4001224;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001224, 1702, 0, 65, 0, 1, 0, 1, 2),
  (4001224, 3667, 0, 35, 0, 1, 0, 1, 1);
UPDATE `creature_template` SET `mingold`=28,`maxgold`=94,`lootid`=4001225 WHERE `entry`=4001225;
DELETE FROM `creature_loot_template` WHERE `Entry`=4001225;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001225, 2592, 0, 40, 0, 1, 0, 1, 2),
  (4001225, 3770, 0, 8, 0, 1, 0, 1, 1),
  (4001225, 1205, 0, 8, 0, 1, 0, 1, 1);
-- Reuse the stock donor's level-appropriate world-drop references when installed.
INSERT INTO `creature_loot_template`
  (`Entry`,`Item`,`Reference`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`)
SELECT 4001225, l.`Item`,l.`Reference`,l.`Chance`,0,l.`LootMode`,l.`GroupId`,l.`MinCount`,l.`MaxCount`
FROM `creature_loot_template` l
WHERE l.`Entry`=431 AND l.`Reference`>=1000000 AND l.`QuestRequired`=0
  AND EXISTS (SELECT 1 FROM `reference_loot_template` r WHERE r.`Entry`=l.`Reference`);
UPDATE `creature_template` SET `mingold`=28,`maxgold`=94,`lootid`=4001227 WHERE `entry`=4001227;
DELETE FROM `creature_loot_template` WHERE `Entry`=4001227;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001227, 2592, 0, 40, 0, 1, 0, 1, 2),
  (4001227, 3770, 0, 8, 0, 1, 0, 1, 1),
  (4001227, 1205, 0, 8, 0, 1, 0, 1, 1);
-- Reuse the stock donor's level-appropriate world-drop references when installed.
INSERT INTO `creature_loot_template`
  (`Entry`,`Item`,`Reference`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`)
SELECT 4001227, l.`Item`,l.`Reference`,l.`Chance`,0,l.`LootMode`,l.`GroupId`,l.`MinCount`,l.`MaxCount`
FROM `creature_loot_template` l
WHERE l.`Entry`=431 AND l.`Reference`>=1000000 AND l.`QuestRequired`=0
  AND EXISTS (SELECT 1 FROM `reference_loot_template` r WHERE r.`Entry`=l.`Reference`);
UPDATE `creature_template` SET `mingold`=28,`maxgold`=94,`lootid`=4001228 WHERE `entry`=4001228;
DELETE FROM `creature_loot_template` WHERE `Entry`=4001228;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001228, 2592, 0, 40, 0, 1, 0, 1, 2),
  (4001228, 3770, 0, 8, 0, 1, 0, 1, 1),
  (4001228, 1205, 0, 8, 0, 1, 0, 1, 1);
-- Reuse the stock donor's level-appropriate world-drop references when installed.
INSERT INTO `creature_loot_template`
  (`Entry`,`Item`,`Reference`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`)
SELECT 4001228, l.`Item`,l.`Reference`,l.`Chance`,0,l.`LootMode`,l.`GroupId`,l.`MinCount`,l.`MaxCount`
FROM `creature_loot_template` l
WHERE l.`Entry`=431 AND l.`Reference`>=1000000 AND l.`QuestRequired`=0
  AND EXISTS (SELECT 1 FROM `reference_loot_template` r WHERE r.`Entry`=l.`Reference`);
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4001224, 900207, 100, 1, 1, 0, 1, 1);
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `RewardXPDifficulty`, `RewardMoney`, `StartItem`, `Flags`, `AllowableRaces`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`, `RequiredNpcOrGo3`, `RequiredNpcOrGo4`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGoCount4`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`, `RequiredItemId1`, `RequiredItemId2`, `RequiredItemId3`, `RequiredItemId4`, `RequiredItemId5`, `RequiredItemId6`, `RequiredItemCount1`, `RequiredItemCount2`, `RequiredItemCount3`, `RequiredItemCount4`, `RequiredItemCount5`, `RequiredItemCount6`, `RewardChoiceItemID1`, `RewardChoiceItemID2`, `RewardChoiceItemID3`, `RewardChoiceItemID4`, `RewardChoiceItemID5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity1`, `RewardChoiceItemQuantity2`, `RewardChoiceItemQuantity3`, `RewardChoiceItemQuantity4`, `RewardChoiceItemQuantity5`, `RewardChoiceItemQuantity6`) VALUES
  (900200, 2, 25, 25, 406, 5, 1000, 900200, 0, 0, 'Signed in Blood', 'Lure one recruit away, knock them out with the blackjack, and recover the recruitment papers.', 'Ortell keeps his voice low. A recruit makes the watch circuit below our camp. Use the Recruit Watch Roster to lure a recruit into the hollow, wait until he reaches cover, then use my blackjack on him. Bring back his papers. We can borrow his place without taking his life.', 'Speak with Elementalist Ortell at the expedition refuge.', 4001250, 0, 0, 0, 1, 0, 0, 0, 'Recruit subdued in cover', '', '', '', 900201, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900201, 2, 25, 25, 406, 5, 1000, 900202, 0, 0, 'Your New Identity', 'Present the altered papers to Condenna and pass the identity check.', 'The recruit has a name, a sponsor and an appointment with Condenna. These altered papers now bear your description. Speak to Condenna at the western training camp to pass her identity check. Keep your cover using the papers; if the disguise is lost, Condenna or Ortell can renew it.', 'Speak with Condenna the Pitiless at the Twilight recruiting compound.', 4001251, 0, 0, 0, 1, 0, 0, 0, 'Papers presented to Condenna', '', '', '', 900202, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900202, 2, 25, 25, 406, 5, 1000, 0, 0, 0, 'Trial By Fire', 'Defeat 8 trial fire elementals while the disguise is active.', 'Our new recruits must face the fire. Speak to Condenna to begin or resume your trial, then defeat eight Trial Fire Elementals while wearing your disguise. They will be called one at a time. This trial tests your nerve, not your loyalties. Renew your cover with Ortell or your papers if needed.', 'Speak with Condenna the Pitiless at the Twilight recruiting compound.', 4001252, 0, 0, 0, 8, 0, 0, 0, 'Trial fire elementals defeated', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900203, 2, 25, 25, 406, 5, 1000, 0, 0, 0, 'In Bloom', 'Collect 8 flame blossoms while avoiding Smolderos.', 'Collect eight Flame Blossoms from the grove west of camp. Smolderos prowls among the patches. He sees through our robes; keep clear of him, and never mistake a uniform for protection.', 'Speak with Condenna the Pitiless at the Twilight recruiting compound.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900203, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900204, 2, 25, 25, 406, 5, 1000, 900204, 0, 0, 'Waste of Flesh', 'Use the binding gem to preserve 3 burning supplicants before their timers expire.', 'Cargall has left three supplicants burning in the training hollow. Ask him to begin the preservation trial, then use the binding gem on each before their forty-five seconds expire. The gem preserves a living recruit for the cult. Failed attempts can be restarted, and saved recruits remain credited.', 'Speak with Instructor Cargall at the Twilight recruiting compound.', 4001253, 4001254, 4001255, 0, 1, 1, 1, 0, 'First supplicant preserved', 'Second supplicant preserved', 'Third supplicant preserved', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900205, 2, 26, 25, 406, 4, 1040, 0, 0, 0, 'Twilight Training', 'Report completion of all three admission trials and meet the two instructors.', 'You have passed the first trials. Visit Instructor Mylva and Instructor Devoran and ask each for an introduction to their training. Return to Condenna when both have acknowledged you.', 'Speak with Condenna the Pitiless at the Twilight recruiting compound.', 4001256, 4001257, 0, 0, 1, 1, 0, 0, 'Training discussed with Mylva', 'Training discussed with Devoran', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900206, 2, 26, 25, 406, 5, 1040, 0, 0, 0, 'Physical Training: Forced Labor', 'Carry 5 training stones between the marked work stations.', 'Use the Training Stone Pile beside Mylva to take one heavy load. Carry it on foot to the Stone Delivery Station to the south. Deliver five loads; each delivery must follow a fresh pickup. Combat, mounting or abandoning the quest drops the current load.', 'Speak with Instructor Mylva at the Twilight recruiting compound.', 4001258, 0, 0, 0, 5, 0, 0, 0, 'Stone loads delivered', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900207, 2, 26, 25, 406, 5, 1040, 0, 0, 0, 'Agility Training: Run Like Hell!', 'Complete the 4-checkpoint obstacle route before the time expires.', 'Use the Agility Course Starting Tablet west of Mylva. Pass markers A, B, C and D in that order within sixty seconds, on the ground and on foot. Combat, mounting, flying or leaving the course resets this attempt. A failed attempt can be restarted at the start marker.', 'Speak with Instructor Mylva at the Twilight recruiting compound.', 4001259, 0, 0, 0, 1, 0, 0, 0, 'Agility course completed', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900208, 2, 26, 25, 406, 5, 1040, 900211, 0, 0, 'Mental Training: Speaking the Truth to Power', 'Answer 10 orb questions correctly near Mylva; each offered question allows five seconds.', 'Use the Orb of Ascension near Mylva. Speak to your questioner and answer ten simple questions correctly. You have five seconds per offered question. Wrong or late answers interrupt the attempt; answers already credited remain recorded. Use the orb again to retry.', 'Speak with Instructor Mylva at the Twilight recruiting compound.', 4001260, 0, 0, 0, 10, 0, 0, 0, 'Mental prompts answered correctly', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900209, 2, 27, 25, 406, 5, 1080, 0, 0, 0, 'Spiritual Training: Mercy is for the Weak', 'Defeat 5 failed supplicants in the cults lethal promotion trial.', 'The cult calls hesitation weakness. Defeat five Failed Supplicants north of the training camp while maintaining your disguise. Ortell needs you to reach the graduation platform; the price of this cover will stay with you.', 'Speak with Instructor Mylva at the Twilight recruiting compound.', 4001261, 0, 0, 0, 5, 0, 0, 0, 'Failed supplicants put to rest', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900210, 2, 27, 25, 406, 5, 1080, 900205, 0, 0, 'Walking the Dog', 'Take an owner-bound training hound through 3 feeding/handling stations.', 'Use the leash near Devoran to call your own training core hound. Take it to feeding stations A, B and C in order, then command it to feed at each station through its gossip menu. Stay nearby. Lost hounds can be called again with the leash, and completed stations remain credited.', 'Speak with Instructor Devoran at the Twilight recruiting compound.', 4001262, 4001263, 4001264, 0, 1, 1, 1, 0, 'Hound fed at the first station', 'Hound fed at the second station', 'Hound fed at the third station', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900211, 2, 27, 25, 406, 5, 1080, 0, 0, 0, 'A Champion''s Collar', 'Defeat the Spinescale Matriarch and bring its spiked hide to Devoran to make the hounds collar.', 'Devoran wants a spiked hide from the Spinescale Matriarch east of his station. Defeat the matriarch and bring him the hide. He will prepare a collar for your supervised match.', 'Speak with Instructor Devoran at the Twilight recruiting compound.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900207, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900212, 2, 27, 25, 406, 5, 1080, 900205, 0, 0, 'Grudge Match', 'Defeat Butcher with your collared hound, then defeat Gromm''ko with the hound nearby.', 'Use the leash or ask Devoran to prepare your collar and supervised match. Take your hound to station A and command it to attack Gromm''ko''s raptor Butcher. When the raptor falls, Gromm''ko turns on you. Defeat him while your hound is alive and nearby. You may fight beside it.', 'Speak with Instructor Devoran at the Twilight recruiting compound.', 4001265, 0, 0, 0, 1, 0, 0, 0, 'Butcher and Gromm''ko defeated', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900213, 2, 27, 25, 406, 5, 1080, 0, 0, 0, 'Gather the Intelligence', 'Recover the communique and battleplans from their caches, then check the dead drop.', 'Recover the communique and battleplans from the guarded caches south of the camp. Use Ortell''s dead drop with both documents before returning to him. The caches are still watched; keep your disguise ready.', 'Speak with Elementalist Ortell at the expedition refuge.', 4001266, 0, 0, 0, 1, 0, 0, 0, 'Documents checked at the dead drop', '', '', '', 900208, 900209, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900214, 2, 28, 25, 406, 5, 1120, 0, 0, 0, 'Seeds of Discord', 'Distract Karr''gonn, then defeat Azennios without revealing the handler.', 'Use the Azennios''s Meeting Tablet near the dead drop to begin a secret meeting. Speak to Karr''gonn to send him after a false order, then defeat Azennios while the distraction lasts. If Karr''gonn returns, withdraw and restart the scene. Never speak Ortell''s name.', 'Speak with Elementalist Ortell at the expedition refuge.', 4001267, 0, 0, 0, 1, 0, 0, 0, 'Azennios defeated during the diversion', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900215, 2, 28, 25, 406, 5, 1120, 900210, 0, 0, 'The Greater of Two Evils', 'Use the ascendancy talisman to assume a fire-elemental form and defeat Garnoth.', 'Use the ascendancy talisman at Garnoth''s Challenge Stone southwest of camp. It grants a fire-elemental form for this duel. Defeat Garnoth while the form remains active. The form ends when the encounter closes or you leave the valley.', 'Speak with Instructor Mylva at the Twilight recruiting compound.', 4001268, 0, 0, 0, 1, 0, 0, 0, 'Garnoth defeated in elemental form', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900216, 2, 28, 25, 406, 5, 1120, 0, 0, 0, 'Twilight Territory', 'Use the calling tablet at the holding camp and defeat 10 Horrorguards while disguised.', 'Use the calling tablet at the holding camp to challenge ten Horrorguards. They will be called one at a time; return to the tablet if your challenge is interrupted. These demons are rivals to the cult, not innocent travelers. Keep your cover intact throughout the challenge and as you return.', 'Speak with Instructor Mylva at the Twilight recruiting compound.', 4001269, 0, 0, 0, 10, 0, 0, 0, 'Horrorguards defeated', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900217, 2, 28, 25, 406, 5, 1120, 0, 0, 0, 'Speech Writing for Dummies', 'Remove the scheduled ogre speaker Okrog and receive Ortell''s cue cards and take his place at the podium.', 'Use Okrog''s Speaking Roster south of the camp to confront the scheduled ogre speaker. Defeat him, then speak to Ortell for your cue cards. Your opening lies in the crowd, not in another prison assault.', 'Speak with Elementalist Ortell at the expedition refuge.', 4001270, 0, 0, 0, 1, 0, 0, 0, 'Okrog defeated', '', '', '', 900212, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900218, 2, 29, 25, 406, 4, 1160, 0, 0, 0, 'Head of the Class', 'Receive the handler''s final instruction and report to Mylva for the speaking slot.', 'Ask Ortell for the final instruction, then report to Mylva. An initiate who can hold the crowd may approach the altar. Use their expectations to bring Jarod within reach.', 'Speak with Instructor Mylva at the Twilight recruiting compound.', 4001271, 0, 0, 0, 1, 0, 0, 0, 'Ortell''s final instruction received', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900219, 2, 29, 25, 406, 5, 1160, 0, 0, 0, 'Graduation Speech', 'Match 10 crowd moods with Inspire, Incite or Pander, then speak to Jarod at the altar.', 'Use the Initiation Podium beside the prisoner altar. Speak to the crowd leader and choose the response matching its displayed mood ten times. You have ten seconds per response. Correct responses remain credited after a retry. Then speak to Jarod at the altar.', 'Speak with Commander Jarod Shadowsong at the prisoner altar.', 4001272, 4001273, 0, 0, 10, 1, 0, 0, 'Crowd responses matched', 'Jarod reached at the altar', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900220, 2, 29, 25, 406, 5, 1160, 0, 0, 0, 'Twilight Riot', 'Defeat the restraint guard, recover its key, then free Jarod and escape through 3 enforcer waves.', 'Speak to Jarod to challenge his restraint guard. Defeat it and recover the prison key, then speak to Jarod again to unlock his bindings and begin the escape. Defeat three pairs of enforcers along the route and stay with him until he reaches Ortell''s refuge. The key can be recovered again after a failed escape.', 'Speak with Elementalist Ortell at the expedition refuge.', 4001274, 0, 0, 0, 1, 0, 0, 0, 'Jarod escorted to the refuge', '', '', '', 900213, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900221, 2, 29, 25, 406, 5, 1160, 0, 0, 0, 'The Buyers Behind the Banner', 'Return to the quiet camp cache and recover the relic buyers'' ledger.', 'Ortell has found a name missing from the orders: the buyer. Return to the quiet ledger cache and recover the Relic Buyers Ledger. The cult''s fire is only a curtain; someone has been buying what it digs from the earth.', 'Speak with Elementalist Ortell at the expedition refuge.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900214, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900222, 2, 30, 25, 406, 4, 1200, 900215, 0, 0, 'A Letter Through the Marsh', 'Deliver Jarod''s introduction to Dezco at the neutral Dustwallow field camp.', 'Jarod writes an introduction to Sunwalker Dezco. Deliver it to Dezco''s neutral field camp beside the Tabetha road in Dustwallow Marsh. Travel on foot or use your usual routes. His expedition can help us follow the buyers. Keep the letter safe until you reach him.', 'Speak with Sunwalker Dezco at the Dawnchaser field camp beside the Tabetha road in Dustwallow.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900215, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 900216, 900217, 900218, 900219, 900220, 900221, 1, 1, 1, 1, 1, 1)
ON DUPLICATE KEY UPDATE
  `QuestType` = VALUES(`QuestType`), `QuestLevel` = VALUES(`QuestLevel`), `MinLevel` = VALUES(`MinLevel`), `QuestSortID` = VALUES(`QuestSortID`), `RewardXPDifficulty` = VALUES(`RewardXPDifficulty`), `RewardMoney` = VALUES(`RewardMoney`), `StartItem` = VALUES(`StartItem`), `Flags` = VALUES(`Flags`), `AllowableRaces` = VALUES(`AllowableRaces`), `LogTitle` = VALUES(`LogTitle`), `LogDescription` = VALUES(`LogDescription`), `QuestDescription` = VALUES(`QuestDescription`), `QuestCompletionLog` = VALUES(`QuestCompletionLog`), `RequiredNpcOrGo1` = VALUES(`RequiredNpcOrGo1`), `RequiredNpcOrGo2` = VALUES(`RequiredNpcOrGo2`), `RequiredNpcOrGo3` = VALUES(`RequiredNpcOrGo3`), `RequiredNpcOrGo4` = VALUES(`RequiredNpcOrGo4`), `RequiredNpcOrGoCount1` = VALUES(`RequiredNpcOrGoCount1`), `RequiredNpcOrGoCount2` = VALUES(`RequiredNpcOrGoCount2`), `RequiredNpcOrGoCount3` = VALUES(`RequiredNpcOrGoCount3`), `RequiredNpcOrGoCount4` = VALUES(`RequiredNpcOrGoCount4`), `ObjectiveText1` = VALUES(`ObjectiveText1`), `ObjectiveText2` = VALUES(`ObjectiveText2`), `ObjectiveText3` = VALUES(`ObjectiveText3`), `ObjectiveText4` = VALUES(`ObjectiveText4`), `RequiredItemId1` = VALUES(`RequiredItemId1`), `RequiredItemId2` = VALUES(`RequiredItemId2`), `RequiredItemId3` = VALUES(`RequiredItemId3`), `RequiredItemId4` = VALUES(`RequiredItemId4`), `RequiredItemId5` = VALUES(`RequiredItemId5`), `RequiredItemId6` = VALUES(`RequiredItemId6`), `RequiredItemCount1` = VALUES(`RequiredItemCount1`), `RequiredItemCount2` = VALUES(`RequiredItemCount2`), `RequiredItemCount3` = VALUES(`RequiredItemCount3`), `RequiredItemCount4` = VALUES(`RequiredItemCount4`), `RequiredItemCount5` = VALUES(`RequiredItemCount5`), `RequiredItemCount6` = VALUES(`RequiredItemCount6`), `RewardChoiceItemID1` = VALUES(`RewardChoiceItemID1`), `RewardChoiceItemID2` = VALUES(`RewardChoiceItemID2`), `RewardChoiceItemID3` = VALUES(`RewardChoiceItemID3`), `RewardChoiceItemID4` = VALUES(`RewardChoiceItemID4`), `RewardChoiceItemID5` = VALUES(`RewardChoiceItemID5`), `RewardChoiceItemID6` = VALUES(`RewardChoiceItemID6`), `RewardChoiceItemQuantity1` = VALUES(`RewardChoiceItemQuantity1`), `RewardChoiceItemQuantity2` = VALUES(`RewardChoiceItemQuantity2`), `RewardChoiceItemQuantity3` = VALUES(`RewardChoiceItemQuantity3`), `RewardChoiceItemQuantity4` = VALUES(`RewardChoiceItemQuantity4`), `RewardChoiceItemQuantity5` = VALUES(`RewardChoiceItemQuantity5`), `RewardChoiceItemQuantity6` = VALUES(`RewardChoiceItemQuantity6`);
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`, `ExclusiveGroup`, `ProvidedItemCount`, `SpecialFlags`) VALUES
  (900200, 900108, 0, 0, 1, 256),
  (900201, 900200, 0, 0, 1, 256),
  (900202, 900201, 0, -900205, 0, 256),
  (900203, 900201, 0, -900205, 0, 256),
  (900204, 900201, 0, -900205, 1, 256),
  (900205, 900202, 0, 0, 0, 256),
  (900206, 900205, 0, 0, 0, 256),
  (900207, 900206, 0, 0, 0, 256),
  (900208, 900207, 0, 0, 1, 256),
  (900209, 900208, 0, -900215, 0, 256),
  (900210, 900205, 0, 0, 1, 256),
  (900211, 900210, 0, 0, 0, 256),
  (900212, 900211, 0, -900215, 1, 256),
  (900213, 900205, 0, 0, 0, 256),
  (900214, 900213, 0, -900215, 0, 256),
  (900215, 900209, 0, -900217, 1, 256),
  (900216, 900209, 0, -900217, 0, 256),
  (900217, 900215, 0, 0, 0, 256),
  (900218, 900217, 0, 0, 0, 256),
  (900219, 900218, 0, 0, 0, 256),
  (900220, 900219, 0, 0, 0, 256),
  (900221, 900220, 0, 0, 0, 256),
  (900222, 900221, 0, 0, 1, 256)
ON DUPLICATE KEY UPDATE
  `PrevQuestID` = VALUES(`PrevQuestID`), `NextQuestID` = VALUES(`NextQuestID`), `ExclusiveGroup` = VALUES(`ExclusiveGroup`), `ProvidedItemCount` = VALUES(`ProvidedItemCount`), `SpecialFlags` = VALUES(`SpecialFlags`);
DELETE FROM `creature_queststarter` WHERE `quest` IN (900200, 900201, 900202, 900203, 900204, 900205, 900206, 900207, 900208, 900209, 900210, 900211, 900212, 900213, 900214, 900215, 900216, 900217, 900218, 900219, 900220, 900221, 900222);
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
  (4001001, 900200),
  (4001001, 900201),
  (4001200, 900202),
  (4001200, 900203),
  (4001201, 900204),
  (4001200, 900205),
  (4001202, 900206),
  (4001202, 900207),
  (4001202, 900208),
  (4001202, 900209),
  (4001203, 900210),
  (4001203, 900211),
  (4001203, 900212),
  (4001001, 900213),
  (4001001, 900214),
  (4001202, 900215),
  (4001202, 900216),
  (4001001, 900217),
  (4001001, 900218),
  (4001202, 900219),
  (4001002, 900220),
  (4001001, 900221),
  (4001204, 900222);
DELETE FROM `creature_questender` WHERE `quest` IN (900200, 900201, 900202, 900203, 900204, 900205, 900206, 900207, 900208, 900209, 900210, 900211, 900212, 900213, 900214, 900215, 900216, 900217, 900218, 900219, 900220, 900221, 900222);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
  (4001001, 900200),
  (4001200, 900201),
  (4001200, 900202),
  (4001200, 900203),
  (4001201, 900204),
  (4001200, 900205),
  (4001202, 900206),
  (4001202, 900207),
  (4001202, 900208),
  (4001202, 900209),
  (4001203, 900210),
  (4001203, 900211),
  (4001203, 900212),
  (4001001, 900213),
  (4001001, 900214),
  (4001202, 900215),
  (4001202, 900216),
  (4001001, 900217),
  (4001202, 900218),
  (4001002, 900219),
  (4001001, 900220),
  (4001001, 900221),
  (4001205, 900222);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) VALUES
  (900200, 'He will wake with a sore head, and nothing worse. These papers give us a way inside. Now I must make their seal speak for you.'),
  (900201, 'The seal is in order. Remember whose banner shelters you, recruit. Your first trial begins with fire.'),
  (900202, 'The flame has tested you and found you standing. Do not mistake that for mastery.'),
  (900203, 'Good. These blossoms will feed the brazier. Cargall will decide whether you are useful beyond gathering fuel.'),
  (900204, 'All three survived. The cult wastes nothing that can still serve. You may continue.'),
  (900205, 'Both instructors have accepted you. Attend to their trials; an initiate must be ready in body and mind.'),
  (900206, 'Five loads, delivered without excuse. Strength is only useful when it obeys.'),
  (900207, 'You reached every station in time. Keep that speed when the ground is less forgiving.'),
  (900208, 'Ten answers under pressure. A wandering mind has no place at the altar.'),
  (900209, 'Their ordeal is over. You have seen what failure means in this camp. Remember it.'),
  (900210, 'It knows your scent now. Trust grows from care repeated, not from a leash pulled harder.'),
  (900211, 'A sound hide. I can make a collar that will hold when your hound lunges.'),
  (900212, 'Butcher and Gromm''ko have had their lesson. Your hound followed its handler well.'),
  (900213, 'These routes are more than troop movements. The cult is moving prisoners and relics under the same seal. We have very little time.'),
  (900214, 'Azennios is gone, and Karr''gonn blames a false order. Their own suspicion has opened a path for us.'),
  (900215, 'Garnoth has fallen. The borrowed flame served its purpose; do not let its power persuade you to keep it.'),
  (900216, 'Ten demons defeated. You have earned the right to stand before the congregation.'),
  (900217, 'Okrog will not be taking the podium. Here are your notes. Give the crowd what it expects while you look for Jarod.'),
  (900218, 'Ortell has prepared you. I will put your name before the congregation. Take your place at the podium.'),
  (900219, 'You kept their eyes on the podium. Now keep your voice down: the restraint guard carries the key. We move when you have it.'),
  (900220, 'Jarod is here, alive. Let the cult shout at an empty altar. We can finally follow the people who paid for all this.'),
  (900221, 'These payments lead to excavations in Dustwallow. Jarod knows someone there who will listen. We will send you with his introduction.'),
  (900222, 'Jarod is free? Then you have already done more than this letter can say. Rest a moment. My people have troubles of their own, and the buyers'' trail passes through them.')
ON DUPLICATE KEY UPDATE
  `RewardText` = VALUES(`RewardText`);
INSERT INTO `quest_request_items` (`ID`, `CompletionText`) VALUES
  (900200, 'The recruit must live. Have you brought his papers?'),
  (900201, 'Your sponsor''s seal, recruit. Show it to me.'),
  (900202, 'Eight flames, eight victories. Have you finished your trial?'),
  (900203, 'The brazier needs eight blossoms. Where are they?'),
  (900204, 'Three supplicants are still of use to us. Did you preserve every one?'),
  (900205, 'Have both Mylva and Devoran accepted you?'),
  (900206, 'Five loads. Count them yourself before you report to me.'),
  (900207, 'Did you finish the entire course in order?'),
  (900208, 'Ten correct answers under pressure. Has the orb recorded them?'),
  (900209, 'Have you ended the suffering of five failed supplicants?'),
  (900210, 'A hound remembers its handler. Did you feed it at all three stations?'),
  (900211, 'Have you taken the matriarch''s hide?'),
  (900212, 'Was your hound victorious over both Butcher and his handler?'),
  (900213, 'Bring both documents. Have you checked them at our dead drop?'),
  (900214, 'Did the diversion last long enough to deal with Azennios?'),
  (900215, 'Has Garnoth fallen to your borrowed flame?'),
  (900216, 'Ten Horrorguards. Have you completed the challenge?'),
  (900217, 'Has Okrog''s speaking slot become available? Keep the cue cards with you.'),
  (900218, 'Has Ortell given you the final instruction?'),
  (900219, 'You held their attention. Did you reach Jarod at the altar?'),
  (900220, 'Where is Jarod? Bring him safely to the refuge, and keep the key.'),
  (900221, 'Does the cache still hold the buyers'' ledger?'),
  (900222, 'Jarod''s seal is familiar. Have you brought his letter?')
ON DUPLICATE KEY UPDATE
  `CompletionText` = VALUES(`CompletionText`);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 19 AND `SourceEntry` IN (900200, 900201, 900202, 900203, 900204, 900205, 900206, 900207, 900208, 900209, 900210, 900211, 900212, 900213, 900214, 900215, 900216, 900217, 900218, 900219, 900220, 900221, 900222);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceEntry`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionValue1`, `Comment`) VALUES
  (19, 900200, 0, 8, 900108, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900201, 0, 8, 900200, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900202, 0, 8, 900201, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900203, 0, 8, 900201, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900204, 0, 8, 900201, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900205, 0, 8, 900202, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900205, 0, 8, 900203, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900205, 0, 8, 900204, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900206, 0, 8, 900205, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900207, 0, 8, 900206, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900208, 0, 8, 900207, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900209, 0, 8, 900208, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900210, 0, 8, 900205, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900211, 0, 8, 900210, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900212, 0, 8, 900211, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900213, 0, 8, 900205, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900214, 0, 8, 900213, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900215, 0, 8, 900209, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900215, 0, 8, 900212, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900215, 0, 8, 900214, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900216, 0, 8, 900209, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900216, 0, 8, 900212, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900216, 0, 8, 900214, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900217, 0, 8, 900215, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900217, 0, 8, 900216, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900218, 0, 8, 900217, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900219, 0, 8, 900218, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900220, 0, 8, 900219, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900221, 0, 8, 900220, 'Broken Seal C02: every listed predecessor must be rewarded'),
  (19, 900222, 0, 8, 900221, 'Broken Seal C02: every listed predecessor must be rewarded');
DELETE FROM `quest_poi_points` WHERE `QuestID` IN (900200, 900201, 900202, 900203, 900204, 900205, 900206, 900207, 900208, 900209, 900210, 900211, 900212, 900213, 900214, 900215, 900216, 900217, 900218, 900219, 900220, 900221, 900222);
DELETE FROM `quest_poi` WHERE `QuestID` IN (900200, 900201, 900202, 900203, 900204, 900205, 900206, 900207, 900208, 900209, 900210, 900211, 900212, 900213, 900214, 900215, 900216, 900217, 900218, 900219, 900220, 900221, 900222);
INSERT INTO `quest_poi` (`QuestID`, `id`, `ObjectiveIndex`, `MapID`, `WorldMapAreaId`, `Floor`, `Priority`, `Flags`) VALUES
  (900200, 0, -1, 1, 81, 0, 0, 0),
  (900200, 1, 0, 1, 81, 0, 0, 0),
  (900200, 2, 4, 1, 81, 0, 0, 0),
  (900201, 0, -1, 1, 81, 0, 0, 0),
  (900201, 1, 0, 1, 81, 0, 0, 0),
  (900201, 2, 4, 1, 81, 0, 0, 0),
  (900202, 0, -1, 1, 81, 0, 0, 0),
  (900202, 1, 0, 1, 81, 0, 0, 0),
  (900203, 0, -1, 1, 81, 0, 0, 0),
  (900203, 1, 4, 1, 81, 0, 0, 0),
  (900203, 2, 4, 1, 81, 0, 0, 0),
  (900203, 3, 4, 1, 81, 0, 0, 0),
  (900203, 4, 4, 1, 81, 0, 0, 0),
  (900203, 5, 4, 1, 81, 0, 0, 0),
  (900203, 6, 4, 1, 81, 0, 0, 0),
  (900203, 7, 4, 1, 81, 0, 0, 0),
  (900203, 8, 4, 1, 81, 0, 0, 0),
  (900204, 0, -1, 1, 81, 0, 0, 0),
  (900204, 1, 0, 1, 81, 0, 0, 0),
  (900204, 2, 1, 1, 81, 0, 0, 0),
  (900204, 3, 2, 1, 81, 0, 0, 0),
  (900205, 0, -1, 1, 81, 0, 0, 0),
  (900205, 1, 0, 1, 81, 0, 0, 0),
  (900205, 2, 1, 1, 81, 0, 0, 0),
  (900206, 0, -1, 1, 81, 0, 0, 0),
  (900206, 1, 0, 1, 81, 0, 0, 0),
  (900206, 2, 0, 1, 81, 0, 0, 0),
  (900207, 0, -1, 1, 81, 0, 0, 0),
  (900207, 1, 0, 1, 81, 0, 0, 0),
  (900207, 2, 0, 1, 81, 0, 0, 0),
  (900207, 3, 0, 1, 81, 0, 0, 0),
  (900207, 4, 0, 1, 81, 0, 0, 0),
  (900207, 5, 0, 1, 81, 0, 0, 0),
  (900208, 0, -1, 1, 81, 0, 0, 0),
  (900208, 1, 0, 1, 81, 0, 0, 0),
  (900209, 0, -1, 1, 81, 0, 0, 0),
  (900209, 1, 0, 1, 81, 0, 0, 0),
  (900209, 2, 0, 1, 81, 0, 0, 0),
  (900210, 0, -1, 1, 81, 0, 0, 0),
  (900210, 1, 0, 1, 81, 0, 0, 0),
  (900210, 2, 1, 1, 81, 0, 0, 0),
  (900210, 3, 2, 1, 81, 0, 0, 0),
  (900211, 0, -1, 1, 81, 0, 0, 0),
  (900211, 1, 4, 1, 81, 0, 0, 0),
  (900212, 0, -1, 1, 81, 0, 0, 0),
  (900212, 1, 0, 1, 81, 0, 0, 0),
  (900213, 0, -1, 1, 81, 0, 0, 0),
  (900213, 1, 0, 1, 81, 0, 0, 0),
  (900213, 2, 4, 1, 81, 0, 0, 0),
  (900213, 3, 5, 1, 81, 0, 0, 0),
  (900214, 0, -1, 1, 81, 0, 0, 0),
  (900214, 1, 0, 1, 81, 0, 0, 0),
  (900215, 0, -1, 1, 81, 0, 0, 0),
  (900215, 1, 0, 1, 81, 0, 0, 0),
  (900216, 0, -1, 1, 81, 0, 0, 0),
  (900216, 1, 0, 1, 81, 0, 0, 0),
  (900217, 0, -1, 1, 81, 0, 0, 0),
  (900217, 1, 0, 1, 81, 0, 0, 0),
  (900217, 2, 4, 1, 81, 0, 0, 0),
  (900218, 0, -1, 1, 81, 0, 0, 0),
  (900218, 1, 0, 1, 81, 0, 0, 0),
  (900219, 0, -1, 1, 81, 0, 0, 0),
  (900219, 1, 0, 1, 81, 0, 0, 0),
  (900219, 2, 1, 1, 81, 0, 0, 0),
  (900220, 0, -1, 1, 81, 0, 0, 0),
  (900220, 1, 0, 1, 81, 0, 0, 0),
  (900220, 2, 4, 1, 81, 0, 0, 0),
  (900221, 0, -1, 1, 81, 0, 0, 0),
  (900221, 1, 4, 1, 81, 0, 0, 0),
  (900222, 0, -1, 1, 141, 0, 0, 0),
  (900222, 1, 4, 1, 141, 0, 0, 0);
INSERT INTO `quest_poi_points` (`QuestID`, `Idx1`, `Idx2`, `X`, `Y`) VALUES
  (900200, 0, 0, 1100, 1540),
  (900200, 1, 0, 869, 1666),
  (900200, 2, 0, 869, 1666),
  (900201, 0, 0, 635, 1624),
  (900201, 1, 0, 635, 1624),
  (900201, 2, 0, 635, 1624),
  (900202, 0, 0, 635, 1624),
  (900202, 1, 0, 635, 1624),
  (900203, 0, 0, 635, 1624),
  (900203, 1, 0, 776, 1588),
  (900203, 2, 0, 790, 1580),
  (900203, 3, 0, 805, 1590),
  (900203, 4, 0, 782, 1603),
  (900203, 5, 0, 798, 1608),
  (900203, 6, 0, 774, 1620),
  (900203, 7, 0, 808, 1625),
  (900203, 8, 0, 790, 1638),
  (900204, 0, 0, 636, 1632),
  (900204, 1, 0, 636, 1632),
  (900204, 2, 0, 636, 1632),
  (900204, 3, 0, 636, 1632),
  (900205, 0, 0, 635, 1624),
  (900205, 1, 0, 644, 1620),
  (900205, 2, 0, 646, 1630),
  (900206, 0, 0, 644, 1620),
  (900206, 1, 0, 636, 1617),
  (900206, 2, 0, 649, 1626),
  (900207, 0, 0, 644, 1620),
  (900207, 1, 0, 650, 1637),
  (900207, 2, 0, 657, 1637),
  (900207, 3, 0, 657, 1616),
  (900207, 4, 0, 625, 1616),
  (900207, 5, 0, 625, 1635),
  (900208, 0, 0, 644, 1620),
  (900208, 1, 0, 644, 1620),
  (900209, 0, 0, 644, 1620),
  (900209, 1, 0, 600, 1648),
  (900209, 2, 0, 600, 1654),
  (900210, 0, 0, 646, 1630),
  (900210, 1, 0, 647, 1636),
  (900210, 2, 0, 640, 1640),
  (900210, 3, 0, 628, 1638),
  (900211, 0, 0, 646, 1630),
  (900211, 1, 0, 955, 1570),
  (900212, 0, 0, 646, 1630),
  (900212, 1, 0, 646, 1630),
  (900213, 0, 0, 1100, 1540),
  (900213, 1, 0, 1089, 1537),
  (900213, 2, 0, 632, 1626),
  (900213, 3, 0, 895, 1687),
  (900214, 0, 0, 1100, 1540),
  (900214, 1, 0, 883, 1675),
  (900215, 0, 0, 644, 1620),
  (900215, 1, 0, 654, 1624),
  (900216, 0, 0, 644, 1620),
  (900216, 1, 0, 887, 1677),
  (900217, 0, 0, 1100, 1540),
  (900217, 1, 0, 887, 1677),
  (900217, 2, 0, 1100, 1540),
  (900218, 0, 0, 644, 1620),
  (900218, 1, 0, 1100, 1540),
  (900219, 0, 0, 895, 1682),
  (900219, 1, 0, 895, 1675),
  (900219, 2, 0, 895, 1682),
  (900220, 0, 0, 1100, 1540),
  (900220, 1, 0, 895, 1682),
  (900220, 2, 0, 895, 1682),
  (900221, 0, 0, 1100, 1540),
  (900221, 1, 0, 894, 1688),
  (900222, 0, 0, -3970, -3350),
  (900222, 1, 0, -3970, -3350);
INSERT INTO `npc_text` (`ID`, `text0_0`, `Probability0`) VALUES
  (4001200, 'Show your sponsor papers. This camp has no patience for an uncertain recruit.', 1),
  (4001201, 'Preserve what the cult can still use. Those who falter will learn the cost.', 1),
  (4001202, 'Your body, your mind and your words must all serve the flame.', 1),
  (4001203, 'A hound needs a handler who can earn its trust. Gromm''ko thinks his raptor has no equal.', 1),
  (4001204, 'The others still need us. Show Dezco what Ortell recovered, and keep moving.', 1),
  (4001205, 'Jarod sends a trusted traveler. Let me see his letter; the Dawnchasers will follow these buyers.', 1),
  (4001206, 'The watch captain sent me here. Is this about my papers?', 1),
  (4001207, 'The fire will not let me go. Use the binding gem before it consumes me.', 1),
  (4001208, 'I can still serve. Please, do not leave me to burn.', 1),
  (4001209, 'Cargall said the gem would hold the flame. You have it, do you not?', 1),
  (4001210, 'The hound watches your hands and sniffs toward the feeding station.', 1),
  (4001211, 'The orb brightens. A voice tests your certainty before the flame.', 1),
  (4001212, 'The congregation waits for its speaker. Read their mood before you answer.', 1),
  (4001002, 'Keep your voice down. My chains have a guard, and the crowd has a memory.', 1)
ON DUPLICATE KEY UPDATE
  `text0_0` = VALUES(`text0_0`), `Probability0` = VALUES(`Probability0`);
DELETE FROM `gossip_menu` WHERE `MenuID` IN (4001200, 4001201, 4001202, 4001203, 4001204, 4001205, 4001206, 4001207, 4001208, 4001209, 4001210, 4001211, 4001212, 4001002);
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
  (4001200, 4001200),
  (4001201, 4001201),
  (4001202, 4001202),
  (4001203, 4001203),
  (4001204, 4001204),
  (4001205, 4001205),
  (4001206, 4001206),
  (4001207, 4001207),
  (4001208, 4001208),
  (4001209, 4001209),
  (4001210, 4001210),
  (4001211, 4001211),
  (4001212, 4001212),
  (4001002, 4001002);
UPDATE `creature_template` SET `gossip_menu_id` = `entry` WHERE `entry` IN (4001200, 4001201, 4001202, 4001203, 4001204, 4001205, 4001206, 4001207, 4001208, 4001209, 4001210, 4001211, 4001212, 4001002);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data3`, `Data5`, `Data18`, `ScriptName`) VALUES
  (4001300, 10, 6420, 'Recruit Watch Roster', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001301, 10, 269, 'Flame Blossom Patch', 1, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001302, 10, 235, 'Training Stone Pile', 0.3, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001303, 10, 6737, 'Training Load Crate', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001304, 10, 6420, 'Agility Course Starting Tablet', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001305, 10, 6420, 'Agility Course: Checkpoint A', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001306, 10, 6420, 'Agility Course: Checkpoint B', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001307, 10, 6420, 'Agility Course: Checkpoint C', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001308, 10, 6420, 'Agility Course: Checkpoint D', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001309, 5, 6737, 'First Hound Feeding Station', 0.5, 0, 0, 1, ''),
  (4001310, 5, 6737, 'Second Hound Feeding Station', 0.5, 0, 0, 1, ''),
  (4001311, 5, 6737, 'Third Hound Feeding Station', 0.5, 0, 0, 1, ''),
  (4001312, 10, 259, 'Sealed Twilight Dispatches', 1, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001313, 10, 259, 'Charred Vale Battleplan Cache', 1, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001314, 10, 6737, 'Ortell''s Sealed Message Crate', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001315, 10, 6420, 'Azennios''s Meeting Tablet', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001316, 10, 235, 'Garnoth''s Challenge Stone', 0.3, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001317, 10, 6420, 'Okrog''s Speaking Roster', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001318, 10, 227, 'Initiation Podium', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001319, 10, 6419, 'Broken Restraint Tablet', 0.55, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001320, 10, 6737, 'Buyer Correspondence Crate', 0.65, 0, 0, 1, 'go_bs_c02_interaction'),
  (4001321, 10, 6419, 'Horrorguard Calling Tablet', 0.55, 0, 0, 1, 'go_bs_c02_interaction')
ON DUPLICATE KEY UPDATE
  `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `size` = VALUES(`size`), `Data3` = VALUES(`Data3`), `Data5` = VALUES(`Data5`), `Data18` = VALUES(`Data18`), `ScriptName` = VALUES(`ScriptName`);
DROP TEMPORARY TABLE IF EXISTS `bs_c02_creature_spawns`;
CREATE TEMPORARY TABLE `bs_c02_creature_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_c02_gameobject_spawns`;
CREATE TEMPORARY TABLE `bs_c02_gameobject_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c02_creature_spawns` (`spawn_key`, `entry`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C02:NPC_CONDENNA:condenna', 4001200, 406, 635.0, 1624.0, -17.659155673889078, 3.14),
  ('BS-C02:NPC_CARGALL:cargall', 4001201, 406, 636.0, 1632.0, -17.671715813413623, 3.14),
  ('BS-C02:NPC_MYLVA:mylva', 4001202, 406, 644.0, 1620.0, -18.099289405229584, 3.14),
  ('BS-C02:NPC_DEVORAN:devoran', 4001203, 406, 646.0, 1630.0, -17.768230569760494, 3.14),
  ('BS-C02:NPC_DEZCO:dezco', 4001205, 15, -3970, -3350, 39.34284809730439, 3.14),
  ('BS-C02:NPC_SMOLDEROS:smolderos', 4001223, 406, 784.0, 1628.0, -33.92676009625418, 3.14),
  ('BS-C02:NPC_MATRIARCH:matriarch', 4001224, 406, 955.0, 1570.0, -10.151935222047097, 3.14),
  ('BS-C02:NPC_FAILED:failed_0', 4001225, 406, 600, 1648, -14.609421585323975, 3.14),
  ('BS-C02:NPC_FAILED:failed_1', 4001225, 406, 600, 1654, -15.662886761449489, 3.14),
  ('BS-C02:NPC_GUARD:guard_0', 4001227, 406, 643.0, 1627.0, -17.777485409410172, 3.14),
  ('BS-C02:NPC_GUARD:guard_1', 4001227, 406, 633.0, 1627.0, -17.611030507710623, 3.14),
  ('BS-C02:NPC_SCOUT:scout_0', 4001228, 406, 638.0, 1627.0, -17.76466084589558, 3.14),
  ('BS-C02:NPC_SCOUT:scout_1', 4001228, 406, 640.0, 1629.0, -17.700405816327685, 3.14);
INSERT INTO `bs_c02_gameobject_spawns` (`spawn_key`, `entry`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C02:GO_RENDEZVOUS:rendezvous', 4001300, 406, 869.0, 1666.0, -19.745591491613013, 3.14),
  ('BS-C02:GO_FLOWER:flower_0', 4001301, 406, 776.0, 1588.0, -29.084771086373635, 3.14),
  ('BS-C02:GO_FLOWER:flower_1', 4001301, 406, 790.0, 1580.0, -29.34597867626155, 3.14),
  ('BS-C02:GO_FLOWER:flower_2', 4001301, 406, 805.0, 1590.0, -29.113468311566045, 3.14),
  ('BS-C02:GO_FLOWER:flower_3', 4001301, 406, 782.0, 1603.0, -30.461388003833616, 3.14),
  ('BS-C02:GO_FLOWER:flower_4', 4001301, 406, 798.0, 1608.0, -30.98785616790653, 3.14),
  ('BS-C02:GO_FLOWER:flower_5', 4001301, 406, 774.0, 1620.0, -32.13109328863422, 3.14),
  ('BS-C02:GO_FLOWER:flower_6', 4001301, 406, 808.0, 1625.0, -29.32172060697105, 3.14),
  ('BS-C02:GO_FLOWER:flower_7', 4001301, 406, 790.0, 1638.0, -33.09359661220252, 3.14),
  ('BS-C02:GO_STONES:stones', 4001302, 406, 636.0, 1617.0, -16.288507813269582, 3.14),
  ('BS-C02:GO_DELIVERY:delivery', 4001303, 406, 649.0, 1626.0, -18.28848477006856, 3.14),
  ('BS-C02:GO_COURSE_START:course_start', 4001304, 406, 650.0, 1637.0, -17.694322389255138, 3.14),
  ('BS-C02:GO_CHECK_A:check_a', 4001305, 406, 657.0, 1637.0, -18.62469819803956, 3.14),
  ('BS-C02:GO_CHECK_B:check_b', 4001306, 406, 657.0, 1616.0, -19.319736655731827, 3.14),
  ('BS-C02:GO_CHECK_C:check_c', 4001307, 406, 625.0, 1616.0, -16.07512208654335, 3.14),
  ('BS-C02:GO_CHECK_D:check_d', 4001308, 406, 625.0, 1635.0, -16.688717955318157, 3.14),
  ('BS-C02:GO_DOG_A:dog_a', 4001309, 406, 647.0, 1636.0, -17.6551893140392, 3.14),
  ('BS-C02:GO_DOG_B:dog_b', 4001310, 406, 640.0, 1640.0, -17.79996144855941, 3.14),
  ('BS-C02:GO_DOG_C:dog_c', 4001311, 406, 628.0, 1638.0, -17.53937160642281, 3.14),
  ('BS-C02:GO_COMMUNIQUE:communique', 4001312, 406, 632.0, 1626.0, -17.55953349355738, 3.14),
  ('BS-C02:GO_PLANS:plans', 4001313, 406, 895.0, 1687.0, -19.327736714629424, 3.14),
  ('BS-C02:GO_DROP:drop', 4001314, 406, 1089.0, 1537.0, 24.93897951494475, 3.14),
  ('BS-C02:GO_DISCORD:discord', 4001315, 406, 883.0, 1675.0, -19.740699647798067, 3.14),
  ('BS-C02:GO_GARNOTH:garnoth', 4001316, 406, 654.0, 1624.0, -17.974739597444334, 3.14),
  ('BS-C02:GO_OKROG:okrog', 4001317, 406, 887.0, 1677.0, -19.722322180493663, 3.14),
  ('BS-C02:GO_PODIUM:podium', 4001318, 406, 895.0, 1675.0, -19.593739876628337, 3.14),
  ('BS-C02:GO_PRISON:prison', 4001319, 406, 895.0, 1682.0, -18.985879877982, 3.14),
  ('BS-C02:GO_BUYERS:buyers', 4001320, 406, 894.0, 1688.0, -19.284569940365806, 3.14),
  ('BS-C02:GO_TERRITORY:horrorguard_0', 4001321, 406, 887.0, 1677.0, -19.176529574765752, 3.14);
SET @BS_C02_ENTRY_COLUMN := (
  SELECT `COLUMN_NAME` FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'creature' AND `COLUMN_NAME` IN ('id1', 'id')
  ORDER BY `COLUMN_NAME` DESC LIMIT 1
);
SET @BS_C02_INSERT := CONCAT(
  'INSERT INTO `creature` (`', @BS_C02_ENTRY_COLUMN, '`, `map`, `zoneId`, `spawnMask`, `phaseMask`, ',
  '`position_x`, `position_y`, `position_z`, `orientation`, `equipment_id`, `spawntimesecs`, `curhealth`, `curmana`, `Comment`) ',
  'SELECT s.`entry`, 1, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, -1, 60, 0, 0, s.`spawn_key` ',
  'FROM `bs_c02_creature_spawns` s LEFT JOIN `creature` c ON c.`Comment` = s.`spawn_key` WHERE c.`guid` IS NULL'
);
PREPARE bs_c02_stmt FROM @BS_C02_INSERT;
EXECUTE bs_c02_stmt;
DEALLOCATE PREPARE bs_c02_stmt;
SET @BS_C02_UPDATE := CONCAT(
  'UPDATE `creature` c INNER JOIN `bs_c02_creature_spawns` s ON c.`Comment` = s.`spawn_key` ',
  'SET c.`', @BS_C02_ENTRY_COLUMN, '` = s.`entry`, c.`zoneId` = s.`zone`, c.`position_x` = s.`x`, ',
  'c.`position_y` = s.`y`, c.`position_z` = s.`z`, c.`orientation` = s.`o`, c.`equipment_id` = -1'
);
PREPARE bs_c02_stmt FROM @BS_C02_UPDATE;
EXECUTE bs_c02_stmt;
DEALLOCATE PREPARE bs_c02_stmt;
INSERT INTO `gameobject`
  (`id`, `map`, `zoneId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`,
   `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`)
SELECT s.`entry`, 1, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, SIN(s.`o` / 2), COS(s.`o` / 2), 60, 100, 1, s.`spawn_key`
FROM `bs_c02_gameobject_spawns` s LEFT JOIN `gameobject` g ON g.`Comment` = s.`spawn_key` WHERE g.`guid` IS NULL;
UPDATE `gameobject` g INNER JOIN `bs_c02_gameobject_spawns` s ON g.`Comment` = s.`spawn_key`
SET g.`id` = s.`entry`, g.`position_x` = s.`x`, g.`position_y` = s.`y`, g.`position_z` = s.`z`, g.`orientation` = s.`o`,
  g.`rotation2` = SIN(s.`o` / 2), g.`rotation3` = COS(s.`o` / 2);
-- Retire obsolete owned campaign placements; surviving spawn keys keep their GUIDs.
SET @BS_C02_PRUNE := CONCAT(
  'DELETE c FROM `creature` c LEFT JOIN `bs_c02_creature_spawns` s ON s.`spawn_key`=c.`Comment` ',
  'INNER JOIN `mod_customnpcs_bs_content` owner ON owner.`kind`=\'creature\' AND owner.`entry`=c.`',@BS_C02_ENTRY_COLUMN,'` AND owner.`chapter`=2 ',
  'WHERE c.`Comment` LIKE \'BS-C02:%\' AND s.`spawn_key` IS NULL'
);
PREPARE bs_c02_stmt FROM @BS_C02_PRUNE;
EXECUTE bs_c02_stmt;
DEALLOCATE PREPARE bs_c02_stmt;
DELETE g FROM `gameobject` g LEFT JOIN `bs_c02_gameobject_spawns` s ON s.`spawn_key`=g.`Comment`
INNER JOIN `mod_customnpcs_bs_content` owner ON owner.`kind`='gameobject' AND owner.`entry`=g.`id` AND owner.`chapter`=2
WHERE g.`Comment` LIKE 'BS-C02:%' AND s.`spawn_key` IS NULL;
DROP TEMPORARY TABLE `bs_c02_creature_spawns`;
DROP TEMPORARY TABLE `bs_c02_gameobject_spawns`;
DROP TEMPORARY TABLE `bs_c02_ids`;
-- Upgrade older Chapter 1 installs without replacing their SmartAI combat rows or template stats.
UPDATE `creature_template` c INNER JOIN `mod_customnpcs_bs_content` o
  ON o.`kind` = 'creature' AND o.`entry` = c.`entry` AND o.`chapter` = 1
SET c.`AIName` = '', c.`ScriptName` = 'npc_bs_c01_cult'
WHERE c.`entry` IN (4001010, 4001011);
COMMIT;
