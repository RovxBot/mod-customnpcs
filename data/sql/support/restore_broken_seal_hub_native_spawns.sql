-- Optional, manual restoration of the hub add-on's native spawn clearances.
-- Backups are retained. Administrator changes after installation are preserved.
-- Disable ModCustomNPCs.BrokenSeal.Hubs.Enable and restart after applying if retiring the add-on.
SET @BS_HUB_RESTORE_COLUMN := (
  SELECT `COLUMN_NAME` FROM `information_schema`.`COLUMNS`
  WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`='creature' AND `COLUMN_NAME` IN ('id1','id')
  ORDER BY `COLUMN_NAME` DESC LIMIT 1
);
SET @BS_HUB_RESTORE := CONCAT(
 'UPDATE `creature` c INNER JOIN `mod_customnpcs_bs_hub_native` b ON c.`guid`=b.`guid` ',
 'SET c.`position_x`=b.`x`,c.`position_y`=b.`y`,c.`position_z`=b.`z`,c.`orientation`=b.`o` ',
 'WHERE c.`',@BS_HUB_RESTORE_COLUMN,'`=b.`entry` AND c.`map`=b.`map` AND ',
 'ABS(c.`position_x`-b.`applied_x`)<0.1 AND ABS(c.`position_y`-b.`applied_y`)<0.1 AND ABS(c.`position_z`-b.`applied_z`)<0.1'
);
START TRANSACTION;
PREPARE bs_hub_restore FROM @BS_HUB_RESTORE;
EXECUTE bs_hub_restore;
DEALLOCATE PREPARE bs_hub_restore;
COMMIT;
