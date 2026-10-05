#!/usr/bin/env python3
"""Build a normal Wrath flight-map client patch from unmodified build-12340 DBCs."""

import argparse
import hashlib
import json
import math
from pathlib import Path

from taxi_patch import Dbc, build_mpq, float_bits

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "data/npcs/flight_masters.json"
NETWORK = ROOT / "data/taxi/later_flight_network.json"
FIELDS = {"TaxiNodes.dbc": 24, "TaxiPath.dbc": 4, "TaxiPathNode.dbc": 11}


def build(npcs, network, originals):
    tables = {name: Dbc(originals[name], fields) for name, fields in FIELDS.items()}
    baseline = network["baseline_sha256"]
    for name, table in tables.items():
        if hashlib.sha256(table.data).hexdigest() != baseline[name]:
            raise ValueError(f"{name} differs from the checked native baseline; merge other taxi changes explicitly")
    referenced = {r[i] for r in tables["TaxiPath.dbc"].records for i in (1, 2)}
    node_rows, strings = [], bytearray()
    for npc in npcs:
        node = npc["taxi_node_id"]
        if not 1 <= node <= 448 or node in tables["TaxiNodes.dbc"].rows or node in referenced:
            raise ValueError(f"Taxi node {node} would replace existing data or exceed the Wrath taxi mask")
        offset = len(tables["TaxiNodes.dbc"].strings) + len(strings)
        strings.extend((npc["town"] + "\0").encode("utf-8"))
        node_rows.append([node, npc["map"], *map(float_bits, npc["landing_position"]),
                          *([offset] * 16), 0xFFFF, *npc["mount_creatures"]])
    node_catalog = dict(tables["TaxiNodes.dbc"].rows)
    node_catalog.update({row[0]: row for row in node_rows})
    owned = {npc["entry"]: npc["taxi_node_id"] for npc in npcs}
    edges = set()
    path_rows, waypoint_rows = [], []
    for route in network["routes"]:
        edge = route["from"], route["to"]
        if edge in edges or route["from"] == route["to"]:
            raise ValueError("Duplicate or circular taxi connection")
        edges.add(edge)
        if route["entry"] not in owned or owned[route["entry"]] not in edge:
            raise ValueError("Route is not attached to its owning flight master")
        if any(node not in node_catalog for node in edge):
            raise ValueError("Taxi route refers to an unknown endpoint")
        source, destination = (node_catalog[node] for node in edge)
        if any(node[1] != route["map"] for node in (source, destination)):
            raise ValueError("These local connections must remain on one map")
        if not any(source[team] and destination[team] for team in (22, 23)):
            raise ValueError("Taxi endpoints have no compatible faction")
        if not 0 <= route["cost"] <= 0x7FFFFFFF or len(route["points"]) < 4:
            raise ValueError("Taxi route needs a valid fare and at least four waypoints")
        if any(len(point) != 3 or any(not math.isfinite(value) for value in point) for point in route["points"]):
            raise ValueError("Taxi waypoints must contain three finite coordinates")
        path_rows.append([route["id"], route["from"], route["to"], route["cost"]])
        for index, point in enumerate(route["points"]):
            waypoint_rows.append([route["first_waypoint_id"] + index, route["id"], index,
                                  route["map"], *map(float_bits, point), 0, 0, 0, 0])
    output = {"TaxiNodes.dbc": tables["TaxiNodes.dbc"].append(node_rows, bytes(strings)),
              "TaxiPath.dbc": tables["TaxiPath.dbc"].append(path_rows),
              "TaxiPathNode.dbc": tables["TaxiPathNode.dbc"].append(waypoint_rows)}
    # Verify every original record and string offset survives the append.
    for name, data in output.items():
        merged = Dbc(data, FIELDS[name])
        if merged.records[:len(tables[name].records)] != tables[name].records or not merged.strings.startswith(tables[name].strings):
            raise ValueError(f"Existing {name} data was changed")
    archive = build_mpq({"DBFilesClient\\" + name: data for name, data in output.items()})
    metadata = {"client_build": 12340, "npc_count": len(npcs), "route_count": len(path_rows),
                "waypoint_count": len(waypoint_rows), "baseline_sha256": baseline,
                "patched_sha256": {name: hashlib.sha256(data).hexdigest() for name, data in output.items()},
                "mpq_sha256": hashlib.sha256(archive).hexdigest()}
    return output, archive, metadata


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dbc-dir", required=True, type=Path, help="Unmodified native build-12340 taxi DBC directory")
    parser.add_argument("--output-dir", type=Path, default=ROOT / "data/client/flight-masters")
    parser.add_argument("--check", action="store_true", help="Verify the existing archive and metadata")
    args = parser.parse_args()
    npcs = json.loads(MANIFEST.read_text())["npcs"]
    network = json.loads(NETWORK.read_text())
    _, archive, metadata = build(npcs, network, {name: (args.dbc_dir / name).read_bytes() for name in FIELDS})
    outputs = {"patch-F.MPQ": archive, "flight-patch.json": (json.dumps(metadata, indent=2) + "\n").encode()}
    if not args.check:
        args.output_dir.mkdir(parents=True, exist_ok=True)
    for name, data in outputs.items():
        path = args.output_dir / name
        if args.check:
            if not path.exists() or path.read_bytes() != data:
                raise SystemExit(f"Regenerate {path}")
        else:
            path.write_bytes(data)
    print(f"{'Verified' if args.check else 'Generated'} patch: {len(npcs)} flight masters, {len(network['routes'])} routes.")


if __name__ == "__main__":
    main()
