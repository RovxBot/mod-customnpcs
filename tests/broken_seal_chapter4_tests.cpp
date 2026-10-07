#include "BrokenSealChapter4.h"
#include <cassert>
#include <iostream>

using namespace BrokenSeal::Chapter4;
int main()
{
    for (unsigned completed = 0; completed <= 8; ++completed)
        for (unsigned index = 0; index <= 8; ++index)
        {
            assert(CanTreatNext(completed, index, false) == (completed < 8 && completed == index));
            assert(!CanTreatNext(completed, index, true));
            assert(CanRestartService(completed, index) == (completed < 3 && completed == index));
        }
    for (unsigned essences = 0; essences <= 9; ++essences)
        for (unsigned bits = 0; bits < 8; ++bits)
        {
            bool treated = bits & 1U;
            bool released = bits & 2U;
            bool defeated = bits & 4U;
            assert(CanReleaseBoss(essences, false) == (essences == 8));
            assert(!CanReleaseBoss(essences, true));
            assert(CanFinishBoss(essences, treated, released, defeated) ==
                   (essences == 8 && treated && released && defeated));
        }
    // Resume from every saved quest count, with no repeat or skipped resident.
    for (unsigned saved = 0; saved < 8; ++saved)
    {
        unsigned count = saved;
        while (count < 8)
        {
            assert(CanTreatNext(count, count, false));
            assert(!CanTreatNext(count, saved, true));
            ++count;
            assert(!CanTreatNext(count, count - 1, false));
        }
    }
    static_assert(VillagerEntries.size() == 8 && PersonalEntries.size() == 7);
    std::cout << "Chapter 4: distinct residents, saved progress, services and ordered boss gates passed.\n";
}
