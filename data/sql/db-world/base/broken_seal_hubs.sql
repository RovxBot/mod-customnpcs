-- The Broken Seal: quest hub safety and camp dressing, Chapters 1-3.
-- Generated from data/quests/broken_seal_hubs.json. Requires all three chapters and rebuilt module.
-- Occupied-ID checks precede content DML. Ordinary stock spawn moves are backed up and conditional.
-- No native spawn is deleted, no shared path or stock creature template is modified.
-- See docs/broken-seal/hub-implementation.md.
CREATE TABLE IF NOT EXISTS `mod_customnpcs_bs_content` (
  `kind` VARCHAR(16) NOT NULL, `entry` INT UNSIGNED NOT NULL, `chapter` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`kind`,`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_hub_ids`;
CREATE TEMPORARY TABLE `bs_hub_ids` (`kind` VARCHAR(16), `entry` INT UNSIGNED, PRIMARY KEY (`kind`,`entry`))
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_hub_ids` (`kind`, `entry`) VALUES
  ('creature', 4009000),
  ('creature', 4009001),
  ('creature', 4009002),
  ('creature', 4009003),
  ('creature', 4009004),
  ('creature', 4009005),
  ('creature', 4009006),
  ('creature', 4009007),
  ('creature', 4009050),
  ('creature', 4009051),
  ('creature', 4009052),
  ('creature', 4009053),
  ('creature', 4009054),
  ('creature', 4009055),
  ('creature', 4009056),
  ('creature', 4009057),
  ('gameobject', 4009100),
  ('gameobject', 4009101),
  ('gameobject', 4009102),
  ('gameobject', 4009103),
  ('gameobject', 4009104),
  ('gameobject', 4009105),
  ('gameobject', 4009106),
  ('gameobject', 4009107),
  ('gameobject', 4009108),
  ('gameobject', 4009109),
  ('gameobject', 4009110),
  ('gameobject', 4009111),
  ('gameobject', 4009112),
  ('gameobject', 4009113),
  ('gameobject', 4009114),
  ('gameobject', 4009115),
  ('gameobject', 4009116),
  ('gameobject', 4009117),
  ('gameobject', 4009118),
  ('gameobject', 4009119),
  ('gameobject', 4009120),
  ('gameobject', 4009121),
  ('gameobject', 4009122),
  ('gameobject', 4009123),
  ('gameobject', 4009124),
  ('gameobject', 4009125),
  ('gameobject', 4009126),
  ('gameobject', 4009127),
  ('gameobject', 4009128),
  ('gameobject', 4009129),
  ('gameobject', 4009130),
  ('gameobject', 4009131),
  ('gameobject', 4009132),
  ('gameobject', 4009133),
  ('gameobject', 4009134),
  ('gameobject', 4009135),
  ('gameobject', 4009136),
  ('gameobject', 4009137),
  ('gameobject', 4009138),
  ('gameobject', 4009139),
  ('gameobject', 4009140),
  ('gameobject', 4009141),
  ('gameobject', 4009142),
  ('gameobject', 4009143),
  ('gameobject', 4009144),
  ('gameobject', 4009145),
  ('gameobject', 4009146),
  ('gameobject', 4009147),
  ('gameobject', 4009148),
  ('gameobject', 4009149),
  ('gameobject', 4009150),
  ('gameobject', 4009151),
  ('gameobject', 4009152),
  ('gameobject', 4009153),
  ('gameobject', 4009154),
  ('gameobject', 4009155),
  ('gameobject', 4009156),
  ('gameobject', 4009157),
  ('gameobject', 4009158),
  ('gameobject', 4009159),
  ('gameobject', 4009160),
  ('gameobject', 4009161),
  ('gameobject', 4009162),
  ('gameobject', 4009163),
  ('gameobject', 4009164),
  ('gameobject', 4009165),
  ('gameobject', 4009166),
  ('gameobject', 4009167),
  ('gameobject', 4009168),
  ('gameobject', 4009169),
  ('gameobject', 4009170),
  ('gameobject', 4009171),
  ('outfit', 4009000),
  ('outfit', 4009001),
  ('outfit', 4009002),
  ('outfit', 4009003),
  ('outfit', 4009004),
  ('outfit', 4009005),
  ('outfit', 4009006),
  ('outfit', 4009007),
  ('outfit', 4009050),
  ('outfit', 4009051),
  ('outfit', 4009052),
  ('outfit', 4009053),
  ('outfit', 4009054),
  ('outfit', 4009055),
  ('outfit', 4009056),
  ('outfit', 4009057),
  ('outfit_entry', 4009000),
  ('outfit_entry', 4009001),
  ('outfit_entry', 4009002),
  ('outfit_entry', 4009003),
  ('outfit_entry', 4009004),
  ('outfit_entry', 4009005),
  ('outfit_entry', 4009006),
  ('outfit_entry', 4009007),
  ('outfit_entry', 4009050),
  ('outfit_entry', 4009051),
  ('outfit_entry', 4009052),
  ('outfit_entry', 4009053),
  ('outfit_entry', 4009054),
  ('outfit_entry', 4009055),
  ('outfit_entry', 4009056),
  ('outfit_entry', 4009057);
DROP TEMPORARY TABLE IF EXISTS `bs_hub_guard`;
CREATE TEMPORARY TABLE `bs_hub_guard` (`id` TINYINT PRIMARY KEY);
INSERT INTO `bs_hub_guard` VALUES (1);
INSERT INTO `bs_hub_guard` SELECT 1 WHERE
  (SELECT COUNT(*) FROM `mod_customnpcs_bs_content` WHERE `kind`='quest' AND
    ((`entry`=900108 AND `chapter`=1) OR (`entry`=900222 AND `chapter`=2) OR (`entry`=900311 AND `chapter`=3))) <> 3
  OR (SELECT COUNT(*) FROM `quest_template` WHERE `ID` IN (900108,900222,900311)) <> 3;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `creature_template` t INNER JOIN `bs_hub_ids` h ON h.`kind`='creature' AND h.`entry`=t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind`=h.`kind` AND o.`entry`=h.`entry` AND o.`chapter`=0
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `gameobject_template` t INNER JOIN `bs_hub_ids` h ON h.`kind`='gameobject' AND h.`entry`=t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind`=h.`kind` AND o.`entry`=h.`entry` AND o.`chapter`=0
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `mod_customnpcs_outfit` t INNER JOIN `bs_hub_ids` h ON h.`kind`='outfit' AND h.`entry`=t.`outfit_id`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind`=h.`kind` AND o.`entry`=h.`entry` AND o.`chapter`=0
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `mod_customnpcs_outfit_entry` t INNER JOIN `bs_hub_ids` h ON h.`kind`='outfit_entry' AND h.`entry`=t.`creature_entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind`=h.`kind` AND o.`entry`=h.`entry` AND o.`chapter`=0
WHERE o.`entry` IS NULL LIMIT 1;
DROP TEMPORARY TABLE `bs_hub_guard`;
CREATE TABLE IF NOT EXISTS `mod_customnpcs_bs_hub_native` (
  `guid` INT UNSIGNED PRIMARY KEY, `entry` INT UNSIGNED NOT NULL, `map` SMALLINT UNSIGNED NOT NULL,
  `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `o` FLOAT NOT NULL,
  `applied_x` FLOAT NOT NULL, `applied_y` FLOAT NOT NULL, `applied_z` FLOAT NOT NULL, `applied_o` FLOAT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
START TRANSACTION;
INSERT INTO `mod_customnpcs_bs_content` (`kind`,`entry`,`chapter`)
SELECT `kind`,`entry`,0 FROM `bs_hub_ids` ON DUPLICATE KEY UPDATE `chapter`=VALUES(`chapter`);
INSERT INTO `creature_template` (`entry`, `name`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `unit_class`, `unit_flags`, `type`, `AIName`, `ScriptName`, `HealthModifier`, `DamageModifier`, `ExperienceModifier`, `lootid`, `flags_extra`) VALUES
  (4009000, 'Vale Expedition Camp Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009001, 'Surveyor Refuge Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009002, 'Twilight Selection Camp Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009003, 'Twilight Supplication Station Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009004, 'Twilight Instructor Camp Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009005, 'Twilight Kennel Station Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009006, 'Dawnchaser Field Camp Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009007, 'Mei''s Mudsprocket Relief Station Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009050, 'Vale Expedition Camp Camp Volunteer', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009051, 'Surveyor Refuge Camp Volunteer', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009052, 'Twilight Selection Camp Quartermaster', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009053, 'Twilight Supplication Station Quartermaster', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009054, 'Twilight Instructor Camp Quartermaster', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009055, 'Twilight Kennel Station Quartermaster', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009056, 'Dawnchaser Field Camp Camp Volunteer', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009057, 'Mei''s Mudsprocket Relief Station Camp Volunteer', 45, 45, 35, 0, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `AIName` = VALUES(`AIName`), `ScriptName` = VALUES(`ScriptName`), `HealthModifier` = VALUES(`HealthModifier`), `DamageModifier` = VALUES(`DamageModifier`), `ExperienceModifier` = VALUES(`ExperienceModifier`), `lootid` = VALUES(`lootid`), `flags_extra` = VALUES(`flags_extra`);
DELETE FROM `creature_template_model` WHERE `CreatureID` IN (4009000, 4009001, 4009002, 4009003, 4009004, 4009005, 4009006, 4009007, 4009050, 4009051, 4009052, 4009053, 4009054, 4009055, 4009056, 4009057);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
  (4009000, 0, 49, 1, 1),
  (4009001, 0, 49, 1, 1),
  (4009002, 0, 49, 1, 1),
  (4009003, 0, 49, 1, 1),
  (4009004, 0, 49, 1, 1),
  (4009005, 0, 49, 1, 1),
  (4009006, 0, 59, 1, 1),
  (4009007, 0, 53, 1, 1),
  (4009050, 0, 49, 1, 1),
  (4009051, 0, 49, 1, 1),
  (4009052, 0, 49, 1, 1),
  (4009053, 0, 49, 1, 1),
  (4009054, 0, 49, 1, 1),
  (4009055, 0, 49, 1, 1),
  (4009056, 0, 59, 1, 1),
  (4009057, 0, 53, 1, 1);
INSERT INTO `mod_customnpcs_outfit` (`outfit_id`, `race`, `gender`, `class`, `skin`, `face`, `hair`, `hair_color`, `facial_hair`, `chest`, `legs`, `feet`, `hands`, `mainhand`) VALUES
  (4009000, 1, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009001, 1, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009002, 1, 0, 1, 0, 0, 0, 0, 0, 6569, 6568, 6573, 4248, 6631),
  (4009003, 1, 0, 1, 0, 0, 0, 0, 0, 6569, 6568, 6573, 4248, 6631),
  (4009004, 1, 0, 1, 0, 0, 0, 0, 0, 6569, 6568, 6573, 4248, 6631),
  (4009005, 1, 0, 1, 0, 0, 0, 0, 0, 6569, 6568, 6573, 4248, 6631),
  (4009006, 6, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009007, 3, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009050, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009051, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009052, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009053, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009054, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009055, 1, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009056, 6, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009057, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0)
ON DUPLICATE KEY UPDATE
  `race` = VALUES(`race`), `gender` = VALUES(`gender`), `class` = VALUES(`class`), `skin` = VALUES(`skin`), `face` = VALUES(`face`), `hair` = VALUES(`hair`), `hair_color` = VALUES(`hair_color`), `facial_hair` = VALUES(`facial_hair`), `chest` = VALUES(`chest`), `legs` = VALUES(`legs`), `feet` = VALUES(`feet`), `hands` = VALUES(`hands`), `mainhand` = VALUES(`mainhand`);
INSERT INTO `mod_customnpcs_outfit_entry` (`creature_entry`, `outfit_id`) VALUES
  (4009000, 4009000),
  (4009001, 4009001),
  (4009002, 4009002),
  (4009003, 4009003),
  (4009004, 4009004),
  (4009005, 4009005),
  (4009006, 4009006),
  (4009007, 4009007),
  (4009050, 4009050),
  (4009051, 4009051),
  (4009052, 4009052),
  (4009053, 4009053),
  (4009054, 4009054),
  (4009055, 4009055),
  (4009056, 4009056),
  (4009057, 4009057)
ON DUPLICATE KEY UPDATE
  `outfit_id` = VALUES(`outfit_id`);
DELETE FROM `creature_template_addon` WHERE `entry` IN (4009000, 4009001, 4009002, 4009003, 4009004, 4009005, 4009006, 4009007, 4009050, 4009051, 4009052, 4009053, 4009054, 4009055, 4009056, 4009057);
INSERT INTO `creature_template_addon` (`entry`, `emote`) VALUES
  (4009050, 69),
  (4009051, 69),
  (4009052, 69),
  (4009053, 69),
  (4009054, 69),
  (4009055, 69),
  (4009056, 69),
  (4009057, 69);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`) VALUES
  (4009100, 5, 7211, 'Vale Expedition Camp Shelter', 0.8),
  (4009101, 5, 6739, 'Vale Expedition Camp Bedroll', 1.0),
  (4009102, 5, 335, 'Vale Expedition Camp Supplies', 1.0),
  (4009103, 5, 335, 'Vale Expedition Camp Supplies', 1.0),
  (4009104, 5, 581, 'Vale Expedition Camp Table', 1.0),
  (4009105, 5, 130, 'Vale Expedition Camp Rack', 1.0),
  (4009106, 5, 192, 'Vale Expedition Camp Hearth', 1.0),
  (4009107, 5, 6038, 'Vale Expedition Camp Lantern', 1.0),
  (4009108, 5, 6038, 'Vale Expedition Camp Lantern', 1.0),
  (4009109, 5, 6151, 'Vale Expedition Camp Boundary', 0.9),
  (4009110, 5, 5191, 'Vale Expedition Camp Banner', 0.8),
  (4009111, 5, 7211, 'Surveyor Refuge Shelter', 0.8),
  (4009112, 5, 6739, 'Surveyor Refuge Bedroll', 1.0),
  (4009113, 5, 6739, 'Surveyor Refuge Bedroll', 1.0),
  (4009114, 5, 6449, 'Surveyor Refuge Medicine', 0.8),
  (4009115, 5, 335, 'Surveyor Refuge Supplies', 1.0),
  (4009116, 5, 6038, 'Surveyor Refuge Lantern', 1.0),
  (4009117, 5, 6151, 'Surveyor Refuge Boundary', 0.9),
  (4009118, 5, 7253, 'Twilight Selection Camp Cult Shelter', 0.6),
  (4009119, 5, 6739, 'Twilight Selection Camp Bedroll', 1.0),
  (4009120, 5, 335, 'Twilight Selection Camp Supplies', 1.0),
  (4009121, 5, 581, 'Twilight Selection Camp Table', 1.0),
  (4009122, 5, 6038, 'Twilight Selection Camp Lantern', 1.0),
  (4009123, 5, 6151, 'Twilight Selection Camp Boundary', 0.9),
  (4009124, 5, 7253, 'Twilight Supplication Station Cult Shelter', 0.6),
  (4009125, 5, 6449, 'Twilight Supplication Station Medicine', 0.8),
  (4009126, 5, 581, 'Twilight Supplication Station Table', 1.0),
  (4009127, 5, 335, 'Twilight Supplication Station Supplies', 1.0),
  (4009128, 5, 6038, 'Twilight Supplication Station Lantern', 1.0),
  (4009129, 5, 6151, 'Twilight Supplication Station Boundary', 0.9),
  (4009130, 5, 7253, 'Twilight Instructor Camp Cult Shelter', 0.6),
  (4009131, 5, 6739, 'Twilight Instructor Camp Bedroll', 1.0),
  (4009132, 5, 581, 'Twilight Instructor Camp Table', 1.0),
  (4009133, 5, 130, 'Twilight Instructor Camp Rack', 1.0),
  (4009134, 5, 6038, 'Twilight Instructor Camp Lantern', 1.0),
  (4009135, 5, 335, 'Twilight Instructor Camp Supplies', 1.0),
  (4009136, 5, 6151, 'Twilight Instructor Camp Boundary', 0.9),
  (4009137, 5, 7253, 'Twilight Kennel Station Cult Shelter', 0.6),
  (4009138, 5, 6739, 'Twilight Kennel Station Bedroll', 1.0),
  (4009139, 5, 335, 'Twilight Kennel Station Supplies', 1.0),
  (4009140, 5, 335, 'Twilight Kennel Station Supplies', 1.0),
  (4009141, 5, 130, 'Twilight Kennel Station Rack', 1.0),
  (4009142, 5, 6038, 'Twilight Kennel Station Lantern', 1.0),
  (4009143, 5, 6151, 'Twilight Kennel Station Boundary', 0.9),
  (4009144, 5, 7211, 'Dawnchaser Field Camp Shelter', 0.8),
  (4009145, 5, 6739, 'Dawnchaser Field Camp Bedroll', 1.0),
  (4009146, 5, 6739, 'Dawnchaser Field Camp Bedroll', 1.0),
  (4009147, 5, 7211, 'Dawnchaser Field Camp Shelter', 0.8),
  (4009148, 5, 6739, 'Dawnchaser Field Camp Bedroll', 1.0),
  (4009149, 5, 6739, 'Dawnchaser Field Camp Bedroll', 1.0),
  (4009150, 5, 335, 'Dawnchaser Field Camp Supplies', 1.0),
  (4009151, 5, 335, 'Dawnchaser Field Camp Supplies', 1.0),
  (4009152, 5, 6449, 'Dawnchaser Field Camp Medicine', 0.8),
  (4009153, 5, 6449, 'Dawnchaser Field Camp Medicine', 0.8),
  (4009154, 5, 581, 'Dawnchaser Field Camp Table', 1.0),
  (4009155, 5, 130, 'Dawnchaser Field Camp Rack', 1.0),
  (4009156, 5, 6038, 'Dawnchaser Field Camp Lantern', 1.0),
  (4009157, 5, 6038, 'Dawnchaser Field Camp Lantern', 1.0),
  (4009158, 5, 6038, 'Dawnchaser Field Camp Lantern', 1.0),
  (4009159, 5, 6151, 'Dawnchaser Field Camp Boundary', 0.9),
  (4009160, 5, 6151, 'Dawnchaser Field Camp Boundary', 0.9),
  (4009161, 5, 5191, 'Dawnchaser Field Camp Banner', 0.8),
  (4009162, 5, 7211, 'Mei''s Mudsprocket Relief Station Shelter', 0.8),
  (4009163, 5, 6739, 'Mei''s Mudsprocket Relief Station Bedroll', 1.0),
  (4009164, 5, 581, 'Mei''s Mudsprocket Relief Station Table', 1.0),
  (4009165, 5, 192, 'Mei''s Mudsprocket Relief Station Hearth', 1.0),
  (4009166, 5, 335, 'Mei''s Mudsprocket Relief Station Supplies', 1.0),
  (4009167, 5, 335, 'Mei''s Mudsprocket Relief Station Supplies', 1.0),
  (4009168, 5, 6038, 'Mei''s Mudsprocket Relief Station Lantern', 1.0),
  (4009169, 5, 130, 'Mei''s Mudsprocket Relief Station Rack', 1.0),
  (4009170, 5, 6151, 'Mei''s Mudsprocket Relief Station Boundary', 0.9),
  (4009171, 5, 5191, 'Mei''s Mudsprocket Relief Station Banner', 0.8)
ON DUPLICATE KEY UPDATE
  `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `size` = VALUES(`size`);
DROP TEMPORARY TABLE IF EXISTS `bs_hub_creature_spawns`;
CREATE TEMPORARY TABLE `bs_hub_creature_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_hub_gameobject_spawns`;
CREATE TEMPORARY TABLE `bs_hub_gameobject_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_hub_creature_spawns` (`spawn_key`, `entry`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-HUB:4009000:0', 4009000, 406, 1108.3, 1545.0, 28.774620026325632, -2.7377328586824166),
  ('BS-HUB:4009000:1', 4009000, 406, 1130.67, 1553.87, 39.97149793649448, 0.4738513364947603),
  ('BS-HUB:4009001:0', 4009001, 406, 1004.2, 1650.0, 9.421110739793843, -2.571552189890083),
  ('BS-HUB:4009001:1', 4009001, 406, 1019.8, 1661.0, -0.43925984698384185, 0.6556956262415362),
  ('BS-HUB:4009002:0', 4009002, 406, 884.2, 1605.0, -22.208678767793185, -2.571552189890083),
  ('BS-HUB:4009002:1', 4009002, 406, 899.8, 1616.0, -19.266353703962803, 0.6556956262415362),
  ('BS-HUB:4009003:0', 4009003, 406, 886.2, 1638.0, -18.04574612376399, -2.571552189890083),
  ('BS-HUB:4009003:1', 4009003, 406, 904.8, 1649.0, -9.675087411799925, 0.6556956262415362),
  ('BS-HUB:4009004:0', 4009004, 406, 852.9, 1587.0, -24.891290912102754, -2.6391713835651625),
  ('BS-HUB:4009004:1', 4009004, 406, 874.1, 1598.0, -22.954961352420185, 0.5829135889557342),
  ('BS-HUB:4009005:0', 4009005, 406, 907.2, 1595.0, -17.72352004052537, -2.571552189890083),
  ('BS-HUB:4009005:1', 4009005, 406, 925.8, 1604.27, -14.474689561971136, 0.6556956262415362),
  ('BS-HUB:4009006:0', 4009006, 15, -4007.7, -3355.0, 39.1219158543485, -3.0097361689657305),
  ('BS-HUB:4009006:1', 4009006, 15, -3932.3, -3344.0, 38.47990963176822, 0.15782753345665762),
  ('BS-HUB:4009007:0', 4009007, 15, -4538.88, -3244.82, 31.536760496289812, -2.7377328586824166),
  ('BS-HUB:4009007:1', 4009007, 15, -4523.3, -3229.0, 31.471600554899407, 0.4738513364947603),
  ('BS-HUB:4009050:0', 4009050, 406, 1098.62, 1552.44, 29.52582169522304, 3.141592653589793),
  ('BS-HUB:4009051:0', 4009051, 406, 1001.95, 1653.01, 11.223482758767357, 0.0),
  ('BS-HUB:4009052:0', 4009052, 406, 900.918, 1604.0, -19.62194978214146, 3.141592653589793),
  ('BS-HUB:4009053:0', 4009053, 406, 905.055, 1643.99, -10.105770543769161, 3.141592653589793),
  ('BS-HUB:4009054:0', 4009054, 406, 868.079, 1600.0, -24.461889942955864, 3.141592653589793),
  ('BS-HUB:4009055:0', 4009055, 406, 911.918, 1605.0, -16.43364583042969, 3.141592653589793),
  ('BS-HUB:4009056:0', 4009056, 15, -3981.08, -3335.0, 37.44540655266874, 3.141592653589793),
  ('BS-HUB:4009057:0', 4009057, 15, -4528.53, -3228.39, 31.033901026964227, 3.141592653589793);
INSERT INTO `bs_hub_gameobject_spawns` (`spawn_key`, `entry`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-HUB:expedition_shelter_0', 4009100, 406, 1103.0, 1540.0, 27.161244499953167, 3.141592653589793),
  ('BS-HUB:expedition_bedroll_1', 4009101, 406, 1109.0, 1540.0, 28.32227133797804, 3.141592653589793),
  ('BS-HUB:expedition_supplies_2', 4009102, 406, 1096.69, 1552.44, 28.473480174029763, 3.141592653589793),
  ('BS-HUB:expedition_supplies_3', 4009103, 406, 1103.47, 1548.3, 28.888241730112373, 3.141592653589793),
  ('BS-HUB:expedition_table_4', 4009104, 406, 1129.0, 1546.0, 34.38619126079383, 3.141592653589793),
  ('BS-HUB:expedition_rack_5', 4009105, 406, 1129.0, 1542.0, 34.4405801266477, 3.141592653589793),
  ('BS-HUB:expedition_hearth_6', 4009106, 406, 1101.39, 1545.39, 27.514754583207644, 3.141592653589793),
  ('BS-HUB:expedition_lantern_7', 4009107, 406, 1114.0, 1553.0, 34.51975101605525, 3.141592653589793),
  ('BS-HUB:expedition_lantern_8', 4009108, 406, 1125.06, 1553.61, 40.5429494686621, 3.141592653589793),
  ('BS-HUB:expedition_boundary_9', 4009109, 406, 1100.17, 1543.17, 26.965853582844726, 3.141592653589793),
  ('BS-HUB:expedition_banner_10', 4009110, 406, 1125.0, 1541.0, 33.1736265861736, 3.141592653589793),
  ('BS-HUB:refuge_shelter_0', 4009111, 406, 1008.83, 1682.92, -4.077839482068257, 3.141592653589793),
  ('BS-HUB:refuge_bedroll_1', 4009112, 406, 1016.0, 1662.0, -1.5395809541355348, 3.141592653589793),
  ('BS-HUB:refuge_bedroll_2', 4009113, 406, 1018.0, 1665.0, -0.15479251855125115, 3.141592653589793),
  ('BS-HUB:refuge_medicine_3', 4009114, 406, 1004.0, 1653.0, 10.324594628795115, 3.141592653589793),
  ('BS-HUB:refuge_supplies_4', 4009115, 406, 1001.0, 1656.0, 10.073391838303603, 3.141592653589793),
  ('BS-HUB:refuge_lantern_5', 4009116, 406, 1006.0, 1652.0, 9.032354589707683, 3.141592653589793),
  ('BS-HUB:refuge_boundary_6', 4009117, 406, 1023.24, 1654.64, 2.2692405784148333, 3.141592653589793),
  ('BS-HUB:selection_cult_shelter_0', 4009118, 406, 891.0, 1619.0, -20.026784214379862, 0.0),
  ('BS-HUB:selection_bedroll_1', 4009119, 406, 885.0, 1620.0, -20.88338572995666, 0.0),
  ('BS-HUB:selection_supplies_2', 4009120, 406, 899.0, 1604.0, -19.926699734167986, 0.0),
  ('BS-HUB:selection_table_3', 4009121, 406, 896.0, 1606.0, -20.423287987371825, 0.0),
  ('BS-HUB:selection_lantern_4', 4009122, 406, 900.0, 1614.0, -19.521469969506278, 0.0),
  ('BS-HUB:selection_boundary_5', 4009123, 406, 883.0, 1609.0, -22.334147951044176, 0.0),
  ('BS-HUB:supplicants_cult_shelter_0', 4009124, 406, 908.485, 1645.49, -8.924219794981212, 0.0),
  ('BS-HUB:supplicants_medicine_1', 4009125, 406, 903.0, 1644.0, -10.881812732524864, 0.0),
  ('BS-HUB:supplicants_table_2', 4009126, 406, 900.0, 1648.0, -10.443133333128934, 0.0),
  ('BS-HUB:supplicants_supplies_3', 4009127, 406, 903.0, 1650.0, -9.729188560152284, 0.0),
  ('BS-HUB:supplicants_lantern_4', 4009128, 406, 889.0, 1638.0, -17.249935683486157, 0.0),
  ('BS-HUB:supplicants_boundary_5', 4009129, 406, 883.0, 1644.0, -14.47678908845182, 0.0),
  ('BS-HUB:instruction_cult_shelter_0', 4009130, 406, 857.0, 1596.0, -24.71253024072307, 0.0),
  ('BS-HUB:instruction_bedroll_1', 4009131, 406, 850.0, 1597.0, -24.43058523993, 0.0),
  ('BS-HUB:instruction_table_2', 4009132, 406, 866.0, 1600.0, -24.766363721558037, 0.0),
  ('BS-HUB:instruction_rack_3', 4009133, 406, 867.0, 1585.0, -21.956549278289078, 0.0),
  ('BS-HUB:instruction_lantern_4', 4009134, 406, 860.0, 1584.0, -23.590405895069654, 0.0),
  ('BS-HUB:instruction_supplies_5', 4009135, 406, 871.531, 1602.7, -24.14925132381511, 0.0),
  ('BS-HUB:instruction_boundary_6', 4009136, 406, 852.0, 1586.0, -24.918438068196913, 0.0),
  ('BS-HUB:kennels_cult_shelter_0', 4009137, 406, 922.0, 1604.27, -14.67697127007466, 0.0),
  ('BS-HUB:kennels_bedroll_1', 4009138, 406, 922.225, 1610.24, -14.458401044187688, 0.0),
  ('BS-HUB:kennels_supplies_2', 4009139, 406, 910.0, 1605.0, -16.96991067808481, 0.0),
  ('BS-HUB:kennels_supplies_3', 4009140, 406, 910.0, 1607.0, -17.193481161622454, 0.0),
  ('BS-HUB:kennels_rack_4', 4009141, 406, 922.0, 1593.0, -16.02669710335936, 0.0),
  ('BS-HUB:kennels_lantern_5', 4009142, 406, 909.0, 1596.0, -17.39850825506439, 0.0),
  ('BS-HUB:kennels_boundary_6', 4009143, 406, 927.0, 1590.0, -15.630382139391482, 0.0),
  ('BS-HUB:dawnchasers_shelter_0', 4009144, 15, -3952.0, -3331.0, 36.81055195542569, 0.0),
  ('BS-HUB:dawnchasers_bedroll_1', 4009145, 15, -3953.0, -3335.0, 37.783133818821824, 0.0),
  ('BS-HUB:dawnchasers_bedroll_2', 4009146, 15, -3947.0, -3335.0, 37.26920439668177, 0.0),
  ('BS-HUB:dawnchasers_shelter_3', 4009147, 15, -3989.0, -3334.0, 35.76800737155726, 0.0),
  ('BS-HUB:dawnchasers_bedroll_4', 4009148, 15, -3993.0, -3336.0, 36.66101468005499, 0.0),
  ('BS-HUB:dawnchasers_bedroll_5', 4009149, 15, -3990.0, -3339.0, 36.76460095515633, 0.0),
  ('BS-HUB:dawnchasers_supplies_6', 4009150, 15, -3983.0, -3335.0, 36.7970096310847, 0.0),
  ('BS-HUB:dawnchasers_supplies_7', 4009151, 15, -3983.0, -3332.0, 36.09938340304793, 0.0),
  ('BS-HUB:dawnchasers_medicine_8', 4009152, 15, -3978.0, -3362.0, 39.38559455682659, 0.0),
  ('BS-HUB:dawnchasers_medicine_9', 4009153, 15, -3975.0, -3362.0, 38.73867164868163, 0.0),
  ('BS-HUB:dawnchasers_table_10', 4009154, 15, -3953.0, -3354.0, 38.576521073859254, 0.0),
  ('BS-HUB:dawnchasers_rack_11', 4009155, 15, -3953.0, -3362.0, 37.9674023323435, 0.0),
  ('BS-HUB:dawnchasers_lantern_12', 4009156, 15, -3985.0, -3355.0, 40.41977791669558, 0.0),
  ('BS-HUB:dawnchasers_lantern_13', 4009157, 15, -3962.0, -3338.0, 39.46449020892156, 0.0),
  ('BS-HUB:dawnchasers_lantern_14', 4009158, 15, -3998.99, -3342.51, 38.25389788609044, 0.0),
  ('BS-HUB:dawnchasers_boundary_15', 4009159, 15, -3943.0, -3344.0, 37.6708647341825, 0.0),
  ('BS-HUB:dawnchasers_boundary_16', 4009160, 15, -4002.0, -3365.0, 38.31017678458511, 0.0),
  ('BS-HUB:dawnchasers_banner_17', 4009161, 15, -3950.0, -3342.0, 39.07451414598363, 0.0),
  ('BS-HUB:wayside_shelter_0', 4009162, 15, -4554.4, -3242.61, 30.611652701467065, 0.0),
  ('BS-HUB:wayside_bedroll_1', 4009163, 15, -4540.27, -3223.47, 30.71857401148607, 0.0),
  ('BS-HUB:wayside_table_2', 4009164, 15, -4530.61, -3228.39, 30.781079476144694, 0.0),
  ('BS-HUB:wayside_hearth_3', 4009165, 15, -4530.88, -3241.44, 30.789205479715122, 0.0),
  ('BS-HUB:wayside_supplies_4', 4009166, 15, -4538.99, -3241.01, 30.686144621048175, 0.0),
  ('BS-HUB:wayside_supplies_5', 4009167, 15, -4537.0, -3241.0, 31.272834616461672, 0.0),
  ('BS-HUB:wayside_lantern_6', 4009168, 15, -4525.07, -3230.67, 30.719709359968537, 0.0),
  ('BS-HUB:wayside_rack_7', 4009169, 15, -4541.03, -3243.97, 30.692722179857057, 0.0),
  ('BS-HUB:wayside_boundary_8', 4009170, 15, -4523.14, -3243.63, 30.775629270403766, 0.0),
  ('BS-HUB:wayside_banner_9', 4009171, 15, -4536.77, -3225.62, 30.701033410469293, 0.0);
SET @BS_HUB_ENTRY_COLUMN := (
  SELECT `COLUMN_NAME` FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'creature' AND `COLUMN_NAME` IN ('id1', 'id')
  ORDER BY `COLUMN_NAME` DESC LIMIT 1
);
SET @BS_HUB_INSERT := CONCAT(
  'INSERT INTO `creature` (`', @BS_HUB_ENTRY_COLUMN, '`, `map`, `zoneId`, `spawnMask`, `phaseMask`, ',
  '`position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `curhealth`, `curmana`, `Comment`) ',
  'SELECT s.`entry`, 1, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, 60, 0, 0, s.`spawn_key` ',
  'FROM `bs_hub_creature_spawns` s LEFT JOIN `creature` c ON c.`Comment` = s.`spawn_key` WHERE c.`guid` IS NULL'
);
PREPARE bs_hub_stmt FROM @BS_HUB_INSERT;
EXECUTE bs_hub_stmt;
DEALLOCATE PREPARE bs_hub_stmt;
SET @BS_HUB_UPDATE := CONCAT(
  'UPDATE `creature` c INNER JOIN `bs_hub_creature_spawns` s ON c.`Comment` = s.`spawn_key` ',
  'SET c.`', @BS_HUB_ENTRY_COLUMN, '` = s.`entry`, c.`zoneId` = s.`zone`, c.`position_x` = s.`x`, ',
  'c.`position_y` = s.`y`, c.`position_z` = s.`z`, c.`orientation` = s.`o`'
);
PREPARE bs_hub_stmt FROM @BS_HUB_UPDATE;
EXECUTE bs_hub_stmt;
DEALLOCATE PREPARE bs_hub_stmt;
INSERT INTO `gameobject`
  (`id`, `map`, `zoneId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`,
   `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`)
SELECT s.`entry`, 1, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, SIN(s.`o` / 2), COS(s.`o` / 2), 60, 100, 1, s.`spawn_key`
FROM `bs_hub_gameobject_spawns` s LEFT JOIN `gameobject` g ON g.`Comment` = s.`spawn_key` WHERE g.`guid` IS NULL;
UPDATE `gameobject` g INNER JOIN `bs_hub_gameobject_spawns` s ON g.`Comment` = s.`spawn_key`
SET g.`id` = s.`entry`, g.`position_x` = s.`x`, g.`position_y` = s.`y`, g.`position_z` = s.`z`, g.`orientation` = s.`o`,
  g.`rotation2` = SIN(s.`o` / 2), g.`rotation3` = COS(s.`o` / 2);
DROP TEMPORARY TABLE IF EXISTS `bs_hub_native_moves`;
CREATE TEMPORARY TABLE `bs_hub_native_moves` (`guid` INT UNSIGNED PRIMARY KEY, `entry` INT UNSIGNED,
  `ox` FLOAT, `oy` FLOAT, `oz` FLOAT, `oo` FLOAT, `nx` FLOAT, `ny` FLOAT, `nz` FLOAT, `no` FLOAT);
INSERT INTO `bs_hub_native_moves` (`guid`, `entry`, `ox`, `oy`, `oz`, `oo`, `nx`, `ny`, `nz`, `no`) VALUES
  (30420, 4022, 1003.41, 1691.52, -4.956, 1.82264, 997.575, 1716.33, -8.83055, 1.82264),
  (30421, 4022, 941.307, 1655.49, -12.7333, 0.472381, 954.913, 1659.08, -10.84, 0.472381),
  (30422, 4022, 936.874, 1560.52, -13.6834, 0.501217, 945.532, 1544.89, -9.73562, 0.501217),
  (31180, 4345, -4495.28, -3212.71, 30.1475, 5.92335, -4477.53, -3204.9, 31.158, 5.92335),
  (31454, 4412, -3931.82, -3264.18, 36.642, 1.64113, -3927.73, -3254.98, 36.717, 1.64113),
  (31914, 4026, 938.699, 1639.8, -13.5585, 5.22154, 956.839, 1638.5, -10.6948, 5.22154),
  (31939, 4026, 898.094, 1564.78, -16.8351, 6.02495, 902.636, 1538.23, -15.4736, 6.02495),
  (31952, 4026, 915.674, 1557.62, -15.561, 0.209711, 916.002, 1537.01, -13.6553, 0.209711),
  (31954, 4026, 920.355, 1552.8, -14.4482, 4.24683, 922.102, 1537.4, -12.4988, 4.24683),
  (32016, 4026, 997.654, 1681.26, -5.32134, 5.17718, 981.796, 1710.29, -9.12789, 5.17718),
  (32090, 4026, 992.583, 1642.01, 14.1659, 3.90456, 967.949, 1625.53, -9.7444, 3.90456),
  (32111, 4026, 854.836, 1638.82, -26.3465, 4.58113, 831.649, 1652.02, -28.0625, 4.58113),
  (32130, 4028, 850.528, 1643.93, -26.7928, 4.61361, 831.014, 1644.35, -28.1172, 4.61361),
  (32134, 4029, 858.662, 1639.48, -25.6678, 1.65219, 831.714, 1652.46, -28.0569, 1.65219),
  (32150, 4036, 843.635, 1578.72, -25.4069, 4.00718, 809.328, 1553.91, -27.0461, 4.00718),
  (32184, 4044, 896.602, 1610.85, -20.293, 6.10456, 971.819, 1604.62, -6.50354, 6.10456),
  (33797, 4348, -3910.2, -3309.3, 43.2623, 4.05015, -3888.16, -3294.3, 51.5782, 4.05015),
  (33825, 4412, -3937.28, -3274.18, 38.145, 3.83283, -3928.79, -3254.51, 36.5249, 3.83283),
  (33868, 4412, -3969.05, -3434.76, 40.0915, 2.97676, -3968.83, -3453.99, 35.9621, 2.97676),
  (33892, 4345, -3914.41, -3393.57, 30.5224, 1.43423, -3888.15, -3414.4, 39.1712, 1.43423),
  (33911, 4344, -3886.49, -3389.57, 32.9654, 4.56137, -3876.02, -3394.53, 35.7632, 4.56137);
-- Claim only the audited original spawn: changed realm placements are left alone.
SET @BS_HUB_BACKUP := CONCAT(
 'INSERT IGNORE INTO `mod_customnpcs_bs_hub_native` (`guid`,`entry`,`map`,`x`,`y`,`z`,`o`,`applied_x`,`applied_y`,`applied_z`,`applied_o`) ',
 'SELECT c.`guid`,m.`entry`,c.`map`,c.`position_x`,c.`position_y`,c.`position_z`,c.`orientation`,m.`nx`,m.`ny`,m.`nz`,m.`no` ',
 'FROM `creature` c INNER JOIN `bs_hub_native_moves` m ON c.`guid`=m.`guid` INNER JOIN `creature_template` t ON t.`entry`=m.`entry` ',
 'WHERE c.`',@BS_HUB_ENTRY_COLUMN,'`=m.`entry` AND c.`map`=1 AND ',
 "t.`ScriptName`='' AND t.`rank`=0 AND t.`npcflag`=0 AND (c.`ScriptName`='' OR c.`ScriptName` IS NULL) AND c.`npcflag`=0 AND c.`MovementType` IN (0,1) AND ",
 'ABS(c.`position_x`-m.`ox`)<0.1 AND ABS(c.`position_y`-m.`oy`)<0.1 AND ABS(c.`position_z`-m.`oz`)<0.1'
);
PREPARE bs_hub_stmt FROM @BS_HUB_BACKUP;
EXECUTE bs_hub_stmt;
DEALLOCATE PREPARE bs_hub_stmt;
SET @BS_HUB_MOVE := CONCAT(
 'UPDATE `creature` c INNER JOIN `bs_hub_native_moves` m ON c.`guid`=m.`guid` ',
 'INNER JOIN `mod_customnpcs_bs_hub_native` b ON b.`guid`=c.`guid` AND b.`entry`=m.`entry` INNER JOIN `creature_template` t ON t.`entry`=m.`entry` ',
 'SET c.`position_x`=m.`nx`,c.`position_y`=m.`ny`,c.`position_z`=m.`nz`,c.`orientation`=m.`no` ',
 'WHERE c.`',@BS_HUB_ENTRY_COLUMN,'`=m.`entry` AND c.`map`=b.`map` AND ',
 "t.`ScriptName`='' AND t.`rank`=0 AND t.`npcflag`=0 AND (c.`ScriptName`='' OR c.`ScriptName` IS NULL) AND c.`npcflag`=0 AND c.`MovementType` IN (0,1) AND ",
 '((ABS(c.`position_x`-b.`x`)<0.1 AND ABS(c.`position_y`-b.`y`)<0.1 AND ABS(c.`position_z`-b.`z`)<0.1) OR ',
 '(ABS(c.`position_x`-b.`applied_x`)<0.1 AND ABS(c.`position_y`-b.`applied_y`)<0.1 AND ABS(c.`position_z`-b.`applied_z`)<0.1))'
);
PREPARE bs_hub_stmt FROM @BS_HUB_MOVE;
EXECUTE bs_hub_stmt;
DEALLOCATE PREPARE bs_hub_stmt;
UPDATE `creature` SET `position_x`=-4535.0,`position_y`=-3235.0,`position_z`=31.005721232444824,`orientation`=3.14 WHERE `Comment`='BS-C03:NPC_MEI:mei';
UPDATE `gameobject` SET `position_x`=-4533.0,`position_y`=-3233.0,`position_z`=30.085449329220566,`orientation`=3.14,`rotation2`=SIN(3.14/2),`rotation3`=COS(3.14/2) WHERE `Comment`='BS-C03:GO_VILLAGE_SIGN:village_sign';
UPDATE `creature` SET `position_x`=1052.0,`position_y`=1646.0,`position_z`=15.459047454452229,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_1';
UPDATE `creature` SET `position_x`=1038.0,`position_y`=1616.0,`position_z`=79.35763348383723,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_2';
UPDATE `creature` SET `position_x`=1032.0,`position_y`=1604.0,`position_z`=87.11358574626871,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_3';
UPDATE `creature` SET `position_x`=1048.73,`position_y`=1630.73,`position_z`=29.246997468726835,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_4';
UPDATE `creature` SET `position_x`=1052.0,`position_y`=1653.0,`position_z`=14.391567806857072,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_5';
UPDATE `creature` SET `position_x`=1060.0,`position_y`=1626.0,`position_z`=34.23473728777762,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_6';
UPDATE `creature` SET `position_x`=963.0,`position_y`=1660.0,`position_z`=-10.141557772543873,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_7';
UPDATE `creature` SET `position_x`=942.0,`position_y`=1655.0,`position_z`=-12.625688946517286,`orientation`=3.14 WHERE `Comment`='BS-C01:NPC_CULT_SCOUT:scout_8';
UPDATE `creature` SET `position_x`=835.0,`position_y`=1664.0,`position_z`=-27.059933500169194,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_0';
UPDATE `creature` SET `position_x`=824.0,`position_y`=1669.0,`position_z`=-28.40598382122006,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_1';
UPDATE `creature` SET `position_x`=819.0,`position_y`=1682.0,`position_z`=-26.401782189081,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_2';
UPDATE `creature` SET `position_x`=839.0,`position_y`=1679.0,`position_z`=-25.57625049232782,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_3';
UPDATE `creature` SET `position_x`=852.0,`position_y`=1697.0,`position_z`=-22.180517612859283,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_4';
UPDATE `creature` SET `position_x`=825.0,`position_y`=1694.0,`position_z`=-24.325921655653925,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_5';
UPDATE `creature` SET `position_x`=810.0,`position_y`=1672.0,`position_z`=-29.03081770956997,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_6';
UPDATE `creature` SET `position_x`=844.0,`position_y`=1712.0,`position_z`=-20.64566856295442,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FIRE:fire_7';
UPDATE `creature` SET `position_x`=846.0,`position_y`=1534.0,`position_z`=-19.41653064558561,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FAILED:failed_0';
UPDATE `creature` SET `position_x`=862.0,`position_y`=1528.0,`position_z`=-17.89641558558829,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FAILED:failed_1';
UPDATE `creature` SET `position_x`=880.0,`position_y`=1527.0,`position_z`=-16.2160568958683,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FAILED:failed_2';
UPDATE `creature` SET `position_x`=885.0,`position_y`=1541.0,`position_z`=-18.675011104123634,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FAILED:failed_3';
UPDATE `creature` SET `position_x`=842.0,`position_y`=1548.0,`position_z`=-23.47708327588033,`orientation`=3.14 WHERE `Comment`='BS-C02:NPC_FAILED:failed_4';
DROP TEMPORARY TABLE `bs_hub_creature_spawns`;
DROP TEMPORARY TABLE `bs_hub_gameobject_spawns`;
DROP TEMPORARY TABLE `bs_hub_native_moves`;
DROP TEMPORARY TABLE `bs_hub_ids`;
COMMIT;
