"""Content invariants for the later-expansion Orgrimmar recreations."""

import importlib.util
import json
import math
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = json.loads((ROOT / "data/npcs/orgrimmar_trainers.json").read_text())

# Independent source identity checks: several previous generic donors had the wrong race/sex.
IDENTITIES = {
    44726: (6, 1), 44743: (6, 0), 45714: (9, 1), 44725: (6, 0), 44735: (6, 1),
    45095: (8, 0), 44740: (6, 1), 45138: (8, 1), 46667: (2, 0), 44975: (8, 0),
    45540: (9, 0), 45545: (9, 0), 45548: (9, 0), 45550: (9, 0), 45559: (9, 1),
    44782: (6, 0), 52170: (9, 0), 46675: (2, 1), 46716: (2, 0), 46741: (2, 1),
}


class OrgrimmarContentTests(unittest.TestCase):
    def test_complete_roster_and_correct_identities(self):
        npcs = MANIFEST["npcs"]
        self.assertEqual({npc["entry"] for npc in npcs}, set(range(4000005, 4000025)))
        self.assertEqual(len(npcs), 20)
        self.assertEqual({npc["source_entry"] for npc in npcs}, set(IDENTITIES))
        for npc in npcs:
            self.assertEqual((npc["race"], npc["gender"]), IDENTITIES[npc["source_entry"]])
            if npc["race"] == 9:
                self.assertIsNone(npc["outfit"], "Legacy goblins must retain native goblin models.")
            else:
                self.assertEqual((npc["outfit"]["race"], npc["outfit"]["gender"]), IDENTITIES[npc["source_entry"]])
            self.assertGreater(npc["fallback_display"], 0)

    def test_placements_stay_near_the_recorded_location(self):
        unchanged = 0
        for npc in MANIFEST["npcs"]:
            x, y, z, facing = npc["position"]
            source_x, source_y, _, source_facing = npc["source_position"]
            self.assertTrue(all(math.isfinite(value) for value in npc["position"]))
            self.assertTrue(npc["navigation_checked"])
            self.assertLessEqual(math.hypot(x - source_x, y - source_y), 18)
            self.assertAlmostEqual(facing, source_facing)
            self.assertTrue(1200 <= x <= 2300 and -5100 <= y <= -3800)
            unchanged += x == source_x and y == source_y
        self.assertEqual(unchanged, 13)

    def test_weapon_and_pose_identity(self):
        for npc in MANIFEST["npcs"]:
            if npc["source_entry"] == 46667:
                self.assertEqual(npc["source_equipment"], [10613, 62373, 0])
                self.assertEqual(npc["equipment"], [10613, 0, 0])
            else:
                self.assertEqual(npc["equipment"], npc["source_equipment"])
            self.assertIn(npc["stand_state"], (0, 1))
            self.assertIn(npc["sheath_state"], (0, 1, 2))
        seated = [npc["source_entry"] for npc in MANIFEST["npcs"] if npc["stand_state"] == 1]
        self.assertEqual(seated, [45095])

    def test_generated_sql_is_current_and_preserves_spawn_overrides(self):
        spec = importlib.util.spec_from_file_location("generator", ROOT / "tools/generate_orgrimmar_appearances.py")
        generator = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(generator)
        expected = generator.generate(MANIFEST)
        for path in generator.OUTPUTS:
            self.assertEqual(path.read_text(), expected)
        self.assertNotIn("DELETE FROM `mod_customnpcs_outfit_spawn`", expected)
        self.assertNotIn("DELETE c FROM `creature`", expected)
        self.assertIn("'id1', 'id'", expected)
        self.assertIn("c.`map` = 1", expected)
        self.assertIn("BETWEEN 1200 AND 2300", expected)


if __name__ == "__main__":
    unittest.main()
