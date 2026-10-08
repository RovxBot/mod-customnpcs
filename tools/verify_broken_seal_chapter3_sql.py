#!/usr/bin/env python3
"""Import three chapters into disposable native/legacy MariaDB fixtures; never touch a realm database."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import uuid
from verify_broken_seal_chapter1_sql import TABLES

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--core-root', type=Path, required=True)
    parser.add_argument('--client', default='mariadb')
    parser.add_argument('--socket', required=True)
    parser.add_argument('--loader')
    parser.add_argument('--library-path')
    args = parser.parse_args()
    if args.loader and not args.library_path:
        parser.error('--loader requires --library-path')
    command = [args.client, '--no-defaults', '--socket=' + args.socket, '--user=root', '--batch', '--skip-column-names']
    if args.loader:
        command = [args.loader, '--library-path', args.library_path, *command]

    def run(sql, database=None, success=True):
        result = subprocess.run(command + ([database] if database else []), input=sql, text=True, capture_output=True)
        if success and result.returncode:
            raise AssertionError(result.stderr)
        return result

    schemas = []
    for table in TABLES:
        source = (args.core_root / f'data/sql/base/db_world/{table}.sql').read_text()
        match = re.search(r'CREATE TABLE `' + table + r'` \(.*?\) ENGINE=[^;]+;', source, re.S)
        assert match, table
        schemas.append(match.group())
    appearance = (ROOT / 'data/sql/db-world/base/custom_npc_appearances.sql').read_text()
    for table in ['mod_customnpcs_outfit', 'mod_customnpcs_outfit_entry', 'mod_customnpcs_outfit_spawn']:
        schemas.append(re.search(r'CREATE TABLE IF NOT EXISTS `' + table + r'` \(.*?\) ENGINE=[^;]+;', appearance, re.S).group())
    c01 = (ROOT / 'data/sql/db-world/base/broken_seal_chapter1.sql').read_text()
    c02 = (ROOT / 'data/sql/db-world/base/broken_seal_chapter2.sql').read_text()
    sql = (ROOT / 'data/sql/db-world/base/broken_seal_chapter3.sql').read_text()
    data = json.loads((ROOT / 'data/quests/broken_seal_chapter3.json').read_text())
    ids = data['ids']
    created = []

    def fixture(chapter1=True):
        database = 'customnpcs_c03_test_' + uuid.uuid4().hex[:12]
        run(f'CREATE DATABASE `{database}` CHARACTER SET utf8mb4;')
        created.append(database)
        run('\n'.join(schemas), database)
        if chapter1:
            run(c01, database)
            run(c02, database)
        return database

    def snapshots(database, prefix):
        return run(f"SELECT guid,Comment FROM creature WHERE Comment LIKE '{prefix}:%' ORDER BY Comment;"
                   f"SELECT guid,Comment FROM gameobject WHERE Comment LIKE '{prefix}:%' ORDER BY Comment;", database).stdout

    try:
        for legacy in [False, True]:
            database = fixture()
            if legacy:
                run('ALTER TABLE creature CHANGE id1 id INT UNSIGNED NOT NULL DEFAULT 0;', database)
            col = 'id' if legacy else 'id1'
            before = [snapshots(database, prefix) for prefix in ['BS-C01', 'BS-C02']]
            run(f"INSERT INTO creature_template (entry,name) VALUES (987654,'Sentinel');"
                f"INSERT INTO creature ({col},Comment) VALUES (987654,'unrelated sentinel');"
                "INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid,outfit_id) VALUES (987654,0);", database)
            run(sql, database)
            first = snapshots(database, 'BS-C03')
            run(sql, database)
            assert first == snapshots(database, 'BS-C03')
            assert before == [snapshots(database, prefix) for prefix in ['BS-C01', 'BS-C02']]
            run(c01, database)
            run(c02, database)
            assert first == snapshots(database, 'BS-C03')
            assert run('SELECT COUNT(*) FROM quest_template WHERE ID BETWEEN 900300 AND 900311;', database).stdout.strip() == '12'
            assert run('SELECT COUNT(*) FROM creature WHERE Comment="unrelated sentinel";'
                       'SELECT COUNT(*) FROM mod_customnpcs_outfit_spawn WHERE spawn_guid=987654;', database).stdout.split() == ['1', '1']
            assert run('SELECT COUNT(*) FROM creature_queststarter WHERE id=4001205 AND quest=900300;'
                       'SELECT COUNT(*) FROM creature_questender WHERE id=4001205 AND quest=900308;', database).stdout.split() == ['1', '1']
            for q in data['quests']:
                actual = run(f"SELECT PrevQuestID,ExclusiveGroup FROM quest_template_addon WHERE ID={q['id']};", database).stdout.split()
                assert actual == [str(ids[q['previous']]), str(q.get('exclusive_group', 0))]
                conditions = run(f"SELECT ConditionValue1,ElseGroup FROM conditions WHERE SourceTypeOrReferenceId=19 "
                                 f"AND SourceEntry={q['id']} AND ConditionTypeOrReference=8 ORDER BY ConditionValue1;", database).stdout.splitlines()
                assert conditions == [f'{v}\t0' for v in sorted(ids[k] for k in q['prerequisites'])]
            assert run('SELECT COUNT(*) FROM creature WHERE Comment LIKE "BS-C03:%";', database).stdout.strip() == str(
                sum(len(a.get('points', [])) or bool(a.get('point')) for a in data['actors']))
            assert run('SELECT COUNT(*) FROM gameobject WHERE Comment LIKE "BS-C03:%";', database).stdout.strip() == str(
                sum(len(o['points']) for o in data['objects']))
            assert run('SELECT COUNT(*) FROM item_template WHERE entry BETWEEN 900309 AND 900314 AND InventoryType=11;', database).stdout.strip() == '6'
            assert run('SELECT NextQuestID FROM quest_template_addon WHERE ID=900311;', database).stdout.strip() == '0'
            assert run('SELECT RewardItem1,RewardAmount1 FROM quest_template WHERE ID=900309;', database).stdout.split() == ['900306','1']
            assert run('SELECT ProvidedItemCount FROM quest_template_addon WHERE ID=900310;', database).stdout.strip() == '3'
            assert run('SELECT COUNT(*) FROM creature WHERE ' + col + ' IN (4001404,4001406,4001407,4001411,4001412,4001413);', database).stdout.strip() == '0'
            assert run('SELECT COUNT(*) FROM creature_loot_template WHERE Entry IN (4001414,4001415,4001416) AND Chance=100 AND QuestRequired=1;', database).stdout.strip() == '4'
            assert run('SELECT Chapter FROM mod_customnpcs_bs_content WHERE kind="creature" AND entry=4001205;', database).stdout.strip() == '2'
            print('Passed', 'legacy creature.id' if legacy else 'native creature.id1', 'import, ALL joins, C01/C02 coexistence, fixed keepsake and three-bundle supply and GUID preservation.')

        for table, col, entry in [('creature_template','entry',4001400),('gameobject_template','entry',4001500),
                                  ('quest_template','ID',900300),('item_template','entry',900300),
                                  ('mod_customnpcs_outfit','outfit_id',4001400),
                                  ('mod_customnpcs_outfit_entry','creature_entry',4001400),('npc_text','ID',4001400),
                                  ('gossip_menu','MenuID',4001400)]:
            database = fixture()
            if table == 'mod_customnpcs_outfit_entry':
                run(f'INSERT INTO `{table}` (`{col}`,`outfit_id`) VALUES ({entry},0);', database)
            else:
                run(f'INSERT INTO `{table}` (`{col}`) VALUES ({entry});', database)
            result = run(sql, database, success=False)
            assert result.returncode and 'Duplicate entry' in result.stderr, (table, result.stderr)
            assert run('SELECT COUNT(*) FROM creature_template WHERE entry=4001401;', database).stdout.strip() == '0'
        database = fixture(False)
        result = run(sql, database, success=False)
        assert result.returncode and 'Duplicate entry' in result.stderr
        assert run('SELECT COUNT(*) FROM quest_template;', database).stdout.strip() == '0'
        print('Passed all eight occupied-ID guards and missing-Chapter-2 rejection before content DML.')
    finally:
        for database in created:
            assert database.startswith('customnpcs_c03_test_') and re.fullmatch(r'[a-z0-9_]+', database)
            run(f'DROP DATABASE IF EXISTS `{database}`;')


if __name__ == '__main__':
    main()
