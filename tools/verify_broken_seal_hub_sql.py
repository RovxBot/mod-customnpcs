#!/usr/bin/env python3
"""Exercise hub imports, native backups and restoration in disposable SQL fixtures."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import uuid
from verify_broken_seal_chapter1_sql import TABLES

ROOT=Path(__file__).resolve().parents[1]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--core-root',type=Path,required=True);parser.add_argument('--client',default='mariadb')
    parser.add_argument('--socket',required=True);parser.add_argument('--loader');parser.add_argument('--library-path')
    args=parser.parse_args();command=[args.client,'--no-defaults','--socket='+args.socket,'--user=root','--batch','--skip-column-names']
    if args.loader:command=[args.loader,'--library-path',args.library_path,*command]
    def run(sql,db=None,ok=True):
        result=subprocess.run(command+([db] if db else []),input=sql,text=True,capture_output=True)
        if ok and result.returncode:raise AssertionError(result.stderr)
        return result
    schemas=[]
    for table in TABLES:
        source=(args.core_root/f'data/sql/base/db_world/{table}.sql').read_text()
        schemas.append(re.search(r'CREATE TABLE `'+table+r'` \(.*?\) ENGINE=[^;]+;',source,re.S).group())
    source=(ROOT/'data/sql/db-world/base/custom_npc_appearances.sql').read_text()
    for table in ['mod_customnpcs_outfit','mod_customnpcs_outfit_entry','mod_customnpcs_outfit_spawn']:
        schemas.append(re.search(r'CREATE TABLE IF NOT EXISTS `'+table+r'` \(.*?\) ENGINE=[^;]+;',source,re.S).group())
    chapters=[(ROOT/f'data/sql/db-world/base/broken_seal_chapter{n}.sql').read_text() for n in [1,2,3,4]]
    sql=(ROOT/'data/sql/db-world/base/broken_seal_hubs.sql').read_text()
    restore=(ROOT/'data/sql/support/restore_broken_seal_hub_native_spawns.sql').read_text()
    data=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text());created=[]
    def fixture(install=True,legacy=False):
        db='customnpcs_hubs_test_'+uuid.uuid4().hex[:12];run(f'CREATE DATABASE `{db}` CHARACTER SET utf8mb4;');created.append(db);run('\n'.join(schemas),db)
        if legacy:run('ALTER TABLE creature CHANGE id1 id INT UNSIGNED NOT NULL DEFAULT 0;',db)
        if install:
            for chapter in chapters:run(chapter,db)
        return db
    try:
        for legacy in [False,True]:
            db=fixture(legacy=legacy);col='id' if legacy else 'id1'
            before=run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-C0%' ORDER BY guid;",db).stdout
            for entry in {r['entry'] for r in data['relocations']}:
                run(f"INSERT INTO creature_template (entry,name) VALUES ({entry},'Native sentinel');",db)
            for i,r in enumerate(data['relocations']):
                p=r['original'];x=p[0]+100 if i==0 else p[0]
                run(f"INSERT INTO creature (guid,{col},map,position_x,position_y,position_z,orientation,wander_distance,MovementType,Comment) VALUES ({r['guid']},{r['entry']},{r['map']},{x},{p[1]},{p[2]},{p[3]},{r['wander']},{r['movement']},'native sentinel');",db)
            run("INSERT INTO creature_template (entry,name) VALUES (987654,'Unrelated');"
                f"INSERT INTO creature ({col},Comment) VALUES (987654,'unrelated sentinel');"
                "INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid,outfit_id) VALUES (987654,0);",db)
            run(sql,db)
            first=run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid;"
                      "SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid;",db).stdout
            run(sql,db)
            selfsame=run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid;"
                        "SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid;",db).stdout
            assert first==selfsame
            assert before==run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-C0%' ORDER BY guid;",db).stdout
            assert run('SELECT COUNT(*) FROM mod_customnpcs_bs_hub_native;',db).stdout.strip()==str(len(data['relocations'])-1)
            for i,r in enumerate(data['relocations']):
                values=run(f"SELECT position_x,position_y,position_z,wander_distance,MovementType,{col} FROM creature WHERE guid={r['guid']};",db).stdout.split()
                expected=r['point'] if i else [r['original'][0]+100,*r['original'][1:]]
                assert all(abs(float(values[j])-expected[j])<.01 for j in range(3)),(r['guid'],values,expected)
                assert abs(float(values[3])-r['wander'])<.01 and int(values[4])==r['movement'] and int(values[5])==r['entry']
            assert run('SELECT COUNT(*) FROM creature WHERE Comment="unrelated sentinel"; SELECT COUNT(*) FROM mod_customnpcs_outfit_spawn WHERE spawn_guid=987654;',db).stdout.split()==['1','1']
            assert run('SELECT COUNT(*) FROM creature WHERE Comment LIKE "BS-HUB:%";',db).stdout.strip()==str(len(data['guards'])*2+len(data['residents']))
            assert run('SELECT COUNT(*) FROM gameobject WHERE Comment LIKE "BS-HUB:%";',db).stdout.strip()==str(len(data['objects']))
            assert run('SELECT COUNT(*) FROM creature_template WHERE entry BETWEEN 4009000 AND 4009057 AND (lootid<>0 OR ExperienceModifier<>0);',db).stdout.strip()=='0'
            # A later operator placement must survive both reimport and restoration.
            custom=data['relocations'][1];run(f"UPDATE creature SET position_x=position_x+150 WHERE guid={custom['guid']};",db)
            custom_before=run(f"SELECT position_x FROM creature WHERE guid={custom['guid']};",db).stdout
            run(sql,db);run(restore,db)
            assert custom_before==run(f"SELECT position_x FROM creature WHERE guid={custom['guid']};",db).stdout
            for r in data['relocations'][2:]:
                values=run(f"SELECT position_x,position_y,position_z FROM creature WHERE guid={r['guid']};",db).stdout.split()
                assert all(abs(float(values[j])-r['original'][j])<.01 for j in range(3))
            # Reapplication after restoring native homes should safely apply them again.
            run(sql,db)
            for chapter in chapters:run(chapter,db)
            assert first==run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid; SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid;",db).stdout
            print('Passed',col,'hub GUIDs, native identity/movement, operator overrides, backup and restore.')
        for table,col,entry in [('creature_template','entry',4009000),('gameobject_template','entry',4009100),('mod_customnpcs_outfit','outfit_id',4009000),('mod_customnpcs_outfit_entry','creature_entry',4009000)]:
            db=fixture();extra=',`outfit_id`' if table=='mod_customnpcs_outfit_entry' else '';value=',0' if extra else ''
            run(f'INSERT INTO `{table}` (`{col}`{extra}) VALUES ({entry}{value});',db);result=run(sql,db,False)
            assert result.returncode and 'Duplicate entry' in result.stderr
            assert run('SELECT COUNT(*) FROM creature_template WHERE entry=4009001;',db).stdout.strip()=='0'
        db=fixture(False);result=run(sql,db,False);assert result.returncode and 'Duplicate entry' in result.stderr
        print('Passed all hub collision guards and missing-chapter rejection before content changes.')
        # Upgrade the already-shipped three-chapter hub version, retaining its GUIDs and original backups.
        historical=(ROOT/'data/sql/db-world/updates/2026_10_06_03_broken_seal_hubs.sql').read_text()
        for legacy in [False,True]:
            db=fixture(False,legacy);col='id' if legacy else 'id1'
            for chapter in chapters[:3]:run(chapter,db)
            for entry in {r['entry'] for r in data['relocations']}:
                run(f"INSERT INTO creature_template (entry,name) VALUES ({entry},'Upgrade sentinel');",db)
            for r in data['relocations']:
                p=r['original']
                run(f"INSERT INTO creature (guid,{col},map,position_x,position_y,position_z,orientation,wander_distance,MovementType) VALUES ({r['guid']},{r['entry']},{r['map']},{p[0]},{p[1]},{p[2]},{p[3]},{r['wander']},{r['movement']});",db)
            run(historical,db)
            old=set(run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-HUB:%'; SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-HUB:%';",db).stdout.splitlines())
            r=data['relocations'][2]
            # Model a prior installed clearance with a different applied home.
            run(f"UPDATE creature SET position_x=position_x+7 WHERE guid={r['guid']}; UPDATE mod_customnpcs_bs_hub_native b INNER JOIN creature c ON c.guid=b.guid SET b.applied_x=c.position_x WHERE b.guid={r['guid']};",db)
            run(chapters[3],db);run(sql,db)
            new=set(run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-HUB:%'; SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-HUB:%';",db).stdout.splitlines())
            assert old<=new
            assert run(f"SELECT ABS(c.position_x-b.applied_x)<0.01 FROM creature c INNER JOIN mod_customnpcs_bs_hub_native b ON b.guid=c.guid WHERE c.guid={r['guid']};",db).stdout.strip()=='1'
            run(restore,db)
            actual=run(f"SELECT position_x,position_y,position_z FROM creature WHERE guid={r['guid']};",db).stdout.split()
            assert all(abs(float(actual[i])-r['original'][i])<.01 for i in range(3))
            print('Passed',col,'historical hub upgrade, old GUID retention and revised-clearance backup restoration.')

    finally:
        for db in created:
            assert db.startswith('customnpcs_hubs_test_') and re.fullmatch('[a-z0-9_]+',db)
            run(f'DROP DATABASE IF EXISTS `{db}`;')


if __name__=='__main__':main()
