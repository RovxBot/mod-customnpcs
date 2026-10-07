#!/usr/bin/env python3
"""Import four chapters into disposable native/legacy MariaDB fixtures; never touch a realm database."""
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
    c03 = (ROOT / 'data/sql/db-world/base/broken_seal_chapter3.sql').read_text()
    sql = (ROOT / 'data/sql/db-world/base/broken_seal_chapter4.sql').read_text()
    data = json.loads((ROOT / 'data/quests/broken_seal_chapter4.json').read_text())
    ids = data['ids']
    created = []

    def fixture(chapter1=True):
        database = 'customnpcs_c04_test_' + uuid.uuid4().hex[:12]
        run(f'CREATE DATABASE `{database}` CHARACTER SET utf8mb4;')
        created.append(database)
        run('\n'.join(schemas), database)
        if chapter1:
            run(c01, database)
            run(c02, database)
            run(c03, database)
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
            before = [snapshots(database, prefix) for prefix in ['BS-C01', 'BS-C02', 'BS-C03']]
            run(f"INSERT INTO creature_template (entry,name) VALUES (987654,'Sentinel');"
                f"INSERT INTO creature ({col},Comment) VALUES (987654,'unrelated sentinel');"
                "INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid,outfit_id) VALUES (987654,0);", database)
            run(sql, database)
            first = snapshots(database, 'BS-C04')
            run(sql, database)
            assert first == snapshots(database, 'BS-C04')
            assert before == [snapshots(database, prefix) for prefix in ['BS-C01', 'BS-C02', 'BS-C03']]
            run(c01, database)
            run(c02, database)
            run(c03, database)
            assert first == snapshots(database, 'BS-C04')
            assert run('SELECT COUNT(*) FROM quest_template WHERE ID BETWEEN 900400 AND 900411;', database).stdout.strip() == '12'
            assert run('SELECT COUNT(*) FROM creature WHERE Comment="unrelated sentinel";'
                       'SELECT COUNT(*) FROM mod_customnpcs_outfit_spawn WHERE spawn_guid=987654;', database).stdout.split() == ['1', '1']
            assert run('SELECT COUNT(*) FROM creature_queststarter WHERE id=4001405 AND quest=900400;'
                       'SELECT COUNT(*) FROM creature_questender WHERE id=4001405 AND quest=900409;', database).stdout.split() == ['1', '1']
            for q in data['quests']:
                actual = run(f"SELECT PrevQuestID,ExclusiveGroup FROM quest_template_addon WHERE ID={q['id']};", database).stdout.split()
                assert actual == [str(ids[q['previous']]), str(q.get('exclusive_group', 0))]
                conditions = run(f"SELECT ConditionValue1,ElseGroup FROM conditions WHERE SourceTypeOrReferenceId=19 "
                                 f"AND SourceEntry={q['id']} AND ConditionTypeOrReference=8 ORDER BY ConditionValue1;", database).stdout.splitlines()
                assert conditions == [f'{v}\t0' for v in sorted(ids[k] for k in q['prerequisites'])]
            assert run('SELECT COUNT(*) FROM creature WHERE Comment LIKE "BS-C04:%";', database).stdout.strip() == str(
                sum(len(a.get('points', [])) or bool(a.get('point')) for a in data['actors']))
            assert run('SELECT COUNT(*) FROM gameobject WHERE Comment LIKE "BS-C04:%";', database).stdout.strip() == str(
                sum(len(o['points']) for o in data['objects']))
            assert run('SELECT COUNT(*) FROM item_template WHERE entry BETWEEN 900410 AND 900415 AND InventoryType=11;', database).stdout.strip() == '6'
            assert run('SELECT NextQuestID FROM quest_template_addon WHERE ID=900411;', database).stdout.strip() == '0'
            assert run('SELECT ProvidedItemCount FROM quest_template_addon WHERE ID IN (900405,900406,900408,900411);',database).stdout.split() == ['1']*4
            assert run('SELECT RequiredNpcOrGoCount1 FROM quest_template WHERE ID=900406;', database).stdout.strip() == '8'
            assert run('SELECT RequiredNpcOrGoCount1,RequiredNpcOrGoCount2,RequiredNpcOrGoCount3 FROM quest_template WHERE ID=900408;', database).stdout.split() == ['8','1','1']
            personal=','.join(str(ids[k]) for k in data['arrays']['PersonalEntries'])
            assert run('SELECT COUNT(*) FROM creature WHERE '+col+' IN ('+personal+');', database).stdout.strip() == '0'
            assert run('SELECT map,zoneId FROM creature WHERE '+col+'=4001604;',database).stdout.split() == ['0','47']
            assert run('SELECT MapID,WorldMapAreaId FROM quest_poi WHERE QuestID=900411;',database).stdout.split() == ['0','26']
            assert run('SELECT maxcount FROM item_template WHERE entry IN (900307,900401) ORDER BY entry;',database).stdout.split() == ['3','6']
            assert run('SELECT Chapter FROM mod_customnpcs_bs_content WHERE kind="creature" AND entry=4001405;', database).stdout.strip() == '3'
            print('Passed', 'legacy creature.id' if legacy else 'native creature.id1', 'Chapter 4 import/reimport, ALL join, shared Mei, both maps, quest progress and C01-C03 GUID preservation.')

        for table, col, entry in [('creature_template','entry',4001600),('gameobject_template','entry',4001700),
                                  ('quest_template','ID',900400),('item_template','entry',900400),
                                  ('mod_customnpcs_outfit','outfit_id',4001601),
                                  ('mod_customnpcs_outfit_entry','creature_entry',4001600),('npc_text','ID',4001600),
                                  ('gossip_menu','MenuID',4001600)]:
            database = fixture()
            if table == 'mod_customnpcs_outfit_entry':
                run(f'INSERT INTO `{table}` (`{col}`,`outfit_id`) VALUES ({entry},0);', database)
            else:
                run(f'INSERT INTO `{table}` (`{col}`) VALUES ({entry});', database)
            result = run(sql, database, success=False)
            assert result.returncode and 'Duplicate entry' in result.stderr, (table, result.stderr)
            assert run('SELECT COUNT(*) FROM creature_template WHERE entry=4001602;', database).stdout.strip() == '0'
        database = fixture(False)
        result = run(sql, database, success=False)
        assert result.returncode and 'Duplicate entry' in result.stderr
        assert run('SELECT COUNT(*) FROM quest_template;', database).stdout.strip() == '0'
        print('Passed all eight occupied-ID guards and missing-Chapter-3 rejection before content DML.')
    finally:
        for database in created:
            assert database.startswith('customnpcs_c04_test_') and re.fullmatch(r'[a-z0-9_]+', database)
            run(f'DROP DATABASE IF EXISTS `{database}`;')


if __name__ == '__main__':
    main()
