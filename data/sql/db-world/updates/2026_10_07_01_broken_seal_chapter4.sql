-- The Broken Seal, Chapter 4: The Village That Gave Up (levels 35-40).
-- Generated from data/quests/broken_seal_chapter4.json. Native 3.3.5a assets only.
-- Requires Chapters 1-3, custom_npc_appearances.sql and the rebuilt module.
-- Reapplication preserves GUIDs. Occupied IDs and missing Chapter 3 reject before content DML.
-- See docs/broken-seal/chapter4-implementation.md.
CREATE TABLE IF NOT EXISTS `mod_customnpcs_bs_content` (
  `kind` VARCHAR(16) NOT NULL,
  `entry` INT UNSIGNED NOT NULL,
  `chapter` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_c04_ids`;
CREATE TEMPORARY TABLE `bs_c04_ids` (
  `kind` VARCHAR(16) NOT NULL, `entry` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`, `entry`)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c04_ids` (`kind`, `entry`) VALUES
  ('creature', 4001600),
  ('creature', 4001601),
  ('creature', 4001602),
  ('creature', 4001603),
  ('creature', 4001604),
  ('creature', 4001605),
  ('creature', 4001606),
  ('creature', 4001607),
  ('creature', 4001608),
  ('creature', 4001609),
  ('creature', 4001610),
  ('creature', 4001611),
  ('creature', 4001612),
  ('creature', 4001613),
  ('creature', 4001614),
  ('creature', 4001615),
  ('creature', 4001616),
  ('creature', 4001617),
  ('creature', 4001618),
  ('creature', 4001619),
  ('creature', 4001650),
  ('creature', 4001651),
  ('creature', 4001652),
  ('creature', 4001653),
  ('creature', 4001654),
  ('creature', 4001655),
  ('creature', 4001656),
  ('creature', 4001657),
  ('creature', 4001658),
  ('creature', 4001659),
  ('creature', 4001660),
  ('creature', 4001661),
  ('creature', 4001662),
  ('creature', 4001663),
  ('creature', 4001664),
  ('creature', 4001665),
  ('creature', 4001666),
  ('creature', 4001667),
  ('creature', 4001668),
  ('creature', 4001669),
  ('gameobject', 4001700),
  ('gameobject', 4001701),
  ('gameobject', 4001702),
  ('gameobject', 4001703),
  ('gameobject', 4001704),
  ('gameobject', 4001705),
  ('gameobject', 4001706),
  ('gameobject', 4001707),
  ('gameobject', 4001708),
  ('quest', 900400),
  ('quest', 900401),
  ('quest', 900402),
  ('quest', 900403),
  ('quest', 900404),
  ('quest', 900405),
  ('quest', 900406),
  ('quest', 900407),
  ('quest', 900408),
  ('quest', 900409),
  ('quest', 900410),
  ('quest', 900411),
  ('item', 900400),
  ('item', 900401),
  ('item', 900402),
  ('item', 900403),
  ('item', 900404),
  ('item', 900405),
  ('item', 900406),
  ('item', 900410),
  ('item', 900411),
  ('item', 900412),
  ('item', 900413),
  ('item', 900414),
  ('item', 900415),
  ('outfit', 4001601),
  ('outfit', 4001602),
  ('outfit', 4001603),
  ('outfit', 4001604),
  ('outfit', 4001605),
  ('outfit', 4001606),
  ('outfit', 4001607),
  ('outfit', 4001608),
  ('outfit', 4001609),
  ('outfit', 4001610),
  ('outfit', 4001611),
  ('outfit', 4001612),
  ('outfit', 4001613),
  ('outfit_entry', 4001600),
  ('outfit_entry', 4001601),
  ('outfit_entry', 4001602),
  ('outfit_entry', 4001603),
  ('outfit_entry', 4001604),
  ('outfit_entry', 4001605),
  ('outfit_entry', 4001606),
  ('outfit_entry', 4001607),
  ('outfit_entry', 4001608),
  ('outfit_entry', 4001609),
  ('outfit_entry', 4001610),
  ('outfit_entry', 4001611),
  ('outfit_entry', 4001612),
  ('outfit_entry', 4001613),
  ('outfit_entry', 4001614),
  ('outfit_entry', 4001615),
  ('outfit_entry', 4001616),
  ('outfit_entry', 4001617),
  ('outfit_entry', 4001618),
  ('outfit_entry', 4001619),
  ('npc_text', 4001600),
  ('npc_text', 4001601),
  ('npc_text', 4001602),
  ('npc_text', 4001603),
  ('npc_text', 4001604),
  ('npc_text', 4001605),
  ('npc_text', 4001606),
  ('npc_text', 4001607),
  ('npc_text', 4001608),
  ('npc_text', 4001609),
  ('npc_text', 4001610),
  ('npc_text', 4001611),
  ('npc_text', 4001612),
  ('gossip_menu', 4001600),
  ('gossip_menu', 4001601),
  ('gossip_menu', 4001602),
  ('gossip_menu', 4001603),
  ('gossip_menu', 4001604),
  ('gossip_menu', 4001605),
  ('gossip_menu', 4001606),
  ('gossip_menu', 4001607),
  ('gossip_menu', 4001608),
  ('gossip_menu', 4001609),
  ('gossip_menu', 4001610),
  ('gossip_menu', 4001611),
  ('gossip_menu', 4001612),
  ('npc_text', 4001670),
  ('npc_text', 4001671),
  ('gossip_menu', 4001670),
  ('gossip_menu', 4001671);
DROP TEMPORARY TABLE IF EXISTS `bs_c04_collision_guard`;
CREATE TEMPORARY TABLE `bs_c04_collision_guard` (`id` TINYINT PRIMARY KEY);
INSERT INTO `bs_c04_collision_guard` VALUES (1);
-- Intentional duplicate-key error if the shared Chapter 3 handoff is absent or unowned.
INSERT INTO `bs_c04_collision_guard`
SELECT 1 WHERE (SELECT COUNT(*) FROM `mod_customnpcs_bs_content`
  WHERE `chapter` = 3 AND ((`kind` = 'creature' AND `entry` = 4001405)
  OR (`kind` = 'quest' AND `entry` = 900311))) <> 2
  OR NOT EXISTS (SELECT 1 FROM `quest_template` WHERE `ID` = 900311)
  OR NOT EXISTS (SELECT 1 FROM `creature_template` WHERE `entry` = 4001405);
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `creature_template` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'creature' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `gameobject_template` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'gameobject' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `quest_template` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'quest' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `item_template` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'item' AND r.`entry` = t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `mod_customnpcs_outfit` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'outfit' AND r.`entry` = t.`outfit_id`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `mod_customnpcs_outfit_entry` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'outfit_entry' AND r.`entry` = t.`creature_entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `npc_text` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'npc_text' AND r.`entry` = t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_c04_collision_guard`
SELECT 1 FROM `gossip_menu` t INNER JOIN `bs_c04_ids` r ON r.`kind` = 'gossip_menu' AND r.`entry` = t.`MenuID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind` = r.`kind` AND o.`entry` = r.`entry` AND o.`chapter` = 4
WHERE o.`entry` IS NULL LIMIT 1;
DROP TEMPORARY TABLE `bs_c04_collision_guard`;
START TRANSACTION;
INSERT INTO `mod_customnpcs_bs_content` (`kind`, `entry`, `chapter`)
SELECT `kind`, `entry`, 4 FROM `bs_c04_ids` ON DUPLICATE KEY UPDATE `chapter` = VALUES(`chapter`);
INSERT INTO `creature_template` (`entry`, `name`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `unit_class`, `unit_flags`, `type`, `AIName`, `ScriptName`, `HealthModifier`, `DamageModifier`, `ExperienceModifier`, `lootid`, `flags_extra`) VALUES
  (4001600, 'Ken-Ken', 40, 40, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001601, 'Yi-Mo Longbrow', 40, 40, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001602, 'Kang Bramblestaff', 40, 40, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001603, 'Maruut Stonebinder', 40, 40, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001604, 'Iain Firebeard', 40, 40, 0, 35, 3, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001605, 'Village Provisioner', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001606, 'Village Herbalist', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001607, 'Village Toolkeeper', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001608, 'Village Cook', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001609, 'Village Laborer', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001610, 'Village Wardkeeper', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001611, 'Village Tailor', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001612, 'Village Scout', 40, 40, 0, 35, 1, 1, 770, 7, '', 'npc_bs_c04_contact', 1, 1, 0, 0, 2),
  (4001613, 'Yi-Mo Longbrow', 40, 40, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c04_actor', 1, 1, 0, 0, 2),
  (4001614, 'Ken-Ken', 40, 40, 0, 35, 0, 1, 770, 7, '', 'npc_bs_c04_actor', 1, 1, 0, 0, 2),
  (4001615, 'Village recovery', 40, 40, 0, 35, 0, 1, 33555202, 10, '', 'npc_bs_c04_scene', 1, 1, 0, 0, 2),
  (4001616, 'Marsh Stalker', 38, 38, 0, 14, 0, 1, 0, 1, '', 'npc_bs_c04_enemy', 1, 1, 0, 0, 0),
  (4001617, 'Essence of Despair', 38, 38, 0, 14, 0, 1, 0, 10, '', 'npc_bs_c04_enemy', 1, 1, 0, 0, 0),
  (4001618, 'Quintessence of Despair', 38, 38, 0, 14, 0, 1, 0, 10, '', 'npc_bs_c04_enemy', 2.5, 0.8, 0, 0, 0),
  (4001619, 'Relit village hearth', 1, 1, 0, 35, 0, 1, 33555202, 10, '', 'npc_bs_c04_flame', 1, 1, 0, 0, 2),
  (4001650, 'Inspect', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001651, 'Question A', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001652, 'Question B', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001653, 'Question C', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001654, 'Escort', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001655, 'Cheer', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001656, 'Herbs', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001657, 'Test A', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001658, 'Test B', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001659, 'Test C', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001660, 'Treated', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001661, 'Well', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001662, 'Essences', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001663, 'Yimo', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001664, 'Boss', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001665, 'Hearth A', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001666, 'Hearth B', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001667, 'Hearth C', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001668, 'Services', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2),
  (4001669, 'Liaison', 1, 1, 0, 35, 0, 1, 33555202, 10, 'NullCreatureAI', '', 1, 1, 0, 0, 2)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `exp` = VALUES(`exp`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `AIName` = VALUES(`AIName`), `ScriptName` = VALUES(`ScriptName`), `HealthModifier` = VALUES(`HealthModifier`), `DamageModifier` = VALUES(`DamageModifier`), `ExperienceModifier` = VALUES(`ExperienceModifier`), `lootid` = VALUES(`lootid`), `flags_extra` = VALUES(`flags_extra`);
DELETE FROM `creature_template_model` WHERE `CreatureID` IN (4001600, 4001601, 4001602, 4001603, 4001604, 4001605, 4001606, 4001607, 4001608, 4001609, 4001610, 4001611, 4001612, 4001613, 4001614, 4001615, 4001616, 4001617, 4001618, 4001619, 4001650, 4001651, 4001652, 4001653, 4001654, 4001655, 4001656, 4001657, 4001658, 4001659, 4001660, 4001661, 4001662, 4001663, 4001664, 4001665, 4001666, 4001667, 4001668, 4001669);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
  (4001600, 0, 843, 1, 1),
  (4001601, 0, 3406, 1, 1),
  (4001602, 0, 3406, 1, 1),
  (4001603, 0, 3770, 1, 1),
  (4001604, 0, 3406, 1, 1),
  (4001605, 0, 3406, 1, 1),
  (4001606, 0, 2585, 1, 1),
  (4001607, 0, 3406, 1, 1),
  (4001608, 0, 2585, 1, 1),
  (4001609, 0, 3406, 1, 1),
  (4001610, 0, 2585, 1, 1),
  (4001611, 0, 3406, 1, 1),
  (4001612, 0, 2585, 1, 1),
  (4001613, 0, 3406, 1, 1),
  (4001614, 0, 843, 1, 1),
  (4001615, 0, 11686, 1, 1),
  (4001616, 0, 545, 1, 1),
  (4001617, 0, 19110, 1, 1),
  (4001618, 0, 19110, 1.8, 1),
  (4001619, 0, 27626, 0.5, 1),
  (4001650, 0, 11686, 1, 1),
  (4001651, 0, 11686, 1, 1),
  (4001652, 0, 11686, 1, 1),
  (4001653, 0, 11686, 1, 1),
  (4001654, 0, 11686, 1, 1),
  (4001655, 0, 11686, 1, 1),
  (4001656, 0, 11686, 1, 1),
  (4001657, 0, 11686, 1, 1),
  (4001658, 0, 11686, 1, 1),
  (4001659, 0, 11686, 1, 1),
  (4001660, 0, 11686, 1, 1),
  (4001661, 0, 11686, 1, 1),
  (4001662, 0, 11686, 1, 1),
  (4001663, 0, 11686, 1, 1),
  (4001664, 0, 11686, 1, 1),
  (4001665, 0, 11686, 1, 1),
  (4001666, 0, 11686, 1, 1),
  (4001667, 0, 11686, 1, 1),
  (4001668, 0, 11686, 1, 1),
  (4001669, 0, 11686, 1, 1);
INSERT INTO `mod_customnpcs_outfit` (`outfit_id`, `race`, `gender`, `class`, `skin`, `face`, `hair`, `hair_color`, `facial_hair`, `chest`, `shoulders`, `shirt`, `waist`, `legs`, `feet`, `hands`, `mainhand`, `ranged`) VALUES
  (4001601, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001602, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 6570, 6568, 0, 14089, 4575, 0),
  (4001603, 6, 0, 1, 0, 0, 0, 0, 0, 6569, 0, 0, 6570, 6568, 0, 14089, 6631, 0),
  (4001604, 3, 0, 1, 0, 0, 0, 0, 0, 6085, 0, 0, 0, 6596, 6573, 14089, 12282, 0),
  (4001605, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001606, 3, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001607, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001608, 3, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001609, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001610, 3, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001611, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001612, 3, 1, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0),
  (4001613, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 0, 0, 0, 6568, 2315, 14089, 0, 0)
ON DUPLICATE KEY UPDATE
  `race` = VALUES(`race`), `gender` = VALUES(`gender`), `class` = VALUES(`class`), `skin` = VALUES(`skin`), `face` = VALUES(`face`), `hair` = VALUES(`hair`), `hair_color` = VALUES(`hair_color`), `facial_hair` = VALUES(`facial_hair`), `chest` = VALUES(`chest`), `shoulders` = VALUES(`shoulders`), `shirt` = VALUES(`shirt`), `waist` = VALUES(`waist`), `legs` = VALUES(`legs`), `feet` = VALUES(`feet`), `hands` = VALUES(`hands`), `mainhand` = VALUES(`mainhand`), `ranged` = VALUES(`ranged`);
INSERT INTO `mod_customnpcs_outfit_entry` (`creature_entry`, `outfit_id`) VALUES
  (4001601, 4001601),
  (4001602, 4001602),
  (4001603, 4001603),
  (4001604, 4001604),
  (4001605, 4001605),
  (4001606, 4001606),
  (4001607, 4001607),
  (4001608, 4001608),
  (4001609, 4001609),
  (4001610, 4001610),
  (4001611, 4001611),
  (4001612, 4001612),
  (4001613, 4001613)
ON DUPLICATE KEY UPDATE
  `outfit_id` = VALUES(`outfit_id`);
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`) VALUES
  (4001602, 1, 4575, 0, 0),
  (4001603, 1, 6631, 0, 0),
  (4001604, 1, 12282, 0, 0)
ON DUPLICATE KEY UPDATE
  `ItemID1` = VALUES(`ItemID1`), `ItemID2` = VALUES(`ItemID2`), `ItemID3` = VALUES(`ItemID3`);
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `bonding`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `description`, `spellid_1`, `spelltrigger_1`, `ScriptName`) VALUES
  (900400, 12, 0, 'Damaged Ward Rubbing', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900401, 12, 0, 'Village Food Supplies', 6399, 1, 0, -1, -1, 1, 0, 6, 6, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900402, 12, 0, 'Prepared Herbal Medicine', 2885, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900403, 12, 0, 'Ken-Ken''s Treatment Mask', 41842, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Village That Gave Up', 34665, 0, 'item_bs_c04_mask'),
  (900404, 12, 0, 'Despair Residue Sample', 18084, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900405, 12, 0, 'Village Pledge of Aid', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900406, 12, 0, 'Letter of Introduction to the Wildhammer', 18098, 1, 0, -1, -1, 1, 0, 1, 1, 4, 0, 0, 0, 0, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900410, 4, 0, 'The Village That Gave Up: Signet of Might', 9846, 2, 11, -1, -1, 40, 35, 1, 1, 1, 4, 8, 7, 7, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900411, 4, 0, 'The Village That Gave Up: Signet of Precision', 9846, 2, 11, -1, -1, 40, 35, 1, 1, 1, 3, 8, 7, 7, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900412, 4, 0, 'The Village That Gave Up: Signet of Sorcery', 9846, 2, 11, -1, -1, 40, 35, 1, 1, 1, 5, 8, 45, 10, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900413, 4, 0, 'The Village That Gave Up: Signet of Restoration', 9846, 2, 11, -1, -1, 40, 35, 1, 1, 1, 6, 8, 43, 4, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900414, 4, 0, 'The Village That Gave Up: Signet of Guarding', 9846, 2, 11, -1, -1, 40, 35, 1, 1, 1, 7, 9, 12, 7, 0, 0, 'The Broken Seal: The Village That Gave Up', 0, 0, ''),
  (900415, 4, 0, 'The Village That Gave Up: Signet of Balance', 9846, 2, 11, -1, -1, 40, 35, 1, 1, 1, 5, 7, 6, 7, 7, 6, 'The Broken Seal: The Village That Gave Up', 0, 0, '')
ON DUPLICATE KEY UPDATE
  `class` = VALUES(`class`), `subclass` = VALUES(`subclass`), `name` = VALUES(`name`), `displayid` = VALUES(`displayid`), `Quality` = VALUES(`Quality`), `InventoryType` = VALUES(`InventoryType`), `AllowableClass` = VALUES(`AllowableClass`), `AllowableRace` = VALUES(`AllowableRace`), `ItemLevel` = VALUES(`ItemLevel`), `RequiredLevel` = VALUES(`RequiredLevel`), `maxcount` = VALUES(`maxcount`), `stackable` = VALUES(`stackable`), `bonding` = VALUES(`bonding`), `stat_type1` = VALUES(`stat_type1`), `stat_value1` = VALUES(`stat_value1`), `stat_type2` = VALUES(`stat_type2`), `stat_value2` = VALUES(`stat_value2`), `stat_type3` = VALUES(`stat_type3`), `stat_value3` = VALUES(`stat_value3`), `description` = VALUES(`description`), `spellid_1` = VALUES(`spellid_1`), `spelltrigger_1` = VALUES(`spelltrigger_1`), `ScriptName` = VALUES(`ScriptName`);
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `RewardXPDifficulty`, `RewardMoney`, `StartItem`, `Flags`, `AllowableRaces`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`, `RequiredNpcOrGo3`, `RequiredNpcOrGo4`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGoCount4`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`, `RequiredItemId1`, `RequiredItemId2`, `RequiredItemId3`, `RequiredItemId4`, `RequiredItemId5`, `RequiredItemId6`, `RequiredItemCount1`, `RequiredItemCount2`, `RequiredItemCount3`, `RequiredItemCount4`, `RequiredItemCount5`, `RequiredItemCount6`, `RewardChoiceItemID1`, `RewardChoiceItemID2`, `RewardChoiceItemID3`, `RewardChoiceItemID4`, `RewardChoiceItemID5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity1`, `RewardChoiceItemQuantity2`, `RewardChoiceItemQuantity3`, `RewardChoiceItemQuantity4`, `RewardChoiceItemQuantity5`, `RewardChoiceItemQuantity6`, `RewardItem1`, `RewardItem2`, `RewardItem3`, `RewardItem4`, `RewardAmount1`, `RewardAmount2`, `RewardAmount3`, `RewardAmount4`) VALUES
  (900400, 2, 35, 35, 15, 5, 7000, 0, 0, 0, 'Ken-Ken', 'Find Ken-Ken and inspect the village together.', 'Kang''s letter brought you to our relief station. The families here have food and shelter, but they have stopped caring for themselves. Ken-Ken is helping at the southern camp. Ask him to show you what has happened.', 'Find Ken-Ken and inspect the village together.', 4001650, 0, 0, 0, 1, 0, 0, 0, 'Village inspected with Ken-Ken', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900401, 2, 35, 35, 15, 5, 7500, 0, 0, 0, 'What''s Eating the Village?', 'Gather 6 safe food supplies and question 3 despondent residents.', 'We must rule out hunger first. Take six sound food bundles from the marked village crate, then hear the troubles of the village provisioner, herbalist and toolkeeper. Each has something different to tell us.', 'Gather 6 safe food supplies and question 3 despondent residents.', 4001651, 4001652, 4001653, 0, 1, 1, 1, 0, 'Village Provisioner questioned', 'Village Herbalist questioned', 'Village Toolkeeper questioned', '', 900401, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900402, 2, 35, 35, 15, 5, 8000, 0, 0, 0, 'Finding Yi-Mo', 'Find Yi-Mo at the marked marsh trail and escort him away from the predators.', 'Yi-Mo has wandered down the marsh trail alone. Read the marked trail sign southeast of the village to find him. Stay beside him, protect him from the stalker, and lead him back through the marked path.', 'Find Yi-Mo at the marked marsh trail and escort him away from the predators.', 4001654, 0, 0, 0, 1, 0, 0, 0, 'Yi-Mo escorted to safety', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900403, 2, 36, 35, 15, 5, 8500, 0, 0, 0, 'Cheer Up, Yi-Mo', 'Recover Yi-Mos lost supplies and persuade him to return to the village.', 'You found me. I do not know why you bothered. My supplies are still beside that trail. Bring back three bundles and talk to me again; perhaps there is still a reason to return to my neighbors.', 'Recover Yi-Mos lost supplies and persuade him to return to the village.', 4001655, 0, 0, 0, 1, 0, 0, 0, 'Yi-Mo persuaded to return', '', '', '', 900401, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900404, 2, 36, 35, 15, 5, 9000, 0, 0, 0, 'Materia Medica', 'Gather 8 local herbs and prepare medicine with Kang.', 'Both the families and Yi-Mo need our help. Gather eight fresh herb sprigs from the marked patches south of camp. Bring them to Kang by his cooking hearth and ask him to prepare the medicine.', 'Gather 8 local herbs and prepare medicine with Kang.', 4001656, 0, 0, 0, 8, 0, 0, 0, 'Medicinal herbs gathered', '', '', '', 900402, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900405, 2, 37, 35, 15, 5, 9500, 900403, 0, 0, 'Why So Serious?', 'Use the supplied treatment mask to test 3 residents and identify the shared residue.', 'Ken-Ken made a mask with Kang''s medicine. Test it on the provisioner, herbalist and toolkeeper. The mask draws out a dark residue. Once all three have been tested, return to Ken-Ken for a sample bottle.', 'Use the supplied treatment mask to test 3 residents and identify the shared residue.', 4001657, 4001658, 4001659, 0, 1, 1, 1, 0, 'Village Provisioner tested', 'Village Herbalist tested', 'Village Toolkeeper tested', '', 900404, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900406, 2, 37, 35, 15, 5, 10000, 900403, 0, 0, 'Apply Directly to the Forehead', 'Treat 8 villagers with the mask and defeat the released lesser manifestations.', 'There are eight people still trapped in this gloom. Use the mask on the next untreated villager, then defeat the despair it releases. Work through the round in the order Ken-Ken shows you. You can ask him to resume whenever you need.', 'Treat 8 villagers with the mask and defeat the released lesser manifestations.', 4001660, 0, 0, 0, 8, 0, 0, 0, 'Villagers freed from despair', '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900407, 2, 38, 35, 15, 5, 10500, 0, 0, 0, 'The Well Beneath the Ward', 'Sample the old ward by the well and confirm where the influence gathers.', 'The old well southeast of the village lies below a damaged ward. Inspect the well first, then take a rubbing of the ward beside it. Bring it to me before touching Yi-Mo with the mask again.', 'Sample the old ward by the well and confirm where the influence gathers.', 4001661, 0, 0, 0, 1, 0, 0, 0, 'Old well inspected', '', '', '', 900400, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900408, 2, 38, 35, 15, 5, 11000, 900403, 0, 0, 'Zhu''s Despair', 'Defeat 8 lesser manifestations, treat Yi-Mo, then defeat the Quintessence of Despair with Ken-Kens help.', 'The broken ward has gathered the village''s despair around Yi-Mo. Meet Ken-Ken at the well southeast of camp and use the well to begin the confrontation. Defeat eight lesser manifestations there, use the mask on Yi-Mo, and defeat the Quintessence it releases. Ken-Ken will stand beside you.', 'Defeat 8 lesser manifestations, treat Yi-Mo, then defeat the Quintessence of Despair with Ken-Kens help.', 4001662, 4001663, 4001664, 0, 8, 1, 1, 0, 'Lesser manifestations defeated', 'Yi-Mo treated at the well', 'Quintessence of Despair defeated', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900409, 2, 39, 35, 15, 5, 11500, 0, 0, 0, 'Hands Back to Work', 'Relight 3 hearths and help 3 recovered villagers restart the village services.', 'The curse is broken; now we rebuild. Light the three marked household hearths and help the first three residents resume their food, medicine and equipment services. Each family needs a different hand.', 'Relight 3 hearths and help 3 recovered villagers restart the village services.', 4001665, 4001666, 4001667, 4001668, 1, 1, 1, 3, 'Household hearth 1 relit', 'Household hearth 2 relit', 'Household hearth 3 relit', 'Village services restarted', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900410, 2, 39, 35, 15, 5, 12000, 0, 0, 0, 'When You Need Us', 'Accept the villages pledge of aid and nominate Mei as its future supply liaison.', 'You stayed when we could not help ourselves. Let me put the village''s promise in writing. Ask Mei to become our supply liaison, then return to me to accept our pledge.', 'Accept the villages pledge of aid and nominate Mei as its future supply liaison.', 4001669, 0, 0, 0, 1, 0, 0, 0, 'Mei named supply liaison', '', '', '', 900405, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (900411, 2, 40, 35, 47, 5, 12500, 900406, 0, 0, 'The Families in the Hills', 'Deliver the Wildhammer introduction letter to Iain at the neutral Hinterlands gathering.', 'The ward rubbing points toward the hills of the Eastern Kingdoms. Iain Firebeard has agreed to receive travelers from both factions at a neutral gathering outside Aerie Peak. Carry this letter to him in the western Hinterlands; you need not enter Aerie Peak itself.', 'Deliver the Wildhammer introduction letter to Iain at the neutral Hinterlands gathering.', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 900406, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 900410, 900411, 900412, 900413, 900414, 900415, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE
  `QuestType` = VALUES(`QuestType`), `QuestLevel` = VALUES(`QuestLevel`), `MinLevel` = VALUES(`MinLevel`), `QuestSortID` = VALUES(`QuestSortID`), `RewardXPDifficulty` = VALUES(`RewardXPDifficulty`), `RewardMoney` = VALUES(`RewardMoney`), `StartItem` = VALUES(`StartItem`), `Flags` = VALUES(`Flags`), `AllowableRaces` = VALUES(`AllowableRaces`), `LogTitle` = VALUES(`LogTitle`), `LogDescription` = VALUES(`LogDescription`), `QuestDescription` = VALUES(`QuestDescription`), `QuestCompletionLog` = VALUES(`QuestCompletionLog`), `RequiredNpcOrGo1` = VALUES(`RequiredNpcOrGo1`), `RequiredNpcOrGo2` = VALUES(`RequiredNpcOrGo2`), `RequiredNpcOrGo3` = VALUES(`RequiredNpcOrGo3`), `RequiredNpcOrGo4` = VALUES(`RequiredNpcOrGo4`), `RequiredNpcOrGoCount1` = VALUES(`RequiredNpcOrGoCount1`), `RequiredNpcOrGoCount2` = VALUES(`RequiredNpcOrGoCount2`), `RequiredNpcOrGoCount3` = VALUES(`RequiredNpcOrGoCount3`), `RequiredNpcOrGoCount4` = VALUES(`RequiredNpcOrGoCount4`), `ObjectiveText1` = VALUES(`ObjectiveText1`), `ObjectiveText2` = VALUES(`ObjectiveText2`), `ObjectiveText3` = VALUES(`ObjectiveText3`), `ObjectiveText4` = VALUES(`ObjectiveText4`), `RequiredItemId1` = VALUES(`RequiredItemId1`), `RequiredItemId2` = VALUES(`RequiredItemId2`), `RequiredItemId3` = VALUES(`RequiredItemId3`), `RequiredItemId4` = VALUES(`RequiredItemId4`), `RequiredItemId5` = VALUES(`RequiredItemId5`), `RequiredItemId6` = VALUES(`RequiredItemId6`), `RequiredItemCount1` = VALUES(`RequiredItemCount1`), `RequiredItemCount2` = VALUES(`RequiredItemCount2`), `RequiredItemCount3` = VALUES(`RequiredItemCount3`), `RequiredItemCount4` = VALUES(`RequiredItemCount4`), `RequiredItemCount5` = VALUES(`RequiredItemCount5`), `RequiredItemCount6` = VALUES(`RequiredItemCount6`), `RewardChoiceItemID1` = VALUES(`RewardChoiceItemID1`), `RewardChoiceItemID2` = VALUES(`RewardChoiceItemID2`), `RewardChoiceItemID3` = VALUES(`RewardChoiceItemID3`), `RewardChoiceItemID4` = VALUES(`RewardChoiceItemID4`), `RewardChoiceItemID5` = VALUES(`RewardChoiceItemID5`), `RewardChoiceItemID6` = VALUES(`RewardChoiceItemID6`), `RewardChoiceItemQuantity1` = VALUES(`RewardChoiceItemQuantity1`), `RewardChoiceItemQuantity2` = VALUES(`RewardChoiceItemQuantity2`), `RewardChoiceItemQuantity3` = VALUES(`RewardChoiceItemQuantity3`), `RewardChoiceItemQuantity4` = VALUES(`RewardChoiceItemQuantity4`), `RewardChoiceItemQuantity5` = VALUES(`RewardChoiceItemQuantity5`), `RewardChoiceItemQuantity6` = VALUES(`RewardChoiceItemQuantity6`), `RewardItem1` = VALUES(`RewardItem1`), `RewardItem2` = VALUES(`RewardItem2`), `RewardItem3` = VALUES(`RewardItem3`), `RewardItem4` = VALUES(`RewardItem4`), `RewardAmount1` = VALUES(`RewardAmount1`), `RewardAmount2` = VALUES(`RewardAmount2`), `RewardAmount3` = VALUES(`RewardAmount3`), `RewardAmount4` = VALUES(`RewardAmount4`);
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`, `ExclusiveGroup`, `ProvidedItemCount`, `SpecialFlags`) VALUES
  (900400, 900311, 0, 0, 0, 256),
  (900401, 900400, 0, -900404, 0, 256),
  (900402, 900400, 0, 0, 0, 256),
  (900403, 900402, 0, -900404, 0, 256),
  (900404, 900401, 0, 0, 0, 256),
  (900405, 900404, 0, 0, 1, 256),
  (900406, 900405, 0, 0, 1, 256),
  (900407, 900406, 0, 0, 0, 256),
  (900408, 900407, 0, 0, 1, 256),
  (900409, 900408, 0, 0, 0, 256),
  (900410, 900409, 0, 0, 0, 256),
  (900411, 900410, 0, 0, 1, 256)
ON DUPLICATE KEY UPDATE
  `PrevQuestID` = VALUES(`PrevQuestID`), `NextQuestID` = VALUES(`NextQuestID`), `ExclusiveGroup` = VALUES(`ExclusiveGroup`), `ProvidedItemCount` = VALUES(`ProvidedItemCount`), `SpecialFlags` = VALUES(`SpecialFlags`);
DELETE FROM `creature_queststarter` WHERE `quest` IN (900400, 900401, 900402, 900403, 900404, 900405, 900406, 900407, 900408, 900409, 900410, 900411);
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
  (4001405, 900400),
  (4001600, 900401),
  (4001600, 900402),
  (4001601, 900403),
  (4001600, 900404),
  (4001600, 900405),
  (4001600, 900406),
  (4001603, 900407),
  (4001600, 900408),
  (4001405, 900409),
  (4001601, 900410),
  (4001603, 900411);
DELETE FROM `creature_questender` WHERE `quest` IN (900400, 900401, 900402, 900403, 900404, 900405, 900406, 900407, 900408, 900409, 900410, 900411);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
  (4001600, 900400),
  (4001600, 900401),
  (4001601, 900402),
  (4001600, 900403),
  (4001602, 900404),
  (4001600, 900405),
  (4001600, 900406),
  (4001603, 900407),
  (4001601, 900408),
  (4001405, 900409),
  (4001601, 900410),
  (4001604, 900411);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) VALUES
  (900400, 'These people are sick with something food alone will not mend.'),
  (900401, 'Their stories share the same emptiness. We must find Yi-Mo.'),
  (900402, 'You came all that way for me? I cannot understand it yet.'),
  (900403, 'He has returned. Now we can begin treating the village together.'),
  (900404, 'The medicine is ready. Ken-Ken''s mask will carry it into the curse.'),
  (900405, 'This residue came from every resident. It is the same influence.'),
  (900406, 'Eight people can breathe freely again. Yi-Mo is still struggling.'),
  (900407, 'The ward has been pulling despair toward the well instead of dispersing it.'),
  (900408, 'You saved me twice. My thoughts are my own again. We will repair what we neglected.'),
  (900409, 'Warm hearths, fresh medicine and working hands. The village has begun again.'),
  (900410, 'When you need seeds, supplies or defenders, remember that this village owes you aid.'),
  (900411, 'Maruut''s friends are welcome here. Rest at our table before we speak of the families.')
ON DUPLICATE KEY UPDATE
  `RewardText` = VALUES(`RewardText`);
INSERT INTO `quest_request_items` (`ID`, `CompletionText`) VALUES
  (900400, 'Find Ken-Ken and inspect the village together.'),
  (900401, 'Gather 6 safe food supplies and question 3 despondent residents.'),
  (900402, 'Find Yi-Mo at the marked marsh trail and escort him away from the predators.'),
  (900403, 'Recover Yi-Mos lost supplies and persuade him to return to the village.'),
  (900404, 'Gather 8 local herbs and prepare medicine with Kang.'),
  (900405, 'Use the supplied treatment mask to test 3 residents and identify the shared residue.'),
  (900406, 'Treat 8 villagers with the mask and defeat the released lesser manifestations.'),
  (900407, 'Sample the old ward by the well and confirm where the influence gathers.'),
  (900408, 'Defeat 8 lesser manifestations, treat Yi-Mo, then defeat the Quintessence of Despair with Ken-Kens help.'),
  (900409, 'Relight 3 hearths and help 3 recovered villagers restart the village services.'),
  (900410, 'Accept the villages pledge of aid and nominate Mei as its future supply liaison.'),
  (900411, 'Deliver the Wildhammer introduction letter to Iain at the neutral Hinterlands gathering.')
ON DUPLICATE KEY UPDATE
  `CompletionText` = VALUES(`CompletionText`);
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 19 AND `SourceEntry` IN (900400, 900401, 900402, 900403, 900404, 900405, 900406, 900407, 900408, 900409, 900410, 900411);
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceEntry`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionValue1`, `Comment`) VALUES
  (19, 900400, 0, 8, 900311, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900401, 0, 8, 900400, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900402, 0, 8, 900400, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900403, 0, 8, 900402, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900404, 0, 8, 900401, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900404, 0, 8, 900403, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900405, 0, 8, 900404, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900406, 0, 8, 900405, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900407, 0, 8, 900406, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900408, 0, 8, 900407, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900409, 0, 8, 900408, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900410, 0, 8, 900409, 'Broken Seal C04: every listed predecessor must be rewarded'),
  (19, 900411, 0, 8, 900410, 'Broken Seal C04: every listed predecessor must be rewarded');
DELETE FROM `quest_poi_points` WHERE `QuestID` IN (900400, 900401, 900402, 900403, 900404, 900405, 900406, 900407, 900408, 900409, 900410, 900411);
DELETE FROM `quest_poi` WHERE `QuestID` IN (900400, 900401, 900402, 900403, 900404, 900405, 900406, 900407, 900408, 900409, 900410, 900411);
INSERT INTO `quest_poi` (`QuestID`, `id`, `ObjectiveIndex`, `MapID`, `WorldMapAreaId`, `Floor`, `Priority`, `Flags`) VALUES
  (900400, 0, -1, 1, 141, 0, 0, 0),
  (900401, 0, -1, 1, 141, 0, 0, 0),
  (900402, 0, -1, 1, 141, 0, 0, 0),
  (900403, 0, -1, 1, 141, 0, 0, 0),
  (900404, 0, -1, 1, 141, 0, 0, 0),
  (900405, 0, -1, 1, 141, 0, 0, 0),
  (900406, 0, -1, 1, 141, 0, 0, 0),
  (900407, 0, -1, 1, 141, 0, 0, 0),
  (900408, 0, -1, 1, 141, 0, 0, 0),
  (900409, 0, -1, 1, 141, 0, 0, 0),
  (900410, 0, -1, 1, 141, 0, 0, 0),
  (900411, 0, -1, 0, 26, 0, 0, 0);
INSERT INTO `quest_poi_points` (`QuestID`, `Idx1`, `Idx2`, `X`, `Y`) VALUES
  (900400, 0, 0, -4580, -3250),
  (900401, 0, 0, -4580, -3250),
  (900402, 0, 0, -4588, -3252),
  (900403, 0, 0, -4580, -3250),
  (900404, 0, 0, -4575, -3255),
  (900405, 0, 0, -4580, -3250),
  (900406, 0, 0, -4580, -3250),
  (900407, 0, 0, -4582, -3260),
  (900408, 0, 0, -4588, -3252),
  (900409, 0, 0, -4535, -3235),
  (900410, 0, 0, -4588, -3252),
  (900411, 0, 0, 80, -2050);
INSERT INTO `npc_text` (`ID`, `text0_0`, `Probability0`) VALUES
  (4001600, 'Too many sads here. Ken-Ken has medicine, but medicine needs brave hands.', 1),
  (4001601, 'I left everything behind. Even the thought of going home feels heavy.', 1),
  (4001602, 'Bring me fresh marsh leaves. We will begin with something warm.', 1),
  (4001603, 'A damaged ward can draw fear into itself. We must find where this one is broken.', 1),
  (4001604, 'Any friend who stands by a family in hardship has a place at our gathering.', 1),
  (4001605, 'There is so much to do. I cannot seem to begin.', 1),
  (4001606, 'There is so much to do. I cannot seem to begin.', 1),
  (4001607, 'There is so much to do. I cannot seem to begin.', 1),
  (4001608, 'There is so much to do. I cannot seem to begin.', 1),
  (4001609, 'There is so much to do. I cannot seem to begin.', 1),
  (4001610, 'There is so much to do. I cannot seem to begin.', 1),
  (4001611, 'There is so much to do. I cannot seem to begin.', 1),
  (4001612, 'There is so much to do. I cannot seem to begin.', 1),
  (4001671, 'The gloom has lifted. We can tend our homes again, and the village will stand by its friends.', 1),
  (4001670, 'Ken-Ken is helping the families south of here. They have food and shelter, but something has stolen their hope.', 1)
ON DUPLICATE KEY UPDATE
  `text0_0` = VALUES(`text0_0`), `Probability0` = VALUES(`Probability0`);
DELETE FROM `gossip_menu` WHERE `MenuID` IN (4001600, 4001601, 4001602, 4001603, 4001604, 4001605, 4001606, 4001607, 4001608, 4001609, 4001610, 4001611, 4001612, 4001671, 4001670);
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
  (4001600, 4001600),
  (4001601, 4001601),
  (4001602, 4001602),
  (4001603, 4001603),
  (4001604, 4001604),
  (4001605, 4001605),
  (4001606, 4001606),
  (4001607, 4001607),
  (4001608, 4001608),
  (4001609, 4001609),
  (4001610, 4001610),
  (4001611, 4001611),
  (4001612, 4001612),
  (4001671, 4001671),
  (4001670, 4001670);
UPDATE `creature_template` SET `gossip_menu_id` = `entry` WHERE `entry` IN (4001600, 4001601, 4001602, 4001603, 4001604, 4001605, 4001606, 4001607, 4001608, 4001609, 4001610, 4001611, 4001612, 4001671, 4001670);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data3`, `Data5`, `Data18`, `ScriptName`) VALUES
  (4001700, 10, 6737, 'Yi-Mo''s Discarded Pack', 0.6, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001701, 10, 269, 'Medicinal marsh herb', 0.7, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001702, 10, 8503, 'Old village well', 0.75, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001703, 10, 235, 'Damaged village ward', 0.4, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001704, 10, 335, 'Safe village provisions', 0.8, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001705, 10, 335, 'Yi-Mo''s lost provisions', 1, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001706, 10, 199, 'Cold household hearth', 1, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001707, 10, 199, 'Cold household hearth', 1, 0, 0, 1, 'go_bs_c04_interaction'),
  (4001708, 10, 199, 'Cold household hearth', 1, 0, 0, 1, 'go_bs_c04_interaction')
ON DUPLICATE KEY UPDATE
  `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `size` = VALUES(`size`), `Data3` = VALUES(`Data3`), `Data5` = VALUES(`Data5`), `Data18` = VALUES(`Data18`), `ScriptName` = VALUES(`ScriptName`);
DROP TEMPORARY TABLE IF EXISTS `bs_c04_creature_spawns`;
CREATE TEMPORARY TABLE `bs_c04_creature_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `map` SMALLINT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_c04_gameobject_spawns`;
CREATE TEMPORARY TABLE `bs_c04_gameobject_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `map` SMALLINT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_c04_creature_spawns` (`spawn_key`, `entry`, `map`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C04:NPC_KEN:ken', 4001600, 1, 15, -4580.0, -3250.0, 33.42, 3.14),
  ('BS-C04:NPC_YIMO:yimo', 4001601, 1, 15, -4588.0, -3252.0, 32.2169, 3.14),
  ('BS-C04:NPC_KANG:kang', 4001602, 1, 15, -4575.0, -3255.0, 32.578, 3.14),
  ('BS-C04:NPC_MARUUT:maruut', 4001603, 1, 15, -4582.0, -3260.0, 32.2219, 3.14),
  ('BS-C04:NPC_IAIN:iain', 4001604, 0, 47, 80.0, -2050.0, 117.231, 3.14),
  ('BS-C04:NPC_VILLAGER_0:villager_0', 4001605, 1, 15, -4586.0, -3240.0, 35.0152, 3.14),
  ('BS-C04:NPC_VILLAGER_1:villager_1', 4001606, 1, 15, -4588.0, -3246.0, 33.4952, 3.14),
  ('BS-C04:NPC_VILLAGER_2:villager_2', 4001607, 1, 15, -4590.0, -3250.0, 32.4036, 3.14),
  ('BS-C04:NPC_VILLAGER_3:villager_3', 4001608, 1, 15, -4590.0, -3256.0, 31.0324, 3.14),
  ('BS-C04:NPC_VILLAGER_4:villager_4', 4001609, 1, 15, -4586.0, -3264.0, 31.4333, 3.14),
  ('BS-C04:NPC_VILLAGER_5:villager_5', 4001610, 1, 15, -4575.0, -3264.0, 35.1583, 3.14),
  ('BS-C04:NPC_VILLAGER_6:villager_6', 4001611, 1, 15, -4568.0, -3255.0, 33.0767, 3.14),
  ('BS-C04:NPC_VILLAGER_7:villager_7', 4001612, 1, 15, -4568.0, -3242.0, 34.083, 3.14);
INSERT INTO `bs_c04_gameobject_spawns` (`spawn_key`, `entry`, `map`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-C04:GO_TRAIL:trail', 4001700, 1, 15, -4515.0, -3300.0, 31.406462575141678, 3.14),
  ('BS-C04:GO_HERB:herb_0', 4001701, 1, 15, -4570.0, -3280.0, 35.25804768150197, 3.14),
  ('BS-C04:GO_HERB:herb_1', 4001701, 1, 15, -4578.0, -3280.0, 35.73284188816158, 3.14),
  ('BS-C04:GO_HERB:herb_2', 4001701, 1, 15, -4586.0, -3280.0, 36.67769968280612, 3.14),
  ('BS-C04:GO_HERB:herb_3', 4001701, 1, 15, -4594.0, -3280.0, 36.62206494205952, 3.14),
  ('BS-C04:GO_HERB:herb_4', 4001701, 1, 15, -4595.0, -3290.0, 37.97382257112362, 3.14),
  ('BS-C04:GO_HERB:herb_5', 4001701, 1, 15, -4585.0, -3290.0, 35.82872020185444, 3.14),
  ('BS-C04:GO_HERB:herb_6', 4001701, 1, 15, -4574.0, -3290.0, 32.85002951943496, 3.14),
  ('BS-C04:GO_HERB:herb_7', 4001701, 1, 15, -4565.0, -3290.0, 31.541513742759985, 3.14),
  ('BS-C04:GO_WELL:well', 4001702, 1, 15, -4532.0, -3324.0, 34.55830546961555, 3.14),
  ('BS-C04:GO_WARD:ward', 4001703, 1, 15, -4535.0, -3326.0, 36.631565430174355, 3.14),
  ('BS-C04:GO_SUPPLY:supply', 4001704, 1, 15, -4565.0, -3258.0, 34.19550885274701, 3.14),
  ('BS-C04:GO_LOST_SUPPLY:lost_supply', 4001705, 1, 15, -4516.57, -3301.57, 30.776066786906007, 3.14),
  ('BS-C04:GO_HEARTH_A:hearth_a', 4001706, 1, 15, -4590.0, -3260.0, 30.644549028402572, 3.14),
  ('BS-C04:GO_HEARTH_B:hearth_b', 4001707, 1, 15, -4565.0, -3245.0, 31.78189636318811, 3.14),
  ('BS-C04:GO_HEARTH_C:hearth_c', 4001708, 1, 15, -4575.0, -3259.0, 33.21154262929703, 3.14);
SET @BS_C04_ENTRY_COLUMN := (
  SELECT `COLUMN_NAME` FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'creature' AND `COLUMN_NAME` IN ('id1', 'id')
  ORDER BY `COLUMN_NAME` DESC LIMIT 1
);
SET @BS_C04_INSERT := CONCAT(
  'INSERT INTO `creature` (`', @BS_C04_ENTRY_COLUMN, '`, `map`, `zoneId`, `spawnMask`, `phaseMask`, ',
  '`position_x`, `position_y`, `position_z`, `orientation`, `equipment_id`, `spawntimesecs`, `curhealth`, `curmana`, `Comment`) ',
  'SELECT s.`entry`, s.`map`, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, -1, 60, 0, 0, s.`spawn_key` ',
  'FROM `bs_c04_creature_spawns` s LEFT JOIN `creature` c ON c.`Comment` = s.`spawn_key` WHERE c.`guid` IS NULL'
);
PREPARE bs_c04_stmt FROM @BS_C04_INSERT;
EXECUTE bs_c04_stmt;
DEALLOCATE PREPARE bs_c04_stmt;
SET @BS_C04_UPDATE := CONCAT(
  'UPDATE `creature` c INNER JOIN `bs_c04_creature_spawns` s ON c.`Comment` = s.`spawn_key` ',
  'SET c.`', @BS_C04_ENTRY_COLUMN, '` = s.`entry`, c.`map` = s.`map`, c.`zoneId` = s.`zone`, c.`position_x` = s.`x`, ',
  'c.`position_y` = s.`y`, c.`position_z` = s.`z`, c.`orientation` = s.`o`, c.`equipment_id` = -1'
);
PREPARE bs_c04_stmt FROM @BS_C04_UPDATE;
EXECUTE bs_c04_stmt;
DEALLOCATE PREPARE bs_c04_stmt;
INSERT INTO `gameobject`
  (`id`, `map`, `zoneId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`,
   `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`)
SELECT s.`entry`, s.`map`, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, SIN(s.`o` / 2), COS(s.`o` / 2), 60, 100, 1, s.`spawn_key`
FROM `bs_c04_gameobject_spawns` s LEFT JOIN `gameobject` g ON g.`Comment` = s.`spawn_key` WHERE g.`guid` IS NULL;
UPDATE `gameobject` g INNER JOIN `bs_c04_gameobject_spawns` s ON g.`Comment` = s.`spawn_key`
SET g.`id` = s.`entry`, g.`map`=s.`map`, g.`zoneId`=s.`zone`, g.`position_x` = s.`x`, g.`position_y` = s.`y`, g.`position_z` = s.`z`, g.`orientation` = s.`o`,
  g.`rotation2` = SIN(s.`o` / 2), g.`rotation3` = COS(s.`o` / 2);
-- Retire obsolete owned campaign placements; surviving spawn keys keep their GUIDs.
SET @BS_C04_PRUNE := CONCAT(
  'DELETE c FROM `creature` c LEFT JOIN `bs_c04_creature_spawns` s ON s.`spawn_key`=c.`Comment` ',
  'INNER JOIN `mod_customnpcs_bs_content` owner ON owner.`kind`=\'creature\' AND owner.`entry`=c.`',@BS_C04_ENTRY_COLUMN,'` AND owner.`chapter`=4 ',
  'WHERE c.`Comment` LIKE \'BS-C04:%\' AND s.`spawn_key` IS NULL'
);
PREPARE bs_c04_stmt FROM @BS_C04_PRUNE;
EXECUTE bs_c04_stmt;
DEALLOCATE PREPARE bs_c04_stmt;
DELETE g FROM `gameobject` g LEFT JOIN `bs_c04_gameobject_spawns` s ON s.`spawn_key`=g.`Comment`
INNER JOIN `mod_customnpcs_bs_content` owner ON owner.`kind`='gameobject' AND owner.`entry`=g.`id` AND owner.`chapter`=4
WHERE g.`Comment` LIKE 'BS-C04:%' AND s.`spawn_key` IS NULL;
DROP TEMPORARY TABLE `bs_c04_creature_spawns`;
DROP TEMPORARY TABLE `bs_c04_gameobject_spawns`;
DROP TEMPORARY TABLE `bs_c04_ids`;
COMMIT;
