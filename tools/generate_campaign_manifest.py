#!/usr/bin/env python3
"""Validate the Broken Seal design inventory and render its review documents.

This tool produces documentation, not installable quest/NPC SQL.
"""

import argparse
import csv
import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'data/quests/broken_seal_campaign.json'
OUTPUT = ROOT / 'docs/broken-seal'


def check_manifest(data):
    chapters = data['chapters']
    catalog = data['catalog']
    quests = [q for ch in chapters for q in ch['quests']]
    indexed = {q['id']: q for q in quests}
    assert len(indexed) == len(quests), 'Duplicate quest IDs'
    assert len({c['id'] for c in chapters}) == len(chapters), 'Duplicate chapter IDs'
    assert chapters[0]['levels'][0] == 20 and chapters[-1]['levels'][1] == 80
    for left, right in zip(chapters, chapters[1:]):
        assert left['levels'][1] == right['levels'][0], 'Gap or overlap in chapter levels'
    reward_groups = {}
    for key, item in catalog['items'].items():
        if item.get('reward_group'):
            reward_groups.setdefault(item['reward_group'], []).append(key)
    for group, choices in reward_groups.items():
        assert len(choices) == 6, f'{group}: expected six quest reward choices'
    for ch in chapters:
        for q in ch['quests']:
            assert ch['levels'][0] <= q['min_level'] <= q['quest_level'] <= ch['levels'][1], q['id']
            assert q['faction'] in ('Both', 'Alliance', 'Horde')
            assert q['objective'] and q['giver'] and q['turn_in'], q['id']
            refs = q['prerequisite_all'] + q['prerequisite_any']
            assert all(p in indexed and p != q['id'] for p in refs), f'{q["id"]}: invalid prerequisite'
            for kind in ('npcs', 'mobs', 'objects'):
                assert set(q[kind]) <= catalog[kind].keys(), f'{q["id"]}: missing {kind}'
            assert q['giver'] in q['npcs'] and q['turn_in'] in q['npcs']
            item_refs = set(q['items_provided']) | set(q['items_acquired']) | set(q['items_used'])
            item_refs.update(q['reward']['fixed_items'])
            assert item_refs <= catalog['items'].keys(), f'{q["id"]}: missing item'
            for field in ('items_provided', 'items_acquired'):
                assert all(isinstance(v, int) and v > 0 for v in q[field].values()), q['id']
            assert not set(q['items_acquired']) & set(q['reward']['fixed_items']), f'{q["id"]}: duplicate fixed grant'
            if q['reward']['choice_group']:
                assert q['reward']['choice_group'] in reward_groups, q['id']
            source = q['source']
            assert source['type'] in ('original', 'adapted')
            if source['type'] == 'adapted':
                assert source['reference'] in data['sources'] and source['original_title'], q['id']
            else:
                assert source['quest_id'] is None and source['original_title'] is None, q['id']

    # Reject cycles even when a permissive OR prerequisite might make them reachable.
    visiting = set()
    visited = set()

    def visit(key):
        assert key not in visiting, f'Prerequisite cycle through {key}'
        if key in visited:
            return
        visiting.add(key)
        for parent in indexed[key]['prerequisite_all'] + indexed[key]['prerequisite_any']:
            visit(parent)
        visiting.remove(key)
        visited.add(key)

    for key in indexed:
        visit(key)

    paths = {}
    for faction in ('Alliance', 'Horde'):
        eligible = {q['id'] for q in quests if q['faction'] in ('Both', faction) and not q.get('retired')}
        completed = set()
        while True:
            next_ids = {key for key in eligible - completed
                        if set(indexed[key]['prerequisite_all']) <= completed
                        and (not indexed[key]['prerequisite_any']
                             or set(indexed[key]['prerequisite_any']) & completed)}
            if not next_ids:
                break
            completed.update(next_ids)
        assert completed == eligible, f'{faction}: unreachable quests {sorted(eligible - completed)}'
        assert chapters[-1]['quests'][-1]['id'] in completed, f'{faction}: finale unreachable'
        paths[faction] = len(completed)

    # Availability matters independently of the dependency graph.
    death_limits = {'leza': 'Life', 'lin': 'Jung Duk', 'suna': 'The Point of No Return',
                    'maruut': 'The Binding', 'grundy': 'Wild, Wild, Wildhammer Wedding'}
    for actor, title in death_limits.items():
        indices = [idx for idx, q in enumerate(quests) if q['title'] == title]
        assert len(indices) == 1, title
        for q in quests[indices[0] + 1:]:
            assert actor not in q['npcs'], f'{q["id"]}: living appearance after {actor} death'

    for kind, table in catalog.items():
        for key, entity in table.items():
            assert entity['database_id'] is None, f'{kind}/{key}: design must not allocate server IDs'
            actual = []
            for ch in chapters:
                for q in ch['quests']:
                    if kind == 'items':
                        found = (key in q['items_provided'] or key in q['items_acquired']
                                 or key in q['items_used'] or key in q['reward']['fixed_items']
                                 or bool(entity.get('reward_group'))
                                 and q['reward']['choice_group'] == entity['reward_group'])
                    else:
                        found = key in q[kind]
                    if found:
                        actual.append(ch['id'])
                        break
            assert actual and actual == entity['chapters'], f'{kind}/{key}: incorrect usage catalog'
    return quests, paths


def check_donors(data, core_root):
    world = core_root / 'data/sql/base/db_world'
    names = {}
    for line in (world / 'creature_template.sql').read_text().splitlines():
        if line.startswith('('):
            fields = next(csv.reader([line[1:line.rfind(')')]], quotechar="'", escapechar='\\'))
            names[int(fields[0])] = fields[6]
    models = {}
    for line in (world / 'creature_template_model.sql').read_text().splitlines():
        if line.startswith('('):
            fields = line[1:line.rfind(')')].split(',')
            models.setdefault(int(fields[0]), []).append(int(fields[2]))
    count = 0
    for kind in ('npcs', 'mobs'):
        for key, entity in data['catalog'][kind].items():
            entry = entity.get('donor_entry')
            if entry is not None:
                assert entry in names and models.get(entry), f'{kind}/{key}: missing native donor {entry}'
                count += 1
    return count


def cell(text):
    return str(text).replace('|', '\\|').replace('\n', '<br>')


def source_link(q, sources):
    source = q['source']
    if source['type'] == 'original':
        return 'New campaign quest'
    url = (f'https://www.wowhead.com/quest={source["quest_id"]}' if source['quest_id']
           else sources[source['reference']]['url'])
    suffix = f' (reference ID {source["quest_id"]})' if source['quest_id'] else ' (ID unverified)'
    return f'Adapted from [{source["original_title"]}]({url}){suffix}'


def references(keys, kind, data):
    return ', '.join(f'[{data["catalog"][kind][key]["name"]}](catalog.md#{kind}-{key})' for key in keys) or 'None'


def chapter_text(ch, data):
    sources = data['sources']
    lines = [f'# {ch["id"]}: {ch["title"]}', '',
             f'Levels **{ch["levels"][0]}–{ch["levels"][1]}** · {ch["zone"]} · **{len(ch["quests"])} quest records**', '',
             '[Campaign index](README.md) · [Full entity catalog](catalog.md)', '',
             ch['adaptation_notes'], '', f'**Chapter outcome:** {ch["endpoint"]}', '',
             'Every objective and count below is the proposed adaptation. Source links identify the donor story; '
             'the listed givers, location, quantities and rewards are campaign design choices.', '',
             'All quests award normal level-appropriate XP and money. This is a story route alongside ordinary leveling. '
             'Prerequisites below override display order; ALL and ANY mean exactly those joins.', '']
    if ch['id'] in ('C01', 'C02', 'C03', 'C04'):
        number = int(ch['id'][1:])
        lines += [f'**Implementation:** [Installation, server IDs and gameplay checks](chapter{number}-implementation.md).', '']
    lines += ['## Quest list', '', '| Quest | Title | Origin |', '|---|---|---|']
    for q in ch['quests']:
        origin = 'Adapted' if q['source']['type'] == 'adapted' else 'New'
        lines.append(f'| [{q["id"]}](#{q["id"].lower()}) | {cell(q["title"])} | {origin} |')
    lines.append('')
    for q in ch['quests']:
        lines += [f'<a id="{q["id"].lower()}"></a>', '', f'## {q["id"]}: {q["title"]}', '', source_link(q, sources), '',
                  f'**Level:** target {q["quest_level"]}, minimum {q["min_level"]}; **faction:** {q["faction"]}.', '',
                  f'**Giver → turn-in:** {references([q["giver"]], "npcs", data)} → {references([q["turn_in"]], "npcs", data)}.', '',
                  '**Prerequisites:** ALL ' + (', '.join(q['prerequisite_all']) or 'none')
                  + '; ANY ' + (', '.join(q['prerequisite_any']) or 'none') + '.', '',
                  f'**Objective:** {q["objective"]}', '',
                  f'**NPC actors:** {references(q["npcs"], "npcs", data)}.', '',
                  f'**Enemies / training creatures:** {references(q["mobs"], "mobs", data)}.', '',
                  f'**Interactables:** {references(q["objects"], "objects", data)}.', '']
        for label, field in [('Provided on accept/retry', 'items_provided'), ('Acquire / deposit', 'items_acquired')]:
            if q[field]:
                refs = [f'{references([key], "items", data)} ×{count}' for key, count in q[field].items()]
                lines += [f'**{label}:** ' + '; '.join(refs) + '.', '']
        if not q['items_provided'] and not q['items_acquired'] and not q['items_used']:
            lines += ['**Quest items:** None; earlier evidence is retrieved through quest history if mentioned.', '']
        if q['items_used']:
            lines += [f'**Other items used:** {references(q["items_used"], "items", data)}.', '']
        reward = q['reward']
        parts = ['Normal XP/money']
        if reward['choice_group']:
            keys = [k for k, v in data['catalog']['items'].items() if v.get('reward_group') == reward['choice_group']]
            parts += ['choose ONE: ' + references(keys, 'items', data)]
        if reward['fixed_items']:
            parts += ['fixed grant: ' + references(reward['fixed_items'], 'items', data)]
        lines += ['**Rewards:** ' + '; '.join(parts) + '.', '']
        if q['scene_notes']:
            lines += [f'**Scene / adaptation requirement:** {q["scene_notes"]}', '']
    lines += ['## Chapter asset checklist', '']
    for kind, label in [('npcs', 'NPC roles'), ('mobs', 'Creature roles'), ('items', 'Quest items, keepsakes and rewards'), ('objects', 'World interactables')]:
        keys = [key for key, value in data['catalog'][kind].items() if ch['id'] in value['chapters']]
        lines += [f'**{label} ({len(keys)}):** {references(keys, kind, data)}.', '']
    return '\n'.join(lines).rstrip() + '\n'


def catalog_text(data):
    lines = ['# The Broken Seal: complete entity catalog', '', '[Campaign index](README.md)', '',
             'Logical keys describe required campaign roles and item definitions. They are not allocated database IDs. '
             'One creature role can need multiple templates/instances for level bands and scene states. '
             'Appearance donors are checked stock candidates, not templates to overwrite.', '',
             'An appearance plan labeled recreation deliberately changes the original race or body. '
             'Undetermined exact native displays, outfits, stats and placements remain implementation work.', '']
    for kind, label in [('npcs', 'NPCs and friendly actors'), ('mobs', 'Enemies, bosses and training creatures'),
                        ('items', 'Quest items, keepsakes and equipment'), ('objects', 'Interactable objects and scene sites')]:
        lines += [f'## {label} ({len(data["catalog"][kind])})', '']
        for key, value in data['catalog'][kind].items():
            lines += [f'<a id="{kind}-{key}"></a>', '', f'### {value["name"]}', '',
                      f'**Key:** `{key}` · **Chapters:** {", ".join(value["chapters"])}.', '']
            if kind == 'items':
                lines += [f'**Type / purpose:** {value["kind"]}; {value["role"]}.', '',
                          f'**Visual:** {value["visual_plan"]}.', '',
                          f'**Binding / lifecycle:** {value["binding"]}; {value["lifecycle"]}.', '']
            elif kind == 'objects':
                lines += [f'**Native representation:** {value["appearance_plan"]}.', '',
                          f'**Interaction:** {value["interaction"]}.', '']
            else:
                lines += [f'**Role:** {value["role"]}.', '', f'**Appearance:** {value["appearance_plan"]}.', '']
                if value.get('origin'):
                    lines += [f'**Origin:** {value["origin"]}.', '']
                if value.get('donor_entry') is not None:
                    lines += [f'**Stock appearance candidate:** creature {value["donor_entry"]}; donor model row checked, exact use/animations pending.', '']
                    evidence = value.get('stock_appearance_evidence')
                    if evidence:
                        displays = ', '.join(str(v) for v in evidence['display_ids'])
                        lines += [f'**Checked stock record:** {evidence["stock_name"]}; native display IDs {displays}; '
                                  f'checked {evidence["checked_on"]}.', '']
                if kind == 'mobs':
                    bands = '; '.join(f'{chapter}: {limits[0]}–{limits[1]}' for chapter, limits in value['level_bands'].items())
                    lines += [f'**Required level variants:** {bands}.', '']
    return '\n'.join(lines).rstrip() + '\n'


def index_text(data, quests, paths):
    catalog = data['catalog']
    counts = Counter(q['source']['type'] for q in quests)
    item_counts = Counter(i['kind'] for i in catalog['items'].values())
    lines = ['# The Broken Seal: full quest and asset inventory', '',
             f'Design inventory, {data["researched_on"]}. **{len(quests)} quest records; {paths["Alliance"]} required quests per character** '
             '(Alliance and Horde entry quests are alternatives). **14 chapters, levels 20–80.**', '',
             f'**Sources:** {counts["adapted"]} source-adapted quest records and {counts["original"]} new connecting/story quests. '
             'Split vision wrappers and renamed counterpart quests count as adaptations, not as additional original Blizzard quests.', '',
             f'**Inventory:** {len(catalog["npcs"])} NPC/friendly-actor roles, {len(catalog["mobs"])} hostile/training-creature roles, '
             f'{item_counts["quest_item"]} quest items, {item_counts["keepsake"]} keepsakes, '
             f'{item_counts["equipment_reward"]} chapter reward choices, and {len(catalog["objects"])} interactables.', '',
             '[Complete entity catalog](catalog.md) · [Machine-readable manifest](../../data/quests/broken_seal_campaign.json) '
             '· [Campaign proposal](../level-20-80-campaign-proposal.md)', '',
             '**Chapters 1–4 have runtime code and installation SQL.** '
             'See the [Chapter 1](chapter1-implementation.md), [Chapter 2](chapter2-implementation.md) and '
             '[Chapter 3](chapter3-implementation.md) and [Chapter 4](chapter4-implementation.md) guides. '
             'Chapters 5–14 remain design inventories.', '',
             'This expands the accepted proposal into a complete required path. Full training, earthen-warfront, '
             'council and vision branches make the inventory larger than the earlier 140–180 estimate. '
             'Chapters 1–4 are implemented in the repository; no realm deployment or client patch was performed.', '',
             '## Chapters', '', '| Levels | Chapter | Quest records | Full quest list |', '|---|---|---:|---|']
    for ch in data['chapters']:
        filename = f'{ch["id"].lower()}.md'
        lines.append(f'| {ch["levels"][0]}–{ch["levels"][1]} | {cell(ch["title"])} | {len(ch["quests"])} | [{ch["id"]}]({filename}) |')
    lines += ['', '## Reading the quest lists', '',
              'Every quest names the giver and turn-in actor, target/minimum level, faction, ALL/ANY prerequisites, '
              'objective, friendly actors, enemies, objects, provided items, acquired evidence and reward choices. '
              'Source IDs are only recorded when verified; otherwise the donor title and branch reference are provided. '
              'Objective counts, giver changes and local item names are proposed for this adaptation.', '',
              'The required path is shared after the two alternate entrances. Source zone-opening quests, reputation '
              'grinds, dailies, raids and unrelated branches are replaced by expedition handoffs. '
              'The full-list claim refers to this adaptation, not every quest in the original expansion zones.', '',
              '## Required implementation contracts', '']
    lines += [f'- {contract}' for contract in data['global_contracts']]
    lines += ['', '## Specific fidelity changes', '',
              '- Native humanoid outfits recreate later cast members; exact race/outfit is still audited where explicitly marked.',
              '- Yi-Mo, Mei, Kang and the Suna-party pandaren are openly recast into native races. Ken-Ken uses a native animal approximation.',
              '- The World Pillar becomes a new local ward network, and Therazanes visible role becomes a council emissary.',
              '- Mogu/yaungol/mantid become named native raider/Silithid counterparts; later sha visuals become a local shadow curse.',
              '- Source vehicle/action-bar interactions use native controls or specified item/gossip equivalents. The final colossus uses timed ground weak-point attacks.',
              '- The native North Sea Kraken represents Ozumat during the last vision; no exact Ozumat or QuelDormir geometry is claimed.', '',
              '## Implementation audits still required', '',
              'Final custom database allocations, individual spawn quantities/coordinates, reachable paths, exact native '
              'item/gameobject displays, outfits, spell IDs, AI, loot tables, numeric item/XP budgets, and scene recovery '
              'are not production-ready. The manifest supplies the complete named design inventory; these are build details '
              'to resolve before importing content. Generic crowd/mob roles need multiple spawns and, where specified, multiple level/state templates.', '',
              'Ordinary quests supply additional leveling XP. Chapter openings are level-gated; the final record quest requires level 80. '
              'All required encounters are designed for solo completion with scripted allies, with difficulty still to tune.', '',
              '## Validation and regeneration', '',
              '```bash', 'python3 tools/generate_campaign_manifest.py --check',
              'python3 tools/generate_campaign_manifest.py --check --core-root /path/to/azerothcore-wotlk', '```', '',
              'The generator checks unique IDs, valid catalog references, dependency cycles, faction reachability, '
              'chapter level continuity, six-choice reward groups, dead-character availability and catalog usage. '
              'The optional read-only core check verifies that each specified stock appearance donor exists with a model. '
              'It does not validate client animation or in-game placement.', '',
              'Edit the JSON manifest, then run the generator without `--check` to update the documents. '
              'New connecting quests and proposed objective counts are original design work. Some source pages were accessible '
              'through indexed excerpts; individual donor-ID and behavior verification continues during implementation.', '',
              '## Source references', '']
    lines += [f'- [{v["name"]}]({v["url"]})' for v in data['sources'].values()]
    return '\n'.join(lines).rstrip() + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Validate and verify generated files without writing')
    parser.add_argument('--core-root', type=Path, help='Read-only stock creature/model donor check')
    args = parser.parse_args()
    data = json.loads(MANIFEST.read_text())
    quests, paths = check_manifest(data)
    donor_count = check_donors(data, args.core_root) if args.core_root else None
    files = {OUTPUT / 'README.md': index_text(data, quests, paths), OUTPUT / 'catalog.md': catalog_text(data)}
    for ch in data['chapters']:
        files[OUTPUT / f'{ch["id"].lower()}.md'] = chapter_text(ch, data)
    for path, content in files.items():
        if args.check:
            assert path.is_file() and path.read_text() == content, f'Stale generated document: {path}'
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
    print(f'Validated {len(quests)} quest records; faction paths {paths}; {len(files)} documents.'
          + (f' Checked {donor_count} native appearance donor references.' if donor_count is not None else ''))


if __name__ == '__main__':
    main()
