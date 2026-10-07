"""Shared native appearance/equipment and ordinary loot authoring for the campaign."""


def equipment_sql(actors):
    from generate_broken_seal_chapter1 import upsert
    values=[]
    for a in actors:
        o=a.get('outfit',{})
        weapons=a.get('weapons',[o.get('mainhand',0),o.get('offhand',0),o.get('ranged',0)])
        if any(weapons):values.append([a['entry'],1,*weapons])
    return upsert('creature_equip_template',['CreatureID','ID','ItemID1','ItemID2','ItemID3'],values,['CreatureID','ID']) if values else ''


def ordinary_loot_sql(actors, chapter=None):
    """Write only owned ordinary enemies; native donor/reference tables are read, never changed."""
    from generate_broken_seal_chapter1 import rows
    result=''
    for a in actors:
        profile=a.get('ordinary_loot')
        if not profile:continue
        e=a['entry'];level=profile['level']
        guard=f" AND {ownership('creature',e,chapter)}" if chapter is not None else ''
        result+=f"UPDATE `creature_template` SET `mingold`={profile['mingold']},`maxgold`={profile['maxgold']},`lootid`={e} WHERE `entry`={e}{guard};\n"
        result+=f'DELETE FROM `creature_loot_template` WHERE `Entry`={e}{guard};\n'
        # Coin always comes from creature_template. Cloth and consumables complement it.
        items=profile.get('items', [[2592 if level<30 else 4306,40,1,2],
                                    [3770 if level<30 else 3771,8,1,1],
                                    [1205 if level<30 else 1708,8,1,1]])
        columns=['Entry','Item','Reference','Chance','QuestRequired','LootMode','GroupId','MinCount','MaxCount']
        values=[[e,item,0,chance,0,1,0,low,high] for item,chance,low,high in items]
        result+=(owned_rows('creature_loot_template',columns,values,'creature',chapter)
                 if chapter is not None else rows('creature_loot_template',columns,values))
        if 'items' in profile:continue
        donor=437 if level<25 else 431 if level<30 else 2586
        result+=f'''-- Reuse the stock donor's level-appropriate world-drop references when installed.
INSERT INTO `creature_loot_template`
  (`Entry`,`Item`,`Reference`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`)
SELECT {e}, l.`Item`,l.`Reference`,l.`Chance`,0,l.`LootMode`,l.`GroupId`,l.`MinCount`,l.`MaxCount`
FROM `creature_loot_template` l
WHERE l.`Entry`={donor} AND l.`Reference`>=1000000 AND l.`QuestRequired`=0
  AND EXISTS (SELECT 1 FROM `reference_loot_template` r WHERE r.`Entry`=l.`Reference`){guard};
'''
    return result


def ownership(kind, entry, chapter):
    return ("EXISTS (SELECT 1 FROM `mod_customnpcs_bs_content` owner "
            f"WHERE owner.`kind`='{kind}' AND owner.`entry`={entry} AND owner.`chapter`={chapter})")


def owned_rows(table, columns, values, kind, chapter, keys=()):
    """Insert only installed module-owned rows; optional keys preserve other columns."""
    from generate_broken_seal_chapter1 import quote
    result=''
    for value in values:
        scalars=', '.join(quote(v) if isinstance(v,str) else str(v) for v in value)
        result+=f'INSERT INTO `{table}` ('+', '.join(f'`{c}`' for c in columns)+')\n'
        result+=f"SELECT {scalars} WHERE {ownership(kind,value[0],chapter)}"
        if keys:
            result+='\nON DUPLICATE KEY UPDATE '+', '.join(
                f'`{c}`=VALUES(`{c}`)' for c in columns if c not in keys)
        result+=';\n'
    return result


def validate_quest_polish(data):
    """Require authored text and map locations for every real objective slot."""
    for quest in data['quests']:
        credits=quest.get('credits', {})
        items=quest.get('required_items', {})
        assert set(quest['objective_labels']) == set(credits), quest['key']
        assert set(quest['objective_locations']) == set(credits) | set(items), quest['key']
        for text in [quest['description'],quest['objectives'],quest['completion'],
                     quest['request_text'],quest['return_text'],*quest['objective_labels'].values()]:
            assert text and not any(marker in text.lower() for marker in
                                    ['placeholder','todo','tbd','the trial is recorded']), quest['key']
        for points in quest['objective_locations'].values():
            assert points and len(points) == len(set(points)), quest['key']
            assert set(points) <= data['points'].keys(), quest['key']
    for item in data['items']:
        assert item['description'] and item['display'] != 18098, item['key']


def quest_poi_rows(data, actor_points):
    """Wrath uses objective slots 0-3 for actors and 4-9 for required items."""
    poi,points=[],[]
    chapter=int(data['chapter'][1:])
    for quest in data['quests']:
        slots={key:index for index,key in enumerate(quest.get('credits',{}))}
        slots.update({key:index+4 for index,key in enumerate(quest.get('required_items',{}))})
        locations=[(-1,actor_points[quest['turn_in']])]
        locations += [(slots[key],point) for key,names in quest['objective_locations'].items() for point in names]
        for blob,(objective,point) in enumerate(locations):
            position=data['points'][point]
            map_id=data.get('point_maps',{}).get(point,1)
            area=26 if map_id==0 else 81 if chapter<=2 and point!='dezco' else 141
            poi.append([quest['id'],blob,objective,map_id,area,0,0,0])
            points.append([quest['id'],blob,0,round(position[0]),round(position[1])])
    return poi,points
