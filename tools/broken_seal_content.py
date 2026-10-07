"""Shared native appearance/equipment and ordinary loot authoring for the campaign."""


def equipment_sql(actors):
    from generate_broken_seal_chapter1 import upsert
    values=[]
    for a in actors:
        o=a.get('outfit',{})
        weapons=a.get('weapons',[o.get('mainhand',0),o.get('offhand',0),o.get('ranged',0)])
        if any(weapons):values.append([a['entry'],1,*weapons])
    return upsert('creature_equip_template',['CreatureID','ID','ItemID1','ItemID2','ItemID3'],values,['CreatureID','ID']) if values else ''


def ordinary_loot_sql(actors):
    """Write only owned ordinary enemies; native donor/reference tables are read, never changed."""
    from generate_broken_seal_chapter1 import rows
    result=''
    for a in actors:
        profile=a.get('ordinary_loot')
        if not profile:continue
        e=a['entry'];level=profile['level']
        result+=f"UPDATE `creature_template` SET `mingold`={profile['mingold']},`maxgold`={profile['maxgold']},`lootid`={e} WHERE `entry`={e};\n"
        result+=f'DELETE FROM `creature_loot_template` WHERE `Entry`={e};\n'
        # Coin always comes from creature_template. Cloth and consumables complement it.
        result+=rows('creature_loot_template',['Entry','Item','Reference','Chance','QuestRequired','LootMode','GroupId','MinCount','MaxCount'],
                     [[e,2592 if level<30 else 4306,0,40,0,1,0,1,2],[e,3770,0,8,0,1,0,1,1],[e,1205,0,8,0,1,0,1,1]])
        donor=437 if level<25 else 431 if level<30 else 435
        result+=f'''-- Reuse the stock donor's level-appropriate world-drop references when installed.
INSERT INTO `creature_loot_template`
  (`Entry`,`Item`,`Reference`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`)
SELECT {e}, l.`Item`,l.`Reference`,l.`Chance`,0,l.`LootMode`,l.`GroupId`,l.`MinCount`,l.`MaxCount`
FROM `creature_loot_template` l
WHERE l.`Entry`={donor} AND l.`Reference`>=1000000 AND l.`QuestRequired`=0
  AND EXISTS (SELECT 1 FROM `reference_loot_template` r WHERE r.`Entry`=l.`Reference`);
'''
    return result
