#!/usr/bin/env python3
"""Verify current compact hub imports in disposable native/legacy fixtures without changing stock content."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import uuid
from verify_broken_seal_chapter1_sql import TABLES

ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--core-root',type=Path,required=True);p.add_argument('--client',default='mariadb');p.add_argument('--socket',required=True);p.add_argument('--loader');p.add_argument('--library-path');a=p.parse_args()
    command=[a.client,'--no-defaults','--socket='+a.socket,'--user=root','--batch','--skip-column-names']
    if a.loader:command=[a.loader,'--library-path',a.library_path,*command]
    def run(sql,db=None,ok=True):
        r=subprocess.run(command+([db] if db else []),input=sql,text=True,capture_output=True)
        if ok:assert r.returncode==0,r.stderr
        return r
    schemas=[]
    for t in TABLES:
        raw=(a.core_root/f'data/sql/base/db_world/{t}.sql').read_text();schemas.append(re.search(r'CREATE TABLE `'+t+r'` \(.*?\) ENGINE=[^;]+;',raw,re.S).group())
    raw=(ROOT/'data/sql/db-world/base/custom_npc_appearances.sql').read_text()
    for t in ['mod_customnpcs_outfit','mod_customnpcs_outfit_entry','mod_customnpcs_outfit_spawn']:schemas.append(re.search(r'CREATE TABLE IF NOT EXISTS `'+t+r'` \(.*?\) ENGINE=[^;]+;',raw,re.S).group())
    chapters=[(ROOT/f'data/sql/db-world/base/broken_seal_chapter{i}.sql').read_text() for i in [1,2,3,4]]
    sql=(ROOT/'data/sql/db-world/base/broken_seal_hubs.sql').read_text();d=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text());created=[]
    def fixture(install=True,legacy=False):
        db='customnpcs_hubs_test_'+uuid.uuid4().hex[:12];created.append(db);run(f'CREATE DATABASE `{db}` CHARACTER SET utf8mb4;');run('\n'.join(schemas),db)
        if legacy:run('ALTER TABLE creature CHANGE id1 id INT UNSIGNED NOT NULL DEFAULT 0;',db)
        if install:
            for s in chapters:run(s,db)
        return db
    try:
        for legacy in [False,True]:
            db=fixture(legacy=legacy);col='id' if legacy else 'id1'
            run(f"INSERT INTO creature_template (entry,name) VALUES (987654,'Native sentinel'); INSERT INTO creature ({col},map,position_x,position_y,position_z,Comment) VALUES (987654,1,641,1670,-19,'native quest sentinel'); INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid,outfit_id) VALUES (987654,0);",db)
            native=run("SELECT * FROM creature WHERE Comment='native quest sentinel'; SELECT * FROM mod_customnpcs_outfit_spawn WHERE spawn_guid=987654;",db).stdout
            campaign=run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-C0%' ORDER BY guid; SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-C0%' ORDER BY guid;",db).stdout
            run(sql,db);first=run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid; SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid;",db).stdout
            run(sql,db);assert first==run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid; SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-HUB:%' ORDER BY guid;",db).stdout
            assert campaign==run("SELECT guid,Comment FROM creature WHERE Comment LIKE 'BS-C0%' ORDER BY guid; SELECT guid,Comment FROM gameobject WHERE Comment LIKE 'BS-C0%' ORDER BY guid;",db).stdout
            assert native==run("SELECT * FROM creature WHERE Comment='native quest sentinel'; SELECT * FROM mod_customnpcs_outfit_spawn WHERE spawn_guid=987654;",db).stdout
            assert run('SELECT COUNT(*) FROM mod_customnpcs_bs_hub_native;',db).stdout.strip()=='0'
            assert run('SELECT COUNT(*) FROM creature WHERE Comment LIKE "BS-HUB:%";',db).stdout.strip()==str(len(d['guards'])*2+len(d['residents']))
            assert run('SELECT COUNT(*) FROM gameobject WHERE Comment LIKE "BS-HUB:%";',db).stdout.strip()==str(len(d['objects'])+len(d.get('encounter_scenery',[])))
            assert run('SELECT faction,lootid,ExperienceModifier FROM creature_template WHERE entry=4009002;',db).stdout.split()==['14','4009002','1']
            assert run('SELECT COUNT(*) FROM creature_template WHERE entry=4009000 AND (lootid<>0 OR ExperienceModifier<>0);',db).stdout.strip()=='0'
            print('Passed',col,'compact hub import/reimport, native sentinel/override preservation, campaign GUID coexistence, hostile armed cult staff and zero stock moves.')
        for t,c,e in [('creature_template','entry',4009000),('gameobject_template','entry',4009200),('mod_customnpcs_outfit','outfit_id',4009000),('mod_customnpcs_outfit_entry','creature_entry',4009000)]:
            db=fixture();extra=',outfit_id' if t=='mod_customnpcs_outfit_entry' else '';value=',0' if extra else '';run(f'INSERT INTO `{t}` (`{c}`{extra}) VALUES ({e}{value});',db);r=run(sql,db,False);assert r.returncode and 'Duplicate entry' in r.stderr
        db=fixture(False);r=run(sql,db,False);assert r.returncode and 'Duplicate entry' in r.stderr
        print('Passed hub occupied-ID and missing-chapter guards before content DML.')
    finally:
        for db in created:
            assert db.startswith('customnpcs_hubs_test_') and re.fullmatch('[a-z0-9_]+',db);run(f'DROP DATABASE IF EXISTS `{db}`;')


if __name__=='__main__':main()
