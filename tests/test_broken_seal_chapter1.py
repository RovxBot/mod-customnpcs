"""Content-integrity and progression checks for the implemented opening chapter."""

import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / 'data/quests/broken_seal_chapter1.json').read_text())
IDS = DATA['ids']


class ChapterOneTests(unittest.TestCase):
    def test_faction_starters_converge_and_every_required_quest_is_reachable(self):
        quests = {q['key']: q for q in DATA['quests']}
        for faction in ('Alliance', 'Horde'):
            completed = set()
            allowed = {key for key, q in quests.items() if q['faction'] in ('Both', faction)}
            while True:
                candidates = {key for key in allowed - completed
                              if (not quests[key]['previous'] or quests[key]['previous'] in completed)
                              and (not quests[key].get('prerequisite_any')
                                   or set(quests[key]['prerequisite_any']) & completed)}
                if not candidates:
                    break
                completed.update(candidates)
            self.assertEqual(completed, allowed)
            self.assertEqual(len(completed), 8)
            self.assertIn('QUEST_RECRUIT', completed)
        self.assertEqual(quests['QUEST_COMMISSION_A']['exclusive_group'],
                         quests['QUEST_COMMISSION_H']['exclusive_group'])
        self.assertTrue(all(q['min_level'] == 20 for q in quests.values()))

    def test_distinct_goals_do_not_overlap_real_kill_targets_or_each_other(self):
        goals = [value for key, value in IDS.items() if key.startswith('CREDIT_')]
        mobs = [a['entry'] for a in DATA['hostile']]
        self.assertEqual(len(goals), len(set(goals)))
        self.assertFalse(set(goals) & set(mobs))
        quests = {q['key']: q for q in DATA['quests']}
        self.assertEqual(quests['QUEST_TRAIL']['credits']['NPC_CULT_SCOUT'], 6)
        self.assertEqual(len(quests['QUEST_TRAIL']['credits']), 4)
        self.assertEqual(len(quests['QUEST_RESCUE']['credits']), 3)
        self.assertEqual(set(quests['QUEST_RESCUE']['credits'].values()), {1})
        self.assertEqual(len(quests['QUEST_WARDS']['credits']), 3)
        self.assertEqual(quests['QUEST_WARDS']['source_item'], 'ITEM_TRACING_KIT')
        self.assertEqual(quests['QUEST_RECRUIT']['credits'], {'CREDIT_RECRUIT': 1, 'CREDIT_SIGNAL': 1})

    def test_personal_captives_have_separate_identity_routes_and_credit(self):
        routes = DATA['escort_routes']
        self.assertEqual(len({r['actor'] for r in routes}), 3)
        self.assertEqual(len({r['cage'] for r in routes}), 3)
        self.assertEqual(len({r['credit'] for r in routes}), 3)
        self.assertTrue(all(r['route'][-1] == DATA['safe_point'] for r in routes))
        proof = DATA['asset_validation']['terrain_and_navigation']['escort_routes']
        self.assertTrue(all(r['complete'] and r['navigation_polygons'] > 1 for r in proof))
        self.assertTrue(DATA['asset_validation']['final_spawn_walkability_checked'])
        self.assertEqual(DATA['asset_validation']['final_ground_positions_checked'], len(DATA['points']))

    def test_reward_budget_and_native_limits(self):
        rewards = [i for i in DATA['items'] if i.get('equipment')]
        self.assertEqual(len(rewards), 6)
        self.assertTrue(all(i['required_level'] == 20 and i['level'] == 25 for i in rewards))
        self.assertTrue(all(1 <= len(i['stats']) <= 3 for i in rewards))
        self.assertTrue(all(len(q.get('credits', {})) <= 4 for q in DATA['quests']))
        self.assertTrue(all(len(q.get('required_items', {})) <= 6 for q in DATA['quests']))
        self.assertFalse(any(q.get('next_quest') for q in DATA['quests']))

    def test_generated_artifacts_and_blueprint_agree(self):
        subprocess.run([sys.executable, str(ROOT / 'tools/generate_broken_seal_chapter1.py'), '--check'], check=True)
        base = ROOT / 'data/sql/db-world/base/broken_seal_chapter1.sql'
        update = ROOT / 'data/sql/db-world/updates/2026_10_06_00_broken_seal_chapter1.sql'
        self.assertEqual(base.read_text(), update.read_text())
        proposal = json.loads((ROOT / 'data/quests/broken_seal_campaign.json').read_text())
        planned = {q['id']: q for q in proposal['chapters'][0]['quests']}
        for q in DATA['quests']:
            self.assertIn(q['logical_id'], planned)
            self.assertEqual(q['title'], planned[q['logical_id']]['title'])
            self.assertEqual(q['faction'], planned[q['logical_id']]['faction'])


if __name__ == '__main__':
    unittest.main()
