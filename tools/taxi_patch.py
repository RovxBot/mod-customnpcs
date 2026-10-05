"""Small WDBC/MPQ utilities for the Wrath flight-map patch (Python standard library)."""

import struct


class Dbc:
    def __init__(self, data, fields):
        if len(data) < 20:
            raise ValueError("Truncated DBC header")
        magic, count, actual_fields, size, strings_size = struct.unpack_from("<4s4I", data)
        if magic != b"WDBC" or actual_fields != fields or size != fields * 4:
            raise ValueError("Expected a native Wrath WDBC table")
        end = 20 + count * size
        if len(data) != end + strings_size:
            raise ValueError("DBC size does not match its header")
        self.data = data
        self.fields = fields
        self.records = [list(row) for row in struct.iter_unpack("<" + "I" * fields, data[20:end])]
        self.rows = {row[0]: row for row in self.records}
        if len(self.rows) != count:
            raise ValueError("Duplicate DBC IDs")
        self.strings = data[end:]

    def string(self, offset):
        if not 0 <= offset < len(self.strings):
            raise ValueError("Invalid DBC string offset")
        end = self.strings.find(b"\0", offset)
        if end < 0:
            raise ValueError("Unterminated DBC string")
        return self.strings[offset:end].decode("utf-8")

    def append(self, records, strings=b""):
        ids = set(self.rows)
        for row in records:
            if len(row) != self.fields or row[0] in ids:
                raise ValueError("New DBC row has the wrong size or an existing ID")
            ids.add(row[0])
        header = struct.pack("<4s4I", b"WDBC", len(self.records) + len(records),
                             self.fields, self.fields * 4, len(self.strings) + len(strings))
        rows = b"".join(struct.pack("<" + "I" * self.fields, *row) for row in self.records + records)
        return header + rows + self.strings + strings


def float_bits(value):
    return struct.unpack("<I", struct.pack("<f", value))[0]


def bits_float(value):
    return struct.unpack("<f", struct.pack("<I", value))[0]


# Blizzard's MPQ hash/encryption algorithm, as documented in StormLib's
# SBaseCommon.cpp (MIT): https://github.com/ladislav-zezula/StormLib
def crypt_table():
    table = [0] * 0x500
    seed = 0x100001
    for low in range(0x100):
        for high in range(5):
            seed = (seed * 125 + 3) % 0x2AAAAB
            first = (seed & 0xFFFF) << 16
            seed = (seed * 125 + 3) % 0x2AAAAB
            table[low + high * 0x100] = first | (seed & 0xFFFF)
    return table


CRYPT = crypt_table()
MASK = 0xFFFFFFFF


def mpq_hash(name, kind):
    first, second = 0x7FED7FED, 0xEEEEEEEE
    for char in name.replace("/", "\\").upper().encode("ascii"):
        first = (CRYPT[kind * 0x100 + char] ^ (first + second)) & MASK
        second = (char + first + second + (second << 5) + 3) & MASK
    return first


def encrypt_table(data, key):
    output = []
    second = 0xEEEEEEEE
    for (word,) in struct.iter_unpack("<I", data):
        second = (second + CRYPT[0x400 + (key & 0xFF)]) & MASK
        output.append((word ^ (key + second)) & MASK)
        key = (((~key << 21) + 0x11111111) | (key >> 11)) & MASK
        second = (word + second + (second << 5) + 3) & MASK
    return struct.pack("<" + "I" * len(output), *output)


def build_mpq(files):
    """Write a deterministic v1 archive, with neutral-locale, uncompressed files."""
    entries = dict(files)
    if "(listfile)" in entries:
        raise ValueError("The archive listfile is generated automatically")
    entries["(listfile)"] = ("\r\n".join(entries) + "\r\n").encode("ascii")
    hash_size = 8
    while hash_size < len(entries) * 2:
        hash_size *= 2
    hashes = [b"\xff" * 16 for _ in range(hash_size)]
    blocks, payload = [], bytearray()
    normalized = set()
    for index, (name, data) in enumerate(entries.items()):
        canonical = name.replace("/", "\\").upper()
        if canonical in normalized:
            raise ValueError("Duplicate archive filename")
        normalized.add(canonical)
        slot = mpq_hash(name, 0) % hash_size
        while hashes[slot] != b"\xff" * 16:
            slot = (slot + 1) % hash_size
        hashes[slot] = struct.pack("<IIHHI", mpq_hash(name, 1), mpq_hash(name, 2), 0, 0, index)
        blocks.append(struct.pack("<4I", 32 + len(payload), len(data), len(data), 0x81000000))
        payload.extend(data)
    hash_offset = 32 + len(payload)
    block_offset = hash_offset + hash_size * 16
    header = struct.pack("<4sIIHH4I", b"MPQ\x1a", 32, block_offset + len(blocks) * 16,
                         0, 3, hash_offset, block_offset, hash_size, len(blocks))
    return (header + payload + encrypt_table(b"".join(hashes), mpq_hash("(hash table)", 3))
            + encrypt_table(b"".join(blocks), mpq_hash("(block table)", 3)))
