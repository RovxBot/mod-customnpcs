#!/usr/bin/env python3
"""Verify guard directions in a disposable database using native AzerothCore data.

Requires permission to create/drop temporary test databases on the given socket.
Does not connect to or update the realm's world database.
"""

import argparse
import difflib
import math
from pathlib import Path
import re
import subprocess
import uuid

from generate_city_guard_trainers import BASE, CITIES, CLASS_SERVICES, OTHER_SERVICES, load_rosters

ROOT = Path(__file__).resolve().parents[1]
TABLES = ("gossip_menu", "gossip_menu_option", "points_of_interest", "npc_text")
GUARDS = {"orgrimmar": 3296, "stormwind": 68, "ironforge": 5595,
          "darnassus": 4262, "thunder_bluff": 3084, "undercity": 5624}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--core-root", type=Path, required=True)
    parser.add_argument("--client", default="mariadb")
    parser.add_argument("--socket", required=True)
    parser.add_argument("--loader", help="Optional Linux loader for a portable client")
    parser.add_argument("--library-path", help="Portable client libraries, used with --loader")
    args = parser.parse_args()
    if args.loader and not args.library_path:
        parser.error("--loader requires --library-path")
    command = [args.client, "--no-defaults", "--socket=" + args.socket, "--user=root",
               "--batch", "--skip-column-names"]
    if args.loader:
        command = [args.loader, "--library-path", args.library_path, *command]

    def run(sql, database=None, success=True):
        result = subprocess.run(command + ([database] if database else []), input=sql,
                                text=True, capture_output=True)
        if success and result.returncode:
            raise AssertionError(result.stderr)
        return result

    database = "customnpcs_guards_test_" + uuid.uuid4().hex[:12]
    created = False
    try:
        run(f"CREATE DATABASE `{database}` CHARACTER SET utf8mb4;")
        created = True
        native = args.core_root / "data/sql/base/db_world"
        for table in TABLES:
            run((native / f"{table}.sql").read_text(), database)
        # Import native guard templates, including their real gossip root IDs.
        source = (native / "creature_template.sql").read_text()
        schema = re.search(r"CREATE TABLE `creature_template` \(.*?\) ENGINE=[^;]+;", source, re.S)
        assert schema, "Missing creature_template schema"
        guard_rows = [line.rstrip(",;") for line in source.splitlines()
                      if re.match(r"\((" + "|".join(map(str, GUARDS.values())) + r"),", line)]
        assert len(guard_rows) == len(GUARDS)
        run(schema.group() + "\nINSERT INTO creature_template VALUES\n" + ",\n".join(guard_rows) + ";", database)

        def snapshot(native_only=False):
            queries = []
            for table in TABLES:
                key = "MenuID" if table.startswith("gossip_menu") else "ID"
                where = f" WHERE `{key}` < 4100000" if native_only else ""
                if native_only and table == "gossip_menu_option":
                    menus = ",".join(str(menu) for city in CITIES for menu in city[2:])
                    where += f" AND NOT (MenuID IN ({menus}) AND OptionID BETWEEN 100 AND 199)"
                queries.append(f"SELECT * FROM `{table}`{where} ORDER BY 1,2;")
            queries.append("SELECT * FROM creature_template ORDER BY entry;")
            return run("\n".join(queries), database).stdout

        before = snapshot()
        sql = BASE.read_text()
        run(sql, database)
        after = snapshot(native_only=True)
        assert before == after, "Native gossip, POIs, text or guards changed:\n" + "\n".join(
            list(difflib.unified_diff(before.splitlines(), after.splitlines()))[:30])
        first = snapshot()
        run(sql, database)
        assert first == snapshot(), "Reapplication changed or duplicated direction data"

        rosters = load_rosters()
        count = 0
        for slug, city, *_ in CITIES:
            root = int(run(f"SELECT gossip_menu_id FROM creature_template WHERE entry={GUARDS[slug]};", database).stdout)
            for npc in rosters[slug]["npcs"]:
                trainer = npc["trainer_id"]
                if trainer in CLASS_SERVICES:
                    broadcast_ids = "45378,6792"
                elif trainer in OTHER_SERVICES:
                    broadcast_ids = None
                else:
                    broadcast_ids = "45382,6793"
                menu = root if broadcast_ids is None else int(run(
                    f"SELECT ActionMenuID FROM gossip_menu_option WHERE MenuID={root} "
                    f"AND OptionBroadcastTextID IN ({broadcast_ids});", database).stdout)
                # Follow the added option through the response menu, text, POI,
                # and both back links. Expectations use the actual native guard.
                row = run(f"""SELECT o.OptionText,o.OptionType,o.OptionNpcFlag,o.OptionBroadcastTextID,
                    p.PositionX,p.PositionY,p.Name,t.text0_0,t.Probability0,
                    b.ActionMenuID,s.ActionMenuID
                    FROM gossip_menu_option o
                    JOIN gossip_menu g ON g.MenuID=o.ActionMenuID
                    JOIN npc_text t ON t.ID=g.TextID
                    JOIN points_of_interest p ON p.ID=o.ActionPoiID
                    JOIN gossip_menu_option b ON b.MenuID=g.MenuID AND b.OptionID=0
                    JOIN gossip_menu_option s ON s.MenuID=g.MenuID AND s.OptionID=1
                    WHERE o.MenuID={menu} AND o.OptionID={100 + npc['entry'] % 100};""", database).stdout.strip().split("\t")
                assert len(row) == 11, (city, npc["name"], row)
                assert npc["name"] in row[0] and row[0] == row[6]
                assert row[1:4] == ["1", "1", "0"], "Guard direction must use native gossip, with literal text"
                assert math.isclose(float(row[4]), npc["position"][0], abs_tol=.05)
                assert math.isclose(float(row[5]), npc["position"][1], abs_tol=.05)
                assert npc["name"] in row[7] and row[8] == "1"
                assert row[9:] == [str(menu), str(root)], "Broken back navigation"
                if slug == "thunder_bluff" and trainer == 31:
                    assert "below Spirit Rise" in row[7]
                count += 1
        assert count == 78
        largest = int(run("SELECT MAX(n) FROM (SELECT COUNT(*) n FROM gossip_menu_option GROUP BY MenuID) sizes;", database).stdout)
        assert largest <= 32
        print("Passed all 78 native guard-to-trainer paths, POIs, back links and idempotent import.")

        # Restore the original fixture, then occupy a reserved native menu slot.
        for table in TABLES:
            run((native / f"{table}.sql").read_text(), database)
        run("INSERT INTO gossip_menu_option (MenuID,OptionID,OptionText,OptionType,OptionNpcFlag,ActionMenuID) "
            "VALUES (401,100,'Another module owns this slot',1,1,12345);", database)
        before = snapshot()
        rejected = run(sql, database, success=False)
        assert rejected.returncode and "Duplicate entry" in rejected.stderr, rejected.stderr
        assert before == snapshot(), "Collision rejection modified existing data"
        print("Passed occupied native-option rejection before persistent data changes.")

        run("DELETE FROM gossip_menu_option WHERE MenuID=401 AND OptionID=100;"
            "DELETE FROM gossip_menu WHERE MenuID=1949;", database)
        before = snapshot()
        rejected = run(sql, database, success=False)
        assert rejected.returncode and "Duplicate entry" in rejected.stderr
        assert before == snapshot(), "Missing native-menu rejection modified existing data"
        print("Passed missing native-menu rejection before persistent data changes.")
    finally:
        if created:
            assert re.fullmatch(r"customnpcs_guards_test_[a-f0-9]{12}", database)
            run(f"DROP DATABASE IF EXISTS `{database}`;")


if __name__ == "__main__":
    main()
