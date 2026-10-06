"""Validate the complete branch graph, native inventory and generated Chapter 2 artifacts."""
import itertools
import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / 'data/quests/broken_seal_chapter2.json').read_text())
C01 = json.loads((ROOT / 'data/quests/broken_seal_chapter1.json').read_text())
QUESTS = {q['key']: q for q in DATA['quests']}


class ChapterTwoTests(unittest.TestCase):
    def test_design_and_implementation_agree(self):
        plan = json.loads((ROOT / 'data/quests/broken_seal_campaign.json').read_text())['chapters'][1]
        logical = {q['id']: q for q in plan['quests']}
        keys = {q['design_id']: q['key'] for q in DATA['quests']}
        keys['BS-C01-09'] = 'QUEST_C01_END'
        self.assertEqual(len(logical), len(QUESTS))
        for q in DATA['quests']:
            intended = logical[q['design_id']]
            self.assertEqual(q['title'], intended['title'])
            self.assertEqual(q['level'], intended['quest_level'])
            self.assertEqual(q['prerequisites'], [keys[k] for k in intended['prerequisite_all']])
            self.assertEqual(q['min_level'], 25)
            self.assertTrue(q['description'] and q['completion'])

    def test_all_branches_are_required_but_can_run_in_any_order(self):
        for order in itertools.permutations(['QUEST_MERCY', 'QUEST_GRUDGE', 'QUEST_DISCORD']):
            completed = {'QUEST_C01_END'}
            while True:
                candidates = {k for k, q in QUESTS.items() if k not in completed and set(q['prerequisites']) <= completed}
                if not candidates:
                    break
                completed.update(candidates)
            self.assertEqual(completed, set(QUESTS) | {'QUEST_C01_END'})
            done = set()
            for key in order[:-1]:
                done.add(key)
                self.assertFalse(set(QUESTS['QUEST_GREATER']['prerequisites']) <= done)
                self.assertFalse(set(QUESTS['QUEST_TERRITORY']['prerequisites']) <= done)
            done.add(order[-1])
            self.assertTrue(set(QUESTS['QUEST_GREATER']['prerequisites']) <= done)
        for q in DATA['quests']:
            parents = q['prerequisites']
            if len(parents) > 1:
                groups = {QUESTS[k]['exclusive_group'] for k in parents}
                self.assertEqual(len(groups), 1)
                self.assertLess(next(iter(groups)), 0)
                self.assertEqual({k for k, v in QUESTS.items() if v.get('exclusive_group') in groups}, set(parents))

    def test_custom_ids_are_disjoint_from_chapter1(self):
        for prefixes in [('QUEST_',), ('NPC_', 'CREDIT_'), ('GO_',), ('ITEM_',)]:
            old = {v for k, v in C01['ids'].items() if k.startswith(prefixes)}
            new = [v for k, v in DATA['ids'].items() if k.startswith(prefixes)
                   and k not in DATA['external_entries'] and k != 'QUEST_C01_END']
            self.assertEqual(len(new), len(set(new)))
            self.assertFalse(set(new) & old)
        self.assertEqual(DATA['ids']['NPC_ORTELL'], C01['ids']['NPC_ORTELL'])
        self.assertEqual(DATA['ids']['NPC_PRISONER'], C01['ids']['NPC_JAROD'])

    def test_inventory_covers_native_client_limits_and_recovery(self):
        actors = {a['key'] for a in DATA['actors']} | DATA['external_entries'].keys()
        items = {i['key'] for i in DATA['items']}
        for q in DATA['quests']:
            self.assertIn(q['giver'], actors)
            self.assertIn(q['turn_in'], actors)
            self.assertLessEqual(len(q['credits']), 4)
            self.assertLessEqual(len(q['required_items']), 6)
            self.assertTrue(set(q['required_items']) <= items)
            self.assertTrue(set(q['recovery_items']) <= items)
            if q['source_item']:
                self.assertIn(q['source_item'], q['recovery_items'])
        self.assertEqual(QUESTS['QUEST_GRUDGE']['recovery_items'], ['ITEM_LEASH', 'ITEM_COLLAR'])
        self.assertEqual(len(QUESTS['QUEST_WASTE']['credits']), 3)
        self.assertEqual(len(QUESTS['QUEST_DOG']['credits']), 3)
        self.assertEqual(QUESTS['QUEST_MENTAL']['credits']['CREDIT_MENTAL'], 10)
        self.assertEqual(QUESTS['QUEST_SPEECH']['credits']['CREDIT_SPEECH'], 10)
        self.assertIn('NPC_BUTCHER', actors)
        self.assertEqual(len(QUESTS['QUEST_LETTER']['reward_choices']), 6)
        self.assertFalse(QUESTS['QUEST_LETTER'].get('next_quest'))
        self.assertEqual(DATA['routes']['EscapeRoute'][-1], 'refuge')
        self.assertTrue(DATA['validation']['all_ground_points_checked'])
        self.assertTrue(all(r['complete'] for r in DATA['validation']['routes']))

    def test_generated_files_are_current(self):
        subprocess.run([sys.executable, str(ROOT / 'tools/generate_broken_seal_chapter2.py'), '--check'], check=True)
        self.assertEqual((ROOT / 'data/sql/db-world/base/broken_seal_chapter2.sql').read_text(),
                         (ROOT / 'data/sql/db-world/updates/2026_10_06_01_broken_seal_chapter2.sql').read_text())


if __name__ == '__main__':
    unittest.main()
