#!/usr/bin/env python3
"""Check native hub assets, actor access and unobstructed campaign corridors."""
import argparse
import json
from pathlib import Path
import subprocess
from verify_broken_seal_chapter2_assets import Dbc
from broken_seal_world_data import map_height

ROOT=Path(__file__).resolve().parents[1]


def intersects_route(box,z,segments):
    for segment in segments:
        a,b=segment['a'],segment['b']
        for i in range(101):
            t=i/100;p=[a[j]+t*(b[j]-a[j]) for j in range(3)]
            if abs(p[2]-z)<5 and box[0]-2<=p[0]<=box[2]+2 and box[1]-2<=p[1]<=box[3]+2:
                return True
    return False


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--client-data',type=Path,required=True);parser.add_argument('--nav-probe',type=Path);args=parser.parse_args()
    d=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text());actors=d['guards']+d['residents']
    tables={n:Dbc(args.client_data/'dbc'/f'{n}.dbc') for n in ['CreatureDisplayInfo','GameObjectDisplayInfo','Item']}
    assert {a['display'] for a in actors}<=tables['CreatureDisplayInfo'].rows.keys()
    assert {o['display'] for o in d['objects']}<=tables['GameObjectDisplayInfo'].rows.keys()
    gear={v for a in actors for k,v in a['outfit'].items() if k in ['chest','legs','feet','hands','mainhand']}
    assert gear<=tables['Item'].rows.keys()
    contacts=[]
    for n in [1,2,3]:
        c=json.loads((ROOT/f'data/quests/broken_seal_chapter{n}.json').read_text())
        contacts += [c['points'][a['point']] for a in c['actors'] if a.get('point')]
    for o in d['objects']:
        box=o['bounds'];z=o['point'][2]
        assert not intersects_route(box,z,d['corridors']),o['key']
        assert not any(abs(z-p[2])<5 and box[0]-2<=p[0]<=box[2]+2 and box[1]-2<=p[1]<=box[3]+2 for p in contacts),o['key']
        heights=[map_height(args.client_data,x,y) for x in [box[0],box[2]] for y in [box[1],box[3]]]
        assert max(heights)-min(heights)<=1.21,o['key']
    positions=[o['point'] for o in d['objects']]+[p for a in actors for p in a.get('points') or [a['point']]]
    if args.nav_probe:
        result=subprocess.run([str(args.nav_probe),str(args.client_data/'mmaps')],input=''.join('p '+' '.join(map(str,p[:3]))+'\n' for p in positions),text=True,capture_output=True,check=True)
        assert len(result.stdout.splitlines())==len(positions)
        for p,line in zip(positions,result.stdout.splitlines()):
            values=line.split();assert int(values[0]) and abs(float(values[3])-p[2])<2,(p,line)
    print(f"Native assets, {len(positions)} ground positions, {len(d['corridors'])} clear corridor segments and quest-NPC access checked.")


if __name__=='__main__':main()
