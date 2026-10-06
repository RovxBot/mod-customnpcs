#!/usr/bin/env python3
"""Audit native roam/patrol envelopes and select reversible hub spawn clearances."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import subprocess
from broken_seal_world_data import table_rows, map_height

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'data/quests/broken_seal_hubs.json'


def distance(row, hub):
    return math.hypot(float(row['position_x']) - hub['center'][0], float(row['position_y']) - hub['center'][1])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--core-root', type=Path, required=True)
    parser.add_argument('--nav-probe', type=Path)
    parser.add_argument('--client-data', type=Path)
    parser.add_argument('--travel-probe', type=Path, help='Optional ground/water probe for marsh creature routes')
    parser.add_argument('--write', action='store_true', help='Update audit evidence and native relocation inventory')
    args = parser.parse_args()
    d = json.loads(MANIFEST.read_text())
    templates = {int(r['entry']): r for r in table_rows(args.core_root, 'creature_template')}
    factions = {int(r['ID']): r for r in table_rows(args.core_root, 'factiontemplate_dbc')}
    candidates = []
    for row in table_rows(args.core_root, 'creature'):
        if int(row['map']) != 1:
            continue
        tpl = templates[int(row['id1'])]
        faction = factions.get(int(tpl['faction']), {})
        if not int(faction.get('EnemyGroup', 0)) & 1 or int(tpl['npcflag']) or int(tpl['rank']) or tpl['ScriptName']:
            continue
        candidates.append((row, tpl))
    paths = {int(r['guid']): int(r['path_id']) for r in table_rows(args.core_root, 'creature_addon') if int(r['path_id'])}
    crossing = []
    relevant_paths = {paths[int(r['guid'])] for r, _ in candidates if int(r['guid']) in paths}
    waypoints = {}
    for row in table_rows(args.core_root, 'waypoint_data'):
        if int(row['id']) in relevant_paths:
            waypoints.setdefault(int(row['id']), []).append(row)
    relocations = []
    original_report = []
    for row, tpl in candidates:
        radius = float(row['wander_distance'])
        detection = float(tpl['detection_range'])
        touched = [h for h in d['hubs'] if abs(float(row['position_z']) - h['center'][2]) <= 30 and
                   distance(row, h) <= h['radius'] + radius + detection + 10]
        if touched:
            original_report.append(dict(guid=int(row['guid']), entry=int(row['id1']), name=tpl['name'],
                movement=int(row['MovementType']), wander=radius, detection=detection,
                hubs=[h['key'] for h in touched], origin=[float(row[k]) for k in ['position_x','position_y','position_z','orientation']]))
        path = waypoints.get(paths.get(int(row['guid']), 0), [])
        for hub in d['hubs']:
            for a, b in zip(path, path[1:] + path[:1]):
                ax, ay = float(a['position_x']), float(a['position_y'])
                bx, by = float(b['position_x']), float(b['position_y'])
                vx, vy = bx-ax, by-ay
                length = vx*vx + vy*vy
                u = max(0, min(1, ((hub['center'][0]-ax)*vx + (hub['center'][1]-ay)*vy) / length)) if length else 0
                z = float(a['position_z']) + u*(float(b['position_z'])-float(a['position_z']))
                if math.hypot(ax+u*vx-hub['center'][0], ay+u*vy-hub['center'][1]) < hub['radius'] + detection and abs(z-hub['center'][2]) <= 15:
                    crossing.append(dict(guid=int(row['guid']), path=int(a['id']), hub=hub['key'], point=int(a['point'])))
                    break
        # Do not rewrite shared/scripted paths. The localized runtime rule handles ordinary passing patrols.
        if not touched or int(row['MovementType']) not in [0, 1] or int(row['guid']) in paths:
            continue
        if not args.nav_probe:
            continue
        near = min(touched, key=lambda h: distance(row, h))
        angle = math.atan2(float(row['position_y'])-near['center'][1], float(row['position_x'])-near['center'][0])
        found = None
        # Search a walkable nearby home outside every camp's wander-plus-aggro envelope.
        for extent in [near['radius']+radius+detection+18, near['radius']+radius+detection+35, near['radius']+radius+detection+55]:
            for turn in [0,.25,-.25,.5,-.5,.75,-.75,1,-1,1.5,-1.5,math.pi]:
                x=near['center'][0]+extent*math.cos(angle+turn);y=near['center'][1]+extent*math.sin(angle+turn)
                z=map_height(args.client_data,x,y)+.05
                result=subprocess.run([str(args.nav_probe),str(args.client_data/'mmaps')],input=f'p {x} {y} {z}\n',text=True,capture_output=True,check=True).stdout.split()
                if not int(result[0]):continue
                x,y,z=map(float,result[1:])
                if any(math.hypot(x-h['center'][0],y-h['center'][1])<h['radius']+radius+detection+10 for h in d['hubs']):continue
                route=subprocess.run([str(args.travel_probe or args.nav_probe),str(args.client_data/'mmaps')],input=f'r {row["position_x"]} {row["position_y"]} {row["position_z"]} {x} {y} {z}\n',text=True,capture_output=True,check=True).stdout.split()
                if route[0]!='1':continue
                found=[x,y,z,float(row['orientation'])];break
            if found:break
        assert found, ('No connected clearance home', row['guid'], tpl['name'])
        relocations.append(dict(guid=int(row['guid']),entry=int(row['id1']),name=tpl['name'],map=1,
            original=[float(row[k]) for k in ['position_x','position_y','position_z','orientation']],
            point=found,wander=radius,movement=int(row['MovementType']),detection=detection,
            hubs=[h['key'] for h in touched]))
    report=dict(source='AzerothCore base-world snapshot; runtime protection also covers ordinary stock additions',
                creature_sha256=hashlib.sha256((args.core_root/'data/sql/base/db_world/creature.sql').read_bytes()).hexdigest(),
                threats=original_report,patrol_crossings=crossing)
    if args.write:
        assert args.nav_probe and args.client_data
        d['native_audit']=report;d['relocations']=relocations;MANIFEST.write_text(json.dumps(d,indent=2)+'\n')
    print(f'{len(original_report)} native roam envelopes, {len(crossing)} patrol intersections, {len(relocations)} connected spawn clearances.')


if __name__ == '__main__':
    main()
