"""Read AzerothCore base-world dumps without importing or modifying a database."""
import csv
from functools import lru_cache
import re
from pathlib import Path


def table_rows(core_root, table):
    path = Path(core_root) / 'data/sql/base/db_world' / (table + '.sql')
    columns = []
    with path.open() as source:
        for line in source:
            match = re.match(r'  `([^`]+)` ', line)
            if match:
                columns.append(match.group(1))
            if not line.startswith('('):
                continue
            body = line.rstrip('\n,;')[1:-1]
            values = next(csv.reader([body], delimiter=',', quotechar="'", escapechar='\\'))
            assert len(values) == len(columns), (table, len(values), len(columns))
            yield dict(zip(columns, values))


@lru_cache(maxsize=64)
def _height_grid(path):
    import struct
    data=path.read_bytes()
    offset=struct.unpack_from('<11I',data)[5]
    _,flags,low,high=struct.unpack_from('<IIff',data,offset)
    if flags & 1:return flags,low,high,(),()
    fmt='H' if flags & 2 else 'B' if flags & 4 else 'f'
    v9=struct.unpack_from('<'+fmt*16641,data,offset+16)
    v8=struct.unpack_from('<'+fmt*16384,data,offset+16+struct.calcsize(fmt)*16641)
    return flags,low,high,v9,v8


def map_height(client_data,x,y,map_id=1):
    """Native terrain height, separately from model/nav-mesh surfaces such as stump tops."""
    gx,gy=int(32-x/(1600/3)),int(32-y/(1600/3))
    flags,low,high,v9,v8=_height_grid(Path(client_data)/f'maps/{map_id:03}{gx:02}{gy:02}.map')
    if flags & 1:return low
    xx, yy = 128*(32-x/(1600/3)), 128*(32-y/(1600/3))
    ix, iy = int(xx), int(yy)
    xx, yy = xx-ix, yy-iy
    ix, iy = ix & 127, iy & 127
    pos = ix*129+iy
    a, b, c, e, mid = v9[pos], v9[pos+129], v9[pos+1], v9[pos+130], v8[ix*128+iy]*2
    if xx+yy < 1:
        aa, bb, cc = (b-a,mid-a-b,a) if xx > yy else (mid-a-c,c-a,a)
    else:
        aa, bb, cc = (b+e-mid,e-b,mid-e) if xx > yy else (e-c,c+e-mid,mid-e)
    z = aa*xx+bb*yy+cc
    return z*(high-low)/(65535 if flags & 2 else 255)+low if flags & (2|4) else z
