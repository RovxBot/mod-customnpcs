#!/usr/bin/env python3
"""Render the manifest as a reviewable top-down hub layout plan (not an in-game screenshot)."""
import html
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
COLORS={'shelter':'#766394','sleeping':'#87775b','supplies':'#aa754c','workstation':'#bd945a',
        'equipment':'#ad824e','medicine':'#5d9c93','lighting':'#ecc276','cooking':'#c86e46','boundary':'#657368','identity':'#a19d65'}


def main():
    d=json.loads((ROOT/'data/quests/broken_seal_hubs.json').read_text());chapters=[json.loads((ROOT/f'data/quests/broken_seal_chapter{i}.json').read_text()) for i in [1,2,3,4]]
    actors={a['entry']:(a['name'],c['points'][a['point']]) for c in chapters for a in c['actors'] if a.get('point')}
    out=['<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="1010" viewBox="0 0 1200 1010">',
         '<rect width="1200" height="1010" fill="#121d26"/>',
         '<text x="20" y="28" fill="#edf5f4" font-size="20" font-family="sans-serif">The Broken Seal — hub layout plan</text>',
         '<text x="20" y="49" fill="#b8c7c8" font-size="12" font-family="sans-serif">Native scenery • cyan: contacts / clear routes • gold: sentries • light circles: protected hand-in areas</text>']
    for i,h in enumerate(d['hubs']):
        left=15+(i%4)*295;top=65+(i//4)*310;extent=max(h['screen_radius'],35);scale=250/(extent*2+8);cx=left+135;cy=top+155
        def xy(x,y):return cx+(x-h['center'][0])*scale,cy-(y-h['center'][1])*scale
        out += [f'<rect x="{left}" y="{top}" width="285" height="298" rx="6" fill="#202e36" stroke="#42555e"/>',
                f'<text x="{left+10}" y="{top+20}" fill="#edf5f4" font-size="13" font-family="sans-serif">{html.escape(h["name"])}</text>',
                f'<circle cx="{cx}" cy="{cy}" r="{h["radius"]*scale}" fill="#24444b" stroke="#467e89" stroke-dasharray="4 3"/>']
        for seg in d['corridors']:
            a,b=seg['a'],seg['b']
            if any(abs(p[0]-h['center'][0])<extent and abs(p[1]-h['center'][1])<extent for p in [a,b]):
                ax,ay=xy(*a[:2]);bx,by=xy(*b[:2])
                # Clip long routes at the panel edge.
                ax=max(left+5,min(left+280,ax));bx=max(left+5,min(left+280,bx));ay=max(top+30,min(top+290,ay));by=max(top+30,min(top+290,by))
                out.append(f'<path d="M {ax:.2f} {ay:.2f} L {bx:.2f} {by:.2f}" stroke="#6aa6b0" stroke-width="2" stroke-dasharray="3 3" fill="none"/>')
        for o in [v for v in d['objects'] if v['hub']==h['key']]:
            b=o['bounds'];x,y=xy(b[0],b[3]);w=(b[2]-b[0])*scale;hh=(b[3]-b[1])*scale
            out.append(f'<rect x="{x:.2f}" y="{y:.2f}" width="{max(w,2):.2f}" height="{max(hh,2):.2f}" fill="{COLORS[o["role"]]}" stroke="#cfdbd4" stroke-width=".5"><title>{html.escape(o["name"])}</title></rect>')
        for entry in h['contacts']:
            if entry not in actors:continue
            name,p=actors[entry];x,y=xy(*p[:2]);out.append(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="3" fill="#8cd3d6"><title>{html.escape(name)}</title></circle>')
        for g in d['guards']:
            if g['hub']!=h['key']:continue
            for p in g['points']:
                x,y=xy(*p[:2]);out.append(f'<path d="M {x:.2f} {y-4:.2f} L {x+4:.2f} {y+3:.2f} L {x-4:.2f} {y+3:.2f} Z" fill="#f0cf7a"><title>Sentry</title></path>')
        out.append(f'<text x="{left+10}" y="{top+284}" fill="#b8c7c8" font-size="11" font-family="sans-serif">{len([o for o in d["objects"] if o["hub"]==h["key"]])} props • 2 sentries • 1 working resident</text>')
    out += ['<text x="20" y="1000" fill="#b8c7c8" font-size="11" font-family="sans-serif">Layout and clearance review. In-game terrain, model rendering and NPC behavior still need a live acceptance pass.</text>','</svg>']
    (ROOT/'docs/broken-seal/hub-layout.svg').write_text('\n'.join(out)+'\n')


if __name__=='__main__':main()
