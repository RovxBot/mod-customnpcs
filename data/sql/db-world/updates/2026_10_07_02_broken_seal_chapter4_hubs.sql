-- The Broken Seal: quest hub safety and camp dressing, Chapters 1-4.
-- Generated from data/quests/broken_seal_hubs.json. Requires all four chapters and rebuilt module.
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
  ('creature', 4009006),
  ('creature', 4009007),
  ('creature', 4009008),
  ('creature', 4009009),
  ('creature', 4009000),
  ('creature', 4009002),
  ('creature', 4009056),
  ('creature', 4009057),
  ('creature', 4009058),
  ('creature', 4009059),
  ('creature', 4009050),
  ('creature', 4009052),
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
  ('gameobject', 4009186),
  ('gameobject', 4009187),
  ('gameobject', 4009188),
  ('gameobject', 4009189),
  ('gameobject', 4009190),
  ('gameobject', 4009191),
  ('gameobject', 4009192),
  ('gameobject', 4009193),
  ('gameobject', 4009194),
  ('gameobject', 4009195),
  ('gameobject', 4009200),
  ('gameobject', 4009201),
  ('gameobject', 4009202),
  ('gameobject', 4009203),
  ('gameobject', 4009204),
  ('gameobject', 4009205),
  ('gameobject', 4009206),
  ('gameobject', 4009207),
  ('gameobject', 4009208),
  ('gameobject', 4009209),
  ('gameobject', 4009210),
  ('gameobject', 4009211),
  ('gameobject', 4009212),
  ('gameobject', 4009213),
  ('gameobject', 4009214),
  ('gameobject', 4009215),
  ('gameobject', 4009216),
  ('gameobject', 4009217),
  ('gameobject', 4009300),
  ('gameobject', 4009301),
  ('gameobject', 4009302),
  ('gameobject', 4009303),
  ('gameobject', 4009304),
  ('gameobject', 4009305),
  ('gameobject', 4009306),
  ('gameobject', 4009307),
  ('gameobject', 4009308),
  ('gameobject', 4009309),
  ('gameobject', 4009310),
  ('gameobject', 4009311),
  ('gameobject', 4009312),
  ('gameobject', 4009313),
  ('gameobject', 4009314),
  ('gameobject', 4009315),
  ('gameobject', 4009316),
  ('gameobject', 4009317),
  ('gameobject', 4009318),
  ('gameobject', 4009319),
  ('gameobject', 4009320),
  ('gameobject', 4009218),
  ('gameobject', 4009219),
  ('gameobject', 4009220),
  ('gameobject', 4009221),
  ('gameobject', 4009222),
  ('gameobject', 4009223),
  ('outfit', 4009006),
  ('outfit', 4009007),
  ('outfit', 4009008),
  ('outfit', 4009009),
  ('outfit', 4009000),
  ('outfit', 4009002),
  ('outfit', 4009056),
  ('outfit', 4009057),
  ('outfit', 4009058),
  ('outfit', 4009059),
  ('outfit', 4009050),
  ('outfit', 4009052),
  ('outfit_entry', 4009006),
  ('outfit_entry', 4009007),
  ('outfit_entry', 4009008),
  ('outfit_entry', 4009009),
  ('outfit_entry', 4009000),
  ('outfit_entry', 4009002),
  ('outfit_entry', 4009056),
  ('outfit_entry', 4009057),
  ('outfit_entry', 4009058),
  ('outfit_entry', 4009059),
  ('outfit_entry', 4009050),
  ('outfit_entry', 4009052),
  ('npc_text', 4009056),
  ('npc_text', 4009057),
  ('npc_text', 4009058),
  ('npc_text', 4009059),
  ('npc_text', 4009050),
  ('npc_text', 4009052),
  ('gossip_menu', 4009056),
  ('gossip_menu', 4009057),
  ('gossip_menu', 4009058),
  ('gossip_menu', 4009059),
  ('gossip_menu', 4009050),
  ('gossip_menu', 4009052);
DROP TEMPORARY TABLE IF EXISTS `bs_hub_guard`;
CREATE TEMPORARY TABLE `bs_hub_guard` (`id` TINYINT PRIMARY KEY);
INSERT INTO `bs_hub_guard` VALUES (1);
INSERT INTO `bs_hub_guard` SELECT 1 WHERE
  (SELECT COUNT(*) FROM `mod_customnpcs_bs_content` WHERE `kind`='quest' AND
    ((`entry`=900108 AND `chapter`=1) OR (`entry`=900222 AND `chapter`=2) OR (`entry`=900311 AND `chapter`=3) OR (`entry`=900411 AND `chapter`=4))) <> 4
  OR (SELECT COUNT(*) FROM `quest_template` WHERE `ID` IN (900108,900222,900311,900411)) <> 4;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `creature_template` t INNER JOIN `bs_hub_ids` h ON h.`kind`='creature' AND h.`entry`=t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind`=h.`kind` AND o.`entry`=h.`entry` AND o.`chapter`=0
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `gameobject_template` t INNER JOIN `bs_hub_ids` h ON h.`kind`='gameobject' AND h.`entry`=t.`entry`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind`=h.`kind` AND o.`entry`=h.`entry` AND o.`chapter`=0
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `gameobject_template_addon` t INNER JOIN `bs_hub_ids` h ON h.`kind`='gameobject' AND h.`entry`=t.`entry`
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
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `npc_text` t INNER JOIN `bs_hub_ids` h ON h.`kind`='npc_text' AND h.`entry`=t.`ID`
LEFT JOIN `mod_customnpcs_bs_content` o ON o.`kind`=h.`kind` AND o.`entry`=h.`entry` AND o.`chapter`=0
WHERE o.`entry` IS NULL LIMIT 1;
INSERT INTO `bs_hub_guard`
SELECT 1 FROM `gossip_menu` t INNER JOIN `bs_hub_ids` h ON h.`kind`='gossip_menu' AND h.`entry`=t.`MenuID`
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
  (4009006, 'Dawnchaser Field Camp Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009007, 'Mei''s Mudsprocket Relief Station Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009008, 'Southern Village Relief Camp Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009009, 'Neutral Wildhammer Gathering Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009000, 'Expedition Sentry', 45, 45, 250, 0, 1, 770, 7, '', 'npc_bs_hub_sentry', 5, 1, 0, 0, 2),
  (4009002, 'Twilight Camp Sentry', 27, 27, 14, 0, 1, 0, 7, '', 'npc_bs_hub_sentry', 1.4, 1, 1, 4009002, 0),
  (4009056, 'Dawnchaser Medical Volunteer', 45, 45, 35, 1, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009057, 'Barrelbottom Supply Clerk', 45, 45, 35, 1, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009058, 'Village Relief Carpenter', 45, 45, 35, 1, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009059, 'Wildhammer Table Steward', 45, 45, 35, 1, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009050, 'Expedition Quartermaster', 45, 45, 35, 1, 1, 770, 7, '', 'npc_bs_hub_resident', 5, 1, 0, 0, 2),
  (4009052, 'Twilight Quartermaster', 27, 27, 14, 1, 1, 770, 7, '', 'npc_bs_hub_resident', 1.4, 1, 0, 0, 0)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `AIName` = VALUES(`AIName`), `ScriptName` = VALUES(`ScriptName`), `HealthModifier` = VALUES(`HealthModifier`), `DamageModifier` = VALUES(`DamageModifier`), `ExperienceModifier` = VALUES(`ExperienceModifier`), `lootid` = VALUES(`lootid`), `flags_extra` = VALUES(`flags_extra`);
DELETE FROM `creature_template_model` WHERE `CreatureID` IN (4009006, 4009007, 4009008, 4009009, 4009000, 4009002, 4009056, 4009057, 4009058, 4009059, 4009050, 4009052);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
  (4009006, 0, 3770, 1, 1),
  (4009007, 0, 3406, 1, 1),
  (4009008, 0, 3406, 1, 1),
  (4009009, 0, 3406, 1, 1),
  (4009000, 0, 5075, 1, 1),
  (4009002, 0, 11811, 1, 1),
  (4009056, 0, 3770, 1, 1),
  (4009057, 0, 3406, 1, 1),
  (4009058, 0, 3406, 1, 1),
  (4009059, 0, 3406, 1, 1),
  (4009050, 0, 5075, 1, 1),
  (4009052, 0, 11824, 1, 1);
INSERT INTO `mod_customnpcs_outfit` (`outfit_id`, `race`, `gender`, `class`, `skin`, `face`, `hair`, `hair_color`, `facial_hair`, `chest`, `legs`, `feet`, `hands`, `mainhand`) VALUES
  (4009006, 6, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009007, 3, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009008, 3, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009009, 3, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009000, 1, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009002, 1, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 12282),
  (4009056, 6, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009057, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009058, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009059, 3, 0, 1, 0, 0, 0, 0, 0, 6238, 6568, 2315, 14089, 0),
  (4009050, 1, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 4575),
  (4009052, 1, 0, 1, 0, 0, 0, 0, 0, 6085, 6596, 6573, 4248, 4575)
ON DUPLICATE KEY UPDATE
  `race` = VALUES(`race`), `gender` = VALUES(`gender`), `class` = VALUES(`class`), `skin` = VALUES(`skin`), `face` = VALUES(`face`), `hair` = VALUES(`hair`), `hair_color` = VALUES(`hair_color`), `facial_hair` = VALUES(`facial_hair`), `chest` = VALUES(`chest`), `legs` = VALUES(`legs`), `feet` = VALUES(`feet`), `hands` = VALUES(`hands`), `mainhand` = VALUES(`mainhand`);
INSERT INTO `mod_customnpcs_outfit_entry` (`creature_entry`, `outfit_id`) VALUES
  (4009006, 4009006),
  (4009007, 4009007),
  (4009008, 4009008),
  (4009009, 4009009),
  (4009000, 4009000),
  (4009002, 0),
  (4009056, 4009056),
  (4009057, 4009057),
  (4009058, 4009058),
  (4009059, 4009059),
  (4009050, 4009050),
  (4009052, 0)
ON DUPLICATE KEY UPDATE
  `outfit_id` = VALUES(`outfit_id`);
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`) VALUES
  (4009006, 1, 12282, 0, 0),
  (4009007, 1, 12282, 0, 0),
  (4009008, 1, 12282, 0, 0),
  (4009009, 1, 12282, 0, 0),
  (4009000, 1, 12282, 0, 0),
  (4009002, 1, 12282, 0, 0),
  (4009050, 1, 4575, 0, 0),
  (4009052, 1, 4575, 0, 0)
ON DUPLICATE KEY UPDATE
  `ItemID1` = VALUES(`ItemID1`), `ItemID2` = VALUES(`ItemID2`), `ItemID3` = VALUES(`ItemID3`);
UPDATE `creature_template` SET `mingold`=28,`maxgold`=94,`lootid`=4009002 WHERE `entry`=4009002;
DELETE FROM `creature_loot_template` WHERE `Entry`=4009002;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`) VALUES
  (4009002, 2592, 0, 40, 0, 1, 0, 1, 2),
  (4009002, 3770, 0, 8, 0, 1, 0, 1, 1),
  (4009002, 1205, 0, 8, 0, 1, 0, 1, 1);
-- Reuse the stock donor's level-appropriate world-drop references when installed.
INSERT INTO `creature_loot_template`
  (`Entry`,`Item`,`Reference`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`)
SELECT 4009002, l.`Item`,l.`Reference`,l.`Chance`,0,l.`LootMode`,l.`GroupId`,l.`MinCount`,l.`MaxCount`
FROM `creature_loot_template` l
WHERE l.`Entry`=431 AND l.`Reference`>=1000000 AND l.`QuestRequired`=0
  AND EXISTS (SELECT 1 FROM `reference_loot_template` r WHERE r.`Entry`=l.`Reference`);
DELETE FROM `creature_template_addon` WHERE `entry` IN (4009006, 4009007, 4009008, 4009009, 4009000, 4009002, 4009056, 4009057, 4009058, 4009059, 4009050, 4009052);
INSERT INTO `creature_template_addon` (`entry`, `emote`) VALUES
  (4009056, 69),
  (4009057, 69),
  (4009058, 69),
  (4009059, 69),
  (4009050, 69),
  (4009052, 69);
INSERT INTO `npc_text` (`ID`, `text0_0`, `Probability0`) VALUES
  (4009056, 'Nala is beside the medical tent. Kang cooks at the hearth, and Kor watches the road. Ask Dezco if you need another antidote or food for the families.', 1),
  (4009057, 'Mei is keeping the relief wagons moving. Ken-Ken is with the families in the small camp southwest of here; follow the road before turning toward their tents.', 1),
  (4009058, 'Ken-Ken tends the families, Kang prepares their medicine, and Maruut studies the well. The provisioner, herbalist and toolkeeper are here among the tents.', 1),
  (4009059, 'Iain welcomes travelers of either banner at this table. You can meet him here without entering Aerie Peak. Take a seat and catch your breath.', 1),
  (4009050, 'Maruut and Ortell are beside the supply wagon. Bring any rescued surveyors to our banner; I will see that they have food and dry blankets.', 1),
  (4009052, 'Papers first. Condenna handles admission and fire trials; Cargall preserves supplicants. Mylva drills body and mind, and Devoran trains the hounds.', 1)
ON DUPLICATE KEY UPDATE
  `text0_0` = VALUES(`text0_0`), `Probability0` = VALUES(`Probability0`);
DELETE FROM `gossip_menu` WHERE `MenuID` IN (4009056, 4009057, 4009058, 4009059, 4009050, 4009052);
INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
  (4009056, 4009056),
  (4009057, 4009057),
  (4009058, 4009058),
  (4009059, 4009059),
  (4009050, 4009050),
  (4009052, 4009052);
UPDATE `creature_template` SET `gossip_menu_id`=`entry` WHERE `entry` IN (4009056, 4009057, 4009058, 4009059, 4009050, 4009052);
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`) VALUES
  (4009162, 5, 7211, 'Mei''s Mudsprocket Relief Station Shelter', 0.8),
  (4009163, 5, 6739, 'Mei''s Mudsprocket Relief Station Bedroll', 1.0),
  (4009164, 5, 581, 'Mei''s Mudsprocket Relief Station Table', 1.0),
  (4009165, 5, 192, 'Mei''s Mudsprocket Relief Station Hearth', 1.0),
  (4009166, 5, 335, 'Mei''s Mudsprocket Relief Station Supplies', 1.0),
  (4009167, 5, 335, 'Mei''s Mudsprocket Relief Station Supplies', 1.0),
  (4009168, 5, 6038, 'Mei''s Mudsprocket Relief Station Lantern', 1.0),
  (4009169, 5, 130, 'Mei''s Mudsprocket Relief Station Rack', 1.0),
  (4009170, 5, 6151, 'Mei''s Mudsprocket Relief Station Boundary', 0.9),
  (4009171, 5, 5191, 'Mei''s Mudsprocket Relief Station Banner', 0.8),
  (4009186, 5, 7211, 'Neutral Wildhammer Gathering Shelter', 0.8),
  (4009187, 5, 7211, 'Neutral Wildhammer Gathering Shelter', 0.8),
  (4009188, 5, 335, 'Neutral Wildhammer Gathering Supplies', 1),
  (4009189, 5, 335, 'Neutral Wildhammer Gathering Supplies', 1),
  (4009190, 5, 6038, 'Neutral Wildhammer Gathering Lighting', 1),
  (4009191, 5, 6038, 'Neutral Wildhammer Gathering Lighting', 1),
  (4009192, 5, 581, 'Neutral Wildhammer Gathering Workstation', 1),
  (4009193, 5, 130, 'Neutral Wildhammer Gathering Equipment', 1),
  (4009194, 5, 6739, 'Neutral Wildhammer Gathering Sleeping', 1),
  (4009195, 5, 5191, 'Neutral Wildhammer Gathering Identity', 0.8),
  (4009200, 5, 7211, 'Vale Expedition and Refuge Shelter', 0.6),
  (4009201, 5, 6739, 'Vale Expedition and Refuge Sleeping', 0.8),
  (4009202, 5, 335, 'Vale Expedition and Refuge Supplies', 0.8),
  (4009203, 5, 6038, 'Vale Expedition and Refuge Lighting', 0.8),
  (4009204, 5, 581, 'Vale Expedition and Refuge Workstation', 0.9),
  (4009205, 5, 192, 'Vale Expedition and Refuge Cooking', 0.8),
  (4009206, 5, 5191, 'Vale Expedition and Refuge Identity', 0.7),
  (4009207, 5, 7253, 'Twilight Recruiting Compound Shelter', 0.48),
  (4009208, 5, 7254, 'Twilight Recruiting Compound Shelter', 0.45),
  (4009209, 5, 6737, 'Twilight Recruiting Compound Supplies', 0.6),
  (4009210, 5, 6737, 'Twilight Recruiting Compound Supplies', 0.6),
  (4009211, 5, 7255, 'Twilight Recruiting Compound Lighting', 0.7),
  (4009212, 5, 7255, 'Twilight Recruiting Compound Lighting', 0.7),
  (4009213, 5, 581, 'Twilight Recruiting Compound Workstation', 0.9),
  (4009214, 5, 130, 'Twilight Recruiting Compound Equipment', 0.8),
  (4009215, 5, 335, 'Twilight Recruiting Compound Medicine', 0.7),
  (4009216, 5, 7261, 'Twilight Recruiting Compound Identity', 0.6),
  (4009217, 5, 6739, 'Twilight Recruiting Compound Sleeping', 0.8),
  (4009300, 5, 7211, 'Dawnchaser Field Camp Shelter', 0.75),
  (4009301, 5, 6739, 'Dawnchaser Field Camp Sleeping', 0.8),
  (4009302, 5, 6739, 'Dawnchaser Field Camp Sleeping', 0.8),
  (4009303, 5, 335, 'Dawnchaser Field Camp Supplies', 0.8),
  (4009304, 5, 335, 'Dawnchaser Field Camp Supplies', 0.8),
  (4009305, 5, 6038, 'Dawnchaser Field Camp Lighting', 0.9),
  (4009306, 5, 6038, 'Dawnchaser Field Camp Lighting', 0.9),
  (4009307, 5, 581, 'Dawnchaser Field Camp Workstation', 0.9),
  (4009308, 5, 130, 'Dawnchaser Field Camp Equipment', 0.8),
  (4009309, 5, 5191, 'Dawnchaser Field Camp Identity', 0.7),
  (4009310, 5, 7211, 'Southern Village Relief Camp Shelter', 0.75),
  (4009311, 5, 6739, 'Southern Village Relief Camp Sleeping', 0.8),
  (4009312, 5, 6739, 'Southern Village Relief Camp Sleeping', 0.8),
  (4009313, 5, 335, 'Southern Village Relief Camp Supplies', 0.8),
  (4009314, 5, 335, 'Southern Village Relief Camp Supplies', 0.8),
  (4009315, 5, 6038, 'Southern Village Relief Camp Lighting', 0.9),
  (4009316, 5, 6038, 'Southern Village Relief Camp Lighting', 0.9),
  (4009317, 5, 581, 'Southern Village Relief Camp Workstation', 0.9),
  (4009318, 5, 130, 'Southern Village Relief Camp Equipment', 0.8),
  (4009319, 5, 5191, 'Southern Village Relief Camp Identity', 0.7),
  (4009320, 5, 7211, 'Southern Village Relief Camp Shelter', 0.65),
  (4009218, 5, 7253, 'Twilight Ritual Compound Shelter', 0.5),
  (4009219, 5, 6737, 'Twilight Ritual Compound Supplies', 0.6),
  (4009220, 5, 7255, 'Twilight Ritual Compound Lighting', 0.7),
  (4009221, 5, 7261, 'Twilight Ritual Compound Identity', 0.6),
  (4009222, 5, 6419, 'Twilight Ritual Compound Workstation', 0.8),
  (4009223, 5, 6431, 'Twilight Ritual Compound Ward', 0.4)
ON DUPLICATE KEY UPDATE
  `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `size` = VALUES(`size`);
INSERT INTO `gameobject_template_addon` (`entry`, `flags`) VALUES
  (4009162, 16),
  (4009163, 16),
  (4009164, 16),
  (4009165, 16),
  (4009166, 16),
  (4009167, 16),
  (4009168, 16),
  (4009169, 16),
  (4009170, 16),
  (4009171, 16),
  (4009186, 16),
  (4009187, 16),
  (4009188, 16),
  (4009189, 16),
  (4009190, 16),
  (4009191, 16),
  (4009192, 16),
  (4009193, 16),
  (4009194, 16),
  (4009195, 16),
  (4009200, 16),
  (4009201, 16),
  (4009202, 16),
  (4009203, 16),
  (4009204, 16),
  (4009205, 16),
  (4009206, 16),
  (4009207, 16),
  (4009208, 16),
  (4009209, 16),
  (4009210, 16),
  (4009211, 16),
  (4009212, 16),
  (4009213, 16),
  (4009214, 16),
  (4009215, 16),
  (4009216, 16),
  (4009217, 16),
  (4009300, 16),
  (4009301, 16),
  (4009302, 16),
  (4009303, 16),
  (4009304, 16),
  (4009305, 16),
  (4009306, 16),
  (4009307, 16),
  (4009308, 16),
  (4009309, 16),
  (4009310, 16),
  (4009311, 16),
  (4009312, 16),
  (4009313, 16),
  (4009314, 16),
  (4009315, 16),
  (4009316, 16),
  (4009317, 16),
  (4009318, 16),
  (4009319, 16),
  (4009320, 16),
  (4009218, 16),
  (4009219, 16),
  (4009220, 16),
  (4009221, 16),
  (4009222, 16),
  (4009223, 16)
ON DUPLICATE KEY UPDATE
  `flags` = VALUES(`flags`);
DROP TEMPORARY TABLE IF EXISTS `bs_hub_creature_spawns`;
CREATE TEMPORARY TABLE `bs_hub_creature_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `map` SMALLINT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
DROP TEMPORARY TABLE IF EXISTS `bs_hub_gameobject_spawns`;
CREATE TEMPORARY TABLE `bs_hub_gameobject_spawns` (`spawn_key` VARCHAR(100) PRIMARY KEY, `entry` INT UNSIGNED, `map` SMALLINT UNSIGNED, `zone` INT UNSIGNED, `x` FLOAT, `y` FLOAT, `z` FLOAT, `o` FLOAT) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `bs_hub_creature_spawns` (`spawn_key`, `entry`, `map`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-HUB:4009006:0', 4009006, 1, 15, -3990, -3358, 39.98269612360333, 0),
  ('BS-HUB:4009006:1', 4009006, 1, 15, -3950, -3342, 39.02451414598363, 0),
  ('BS-HUB:4009007:0', 4009007, 1, 15, -4538.88, -3244.82, 31.536760496289812, -2.7377328586824166),
  ('BS-HUB:4009007:1', 4009007, 1, 15, -4523.3, -3229.0, 31.471600554899407, 0.4738513364947603),
  ('BS-HUB:4009008:0', 4009008, 1, 15, -4597.0, -3257.0, 30.569009812932144, 0),
  ('BS-HUB:4009008:1', 4009008, 1, 15, -4563.0, -3249.0, 30.629841571377252, 0),
  ('BS-HUB:4009009:0', 4009009, 0, 47, 62.0, -2059.0, 136.529, 0),
  ('BS-HUB:4009009:1', 4009009, 0, 47, 98.4288, -2050.31, 113.968, 0),
  ('BS-HUB:4009000:0', 4009000, 1, 406, 1088.0, 1528.0, 27.761279170884507, 0),
  ('BS-HUB:4009000:1', 4009000, 1, 406, 1112.0, 1552.0, 33.01090127549298, 0),
  ('BS-HUB:4009002:0', 4009002, 1, 406, 628, 1614, -16.013777396168027, 0),
  ('BS-HUB:4009002:1', 4009002, 1, 406, 652, 1634, -18.07020276633058, 0),
  ('BS-HUB:4009056:0', 4009056, 1, 15, -3970, -3366, 38.46056030675433, 0),
  ('BS-HUB:4009057:0', 4009057, 1, 15, -4528.53, -3228.39, 31.033901026964227, 3.141592653589793),
  ('BS-HUB:4009058:0', 4009058, 1, 15, -4581.0, -3265.0, 32.9671003386268, 0),
  ('BS-HUB:4009059:0', 4009059, 0, 47, 77.2666, -2068.4, 115.269, 0),
  ('BS-HUB:4009050:0', 4009050, 1, 406, 1098.0, 1546.0, 26.76780512927955, 0),
  ('BS-HUB:4009052:0', 4009052, 1, 406, 640, 1618, -17.657040281969092, 0);
INSERT INTO `bs_hub_gameobject_spawns` (`spawn_key`, `entry`, `map`, `zone`, `x`, `y`, `z`, `o`) VALUES
  ('BS-HUB:wayside_shelter_0', 4009162, 1, 15, -4554.4, -3242.61, 30.611652701467065, 0.0),
  ('BS-HUB:wayside_bedroll_1', 4009163, 1, 15, -4540.27, -3223.47, 30.71857401148607, 0.0),
  ('BS-HUB:wayside_table_2', 4009164, 1, 15, -4530.61, -3228.39, 30.781079476144694, 0.0),
  ('BS-HUB:wayside_hearth_3', 4009165, 1, 15, -4530.88, -3241.44, 30.789205479715122, 0.0),
  ('BS-HUB:wayside_supplies_4', 4009166, 1, 15, -4538.99, -3241.01, 30.686144621048175, 0.0),
  ('BS-HUB:wayside_supplies_5', 4009167, 1, 15, -4537.0, -3241.0, 31.272834616461672, 0.0),
  ('BS-HUB:wayside_lantern_6', 4009168, 1, 15, -4525.07, -3230.67, 30.719709359968537, 0.0),
  ('BS-HUB:wayside_rack_7', 4009169, 1, 15, -4541.03, -3243.97, 30.692722179857057, 0.0),
  ('BS-HUB:wayside_boundary_8', 4009170, 1, 15, -4523.14, -3243.63, 30.775629270403766, 0.0),
  ('BS-HUB:wayside_banner_9', 4009171, 1, 15, -4536.77, -3225.62, 30.701033410469293, 0.0),
  ('BS-HUB:wildhammer_shelter_4009186', 4009186, 0, 47, 86.5851, -2062.79, 113.09, 0),
  ('BS-HUB:wildhammer_shelter_4009187', 4009187, 0, 47, 98.3977, -2036.04, 116.408, 0),
  ('BS-HUB:wildhammer_supplies_4009188', 4009188, 0, 47, 78.8103, -2033.85, 118.38, 0),
  ('BS-HUB:wildhammer_supplies_4009189', 4009189, 0, 47, 65.4668, -2042.26, 138.684, 0),
  ('BS-HUB:wildhammer_lighting_4009190', 4009190, 0, 47, 61.0748, -2037.42, 138.511, 0),
  ('BS-HUB:wildhammer_lighting_4009191', 4009191, 0, 47, 60.0546, -2050.45, 140.686, 0),
  ('BS-HUB:wildhammer_workstation_4009192', 4009192, 0, 47, 88.3774, -2039.65, 115.847, 0),
  ('BS-HUB:wildhammer_equipment_4009193', 4009193, 0, 47, 61.9478, -2046.04, 139.762, 0),
  ('BS-HUB:wildhammer_sleeping_4009194', 4009194, 0, 47, 93.9429, -2055.17, 113.109, 0),
  ('BS-HUB:wildhammer_identity_4009195', 4009195, 0, 47, 83.9936, -2041.24, 116.172, 0),
  ('BS-HUB:expedition_shelter_4009200', 4009200, 1, 406, 1106.1192129074211, 1535.8803162119398, 27.659685210352666, 0),
  ('BS-HUB:expedition_sleeping_4009201', 4009201, 1, 406, 1095.135582418349, 1545.6081914852743, 25.180867550783276, 0),
  ('BS-HUB:expedition_supplies_4009202', 4009202, 1, 406, 1104.6239280009008, 1551.1526879854885, 30.648744593760732, 0),
  ('BS-HUB:expedition_lighting_4009203', 4009203, 1, 406, 1105.257558205009, 1540.8328518088642, 27.55423436009303, 0),
  ('BS-HUB:expedition_workstation_4009204', 4009204, 1, 406, 1089.867166041044, 1532.3217474804032, 25.86576748292283, 0),
  ('BS-HUB:expedition_cooking_4009205', 4009205, 1, 406, 1101.5395558392568, 1531.4348401958255, 27.581286577049248, 0),
  ('BS-HUB:expedition_identity_4009206', 4009206, 1, 406, 1098.2470331251745, 1527.5583942779037, 28.536988266240723, 0),
  ('BS-HUB:selection_shelter_4009207', 4009207, 1, 406, 641.2369940769273, 1611.2852760590692, -17.36612073932697, 0),
  ('BS-HUB:selection_shelter_4009208', 4009208, 1, 406, 641.164448001601, 1635.1760313801033, -17.48919715092978, 0),
  ('BS-HUB:selection_supplies_4009209', 4009209, 1, 406, 651.2744639942374, 1630.7634752302658, -18.16105170525925, 0),
  ('BS-HUB:selection_supplies_4009210', 4009210, 1, 406, 631.4477794365837, 1632.7929811070812, -17.41697441443699, 0),
  ('BS-HUB:selection_lighting_4009211', 4009211, 1, 406, 628.833908127005, 1631.8589257186438, -16.888722490642557, 0),
  ('BS-HUB:selection_lighting_4009212', 4009212, 1, 406, 632.7832011386972, 1637.6535242356438, -17.514644516861292, 0),
  ('BS-HUB:selection_workstation_4009213', 4009213, 1, 406, 630.6027449804797, 1621.0035600412555, -17.320151063113652, 0),
  ('BS-HUB:selection_equipment_4009214', 4009214, 1, 406, 632.9834330729831, 1633.6397412170115, -17.476662061102125, 0),
  ('BS-HUB:selection_medicine_4009215', 4009215, 1, 406, 633.0724631284171, 1620.885425059895, -17.411320752896696, 0),
  ('BS-HUB:selection_identity_4009216', 4009216, 1, 406, 634.5595159620635, 1640.0182156286346, -17.79260575626349, 0),
  ('BS-HUB:selection_sleeping_4009217', 4009217, 1, 406, 645.9881397013855, 1614.5453397260367, -19.179125005445723, 0),
  ('BS-HUB:dawnchasers_shelter_4009300', 4009300, 1, 15, -3954.720932938713, -3354.166127829363, 38.58686039274206, 0),
  ('BS-HUB:dawnchasers_sleeping_4009301', 4009301, 1, 15, -3984.1125558125086, -3362.9333291095795, 39.58166230624587, 0),
  ('BS-HUB:dawnchasers_sleeping_4009302', 4009302, 1, 15, -3959.0595683588194, -3357.6928670555058, 37.344242228024434, 0),
  ('BS-HUB:dawnchasers_supplies_4009303', 4009303, 1, 15, -3969.5354350386983, -3369.368195493438, 38.682232919725, 0),
  ('BS-HUB:dawnchasers_supplies_4009304', 4009304, 1, 15, -3963.711771267976, -3333.1584917988307, 38.043023772725924, 0),
  ('BS-HUB:dawnchasers_lighting_4009305', 4009305, 1, 15, -3963.8113445430113, -3364.209428114368, 38.136607113236096, 0),
  ('BS-HUB:dawnchasers_lighting_4009306', 4009306, 1, 15, -3987.520307044563, -3353.089981642616, 40.18517974644807, 0),
  ('BS-HUB:dawnchasers_workstation_4009307', 4009307, 1, 15, -3962.6641029850916, -3366.5071008849004, 38.33203513915926, 0),
  ('BS-HUB:dawnchasers_equipment_4009308', 4009308, 1, 15, -3985.0024306131204, -3337.8504035175306, 37.12120910444281, 0),
  ('BS-HUB:dawnchasers_identity_4009309', 4009309, 1, 15, -3978.285513584099, -3329.6921219234173, 36.815589185017245, 0),
  ('BS-HUB:village_shelter_4009310', 4009310, 1, 15, -4580.954851959627, -3239.3267953621225, 34.78600911119471, 0),
  ('BS-HUB:village_sleeping_4009311', 4009311, 1, 15, -4593.683123277465, -3254.8522210083875, 29.665985587549528, 0),
  ('BS-HUB:village_sleeping_4009312', 4009312, 1, 15, -4592.172052715965, -3256.792818726058, 29.560526836006705, 0),
  ('BS-HUB:village_supplies_4009313', 4009313, 1, 15, -4584.798766013494, -3233.9607278445633, 34.92502355506392, 0),
  ('BS-HUB:village_supplies_4009314', 4009314, 1, 15, -4577.665544540801, -3263.10016314385, 33.52505135769071, 0),
  ('BS-HUB:village_lighting_4009315', 4009315, 1, 15, -4588.464938488578, -3234.0370429485292, 34.92921795508107, 0),
  ('BS-HUB:village_lighting_4009316', 4009316, 1, 15, -4595.139619173372, -3251.331874549655, 31.513734053167973, 0),
  ('BS-HUB:village_workstation_4009317', 4009317, 1, 15, -4588.4148244544585, -3236.1818219176944, 34.923141388909926, 0),
  ('BS-HUB:village_equipment_4009318', 4009318, 1, 15, -4572.378782616223, -3250.292933552279, 32.21009538000764, 0),
  ('BS-HUB:village_identity_4009319', 4009319, 1, 15, -4575.326992545862, -3240.515617070019, 34.89823692172803, 0),
  ('BS-HUB:village_shelter_4009320', 4009320, 1, 15, -4568.643642453909, -3250.914741838209, 31.5231804330702, 0),
  ('BS-HUB:holding_shelter_4009218', 4009218, 1, 406, 904.1504280618537, 1686.4200998281256, -18.31167455071136, 0),
  ('BS-HUB:holding_supplies_4009219', 4009219, 1, 406, 887.7563271365315, 1667.8982813080459, -17.517690671783146, 0),
  ('BS-HUB:holding_lighting_4009220', 4009220, 1, 406, 879.1210592712869, 1669.3055838991986, -18.230569062900564, 0),
  ('BS-HUB:holding_identity_4009221', 4009221, 1, 406, 887.7627916458168, 1693.2820748385043, -18.585902042375384, 0),
  ('BS-HUB:holding_workstation_4009222', 4009222, 1, 406, 890.9035682673043, 1696.2878787039203, -17.558038891300832, 0),
  ('BS-HUB:holding_ward_4009223', 4009223, 1, 406, 879.2774500576339, 1685.4047303595542, -19.491394920361806, 0);
SET @BS_HUB_ENTRY_COLUMN := (
  SELECT `COLUMN_NAME` FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = 'creature' AND `COLUMN_NAME` IN ('id1', 'id')
  ORDER BY `COLUMN_NAME` DESC LIMIT 1
);
SET @BS_HUB_INSERT := CONCAT(
  'INSERT INTO `creature` (`', @BS_HUB_ENTRY_COLUMN, '`, `map`, `zoneId`, `spawnMask`, `phaseMask`, ',
  '`position_x`, `position_y`, `position_z`, `orientation`, `equipment_id`, `spawntimesecs`, `curhealth`, `curmana`, `Comment`) ',
  'SELECT s.`entry`, s.`map`, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, -1, 60, 0, 0, s.`spawn_key` ',
  'FROM `bs_hub_creature_spawns` s LEFT JOIN `creature` c ON c.`Comment` = s.`spawn_key` WHERE c.`guid` IS NULL'
);
PREPARE bs_hub_stmt FROM @BS_HUB_INSERT;
EXECUTE bs_hub_stmt;
DEALLOCATE PREPARE bs_hub_stmt;
SET @BS_HUB_UPDATE := CONCAT(
  'UPDATE `creature` c INNER JOIN `bs_hub_creature_spawns` s ON c.`Comment` = s.`spawn_key` ',
  'SET c.`', @BS_HUB_ENTRY_COLUMN, '` = s.`entry`, c.`map` = s.`map`, c.`zoneId` = s.`zone`, c.`position_x` = s.`x`, ',
  'c.`position_y` = s.`y`, c.`position_z` = s.`z`, c.`orientation` = s.`o`, c.`equipment_id` = -1'
);
PREPARE bs_hub_stmt FROM @BS_HUB_UPDATE;
EXECUTE bs_hub_stmt;
DEALLOCATE PREPARE bs_hub_stmt;
INSERT INTO `gameobject`
  (`id`, `map`, `zoneId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`,
   `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `Comment`)
SELECT s.`entry`, s.`map`, s.`zone`, 1, 1, s.`x`, s.`y`, s.`z`, s.`o`, SIN(s.`o` / 2), COS(s.`o` / 2), 60, 100, 1, s.`spawn_key`
FROM `bs_hub_gameobject_spawns` s LEFT JOIN `gameobject` g ON g.`Comment` = s.`spawn_key` WHERE g.`guid` IS NULL;
UPDATE `gameobject` g INNER JOIN `bs_hub_gameobject_spawns` s ON g.`Comment` = s.`spawn_key`
SET g.`id` = s.`entry`, g.`map`=s.`map`, g.`zoneId`=s.`zone`, g.`position_x` = s.`x`, g.`position_y` = s.`y`, g.`position_z` = s.`z`, g.`orientation` = s.`o`,
  g.`rotation2` = SIN(s.`o` / 2), g.`rotation3` = COS(s.`o` / 2);
DROP TEMPORARY TABLE IF EXISTS `bs_hub_native_moves`;
CREATE TEMPORARY TABLE `bs_hub_native_moves` (`guid` INT UNSIGNED PRIMARY KEY, `entry` INT UNSIGNED, `map` SMALLINT UNSIGNED,
  `ox` FLOAT, `oy` FLOAT, `oz` FLOAT, `oo` FLOAT, `nx` FLOAT, `ny` FLOAT, `nz` FLOAT, `no` FLOAT);
-- Claim only the audited original spawn: changed realm placements are left alone.
SET @BS_HUB_BACKUP := CONCAT(
 'INSERT IGNORE INTO `mod_customnpcs_bs_hub_native` (`guid`,`entry`,`map`,`x`,`y`,`z`,`o`,`applied_x`,`applied_y`,`applied_z`,`applied_o`) ',
 'SELECT c.`guid`,m.`entry`,c.`map`,c.`position_x`,c.`position_y`,c.`position_z`,c.`orientation`,m.`nx`,m.`ny`,m.`nz`,m.`no` ',
 'FROM `creature` c INNER JOIN `bs_hub_native_moves` m ON c.`guid`=m.`guid` INNER JOIN `creature_template` t ON t.`entry`=m.`entry` ',
 'WHERE c.`',@BS_HUB_ENTRY_COLUMN,'`=m.`entry` AND c.`map`=m.`map` AND ',
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
-- Track a successfully applied revised clearance while retaining the original home for restoration.
SET @BS_HUB_TRACK := CONCAT(
 'UPDATE `mod_customnpcs_bs_hub_native` b INNER JOIN `bs_hub_native_moves` m ON m.`guid`=b.`guid` AND m.`entry`=b.`entry` ',
 'INNER JOIN `creature` c ON c.`guid`=b.`guid` ',
 'SET b.`applied_x`=m.`nx`,b.`applied_y`=m.`ny`,b.`applied_z`=m.`nz`,b.`applied_o`=m.`no` ',
 'WHERE c.`',@BS_HUB_ENTRY_COLUMN,'`=m.`entry` AND c.`map`=b.`map` AND ',
 'ABS(c.`position_x`-m.`nx`)<0.1 AND ABS(c.`position_y`-m.`ny`)<0.1 AND ABS(c.`position_z`-m.`nz`)<0.1'
);
PREPARE bs_hub_stmt FROM @BS_HUB_TRACK;
EXECUTE bs_hub_stmt;
DEALLOCATE PREPARE bs_hub_stmt;
DELETE FROM `creature` WHERE `Comment` IN ('BS-HUB:expedition_shelter_0', 'BS-HUB:expedition_bedroll_1', 'BS-HUB:expedition_supplies_2', 'BS-HUB:expedition_supplies_3', 'BS-HUB:expedition_table_4', 'BS-HUB:expedition_rack_5', 'BS-HUB:expedition_hearth_6', 'BS-HUB:expedition_lantern_7', 'BS-HUB:expedition_lantern_8', 'BS-HUB:expedition_boundary_9', 'BS-HUB:expedition_banner_10', 'BS-HUB:refuge_shelter_0', 'BS-HUB:refuge_bedroll_1', 'BS-HUB:refuge_bedroll_2', 'BS-HUB:refuge_medicine_3', 'BS-HUB:refuge_supplies_4', 'BS-HUB:refuge_lantern_5', 'BS-HUB:refuge_boundary_6', 'BS-HUB:selection_cult_shelter_0', 'BS-HUB:selection_bedroll_1', 'BS-HUB:selection_supplies_2', 'BS-HUB:selection_table_3', 'BS-HUB:selection_lantern_4', 'BS-HUB:selection_boundary_5', 'BS-HUB:supplicants_cult_shelter_0', 'BS-HUB:supplicants_medicine_1', 'BS-HUB:supplicants_table_2', 'BS-HUB:supplicants_supplies_3', 'BS-HUB:supplicants_lantern_4', 'BS-HUB:supplicants_boundary_5', 'BS-HUB:instruction_cult_shelter_0', 'BS-HUB:instruction_bedroll_1', 'BS-HUB:instruction_table_2', 'BS-HUB:instruction_rack_3', 'BS-HUB:instruction_lantern_4', 'BS-HUB:instruction_supplies_5', 'BS-HUB:instruction_boundary_6', 'BS-HUB:kennels_cult_shelter_0', 'BS-HUB:kennels_bedroll_1', 'BS-HUB:kennels_supplies_2', 'BS-HUB:kennels_supplies_3', 'BS-HUB:kennels_rack_4', 'BS-HUB:kennels_lantern_5', 'BS-HUB:kennels_boundary_6', 'BS-HUB:4009001:0', 'BS-HUB:4009001:1', 'BS-HUB:4009003:0', 'BS-HUB:4009003:1', 'BS-HUB:4009004:0', 'BS-HUB:4009004:1', 'BS-HUB:4009005:0', 'BS-HUB:4009005:1', 'BS-HUB:4009051:0', 'BS-HUB:4009053:0', 'BS-HUB:4009054:0', 'BS-HUB:4009055:0', 'BS-HUB:dawnchasers_shelter_0', 'BS-HUB:dawnchasers_bedroll_1', 'BS-HUB:dawnchasers_bedroll_2', 'BS-HUB:dawnchasers_shelter_3', 'BS-HUB:dawnchasers_bedroll_4', 'BS-HUB:dawnchasers_bedroll_5', 'BS-HUB:dawnchasers_supplies_6', 'BS-HUB:dawnchasers_supplies_7', 'BS-HUB:dawnchasers_medicine_8', 'BS-HUB:dawnchasers_medicine_9', 'BS-HUB:dawnchasers_table_10', 'BS-HUB:dawnchasers_rack_11', 'BS-HUB:dawnchasers_lantern_12', 'BS-HUB:dawnchasers_lantern_13', 'BS-HUB:dawnchasers_lantern_14', 'BS-HUB:dawnchasers_boundary_15', 'BS-HUB:dawnchasers_boundary_16', 'BS-HUB:dawnchasers_banner_17', 'BS-HUB:village_shelter_4009172', 'BS-HUB:village_shelter_4009173', 'BS-HUB:village_supplies_4009174', 'BS-HUB:village_supplies_4009175', 'BS-HUB:village_lighting_4009176', 'BS-HUB:village_lighting_4009177', 'BS-HUB:village_workstation_4009178', 'BS-HUB:village_equipment_4009179', 'BS-HUB:village_sleeping_4009180', 'BS-HUB:village_identity_4009181', 'BS-HUB:village_shelter_4009182', 'BS-HUB:village_sleeping_4009183', 'BS-HUB:village_supplies_4009184', 'BS-HUB:village_lighting_4009185');
DELETE FROM `gameobject` WHERE `Comment` IN ('BS-HUB:expedition_shelter_0', 'BS-HUB:expedition_bedroll_1', 'BS-HUB:expedition_supplies_2', 'BS-HUB:expedition_supplies_3', 'BS-HUB:expedition_table_4', 'BS-HUB:expedition_rack_5', 'BS-HUB:expedition_hearth_6', 'BS-HUB:expedition_lantern_7', 'BS-HUB:expedition_lantern_8', 'BS-HUB:expedition_boundary_9', 'BS-HUB:expedition_banner_10', 'BS-HUB:refuge_shelter_0', 'BS-HUB:refuge_bedroll_1', 'BS-HUB:refuge_bedroll_2', 'BS-HUB:refuge_medicine_3', 'BS-HUB:refuge_supplies_4', 'BS-HUB:refuge_lantern_5', 'BS-HUB:refuge_boundary_6', 'BS-HUB:selection_cult_shelter_0', 'BS-HUB:selection_bedroll_1', 'BS-HUB:selection_supplies_2', 'BS-HUB:selection_table_3', 'BS-HUB:selection_lantern_4', 'BS-HUB:selection_boundary_5', 'BS-HUB:supplicants_cult_shelter_0', 'BS-HUB:supplicants_medicine_1', 'BS-HUB:supplicants_table_2', 'BS-HUB:supplicants_supplies_3', 'BS-HUB:supplicants_lantern_4', 'BS-HUB:supplicants_boundary_5', 'BS-HUB:instruction_cult_shelter_0', 'BS-HUB:instruction_bedroll_1', 'BS-HUB:instruction_table_2', 'BS-HUB:instruction_rack_3', 'BS-HUB:instruction_lantern_4', 'BS-HUB:instruction_supplies_5', 'BS-HUB:instruction_boundary_6', 'BS-HUB:kennels_cult_shelter_0', 'BS-HUB:kennels_bedroll_1', 'BS-HUB:kennels_supplies_2', 'BS-HUB:kennels_supplies_3', 'BS-HUB:kennels_rack_4', 'BS-HUB:kennels_lantern_5', 'BS-HUB:kennels_boundary_6', 'BS-HUB:4009001:0', 'BS-HUB:4009001:1', 'BS-HUB:4009003:0', 'BS-HUB:4009003:1', 'BS-HUB:4009004:0', 'BS-HUB:4009004:1', 'BS-HUB:4009005:0', 'BS-HUB:4009005:1', 'BS-HUB:4009051:0', 'BS-HUB:4009053:0', 'BS-HUB:4009054:0', 'BS-HUB:4009055:0', 'BS-HUB:dawnchasers_shelter_0', 'BS-HUB:dawnchasers_bedroll_1', 'BS-HUB:dawnchasers_bedroll_2', 'BS-HUB:dawnchasers_shelter_3', 'BS-HUB:dawnchasers_bedroll_4', 'BS-HUB:dawnchasers_bedroll_5', 'BS-HUB:dawnchasers_supplies_6', 'BS-HUB:dawnchasers_supplies_7', 'BS-HUB:dawnchasers_medicine_8', 'BS-HUB:dawnchasers_medicine_9', 'BS-HUB:dawnchasers_table_10', 'BS-HUB:dawnchasers_rack_11', 'BS-HUB:dawnchasers_lantern_12', 'BS-HUB:dawnchasers_lantern_13', 'BS-HUB:dawnchasers_lantern_14', 'BS-HUB:dawnchasers_boundary_15', 'BS-HUB:dawnchasers_boundary_16', 'BS-HUB:dawnchasers_banner_17', 'BS-HUB:village_shelter_4009172', 'BS-HUB:village_shelter_4009173', 'BS-HUB:village_supplies_4009174', 'BS-HUB:village_supplies_4009175', 'BS-HUB:village_lighting_4009176', 'BS-HUB:village_lighting_4009177', 'BS-HUB:village_workstation_4009178', 'BS-HUB:village_equipment_4009179', 'BS-HUB:village_sleeping_4009180', 'BS-HUB:village_identity_4009181', 'BS-HUB:village_shelter_4009182', 'BS-HUB:village_sleeping_4009183', 'BS-HUB:village_supplies_4009184', 'BS-HUB:village_lighting_4009185');
DROP TEMPORARY TABLE `bs_hub_creature_spawns`;
DROP TEMPORARY TABLE `bs_hub_gameobject_spawns`;
DROP TEMPORARY TABLE `bs_hub_native_moves`;
DROP TEMPORARY TABLE `bs_hub_ids`;
COMMIT;
