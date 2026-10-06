#!/usr/bin/env python3
"""Audit Chapter 3 native DBC assets, dry scene points and ground/water travel routes."""
import argparse
import json
from pathlib import Path
import subprocess
import struct
from verify_broken_seal_chapter2_assets import Dbc

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--client-data', type=Path, required=True)
    parser.add_argument('--ground-probe', type=Path, help='Detour probe with NAV_GROUND (1)')
    parser.add_argument('--travel-probe', type=Path, help='Detour probe with NAV_GROUND | NAV_WATER (9)')
    args = parser.parse_args()
    d = json.loads((ROOT / 'data/quests/broken_seal_chapter3.json').read_text())
    tables = {name: Dbc(args.client_data / 'dbc' / (name + '.dbc')) for name in
              ['CreatureDisplayInfo', 'CreatureModelData', 'GameObjectDisplayInfo', 'ItemDisplayInfo',
               'Item', 'Spell', 'WorldMapArea']}
    for name, values in [('CreatureDisplayInfo', [a['display'] for a in d['actors']] + [11686]),
                         ('GameObjectDisplayInfo', [o['display'] for o in d['objects']]),
                         ('ItemDisplayInfo', [i['display'] for i in d['items']]),
                         ('Spell', [v for k, v in d['ids'].items() if k.startswith('SPELL_')]),
                         ('Item', [v for a in d['actors'] for k, v in a.get('outfit', {}).items()
                                   if k in ['chest', 'shoulders', 'waist', 'legs', 'feet', 'hands', 'mainhand']])]:
        assert set(values) <= tables[name].rows.keys(), (name, set(values) - tables[name].rows.keys())
    assert tables['Spell'].rows[d['ids']['SPELL_ANTIDOTE_TARGET']][86] == 25
    infant = tables['CreatureDisplayInfo'].rows[d['native_assets']['infants']['display']]
    assert infant[1] in tables['CreatureModelData'].rows
    model = tables['CreatureModelData'].rows[infant[1]]
    raw = (args.client_data / 'dbc/CreatureModelData.dbc').read_bytes()
    _, records, _, record_size, _ = struct.unpack_from('<4s4I', raw)
    offset = 20 + records * record_size + model[2]
    path = raw[offset:raw.index(b'\0', offset)].decode()
    assert path == d['native_assets']['infants']['model'], path
    for item in d['items']:
        if item.get('icon_donor_item'):
            assert tables['Item'].rows[item['icon_donor_item']][5] == item['display']
    assert tables['WorldMapArea'].rows[141][1:3] == (1, 15)
    print('Native creature/object/wardrobe/item/spell/map IDs, antidote targeting and infant model checked.')
    if args.ground_probe:
        points = list(d['points'].items())
        result = subprocess.run([str(args.ground_probe), str(args.client_data / 'mmaps')],
                                input=''.join('p ' + ' '.join(map(str, p[:3])) + '\n' for _, p in points),
                                text=True, capture_output=True, check=True)
        assert len(result.stdout.splitlines()) == len(points)
        for (name, p), line in zip(points, result.stdout.splitlines()):
            ref, x, y, z = line.split()
            assert int(ref) and abs(float(z) - p[2]) < 2, (name, line, p)
        print(f'{len(points)} dry ground positions checked.')
    if args.travel_probe:
        routes = d['validation']['routes']
        result = subprocess.run([str(args.travel_probe), str(args.client_data / 'mmaps')],
                                input=''.join('r ' + ' '.join(map(str, d['points'][r['start']][:3] +
                                        d['points'][r['end']][:3])) + '\n' for r in routes),
                                text=True, capture_output=True, check=True)
        assert len(result.stdout.splitlines()) == len(routes)
        for route, line in zip(routes, result.stdout.splitlines()):
            assert line.split()[0] == '1', (route, line)
        print(f'{len(routes)} travel routes checked with ground and water enabled; no flight needed.')


if __name__ == '__main__':
    main()
