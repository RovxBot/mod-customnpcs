#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER1_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER1_H

#include "BrokenSealChapter1Data.h"

#include <algorithm>
#include <array>
#include <cstddef>
#include <cstdint>

namespace BrokenSeal::Chapter1
{
using Counts = std::array<std::uint16_t, DistinctCount>;

template <std::size_t N>
constexpr std::size_t IndexOf(std::array<std::uint32_t, N> const& values, std::uint32_t entry)
{
    for (std::size_t i = 0; i < N; ++i)
        if (values[i] == entry)
            return i;
    return N;
}

inline bool AllDistinctDone(Counts const& counts)
{
    return std::all_of(counts.begin(), counts.end(), [](std::uint16_t n) { return n >= 1; });
}

inline bool NeedsDistinct(Counts const& counts, std::size_t index)
{
    return index < counts.size() && counts[index] == 0;
}

struct SceneSafety
{
    bool enabled;
    bool questActive;
    bool ownerAlive;
    bool sameMapAndPhase;
    bool inCombat;
    float distance;
};

inline bool CanObserve(SceneSafety const& state)
{
    return state.enabled && state.questActive && state.ownerAlive && state.sameMapAndPhase &&
        !state.inCombat && state.distance <= 8.0f;
}

inline bool CanEscort(SceneSafety const& state)
{
    return state.enabled && state.questActive && state.ownerAlive && state.sameMapAndPhase &&
        state.distance <= 80.0f;
}

inline bool CanCreditArrival(SceneSafety const& state, bool reached, float distanceToRefuge)
{
    return CanEscort(state) && !state.inCombat && reached && distanceToRefuge <= 3.0f;
}
}

#endif
