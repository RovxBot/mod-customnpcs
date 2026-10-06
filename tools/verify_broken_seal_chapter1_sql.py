#!/usr/bin/env python3
"""Exercise Chapter 1 SQL in disposable databases built from AzerothCore schemas.

Requires a local MariaDB/MySQL client and permission to create/drop test databases.
Never imports into the realm's world database. Temporary names include a random suffix.
"""

import argparse
import json
from pathlib import Path
import re
import subprocess
import uuid

ROOT = Path(__file__).resolve().parents[1]
TABLES = ['creature_template', 'creature_template_model', 'creature_template_addon',
          'creature', 'creature_equip_template', 'smart_scripts', 'item_template', 'page_text',
          'creature_loot_template', 'quest_template', 'quest_template_addon', 'creature_queststarter',
          'creature_questender', 'quest_offer_reward', 'quest_request_items', 'conditions',
          'npc_text', 'gossip_menu', 'gameobject_template', 'gameobject', 'quest_poi', 'quest_poi_points']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--core-root', type=Path, required=True)
    parser.add_argument('--client', default='mariadb')
    parser.add_argument('--socket', required=True)
    parser.add_argument('--loader', help='Optional Linux loader for a portable client')
    parser.add_argument('--library-path', help='Portable client libraries, used with --loader')
    args = parser.parse_args()
    if args.loader and not args.library_path:
        parser.error('--loader requires --library-path')
    command = [args.client, '--no-defaults', '--socket=' + args.socket, '--user=root',
               '--batch', '--skip-column-names']
    if args.loader:
        command = [args.loader, '--library-path', args.library_path, *command]

    def run(sql, database=None, success=True):
        result = subprocess.run(command + ([database] if database else []), input=sql,
                                text=True, capture_output=True)
        if success and result.returncode:
            raise AssertionError(result.stderr)
        return result

    schemas = []
    for table in TABLES:
        source = (args.core_root / f'data/sql/base/db_world/{table}.sql').read_text()
        match = re.search(r'CREATE TABLE `' + table + r'` \(.*?\) ENGINE=[^;]+;', source, re.S)
        assert match, table
        schemas.append(match.group())
    appearances = (ROOT / 'data/sql/db-world/base/custom_npc_appearances.sql').read_text()
    for table in ('mod_customnpcs_outfit', 'mod_customnpcs_outfit_entry', 'mod_customnpcs_outfit_spawn'):
        match = re.search(r'CREATE TABLE IF NOT EXISTS `' + table + r'` \(.*?\) ENGINE=[^;]+;', appearances, re.S)
        assert match, table
        schemas.append(match.group())

    sql = (ROOT / 'data/sql/db-world/base/broken_seal_chapter1.sql').read_text()
    data = json.loads((ROOT / 'data/quests/broken_seal_chapter1.json').read_text())
    created = []
    try:
        for legacy in (False, True):
            database = 'customnpcs_c01_test_' + uuid.uuid4().hex[:12]
            run(f'CREATE DATABASE `{database}` CHARACTER SET utf8mb4;')
            created.append(database)
            run('\n'.join(schemas), database)
            if legacy:
                run('ALTER TABLE creature CHANGE id1 id INT UNSIGNED NOT NULL DEFAULT 0;', database)
            column = 'id' if legacy else 'id1'
            # An unrelated template, spawn and outfit override must survive both imports.
            run(f"INSERT INTO creature_template (entry,name) VALUES (987654,'Unrelated sentinel');"
                f"INSERT INTO creature ({column},Comment) VALUES (987654,'unrelated sentinel');"
                "INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid,outfit_id) VALUES (987654,0);", database)
            run(sql, database)
            first = run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-C01:%' ORDER BY Comment;"
                        "SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-C01:%' ORDER BY Comment;", database).stdout
            run(sql, database)
            second = run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-C01:%' ORDER BY Comment;"
                         "SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-C01:%' ORDER BY Comment;", database).stdout
            assert first == second, 'Reapplication replaced/duplicated owned GUIDs'
            assert run('SELECT COUNT(*) FROM creature_template WHERE entry=987654;'
                       'SELECT COUNT(*) FROM creature WHERE Comment="unrelated sentinel";'
                       'SELECT COUNT(*) FROM mod_customnpcs_outfit_spawn WHERE spawn_guid=987654;', database).stdout.split() == ['1', '1', '1']
            assert run('SELECT COUNT(*) FROM quest_template WHERE ID BETWEEN 900100 AND 900108;', database).stdout.strip() == '9'
            assert run('SELECT COUNT(*) FROM item_template WHERE entry BETWEEN 900110 AND 900115 AND InventoryType=11;', database).stdout.strip() == '6'
            assert run('SELECT COUNT(*) FROM conditions WHERE SourceTypeOrReferenceId=19 AND SourceEntry=900102 AND ConditionTypeOrReference=8;', database).stdout.strip() == '2'
            assert run('SELECT NextQuestID FROM quest_template_addon WHERE ID IN (900100,900101) ORDER BY ID;', database).stdout.split() == ['900102', '900102']
            assert run('SELECT PrevQuestID FROM quest_template_addon WHERE ID BETWEEN 900103 AND 900108 ORDER BY ID;', database).stdout.split() == [str(i) for i in range(900102, 900108)]
            assert run('SELECT COUNT(*) FROM gameobject WHERE Comment LIKE "BS-C01:%";', database).stdout.strip() == str(len(data['objects']))
            print('Passed', 'legacy creature.id' if legacy else 'native creature.id1', 'schema and idempotent import.')

        database = 'customnpcs_c01_test_' + uuid.uuid4().hex[:12]
        run(f'CREATE DATABASE `{database}` CHARACTER SET utf8mb4;')
        created.append(database)
        run('\n'.join(schemas), database)
        run("INSERT INTO quest_template (ID,LogTitle) VALUES (900100,'Occupied by another module');", database)
        result = run(sql, database, success=False)
        assert result.returncode and 'Duplicate entry' in result.stderr, result.stderr
        assert run('SELECT LogTitle FROM quest_template WHERE ID=900100;', database).stdout.strip() == 'Occupied by another module'
        assert run('SELECT COUNT(*) FROM creature_template WHERE entry=4001000;', database).stdout.strip() == '0'
        print('Passed occupied-ID rejection before content mutation.')
    finally:
        for database in created:
            assert database.startswith('customnpcs_c01_test_') and re.fullmatch(r'[a-z0-9_]+', database)
            run(f'DROP DATABASE IF EXISTS `{database}`;')


if __name__ == '__main__':
    main()
