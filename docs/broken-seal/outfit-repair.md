# Courier clothing and campaign outfit repair

The Alliance courier's missing trousers came from its outfit definition: a chest
piece and shirt were specified, while `legs` defaulted to zero. Zero hides the slot.
The Horde courier, scout, cult scouts and two non-robed captives had the same omission.
Their presets now include trousers; both couriers also have matching boots.
All campaign humanoid presets explicitly include leg clothing, including those
whose robes already cover it.

A separate generator default wrote rendering class `0` for the Chapter 2, Chapter 3
and hub outfits. The appearance loader rejects that class, causing the native
fallback model to appear instead. All 44 affected presets now use valid rendering
class `1`; generators default that field to `1`, and reject invalid explicit classes
or incomplete campaign clothing. This changes cosmetic rendering only.

## Apply to the current realm

For the Alliance courier's immediate fix, use the existing admin commands:

```text
.customnpc outfit set 4001006 legs 1431
.customnpc outfit set 4001006 feet 1427
```

These commands save and reload outfits; no worldserver rebuild is needed for the
clothing change. Outfit `4001006` uses Patchwork Pants, native display **16796**,
and Patchwork Shoes, display **16798**.

For all corrections, apply
[the appearance-only repair](../../data/sql/db-world/updates/2026_10_07_00_broken_seal_outfit_corrections.sql)
through the updater or manually to the world database, then run:

```text
.customnpc outfit reload
```

The repair only touches module-owned campaign/hub outfits. It fixes invalid class
`0` and fills empty preset clothing when the preset race, gender and chest still
match. Valid custom classes, nonzero clothing, custom replacement costumes and
per-spawn overrides are retained. It does not change NPC positions, quest progress
or creature combat stats. Fresh chapter/hub SQL now includes the corrected data.

Select the courier and run `.customnpc outfit info`. Its effective assigned outfit
should be `4001006`. After rebuilding the module's diagnostic enhancement, the
command also prints every configured armor value and resolved display; the legs
line should read `configured 1431, resolved display 16796`.

A spawn override takes priority over the entry assignment. If `info` shows another
outfit or `0`, inspect the selected spawn's override before changing it. A zero
override deliberately preserves the original native model. Also check both
`ModCustomNPCs.Enable` and `ModCustomNPCs.Appearance.Enable`, and look for
`Ignoring outfit` messages in the worldserver log.

## What was verified

The loader's legs column maps to the correct mirror-image armor slot, and the
68-byte packet matches the core's slot order. Reload recreates client-visible
objects so changed clothing is requested again. Tests exercise the courier's actual
item-to-display conversion and leg bytes, slot ordering, positive/negative/empty
armor values, assignment precedence and stock-client race/class validation.

All **56 campaign/hub outfits** passed native item existence, inventory-slot and
display checks. The SQL fixture verified repair/reapplication and preservation of
custom classes, clothing, replacement costumes, overrides and unowned records.
The appearance manager and command source passed syntax checks against the core.
A live client check of the corrected outfits remains necessary; no realm database
was changed during this repair.

```bash
python3 tools/verify_broken_seal_outfits.py --client-data /path/to/native/data
python3 tools/generate_broken_seal_outfit_fix.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
clang++ -std=c++20 -Wall -Wextra -Werror -Isrc tests/outfit_tests.cpp -o /tmp/outfit-tests
/tmp/outfit-tests
python3 tools/verify_broken_seal_outfit_sql.py --core-root /path/to/core --socket /path/to/test.sock
```
