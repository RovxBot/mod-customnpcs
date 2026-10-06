#!/usr/bin/env python3
"""Test installed-outfit repairs without modifying a realm database."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import uuid
from verify_broken_seal_chapter1_sql import TABLES
from verify_broken_seal_outfits import inventory

ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--core-root',type=Path,required=True);p.add_argument('--client',default='mariadb');p.add_argument('--socket',required=True);p.add_argument('--loader');p.add_argument('--library-path');a=p.parse_args()
    command=[a.client,'--no-defaults','--socket='+a.socket,'--user=root','--batch','--skip-column-names']
    if a.loader:command=[a.loader,'--library-path',a.library_path,*command]
    db='customnpcs_outfit_test_'+uuid.uuid4().hex[:12]
    def run(sql,selected=True):
        result=subprocess.run(command+([db] if selected else []),input=sql,text=True,capture_output=True)
        assert result.returncode==0,result.stderr
        return result.stdout.split()
    run(f'CREATE DATABASE `{db}` CHARACTER SET utf8mb4;',False)
    try:
        for table in TABLES:
            raw=(a.core_root/f'data/sql/base/db_world/{table}.sql').read_text();run(re.search(r'CREATE TABLE `'+table+r'` \(.*?\) ENGINE=[^;]+;',raw,re.S).group())
        raw=(ROOT/'data/sql/db-world/base/custom_npc_appearances.sql').read_text()
        for table in ['mod_customnpcs_outfit','mod_customnpcs_outfit_entry','mod_customnpcs_outfit_spawn']:
            run(re.search(r'CREATE TABLE IF NOT EXISTS `'+table+r'` \(.*?\) ENGINE=[^;]+;',raw,re.S).group())
        for name in ['chapter1','chapter2','chapter3','hubs']:run((ROOT/f'data/sql/db-world/base/broken_seal_{name}.sql').read_text())
        # Simulate the two exact installation bugs and intentional edits/overrides.
        run('UPDATE mod_customnpcs_outfit SET class=0 WHERE outfit_id BETWEEN 4001200 AND 4009057;'
            'UPDATE mod_customnpcs_outfit SET legs=0 WHERE outfit_id=4001006;'
            'UPDATE mod_customnpcs_outfit SET feet=0 WHERE outfit_id=4001006;'
            'UPDATE mod_customnpcs_outfit SET class=2 WHERE outfit_id=4001200;'
            'UPDATE mod_customnpcs_outfit SET legs=6568 WHERE outfit_id=4001007;'
            'UPDATE mod_customnpcs_outfit SET chest=6238,legs=0 WHERE outfit_id=4001005;'
            'INSERT INTO mod_customnpcs_outfit (outfit_id,class,legs) VALUES (987654,0,0);'
            'INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid,outfit_id) VALUES (987654,987654);')
        repair=(ROOT/'data/sql/db-world/updates/2026_10_07_00_broken_seal_outfit_corrections.sql').read_text()
        for _ in range(2):
            run(repair)
            assert run('SELECT legs,feet FROM mod_customnpcs_outfit WHERE outfit_id=4001006;')==['1431','1427']
            assert run('SELECT COUNT(*) FROM mod_customnpcs_outfit WHERE class=0 AND outfit_id<>987654;')==['0']
            assert run('SELECT class FROM mod_customnpcs_outfit WHERE outfit_id=4001200;')==['2']
            assert run('SELECT legs FROM mod_customnpcs_outfit WHERE outfit_id=4001007;')==['6568']
            assert run('SELECT chest,legs FROM mod_customnpcs_outfit WHERE outfit_id=4001005;')==['6238','0']
            assert run('SELECT class,legs FROM mod_customnpcs_outfit WHERE outfit_id=987654;')==['0','0']
            assert run('SELECT outfit_id FROM mod_customnpcs_outfit_spawn WHERE spawn_guid=987654;')==['987654']
        # No ownership marker means no authority to change the record.
        run('DELETE FROM mod_customnpcs_bs_content WHERE kind="outfit" AND entry=4001201; UPDATE mod_customnpcs_outfit SET class=0 WHERE outfit_id=4001201;')
        run(repair);assert run('SELECT class FROM mod_customnpcs_outfit WHERE outfit_id=4001201;')==['0']
        print('Outfit repair passed: empty courier slots, invalid classes, reimport and preservation of custom clothing/classes/overrides/unowned records.')
    finally:
        assert re.fullmatch('customnpcs_outfit_test_[a-f0-9]+',db);run(f'DROP DATABASE `{db}`;',False)


if __name__=='__main__':main()
