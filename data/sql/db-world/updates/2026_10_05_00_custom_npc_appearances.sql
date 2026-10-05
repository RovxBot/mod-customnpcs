-- mod-customNPCs: reusable player-style NPC appearances.
-- Safe to re-run: no outfit, assignment, existing NPC, or spawn is overwritten.
-- Armor: 0 = hidden, positive = item entry, negative = ItemDisplayInfo.dbc ID.
-- Weapons: 0 = hidden, positive = Item.dbc entry (never a display ID).
CREATE TABLE IF NOT EXISTS `mod_customnpcs_outfit` (
  `outfit_id` INT UNSIGNED NOT NULL,
  `race` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `gender` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `class` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `skin` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `face` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `hair` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `hair_color` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `facial_hair` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `guild_id` INT UNSIGNED NOT NULL DEFAULT 0,
  `head` INT NOT NULL DEFAULT 0,
  `shoulders` INT NOT NULL DEFAULT 0,
  `shirt` INT NOT NULL DEFAULT 0,
  `chest` INT NOT NULL DEFAULT 0,
  `waist` INT NOT NULL DEFAULT 0,
  `legs` INT NOT NULL DEFAULT 0,
  `feet` INT NOT NULL DEFAULT 0,
  `wrists` INT NOT NULL DEFAULT 0,
  `hands` INT NOT NULL DEFAULT 0,
  `back` INT NOT NULL DEFAULT 0,
  `tabard` INT NOT NULL DEFAULT 0,
  `mainhand` INT UNSIGNED NOT NULL DEFAULT 0,
  `offhand` INT UNSIGNED NOT NULL DEFAULT 0,
  `ranged` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`outfit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Module commands use security level 3; these rows supply in-game syntax help.
DELETE FROM `command` WHERE `name` IN (
  'customnpc outfit create', 'customnpc outfit capture', 'customnpc outfit set',
  'customnpc outfit apply', 'customnpc outfit spawn', 'customnpc outfit clear',
  'customnpc outfit clearspawn', 'customnpc outfit info', 'customnpc outfit reload'
);
INSERT INTO `command` (`name`, `security`, `help`) VALUES
('customnpc outfit create', 3, 'Syntax: .customnpc outfit create <id> <race> <gender>\nCreate an unused nonzero outfit ID. Gender: 0 male, 1 female. WotLK races: 1-8, 10, 11.'),
('customnpc outfit capture', 3, 'Syntax: .customnpc outfit capture <id>\nCreate or overwrite an outfit with your equipped character appearance.'),
('customnpc outfit set', 3, 'Syntax: .customnpc outfit set <id> <field> <value>\nFields: race gender class skin face hair hair_color facial_hair guild_id head shoulders shirt chest waist legs feet wrists hands back tabard mainhand offhand ranged. Armor: item entry, negative display ID, or 0 to hide. Weapons: item entry or 0.'),
('customnpc outfit apply', 3, 'Syntax: .customnpc outfit apply <id>\nAssign an outfit to every spawn of the selected NPC entry. Spawn overrides take priority.'),
('customnpc outfit spawn', 3, 'Syntax: .customnpc outfit spawn <id>\nOverride only the selected saved spawn. ID 0 keeps its original appearance.'),
('customnpc outfit clear', 3, 'Syntax: .customnpc outfit clear\nRemove the selected NPC entry assignment. Spawn overrides remain.'),
('customnpc outfit clearspawn', 3, 'Syntax: .customnpc outfit clearspawn\nRemove the selected spawn override and use its entry assignment again.'),
('customnpc outfit info', 3, 'Syntax: .customnpc outfit info\nShow the selected NPC entry, spawn GUID, current model, and assigned outfit.'),
('customnpc outfit reload', 3, 'Syntax: .customnpc outfit reload\nReload outfit definitions and assignments. Loaded NPCs refresh on their next update.');

CREATE TABLE IF NOT EXISTS `mod_customnpcs_outfit_entry` (
  `creature_entry` INT UNSIGNED NOT NULL,
  `outfit_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`creature_entry`),
  KEY `idx_outfit_id` (`outfit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Spawn overrides win over entry assignments. An outfit_id of 0 explicitly
-- preserves the original appearance for this spawn, even when its entry is dressed.
CREATE TABLE IF NOT EXISTS `mod_customnpcs_outfit_spawn` (
  `spawn_guid` INT UNSIGNED NOT NULL,
  `outfit_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`spawn_guid`),
  KEY `idx_outfit_id` (`outfit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
