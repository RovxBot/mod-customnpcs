"""Hub safety, scenery, contact coverage and migration contract checks."""
import json
import math
from pathlib import Path
import subprocess
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
DATA=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text())
CHAPTERS=[json.loads((ROOT/f'data/quests/broken_seal_chapter{n}.json').read_text()) for n in [1,2,3,4]]


class HubTests(unittest.TestCase):
    def test_contact_coverage_and_quest_enemy_clearance(self):
        contacts={entry:h for h in DATA['hubs'] for entry in h['contacts']}
        for data in CHAPTERS:
            for actor in data['actors']:
                if actor['entry'] not in contacts or not actor.get('point'):
                    continue
                h=contacts[actor['entry']];p=data['points'][actor['point']]
                self.assertLessEqual(math.hypot(p[0]-h['center'][0],p[1]-h['center'][1]),h['radius'])
                self.assertLessEqual(abs(p[2]-h['center'][2]),h['vertical_tolerance'])
            for actor in data.get('hostile',[]) or [a for a in data['actors'] if a['faction']==14 and a.get('points')]:
                for name in actor['points']:
                    p=data['points'][name]
                    for h in [h for h in DATA['hubs'] if not h.get('cult')]:
                        if h['map']==data.get('point_maps',{}).get(name,1) and abs(p[2]-h['center'][2])<=20:
                            self.assertGreaterEqual(math.hypot(p[0]-h['center'][0],p[1]-h['center'][1]),h['radius']+25,(actor['key'],name,h['key']))

    def test_each_hub_has_functional_scenery_and_staff(self):
        for h in DATA['hubs']:
            objects=[o for o in DATA['objects'] if o['hub']==h['key']]
            roles={o['role'] for o in objects}
            self.assertTrue({'shelter','supplies','lighting'}<=roles)
            self.assertTrue(roles & {'medicine','workstation','equipment'})
            self.assertGreaterEqual(len(objects),5)
            self.assertTrue(all(o['terrain_relief']<=1.2 for o in objects))
            self.assertEqual(len(next(g for g in DATA['guards'] if g['hub']==h['key'])['points']),2)
            self.assertEqual(len([a for a in DATA['residents'] if a['hub']==h['key']]),1)
        for i,a in enumerate(DATA['objects']):
            for b in DATA['objects'][i+1:]:
                aa,bb=a['bounds'],b['bounds']
                self.assertTrue(aa[2]<bb[0] or aa[0]>bb[2] or aa[3]<bb[1] or aa[1]>bb[3],(a['key'],b['key']))

    def test_stock_clearances_keep_identity_and_wander_envelope(self):
        self.assertEqual(len(DATA['relocations']),len({r['guid'] for r in DATA['relocations']}))
        self.assertFalse(DATA['relocations'])
        self.assertFalse(DATA['policy']['native_spawn_edits'])
        for r in DATA['relocations']:
            self.assertIn(r['movement'],[0,1]);self.assertNotEqual(r['point'][:3],r['original'][:3])
            for h in [h for h in DATA['hubs'] if h['map']==r['map']]:
                self.assertGreaterEqual(math.hypot(r['point'][0]-h['center'][0],r['point'][1]-h['center'][1]),h['radius']+r['wander']+r['detection']+10)
        self.assertEqual(next(h for h in DATA['hubs'] if h['key']=='wayside')['center'],CHAPTERS[2]['points']['mei'])

    def test_owned_ids_do_not_overlap_chapter_assets(self):
        actors=[a['entry'] for a in DATA['guards']+DATA['residents']]
        objects=[o['entry'] for o in DATA['objects']]
        self.assertEqual(len(actors),len(set(actors)));self.assertEqual(len(objects),len(set(objects)))
        old_actors={v for c in CHAPTERS for k,v in c['ids'].items() if k.startswith(('NPC_','CREDIT_'))}
        old_objects={v for c in CHAPTERS for k,v in c['ids'].items() if k.startswith('GO_')}
        self.assertFalse(set(actors)&old_actors);self.assertFalse(set(objects)&old_objects)

    def test_scene_corridors_and_full_camp_coverage(self):
        self.assertTrue(DATA['validation']['corridors_clear'])
        self.assertEqual(len(DATA['corridors']),26)
        from sys import path
        path.insert(0,str(ROOT/'tools'))
        from verify_broken_seal_hub_assets import intersects_route
        self.assertTrue(all(not intersects_route(o['bounds'],o['point'][2],DATA['corridors']) for o in DATA['objects']))
        self.assertEqual(next(h for h in DATA['hubs'] if h['key']=='dawnchasers')['activation_chapter'],2)
        self.assertIn('4001002',DATA['exceptions'])

    def test_generated_files_current(self):
        subprocess.run([sys.executable,str(ROOT/'tools/generate_broken_seal_hubs.py'),'--check'],check=True)
        self.assertEqual((ROOT/'data/sql/db-world/base/broken_seal_hubs.sql').read_text(),
                         (ROOT/'data/sql/db-world/updates/2026_10_07_02_broken_seal_chapter4_hubs.sql').read_text())


if __name__=='__main__':unittest.main()
