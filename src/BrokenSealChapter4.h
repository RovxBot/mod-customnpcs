#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER4_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER4_H

#include "BrokenSealChapter4Data.h"

namespace BrokenSeal::Chapter4
{
inline bool CanTreatNext(std::uint32_t completed, std::uint32_t villagerIndex, bool encounterActive)
{
    return completed < 8 && completed == villagerIndex && !encounterActive;
}
inline bool CanRestartService(std::uint32_t completed, std::uint32_t villagerIndex)
{
    return completed < 3 && completed == villagerIndex;
}
inline bool CanReleaseBoss(std::uint32_t essences, bool bossActive)
{
    return essences == 8 && !bossActive;
}
inline bool CanFinishBoss(std::uint32_t essences, bool treated, bool bossReleased, bool bossDefeated)
{
    return essences == 8 && treated && bossReleased && bossDefeated;
}
} // namespace BrokenSeal::Chapter4
#endif
