#include "BrokenSealHubs.h"
#include <cassert>
#include <iostream>

using namespace BrokenSeal::Hubs;
int main()
{
    IntruderPolicy ordinary{true, true, false, false, false, false, false, true};
    assert(IsAmbient(ordinary));
    assert(!ShouldRepel(false, false)); // Outside quest fights must remain untouched.
    assert(ShouldRepel(true, false));
    assert(ShouldRepel(false, true));
    assert(ShouldRepel(true, true));
    for (unsigned i = 0; i < 8; ++i)
    {
        IntruderPolicy excluded = ordinary;
        switch (i)
        {
            case 0: excluded.staticSpawn = false; break;
            case 1: excluded.alive = false; break;
            case 2: excluded.playerControlled = true; break;
            case 3: excluded.summoned = true; break;
            case 4: excluded.scripted = true; break;
            case 5: excluded.questOrServiceNpc = true; break;
            case 6: excluded.bossOrElite = true; break;
            case 7: excluded.hostileToPlayers = false; break;
        }
        assert(!IsAmbient(excluded));
    }
    for (Hub const& hub : Areas)
    {
        assert(Contains(hub, hub.x, hub.y, hub.z, hub.radius));
        assert(Contains(hub, hub.x + hub.radius, hub.y, hub.z, hub.radius));
        assert(!Contains(hub, hub.x + hub.radius + 0.01f, hub.y, hub.z, hub.radius));
        assert(!Contains(hub, hub.x, hub.y, hub.z + hub.height + 0.01f, hub.radius));
        assert(!Contains(hub, hub.x, hub.y, hub.z - hub.height - 0.01f, hub.radius));
        assert(!Contains(hub, hub.x + hub.radius, hub.y + hub.radius, hub.z, hub.radius));
        assert(Contains(hub, hub.x + hub.radius + 1.0f, hub.y, hub.z, hub.screen));
    }
    for (Footprint const& f : Footprints)
    {
        assert(ContainsFootprint(f, f.left, f.bottom, f.z));
        assert(ContainsFootprint(f, f.right, f.top, f.z));
        assert(!ContainsFootprint(f, f.right + 2.1f, f.top, f.z));
        assert(!ContainsFootprint(f, f.left, f.bottom, f.z + 8.1f));
    }
    std::cout << "Hub boundaries and ambient-only safety exclusions passed.\n";
}
