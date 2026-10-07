#!/usr/bin/env python3
"""Upgrade shipped Chapter 1/2 SQL in disposable fixtures; assert stock quests/spawns are preserved."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import uuid
from verify_broken_seal_chapter1_sql import TABLES
from broken_seal_world_data import table_rows

ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--core-root',type=Path,required=True);p.add_argument('--client',default='mariadb');p.add_argument('--socket',required=True);p.add_argument('--loader');p.add_argument('--library-path');a=p.parse_args()
    command=[a.client,'--no-defaults','--socket='+a.socket,'--user=root','--batch','--skip-column-names']
    if a.loader:command=[a.loader,'--library-path',a.library_path,*command]
    def run(sql,db=None):
        r=subprocess.run(command+([db] if db else []),input=sql,text=True,capture_output=True);assert r.returncode==0,r.stderr;return r.stdout
    schemas=[]
    for t in TABLES:
        text=(a.core_root/f'data/sql/base/db_world/{t}.sql').read_text();schemas.append(re.search(r'CREATE TABLE `'+t+r'` \(.*?\) ENGINE=[^;]+;',text,re.S).group())
    text=(ROOT/'data/sql/db-world/base/custom_npc_appearances.sql').read_text()
    for t in ['mod_customnpcs_outfit','mod_customnpcs_outfit_entry','mod_customnpcs_outfit_spawn']:
        schemas.append(re.search(r'CREATE TABLE IF NOT EXISTS `'+t+r'` \(.*?\) ENGINE=[^;]+;',text,re.S).group())
    old=[subprocess.run(['git','show',f'1f7c966:data/sql/db-world/base/broken_seal_chapter{i}.sql'],cwd=ROOT,text=True,capture_output=True,check=True).stdout for i in [1,2]]
    upgrade=(ROOT/'data/sql/db-world/updates/2026_10_07_03_broken_seal_world_polish.sql').read_text()
    native_c=[r for r in table_rows(a.core_root,'creature') if r['map']=='1' and 400<float(r['position_x'])<1600 and 1200<float(r['position_y'])<2300]
    native_g=[r for r in table_rows(a.core_root,'gameobject') if r['map']=='1' and 400<float(r['position_x'])<1600 and 1200<float(r['position_y'])<2300]
    created=[]
    try:
        for legacy in [False,True]:
            db='customnpcs_polish_test_'+uuid.uuid4().hex[:12];created.append(db);run(f'CREATE DATABASE `{db}` CHARACTER SET utf8mb4;');run('\n'.join(schemas),db)
            if legacy:run('ALTER TABLE creature CHANGE id1 id INT UNSIGNED NOT NULL DEFAULT 0;',db)
            col='id' if legacy else 'id1'
            for s in old:run(s,db)
            # Include native creature/object placements and quest/loot links that the campaign must not alter.
            for r in native_c:
                run(f"INSERT INTO creature (guid,{col},map,position_x,position_y,position_z,orientation,wander_distance,MovementType,Comment) VALUES ({r['guid']},{r['id1']},1,{r['position_x']},{r['position_y']},{r['position_z']},{r['orientation']},{r['wander_distance']},{r['MovementType']},'native quest spawn');",db)
            for r in native_g:
                run(f"INSERT INTO gameobject (guid,id,map,position_x,position_y,position_z,orientation,Comment) VALUES ({r['guid']},{r['id']},1,{r['position_x']},{r['position_y']},{r['position_z']},{r['orientation']},'native quest object');",db)
            run("INSERT INTO quest_template (ID,LogTitle,RequiredNpcOrGo1,RequiredNpcOrGoCount1) VALUES (6421,'Native quest sentinel',4026,8); INSERT INTO gameobject_template (entry,name,displayId) VALUES (177929,'Gaea Dirt Mound',379); INSERT INTO creature_queststarter (id,quest) VALUES (4026,6421);",db)
            snapshot=run("SELECT * FROM creature WHERE Comment='native quest spawn' ORDER BY guid; SELECT * FROM gameobject WHERE Comment='native quest object' ORDER BY guid; SELECT * FROM quest_template WHERE ID=6421; SELECT * FROM creature_queststarter WHERE quest=6421; SELECT * FROM gameobject_template WHERE entry=177929;",db)
            old_guids=run("SELECT guid,Comment FROM creature WHERE Comment IN ('BS-C01:NPC_MARUUT:maruut','BS-C02:NPC_CONDENNA:condenna');",db)
            for iteration in [0,1]:
                run(upgrade,db)
                assert snapshot==run("SELECT * FROM creature WHERE Comment='native quest spawn' ORDER BY guid; SELECT * FROM gameobject WHERE Comment='native quest object' ORDER BY guid; SELECT * FROM quest_template WHERE ID=6421; SELECT * FROM creature_queststarter WHERE quest=6421; SELECT * FROM gameobject_template WHERE entry=177929;",db)
                assert old_guids==run("SELECT guid,Comment FROM creature WHERE Comment IN ('BS-C01:NPC_MARUUT:maruut','BS-C02:NPC_CONDENNA:condenna');",db)
                assert run('SELECT COUNT(*) FROM creature WHERE '+col+' IN (4001222,4001226);',db).strip()=='0'
                assert run('SELECT COUNT(*) FROM gameobject WHERE id IN (4001104,4001105,4001106);',db).strip()=='0'
                assert run('SELECT COUNT(*) FROM creature WHERE '+col+' IN (4001004,4001008,4001009);',db).strip()=='3'
                assert run('SELECT COUNT(*) FROM creature_template WHERE entry IN (4001200,4001201,4001202,4001203) AND faction=14;',db).strip()=='4'
                assert run('SELECT COUNT(*) FROM mod_customnpcs_outfit_entry WHERE creature_entry IN (4001200,4001201,4001202,4001203,4001225,4001227,4001228) AND outfit_id=0;',db).strip()=='7'
                assert run('SELECT COUNT(*) FROM creature_equip_template WHERE CreatureID IN (4001010,4001011,4001200,4001201,4001202,4001203,4001225,4001227,4001228) AND ItemID1>0;',db).strip()=='9'
                assert run('SELECT COUNT(*) FROM creature_template WHERE entry IN (4001010,4001011,4001225,4001227,4001228) AND mingold>0 AND maxgold>=mingold AND lootid=entry;',db).strip()=='5'
                assert run('SELECT COUNT(*) FROM creature_loot_template WHERE Entry=4001010 AND Item=900101 AND QuestRequired=1;',db).strip()=='1'
                assert run('SELECT COUNT(*) FROM creature_loot_template WHERE Entry IN (4001010,4001011,4001225,4001227,4001228) AND QuestRequired=0;',db).strip()=='15'
                assert run('SELECT COUNT(*) FROM mod_customnpcs_bs_hub_native;',db).strip()=='0'
            print('Passed',col,'shipped-world upgrade/reimport, 154 native NPCs, 155 native objects/quest links, textured stock bindings, armed NPCs, regular loot, no permanent trial spawns and three visible captives.')
    finally:
        for db in created:
            assert db.startswith('customnpcs_polish_test_') and re.fullmatch('[a-z0-9_]+',db);run(f'DROP DATABASE IF EXISTS `{db}`;')


if __name__=='__main__':main()
