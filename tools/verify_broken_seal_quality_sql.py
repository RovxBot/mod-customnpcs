#!/usr/bin/env python3
"""Upgrade previous campaign SQL in disposable fixtures; verify text, loot and progress contracts."""
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
    parser.add_argument('--core-root',type=Path,required=True)
    parser.add_argument('--socket',required=True)
    parser.add_argument('--client',default='mariadb')
    parser.add_argument('--loader')
    parser.add_argument('--library-path')
    parser.add_argument('--previous-revision',default='3eccb67')
    args=parser.parse_args()
    command=[args.client,'--no-defaults','--socket='+args.socket,'--user=root','--batch','--skip-column-names']
    if args.loader:
        command=[args.loader,'--library-path',args.library_path,*command]

    def run(sql,database=None,success=True):
        result=subprocess.run(command+([database] if database else []),input=sql,text=True,capture_output=True)
        if success:
            assert result.returncode==0,result.stderr
        return result

    schemas=[]
    for table in TABLES:
        raw=(args.core_root/f'data/sql/base/db_world/{table}.sql').read_text()
        schemas.append(re.search(r'CREATE TABLE `'+table+r'` \(.*?\) ENGINE=[^;]+;',raw,re.S).group())
    raw=(ROOT/'data/sql/db-world/base/custom_npc_appearances.sql').read_text()
    for table in ['mod_customnpcs_outfit','mod_customnpcs_outfit_entry','mod_customnpcs_outfit_spawn']:
        schemas.append(re.search(r'CREATE TABLE IF NOT EXISTS `'+table+r'` \(.*?\) ENGINE=[^;]+;',raw,re.S).group())

    def previous(path):
        return subprocess.run(['git','show',f'{args.previous_revision}:{path}'],cwd=ROOT,text=True,capture_output=True,check=True).stdout

    old=[previous(f'data/sql/db-world/base/broken_seal_chapter{i}.sql') for i in range(1,5)]
    old_hubs=previous('data/sql/db-world/base/broken_seal_hubs.sql')
    sql=(ROOT/'data/sql/db-world/updates/2026_10_07_04_broken_seal_campaign_quality.sql').read_text()
    data=[json.loads((ROOT/f'data/quests/broken_seal_chapter{i}.json').read_text()) for i in range(1,5)]
    created=[]

    def fixture(chapters=4,legacy=False):
        database='customnpcs_quality_test_'+uuid.uuid4().hex[:12]
        created.append(database)
        run(f'CREATE DATABASE `{database}` CHARACTER SET utf8mb4;')
        run('\n'.join(schemas),database)
        if legacy:
            run('ALTER TABLE creature CHANGE id1 id INT UNSIGNED NOT NULL DEFAULT 0;',database)
        for text in old[:chapters]:
            run(text,database)
        if chapters==4:
            run(old_hubs,database)
        return database

    def preserved(database):
        return run("SELECT * FROM creature ORDER BY guid; SELECT * FROM gameobject ORDER BY guid; "
                   "SELECT * FROM mod_customnpcs_outfit_spawn ORDER BY spawn_guid; "
                   "SELECT * FROM quest_template_addon ORDER BY ID; "
                   "SELECT * FROM conditions ORDER BY SourceEntry,ConditionValue1; "
                   "SELECT * FROM creature_queststarter ORDER BY quest,id; "
                   "SELECT * FROM creature_questender ORDER BY quest,id;",database).stdout

    try:
        for legacy in [False,True]:
            for count in [2,3,4]:
                database=fixture(count,legacy)
                col='id' if legacy else 'id1'
                # An occupied but unowned later-chapter quest, actor and prop must remain untouched.
                if count<4:
                    run("INSERT INTO quest_template (ID,LogTitle,QuestDescription) VALUES (900411,'Other module','Keep me'); "
                        "INSERT INTO creature_template (entry,name,mingold,lootid) VALUES (4001610,'Other actor',9,77); "
                        "INSERT INTO gameobject_template (entry,name) VALUES (4001700,'Other prop');",database)
                run(f"INSERT INTO creature_template (entry,name) VALUES (987654,'Native sentinel'); "
                    f"INSERT INTO creature ({col},Comment) VALUES (987654,'native sentinel'); "
                    "INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid,outfit_id) VALUES (987654,0);",database)
                before=preserved(database)
                for iteration in range(2):
                    run(sql,database)
                    assert before==preserved(database),'Upgrade modified spawns, overrides or progression'
                    for chapter in data[:count]:
                        for quest in chapter['quests']:
                            # Compare the client-facing objective and return fields, not just row existence.
                            result=run(f"SELECT QuestCompletionLog,ObjectiveText1,ObjectiveText2,ObjectiveText3,ObjectiveText4 "
                                       f"FROM quest_template WHERE ID={quest['id']};",database).stdout.rstrip('\n').split('\t')
                            labels=list(quest['objective_labels'].values())
                            assert result==[quest['return_text'],*labels,*['']*(4-len(labels))],quest['title']
                            assert int(run(f"SELECT COUNT(*) FROM quest_poi WHERE QuestID={quest['id']} AND ObjectiveIndex>=0;",database).stdout)>0
                        for item in chapter['items']:
                            actual=run(f"SELECT displayid,description FROM item_template WHERE entry={item['entry']};",database).stdout.rstrip('\n').split('\t')
                            assert actual==[str(item['display']),item['description']],item['name']
                    for chapter in data[:min(count,3)]:
                        for actor in chapter['actors']+chapter.get('hostile',[]):
                            if actor.get('ordinary_loot'):
                                assert int(run(f"SELECT COUNT(*) FROM creature_loot_template WHERE Entry={actor['entry']} AND QuestRequired=0;",database).stdout)>0
                                assert run(f"SELECT COUNT(*) FROM creature_template WHERE entry={actor['entry']} AND mingold>0 AND maxgold>=mingold AND ExperienceModifier=1;",database).stdout.strip()=='1'
                    assert run('SELECT COUNT(*) FROM creature_loot_template WHERE Entry=4001224 AND Item=900207 AND QuestRequired=1;',database).stdout.strip()=='1'
                    if count>=3:
                        assert run('SELECT COUNT(*) FROM creature_loot_template WHERE Entry IN (4001414,4001415,4001416) AND QuestRequired=1;',database).stdout.strip()=='3'
                        assert run('SELECT COUNT(*) FROM creature_equip_template WHERE CreatureID IN (4001414,4001415) AND ItemID1>0;',database).stdout.strip()=='2'
                        assert run("SELECT COUNT(*) FROM npc_text WHERE ID=4001465 AND text0_0 LIKE 'Redhorn%';",database).stdout.strip()=='1'
                    if count==4:
                        assert run('SELECT COUNT(*) FROM creature_template WHERE entry IN (4009050,4009052,4009056,4009057,4009058,4009059) AND npcflag=1 AND gossip_menu_id=entry;',database).stdout.strip()=='6'
                    else:
                        assert run('SELECT QuestDescription FROM quest_template WHERE ID=900411;',database).stdout.strip()=='Keep me'
                        assert run('SELECT name,mingold,lootid FROM creature_template WHERE entry=4001610;',database).stdout.split()==['Other','actor','9','77']
                print(f'Passed {col}: Chapters 1-{count} upgrade/reimport; text, map slots, ordinary/quest loot and unchanged progress/spawns/overrides.')
        for table,column,entry in [('npc_text','ID',4009050),('gossip_menu','MenuID',4009050),('npc_text','ID',4001465)]:
            database=fixture()
            run(f"INSERT INTO `{table}` (`{column}`) VALUES ({entry});",database)
            before=run('SELECT RewardText FROM quest_offer_reward WHERE ID=900220;',database).stdout
            result=run(sql,database,False)
            assert result.returncode and 'Duplicate entry' in result.stderr
            assert before==run('SELECT RewardText FROM quest_offer_reward WHERE ID=900220;',database).stdout
        print('Passed new hub-text ownership collisions before campaign content changes.')
    finally:
        for database in created:
            assert re.fullmatch(r'customnpcs_quality_test_[a-f0-9]+',database)
            run(f'DROP DATABASE IF EXISTS `{database}`;')


if __name__=='__main__':
    main()
