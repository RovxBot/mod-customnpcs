"""Cross-city identity, service and placement invariants for the remaining capitals."""

import json
import math
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
ORDER = ("ironforge", "darnassus", "thunder_bluff", "undercity")
MANIFESTS = {city: json.loads((ROOT / f"data/npcs/{city}_trainers.json").read_text()) for city in ORDER}
EXPECTED = {
    "ironforge": {
        50716: (3, 0, 16), 50717: (3, 1, 16), 50720: (3, 1, 16),
        50723: (3, 0, 31), 50729: (3, 1, 31), 50732: (3, 0, 31),
        52335: (22, 0, 33), 52586: (3, 0, 111),
    },
    "darnassus": {
        50497: (1, 0, 7), 50498: (1, 1, 9), 50499: (1, 1, 16),
        50500: (1, 0, 1), 50501: (1, 1, 11), 50502: (1, 0, 31),
        50504: (4, 1, 11), 50505: (4, 0, 33), 50506: (4, 0, 33),
        50507: (4, 1, 33), 50690: (4, 0, 16), 50714: (4, 1, 16),
        50715: (4, 0, 16), 52292: (11, 0, 14), 52636: (22, 1, 89),
        52640: (22, 0, 59), 52642: (22, 0, 78), 52645: (4, 1, 111),
    },
    "thunder_bluff": {
        43001: (6, 0, 3), 43004: (6, 1, 11), 43795: (6, 1, 3),
        43796: (6, 0, 11), 43870: (6, 0, 11), 43881: (5, 0, 31),
        43883: (5, 0, 31), 43892: (5, 1, 31), 51638: (6, 0, 14),
        51639: (6, 0, 14), 51640: (6, 1, 14), 52651: (6, 0, 89),
        52657: (6, 1, 111),
    },
    "undercity": {
        39116: (5, 0, 7), 50609: (5, 0, 7), 52317: (6, 1, 14),
        52319: (6, 1, 33), 52587: (5, 0, 111),
    },
}


class CapitalContentTests(unittest.TestCase):
    def test_rosters_and_reserved_entries(self):
        all_entries = set()
        for i, city in enumerate(ORDER):
            npcs = MANIFESTS[city]["npcs"]
            with self.subTest(city=city):
                self.assertEqual({n["source_entry"] for n in npcs}, set(EXPECTED[city]))
                start = 4000200 + i * 100
                self.assertEqual({n["entry"] for n in npcs}, set(range(start, start + len(EXPECTED[city]))))
                self.assertFalse(all_entries & {n["entry"] for n in npcs})
                all_entries.update(n["entry"] for n in npcs)
                for n in npcs:
                    self.assertEqual((n["race"], n["gender"], n["trainer_id"]), EXPECTED[city][n["source_entry"]])
                    self.assertIn(n["unit_class"], (1, 2, 4, 8))
                    self.assertTrue(n["npcflag"] & 16)
                    if n["outfit"]:
                        self.assertEqual((n["outfit"]["race"], n["outfit"]["gender"]), (n["render_race"], n["gender"]))
                self.assertEqual(len(MANIFESTS[city]["excluded"]), 1)
                self.assertIn("Archaeology", MANIFESTS[city]["excluded"][0]["reason"])

    def test_native_dark_iron_skins_and_explicit_human_approximations(self):
        natives = {n["source_entry"]: n for n in MANIFESTS["ironforge"]["npcs"] if n["outfit"] is None}
        self.assertEqual(set(natives), {50716, 50717, 50723, 50729})
        for n in natives.values():
            self.assertEqual(n["native_skin"], n["source_customization"]["Skin Color"])
        humans = [n for m in MANIFESTS.values() for n in m["npcs"] if n["race"] == 22]
        self.assertEqual({n["source_entry"] for n in humans}, {52335, 52636, 52640, 52642})
        for n in humans:
            self.assertEqual(n["render_race"], 1)
            self.assertTrue(any("not a verified source form" in note for note in n["notes"]))

    def test_grounded_positions_and_howling_oak_group(self):
        for city, manifest in MANIFESTS.items():
            xmin, xmax, ymin, ymax = manifest["bounds"]
            for n in manifest["npcs"]:
                with self.subTest(city=city, npc=n["name"]):
                    self.assertTrue(n["navigation_checked"])
                    self.assertTrue(all(math.isfinite(v) for v in n["position"]))
                    self.assertEqual(n["position"][3], n["source_position"][3])
                    self.assertAlmostEqual(n["horizontal_adjustment"], math.dist(n["source_position"][:2], n["position"][:2]), places=3)
                    self.assertTrue(xmin <= n["position"][0] <= xmax and ymin <= n["position"][1] <= ymax)
                    self.assertLess(n["horizontal_adjustment"], 3 if city == "darnassus" else .001)
            # Ensure nearby source NPCs remain distinct on the same floor.
            for i, a in enumerate(manifest["npcs"]):
                for b in manifest["npcs"][i + 1:]:
                    self.assertGreater(math.dist(a["position"][:3], b["position"][:3]), 1)
        group = [n for n in MANIFESTS["darnassus"]["npcs"] if 50497 <= n["source_entry"] <= 50507]
        self.assertLess(max(n["position"][2] for n in group) - min(n["position"][2] for n in group), 3)

    def test_documented_weapon_and_clothing_substitutions(self):
        npcs = {n["source_entry"]: n for m in MANIFESTS.values() for n in m["npcs"]}
        self.assertEqual(npcs[50497]["source_equipment"][2], 52052)
        self.assertEqual(npcs[50497]["equipment"][2], 25270)
        self.assertEqual(npcs[43795]["source_equipment"][0], 58164)
        self.assertEqual(npcs[43795]["equipment"][0], 35724)
        self.assertEqual(npcs[50500]["outfit"]["tabard"], 0)
        # Existing Wrath Nathanos and Aponi identities elsewhere are left alone.
        self.assertEqual(npcs[50609]["fallback_display"], 11814)
        self.assertEqual(npcs[43795]["fallback_display"], 29249)
        self.assertTrue(all(not n["vendors"] for n in npcs.values()))

    def test_sql_is_current_and_updates_follow_requested_order(self):
        subprocess.run([sys.executable, str(ROOT / "tools/generate_city_trainers.py"), "--check"], check=True)
        for i, city in enumerate(ORDER, start=3):
            base = ROOT / f"data/sql/db-world/base/{city}_trainers.sql"
            update = ROOT / f"data/sql/db-world/updates/2026_10_05_{i:02}_{city}_trainers.sql"
            self.assertEqual(base.read_text(), update.read_text())


if __name__ == "__main__":
    unittest.main()
