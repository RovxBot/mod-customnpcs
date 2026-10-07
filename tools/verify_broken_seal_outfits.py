#!/usr/bin/env python3
"""Audit campaign outfits against native item slots, displays and loader class/race rules."""
import argparse
import json
from pathlib import Path
from broken_seal_outfits import validate_outfits
from verify_broken_seal_chapter2_assets import Dbc

ROOT=Path(__file__).resolve().parents[1]
SLOTS={'head':{1},'shoulders':{3},'shirt':{4},'chest':{5,20},'waist':{6},'legs':{7},'feet':{8},'wrists':{9},'hands':{10},'back':{16},'tabard':{19}}


def inventory(chapters=(1,2,3,4), legacy_hubs=False):
    actors=[]
    for n in chapters:
        d=json.loads((ROOT/f'data/quests/broken_seal_chapter{n}.json').read_text());actors+=d.get('actors',[])+d.get('hostile',[])
    d=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text())
    actors += [a for a in d['guards'] if not legacy_hubs or a['entry'] < 4009008]
    actors += [a for a in d['residents'] if not legacy_hubs or a['entry'] < 4009058]
    return actors


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--client-data',type=Path,required=True);args=parser.parse_args()
    item=Dbc(args.client_data/'dbc/Item.dbc');display=Dbc(args.client_data/'dbc/ItemDisplayInfo.dbc')
    actors=inventory();validate_outfits(actors);count=0
    for a in actors:
        outfit=a.get('outfit')
        if not outfit:continue
        count+=1
        for slot,types in SLOTS.items():
            value=outfit.get(slot,0)
            if value>0:
                assert value in item.rows,(a['entry'],slot,value,'missing native item')
                row=item.rows[value]
                assert row[6] in types,(a['entry'],slot,value,'wrong inventory slot',row[6])
                assert row[5] in display.rows,(a['entry'],slot,value,'missing native display')
            elif value<0:assert -value in display.rows,(a['entry'],slot,value)
        for slot in ['mainhand','offhand','ranged']:
            value=outfit.get(slot,0)
            if value:assert value in item.rows and item.rows[value][5] in display.rows,(a['entry'],slot,value)
    print(f'{count} campaign/hub outfits passed loader rules, complete clothing, native inventory slots and display lookup.')


if __name__=='__main__':main()
