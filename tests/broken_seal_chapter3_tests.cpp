#include "BrokenSealChapter3.h"
#include <cassert>
#include <iostream>

using namespace BrokenSeal::Chapter3;

int main()
{
    SceneSafety safe{true, true, true, true, false, false, false, 20.0f};
    assert(CanObserve(safe));
    auto fighting = safe;
    fighting.inCombat = true;
    assert(CanFightPool(fighting));
    fighting.distance = 45.01f;
    assert(!CanFightPool(fighting));
    fighting.distance = 20.0f;
    fighting.alive = false;
    assert(!CanFightPool(fighting));
    for (unsigned i = 0; i < 8; ++i)
    {
        SceneSafety invalid = safe;
        switch (i)
        {
            case 0: invalid.enabled = false; break;
            case 1: invalid.questActive = false; break;
            case 2: invalid.alive = false; break;
            case 3: invalid.sameWorld = false; break;
            case 4: invalid.inCombat = true; break;
            case 5: invalid.mounted = true; break;
            case 6: invalid.flying = true; break;
            case 7: invalid.distance = 20.01f; break;
        }
        assert(!CanObserve(invalid));
    }
    for (unsigned mask = 0; mask < 8; ++mask)
    {
        Counts counts{};
        unsigned completed = 0;
        for (unsigned i = 0; i < 3; ++i)
            if (mask & (1U << i))
            {
                counts[i] = 1;
                ++completed;
            }
        assert(RemainingBundles(counts) == 3 - completed);
        assert(MissingBundles(counts, 0) == 3 - completed);
        assert(MissingBundles(counts, 3) == 0);
        for (unsigned i = 0; i < 3; ++i)
        {
            assert(CanDeliver(counts, i, 1) == (counts[i] == 0));
            assert(!CanDeliver(counts, i, 0));
        }
        assert(!CanDeliver(counts, 3, 3));
    }
    Counts partial{1, 0, 0};
    assert(MissingBundles(partial, 1) == 1);
    assert(MissingBundles(partial, 2) == 0);
    assert(MissingBundles(partial, 5) == 0);

    BirthSequence sequence;
    assert(!sequence.CanFinish(true, true, true));
    assert(!sequence.Advance(BirthSequence::MotherLost));
    assert(sequence.Advance(BirthSequence::Delivered));
    assert(!sequence.Advance(BirthSequence::Delivered));
    assert(!sequence.Advance(BirthSequence::Concluded));
    assert(sequence.Advance(BirthSequence::MotherLost));
    assert(!sequence.CanFinish(true, true, true));
    assert(sequence.Advance(BirthSequence::TwinsStable));
    assert(!sequence.CanFinish(false, true, true));
    assert(!sequence.CanFinish(true, false, true));
    assert(!sequence.CanFinish(true, true, false));
    assert(sequence.CanFinish(true, true, true));
    assert(sequence.Advance(BirthSequence::Concluded));
    assert(!sequence.Advance(BirthSequence::Concluded));
    assert(!sequence.CanFinish(true, true, true));
    BirthSequence retry;
    assert(retry.Current() == BirthSequence::Beginning);
    std::cout << "Chapter 3: scene safety, distinct food deliveries, recovery and birth sequence checks passed.\n";
}
