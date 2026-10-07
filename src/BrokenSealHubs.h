#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_HUBS_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_HUBS_H

#include "BrokenSealHubsData.h"

namespace BrokenSeal::Hubs
{
inline bool Contains(Hub const& hub, float x, float y, float z, float radius)
{
    float dx = x - hub.x;
    float dy = y - hub.y;
    float dz = z - hub.z;
    return dx * dx + dy * dy <= radius * radius && dz <= hub.height && dz >= -hub.height;
}
inline bool ContainsFootprint(Footprint const& f, float x, float y, float z)
{
    return x >= f.left - 2.0f && x <= f.right + 2.0f && y >= f.bottom - 2.0f && y <= f.top + 2.0f && z >= f.z - 8.0f &&
           z <= f.z + 8.0f;
}
struct IntruderPolicy
{
    bool staticSpawn;
    bool alive;
    bool playerControlled;
    bool summoned;
    bool scripted;
    bool questOrServiceNpc;
    bool bossOrElite;
    bool hostileToPlayers;
};
inline bool IsAmbient(IntruderPolicy const& p)
{
    return p.staticSpawn && p.alive && !p.playerControlled && !p.summoned && !p.scripted && !p.questOrServiceNpc &&
           !p.bossOrElite && p.hostileToPlayers;
}
inline bool ShouldRepel(bool insideRestingArea, bool attackingProtectedPlayer)
{
    return insideRestingArea || attackingProtectedPlayer;
}
} // namespace BrokenSeal::Hubs
#endif
