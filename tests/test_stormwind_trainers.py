"""Identity, appearance, service and placement checks for Stormwind's additions."""

import json
import math
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = json.loads((ROOT / "data/npcs/stormwind_trainers.json").read_text())
IDENTITIES = {
    43277: (1, 0), 43693: (1, 1), 43769: (3, 1), 44247: (1, 0), 44249: (1, 1),
    44251: (1, 1), 44393: (3, 0), 44394: (3, 1), 44396: (22, 1), 44582: (1, 1),
    45306: (7, 1), 51998: (1, 0), 55684: (1, 0), 56796: (1, 1),
}


class StormwindContentTests(unittest.TestCase):
    def test_complete_new_roster_and_identity(self):
        npcs = MANIFEST["npcs"]
        self.assertEqual(len(npcs), 14)
        self.assertEqual({npc["entry"] for npc in npcs}, set(range(4000100, 4000114)))
        self.assertEqual({npc["source_entry"] for npc in npcs}, set(IDENTITIES))
        for npc in npcs:
            self.assertEqual((npc["race"], npc["gender"]), IDENTITIES[npc["source_entry"]])
            self.assertIn(npc["unit_class"], (1, 2, 4, 8))

    def test_canonical_human_form_and_native_wildhammer_skins(self):
        npcs = {npc["source_entry"]: npc for npc in MANIFEST["npcs"]}
        celestine = npcs[44396]
        self.assertEqual(celestine["race"], 22)
        self.assertEqual(celestine["appearance_reference_display"], 29961)
        self.assertEqual((celestine["outfit"]["race"], celestine["outfit"]["gender"]), (1, 1))
        self.assertLess(celestine["position"][0], -8700)
        self.assertGreater(celestine["position"][1], 1050)
        self.assertEqual(sum(npc["outfit"] is not None for npc in npcs.values()), 11)
        for source in (43769, 44393, 44394):
            self.assertIsNone(npcs[source]["outfit"])
            self.assertEqual(npcs[source]["render_race"], 3)

    def test_roles_remain_specific_and_supplies_remain_native(self):
        npcs = {npc["source_entry"]: npc for npc in MANIFEST["npcs"]}
        self.assertEqual(npcs[44251]["trainer_id"], 125)  # Pet trainer, not player hunter curriculum.
        self.assertEqual(npcs[43769]["trainer_id"], 36)   # Wrath riding/flying only.
        self.assertEqual(npcs[43693]["trainer_id"], 37)
        self.assertEqual(npcs[55684]["trainer_id"], 59)
        self.assertEqual(npcs[44582]["trainer_id"], 111)
        self.assertEqual(npcs[56796]["trainer_id"], 81)
        self.assertEqual({vendor["item"] for vendor in npcs[55684]["vendors"]}, {2901, 5956, 2880, 3466, 3857, 18567})
        self.assertTrue(all(vendor["ExtendedCost"] == 0 for vendor in npcs[55684]["vendors"]))
        self.assertEqual(npcs[44249]["equipment"][2], 23748)
        self.assertEqual(npcs[44249]["source_equipment"][2], 57240)

    def test_grounded_placements_and_groups(self):
        npcs = {npc["source_entry"]: npc for npc in MANIFEST["npcs"]}
        for npc in npcs.values():
            self.assertTrue(npc["navigation_checked"])
            self.assertTrue(all(math.isfinite(value) for value in npc["position"]))
            self.assertEqual(npc["position"][3], npc["source_position"][3])
            if npc["source_entry"] != 44396:
                self.assertLess(npc["horizontal_adjustment"], 14)
        self.assertGreater(math.dist(npcs[44393]["position"][:2], npcs[44394]["position"][:2]), 2)
        self.assertLess(math.dist(npcs[44393]["position"][:2], npcs[44394]["position"][:2]), 5)
        hunter_heights = [npcs[source]["position"][2] for source in (43277, 44247, 44249)]
        self.assertLess(max(hunter_heights) - min(hunter_heights), 1)

    def test_generated_sql_is_current(self):
        subprocess.run([sys.executable, str(ROOT / "tools/generate_stormwind_trainers.py"), "--check"], check=True)


if __name__ == "__main__":
    unittest.main()
