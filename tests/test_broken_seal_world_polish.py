"""Regression contracts for the normal-world polish feedback and shipped upgrade."""
import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
CH=[json.loads((ROOT/f'data/quests/broken_seal_chapter{i}.json').read_text()) for i in [1,2,3,4]]
HUB=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text())


class WorldPolishTests(unittest.TestCase):
    def test_real_clues_visible_captives_and_no_placeholder_cages(self):
        self.assertFalse(any(o['display']==22 for c in CH for o in c['objects']))
        self.assertFalse(any(o['display']==676 for c in CH[:2] for o in c['objects']))
        captives=[a for a in CH[0]['actors'] if a['key'].startswith('NPC_CAPTIVE_')]
        self.assertEqual(len(captives),3)
        self.assertTrue(all(a['point'] and a['npc_flags']==1 for a in captives))
        self.assertEqual(len({a['point'] for a in captives}),3)

    def test_texture_fallbacks_and_armed_cult_roles(self):
        for c in CH:
            for a in c['actors']+c.get('hostile',[]):
                if a.get('outfit'):self.assertGreater(a['fallback_texture_extra'],0,a['key'])
        actors={a['key']:a for a in CH[1]['actors']}
        for k in ['NPC_CONDENNA','NPC_CARGALL','NPC_MYLVA','NPC_DEVORAN']:
            self.assertEqual(actors[k]['faction'],14)
            self.assertTrue(actors[k]['native_appearance'])
            self.assertGreater(actors[k]['outfit']['mainhand'],0)
        for k in ['NPC_GUARD','NPC_SCOUT','NPC_FAILED']:
            self.assertTrue(actors[k]['native_appearance'])
            self.assertGreater(actors[k]['outfit']['mainhand'],0)

    def test_trial_opponents_are_not_permanent_populations(self):
        actors={a['key']:a for a in CH[1]['actors']}
        for k in ['NPC_FIRE','NPC_HORRORGUARD']:
            self.assertFalse(actors[k].get('point'))
            self.assertFalse(actors[k].get('points'))
            self.assertEqual(actors[k]['experience_multiplier'],0)
        q={v['key']:v for v in CH[1]['quests']}
        self.assertEqual(q['QUEST_FIRE']['credits']['CREDIT_FIRE'],8)
        self.assertEqual(q['QUEST_TERRITORY']['credits']['CREDIT_TERRITORY'],10)

    def test_ordinary_loot_and_normal_world_noninterference(self):
        for a in CH[0]['hostile']:
            if a.get('outfit'):
                self.assertGreater(a['ordinary_loot']['mingold'],0)
        self.assertFalse(HUB['policy']['native_spawn_edits'])
        self.assertFalse(HUB['policy']['phasing'])
        self.assertEqual(HUB['policy']['permanent_cult_compounds'],2)
        self.assertFalse(HUB['relocations'])
        recruiting=next(h for h in HUB['hubs'] if h.get('cult'))
        self.assertEqual(set(recruiting['contacts']),{4001200,4001201,4001202,4001203})
        self.assertLessEqual(recruiting['radius'],20)
        self.assertTrue(all(h['radius']<=23 for h in HUB['hubs']))

    def test_repeatable_upgrade_and_frozen_historical_repair(self):
        subprocess.run([sys.executable,str(ROOT/'tools/generate_broken_seal_polish.py'),'--check'],check=True)
        frozen=json.loads((ROOT/'data/quests/broken_seal_legacy_outfits.json').read_text())
        self.assertEqual(len(frozen['rows']),56)
        subprocess.run([sys.executable,str(ROOT/'tools/generate_broken_seal_outfit_fix.py'),'--check'],check=True)


if __name__=='__main__':unittest.main()
