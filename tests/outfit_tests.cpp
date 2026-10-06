/* SPDX-License-Identifier: AGPL-3.0-or-later */
#include "CustomNpcOutfit.h"

#include <cassert>
#include <iostream>
#include <limits>
#include <type_traits>
#include <vector>

namespace
{
struct Packet
{
    std::vector<std::uint8_t> bytes;

    template <typename T>
    Packet& operator<<(T value)
    {
        static_assert(std::is_unsigned<T>::value, "Protocol fields must be unsigned.");
        for (std::size_t i = 0; i < sizeof(T); ++i)
            bytes.push_back(static_cast<std::uint8_t>(value >> (8 * i)));
        return *this;
    }
};

void TestPacket()
{
    CustomNpcs::Outfit outfit;
    outfit.display = 0x44332211;
    outfit.race = 6;
    outfit.gender = 1;
    outfit.playerClass = 7;
    outfit.skin = 2;
    outfit.face = 3;
    outfit.hair = 4;
    outfit.hairColor = 5;
    outfit.facialHair = 6;
    outfit.guild = 0xddccbbaa;
    for (std::size_t i = 0; i < outfit.armorDisplays.size(); ++i)
        outfit.armorDisplays[i] = 0x01020300 + i;

    Packet packet;
    CustomNpcs::WriteMirrorImageData(packet, std::uint64_t(0x8877665544332211), outfit);
    std::vector<std::uint8_t> expected =
    {
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, // Raw GUID, not packed GUID.
        0x11, 0x22, 0x33, 0x44, 6, 1, 7, 2, 3, 4, 5, 6,
        0xaa, 0xbb, 0xcc, 0xdd,
        0, 3, 2, 1, 1, 3, 2, 1, 2, 3, 2, 1, 3, 3, 2, 1,
        4, 3, 2, 1, 5, 3, 2, 1, 6, 3, 2, 1, 7, 3, 2, 1,
        8, 3, 2, 1, 9, 3, 2, 1, 10, 3, 2, 1
    };
    assert(packet.bytes.size() == 68);
    assert(packet.bytes == expected);
    // Weapons never append fields to the armor-only mirror-image packet.
    outfit.weapons = { 19019, 19019, 34334 };
    Packet armed;
    CustomNpcs::WriteMirrorImageData(armed, std::uint64_t(0x8877665544332211), outfit);
    assert(armed.bytes == expected);
}

void TestEquipment()
{
    auto itemLookup = [](std::uint32_t entry) { return entry == 19019 ? std::uint32_t(30606) : 0u; };
    auto displayLookup = [](std::uint32_t display) { return display == 30606; };
    std::uint32_t display = 999;
    assert(CustomNpcs::ResolveArmor(0, display, itemLookup, displayLookup) && display == 0);
    assert(CustomNpcs::ResolveArmor(19019, display, itemLookup, displayLookup) && display == 30606);
    assert(CustomNpcs::ResolveArmor(-30606, display, itemLookup, displayLookup) && display == 30606);
    assert(!CustomNpcs::ResolveArmor(99999, display, itemLookup, displayLookup));
    assert(!CustomNpcs::ResolveArmor(-99999, display, itemLookup, displayLookup));
    assert(!CustomNpcs::ResolveArmor(std::numeric_limits<std::int32_t>::min(), display,
        itemLookup, displayLookup));
    assert(display == 2147483648u); // No signed overflow even for corrupt SQL input.
}

void TestCourierLegDisplay()
{
    CustomNpcs::Outfit outfit;
    outfit.armor[CustomNpcs::Legs] = 1431;
    std::uint32_t& display = outfit.armorDisplays[CustomNpcs::Legs];
    assert(CustomNpcs::ResolveArmor(outfit.armor[CustomNpcs::Legs], display,
        [](std::uint32_t entry) { return entry == 1431 ? 16796u : 0u; },
        [](std::uint32_t id) { return id == 16796; }));
    Packet packet;
    CustomNpcs::WriteMirrorImageData(packet, std::uint64_t(1), outfit);
    constexpr std::size_t legOffset = 24 + CustomNpcs::Legs * sizeof(std::uint32_t);
    std::uint32_t wireDisplay = 0;
    for (std::size_t i = 0; i < 4; ++i)
        wireDisplay |= std::uint32_t(packet.bytes[legOffset + i]) << (i * 8);
    assert(wireDisplay == 16796);
}

void TestAssignments()
{
    CustomNpcs::OutfitCatalog catalog;
    catalog.enabled = true;
    auto first = std::make_shared<CustomNpcs::Outfit>();
    first->id = 1;
    auto second = std::make_shared<CustomNpcs::Outfit>();
    second->id = 2;
    catalog.outfits.emplace(1, first);
    catalog.outfits.emplace(2, second);
    catalog.entries.emplace(4000000, 1);
    catalog.spawns.emplace(100, 2);
    catalog.spawns.emplace(101, 0);
    assert(catalog.Find(4000000, 0) == first); // Summons use the entry.
    assert(catalog.Find(4000000, 99) == first);
    assert(catalog.Find(4000000, 100) == second);
    assert(!catalog.Find(4000000, 101)); // Explicit original-look override beats the entry.
    assert(!catalog.Find(4000001, 99));
    catalog.spawns.erase(100);
    assert(catalog.Find(4000000, 100) == first); // Removing an override resumes the entry assignment.
    catalog.entries.erase(4000000);
    assert(!catalog.Find(4000000, 99));
    catalog.entries.emplace(4000000, 999);
    assert(!catalog.Find(4000000, 99)); // Missing outfits do not produce a dangling reference.
    catalog.enabled = false;
    assert(!catalog.Find(4000000, 101));
}

void TestStockClientIds()
{
    for (std::uint32_t race : { 1u, 2u, 3u, 4u, 5u, 6u, 7u, 8u, 10u, 11u })
        assert(CustomNpcs::IsPlayableRace(race));
    for (std::uint32_t race : { 0u, 9u, 12u, 22u, 24u, 25u, 26u, 255u, 256u })
        assert(!CustomNpcs::IsPlayableRace(race));
    assert(CustomNpcs::IsPlayerClass(6));
    assert(!CustomNpcs::IsPlayerClass(10)); // Monk has no player rendering support in WotLK.
    assert(!CustomNpcs::IsPlayerClass(0));
}
}

int main()
{
    TestPacket();
    TestEquipment();
    TestCourierLegDisplay();
    TestAssignments();
    TestStockClientIds();
    std::cout << "Outfit protocol, equipment, assignment, and stock-client ID tests passed.\n";
}
