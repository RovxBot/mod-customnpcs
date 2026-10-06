"""Integrity checks for the Dawnchaser quest graph, story contracts and generated inventory."""
import itertools
import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / 'data/quests/broken_seal_chapter3.json').read_text())
QUESTS = {q['key']: q for q in DATA['quests']}


class ChapterThreeTests(unittest.TestCase):
    def test_matches_accepted_campaign_graph(self):
        planned = json.loads((ROOT / 'data/quests/broken_seal_campaign.json').read_text())['chapters'][2]
        logical = {q['id']: q for q in planned['quests']}
        keys = {q['design_id']: q['key'] for q in DATA['quests']}
        keys['BS-C02-23'] = 'QUEST_C02_END'
        self.assertEqual(len(QUESTS), 12)
        for q in DATA['quests']:
            design = logical[q['design_id']]
            self.assertEqual(q['title'], design['title'])
            self.assertEqual(q['level'], design['quest_level'])
            self.assertEqual(q['min_level'], 30)
            self.assertEqual(q['prerequisites'], [keys[k] for k in design['prerequisite_all']])
        done = {'QUEST_C02_END'}
        while True:
            ready = {k for k, q in QUESTS.items() if k not in done and set(q['prerequisites']) <= done}
            if not ready:
                break
            done.update(ready)
        self.assertEqual(done, set(QUESTS) | {'QUEST_C02_END'})

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

    def test_ids_and_shared_dezco(self):
        previous = [json.loads((ROOT / f'data/quests/broken_seal_chapter{n}.json').read_text()) for n in [1, 2]]
        for prefixes in [('QUEST_',), ('NPC_', 'CREDIT_'), ('GO_',), ('ITEM_',)]:
            old = {v for d in previous for k, v in d['ids'].items() if k.startswith(prefixes)}
            new = [v for k, v in DATA['ids'].items() if k.startswith(prefixes)
                   and k not in DATA['external_entries'] and k != 'QUEST_C02_END']
            self.assertEqual(len(new), len(set(new)))
            self.assertFalse(set(new) & old)
        self.assertEqual(DATA['ids']['NPC_DEZCO'], previous[1]['ids']['NPC_DEZCO'])
        self.assertEqual(QUESTS['QUEST_SEARCH']['previous'], 'QUEST_C02_END')
        self.assertFalse(QUESTS['QUEST_LETTER'].get('next_quest'))

    def test_story_and_native_inventory_contracts(self):
        actors = {a['key']: a for a in DATA['actors']}
        self.assertIsNone(actors['NPC_LEZA']['point'])
        self.assertEqual(actors['NPC_LEZA']['script'], 'npc_bs_c03_actor')
        self.assertEqual(actors['NPC_CHEZIN']['script'], 'npc_bs_c03_corpse')
        self.assertEqual(actors['NPC_CHEZIN']['npc_flags'], 0)
        for key in ['NPC_REDHORN', 'NPC_CLOUDHOOF']:
            self.assertIsNone(actors[key]['point'])
            self.assertEqual(actors[key]['display'], DATA['native_assets']['infants']['display'])
            self.assertEqual(actors[key]['experience_multiplier'], 0)
        self.assertEqual(QUESTS['QUEST_LIFE']['credits'], {'CREDIT_LIFE': 1})
        self.assertEqual(QUESTS['QUEST_LIVING']['source_count'], 3)
        self.assertEqual(len(QUESTS['QUEST_LIVING']['credits']), 4)
        self.assertEqual(QUESTS['QUEST_VIGIL']['fixed_rewards'], {'ITEM_KEEPSAKE': 1})
        self.assertEqual(len(QUESTS['QUEST_LETTER']['reward_choices']), 6)
        for q in DATA['quests']:
            self.assertLessEqual(len(q['credits']), 4)
            self.assertLessEqual(len(q['required_items']), 6)
            self.assertLessEqual(len(q['fixed_rewards']), 4)
        rewards = [i for i in DATA['items'] if i.get('equipment')]
        self.assertTrue(all(i['required_level'] == 30 and i['level'] == 35 for i in rewards))
        self.assertEqual(len(rewards), 6)
        self.assertTrue(DATA['validation']['all_ground_points_checked'])
        self.assertTrue(all(r['complete'] for r in DATA['validation']['routes']))

    def test_generated_files_current(self):
        subprocess.run([sys.executable, str(ROOT / 'tools/generate_broken_seal_chapter3.py'), '--check'], check=True)
        self.assertEqual((ROOT / 'data/sql/db-world/base/broken_seal_chapter3.sql').read_text(),
                         (ROOT / 'data/sql/db-world/updates/2026_10_06_02_broken_seal_chapter3.sql').read_text())


if __name__ == '__main__':
    unittest.main()
