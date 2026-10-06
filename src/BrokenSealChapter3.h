#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER3_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER3_H

#include "BrokenSealChapter3Data.h"
#include <array>
#include <cstddef>
#include <cstdint>

namespace BrokenSeal::Chapter3
{
struct SceneSafety
{
    bool enabled;
    bool questActive;
    bool alive;
    bool sameWorld;
    bool inCombat;
    bool mounted;
    bool flying;
    float distance;
};

inline bool CanObserve(SceneSafety const& s)
{
    return s.enabled && s.questActive && s.alive && s.sameWorld && !s.inCombat && !s.mounted && !s.flying &&
           s.distance <= 20.0f;
}

using Counts = std::array<std::uint16_t, 3>;
inline std::uint32_t RemainingBundles(Counts const& counts)
{
    std::uint32_t result = 0;
    for (std::uint16_t count : counts)
        if (!count)
            ++result;
    return result;
}
inline bool CanDeliver(Counts const& counts, std::size_t index, std::uint32_t bundles)
{
    return index < counts.size() && !counts[index] && bundles > 0;
}
inline std::uint32_t MissingBundles(Counts const& counts, std::uint32_t stored)
{
    std::uint32_t remaining = RemainingBundles(counts);
    return stored < remaining ? remaining - stored : 0;
}

// Progress through the private vignette is transient; native quest credit is awarded at its conclusion.
class BirthSequence
{
public:
    enum Stage : std::uint32_t
    {
        Beginning,
        Delivered,
        MotherLost,
        TwinsStable,
        Concluded
    };
    bool Advance(Stage next)
    {
        if (next != _stage + 1 || next > Concluded)
            return false;
        _stage = next;
        return true;
    }
    bool CanFinish(bool motherDead, bool redhornAlive, bool cloudhoofAlive) const
    {
        return _stage == TwinsStable && motherDead && redhornAlive && cloudhoofAlive;
    }
    Stage Current() const { return _stage; }

private:
    Stage _stage = Beginning;
};
} // namespace BrokenSeal::Chapter3
#endif
