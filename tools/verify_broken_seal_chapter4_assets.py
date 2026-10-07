#!/usr/bin/env python3
"""Audit Chapter 4 native models, item slots, prop foundations and navigation on both maps."""
import argparse
import json
import math
from pathlib import Path
import struct
import subprocess
from broken_seal_world_data import map_height, table_rows
from verify_broken_seal_chapter2_assets import Dbc

ROOT = Path(__file__).resolve().parents[1]


def model_string(path, row, field):
    raw = path.read_bytes()
    _, records, _, size, _ = struct.unpack_from('<4s4I', raw)
    offset = 20 + records * size + row[field]
    return raw[offset:raw.index(b'\0', offset)].decode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--client-data', type=Path, required=True)
    parser.add_argument('--core-root', type=Path, help='Also check opposing faction guard access at Iain')
    parser.add_argument('--ground-probe', type=Path)
    parser.add_argument('--travel-probe', type=Path)
    args = parser.parse_args()
    d = json.loads((ROOT / 'data/quests/broken_seal_chapter4.json').read_text())
    tables = {name: Dbc(args.client_data / 'dbc' / (name + '.dbc')) for name in
              ['CreatureDisplayInfo', 'CreatureModelData', 'GameObjectDisplayInfo', 'ItemDisplayInfo',
               'Item', 'Spell', 'WorldMapArea']}
    for name, values in [('CreatureDisplayInfo', [a['display'] for a in d['actors']] + [11686]),
                         ('GameObjectDisplayInfo', [o['display'] for o in d['objects']]),
                         ('ItemDisplayInfo', [i['display'] for i in d['items']]),
                         ('Spell', [v for k, v in d['ids'].items() if k.startswith('SPELL_')])]:
        assert set(values) <= tables[name].rows.keys(), (name, set(values) - tables[name].rows.keys())
    assert tables['Spell'].rows[d['ids']['SPELL_MASK_TARGET']][86] == 25
    for item in d['items']:
        if item.get('icon_donor_item'):
            assert tables['Item'].rows[item['icon_donor_item']][5] == item['display']
    assert tables['WorldMapArea'].rows[141][1:3] == (1, 15)
    assert tables['WorldMapArea'].rows[26][1:3] == (0, 47)
    for obj in d['objects']:
        row = tables['GameObjectDisplayInfo'].rows[obj['display']]
        actual = model_string(args.client_data/'dbc/GameObjectDisplayInfo.dbc', row, 1)
        assert actual == d['native_assets']['object_models'][obj['key']], (obj['key'],actual)
        bounds = [struct.unpack('<f',struct.pack('<I',v))[0]*obj['scale'] for v in row[12:18]]
        for name in obj['points']:
            p = d['points'][name]
            cosine,sine = math.cos(p[3]),math.sin(p[3])
            corners = [(p[0]+x*cosine-y*sine,p[1]+x*sine+y*cosine)
                       for x in [bounds[0],bounds[3]] for y in [bounds[1],bounds[4]]]
            heights = [map_height(args.client_data,x,y) for x,y in corners]
            assert max(heights)-min(heights) <= 1.21,(name,heights)
    flame = tables['CreatureDisplayInfo'].rows[next(a['display'] for a in d['actors'] if a['key']=='NPC_HEARTH_FLAME')]
    model = tables['CreatureModelData'].rows[flame[1]]
    assert model_string(args.client_data/'dbc/CreatureModelData.dbc',model,2).endswith('UndeadFireSmall.mdx')
    print('Native IDs, actual prop models, fire effect, mask targeting and all prop foundations checked.')
    if args.core_root:
        templates={int(r['entry']):r for r in table_rows(args.core_root,'creature_template')}
        factions={int(r['ID']):r for r in table_rows(args.core_root,'factiontemplate_dbc')}
        p=d['points']['iain'];nearest=None
        for r in table_rows(args.core_root,'creature'):
            if int(r['map'])!=0:continue
            t=templates[int(r['id1'])]
            f=factions.get(int(t['faction']),{})
            if not int(f.get('EnemyGroup',0)) & 6:continue
            distance=math.hypot(float(r['position_x'])-p[0],float(r['position_y'])-p[1])
            if nearest is None or distance<nearest:nearest=distance
            if abs(float(r['position_z'])-p[2])<30:
                assert distance>22+float(t['detection_range'])+float(r['wander_distance'])+10,(r,t['name'])
        print(f'Neutral Hinterlands receiving camp clears faction-hostile native homes; nearest {nearest:.1f} m.')
    if args.ground_probe:
        for map_id in [0,1]:
            points=[(k,p) for k,p in d['points'].items() if d.get('point_maps',{}).get(k,1)==map_id]
            output=subprocess.run([str(args.ground_probe),str(args.client_data/'mmaps'),'1',str(map_id)],
                                  input=''.join('p '+' '.join(map(str,p[:3]))+'\n' for k,p in points),
                                  text=True,capture_output=True,check=True).stdout.splitlines()
            assert len(output)==len(points)
            for (name,p),line in zip(points,output):
                ref,x,y,z=line.split()
                assert int(ref) and abs(float(z)-p[2])<2 and math.hypot(float(x)-p[0],float(y)-p[1])<3,(name,line,p)
            print(f'{len(points)} ground positions checked on map {map_id}.')
    if args.travel_probe:
        for map_id in [0,1]:
            routes=[r for r in d['validation']['routes'] if r.get('map',1)==map_id]
            output=subprocess.run([str(args.travel_probe),str(args.client_data/'mmaps'),'9',str(map_id)],
                                  input=''.join('r '+' '.join(map(str,d['points'][r['start']][:3]+d['points'][r['end']][:3]))+'\n' for r in routes),
                                  text=True,capture_output=True,check=True).stdout.splitlines()
            assert len(output)==len(routes)
            for r,line in zip(routes,output):assert line.split()[0]=='1',(r,line)
            print(f'{len(routes)} ground/water travel routes checked on map {map_id}.')


if __name__=='__main__':main()
