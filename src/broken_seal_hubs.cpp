/*
 * Copyright (C) mod-customNPCs contributors.
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
#include "BrokenSealHubs.h"
#include "CellImpl.h"
#include "Config.h"
#include "Creature.h"
#include "DBCStructure.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "ScriptedCreature.h"

#include <algorithm>
#include <chrono>
#include <list>

namespace BrokenSeal::Hubs
{
using namespace std::chrono_literals;
bool Enabled(Hub const& hub)
{
    if (!sConfigMgr->GetOption<bool>("ModCustomNPCs.Enable", true) ||
        !sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Hubs.Enable", true) ||
        !sObjectMgr->GetCreatureTemplate(hub.guard))
        return false;
    if (!sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter1.Enable", true))
        return false;
    if (hub.chapter >= 2 && !sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter2.Enable", true))
        return false;
    return hub.chapter < 3 || sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter3.Enable", true);
}
Hub const* RestingArea(Unit const* unit)
{
    if (!unit || !unit->IsInWorld() || unit->GetMapId() != 1)
        return nullptr;
    if (!(unit->GetPhaseMask() & 1))
        return nullptr;
    for (Hub const& hub : Areas)
        if (Contains(hub, unit->GetPositionX(), unit->GetPositionY(), unit->GetPositionZ(), hub.radius) && Enabled(hub))
            return &hub;
    for (Footprint const& f : Footprints)
        if (ContainsFootprint(f, unit->GetPositionX(), unit->GetPositionY(), unit->GetPositionZ()) &&
            Enabled(Areas[f.area]))
            return &Areas[f.area];
    return nullptr;
}
bool Ambient(Creature const* creature, bool allowDeadSource = false)
{
    if (!creature || creature->GetMapId() != 1)
        return false;
    CreatureTemplate const* tpl = creature->GetCreatureTemplate();
    FactionTemplateEntry const* faction = creature->GetFactionTemplateEntry();
    IntruderPolicy p{creature->GetSpawnId() != 0,
                     allowDeadSource || creature->IsAlive(),
                     creature->GetCharmerOrOwnerPlayerOrPlayerItself() != nullptr,
                     creature->IsSummon(),
                     creature->GetScriptId() != 0 && std::find(PublicQuestMobs.begin(), PublicQuestMobs.end(),
                                                               creature->GetEntry()) == PublicQuestMobs.end(),
                     creature->GetNpcFlags() != 0,
                     tpl->rank != CREATURE_ELITE_NORMAL || creature->isWorldBoss() || creature->IsDungeonBoss(),
                     faction && (faction->hostileMask & 1)};
    return IsAmbient(p);
}
bool ProtectedPair(Unit const* first, Unit const* second, bool damage = false)
{
    if (!first || !second || !first->IsInWorld() || !second->IsInWorld() || first->FindMap() != second->FindMap() ||
        !(first->GetPhaseMask() & second->GetPhaseMask()))
        return false;
    // Only PCs and their actual controlled units get the resting-area rule.
    Player const* player = first->GetCharmerOrOwnerPlayerOrPlayerItself();
    Creature const* intruder = second->ToCreature();
    return player && Ambient(intruder, damage) && RestingArea(player);
}
class bs_hub_safety : public UnitScript
{
public:
    bs_hub_safety() : UnitScript("bs_hub_safety", true, {UNITHOOK_IF_NORMAL_REACTION, UNITHOOK_ON_DAMAGE}) {}
    bool IfNormalReaction(Unit const* unit, Unit const* target, ReputationRank& reaction) override
    {
        if (!ProtectedPair(unit, target) && !ProtectedPair(target, unit))
            return true;
        reaction = REP_FRIENDLY;
        return false;
    }
    void OnDamage(Unit* attacker, Unit* victim, std::uint32_t& damage) override
    {
        // Also catches damage from an ambient attack/DoT started just before entering camp.
        // No blanket invulnerability, player faction changes, or interference with scripted encounters.
        if (ProtectedPair(attacker, victim, true) || ProtectedPair(victim, attacker, true))
            damage = 0;
    }
};
struct npc_bs_hub_sentryAI : ScriptedAI
{
    explicit npc_bs_hub_sentryAI(Creature* c) : ScriptedAI(c) {}
    EventMap events;
    Hub const* Area() const
    {
        for (Hub const& hub : Areas)
            if (hub.guard == me->GetEntry())
                return &hub;
        return nullptr;
    }
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        me->SetSheath(SHEATH_STATE_MELEE);
        events.Reset();
        events.ScheduleEvent(1, 1000ms);
    }
    bool CanAIAttack(Unit const*) const override { return false; }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override { damage = 0; }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() != 1)
            return;
        Hub const* hub = Area();
        if (hub && Enabled(*hub))
        {
            std::list<Creature*> creatures;
            Acore::AnyUnitInObjectRangeCheck check(me, hub->screen + hub->radius);
            Acore::CreatureListSearcher<Acore::AnyUnitInObjectRangeCheck> searcher(me, creatures, check);
            Cell::VisitObjects(me, searcher, hub->screen + hub->radius);
            for (Creature* c : creatures)
            {
                if (!Ambient(c) || c->IsInEvadeMode() || !c->IsAIEnabled || !me->IsWithinLOSInMap(c) ||
                    !Contains(*hub, c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), hub->screen))
                    continue;
                me->HandleEmoteCommand(EMOTE_ONESHOT_POINT);
                // Send ordinary intruders home. Evade clears loot/tag/threat, so these cannot be farmed via guards.
                c->AI()->EnterEvadeMode(EVADE_REASON_BOUNDARY);
            }
        }
        events.ScheduleEvent(1, 1000ms);
    }
};
class npc_bs_hub_sentry : public CreatureScript
{
public:
    npc_bs_hub_sentry() : CreatureScript("npc_bs_hub_sentry") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_hub_sentryAI(c); }
};
struct npc_bs_hub_residentAI : ScriptedAI
{
    explicit npc_bs_hub_residentAI(Creature* c) : ScriptedAI(c) {}
    void Reset() override { me->SetReactState(REACT_PASSIVE); }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override { damage = 0; }
};
class npc_bs_hub_resident : public CreatureScript
{
public:
    npc_bs_hub_resident() : CreatureScript("npc_bs_hub_resident") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_hub_residentAI(c); }
};
} // namespace BrokenSeal::Hubs
void AddBrokenSealHubScripts()
{
    using namespace BrokenSeal::Hubs;
    new bs_hub_safety();
    new npc_bs_hub_sentry();
    new npc_bs_hub_resident();
}
