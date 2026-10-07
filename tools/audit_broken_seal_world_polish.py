#!/usr/bin/env python3
"""Verify grounded real props, textured native fallbacks and preservation of native quest locations."""
import argparse
import json
import math
from pathlib import Path
import struct
import subprocess
from broken_seal_world_data import map_height, table_rows
from verify_broken_seal_chapter2_assets import Dbc

ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--client-data',type=Path,required=True);p.add_argument('--core-root',type=Path,required=True);p.add_argument('--nav-probe',type=Path);a=p.parse_args()
    chapters=[json.loads((ROOT/f'data/quests/broken_seal_chapter{n}.json').read_text()) for n in [1,2,3,4]]
    hubs=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text())
    models=Dbc(a.client_data/'dbc/CreatureDisplayInfo.dbc');objects=Dbc(a.client_data/'dbc/GameObjectDisplayInfo.dbc');gear=Dbc(a.client_data/'dbc/Item.dbc')
    item_displays=Dbc(a.client_data/'dbc/ItemDisplayInfo.dbc')
    native_go=[r for r in table_rows(a.core_root,'gameobject') if int(r['map']) in [0,1]]
    count=0;props=0
    for n,c in enumerate(chapters,1):
        for item in c['items']:
            assert item['display'] in item_displays.rows,(n,item['key'],'missing item icon')
            if item.get('icon_donor_item'):
                assert gear.rows[item['icon_donor_item']][5] == item['display'],(n,item['key'],'icon donor mismatch')
        for actor in c['actors']+c.get('hostile',[]):
            outfit=actor.get('outfit')
            if not outfit:continue
            value=actor.get('fallback_display',actor.get('display'))
            assert value in models.rows and models.rows[value][3],(n,actor['key'],'missing native NPC skin')
            count+=1
            for slot in ['mainhand','offhand','ranged']:
                if outfit.get(slot):assert outfit[slot] in gear.rows,(actor['key'],slot)
        for actor in c['actors']+c.get('hostile',[]):
            for weapon in actor.get('weapons',[]):
                assert not weapon or weapon in gear.rows,(n,actor['key'],'missing held weapon')
            for item,chance,low,high in actor.get('ordinary_loot',{}).get('items',[]):
                assert item in gear.rows and 0<chance<=100 and 0<low<=high,(n,actor['key'],'invalid incidental loot')
        for o in c['objects']:
            assert o['display'] != 22,(n,o['key'],'placeholder sign')
            assert not (n<=2 and o['display']==676),(n,o['key'],'empty cage')
            row=objects.rows[o['display']];v=[struct.unpack('<f',struct.pack('<I',q))[0]*o['scale'] for q in row[12:18]]
            for key in o.get('points') or [o['point']]:
                pos=c['points'][key];m=c.get('point_maps',{}).get(key,1);co,si=math.cos(pos[3]),math.sin(pos[3])
                corners=[(pos[0]+x*co-y*si,pos[1]+x*si+y*co) for x in [v[0],v[3]] for y in [v[1],v[4]]]
                box=[min(x for x,y in corners),min(y for x,y in corners),max(x for x,y in corners),max(y for x,y in corners)]
                heights=[map_height(a.client_data,x,y,m) for x,y in corners]
                assert max(heights)-min(heights)<=1.21,(n,key,'footprint too uneven',heights)
                base=map_height(a.client_data,*pos[:2],m)
                assert abs(pos[2]+v[2]-base)<.06,(n,key,'floating root',pos,base,v[2])
                if n<=2:
                    for r in native_go:
                        if int(r['map']) != m:continue
                        x,y,z=map(float,[r['position_x'],r['position_y'],r['position_z']])
                        assert not (abs(z-base)<6 and box[0]-1<x<box[2]+1 and box[1]-1<y<box[3]+1),(n,key,'overlays native object',r['id'],r['guid'])
                props+=1
    assert not hubs['relocations'] and not hubs['policy']['native_spawn_edits']
    c1,c2=chapters[:2];actors={x['key']:x for x in c2['actors']}
    for key in ['NPC_FIRE','NPC_HORRORGUARD']:assert not actors[key].get('point') and not actors[key].get('points')
    captives=[x for x in c1['actors'] if x['key'].startswith('NPC_CAPTIVE_')]
    assert len(captives)==3 and all(x.get('point') and x['npc_flags']==1 for x in captives)
    if a.nav_probe:
        lines=[]
        for ac in captives:lines.append('r '+' '.join(map(str,c1['points'][ac['point']][:3]+c1['points'][c1['safe_point']][:3]))+'\n')
        out=subprocess.run([str(a.nav_probe),str(a.client_data/'mmaps')],input=''.join(lines),text=True,capture_output=True,check=True).stdout.splitlines()
        assert len(out)==3 and all(r.split()[0]=='1' for r in out),out
    print(f'{count} textured native fallback models, {props} real grounded quest props, three escort paths and no stock-spawn moves checked.')


if __name__=='__main__':main()
