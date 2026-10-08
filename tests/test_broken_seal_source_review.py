"""Gameplay contracts from the source audit and the player's travel feedback."""
import json
import math
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
CH = [json.loads((ROOT / f'data/quests/broken_seal_chapter{n}.json').read_text()) for n in range(1, 5)]


class SourceGameplayTests(unittest.TestCase):
    def test_reconnaissance_precedes_required_entry_into_jarods_compound(self):
        data = CH[0]
        center = data['points']['jarod'][:2]
        for quest in data['quests']:
            if quest['key'] == 'QUEST_COMMANDER':
                break
            for locations in quest['objective_locations'].values():
                for point in locations:
                    self.assertGreater(math.dist(center, data['points'][point][:2]), 40, (quest['key'], point))
        self.assertTrue(data['quests'][-1]['retired'])
        self.assertEqual(CH[1]['ids']['QUEST_C01_END'], data['ids']['QUEST_COMMANDER'])

    def test_source_training_requires_actions_and_materials(self):
        data = CH[1]
        quests = {q['key']: q for q in data['quests']}
        self.assertEqual(quests['QUEST_BLOOM']['required_items'], {'ITEM_BLOSSOMS': 5})
        self.assertEqual(len(quests['QUEST_WASTE']['credits']), 4)
        self.assertEqual(quests['QUEST_LABOR']['source_item'], 'ITEM_PICK')
        lodestones = next(o for o in data['objects'] if o['key'] == 'GO_STONES')
        self.assertEqual(len(lodestones['points']), 5)
        self.assertEqual(lodestones['display'], 312)
        self.assertEqual(quests['QUEST_DOG']['credits'], {'CREDIT_DOG_A': 5})
        self.assertEqual(quests['QUEST_DOG']['item_drops'], {'ITEM_MEAT': 5})
        self.assertTrue({'ITEM_ASCENDANT_STRIKE', 'ITEM_FLAME_SHIELD'} <= set(quests['QUEST_GREATER']['recovery_items']))

    def test_field_reports_and_named_encounters_are_separate(self):
        data = CH[1]
        quests = {q['key']: q for q in data['quests']}
        for key in ('QUEST_INTELLIGENCE', 'QUEST_DISCORD', 'QUEST_WRITING', 'QUEST_HEAD'):
            self.assertEqual(quests[key]['giver'], 'GO_HIDEOUT')
        self.assertEqual(quests['QUEST_INTELLIGENCE']['credits'], {})
        self.assertEqual(quests['QUEST_DISCORD']['required_items'], {'ITEM_KEY': 1})
        for target in ('discord', 'okrog', 'garnoth', 'horrorguard_0'):
            self.assertGreater(math.dist(data['points'][target][:2], data['points']['prison'][:2]), 100)
        self.assertEqual(quests['QUEST_RIOT']['source_item'], 'ITEM_KEY')

    def test_dawnchaser_evidence_and_pool_are_substantial(self):
        data = CH[2]
        quests = {q['key']: q for q in data['quests']}
        self.assertEqual(quests['QUEST_POISON']['required_items'], {'ITEM_POISON_BLADE': 5})
        self.assertEqual(quests['QUEST_BLIND']['credits'], {'NPC_OUTRIDER': 1})
        self.assertEqual(quests['QUEST_POOLS']['credits'], {'CREDIT_POOL_GUARD': 4})
        self.assertIn({'actor': 'NPC_DOMINATOR', 'item': 'ITEM_ORDERS'}, data['loot'])
        retired = {'GO_LOOKOUT_A', 'GO_LOOKOUT_B', 'GO_LOOKOUT_C', 'GO_POOL', 'GO_DEVICE'}
        self.assertFalse(retired & {o['key'] for o in data['objects']})

    def test_village_finding_precedes_escort_and_materials_precede_mask(self):
        data = CH[3]
        quests = {q['key']: q for q in data['quests']}
        self.assertEqual(quests['QUEST_FIND']['credits'], {})
        self.assertEqual(quests['QUEST_CHEER']['credits'], {'CREDIT_CHEER': 1})
        self.assertEqual(quests['QUEST_MEDICINE']['required_items'],
                         {'ITEM_HONEYCOMB': 4, 'ITEM_MUDFISH': 4, 'ITEM_SALTY_CORE': 4})
        self.assertEqual(quests['QUEST_TEST']['required_items'], {'ITEM_FANGS': 18, 'ITEM_PIGMENT': 1})
        yimo = next(a for a in data['actors'] if a['key'] == 'NPC_YIMO')
        self.assertEqual(yimo['point'], 'yimo')
        self.assertIn('NPC_YIMO', data['arrays']['PersonalEntries'])

    def test_research_covers_every_implemented_record_and_is_current(self):
        review = json.loads((ROOT / 'data/quests/broken_seal_source_review.json').read_text())
        self.assertEqual({r['entry'] for r in review['quests']}, {q['id'] for c in CH for q in c['quests']})
        self.assertEqual(len(review['quests']), 56)
        for tool in ('render_broken_seal_source_review.py', 'generate_broken_seal_source_gameplay.py'):
            subprocess.run([sys.executable, str(ROOT / 'tools' / tool), '--check'], check=True)


if __name__ == '__main__':
    unittest.main()
