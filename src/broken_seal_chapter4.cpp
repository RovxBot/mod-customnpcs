/*
 * Copyright (C) mod-customNPCs contributors.
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
#include "BrokenSealChapter4.h"
#include "BrokenSealChapter4Integration.h"
#include "Chat.h"
#include "Config.h"
#include "Creature.h"
#include "GameObject.h"
#include "Item.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "Spell.h"
#include "TemporarySummon.h"

#include <chrono>
#include <list>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace BrokenSeal::Chapter4
{
using namespace std::chrono_literals;
constexpr std::uint32_t Sender = 304;
constexpr char StateKey[] = "mod-customnpcs.broken-seal.chapter4";
enum Mode : std::uint32_t
{
    INSPECT = 1,
    ESCORT,
    TREAT,
    DESPAIR
};
enum Data : std::int32_t
{
    DATA_PARENT = 1
};
enum Event : std::uint32_t
{
    CHECK = 1,
    STEP,
    TIMEOUT,
    COMBAT_SPELL,
    FINISH
};
enum Action : std::uint32_t
{
    RECOVER = 1,
    INSPECT_VILLAGE,
    QUESTION,
    ENCOURAGE,
    MAKE_MEDICINE,
    BOTTLE_RESIDUE,
    BEGIN_TREATMENT,
    BEGIN_DESPAIR,
    RESTART_SERVICE,
    PLEDGE,
    NAME_LIAISON
};
struct PlayerState : DataMap::Base
{
    ObjectGuid scene;
    std::uint32_t phase = 0;
    std::unordered_map<ObjectGuid, std::uint32_t> herbs;
};
PlayerState& State(Player* p)
{
    PlayerState* state = p->CustomData.GetDefault<PlayerState>(StateKey);
    if (!state->phase)
        state->phase = p->GetPhaseMask();
    return *state;
}
bool Enabled()
{
    return sConfigMgr->GetOption<bool>("ModCustomNPCs.Enable", true) &&
           sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter1.Enable", true) &&
           sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter2.Enable", true) &&
           sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter3.Enable", true) &&
           sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter4.Enable", true) &&
           sObjectMgr->GetQuestTemplate(QUEST_INTRO);
}
bool Active(Player const* p, std::uint32_t quest)
{
    return p && p->GetQuestStatus(quest) == QUEST_STATUS_INCOMPLETE;
}
bool Held(Player const* p, std::uint32_t quest)
{
    return p && (Active(p, quest) || p->GetQuestStatus(quest) == QUEST_STATUS_COMPLETE);
}
bool SameWorld(Player const* p, WorldObject const* object)
{
    return p && object && p->IsInWorld() && object->IsInWorld() && p->FindMap() == object->FindMap() &&
           (p->GetPhaseMask() & object->GetPhaseMask());
}
bool Interact(Player const* p, WorldObject const* object)
{
    return Enabled() && SameWorld(p, object) && p->IsAlive() && !p->IsInCombat() && p->IsWithinDistInMap(object, 7.0f);
}
void Tell(Player* p, std::string_view message)
{
    ChatHandler(p->GetSession()).SendSysMessage(message);
}
std::uint32_t Count(Player* p, std::uint32_t quest, std::uint32_t credit)
{
    return p->GetReqKillOrCastCurrentCount(quest, credit);
}
void Credit(Player* p, std::uint32_t quest, std::uint32_t credit, bool repeat = false)
{
    if (Enabled() && Active(p, quest) && (repeat || !Count(p, quest, credit)))
        p->KilledMonsterCredit(credit);
}
bool Give(Player* p, std::uint32_t item)
{
    return p->HasItemCount(item, 1, true) || p->AddItem(item, 1);
}
template <std::size_t N> std::size_t Index(std::array<std::uint32_t, N> const& values, std::uint32_t entry)
{
    for (std::size_t i = 0; i < N; ++i)
        if (values[i] == entry)
            return i;
    return N;
}
bool Owned(Creature const* c, Player const* p)
{
    TempSummon const* summon = c->ToTempSummon();
    return summon && summon->GetSummonerGUID() == p->GetGUID();
}
Creature* Summon(Player* p, std::uint32_t entry, Point const& point, std::uint32_t duration = 480000)
{
    return p->SummonCreature(entry, Position(point.x, point.y, point.z, point.orientation), TEMPSUMMON_TIMED_DESPAWN,
                             duration, 0, nullptr, true);
}
inline constexpr std::array<Point, 3> HearthPoints = {Locations::hearth_a, Locations::hearth_b, Locations::hearth_c};
bool LightHearth(Player* p, Point const& point)
{
    if (p->GetMapId() != 1 || p->GetDistance(point.x, point.y, point.z) > 100.0f)
        return false;
    std::list<Creature*> flames;
    p->GetCreatureListWithEntryInGrid(flames, NPC_HEARTH_FLAME, 100.0f);
    for (Creature* c : flames)
        if (Owned(c, p) && c->GetDistance(point.x, point.y, point.z) < 2.0f)
            return true;
    State(p);
    return Summon(p, NPC_HEARTH_FLAME, point, 120000) != nullptr;
}
void RestoreHearths(Player* p)
{
    if (p->GetMapId() != 1 || (!Held(p, QUEST_WORK) && !p->IsQuestRewarded(QUEST_WORK)))
        return;
    for (std::size_t i = 0; i < HearthPoints.size(); ++i)
        if (p->IsQuestRewarded(QUEST_WORK) || Count(p, QUEST_WORK, HearthCredits[i]))
            LightHearth(p, HearthPoints[i]);
}
std::uint32_t Greeting(Player* p, Creature* c)
{
    if ((p->IsQuestRewarded(QUEST_DESPAIR) || p->GetQuestStatus(QUEST_DESPAIR) == QUEST_STATUS_COMPLETE) &&
        (c->GetEntry() == NPC_YIMO || c->GetEntry() == NPC_MEI ||
         Index(VillagerEntries, c->GetEntry()) < VillagerEntries.size()))
        return TEXT_RECOVERED;
    return c->GetEntry();
}
void Cleanup(Player* p)
{
    if (p->IsInWorld())
        for (std::uint32_t entry : PersonalEntries)
        {
            std::list<Creature*> creatures;
            p->GetCreatureListWithEntryInGrid(creatures, entry, 200.0f);
            for (Creature* c : creatures)
                if (Owned(c, p))
                    c->DespawnOrUnsummon();
        }
    p->CustomData.Erase(StateKey);
}
void Recover(Player* p)
{
    if (Held(p, QUEST_TEST) || Held(p, QUEST_TREAT) || Held(p, QUEST_DESPAIR))
        Give(p, ITEM_MASK);
    if (Held(p, QUEST_LETTER))
        Give(p, ITEM_LETTER);
}
std::uint32_t SceneQuest(std::uint32_t mode)
{
    switch (mode)
    {
        case INSPECT:
            return QUEST_INTRO;
        case ESCORT:
            return QUEST_FIND;
        case TREAT:
            return QUEST_TREAT;
        case DESPAIR:
            return QUEST_DESPAIR;
        default:
            return 0;
    }
}
struct npc_bs_c04_sceneAI : ScriptedAI
{
    explicit npc_bs_c04_sceneAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid patient;
    ObjectGuid enemy;
    ObjectGuid helper;
    std::vector<ObjectGuid> children;
    std::unordered_set<ObjectGuid> defeated;
    EventMap events;
    std::uint32_t mode = 0;
    std::uint32_t phase = 0;
    std::uint32_t step = 0;
    std::uint32_t treatmentIndex = 0;
    bool encounterActive = false;
    bool bossReleased = false;
    bool finishing = false;
    Player* Owner() const
    {
        return ObjectAccessor::FindConnectedPlayer(owner);
    }
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 1000ms);
        events.ScheduleEvent(TIMEOUT, 8min);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        owner = summoner->GetGUID();
        phase = summoner->GetPhaseMask();
        me->setActive(true);
    }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        damage = 0;
    }
    Creature* Child(Player* p, std::uint32_t entry, Point const& point)
    {
        Creature* c = Summon(p, entry, point);
        if (c)
        {
            children.push_back(c->GetGUID());
            c->AI()->SetGUID(me->GetGUID(), DATA_PARENT);
        }
        return c;
    }
    void Abort()
    {
        for (ObjectGuid const& guid : children)
            if (Creature* c = ObjectAccessor::GetCreature(*me, guid))
                c->DespawnOrUnsummon();
        children.clear();
        events.Reset();
        me->DespawnOrUnsummon();
    }
    bool Configure(Player* p, std::uint32_t requested)
    {
        mode = requested;
        if (mode == INSPECT)
        {
            Tell(p, "Ken-Ken points out the cold hearths, untouched food and silent households.");
            events.ScheduleEvent(STEP, 5s);
        }
        else if (mode == ESCORT)
        {
            Creature* yi = Child(p, NPC_YIMO_SCENE, EscortPath[0]);
            if (!yi)
                return false;
            patient = yi->GetGUID();
            yi->Whisper("I do not care where this trail ends. You should leave me here.", LANG_UNIVERSAL, p);
            events.ScheduleEvent(STEP, 2s);
        }
        else if (mode == TREAT)
        {
            std::uint32_t done = Count(p, QUEST_TREAT, CREDIT_TREATED);
            if (done >= VillagerNames.size())
                return false;
            Tell(p, std::string("The next patient is the ") + VillagerNames[done] +
                        ". Use the mask and defeat the despair released before continuing.");
        }
        else if (mode == DESPAIR)
        {
            Creature* ken = Child(p, NPC_KEN_SCENE, Locations::ken_scene);
            if (!ken)
                return false;
            helper = ken->GetGUID();
            ken->GetMotionMaster()->MoveFollow(p, 3.0f, 1.0f);
            std::uint32_t done = Count(p, QUEST_DESPAIR, CREDIT_ESSENCES);
            for (std::uint32_t i = done; i < EssencePoints.size(); ++i)
                if (!Child(p, NPC_ESSENCE, EssencePoints[i]))
                    return false;
            if (done == 8)
                return PrepareYi(p);
            ken->Whisper("The well is full of sads! Clear the little nasties before we help Yi-Mo.", LANG_UNIVERSAL, p);
        }
        return true;
    }
    bool PrepareYi(Player* p)
    {
        if (Creature* yi = ObjectAccessor::GetCreature(*me, patient))
            return yi->IsAlive();
        Creature* yi = Child(p, NPC_YIMO_SCENE, Locations::yimo_scene);
        if (!yi)
            return false;
        patient = yi->GetGUID();
        yi->Whisper("The village would be better without me. I cannot bear to face them.", LANG_UNIVERSAL, p);
        Tell(p, "The lesser manifestations are gone. Use Ken-Ken's mask on Yi-Mo beside the well.");
        return true;
    }
    void EscortArrived(std::uint32_t arrived)
    {
        if (mode != ESCORT || arrived != step)
            return;
        Player* p = Owner();
        Creature* yi = ObjectAccessor::GetCreature(*me, patient);
        if (!Enabled() || !p || !yi || !p->IsAlive() || !SameWorld(p, me) || p->GetPhaseMask() != phase ||
            !Active(p, QUEST_FIND) || p->IsMounted() || p->IsFlying() || !p->IsWithinDistInMap(yi, 40.0f))
        {
            Abort();
            return;
        }
        if (step == 1)
        {
            Creature* stalker = Child(p, NPC_STALKER, Locations::stalker);
            if (!stalker)
            {
                Abort();
                return;
            }
            enemy = stalker->GetGUID();
            encounterActive = true;
            stalker->AI()->AttackStart(p);
            Tell(p, "A marsh stalker blocks Yi-Mo's path. Protect him before moving on.");
        }
        else if (step + 1 == EscortPath.size())
        {
            Credit(p, QUEST_FIND, CREDIT_ESCORT);
            Tell(p, "Yi-Mo reaches the village approach. Speak to him at the southern relief camp.");
            Abort();
        }
        else
            events.ScheduleEvent(STEP, 2s);
    }
    void Treat(Player* p, Creature* target)
    {
        if (p->GetGUID() != owner || !Interact(p, target) || !p->HasItemCount(ITEM_MASK, 1))
            return;
        if (mode == TREAT && Active(p, QUEST_TREAT))
        {
            std::uint32_t done = Count(p, QUEST_TREAT, CREDIT_TREATED);
            auto index = Index(VillagerEntries, target->GetEntry());
            if (!CanTreatNext(done, static_cast<std::uint32_t>(index), encounterActive))
            {
                Tell(p,
                     "Follow the treatment round in order, and defeat the released despair before the next patient.");
                return;
            }
            Creature* manifestation = Child(p, NPC_ESSENCE, VillagerPoints[index]);
            if (!manifestation)
                return;
            treatmentIndex = done;
            enemy = manifestation->GetGUID();
            encounterActive = true;
            target->Whisper("Something cold is leaving me. Please do not let it back in!", LANG_UNIVERSAL, p);
            p->CastSpell(target, SPELL_HEAL_VISUAL, true);
            manifestation->AI()->AttackStart(p);
        }
        else if (mode == DESPAIR && Active(p, QUEST_DESPAIR) && target->GetGUID() == patient && Owned(target, p))
        {
            if (!CanReleaseBoss(Count(p, QUEST_DESPAIR, CREDIT_ESSENCES), bossReleased))
                return;
            Creature* boss = Child(p, NPC_QUINTESSENCE, Locations::boss);
            if (!boss)
                return;
            enemy = boss->GetGUID();
            bossReleased = true;
            Credit(p, QUEST_DESPAIR, CREDIT_YIMO);
            p->CastSpell(target, SPELL_HEAL_VISUAL, true);
            target->Whisper("There is something behind my thoughts. It is tearing free!", LANG_UNIVERSAL, p);
            boss->AI()->AttackStart(p);
        }
    }
    void Defeated(Creature* c)
    {
        Player* p = Owner();
        if (!Enabled() || !p || c->IsAlive() || !SameWorld(p, me) || !p->IsAlive() ||
            p->GetPhaseMask() != phase || p->IsMounted() || p->IsFlying() ||
            !p->IsWithinDistInMap(me, 65.0f) || !Owned(c, p) ||
            !Active(p, SceneQuest(mode)))
            return;
        if (!defeated.insert(c->GetGUID()).second)
            return;
        if (mode == ESCORT && c->GetGUID() == enemy && encounterActive)
        {
            encounterActive = false;
            events.ScheduleEvent(STEP, 2s);
        }
        else if (mode == TREAT && c->GetGUID() == enemy && encounterActive &&
                 treatmentIndex == Count(p, QUEST_TREAT, CREDIT_TREATED))
        {
            encounterActive = false;
            Credit(p, QUEST_TREAT, CREDIT_TREATED, true);
            if (Active(p, QUEST_TREAT))
                Tell(p, std::string("The resident is free. Next, treat the ") +
                            VillagerNames[Count(p, QUEST_TREAT, CREDIT_TREATED)] + ".");
            else
                Abort();
        }
        else if (mode == DESPAIR && c->GetEntry() == NPC_ESSENCE && !bossReleased)
        {
            Credit(p, QUEST_DESPAIR, CREDIT_ESSENCES, true);
            if (Count(p, QUEST_DESPAIR, CREDIT_ESSENCES) == 8 && !PrepareYi(p))
                Abort();
        }
        else if (mode == DESPAIR && c->GetGUID() == enemy &&
                 CanFinishBoss(Count(p, QUEST_DESPAIR, CREDIT_ESSENCES), Count(p, QUEST_DESPAIR, CREDIT_YIMO) != 0,
                               bossReleased, c->GetEntry() == NPC_QUINTESSENCE))
        {
            finishing = true;
            if (Creature* ken = ObjectAccessor::GetCreature(*me, helper))
                ken->Whisper("Stay with Ken-Ken! The worst has passed. Yi-Mo can hear us again.", LANG_UNIVERSAL, p);
            events.ScheduleEvent(FINISH, 3s);
        }
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        while (std::uint32_t event = events.ExecuteEvent())
        {
            Player* p = Owner();
            if (!Enabled() || !p || !p->IsAlive() || !SameWorld(p, me) || p->GetPhaseMask() != phase ||
                !Active(p, SceneQuest(mode)) || p->IsMounted() || p->IsFlying() ||
                !p->IsWithinDistInMap(me, mode == ESCORT ? 150.0f : 65.0f))
            {
                Abort();
                return;
            }
            if (event == CHECK)
            {
                if (mode == ESCORT)
                    if (Creature* yi = ObjectAccessor::GetCreature(*me, patient))
                        if (!p->IsWithinDistInMap(yi, 40.0f))
                        {
                            Abort();
                            return;
                        }
                if (mode == DESPAIR && !finishing)
                    if (Creature* ken = ObjectAccessor::GetCreature(*me, helper))
                    {
                        Creature* victim = p->GetVictim() ? p->GetVictim()->ToCreature() : nullptr;
                        if (!victim)
                            for (ObjectGuid const& guid : children)
                                if (Creature* candidate = ObjectAccessor::GetCreature(*me, guid))
                                    if (candidate->IsAlive() && candidate->GetFaction() == 14 &&
                                        candidate->IsInCombat())
                                    {
                                        victim = candidate;
                                        break;
                                    }
                        if (victim && Owned(victim, p) && victim->GetFaction() == 14)
                            ken->AI()->AttackStart(victim);
                        else if (!ken->IsInCombat())
                            ken->GetMotionMaster()->MoveFollow(p, 3.0f, 1.0f);
                    }
                events.ScheduleEvent(CHECK, 1s);
            }
            else if (event == TIMEOUT)
            {
                Tell(p, "The treatment party withdraws. Speak to Ken-Ken or use the trail sign to resume.");
                Abort();
                return;
            }
            else if (event == FINISH)
            {
                if (Creature* yi = ObjectAccessor::GetCreature(*me, patient))
                    yi->Whisper("My mind is clear. You came back for me twice. We will rebuild, and we will remember.",
                                LANG_UNIVERSAL, p);
                Credit(p, QUEST_DESPAIR, CREDIT_BOSS);
                Abort();
                return;
            }
            else if (event == STEP && mode == INSPECT)
            {
                if (!p->IsWithinDistInMap(me, 20.0f) || p->IsInCombat())
                {
                    Abort();
                    return;
                }
                if (step++ == 0)
                {
                    Tell(p, "The families describe the same hopelessness. Their food is sound, but nobody will eat.");
                    events.ScheduleEvent(STEP, 7s);
                }
                else
                {
                    Credit(p, QUEST_INTRO, CREDIT_INSPECT);
                    Abort();
                    return;
                }
            }
            else if (event == STEP && mode == ESCORT)
            {
                Creature* yi = ObjectAccessor::GetCreature(*me, patient);
                if (!yi || !yi->IsAlive())
                {
                    Abort();
                    return;
                }
                ++step;
                if (step >= EscortPath.size())
                    return;
                Point const& next = EscortPath[step];
                yi->SetWalk(true);
                yi->GetMotionMaster()->MovePoint(step, next.x, next.y, next.z);
            }
        }
    }
};
npc_bs_c04_sceneAI* Scene(Player* p)
{
    PlayerState* state = p->CustomData.Get<PlayerState>(StateKey);
    Creature* c = state ? ObjectAccessor::GetCreature(*p, state->scene) : nullptr;
    return c && Owned(c, p) ? dynamic_cast<npc_bs_c04_sceneAI*>(c->AI()) : nullptr;
}
bool Start(Player* p, std::uint32_t mode)
{
    if (!Enabled() || !Active(p, SceneQuest(mode)) || !p->IsAlive() || p->IsInCombat() || p->IsMounted() ||
        p->IsFlying() || p->GetMapId() != 1)
        return false;
    if (auto* current = Scene(p))
    {
        if (current->mode == mode)
            return true;
        current->Abort();
    }
    Point const& point = mode == ESCORT ? Locations::trail : mode == DESPAIR ? Locations::well : Locations::ken;
    Creature* c = Summon(p, NPC_SCENE, point);
    if (!c)
        return false;
    State(p).scene = c->GetGUID();
    auto* ai = dynamic_cast<npc_bs_c04_sceneAI*>(c->AI());
    if (!ai || !ai->Configure(p, mode))
    {
        if (ai)
            ai->Abort();
        else
            c->DespawnOrUnsummon();
        return false;
    }
    return true;
}
struct npc_bs_c04_actorAI : ScriptedAI
{
    explicit npc_bs_c04_actorAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid parent;
    EventMap events;
    void Reset() override
    {
        me->SetReactState(me->GetEntry() == NPC_KEN_SCENE ? REACT_DEFENSIVE : REACT_PASSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 1s);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        owner = summoner->GetGUID();
        me->setActive(true);
    }
    void SetGUID(ObjectGuid const& guid, std::int32_t type) override
    {
        if (type == DATA_PARENT)
            parent = guid;
    }
    ObjectGuid GetGUID(std::int32_t type) const override
    {
        return type == DATA_PARENT ? parent : owner;
    }
    bool CanAIAttack(Unit const* unit) const override
    {
        Creature const* c = unit ? unit->ToCreature() : nullptr;
        TempSummon const* summon = c ? c->ToTempSummon() : nullptr;
        return Enabled() && me->GetEntry() == NPC_KEN_SCENE && summon && summon->GetSummonerGUID() == owner &&
               (c->GetEntry() == NPC_ESSENCE || c->GetEntry() == NPC_QUINTESSENCE);
    }
    void MovementInform(std::uint32_t type, std::uint32_t id) override
    {
        if (type == POINT_MOTION_TYPE && me->GetEntry() == NPC_YIMO_SCENE)
            if (Creature* c = ObjectAccessor::GetCreature(*me, parent))
                if (auto* ai = dynamic_cast<npc_bs_c04_sceneAI*>(c->AI()))
                    ai->EscortArrived(id);
    }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        damage = 0;
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == CHECK)
        {
            Player* p = ObjectAccessor::FindConnectedPlayer(owner);
            if (!Enabled() || !p || !p->IsAlive() || !SameWorld(p, me) || !ObjectAccessor::GetCreature(*me, parent))
            {
                me->DespawnOrUnsummon();
                return;
            }
            events.ScheduleEvent(CHECK, 1s);
        }
        if (me->GetEntry() == NPC_KEN_SCENE && UpdateVictim())
            DoMeleeAttackIfReady();
    }
};
struct npc_bs_c04_enemyAI : ScriptedAI
{
    explicit npc_bs_c04_enemyAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid parent;
    EventMap events;
    void Reset() override
    {
        me->SetReactState(REACT_DEFENSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 1s);
        events.ScheduleEvent(COMBAT_SPELL, 6s);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        owner = summoner->GetGUID();
        me->setActive(true);
    }
    void SetGUID(ObjectGuid const& guid, std::int32_t type) override
    {
        if (type == DATA_PARENT)
            parent = guid;
    }
    bool Allowed(Unit const* unit) const
    {
        Player const* p = unit ? unit->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
        Creature const* c = unit ? unit->ToCreature() : nullptr;
        TempSummon const* summon = c ? c->ToTempSummon() : nullptr;
        return (p && p->GetGUID() == owner) ||
               (summon && c->GetEntry() == NPC_KEN_SCENE && summon->GetSummonerGUID() == owner);
    }
    bool CanAIAttack(Unit const* unit) const override
    {
        return Enabled() && Allowed(unit);
    }
    void DamageTaken(Unit* attacker, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        if (!Enabled() || !Allowed(attacker))
            damage = 0;
    }
    void JustDied(Unit*) override
    {
        if (Creature* c = ObjectAccessor::GetCreature(*me, parent))
            if (auto* ai = dynamic_cast<npc_bs_c04_sceneAI*>(c->AI()))
                ai->Defeated(me);
    }
    void EnterEvadeMode(EvadeReason why) override
    {
        ScriptedAI::EnterEvadeMode(why);
        // A reset encounter remains available to its owner; no kill credit comes from guard evades.
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        while (std::uint32_t event = events.ExecuteEvent())
        {
            if (event == CHECK)
            {
                Player* p = ObjectAccessor::FindConnectedPlayer(owner);
                if (!Enabled() || !p || !p->IsAlive() || !SameWorld(p, me) || !ObjectAccessor::GetCreature(*me, parent))
                {
                    me->DespawnOrUnsummon();
                    return;
                }
                events.ScheduleEvent(CHECK, 1s);
            }
            else if (event == COMBAT_SPELL)
            {
                if (UpdateVictim() && !me->HasUnitState(UNIT_STATE_CASTING))
                    DoCastVictim(me->GetEntry() == NPC_STALKER ? SPELL_POISON : SPELL_SHADOW_BOLT);
                events.ScheduleEvent(COMBAT_SPELL, 8s);
            }
        }
        if (UpdateVictim())
            DoMeleeAttackIfReady();
    }
};
void Menu(Player* p, Creature* c)
{
    if (!Interact(p, c))
        return;
    RestoreHearths(p);
    auto add = [&](std::uint32_t action, char const* label)
    { AddGossipItemFor(p, GOSSIP_ICON_CHAT, label, Sender, action); };
    std::uint32_t entry = c->GetEntry();
    add(RECOVER, "Replace a lost treatment mask or introduction letter.");
    if (entry == NPC_KEN)
    {
        if (Active(p, QUEST_INTRO))
            add(INSPECT_VILLAGE, "Show me what has happened to the families.");
        if (Active(p, QUEST_TEST))
            add(BOTTLE_RESIDUE, "Bottle the residue from the three tests.");
        if (Active(p, QUEST_TREAT))
            add(BEGIN_TREATMENT, "Begin or resume the village treatment round.");
        if (Active(p, QUEST_DESPAIR))
            add(BEGIN_DESPAIR, "Meet me at the well to help Yi-Mo.");
    }
    auto index = Index(VillagerEntries, entry);
    if (index < 3 && Active(p, QUEST_FOOD))
        add(QUESTION, "Tell me what has made you give up.");
    if (index < 3 && Active(p, QUEST_WORK) && CanRestartService(Count(p, QUEST_WORK, CREDIT_SERVICES), index))
        add(RESTART_SERVICE, "Let us restart your village service.");
    if (entry == NPC_YIMO)
    {
        if (Active(p, QUEST_CHEER))
            add(ENCOURAGE, "Your supplies are safe. Your neighbors still need you.");
        if (Active(p, QUEST_PLEDGE))
            add(PLEDGE, "I will remember your promise of aid.");
    }
    if (entry == NPC_KANG && Active(p, QUEST_MEDICINE))
        add(MAKE_MEDICINE, "Prepare the herbs at your hearth.");
    if (entry == NPC_MEI && Active(p, QUEST_PLEDGE))
        add(NAME_LIAISON, "Will you become the village's supply liaison?");
}
bool Select(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action)
{
    if (sender != Sender)
        return false;
    CloseGossipMenuFor(p);
    if (!Interact(p, c))
        return true;
    std::uint32_t entry = c->GetEntry();
    auto index = Index(VillagerEntries, entry);
    if (action == RECOVER)
        Recover(p);
    else if (action == INSPECT_VILLAGE && entry == NPC_KEN)
        Start(p, INSPECT);
    else if (action == BEGIN_TREATMENT && entry == NPC_KEN)
    {
        Recover(p);
        if (p->HasItemCount(ITEM_MASK, 1))
            Start(p, TREAT);
    }
    else if (action == BEGIN_DESPAIR && entry == NPC_KEN)
    {
        Recover(p);
        if (p->HasItemCount(ITEM_MASK, 1))
        {
            Tell(p, "Meet Ken-Ken at the old well southeast of the village, then use it to begin the confrontation.");
        }
    }
    else if (action == QUESTION && index < 3 && Active(p, QUEST_FOOD))
    {
        static constexpr std::array<char const*, 3> stories = {
            "There is food, but I cannot see the point of eating.",
            "I hear the well at night. It repeats every failure.",
            "Yi-Mo went down the trail. I could not even make myself follow."};
        c->Whisper(stories[index], LANG_UNIVERSAL, p);
        Credit(p, QUEST_FOOD, QuestionCredits[index]);
    }
    else if (action == ENCOURAGE && entry == NPC_YIMO && Active(p, QUEST_CHEER) && p->HasItemCount(ITEM_FOOD, 3))
    {
        c->Whisper("You kept them safe. Perhaps I can still do one useful thing for my neighbors.", LANG_UNIVERSAL, p);
        Credit(p, QUEST_CHEER, CREDIT_CHEER);
    }
    else if (action == MAKE_MEDICINE && entry == NPC_KANG && Active(p, QUEST_MEDICINE) &&
             Count(p, QUEST_MEDICINE, CREDIT_HERBS) == 8 && c->FindNearestGameObject(GO_HEARTH_C, 12.0f))
    {
        LightHearth(p, Locations::hearth_c);
        if (Give(p, ITEM_MEDICINE))
            c->Whisper("Warm the fresh leaves gently. This medicine will help Ken-Ken draw the gloom out.",
                       LANG_UNIVERSAL, p);
    }
    else if (action == BOTTLE_RESIDUE && entry == NPC_KEN && Active(p, QUEST_TEST))
    {
        bool ready = true;
        for (std::uint32_t credit : TestCredits)
            ready = ready && Count(p, QUEST_TEST, credit);
        if (ready)
            Give(p, ITEM_RESIDUE);
        else
            Tell(p, "Test all three residents before bottling the residue.");
    }
    else if (action == RESTART_SERVICE && Active(p, QUEST_WORK) &&
             CanRestartService(Count(p, QUEST_WORK, CREDIT_SERVICES), index))
    {
        static constexpr std::array<char const*, 3> services = {
            "I will sort and share the sound provisions.", "I can prepare medicine for the families again.",
            "The tools need repair. I will put them back into service."};
        c->Whisper(services[index], LANG_UNIVERSAL, p);
        Credit(p, QUEST_WORK, CREDIT_SERVICES, true);
    }
    else if (action == PLEDGE && entry == NPC_YIMO && Active(p, QUEST_PLEDGE))
        Give(p, ITEM_PLEDGE);
    else if (action == NAME_LIAISON && entry == NPC_MEI && Active(p, QUEST_PLEDGE))
    {
        c->Whisper("I will keep our supply route open. The village can call on us, and we can call on it.",
                   LANG_UNIVERSAL, p);
        Credit(p, QUEST_PLEDGE, CREDIT_LIAISON);
    }
    return true;
}
struct npc_bs_c04_contactAI : ScriptedAI
{
    explicit npc_bs_c04_contactAI(Creature* c) : ScriptedAI(c) {}
    EventMap events;
    void Flags()
    {
        if (Enabled())
        {
            me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);
            if (me->GetEntry() <= NPC_IAIN)
                me->SetNpcFlag(UNIT_NPC_FLAG_QUESTGIVER);
        }
        else
            me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
    }
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        Flags();
        events.Reset();
        events.ScheduleEvent(CHECK, 2s);
    }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        damage = 0;
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == CHECK)
        {
            Flags();
            events.ScheduleEvent(CHECK, 2s);
        }
    }
};
class npc_bs_c04_contact : public CreatureScript
{
public:
    npc_bs_c04_contact() : CreatureScript("npc_bs_c04_contact") {}
    CreatureAI* GetAI(Creature* c) const override
    {
        return new npc_bs_c04_contactAI(c);
    }
    bool OnGossipHello(Player* p, Creature* c) override
    {
        if (!Interact(p, c))
            return true;
        ClearGossipMenuFor(p);
        p->PrepareQuestMenu(c->GetGUID());
        Menu(p, c);
        SendGossipMenuFor(p, Greeting(p, c), c->GetGUID());
        return true;
    }
    bool OnGossipSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action) override
    {
        return Select(p, c, sender, action);
    }
};
struct npc_bs_c04_flameAI : ScriptedAI
{
    explicit npc_bs_c04_flameAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    EventMap events;
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 1s);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        owner = summoner->GetGUID();
    }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        damage = 0;
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() != CHECK)
            return;
        Player* p = ObjectAccessor::FindConnectedPlayer(owner);
        if (!Enabled() || !p || !p->IsAlive() || !SameWorld(p, me) || p->GetPhaseMask() != me->GetPhaseMask())
        {
            me->DespawnOrUnsummon();
            return;
        }
        events.ScheduleEvent(CHECK, 1s);
    }
};
class npc_bs_c04_flame : public CreatureScript
{
public:
    npc_bs_c04_flame() : CreatureScript("npc_bs_c04_flame") {}
    CreatureAI* GetAI(Creature* c) const override
    {
        return new npc_bs_c04_flameAI(c);
    }
};
class npc_bs_c04_actor : public CreatureScript
{
public:
    npc_bs_c04_actor() : CreatureScript("npc_bs_c04_actor") {}
    CreatureAI* GetAI(Creature* c) const override
    {
        return new npc_bs_c04_actorAI(c);
    }
};
class npc_bs_c04_scene : public CreatureScript
{
public:
    npc_bs_c04_scene() : CreatureScript("npc_bs_c04_scene") {}
    CreatureAI* GetAI(Creature* c) const override
    {
        return new npc_bs_c04_sceneAI(c);
    }
};
class npc_bs_c04_enemy : public CreatureScript
{
public:
    npc_bs_c04_enemy() : CreatureScript("npc_bs_c04_enemy") {}
    CreatureAI* GetAI(Creature* c) const override
    {
        return new npc_bs_c04_enemyAI(c);
    }
};
class go_bs_c04_interaction : public GameObjectScript
{
public:
    go_bs_c04_interaction() : GameObjectScript("go_bs_c04_interaction") {}
    bool OnGossipHello(Player* p, GameObject* go) override
    {
        if (!Interact(p, go))
            return true;
        std::uint32_t entry = go->GetEntry();
        if (entry == GO_TRAIL)
            Start(p, ESCORT);
        else if ((entry == GO_SUPPLY && Held(p, QUEST_FOOD)) || (entry == GO_LOST_SUPPLY && Held(p, QUEST_CHEER)))
        {
            std::uint32_t needed = Held(p, QUEST_FOOD) ? 6 : 3;
            if (p->GetItemCount(ITEM_FOOD, true) < needed)
                p->AddItem(ITEM_FOOD, 1);
        }
        else if (entry == GO_HERB && Active(p, QUEST_MEDICINE) && Count(p, QUEST_MEDICINE, CREDIT_HERBS) < 8)
        {
            auto& nodes = State(p).herbs;
            auto it = nodes.find(go->GetGUID());
            if (it == nodes.end() || getMSTimeDiff(it->second, getMSTime()) >= 60000)
            {
                Credit(p, QUEST_MEDICINE, CREDIT_HERBS, true);
                nodes[go->GetGUID()] = getMSTime();
            }
            else
                Tell(p, "Gather from another marked herb patch while these leaves regrow.");
        }
        else if (entry == GO_WELL)
        {
            if (Active(p, QUEST_WARD))
                Credit(p, QUEST_WARD, CREDIT_WELL);
            else if (Active(p, QUEST_DESPAIR))
            {
                Recover(p);
                if (p->HasItemCount(ITEM_MASK, 1))
                    Start(p, DESPAIR);
            }
        }
        else if (entry == GO_WARD && Active(p, QUEST_WARD) && Count(p, QUEST_WARD, CREDIT_WELL))
            Give(p, ITEM_WARD);
        else
        {
            auto index = Index(HearthEntries, entry);
            if (index < HearthEntries.size())
            {
                if (Active(p, QUEST_WORK) && !Count(p, QUEST_WORK, HearthCredits[index]) &&
                    LightHearth(p, HearthPoints[index]))
                    Credit(p, QUEST_WORK, HearthCredits[index]);
                else
                    RestoreHearths(p);
                if (entry == GO_HEARTH_C && Active(p, QUEST_MEDICINE) && Count(p, QUEST_MEDICINE, CREDIT_HERBS) == 8 &&
                    p->FindNearestCreature(NPC_KANG, 12.0f))
                {
                    LightHearth(p, HearthPoints[index]);
                    Give(p, ITEM_MEDICINE);
                }
            }
        }
        return true;
    }
};
class item_bs_c04_mask : public ItemScript
{
public:
    item_bs_c04_mask() : ItemScript("item_bs_c04_mask") {}
    bool OnUse(Player* p, Item* item, SpellCastTargets const& targets) override
    {
        p->SendEquipError(EQUIP_ERR_OK, item, nullptr);
        Creature* target = targets.GetUnitTarget() ? targets.GetUnitTarget()->ToCreature() : nullptr;
        if (!target || !Interact(p, target))
            return true;
        auto index = Index(VillagerEntries, target->GetEntry());
        if (Active(p, QUEST_TEST) && index < TestCredits.size())
        {
            Credit(p, QUEST_TEST, TestCredits[index]);
            p->CastSpell(target, SPELL_HEAL_VISUAL, true);
            target->Whisper("The mask draws a dark residue from my skin. It came from the well.", LANG_UNIVERSAL, p);
        }
        else if (Active(p, QUEST_TREAT) && index < VillagerEntries.size())
        {
            if (Start(p, TREAT))
                if (auto* ai = Scene(p))
                    ai->Treat(p, target);
        }
        else if (Active(p, QUEST_DESPAIR) && target->GetEntry() == NPC_YIMO_SCENE && Owned(target, p))
            if (auto* ai = Scene(p))
                ai->Treat(p, target);
        return true;
    }
};
class bs_c04_player : public PlayerScript
{
public:
    bs_c04_player()
        : PlayerScript("bs_c04_player", {PLAYERHOOK_ON_LOGOUT, PLAYERHOOK_ON_QUEST_ABANDON, PLAYERHOOK_ON_UPDATE})
    {
    }
    void OnPlayerLogout(Player* p) override
    {
        Cleanup(p);
    }
    void OnPlayerQuestAbandon(Player* p, std::uint32_t quest) override
    {
        if (quest >= QUEST_INTRO && quest <= QUEST_LETTER)
            Cleanup(p);
    }
    void OnPlayerUpdate(Player* p, std::uint32_t) override
    {
        PlayerState* state = p->CustomData.Get<PlayerState>(StateKey);
        if (state && (!Enabled() || !p->IsAlive() || p->GetMapId() != 1 || state->phase != p->GetPhaseMask()))
            Cleanup(p);
    }
};
void FilterQuestMenu(Player* p)
{
    QuestMenu& menu = p->PlayerTalkClass->GetQuestMenu();
    std::vector<QuestMenuItem> keep;
    for (std::uint16_t i = 0; i < menu.GetMenuItemCount(); ++i)
    {
        QuestMenuItem const& item = menu.GetItem(i);
        if (item.QuestId < QUEST_INTRO || item.QuestId > QUEST_LETTER)
            keep.push_back(item);
    }
    menu.ClearMenu();
    for (QuestMenuItem const& item : keep)
        menu.AddMenuItem(item.QuestId, item.QuestIcon);
}
} // namespace BrokenSeal::Chapter4
std::uint32_t BrokenSealChapter4Gossip(Player* p, Creature* c)
{
    using namespace BrokenSeal::Chapter4;
    if (c->GetEntry() != NPC_MEI)
        return c->GetEntry();
    if (!Enabled())
    {
        FilterQuestMenu(p);
        return c->GetEntry();
    }
    Menu(p, c);
    std::uint32_t greeting = Greeting(p, c);
    return greeting == TEXT_RECOVERED ? greeting : p->IsQuestRewarded(QUEST_C03_END) ? TEXT_MEI : c->GetEntry();
}
bool BrokenSealChapter4Select(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action)
{
    return BrokenSeal::Chapter4::Select(p, c, sender, action);
}
void AddBrokenSealChapter4Scripts()
{
    using namespace BrokenSeal::Chapter4;
    new npc_bs_c04_contact();
    new npc_bs_c04_actor();
    new npc_bs_c04_flame();
    new npc_bs_c04_scene();
    new npc_bs_c04_enemy();
    new go_bs_c04_interaction();
    new item_bs_c04_mask();
    new bs_c04_player();
}
