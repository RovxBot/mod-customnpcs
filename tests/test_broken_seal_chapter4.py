"""Integrity checks for the Village recovery quest graph, story contracts and generated inventory."""
import itertools
import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / 'data/quests/broken_seal_chapter4.json').read_text())
QUESTS = {q['key']: q for q in DATA['quests']}


class ChapterFourTests(unittest.TestCase):
    def test_matches_accepted_campaign_graph(self):
        planned = json.loads((ROOT / 'data/quests/broken_seal_campaign.json').read_text())['chapters'][3]
        logical = {q['id']: q for q in planned['quests']}
        keys = {q['design_id']: q['key'] for q in DATA['quests']}
        keys['BS-C03-12'] = 'QUEST_C03_END'
        self.assertEqual(len(QUESTS), 12)
        for q in DATA['quests']:
            design = logical[q['design_id']]
            self.assertEqual(q['title'], design['title'])
            self.assertEqual(q['level'], design['quest_level'])
            self.assertEqual(q['min_level'], 35)
            self.assertEqual(q['prerequisites'], [keys[k] for k in design['prerequisite_all']])
        done = {'QUEST_C03_END'}
        while True:
            ready = {k for k, q in QUESTS.items() if k not in done and set(q['prerequisites']) <= done}
            if not ready:
                break
            done.update(ready)
        self.assertEqual(done, set(QUESTS) | {'QUEST_C03_END'})

    def test_every_partial_branch_subset_keeps_join_locked(self):
        for q in DATA['quests']:
            parents = q['prerequisites']
            if len(parents) < 2:
                continue
            groups = {QUESTS[k]['exclusive_group'] for k in parents}
            self.assertEqual(len(groups), 1)
            group = next(iter(groups))
            self.assertLess(group, 0)
            grouped = {k for k, v in QUESTS.items() if v.get('exclusive_group') == group}
            self.assertEqual(grouped, set(parents))
            for count in range(len(parents)):
                for subset in itertools.combinations(parents, count):
                    self.assertFalse(grouped <= set(subset))
            self.assertTrue(grouped <= set(parents))

    def test_ids_and_shared_mei(self):
        previous = [json.loads((ROOT / f'data/quests/broken_seal_chapter{n}.json').read_text()) for n in [1, 2, 3]]
        for prefixes in [('QUEST_',), ('NPC_', 'CREDIT_'), ('GO_',), ('ITEM_',)]:
            old = {v for d in previous for k,v in d['ids'].items() if k.startswith(prefixes)}
            new = [v for k,v in DATA['ids'].items() if k.startswith(prefixes)
                   and k not in DATA['external_entries'] and k != 'QUEST_C03_END']
            self.assertEqual(len(new),len(set(new)))
            self.assertFalse(set(new) & old)
        self.assertEqual(DATA['ids']['NPC_MEI'],previous[2]['ids']['NPC_MEI'])
        self.assertEqual(QUESTS['QUEST_INTRO']['previous'],'QUEST_C03_END')
        self.assertFalse(QUESTS['QUEST_LETTER'].get('next_quest'))

    def test_story_and_persistence_contracts(self):
        actors={a['key']:a for a in DATA['actors']}
        for key in DATA['arrays']['PersonalEntries']:
            self.assertEqual(actors[key]['point'],'yimo' if key=='NPC_YIMO' else None)
            self.assertEqual(actors[key]['npc_flags'],3 if key=='NPC_YIMO' else 0)
            self.assertEqual(actors[key]['experience_multiplier'],0)
        self.assertEqual(len(DATA['arrays']['VillagerEntries']),8)
        self.assertEqual(QUESTS['QUEST_TREAT']['credits'],{'CREDIT_TREATED':8})
        self.assertEqual(QUESTS['QUEST_DESPAIR']['credits'],{'CREDIT_ESSENCES':8,'CREDIT_YIMO':1,'CREDIT_BOSS':1})
        self.assertEqual(len(QUESTS['QUEST_FOOD']['credits']),3)
        self.assertEqual(QUESTS['QUEST_TEST']['required_items'],{'ITEM_FANGS':18,'ITEM_PIGMENT':1})
        self.assertEqual(QUESTS['QUEST_WORK']['credits']['CREDIT_SERVICES'],3)
        self.assertEqual(len(QUESTS['QUEST_WORK']['credits']),4)
        self.assertEqual(actors['NPC_IAIN']['map'],0)
        self.assertEqual(actors['NPC_IAIN']['zone'],47)
        self.assertEqual(actors['NPC_IAIN']['faction'],35)
        for key in ['NPC_KEN','NPC_KEN_SCENE']:
            self.assertEqual(actors[key]['display'],843)
            self.assertNotIn('outfit',actors[key])
        items={i['key']:i for i in DATA['items']}
        self.assertEqual(items['ITEM_FOOD']['maxcount'],6)
        c3=json.loads((ROOT/'data/quests/broken_seal_chapter3.json').read_text())
        self.assertNotEqual(items['ITEM_FOOD']['entry'],c3['ids']['ITEM_FOOD'])
        self.assertEqual(len(QUESTS['QUEST_LETTER']['reward_choices']),6)
        self.assertTrue(DATA['validation']['all_ground_points_checked'])
        self.assertTrue(all(r['complete'] for r in DATA['validation']['routes']))

    def test_generated_files_current(self):
        subprocess.run([sys.executable, str(ROOT / 'tools/generate_broken_seal_chapter4.py'), '--check'], check=True)
        self.assertEqual((ROOT / 'data/sql/db-world/base/broken_seal_chapter4.sql').read_text(),
                         (ROOT / 'data/sql/db-world/updates/2026_10_07_01_broken_seal_chapter4.sql').read_text())


if __name__ == '__main__':
    unittest.main()
