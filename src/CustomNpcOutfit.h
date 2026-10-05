/*
 * Copyright (C) 2026 mod-customNPCs contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#ifndef MOD_CUSTOMNPCS_OUTFIT_H
#define MOD_CUSTOMNPCS_OUTFIT_H

#include <array>
#include <cstddef>
#include <cstdint>
#include <memory>
#include <unordered_map>

namespace CustomNpcs
{
// This order is part of the 3.3.5a SMSG_MIRRORIMAGE_DATA protocol.
enum ArmorSlot : std::size_t
{
    Head, Shoulders, Shirt, Chest, Waist, Legs, Feet, Wrists, Hands, Back, Tabard, ArmorSlotCount
};

inline constexpr std::array<char const*, ArmorSlotCount> ArmorColumns =
    { "head", "shoulders", "shirt", "chest", "waist", "legs", "feet", "wrists", "hands", "back", "tabard" };

struct Outfit
{
    std::uint32_t id = 0;
    std::uint8_t race = 1;
    std::uint8_t gender = 0;
    std::uint8_t playerClass = 1; // Rendering only; never changes creature_template.unit_class.
    std::uint8_t skin = 0;
    std::uint8_t face = 0;
    std::uint8_t hair = 0;
    std::uint8_t hairColor = 0;
    std::uint8_t facialHair = 0;
    std::uint32_t guild = 0;
    std::uint32_t display = 0;
    std::array<std::int32_t, ArmorSlotCount> armor{};
    std::array<std::uint32_t, ArmorSlotCount> armorDisplays{};
    std::array<std::uint32_t, 3> weapons{}; // Main hand, off hand, ranged: item entries only.
};

inline bool IsPlayableRace(std::uint32_t race)
{
    return (race >= 1 && race <= 8) || race == 10 || race == 11;
}

inline bool IsPlayerClass(std::uint32_t playerClass)
{
    return (playerClass >= 1 && playerClass <= 9) || playerClass == 11;
}

// Negative values select a display directly. Widen before negating INT32_MIN.
template <typename ItemLookup, typename DisplayLookup>
bool ResolveArmor(std::int32_t value, std::uint32_t& display, ItemLookup itemLookup, DisplayLookup displayLookup)
{
    display = 0;
    if (!value)
        return true;

    display = value > 0 ? itemLookup(static_cast<std::uint32_t>(value)) :
        static_cast<std::uint32_t>(-static_cast<std::int64_t>(value));
    return display && displayLookup(display);
}

template <typename Packet, typename Guid>
void WriteMirrorImageData(Packet& packet, Guid const& guid, Outfit const& outfit)
{
    packet << guid << outfit.display << outfit.race << outfit.gender << outfit.playerClass;
    packet << outfit.skin << outfit.face << outfit.hair << outfit.hairColor << outfit.facialHair << outfit.guild;
    for (std::uint32_t display : outfit.armorDisplays)
        packet << display;
}

struct OutfitCatalog
{
    bool enabled = false;
    std::unordered_map<std::uint32_t, std::shared_ptr<Outfit const>> outfits;
    std::unordered_map<std::uint32_t, std::uint32_t> entries;
    std::unordered_map<std::uint32_t, std::uint32_t> spawns;

    std::shared_ptr<Outfit const> Find(std::uint32_t entry, std::uint32_t spawn) const
    {
        if (!enabled)
            return nullptr;

        std::uint32_t id = 0;
        auto const spawnItr = spawns.find(spawn);
        if (spawn && spawnItr != spawns.end())
            id = spawnItr->second; // A zero override explicitly keeps the original appearance.
        else if (auto const entryItr = entries.find(entry); entryItr != entries.end())
            id = entryItr->second;

        auto const outfitItr = outfits.find(id);
        return outfitItr != outfits.end() ? outfitItr->second : nullptr;
    }
};
}

#endif
