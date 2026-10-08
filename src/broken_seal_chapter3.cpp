/*
 * Copyright (C) mod-customNPCs contributors.
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#include "BrokenSealChapter3.h"
#include "BrokenSealChapter3Integration.h"
#include "BrokenSealChapter4Integration.h"
#include "Chat.h"
#include "Config.h"
#include "Creature.h"
#include "GameObject.h"
#include "Item.h"
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
#include <string_view>
#include <unordered_map>
#include <vector>

namespace BrokenSeal::Chapter3
{
using namespace std::chrono_literals;
constexpr std::uint32_t Sender = 303;
constexpr char StateKey[] = "mod-customnpcs.broken-seal.chapter3";
enum Mode : std::uint32_t
{
    PATIENT = 1,
    LIFE,
    VIGIL,
    POOL
};
enum Data : std::int32_t
{
    DATA_PARENT = 1,
    DATA_POOL_DEFEATED = 2
};
enum Event : std::uint32_t
{
    CHECK = 1,
    TIMEOUT,
    STEP,
    TREATED,
    MOTHER_LOST,
    COMBAT_SPELL,
    POOL_HELP
};
enum Action : std::uint32_t
{
    RECOVER = 1,
    PREPARE_PATIENT,
    PREPARE_REMEDY,
    COMPARE_ORDERS,
    MAKE_PROMISE,
    BEGIN_LIFE,
    BEGIN_VIGIL,
    PRESENT_TWINS,
    DELIVER_FOOD,
    BEGIN_POOL,
    COOK_STEW,
};

struct PlayerState : DataMap::Base
{
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
           sObjectMgr->GetQuestTemplate(QUEST_SEARCH);
}

bool Active(Player const* p, std::uint32_t quest)
{
    return p && p->GetQuestStatus(quest) == QUEST_STATUS_INCOMPLETE;
}
bool Held(Player const* p, std::uint32_t quest)
{
    return p &&
           (p->GetQuestStatus(quest) == QUEST_STATUS_INCOMPLETE || p->GetQuestStatus(quest) == QUEST_STATUS_COMPLETE);
}
bool LifeFinished(Player const* p)
{
    return p && (p->IsQuestRewarded(QUEST_LIFE) || p->GetQuestStatus(QUEST_LIFE) == QUEST_STATUS_COMPLETE);
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
bool Give(Player* p, std::uint32_t item)
{
    return p->HasItemCount(item, 1, true) || p->AddItem(item, 1);
}
bool HasCredit(Player* p, std::uint32_t quest, std::uint32_t credit)
{
    return p->GetReqKillOrCastCurrentCount(quest, credit) > 0;
}
void Credit(Player* p, std::uint32_t quest, std::uint32_t credit, std::uint32_t cap = 1)
{
    if (Enabled() && Active(p, quest) && p->GetReqKillOrCastCurrentCount(quest, credit) < cap)
        p->KilledMonsterCredit(credit);
}
Counts DeliveryCounts(Player* p)
{
    Counts result{};
    for (std::size_t i = 0; i < result.size(); ++i)
        result[i] = static_cast<std::uint16_t>(p->GetReqKillOrCastCurrentCount(QUEST_LIVING, RefugeeCredits[i]));
    return result;
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
Creature* FindOwned(Player* p, std::uint32_t entry)
{
    std::list<Creature*> list;
    p->GetCreatureListWithEntryInGrid(list, entry, 100.0f);
    for (Creature* c : list)
        if (c->IsAlive() && Owned(c, p))
            return c;
    return nullptr;
}
Creature* Summon(Player* p, std::uint32_t entry, Point const& point, std::uint32_t duration = 180000)
{
    return p->SummonCreature(entry, Position(point.x, point.y, point.z, point.orientation), TEMPSUMMON_TIMED_DESPAWN,
                             duration, 0, nullptr, true);
}
void Cleanup(Player* p)
{
    if (p->IsInWorld())
        for (std::uint32_t entry : PersonalEntries)
        {
            std::list<Creature*> list;
            p->GetCreatureListWithEntryInGrid(list, entry, 150.0f);
            for (Creature* c : list)
                if (Owned(c, p))
                    c->DespawnOrUnsummon();
        }
    p->CustomData.Erase(StateKey);
}
void Recover(Player* p)
{
    if (Held(p, QUEST_LETTER))
        Give(p, ITEM_LETTER);
    if (Active(p, QUEST_LIVING))
    {
        std::uint32_t missing = MissingBundles(DeliveryCounts(p), p->GetItemCount(ITEM_FOOD, true));
        if (missing)
            p->AddItem(ITEM_FOOD, missing);
    }
}
void Deliver(Player* p, std::size_t index)
{
    if (!Enabled() || !Active(p, QUEST_LIVING) || !CanDeliver(DeliveryCounts(p), index, p->GetItemCount(ITEM_FOOD)))
        return;
    Creature* refugee = p->FindNearestCreature(RefugeeEntries[index], 12.0f);
    if (!refugee || !refugee->IsAlive() || !SameWorld(p, refugee))
        return;
    p->DestroyItemCount(ITEM_FOOD, 1, true);
    Credit(p, QUEST_LIVING, RefugeeCredits[index]);
    refugee->Whisper("We can share this while it is still warm. Thank you for remembering us.", LANG_UNIVERSAL, p);
}
void PresentTwins(Player* p)
{
    if (!Enabled() || !LifeFinished(p))
        return;
    State(p);
    if (!FindOwned(p, NPC_REDHORN))
        Summon(p, NPC_REDHORN, Locations::redhorn, 120000);
    if (!FindOwned(p, NPC_CLOUDHOOF))
        Summon(p, NPC_CLOUDHOOF, Locations::cloudhoof, 120000);
    Tell(p, "Nala settles Redhorn and Cloudhoof in their bundled cots. Both boys are breathing steadily.");
}

struct npc_bs_c03_actorAI : ScriptedAI
{
    explicit npc_bs_c03_actorAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid parent;
    EventMap events;
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        if (me->GetEntry() == NPC_LEZA)
        {
            me->SetStandState(UNIT_STAND_STATE_SLEEP);
            me->SetCorpseDelay(60);
        }
        events.Reset();
        events.ScheduleEvent(CHECK, 1000ms);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        if (summoner->ToPlayer())
            owner = summoner->GetGUID();
        me->setActive(true);
    }
    void SetGUID(ObjectGuid const& guid, std::int32_t type) override
    {
        if (type == DATA_PARENT)
            parent = guid;
    }
    ObjectGuid GetGUID(std::int32_t type) const override { return type == DATA_PARENT ? parent : owner; }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override { damage = 0; }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == CHECK)
        {
            Player* p = ObjectAccessor::GetPlayer(*me, owner);
            bool birthActor = me->GetEntry() == NPC_LEZA;
            if (!p || !Enabled() || !p->IsAlive() || !SameWorld(p, me) || me->GetDistance(p) > 40.0f ||
                (birthActor && LifeFinished(p)) || (!parent.IsEmpty() && !ObjectAccessor::GetCreature(*me, parent)))
            {
                me->DespawnOrUnsummon();
                return;
            }
            events.ScheduleEvent(CHECK, 1000ms);
        }
    }
};

struct npc_bs_c03_sceneAI : ScriptedAI
{
    explicit npc_bs_c03_sceneAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid leza;
    ObjectGuid nala;
    ObjectGuid dezco;
    ObjectGuid redhorn;
    ObjectGuid cloudhoof;
    ObjectGuid opponent;
    ObjectGuid poolGuide;
    std::vector<ObjectGuid> children;
    EventMap events;
    Mode mode = PATIENT;
    BirthSequence birth;
    bool treating = false;
    bool stopped = false;

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 500ms);
        events.ScheduleEvent(TIMEOUT, 120000ms);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        if (summoner->ToPlayer())
            owner = summoner->GetGUID();
        me->setActive(true);
    }
    Player* Owner() { return ObjectAccessor::GetPlayer(*me, owner); }
    Creature* Resolve(ObjectGuid const& guid) { return ObjectAccessor::GetCreature(*me, guid); }
    bool Alive(ObjectGuid const& guid)
    {
        Creature* c = Resolve(guid);
        return c && c->IsAlive();
    }
    std::uint32_t Quest() const
    {
        return mode == POOL ? QUEST_POOLS : mode == PATIENT ? QUEST_POISON : mode == LIFE ? QUEST_LIFE : QUEST_VIGIL;
    }
    bool Safe(Player* p)
    {
        SceneSafety state{Enabled(),
                          Active(p, Quest()),
                          p && p->IsAlive(),
                          SameWorld(p, me),
                          p && p->IsInCombat(),
                          p && p->IsMounted(),
                          p && (p->IsFlying() || p->IsInFlight()),
                          p ? me->GetDistance(p) : 999.0f};
        return mode == POOL ? CanFightPool(state) : CanObserve(state);
    }
    void Stop(std::string_view message = {})
    {
        if (stopped)
            return;
        stopped = true;
        events.Reset();
        if (Player* p = Owner())
            if (!message.empty())
                Tell(p, message);
        for (ObjectGuid const& guid : children)
            if (Creature* c = Resolve(guid))
                c->DespawnOrUnsummon(1000ms);
        me->DespawnOrUnsummon(1000ms);
    }
    ObjectGuid Child(std::uint32_t entry, Point const& point)
    {
        if (stopped)
            return ObjectGuid::Empty;
        Player* p = Owner();
        if (p)
            if (Creature* c = Summon(p, entry, point))
            {
                c->AI()->SetGUID(me->GetGUID(), DATA_PARENT);
                children.push_back(c->GetGUID());
                return c->GetGUID();
            }
        Stop("This attempt could not be prepared. Speak to the quest contact again.");
        return ObjectGuid::Empty;
    }
    void Whisper(ObjectGuid const& speaker, std::string_view words)
    {
        if (Player* p = Owner())
            if (Creature* c = Resolve(speaker))
                c->Whisper(words, LANG_UNIVERSAL, p);
    }
    void Begin(Mode value)
    {
        mode = value;
        if (mode == POOL)
        {
            if (Creature* guide = me->FindNearestCreature(NPC_POOL_GUIDE, 20.0f))
                poolGuide = guide->GetGUID();
            events.RescheduleEvent(TIMEOUT, 300s);
            events.ScheduleEvent(POOL_HELP, 3s);
            NextPoolGuardian();
            return;
        }
        if (mode == VIGIL)
        {
            dezco = Child(NPC_DEZCO_SCENE, Locations::memorial);
            Whisper(dezco, "Stay with me a little while. We do not have to make another decision yet.");
            events.ScheduleEvent(STEP, 20000ms);
            return;
        }
        leza = Child(NPC_LEZA, Locations::leza);
        nala = Child(NPC_NALA_SCENE, Locations::nala_scene);
        if (mode == PATIENT)
        {
            Whisper(nala, "Come close enough to give her the antidote. I will watch her breathing.");
            return;
        }
        dezco = Child(NPC_DEZCO_SCENE, Locations::dezco_scene);
        Whisper(nala, "Wait outside the canvas. I am staying beside her; we will tell you what is happening.");
        events.ScheduleEvent(STEP, 10000ms);
    }
    void NextPoolGuardian()
    {
        Player* p = Owner();
        if (!p || !Safe(p))
        {
            Stop();
            return;
        }
        std::uint32_t count = p->GetReqKillOrCastCurrentCount(QUEST_POOLS, CREDIT_POOL_GUARD);
        if (count >= 4)
        {
            if (Give(p, ITEM_SAMPLE))
                Stop("The waters are clear enough to sample. Bring the purified water to Kang.");
            else
                Stop("Make room for the sample, then speak to Na Lek again. Your victories remain recorded.");
            return;
        }
        opponent = Child(NPC_POOL_GUARD, count % 2 ? Locations::pool_guard_b : Locations::pool_guard_a);
        if (Creature* guard = Resolve(opponent))
            guard->AI()->AttackStart(p);
    }
    void SetData(std::uint32_t type, std::uint32_t) override
    {
        if (type != DATA_POOL_DEFEATED || mode != POOL || stopped)
            return;
        Player* p = Owner();
        Creature* guard = Resolve(opponent);
        if (!p || !Safe(p) || !guard || guard->IsAlive() || !Owned(guard, p))
            return;
        opponent.Clear();
        Credit(p, QUEST_POOLS, CREDIT_POOL_GUARD, 4);
        NextPoolGuardian();
    }
    void Treat(Player* p, Creature* patient)
    {
        if (mode != PATIENT || stopped || treating || !Owned(me, p) || !Owned(patient, p) ||
            patient->GetGUID() != leza || !Safe(p) || !Interact(p, patient) || !p->HasItemCount(ITEM_ANTIDOTE, 1) ||
            !Alive(leza) || !Alive(nala) || LifeFinished(p))
            return;
        Creature* nurse = Resolve(nala);
        if (!nurse || nurse->GetDistance(patient) > 7.0f)
            return;
        treating = true;
        nurse->CastSpell(patient, SPELL_HEAL_VISUAL, true);
        Whisper(nala, "Let it settle. Do not leave her before we know how she responds.");
        events.ScheduleEvent(TREATED, 5000ms);
    }
    void AdvanceLife(Player* p)
    {
        if (birth.Current() == BirthSequence::Beginning)
        {
            if (!Alive(leza) || !Alive(nala) || !Alive(dezco))
            {
                Stop("A scene actor is missing. Use the medical tent to restart.");
                return;
            }
            redhorn = Child(NPC_REDHORN, Locations::redhorn);
            cloudhoof = Child(NPC_CLOUDHOOF, Locations::cloudhoof);
            if (stopped || !Alive(redhorn) || !Alive(cloudhoof))
                return;
            birth.Advance(BirthSequence::Delivered);
            Whisper(nala, "Two boys. Redhorn and Cloudhoof are here. Keep them warm while I tend their mother.");
            events.ScheduleEvent(STEP, 15000ms);
        }
        else if (birth.Current() == BirthSequence::Delivered)
        {
            if (!Alive(leza) || !Alive(nala) || !Alive(dezco))
            {
                Stop("A scene actor is missing. Use the medical tent to restart.");
                return;
            }
            Creature* mother = Resolve(leza);
            if (Creature* father = Resolve(dezco))
                father->CastSpell(mother, SPELL_HEAL_VISUAL, true);
            Whisper(leza, "Stay with the boys. Do not let this be the last thing our journey gives them.");
            events.ScheduleEvent(MOTHER_LOST, 5000ms);
        }
        else if (birth.Current() == BirthSequence::MotherLost)
        {
            if (!Alive(redhorn) || !Alive(cloudhoof) || !Alive(nala) || !Alive(dezco))
            {
                Stop("The scene was interrupted. Use the medical tent to restart.");
                return;
            }
            birth.Advance(BirthSequence::TwinsStable);
            Whisper(nala, "Leza is gone. Both boys are breathing, Dezco. They still need us.");
            events.ScheduleEvent(STEP, 15000ms);
        }
        else if (birth.Current() == BirthSequence::TwinsStable)
        {
            Creature* mother = Resolve(leza);
            if (!mother || !Alive(nala) || !Alive(dezco) ||
                !birth.CanFinish(!mother->IsAlive(), Alive(redhorn), Alive(cloudhoof)))
            {
                Stop("The scene was interrupted. Use the medical tent to restart.");
                return;
            }
            Whisper(dezco,
                    "I cannot bring her back. I can keep her sons safe. We will remember her and care for the living.");
            birth.Advance(BirthSequence::Concluded);
            Credit(p, QUEST_LIFE, CREDIT_LIFE);
            Stop("Return to Dezco when you are ready. Nala can present the twins again afterward.");
        }
    }
    void UpdateAI(std::uint32_t diff) override
    {
        if (stopped)
            return;
        events.Update(diff);
        while (std::uint32_t event = events.ExecuteEvent())
        {
            Player* p = Owner();
            if (!p || !Safe(p))
            {
                Stop("This attempt has ended. Speak to the quest contact to try again.");
                return;
            }
            if (event == TIMEOUT)
            {
                Stop("The scene has timed out. Its starting contact can prepare another attempt.");
                return;
            }
            if (event == CHECK)
                events.ScheduleEvent(CHECK, 500ms);
            else if (event == POOL_HELP && mode == POOL)
            {
                if (Creature* guide = Resolve(poolGuide))
                    guide->CastSpell(p, SPELL_POOL_HEAL, true);
                events.ScheduleEvent(POOL_HELP, 3s);
            }
            else if (event == TREATED && mode == PATIENT)
            {
                if (!Alive(leza) || !Alive(nala) || !p->HasItemCount(ITEM_ANTIDOTE, 1))
                {
                    Stop("The treatment was interrupted. Replace your antidote and ask Nala to prepare Leza again.");
                    return;
                }
                Whisper(leza, "The fever has eased. Thank you for staying.");
                p->DestroyItemCount(ITEM_ANTIDOTE, 1, true);
                Credit(p, QUEST_POISON, CREDIT_TREATED);
                Stop();
            }
            else if (event == MOTHER_LOST && mode == LIFE && birth.Current() == BirthSequence::Delivered)
            {
                Creature* mother = Resolve(leza);
                Creature* nurse = Resolve(nala);
                if (!mother || !mother->IsAlive() || !nurse || !nurse->IsAlive())
                {
                    Stop("The scene was interrupted. Use the medical tent to restart.");
                    return;
                }
                Unit::Kill(nurse, mother, false);
                birth.Advance(BirthSequence::MotherLost);
                events.ScheduleEvent(STEP, 12000ms);
            }
            else if (event == STEP && mode == LIFE)
                AdvanceLife(p);
            else if (event == STEP && mode == VIGIL)
            {
                if (!Alive(dezco))
                {
                    Stop("The vigil has ended. Return to the memorial to begin again.");
                    return;
                }
                Whisper(dezco, "She showed us a way forward. We can take the next step without forgetting her.");
                Credit(p, QUEST_VIGIL, CREDIT_VIGIL);
                Stop("The vigil is complete. Dezco has Leza's memorial totem for you.");
            }
        }
    }
};

void Start(Player* p, Mode mode, Point const& point)
{
    std::uint32_t quest = mode == POOL ? QUEST_POOLS : mode == PATIENT ? QUEST_POISON :
                         mode == LIFE ? QUEST_LIFE : QUEST_VIGIL;
    if (!Enabled() || !Active(p, quest) || !p->IsAlive() || p->IsInCombat() || p->IsMounted() || p->IsFlying() ||
        p->IsInFlight() || ((mode == PATIENT || mode == LIFE) && LifeFinished(p)))
        return;
    if (Creature* existing = FindOwned(p, NPC_SCENE))
    {
        auto* ai = dynamic_cast<npc_bs_c03_sceneAI*>(existing->AI());
        if (ai && !ai->stopped)
        {
            Tell(p, "Your scene is already running. Stay nearby, or let it end before starting another.");
            return;
        }
    }
    State(p);
    if (Creature* c = Summon(p, NPC_SCENE, point, mode == POOL ? 305000 : 125000))
        if (auto* ai = dynamic_cast<npc_bs_c03_sceneAI*>(c->AI()))
            ai->Begin(mode);
}

bool Contact(std::uint32_t entry)
{
    return entry == NPC_DEZCO || entry == NPC_NALA || entry == NPC_KANG || entry == NPC_KOR || entry == NPC_MEI ||
           entry == NPC_POOL_GUIDE || Index(RefugeeEntries, entry) < RefugeeEntries.size();
}
void Menu(Player* p, Creature* c)
{
    if (!Interact(p, c) || !Contact(c->GetEntry()))
        return;
    std::uint32_t entry = c->GetEntry();
    if (entry == NPC_DEZCO || entry == NPC_NALA || entry == NPC_KANG)
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Replace my active quest supplies.", Sender, RECOVER);
    if (entry == NPC_NALA)
    {
        if (Active(p, QUEST_LIFE))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "I am ready to stand by the medical tent.", Sender, BEGIN_LIFE);
        if (LifeFinished(p))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Let me see Redhorn and Cloudhoof safely in their cots.", Sender,
                             PRESENT_TWINS);
    }
    if (entry == NPC_KANG && Active(p, QUEST_HERBS))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Prepare the second remedy from my lotus leaves.", Sender,
                         PREPARE_REMEDY);
    if (entry == NPC_KANG && Active(p, QUEST_STEW))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Prepare stew from my skitterer meat.", Sender, COOK_STEW);
    if (entry == NPC_POOL_GUIDE && Active(p, QUEST_POOLS))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "I will help break the guardians' hold on the pool.", Sender, BEGIN_POOL);
    if (entry == NPC_DEZCO)
    {
        if (Active(p, QUEST_VIGIL))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "I will join you at Leza's memorial.", Sender, BEGIN_VIGIL);
        if (Active(p, QUEST_LIVING) && !RemainingBundles(DeliveryCounts(p)))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT,
                             "The food is delivered. What comes next for the boys and the expedition?", Sender,
                             MAKE_PROMISE);
    }
    if (Index(RefugeeEntries, entry) < RefugeeEntries.size() && Active(p, QUEST_LIVING))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Deliver one food bundle to this group.", Sender, DELIVER_FOOD);
}
bool Select(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action)
{
    if (sender != Sender)
        return false;
    if (!Interact(p, c) || !Contact(c->GetEntry()))
        return true;
    ClearGossipMenuFor(p);
    CloseGossipMenuFor(p);
    std::uint32_t entry = c->GetEntry();
    if (action == RECOVER && (entry == NPC_DEZCO || entry == NPC_NALA || entry == NPC_KANG))
        Recover(p);
    else if (action == PREPARE_PATIENT && entry == NPC_NALA)
    {
        Recover(p);
        if (p->HasItemCount(ITEM_ANTIDOTE, 1))
            Start(p, PATIENT, Locations::tent);
    }
    else if (action == PREPARE_REMEDY && entry == NPC_KANG && Active(p, QUEST_HERBS) &&
             p->HasItemCount(ITEM_LEAVES, 12))
    {
        c->Whisper("This tea can lend her strength. Keep it warm while I make enough for Nala to use.", LANG_UNIVERSAL,
                   p);
        Credit(p, QUEST_HERBS, CREDIT_REMEDY);
    }
    else if (action == COMPARE_ORDERS && entry == NPC_DEZCO && Active(p, QUEST_AGENDA) &&
             p->HasItemCount(ITEM_ORDERS, 1) && HasCredit(p, QUEST_AGENDA, CREDIT_DEVICE))
    {
        c->Whisper("The buyer's mark matches. The ward is drawing life into the relic instead of healing the pool.",
                   LANG_UNIVERSAL, p);
        Credit(p, QUEST_AGENDA, CREDIT_AGENDA);
    }
    else if (action == MAKE_PROMISE && entry == NPC_DEZCO && Active(p, QUEST_LIVING) &&
             !RemainingBundles(DeliveryCounts(p)))
    {
        c->Whisper("Redhorn and Cloudhoof will grow up knowing Leza's name. The expedition will help the people she "
                   "hoped to find.",
                   LANG_UNIVERSAL, p);
        Credit(p, QUEST_LIVING, CREDIT_PROMISE);
    }
    else if (action == BEGIN_LIFE && entry == NPC_NALA)
        Start(p, LIFE, Locations::tent);
    else if (action == BEGIN_VIGIL && entry == NPC_DEZCO)
        Start(p, VIGIL, Locations::memorial);
    else if (action == COOK_STEW && entry == NPC_KANG && Active(p, QUEST_STEW) &&
             p->HasItemCount(ITEM_MEAT, 8))
    {
        c->Whisper("The families can eat while we work. I will keep this broth warm for them.", LANG_UNIVERSAL, p);
        Credit(p, QUEST_STEW, CREDIT_STEW);
    }
    else if (action == BEGIN_POOL && entry == NPC_POOL_GUIDE)
        Start(p, POOL, Locations::pool_guide);
    else if (action == PRESENT_TWINS && entry == NPC_NALA)
        PresentTwins(p);
    else if (action == DELIVER_FOOD)
        Deliver(p, Index(RefugeeEntries, entry));
    return true;
}

struct npc_bs_c03_contactAI : ScriptedAI
{
    explicit npc_bs_c03_contactAI(Creature* c) : ScriptedAI(c) {}
    EventMap events;
    void Flags()
    {
        if (Enabled())
            me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
        else
            me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
    }
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        Flags();
        events.Reset();
        events.ScheduleEvent(CHECK, 2000ms);
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == CHECK)
        {
            Flags();
            events.ScheduleEvent(CHECK, 2000ms);
        }
    }
};
class npc_bs_c03_contact : public CreatureScript
{
public:
    npc_bs_c03_contact() : CreatureScript("npc_bs_c03_contact") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c03_contactAI(c); }
    bool OnGossipHello(Player* p, Creature* c) override
    {
        if (!Interact(p, c))
            return true;
        ClearGossipMenuFor(p);
        p->PrepareQuestMenu(c->GetGUID());
        Menu(p, c);
        std::uint32_t greeting = BrokenSealChapter4Gossip(p, c);
        if (c->GetEntry() == NPC_NALA && LifeFinished(p))
            greeting = TEXT_NALA_TWINS;
        SendGossipMenuFor(p, greeting, c->GetGUID());
        return true;
    }
    bool OnGossipSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action) override
    {
        if (!BrokenSealChapter4Select(p, c, sender, action))
            Select(p, c, sender, action);
        return true;
    }
};
class npc_bs_c03_actor : public CreatureScript
{
public:
    npc_bs_c03_actor() : CreatureScript("npc_bs_c03_actor") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c03_actorAI(c); }
};
class npc_bs_c03_scene : public CreatureScript
{
public:
    npc_bs_c03_scene() : CreatureScript("npc_bs_c03_scene") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c03_sceneAI(c); }
};
struct npc_bs_c03_corpseAI : ScriptedAI
{
    explicit npc_bs_c03_corpseAI(Creature* c) : ScriptedAI(c) {}
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        me->SetStandState(UNIT_STAND_STATE_DEAD);
    }
};
class npc_bs_c03_corpse : public CreatureScript
{
public:
    npc_bs_c03_corpse() : CreatureScript("npc_bs_c03_corpse") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c03_corpseAI(c); }
};

struct npc_bs_c03_enemyAI : ScriptedAI
{
    explicit npc_bs_c03_enemyAI(Creature* c) : ScriptedAI(c) {}
    EventMap events;
    bool CanAIAttack(Unit const*) const override { return Enabled(); }
    void Reset() override
    {
        me->SetReactState(REACT_AGGRESSIVE);
        events.Reset();
        events.ScheduleEvent(COMBAT_SPELL, 5000ms);
    }
    void UpdateAI(std::uint32_t diff) override
    {
        if (!Enabled() || !UpdateVictim())
            return;
        events.Update(diff);
        if (events.ExecuteEvent() == COMBAT_SPELL)
        {
            if (!me->HasUnitState(UNIT_STATE_CASTING))
                DoCastVictim(me->GetEntry() == NPC_HEXER        ? SPELL_HEX_BOLT
                             : me->GetEntry() == NPC_SKITTERER ? SPELL_POISON
                                                              : SPELL_STRIKE);
            events.ScheduleEvent(COMBAT_SPELL, 8000ms);
        }
        DoMeleeAttackIfReady();
    }
};
class npc_bs_c03_enemy : public CreatureScript
{
public:
    npc_bs_c03_enemy() : CreatureScript("npc_bs_c03_enemy") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c03_enemyAI(c); }
};

struct npc_bs_c03_pool_guardAI : ScriptedAI
{
    explicit npc_bs_c03_pool_guardAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid parent;
    EventMap events;

    void Reset() override
    {
        me->SetReactState(REACT_DEFENSIVE);
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
    bool CanAIAttack(Unit const* target) const override
    {
        Player const* p = target ? target->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
        return Enabled() && p && p->GetGUID() == owner;
    }
    void DamageTaken(Unit* attacker, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        if (!CanAIAttack(attacker))
            damage = 0;
    }
    void JustDied(Unit*) override
    {
        if (Creature* focus = ObjectAccessor::GetCreature(*me, parent))
            focus->AI()->SetData(DATA_POOL_DEFEATED, 1);
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == CHECK)
        {
            Player* p = ObjectAccessor::FindConnectedPlayer(owner);
            if (!Enabled() || !p || !p->IsAlive() || !SameWorld(p, me) ||
                !ObjectAccessor::GetCreature(*me, parent))
            {
                me->DespawnOrUnsummon();
                return;
            }
            events.ScheduleEvent(CHECK, 1s);
        }
        if (UpdateVictim())
            DoMeleeAttackIfReady();
    }
};

class npc_bs_c03_pool_guard : public CreatureScript
{
public:
    npc_bs_c03_pool_guard() : CreatureScript("npc_bs_c03_pool_guard") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c03_pool_guardAI(c); }
};

class go_bs_c03_interaction : public GameObjectScript
{
public:
    go_bs_c03_interaction() : GameObjectScript("go_bs_c03_interaction") {}
    bool OnGossipHello(Player* p, GameObject* go) override
    {
        if (!Interact(p, go))
            return true;
        std::uint32_t entry = go->GetEntry();
        if (entry == GO_TRACK && Active(p, QUEST_SEARCH))
        {
            if (p->FindNearestCreature(NPC_CHEZIN, 15.0f))
                Give(p, ITEM_ORDERS);
        }
        else if (entry == GO_TENT)
        {
            if (Active(p, QUEST_LIFE))
                Start(p, LIFE, Locations::tent);
            else if (Active(p, QUEST_POISON))
            {
                Recover(p);
                if (p->HasItemCount(ITEM_ANTIDOTE, 1))
                    Start(p, PATIENT, Locations::tent);
            }
        }
        else if (entry == GO_HEARTH && Active(p, QUEST_STEW) && p->HasItemCount(ITEM_MEAT, 8))
            Credit(p, QUEST_STEW, CREDIT_STEW);
        else if (Index(LookoutEntries, entry) < LookoutEntries.size())
            Credit(p, QUEST_BLIND, LookoutCredits[Index(LookoutEntries, entry)]);
        else if (entry == GO_HERB && Active(p, QUEST_HERBS))
        {
            auto& nodes = State(p).herbs;
            auto it = nodes.find(go->GetGUID());
            if (it != nodes.end() && getMSTimeDiff(it->second, getMSTime()) < 60000)
                Tell(p, "These leaves need a minute to regrow for you. Try another lotus patch.");
            else if (p->AddItem(ITEM_LEAVES, 1))
                nodes[go->GetGUID()] = getMSTime();
        }
        else if (entry == GO_ORDERS && Active(p, QUEST_AGENDA))
            Give(p, ITEM_ORDERS);
        else if (entry == GO_DEVICE)
            Credit(p, QUEST_AGENDA, CREDIT_DEVICE);
        else if (entry == GO_POOL && Active(p, QUEST_POOLS))
            Give(p, ITEM_SAMPLE);
        else if (entry == GO_MEMORIAL)
            Start(p, VIGIL, Locations::memorial);
        else if (Index(SupplyEntries, entry) < SupplyEntries.size())
            Deliver(p, Index(SupplyEntries, entry));
        return true;
    }
};
class item_bs_c03_antidote : public ItemScript
{
public:
    item_bs_c03_antidote() : ItemScript("item_bs_c03_antidote") {}
    bool OnUse(Player* p, Item* item, SpellCastTargets const& targets) override
    {
        p->SendEquipError(EQUIP_ERR_OK, item, nullptr);
        if (!Enabled() || !Active(p, QUEST_POISON) || LifeFinished(p))
            return true;
        Creature* patient = targets.GetUnitTarget() ? targets.GetUnitTarget()->ToCreature() : nullptr;
        if (patient && patient->GetEntry() == NPC_LEZA && Owned(patient, p))
            if (Creature* focus = ObjectAccessor::GetCreature(*patient, patient->AI()->GetGUID(DATA_PARENT)))
                if (auto* ai = dynamic_cast<npc_bs_c03_sceneAI*>(focus->AI()))
                    ai->Treat(p, patient);
        return true;
    }
};

class bs_c03_player : public PlayerScript
{
public:
    bs_c03_player()
        : PlayerScript("bs_c03_player", {PLAYERHOOK_ON_LOGOUT, PLAYERHOOK_ON_QUEST_ABANDON, PLAYERHOOK_ON_UPDATE})
    {
    }
    void OnPlayerLogout(Player* p) override { Cleanup(p); }
    void OnPlayerQuestAbandon(Player* p, std::uint32_t quest) override
    {
        if (quest >= QUEST_SEARCH && quest <= QUEST_LETTER)
            Cleanup(p);
    }
    void OnPlayerUpdate(Player* p, std::uint32_t) override
    {
        PlayerState* state = p->CustomData.Get<PlayerState>(StateKey);
        if (state && (!Enabled() || !p->IsAlive() || p->GetMapId() != 1 || p->GetZoneId() != 15 ||
                      state->phase != p->GetPhaseMask()))
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
        if (item.QuestId < QUEST_SEARCH || item.QuestId > QUEST_LETTER)
            keep.push_back(item);
    }
    menu.ClearMenu();
    for (QuestMenuItem const& item : keep)
        menu.AddMenuItem(item.QuestId, item.QuestIcon);
}
} // namespace BrokenSeal::Chapter3

std::uint32_t BrokenSealChapter3Gossip(Player* p, Creature* c)
{
    using namespace BrokenSeal::Chapter3;
    if (c->GetEntry() != NPC_DEZCO)
        return c->GetEntry();
    if (!Enabled())
    {
        FilterQuestMenu(p);
        return c->GetEntry();
    }
    Menu(p, c);
    return p->IsQuestRewarded(QUEST_C02_END) ? TEXT_DEZCO : c->GetEntry();
}
bool BrokenSealChapter3Select(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action)
{
    return BrokenSeal::Chapter3::Select(p, c, sender, action);
}
void AddBrokenSealChapter3Scripts()
{
    using namespace BrokenSeal::Chapter3;
    new npc_bs_c03_contact();
    new npc_bs_c03_actor();
    new npc_bs_c03_scene();
    new npc_bs_c03_corpse();
    new npc_bs_c03_enemy();
    new npc_bs_c03_pool_guard();
    new go_bs_c03_interaction();
    new item_bs_c03_antidote();
    new bs_c03_player();
}
