// Behavioral checks for distinct progress and interrupted personal scenes.
#include "BrokenSealChapter1.h"

#include <cassert>
#include <iostream>

using namespace BrokenSeal::Chapter1;

int main()
{
    Counts alice{};
    Counts bob{};
    for (unsigned replay = 0; replay < 20; ++replay)
    {
        if (NeedsDistinct(alice, 0))
            ++alice[0];
    }
    assert(alice[0] == 1);
    assert(!AllDistinctDone(alice));
    assert(NeedsDistinct(bob, 0));
    assert(!NeedsDistinct(alice, DistinctCount));
    alice[1] = 1;
    alice[2] = 1;
    assert(AllDistinctDone(alice));
    assert(!AllDistinctDone(bob));
    assert(IndexOf(CaptiveEntries, NPC_CAPTIVE_B) == 1);
    assert(IndexOf(CaptiveEntries, NPC_SCOUT) == DistinctCount);
    assert(IndexOf(WardEntries, GO_CAGE_A) == DistinctCount);

    SceneSafety safety{true, true, true, true, false, 5.0f};
    assert(CanObserve(safety));
    safety.inCombat = true;
    assert(!CanObserve(safety));
    assert(CanEscort(safety)); // Pauses rather than losing prior rescued people.
    assert(!CanCreditArrival(safety, true, 1.0f));
    safety.inCombat = false;
    assert(!CanCreditArrival(safety, false, 1.0f)); // Cage opening is not arrival.
    assert(!CanCreditArrival(safety, true, 25.0f)); // Partial paths do not finish.
    assert(CanCreditArrival(safety, true, 1.0f));
    safety.questActive = false;
    assert(!CanEscort(safety)); // Abandonment/reward ends the owned actor.
    safety.questActive = true;
    safety.ownerAlive = false;
    assert(!CanObserve(safety));
    assert(!CanCreditArrival(safety, true, 1.0f));
    safety.ownerAlive = true;
    safety.sameMapAndPhase = false;
    assert(!CanEscort(safety));
    safety.sameMapAndPhase = true;
    safety.enabled = false;
    assert(!CanObserve(safety));
    assert(!CanEscort(safety));
    safety.enabled = true;
    safety.distance = 100.0f;
    assert(!CanObserve(safety));
    assert(!CanEscort(safety));
    safety.distance = 5.0f;
    assert(CanObserve(safety)); // A retry is possible after an interruption.

    assert(CaptiveCredits[0] != CaptiveCredits[1]);
    assert(CaptiveCredits[1] != CaptiveCredits[2]);
    assert(WardCredits[0] != WardCredits[1]);
    assert(TrailCredits[0] != TrailCredits[2]);
    std::cout << "Chapter 1 distinct progress and scene-safety checks passed.\n";
}
