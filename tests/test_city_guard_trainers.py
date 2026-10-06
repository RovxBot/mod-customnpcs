"""Guard-direction regeneration and roster changes that must fail safely."""

import copy
from pathlib import Path
import re
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from generate_city_guard_trainers import directions, load_rosters


class CityGuardTrainerTests(unittest.TestCase):
    def test_checked_in_sql_matches_all_rosters(self):
        subprocess.run([sys.executable, str(ROOT / "tools/generate_city_guard_trainers.py"),
                        "--check"], check=True)

    def test_reordered_rosters_keep_existing_menu_slots_and_markers(self):
        rosters = load_rosters()
        before = {d["entry"]: d for d in directions(rosters)}
        for roster in rosters.values():
            roster["npcs"].reverse()
        self.assertEqual(before, {d["entry"]: d for d in directions(rosters)})
        self.assertEqual(len(before), 78)

    def test_unsupported_service_and_bad_placements_stop_generation(self):
        original = load_rosters()
        for changes in ({"trainer_id": 9999}, {"position": [1, 2, float("nan"), 0]},
                        {"entry": 4000600}):
            with self.subTest(changes=changes):
                rosters = copy.deepcopy(original)
                rosters["stormwind"]["npcs"][0].update(changes)
                with self.assertRaises(ValueError):
                    directions(rosters)

    def test_duplicate_trainers_stop_generation(self):
        rosters = load_rosters()
        rosters["stormwind"]["npcs"].append(rosters["stormwind"]["npcs"][0])
        with self.assertRaises(ValueError):
            directions(rosters)

    def test_orgrimmar_services_match_the_installed_curricula(self):
        sql = (ROOT / "data/sql/db-world/base/later_expansion_trainers.sql").read_text()
        for npc in load_rosters()["orgrimmar"]["npcs"]:
            row = re.search(r"\(" + str(npc["entry"]) +
                            r",\s*\d+,\s*(\d+),\s*'(?:[^']|'')*',\s*'((?:[^']|'')*)'", sql)
            self.assertIsNotNone(row, npc["name"])
            self.assertEqual(int(row[1]), npc["trainer_id"])
            self.assertEqual(row[2].replace("''", "'"), npc["subname"])


if __name__ == "__main__":
    unittest.main()
