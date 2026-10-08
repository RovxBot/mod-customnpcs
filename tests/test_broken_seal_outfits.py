"""Regression checks for complete clothing and valid generated rendering classes."""
import copy
import csv
import importlib
import json
from pathlib import Path
import re
import subprocess
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from broken_seal_outfits import validate_outfits
from verify_broken_seal_outfits import inventory


def outfit_rows(sql):
    match=re.search(r'INSERT INTO `mod_customnpcs_outfit` \((.*?)\) VALUES\n(.*?)\nON DUPLICATE KEY UPDATE',sql,re.S)
    assert match
    cols=re.findall(r'`([^`]+)`',match[1])
    return [dict(zip(cols,map(int,next(csv.reader([line.strip().rstrip(',;')[1:-1]]))))) for line in match[2].splitlines()]


class OutfitRegressionTests(unittest.TestCase):
    def test_campaign_outfits_are_clothed_and_valid(self):
        actors=inventory();validate_outfits(actors)
        dressed=[a for a in actors if a.get('outfit')]
        self.assertEqual(len(dressed),67)
        self.assertTrue(all(a['outfit']['class'] in set(range(1,10))|{11} for a in dressed))
        self.assertTrue(all(a['outfit']['legs'] for a in dressed))
        presets={a['entry']:a['outfit'] for a in dressed}
        self.assertEqual(presets[4001006]['legs'],1431)
        self.assertEqual(presets[4001006]['feet'],1427)
        self.assertEqual(presets[4001007]['legs'],139)
        self.assertEqual(presets[4001007]['feet'],140)

    def test_generators_default_missing_rendering_class_to_valid_one(self):
        for suffix in ['chapter1','chapter2','chapter3','chapter4','hubs']:
            module=importlib.import_module('generate_broken_seal_'+suffix)
            data=json.loads((ROOT/f'data/quests/broken_seal_{suffix}.json').read_text())
            modified=copy.deepcopy(data)
            actors=modified.get('actors',[])+modified.get('hostile',[])+modified.get('guards',[])+modified.get('residents',[])
            for a in actors:
                if a.get('outfit'):a['outfit'].pop('class',None)
            generated=outfit_rows(module.sql(modified))
            self.assertTrue(all(row['class']==1 for row in generated),suffix)
            self.assertTrue(all(row['legs']>0 for row in generated),suffix)

    def test_invalid_class_or_incomplete_wardrobe_fails_authoring(self):
        actor={'entry':1,'outfit':{'race':1,'gender':0,'class':0,'chest':1433,'legs':1431}}
        with self.assertRaises(AssertionError):validate_outfits([actor])
        actor['outfit']['class']=1;actor['outfit']['legs']=0
        with self.assertRaises(AssertionError):validate_outfits([actor])

    def test_repair_is_current_and_appearance_only(self):
        subprocess.run([sys.executable,str(ROOT/'tools/generate_broken_seal_outfit_fix.py'),'--check'],check=True)
        text=(ROOT/'data/sql/db-world/updates/2026_10_07_00_broken_seal_outfit_corrections.sql').read_text()
        self.assertNotIn('UPDATE `creature`',text)
        self.assertNotIn('UPDATE `quest_template`',text)
        self.assertNotIn('mod_customnpcs_outfit_spawn',text)


if __name__=='__main__':unittest.main()
