#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER2_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER2_H

#include "BrokenSealChapter2Data.h"
#include <cstdint>

namespace BrokenSeal::Chapter2
{
struct TrialSafety
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

inline bool CanContinue(TrialSafety const& s, bool combatAllowed, float radius)
{
    return s.enabled && s.questActive && s.alive && s.sameWorld && !s.mounted && !s.flying &&
           (combatAllowed || !s.inCombat) && s.distance <= radius;
}

// A response consumes exactly the offer that produced its menu. Old menus cannot answer a new question.
class AnswerOffer
{
  public:
    void Open(std::uint32_t ticket, std::uint32_t correct, std::uint32_t window = UINT32_MAX)
    {
        _ticket = ticket;
        _correct = correct;
        _window = window;
        _pending = true;
    }

    bool Pending() const { return _pending; }
    std::uint32_t Ticket() const { return _ticket; }
    void Cancel() { _pending = false; }

    enum Result
    {
        Stale,
        Wrong,
        Correct,
        Expired
    };
    Result Answer(std::uint32_t ticket, std::uint32_t choice, std::uint32_t elapsed = 0)
    {
        if (!_pending || ticket != _ticket)
            return Stale;
        _pending = false;
        if (elapsed >= _window)
            return Expired;
        return choice == _correct ? Correct : Wrong;
    }

  private:
    std::uint32_t _ticket = 0;
    std::uint32_t _correct = 0;
    std::uint32_t _window = UINT32_MAX;
    bool _pending = false;
};

inline bool CanDeliver(bool carrying, bool active, bool onFoot, bool atStation)
{
    return carrying && active && onFoot && atStation;
}
} // namespace BrokenSeal::Chapter2

#endif
