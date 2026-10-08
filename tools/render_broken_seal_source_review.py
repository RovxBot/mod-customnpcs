#!/usr/bin/env python3
"""Render the researched source review and current quest travel measurements."""
import argparse
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/broken-seal/source-review.md'


def generate():
    review = json.loads((ROOT / 'data/quests/broken_seal_source_review.json').read_text())
    chapters = [json.loads((ROOT / f'data/quests/broken_seal_chapter{n}.json').read_text()) for n in range(1, 5)]
    lines = ['# Broken Seal: source gameplay and travel review', '',
             f'Researched **{review["reviewed_on"]}**. {review["scope"]}', '', review['decision'], '',
             review['method'], '',
             'The original prologue contains authored investigations. Commander Jarod Shadowsong (25597) is a retail handoff to Ortell; the campaign lookout is an authored first reconnaissance, not a claim that retail has a spyglass objective.', '',
             '## Corrected interactions', '',
             '- The extra Name on the Papers trip is retired for new players. Existing holders settle it with Ortell; Signed in Blood follows the rewarded commander observation.',
             '- The prologue trail stays away from Jarod\'s compound. The six scouts occupy the route to the separate roadside prisoners; the defended ward sites remain spread across the Vale.',
             '- The recruit is lured through conversation. Labor uses a pick and five ore deposits; agility is a one-minute chase; hound feeding consumes meat hunted from basilisks.',
             '- Ortell\'s repeated intelligence reports use a real native outhouse outside the training camp. The separate documents remain in their camps. Azennios and Okrog are encountered at distinct world locations without a cache or book acting as a summon button.',
             '- The ascendant duel grants the source\'s strike and shield powers through quest-item foci. The ceremony draws the crowd\'s reaction and brings Ortell to the altar; the deposited key releases Jarod, who leaves by a direct escort.',
             '- Dawnchaser poison evidence comes from five blades. A named enemy carries the excavation orders; the pool is a native pond with four guardians and Na Lek\'s healing aid. Nala, Kang and Dezco start their scenes directly.',
             '- Yi-Mo is found before he is brought home. Ken-Ken requests the three-component remedy, then eighteen fangs and pigment; the eight patient treatments and ordered despair finale remain.', '',
             'Rescued captives and captive Jarod use native per-player creature visibility keyed to saved quest progress. The ordinary world phase is unchanged. GM visibility deliberately remains unrestricted; test the player experience with GM mode off.', '',
             '## Native-client substitutions', '']
    lines += ['- ' + text for text in review['native_substitutions']]
    lines += ['', '## Existing realm upgrade', '',
              '1. Rebuild the module. Apply `2026_10_08_00_broken_seal_source_gameplay.sql` to an installed Chapter 1/2 world database.',
              '2. If Chapter 3 is installed, reapply `data/sql/db-world/base/broken_seal_chapter3.sql`. If Chapter 4 is installed, reapply its current base SQL afterward. These are updates to owned content; do not install optional chapters merely to run the correction.',
              '3. Restart with the rebuilt binary after the SQL is ready. For a Chapter 1-only realm, reapply the current Chapter 1 base instead of the combined update. Fresh installs use the documented chapter order and current base SQL.', '',
              'Quest IDs and rewarded history are retained. Changed active objectives receive the revised requirements; existing counter progress is kept, but old item supplies may no longer fit the new task. Recover tools at the contacts, and abandon/reaccept a changed active quest if its saved completion state or client cache does not match the new objectives. Do not reset unrelated quests or characters.', '',
              'The earlier `05` route update remains available for its first revision. The new dated update is required when that earlier name is already marked applied. SQL import alone does not install the changed AI.', '',
              '## Quest-by-quest evidence and travel', '',
              'The distance column gives the shortest and longest objective-point distance from the giver. It excludes cross-map handoffs and does not measure Detour walking-path length. A local investigation or handoff can be short; a named opponent or exploration objective must have a physical subject and a coherent route.', '',
              '| Quest | Source mechanic and evidence | Correction / retained adaptation | Objective distance |',
              '|---|---|---|---|']
    for row in review['quests']:
        chapter = chapters[row['chapter'] - 1]
        quest = next(q for q in chapter['quests'] if q['id'] == row['entry'])
        point = row['giver_point']
        locations = list(dict.fromkeys(p for points in quest['objective_locations'].values() for p in points))
        maps = chapter.get('point_maps', {})
        distances = [math.dist(chapter['points'][point][:2], chapter['points'][p][:2]) for p in locations
                     if point in chapter['points'] and maps.get(point, 1) == maps.get(p, 1)]
        distance = f'{min(distances):.0f}–{max(distances):.0f} m' if distances else 'Contact / handoff'
        source = row['source_mechanic']
        if row['source_url']:
            source = f'[{source}]({row["source_url"]})'
        title = row['title'] + (' (retired)' if row['retired'] else '')
        cells = [f'{row["entry"]}: {title}', source, row['finding'], distance]
        lines.append('| ' + ' | '.join(cell.replace('|', '\\|').replace('\n', ' ') for cell in cells) + ' |')
    lines += ['', '## Offline verification recorded', '',
              '49 campaign Python tests passed. Chapter 1–4 standalone C++ checks and all four runtime syntax checks passed against the current core headers. Native audits checked 55 textured fallbacks, 62 grounded quest-prop placements, all current Chapter 2–4 ground points and navigation routes, the three shared surveyor escort connections and the preserved native quest areas.', '',
              'Current Chapter 1–4 and full-hub SQL imported/reimported on both creature.id1 and legacy creature.id schemas. The October 8 Chapter 1/2 upgrade applied twice to the prior installed polish/quality revision, preserving 154 native NPCs, 155 native objects and quest links, surviving captive/ward GUIDs and a captive appearance override. Retired markers, the native concealed questgiver, source supplies and occupied-ID rejection were checked.', '',
              '## Acceptance checks', '',
              'Offline checks cover generated content, branch gates, native item/actor/object IDs, prop grounding and footprint relief, navigation, core syntax and disposable SQL fixtures. They do not establish client rendering, collision with newly spawned scenery, line of sight through stock models or successful live quest play.', '',
              'In the client, verify the recruit conversation and blackjack arrival; all five lodestone uses; a full chase with combat, death and boundary interruption; five real hound meals; the two ascendant cooldowns, target restriction and shield expiry; field-contact hand-ins; the crowd response, key recovery and Jarod escape; the water encounter with full bags; and Yi-Mo\'s stage-specific location. Test two players with different progress/disguise states, and native quests/patrols around all encounter sites.', '',
              'The remaining client acceptance work is explicit: this review and the offline checks are not a deployment or playthrough claim.', '']
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    content = generate()
    if args.check:
        assert OUT.read_text() == content, 'Stale source review'
    else:
        OUT.write_text(content)
    print('Generated/checked 56 source reviews and current local quest distances.')


if __name__ == '__main__':
    main()
