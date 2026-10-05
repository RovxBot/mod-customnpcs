"""Flight-stop scope, graph integrity and native-data preservation checks."""

import copy
import hashlib
import json
import math
from pathlib import Path
import struct
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from build_flight_patch import build
from taxi_patch import Dbc, float_bits

MANIFEST = json.loads((ROOT / "data/npcs/flight_masters.json").read_text())
NETWORK = json.loads((ROOT / "data/taxi/later_flight_network.json").read_text())
EXPECTED = {33253, 34927, 34943, 35139, 39210, 39212, 40552, 40553, 40809, 41140, 41142,
            41325, 41332, 42406, 42426, 42983, 43000, 43088, 43124, 43697, 43701, 43702,
            43991, 44036, 44244, 46004, 46006, 47665, 47875}


class FlightContentTests(unittest.TestCase):
    def test_existing_settlements_and_complete_roster(self):
        npcs = MANIFEST["npcs"]
        self.assertEqual({n["source_entry"] for n in npcs}, EXPECTED)
        self.assertEqual({n["entry"] for n in npcs}, set(range(4000600, 4000629)))
        self.assertEqual(sum(n["continent"] == "Kalimdor" for n in npcs), 12)
        for n in npcs:
            with self.subTest(npc=n["name"]):
                self.assertIn(n["map"], (0, 1, 530))
                self.assertEqual(n["map"], n["wrath_settlement_proof"]["map"])
                self.assertGreater(n["wrath_settlement_proof"]["entry"], 0)
                self.assertLess(math.dist(n["source_position"][:2], n["wrath_settlement_proof"]["position"][:2]), 450)
                self.assertEqual((n["outfit"]["race"], n["outfit"]["gender"]), (n["race"], n["gender"]))
                self.assertLessEqual(n["maxlevel"], 80)
        forbidden = {"Bilgewater Harbor", "Fuselight", "Fort Triumph", "Lor'danel", "Bogpaddle",
                     "Bootlegger Outpost", "Ramkahen", "Krom'gar Fortress", "The Menders' Stead"}
        self.assertFalse(forbidden & {n["town"] for n in npcs})
        excluded = {n["source_entry"] for n in MANIFEST["excluded"]}
        self.assertTrue({36728, 39211, 40358, 43045, 47644, 48273, 48274, 48275} <= excluded)

    def test_open_ground_and_landing_placements(self):
        for n in MANIFEST["npcs"]:
            self.assertTrue(n["navigation_checked"])
            self.assertTrue(all(math.isfinite(value) for value in n["position"] + n["landing_position"]))
            self.assertEqual(n["position"][3], n["source_position"][3])
            self.assertLess(n["horizontal_adjustment"], 5.1)
            self.assertLessEqual(n["highest_navigation_surface"], n["position"][2] + .2)
            self.assertGreater(math.dist(n["position"][:3], n["landing_position"]), 1)
            self.assertLess(math.dist(n["position"][:3], n["landing_position"]), 3)
        eeryven = next(n for n in MANIFEST["npcs"] if n["source_entry"] == 41332)
        self.assertGreater(eeryven["horizontal_adjustment"], 4.9)
        self.assertTrue(any("roof" in note for note in eeryven["notes"]))

    def test_graph_has_return_routes_and_valid_owned_waypoints(self):
        npcs = {n["entry"]: n for n in MANIFEST["npcs"]}
        nodes = {n["taxi_node_id"] for n in npcs.values()}
        self.assertEqual(len(nodes), 29)
        self.assertTrue(all(1 <= node <= 448 for node in nodes))
        routes = NETWORK["routes"]
        self.assertEqual(len(routes), 110)
        edges = {(r["from"], r["to"]): r for r in routes}
        self.assertEqual(len(edges), len(routes))
        waypoint_ids = set()
        for r in routes:
            npc = npcs[r["entry"]]
            reverse = edges[(r["to"], r["from"])]
            self.assertEqual(r["points"], list(reversed(reverse["points"])))
            self.assertEqual(r["cost"], reverse["cost"])
            self.assertEqual(r["map"], npc["map"])
            self.assertIn(npc["taxi_node_id"], (r["from"], r["to"]))
            self.assertGreaterEqual(len(r["points"]), 4)
            self.assertGreaterEqual(r["native_join_index"], 2)
            self.assertGreaterEqual(r["cost"], 25)
            endpoint = r["points"][0] if r["from"] == npc["taxi_node_id"] else r["points"][-1]
            self.assertEqual(endpoint, npc["landing_position"])
            ids = set(range(r["first_waypoint_id"], r["first_waypoint_id"] + len(r["points"])))
            self.assertFalse(ids & waypoint_ids)
            waypoint_ids |= ids
        for npc in npcs.values():
            destinations = {r["to"] for r in routes if r["from"] == npc["taxi_node_id"]}
            self.assertEqual(destinations, set(npc["connections"]))

    def test_checked_in_sql_and_client_archive(self):
        subprocess.run([sys.executable, str(ROOT / "tools/generate_flight_masters.py"), "--check"], check=True)
        meta = json.loads((ROOT / "data/client/flight-masters/flight-patch.json").read_text())
        archive = (ROOT / "data/client/flight-masters/patch-F.MPQ").read_bytes()
        self.assertEqual(hashlib.sha256(archive).hexdigest(), meta["mpq_sha256"])
        self.assertEqual(meta["baseline_sha256"], NETWORK["baseline_sha256"])
        self.assertEqual(meta["route_count"], len(NETWORK["routes"]))
        self.assertEqual(meta["waypoint_count"], sum(len(r["points"]) for r in NETWORK["routes"]))
        self.assertEqual(archive[:4], b"MPQ\x1a")
        self.assertEqual(struct.unpack_from("<I", archive, 8)[0], len(archive))


def wdbc(fields, records, strings=b"\0"):
    return (struct.pack("<4s4I", b"WDBC", len(records), fields, fields * 4, len(strings))
            + b"".join(struct.pack("<" + "I" * fields, *r) for r in records) + strings)


class PatchPreservationTests(unittest.TestCase):
    def setUp(self):
        node = lambda id, x, offset: [id, 0, float_bits(x), 0, float_bits(10), *([offset] * 16), 65535, 0, 541]
        self.originals = {"TaxiNodes.dbc": wdbc(24, [node(1, 0, 1), node(2, 100, 6)], b"\0OldA\0OldB\0"),
                          "TaxiPath.dbc": wdbc(4, [[1, 1, 2, 100]]),
                          "TaxiPathNode.dbc": wdbc(11, [[1, 1, 0, 0, 0, 0, float_bits(10), 0, 0, 0, 0]])}
        self.npcs = [{"entry": 4000600, "taxi_node_id": 338, "map": 0, "town": "New Stop",
                      "landing_position": [50, 0, 10], "mount_creatures": [0, 541]}]
        route = {"id": 10000, "entry": 4000600, "from": 338, "to": 2, "map": 0,
                 "cost": 25, "first_waypoint_id": 500000,
                 "points": [[50, 0, 10], [50, 0, 70], [100, 0, 70], [100, 0, 10]]}
        self.network = {"baseline_sha256": {n: hashlib.sha256(d).hexdigest() for n, d in self.originals.items()},
                        "routes": [route]}

    def test_original_records_and_localized_strings_are_preserved(self):
        output, _, _ = build(self.npcs, self.network, self.originals)
        for name, fields in (("TaxiNodes.dbc", 24), ("TaxiPath.dbc", 4), ("TaxiPathNode.dbc", 11)):
            original, merged = Dbc(self.originals[name], fields), Dbc(output[name], fields)
            for id, row in original.rows.items():
                self.assertEqual(merged.rows[id], row)
            self.assertTrue(merged.strings.startswith(original.strings))
        nodes = Dbc(output["TaxiNodes.dbc"], 24)
        self.assertEqual(nodes.string(nodes.rows[1][5]), "OldA")
        self.assertEqual(nodes.string(nodes.rows[338][5]), "New Stop")

    def test_rejects_changed_baseline_and_unsafe_node_ids(self):
        changed = dict(self.originals)
        changed["TaxiPath.dbc"] = wdbc(4, [[1, 1, 2, 999]])
        with self.assertRaises(ValueError):
            build(self.npcs, self.network, changed)
        for node_id in (1, 449):
            npcs = copy.deepcopy(self.npcs)
            npcs[0]["taxi_node_id"] = node_id
            with self.assertRaises(ValueError):
                build(npcs, self.network, self.originals)

    def test_rejects_broken_routes_and_waypoint_collisions(self):
        for changes in ({"to": 99}, {"map": 1}, {"entry": 123}, {"first_waypoint_id": 1},
                        {"points": [[50, 0, float("nan")]] * 4}):
            network = copy.deepcopy(self.network)
            network["routes"][0].update(changes)
            with self.assertRaises(ValueError):
                build(self.npcs, network, self.originals)


if __name__ == "__main__":
    unittest.main()
