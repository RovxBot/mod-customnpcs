#!/usr/bin/env python3
"""Audit Chapter 2 against extracted native DBCs and optional native map-1 Detour probe."""
import argparse
import json
from pathlib import Path
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[1]


class Dbc:
    def __init__(self, path):
        data = path.read_bytes()
        magic, n, fields, size, _ = struct.unpack_from('<4s4I', data)
        assert magic == b'WDBC' and size == fields * 4
        self.rows = {struct.unpack_from('<I', data, 20 + i * size)[0]:
                     struct.unpack_from('<' + 'I' * fields, data, 20 + i * size) for i in range(n)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--client-data', type=Path, required=True)
    parser.add_argument('--nav-probe', type=Path, help='Optional Detour probe: p x y z; r x y z x y z')
    args = parser.parse_args()
    d = json.loads((ROOT / 'data/quests/broken_seal_chapter2.json').read_text())
    tables = {name: Dbc(args.client_data / 'dbc' / (name + '.dbc')) for name in
              ['CreatureDisplayInfo', 'GameObjectDisplayInfo', 'ItemDisplayInfo', 'Item', 'Spell', 'WorldMapArea']}
    for name, values in [('CreatureDisplayInfo', [a['display'] for a in d['actors']] + [11686]),
                         ('GameObjectDisplayInfo', [o['display'] for o in d['objects']]),
                         ('ItemDisplayInfo', [i['display'] for i in d['items']]),
                         ('Spell', [v for k, v in d['ids'].items() if k.startswith('SPELL_')]),
                         ('Item', [v for a in d['actors'] for k, v in a.get('outfit', {}).items()
                                   if k in ['chest', 'shoulders', 'waist', 'legs', 'feet', 'hands', 'mainhand']])]:
        assert set(values) <= tables[name].rows.keys(), (name, set(values) - tables[name].rows.keys())
    for name in ['disguise', 'fire_form']:
        spell = tables['Spell'].rows[d['native_assets'][name]['spell']]
        assert spell[71:74] == (6, 0, 0) and spell[95:98] == (56, 0, 0)
        assert spell[110] == d['native_assets'][name]['creature']
    for key in ['blackjack', 'gem']:
        assert tables['Spell'].rows[d['native_assets']['tool_targeting'][key]][86] == 25
    assert tables['WorldMapArea'].rows[81][1:3] == (1, 406)
    assert tables['WorldMapArea'].rows[141][1:3] == (1, 15)
    print('All creature, object, item, wardrobe, spell and map-area IDs exist in native DBCs.')
    if args.nav_probe:
        names = list(d['points'])
        points = list(d['points'].values())
        edges = [('course_start', 'check_a'), ('stones', 'delivery'), ('hound', 'dog_a'),
                 ('recruit_start', 'recruit_hide')]
        for route in list(d['routes'].values()) + [['prison', *d['routes']['EscapeRoute']]]:
            edges.extend(zip(route, route[1:]))
        commands = ['p ' + ' '.join(map(str, p[:3])) for p in points]
        commands += ['r ' + ' '.join(map(str, d['points'][a][:3] + d['points'][b][:3])) for a, b in edges]
        result = subprocess.run([str(args.nav_probe), str(args.client_data / 'mmaps')],
                                input='\n'.join(commands) + '\n', text=True, capture_output=True, check=True)
        lines = result.stdout.splitlines()
        assert len(lines) == len(commands)
        for name, p, line in zip(names, points, lines):
            ref, x, y, z = line.split()
            assert int(ref) and abs(float(z) - p[2]) < 2.0, (name, line, p)
        for edge, line in zip(edges, lines[len(points):]):
            assert line.split()[0] == '1', (edge, line)
        print(f'{len(points)} ground points and {len(edges)} complete native navigation routes checked.')


if __name__ == '__main__':
    main()
