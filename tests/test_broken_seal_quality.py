"""Regression checks for authored objectives and installed-chapter quality upgrades."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from broken_seal_content import quest_poi_rows, validate_quest_polish


class CampaignQualityTests(unittest.TestCase):
    def test_all_objectives_have_authored_labels_and_matching_map_slots(self):
        for chapter in range(1,5):
            data=json.loads((ROOT/f'data/quests/broken_seal_chapter{chapter}.json').read_text())
            validate_quest_polish(data)
            actors={a['key']:a['point'] for a in data['actors'] if a.get('point')}
            actors.update(NPC_ORTELL='ortell',NPC_PRISONER='prison',NPC_JAROD_FREE='refuge',NPC_DEZCO='dezco',NPC_MEI='mei')
            actors.update(NPC_YIMO='yimo')
            actors.update({o['key']:o['points'][0] for o in data['objects'] if o.get('questgiver')})
            poi,points=quest_poi_rows(data,actors)
            self.assertEqual(len(poi),len(points))
            for quest in data['quests']:
                slots={p[2] for p in poi if p[0]==quest['id']}
                expected={-1}|set(range(len(quest.get('credits',{}))))|set(range(4,4+len(quest.get('required_items',{}))))
                self.assertEqual(slots,expected,quest['title'])
            if chapter==4:
                self.assertTrue(all(p[3:5]==[0,26] for p in poi if p[0]==900411))
            broken=copy.deepcopy(data)
            broken['quests'][0]['objective_locations']={}
            with self.assertRaises(AssertionError):
                validate_quest_polish(broken)

    def test_ordinary_enemies_have_rewards_without_farmable_private_actors(self):
        for chapter in range(1,5):
            data=json.loads((ROOT/f'data/quests/broken_seal_chapter{chapter}.json').read_text())
            for actor in data['actors']+data.get('hostile',[]):
                if actor in data.get('hostile',[]) or (actor.get('points') and actor.get('experience_multiplier')):
                    self.assertIn('ordinary_loot',actor,actor['name'])
                    self.assertGreater(actor['ordinary_loot']['mingold'],0,actor['name'])
                    self.assertGreaterEqual(actor['ordinary_loot']['maxgold'],actor['ordinary_loot']['mingold'])
                if actor.get('script','').endswith('_enemy') and not actor.get('point') and not actor.get('points'):
                    self.assertEqual(actor['experience_multiplier'],0,actor['name'])
                    self.assertNotIn('ordinary_loot',actor,actor['name'])

    def test_later_hub_residents_and_refugees_are_distinct(self):
        data=json.loads((ROOT/'data/quests/broken_seal_chapter3.json').read_text())
        refugees=[a for a in data['actors'] if a['key'].startswith('NPC_REFUGEE_')]
        self.assertEqual(len({a['greeting'] for a in refugees}),3)
        self.assertFalse(any('Group ' in a['name'] for a in refugees))
        hubs=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text())
        self.assertTrue(all(a['greeting'] and 'Camp Camp' not in a['name'] for a in hubs['residents']))

    def test_documents_and_tools_use_identifiable_native_icons(self):
        for chapter in range(1,5):
            data=json.loads((ROOT/f'data/quests/broken_seal_chapter{chapter}.json').read_text())
            for item in data['items']:
                self.assertNotEqual(item['display'],18098,item['name'])
                self.assertTrue(item['description'],item['name'])
        data=json.loads((ROOT/'data/quests/broken_seal_chapter2.json').read_text())
        tools={i['display'] for i in data['items'] if i['key'] in
               ['ITEM_BLACKJACK','ITEM_BLOSSOMS','ITEM_GEM','ITEM_LEASH','ITEM_HIDE','ITEM_KEY']}
        self.assertEqual(len(tools),6)

    def test_upgrade_is_generated_from_current_manifests(self):
        subprocess.run([sys.executable,str(ROOT/'tools/generate_broken_seal_quality.py'),'--check'],check=True)


if __name__=='__main__':
    unittest.main()
