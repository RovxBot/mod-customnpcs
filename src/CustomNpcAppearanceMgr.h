/*
 * Copyright (C) 2026 mod-customNPCs contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#ifndef MOD_CUSTOMNPCS_APPEARANCE_MGR_H
#define MOD_CUSTOMNPCS_APPEARANCE_MGR_H

#include "CustomNpcOutfit.h"
#include "ObjectGuid.h"

#include <map>
#include <mutex>
#include <string>
#include <tuple>

class Creature;
class WorldSession;

namespace CustomNpcs
{
class AppearanceMgr
{
public:
    static AppearanceMgr& Instance();

    // Publishes an immutable catalog. Each map applies changes during its own update.
    void Reload();
    bool Validate(Outfit& outfit, std::string& error) const;
    std::shared_ptr<Outfit const> GetOutfit(std::uint32_t id) const;
    std::shared_ptr<Outfit const> GetOutfitFor(Creature const* creature) const;
    void Update(Creature* creature);
    void Remove(Creature const* creature);
    void Detach(Creature* creature);
    bool SendMirrorImage(WorldSession* session, ObjectGuid guid) const;

private:
    using CreatureKey = std::tuple<std::uint32_t, std::uint32_t, ObjectGuid>;
    struct AppliedAppearance
    {
        std::uint32_t entry = 0;
        std::uint32_t originalDisplay = 0;
        std::uint32_t originalNativeDisplay = 0;
        float originalScale = 1.0f;
        float originalBoundingRadius = 0.0f;
        float originalCombatReach = 0.0f;
        std::uint8_t originalGender = 0;
        bool originalMirrorFlag = false;
        std::array<std::uint32_t, 3> originalWeapons{};
        std::shared_ptr<Outfit const> outfit;
        bool suspended = false;
    };

    static CreatureKey Key(Creature const* creature);
    static void Apply(Creature* creature, Outfit const& outfit, AppliedAppearance const& appearance);
    static void Restore(Creature* creature, AppliedAppearance const& appearance);

    std::shared_ptr<OutfitCatalog const> _catalog = std::make_shared<OutfitCatalog>();
    // Keys include the instance; neither raw creature nor map pointers outlive a hook.
    std::mutex _appliedMutex;
    std::map<CreatureKey, AppliedAppearance> _applied;
};
}

#endif
