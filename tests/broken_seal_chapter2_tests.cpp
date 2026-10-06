#include "BrokenSealChapter2.h"
#include <cassert>
#include <iostream>

using namespace BrokenSeal::Chapter2;

int main()
{
    AnswerOffer offer;
    assert(offer.Answer(1, 0) == AnswerOffer::Stale);
    offer.Open(17, 1);
    assert(offer.Answer(16, 1) == AnswerOffer::Stale);
    assert(offer.Pending());
    assert(offer.Answer(17, 0) == AnswerOffer::Wrong);
    assert(!offer.Pending());
    assert(offer.Answer(17, 1) == AnswerOffer::Stale);
    offer.Open(18, 0);
    assert(offer.Answer(17, 0) == AnswerOffer::Stale);
    assert(offer.Answer(18, 0) == AnswerOffer::Correct);
    assert(offer.Answer(18, 0) == AnswerOffer::Stale);
    offer.Open(19, 2);
    offer.Cancel(); // timeout, abandon, departure or despawn
    assert(offer.Answer(19, 2) == AnswerOffer::Stale);

    offer.Open(20, 1, 5000);
    assert(offer.Answer(20, 1, 4999) == AnswerOffer::Correct);
    offer.Open(21, 1, 5000);
    assert(offer.Answer(21, 1, 5000) == AnswerOffer::Expired);
    assert(!offer.Pending());
    offer.Open(22, 0, 10000);
    assert(offer.Answer(21, 0, 10001) == AnswerOffer::Stale);
    assert(offer.Answer(22, 0, 10001) == AnswerOffer::Expired);

    TrialSafety safe{true, true, true, true, false, false, false, 7.0f};
    assert(CanContinue(safe, false, 8.0f));
    for (unsigned i = 0; i < 8; ++i)
    {
        TrialSafety invalid = safe;
        switch (i)
        {
            case 0: invalid.enabled = false; break;
            case 1: invalid.questActive = false; break;
            case 2: invalid.alive = false; break;
            case 3: invalid.sameWorld = false; break;
            case 4: invalid.inCombat = true; break;
            case 5: invalid.mounted = true; break;
            case 6: invalid.flying = true; break;
            case 7: invalid.distance = 8.01f; break;
        }
        assert(!CanContinue(invalid, false, 8.0f));
    }
    safe.inCombat = true;
    assert(CanContinue(safe, true, 90.0f));
    assert(!CanContinue(safe, false, 90.0f));
    assert(CanDeliver(true, true, true, true));
    assert(!CanDeliver(false, true, true, true));
    assert(!CanDeliver(true, false, true, true));
    assert(!CanDeliver(true, true, false, true));
    assert(!CanDeliver(true, true, true, false));
    std::cout << "Chapter 2: replay, timeout, scene safety and delivery policy checks passed.\n";
}
