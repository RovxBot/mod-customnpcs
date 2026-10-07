/*
 * Copyright (C) mod-customNPCs contributors.
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#include "BrokenSealChapter1.h"
#include "BrokenSealChapter2Integration.h"

#include "Chat.h"
#include "Config.h"
#include "Creature.h"
#include "GameObject.h"
#include "GameObjectAI.h"
#include "Item.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "QuestDef.h"
#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "SmartAI.h"
#include "Spell.h"
#include "TemporarySummon.h"

#include <chrono>
#include <list>
#include <string_view>

namespace BrokenSeal::Chapter1
{
using namespace std::chrono_literals;
enum Data : std::int32_t
{
    DATA_OWNER = 1,
    DATA_ANCHOR = 2,
    DATA_KIND = 3,
    DATA_SHIFT_SERIAL = 4,
};

enum Action : std::int32_t
{
    ACTION_ESCORT = 1,
    ACTION_OBSERVE = 2,
    ACTION_RESET_CAPTIVE = 3,
};

enum Event : std::uint32_t
{
    EVENT_CHECK = 1,
    EVENT_TIMEOUT = 2,
    EVENT_MOVE = 3,
    EVENT_MINIMUM_WATCH = 4,
    EVENT_CLOSE_CAGE = 5,
};

enum Scene : std::uint32_t
{
    SCENE_COMMANDER = 0,
    SCENE_RECRUIT = 1,
};

enum GossipAction : std::uint32_t
{
    GOSSIP_COMPARE = 100,
    GOSSIP_SIGNAL = 101,
    GOSSIP_REPLACE_KIT = 102,
    GOSSIP_HELP = 103,
};

bool Enabled()
{
    return sConfigMgr->GetOption<bool>("ModCustomNPCs.Enable", true) &&
           sConfigMgr->GetOption<bool>("ModCustomNPCs.BrokenSeal.Chapter1.Enable", true);
}

bool Active(Player const* player, std::uint32_t quest)
{
    return player && player->GetQuestStatus(quest) == QUEST_STATUS_INCOMPLETE;
}

void Tell(Player* player, std::string_view text)
{
    ChatHandler(player->GetSession()).SendSysMessage(text);
}

bool SameWorld(Player const* player, WorldObject const* object)
{
    return player && object && player->IsInWorld() && object->IsInWorld() && player->FindMap() == object->FindMap() &&
           (player->GetPhaseMask() & object->GetPhaseMask());
}

bool CanInteract(Player const* player, WorldObject const* object)
{
    return Enabled() && SameWorld(player, object) && player->IsAlive() && !player->IsInCombat() &&
           player->IsWithinDistInMap(object, 7.0f);
}

Counts ReadCounts(Player* player, std::uint32_t quest, std::array<std::uint32_t, 3> const& credits)
{
    Counts result{};
    for (std::size_t i = 0; i < result.size(); ++i)
        result[i] = static_cast<std::uint16_t>(player->GetReqKillOrCastCurrentCount(quest, credits[i]));
    return result;
}

void CreditOnce(Player* player, std::uint32_t quest, std::uint32_t credit)
{
    if (Enabled() && Active(player, quest) && !player->GetReqKillOrCastCurrentCount(quest, credit))
        player->KilledMonsterCredit(credit);
}

bool GiveDocument(Player* player, std::uint32_t item)
{
    // The native uniqueness/bag checks also handle copies in storage.
    if (player->HasItemCount(item, 1, true))
        return true;
    return player->AddItem(item, 1);
}

void TraceWard(Player* player, GameObject* go)
{
    if (!CanInteract(player, go) || !Active(player, QUEST_WARDS))
        return;
    std::size_t index = IndexOf(WardEntries, go->GetEntry());
    if (index == DistinctCount)
        return;
    if (!player->HasItemCount(ITEM_TRACING_KIT, 1))
    {
        Tell(player, "You need Maruut's tracing kit. He can replace a lost one.");
        return;
    }
    if (NeedsDistinct(ReadCounts(player, QUEST_WARDS, WardCredits), index))
    {
        CreditOnce(player, QUEST_WARDS, WardCredits[index]);
        Tell(player, "You trace a spiral cut across the older runes.");
    }
    if (AllDistinctDone(ReadCounts(player, QUEST_WARDS, WardCredits)))
    {
        if (!GiveDocument(player, ITEM_RUBBING))
            Tell(player, "Make room for the complete rubbing, then use the kit on any ward stone again.");
    }
}

bool IsOwnedBy(Creature* creature, Player* player)
{
    TempSummon* summon = creature->ToTempSummon();
    return summon && summon->GetSummonerGUID() == player->GetGUID();
}

Creature* FindOwned(Player* player, std::uint32_t entry)
{
    std::list<Creature*> creatures;
    player->GetCreatureListWithEntryInGrid(creatures, entry, 300.0f);
    for (Creature* creature : creatures)
        if (creature->IsAlive() && IsOwnedBy(creature, player))
            return creature;
    return nullptr;
}

void CleanPersonalActors(Player* player)
{
    if (!player->IsInWorld())
        return;
    for (std::uint32_t entry : {NPC_CAPTIVE_A, NPC_CAPTIVE_B, NPC_CAPTIVE_C, NPC_SCENE})
    {
        std::list<Creature*> creatures;
        player->GetCreatureListWithEntryInGrid(creatures, entry, 400.0f);
        for (Creature* creature : creatures)
            if (entry != NPC_SCENE && creature->AI()->GetGUID(0) == player->GetGUID())
                creature->AI()->DoAction(ACTION_RESET_CAPTIVE);
            else if (IsOwnedBy(creature, player))
                creature->DespawnOrUnsummon();
    }
}

struct npc_bs_c01_captiveAI : ScriptedAI
{
    explicit npc_bs_c01_captiveAI(Creature* creature) : ScriptedAI(creature) {}
    ObjectGuid owner;
    EventMap events;
    bool started = false;
    bool paused = false;
    bool returning = false;
    bool reached = false;

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        me->SetWalk(true);
        me->SetStandState(UNIT_STAND_STATE_KNEEL);
        me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);
        owner.Clear();
        started = paused = returning = reached = false;
        events.Reset();
        events.ScheduleEvent(EVENT_CHECK, 1s);
    }
    ObjectGuid GetGUID(std::int32_t) const override
    {
        return owner;
    }
    void ReturnHome()
    {
        owner.Clear();
        started = paused = reached = false;
        returning = true;
        me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP);
        me->SetStandState(UNIT_STAND_STATE_STAND);
        Position const& home = me->GetHomePosition();
        me->GetMotionMaster()->MovePoint(2, home.GetPositionX(), home.GetPositionY(), home.GetPositionZ());
        events.Reset();
        events.ScheduleEvent(EVENT_CHECK, 1s);
    }
    void DoAction(std::int32_t action) override
    {
        if (action == ACTION_RESET_CAPTIVE)
            ReturnHome();
    }
    bool Begin(Player* p)
    {
        std::size_t index = IndexOf(CaptiveEntries, me->GetEntry());
        if (!Enabled() || !CanInteract(p, me) || !Active(p, QUEST_RESCUE) || index >= DistinctCount ||
            !NeedsDistinct(ReadCounts(p, QUEST_RESCUE, CaptiveCredits), index))
            return false;
        if (started || returning)
        {
            Tell(p, "This surveyor is already being escorted or returning to the guard post. Try another captive.");
            return false;
        }
        owner = p->GetGUID();
        started = true;
        me->SetStandState(UNIT_STAND_STATE_STAND);
        me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP);
        me->Whisper("I can walk. Stay with me until we reach the expedition camp.", LANG_UNIVERSAL, p);
        me->GetMotionMaster()->MovePoint(1, Refuge.x, Refuge.y, Refuge.z);
        events.RescheduleEvent(EVENT_TIMEOUT, 180s);
        return true;
    }
    void MovementInform(std::uint32_t type, std::uint32_t id) override
    {
        if (type != POINT_MOTION_TYPE)
            return;
        if (id == 1 && started)
            reached = me->GetDistance(Refuge.x, Refuge.y, Refuge.z) <= 3.0f;
        else if (id == 2 && returning)
        {
            returning = false;
            me->SetStandState(UNIT_STAND_STATE_KNEEL);
            if (Enabled())
                me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);
        }
    }
    void DamageTaken(Unit*, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        damage = 0;
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        while (std::uint32_t event = events.ExecuteEvent())
        {
            if (!started)
            {
                if (!returning)
                {
                    if (Enabled())
                        me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);
                    else
                        me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP);
                }
                events.ScheduleEvent(EVENT_CHECK, 1s);
                continue;
            }
            Player* p = ObjectAccessor::FindConnectedPlayer(owner);
            if (event == EVENT_TIMEOUT || !p)
            {
                ReturnHome();
                return;
            }
            SceneSafety safety{Enabled(),        Active(p, QUEST_RESCUE), p->IsAlive(),
                               SameWorld(p, me), p->IsInCombat(),         me->GetDistance(p)};
            if (!CanEscort(safety))
            {
                ReturnHome();
                return;
            }
            std::size_t index = IndexOf(CaptiveEntries, me->GetEntry());
            if (CanCreditArrival(safety, reached, me->GetDistance(Refuge.x, Refuge.y, Refuge.z)))
            {
                CreditOnce(p, QUEST_RESCUE, CaptiveCredits[index]);
                me->Whisper("We're safe. The others are still counting on you.", LANG_UNIVERSAL, p);
                owner.Clear();
                started = paused = reached = false;
                returning = true;
                events.Reset();
                me->DespawnOrUnsummon(5s, 60s);
                return;
            }
            if (safety.inCombat && !paused)
            {
                me->GetMotionMaster()->MoveIdle();
                paused = true;
            }
            else if (!safety.inCombat && paused)
            {
                paused = false;
                me->GetMotionMaster()->MovePoint(1, Refuge.x, Refuge.y, Refuge.z);
            }
            events.ScheduleEvent(EVENT_CHECK, 1s);
        }
    }
};

struct npc_bs_c01_recruitAI : ScriptedAI
{
    explicit npc_bs_c01_recruitAI(Creature* creature) : ScriptedAI(creature) {}

    EventMap events;
    std::size_t next = 1;
    std::uint32_t serial = 0;

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        me->SetWalk(true);
        events.Reset();
        events.ScheduleEvent(EVENT_MOVE, 6000ms);
    }

    std::uint32_t GetData(std::uint32_t id) const override
    {
        return id == DATA_SHIFT_SERIAL ? serial : 0;
    }

    void MovementInform(std::uint32_t type, std::uint32_t id) override
    {
        if (type != POINT_MOTION_TYPE || id != 1)
            return;
        Point const& target = RecruitPatrol[next];
        if (me->GetDistance(target.x, target.y, target.z) <= 3.0f)
        {
            ++serial;
            next = (next + 1) % RecruitPatrol.size();
        }
        events.RescheduleEvent(EVENT_MOVE, 6000ms);
    }

    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == EVENT_MOVE)
        {
            Point const& p = RecruitPatrol[next];
            me->GetMotionMaster()->MovePoint(1, p.x, p.y, p.z);
            // A failed movement still retries; it does not count a watch change.
            events.ScheduleEvent(EVENT_MOVE, 20000ms);
        }
    }
};

struct npc_bs_c01_observationAI : ScriptedAI
{
    explicit npc_bs_c01_observationAI(Creature* creature) : ScriptedAI(creature) {}

    ObjectGuid owner;
    ObjectGuid anchor;
    ObjectGuid recruit;
    EventMap events;
    std::uint32_t kind = SCENE_COMMANDER;
    std::uint32_t initialSerial = 0;
    bool minimumWatch = false;

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
    }

    void IsSummonedBy(WorldObject* summoner) override
    {
        if (summoner->ToPlayer())
            owner = summoner->GetGUID();
        me->setActive(true);
    }

    void SetGUID(ObjectGuid const& guid, std::int32_t id) override
    {
        if (id == DATA_ANCHOR)
            anchor = guid;
    }

    void SetData(std::uint32_t id, std::uint32_t value) override
    {
        if (id == DATA_KIND)
            kind = value;
    }

    void DoAction(std::int32_t action) override
    {
        if (action != ACTION_OBSERVE || owner.IsEmpty() || anchor.IsEmpty())
            return;
        if (kind == SCENE_RECRUIT)
        {
            if (Creature* actor = me->FindNearestCreature(NPC_RECRUIT, 70.0f))
            {
                recruit = actor->GetGUID();
                initialSerial = actor->AI()->GetData(DATA_SHIFT_SERIAL);
            }
            else
            {
                me->DespawnOrUnsummon();
                return;
            }
        }
        events.ScheduleEvent(EVENT_CHECK, 1000ms);
        events.ScheduleEvent(EVENT_MINIMUM_WATCH, 5000ms);
        events.ScheduleEvent(EVENT_TIMEOUT, 45000ms);
    }

    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        while (std::uint32_t event = events.ExecuteEvent())
        {
            Player* player = ObjectAccessor::GetPlayer(*me, owner);
            GameObject* point = ObjectAccessor::GetGameObject(*me, anchor);
            if (!player || !point || event == EVENT_TIMEOUT)
            {
                me->DespawnOrUnsummon();
                return;
            }
            std::uint32_t quest = kind == SCENE_COMMANDER ? QUEST_COMMANDER : QUEST_RECRUIT;
            SceneSafety safety{Enabled(),
                               Active(player, quest),
                               player->IsAlive(),
                               SameWorld(player, point),
                               player->IsInCombat(),
                               point->GetDistance(player)};
            if (!CanObserve(safety))
            {
                Tell(player, "The observation is interrupted. Return quietly to the marked point and try again.");
                me->DespawnOrUnsummon();
                return;
            }
            if (event == EVENT_MINIMUM_WATCH)
                minimumWatch = true;
            bool witnessed = kind == SCENE_COMMANDER;
            if (kind == SCENE_COMMANDER)
            {
                Creature* jarod = point->FindNearestCreature(NPC_JAROD, 70.0f);
                witnessed = jarod && jarod->IsAlive() && player->IsWithinLOSInMap(jarod);
            }
            else if (Creature* actor = ObjectAccessor::GetCreature(*me, recruit))
                witnessed = actor->IsAlive() && player->IsWithinLOSInMap(actor) &&
                            actor->AI()->GetData(DATA_SHIFT_SERIAL) != initialSerial;
            if (minimumWatch && witnessed)
            {
                CreditOnce(player, quest, kind == SCENE_COMMANDER ? CREDIT_COMMANDER : CREDIT_RECRUIT);
                Tell(player, kind == SCENE_COMMANDER ? "Jarod shifts against his restraints. He is alive. Return to "
                                                       "Ortell before the guards notice you."
                                                     : "The recruit reaches the next watch post. You have seen the "
                                                       "change. Return to Ortell to agree the signal.");
                me->DespawnOrUnsummon();
                return;
            }
            if (event == EVENT_CHECK)
                events.ScheduleEvent(EVENT_CHECK, 1000ms);
        }
    }
};

void StartObservation(Player* player, GameObject* go, std::uint32_t kind)
{
    std::uint32_t quest = kind == SCENE_COMMANDER ? QUEST_COMMANDER : QUEST_RECRUIT;
    std::uint32_t credit = kind == SCENE_COMMANDER ? CREDIT_COMMANDER : CREDIT_RECRUIT;
    if (!CanInteract(player, go) || !Active(player, quest) || player->GetReqKillOrCastCurrentCount(quest, credit) ||
        FindOwned(player, NPC_SCENE))
        return;
    if (TempSummon* observer =
            player->SummonCreature(NPC_SCENE, go->GetPosition(), TEMPSUMMON_TIMED_DESPAWN, 50000, 0, nullptr, true))
    {
        observer->AI()->SetGUID(go->GetGUID(), DATA_ANCHOR);
        observer->AI()->SetData(DATA_KIND, kind);
        observer->AI()->DoAction(ACTION_OBSERVE);
        Tell(player, "Remain at the marked point, alive and out of combat, while you observe.");
    }
}

class go_bs_c01_interaction : public GameObjectScript
{
public:
    go_bs_c01_interaction() : GameObjectScript("go_bs_c01_interaction") {}

    bool OnGossipHello(Player* player, GameObject* go) override
    {
        // Always intercept: default goober use must not consume a shared quest object.
        if (!CanInteract(player, go))
            return true;
        if (go->GetEntry() == GO_WAGON && Active(player, QUEST_WAGON))
        {
            GiveDocument(player, ITEM_LOG);
            return true;
        }
        std::size_t trail = IndexOf(TrailEntries, go->GetEntry());
        if (trail != DistinctCount && Active(player, QUEST_TRAIL))
        {
            if (NeedsDistinct(ReadCounts(player, QUEST_TRAIL, TrailCredits), trail))
            {
                CreditOnce(player, QUEST_TRAIL, TrailCredits[trail]);
                Tell(player, "The ash hides a spiral etched into the damaged tablet. You record this distinct marker.");
            }
            return true;
        }
        if (IndexOf(WardEntries, go->GetEntry()) != DistinctCount)
            TraceWard(player, go);
        else if (go->GetEntry() == GO_COVER)
            StartObservation(player, go, SCENE_COMMANDER);
        else if (go->GetEntry() == GO_DEAD_DROP)
            StartObservation(player, go, SCENE_RECRUIT);
        return true;
    }
};

class item_bs_c01_tracing_kit : public ItemScript
{
public:
    item_bs_c01_tracing_kit() : ItemScript("item_bs_c01_tracing_kit") {}

    bool OnUse(Player* player, Item* item, SpellCastTargets const& targets) override
    {
        if (item->GetEntry() == ITEM_TRACING_KIT)
        {
            player->SendEquipError(EQUIP_ERR_OK, item, nullptr);
            if (GameObject* go = targets.GetGOTarget())
                TraceWard(player, go);
            else if (Enabled() && Active(player, QUEST_WARDS))
                Tell(player, "Use the tracing kit on one of the three marked ward stones.");
        }
        return true;
    }
};

struct npc_bs_c01_contactAI : ScriptedAI
{
    explicit npc_bs_c01_contactAI(Creature* creature) : ScriptedAI(creature) {}
    EventMap events;

    void RefreshFlags()
    {
        if (me->GetEntry() == NPC_JAROD)
        {
            if (BrokenSealChapter2Available())
                me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
            else
                me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
            return;
        }
        if (Enabled())
            me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
        else
            me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
    }

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        RefreshFlags();
        events.Reset();
        events.ScheduleEvent(EVENT_CHECK, 2000ms);
    }

    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == EVENT_CHECK)
        {
            RefreshFlags();
            events.ScheduleEvent(EVENT_CHECK, 2000ms);
        }
    }
};

class npc_bs_c01_contact : public CreatureScript
{
public:
    npc_bs_c01_contact() : CreatureScript("npc_bs_c01_contact") {}
    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_bs_c01_contactAI(creature);
    }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        if (!CanInteract(player, creature))
            return true;
        ClearGossipMenuFor(player);
        BrokenSealChapter2Altar(player, creature);
        player->PrepareQuestMenu(creature->GetGUID());
        BrokenSealChapter2Gossip(player, creature);
        if (creature->GetEntry() == NPC_ORTELL)
        {
            if (Active(player, QUEST_COMPARE))
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Compare the orders with the ward rubbing.",
                                 GOSSIP_SENDER_MAIN, GOSSIP_COMPARE);
            if (Active(player, QUEST_RECRUIT) && player->GetReqKillOrCastCurrentCount(QUEST_RECRUIT, CREDIT_RECRUIT))
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "I saw the watch change. Let us agree the signal.",
                                 GOSSIP_SENDER_MAIN, GOSSIP_SIGNAL);
        }
        if (creature->GetEntry() == NPC_MARUUT && Active(player, QUEST_WARDS) &&
            !player->HasItemCount(ITEM_TRACING_KIT, 1, true))
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "I need a replacement tracing kit.", GOSSIP_SENDER_MAIN,
                             GOSSIP_REPLACE_KIT);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Where should I go next?", GOSSIP_SENDER_MAIN, GOSSIP_HELP);
        SendGossipMenuFor(player, creature->GetEntry(), creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, std::uint32_t sender, std::uint32_t action) override
    {
        if (BrokenSealChapter2Select(player, creature, sender, action))
            return true;
        if (sender != GOSSIP_SENDER_MAIN || !CanInteract(player, creature))
            return true;
        ClearGossipMenuFor(player);
        CloseGossipMenuFor(player);
        if (action == GOSSIP_COMPARE && creature->GetEntry() == NPC_ORTELL && Active(player, QUEST_COMPARE))
        {
            creature->Whisper("The spiral in the orders matches the cuts in the ward. One hand is directing both. "
                              "Find the guarded altar, but watch from cover. We need Jarod alive.",
                              LANG_UNIVERSAL, player);
            CreditOnce(player, QUEST_COMPARE, CREDIT_COMPARE);
        }
        else if (action == GOSSIP_SIGNAL && creature->GetEntry() == NPC_ORTELL && Active(player, QUEST_RECRUIT) &&
                 player->GetReqKillOrCastCurrentCount(QUEST_RECRUIT, CREDIT_RECRUIT))
        {
            creature->Whisper("Two short knocks, then a pause. If the wrong person answers, you walk away. "
                              "Do not let courage become noise.",
                              LANG_UNIVERSAL, player);
            CreditOnce(player, QUEST_RECRUIT, CREDIT_SIGNAL);
        }
        else if (action == GOSSIP_REPLACE_KIT && creature->GetEntry() == NPC_MARUUT && Active(player, QUEST_WARDS))
            GiveDocument(player, ITEM_TRACING_KIT);
        else if (action == GOSSIP_HELP)
        {
            if (Active(player, QUEST_RECRUIT))
                Tell(player, "Watch the moving recruit from Ortell's dead drop south of the concealed observation "
                             "stone, then speak to Ortell.");
            else if (Active(player, QUEST_COMMANDER))
                Tell(
                    player,
                    "Use the concealed observation stone west of Jarod's altar. Stay there quietly and out of combat.");
            else if (Active(player, QUEST_COMPARE))
                Tell(player, "Ask Ortell here in camp to compare the deposited orders and rubbing.");
            else if (Active(player, QUEST_WARDS))
                Tell(player,
                     "Trace each of the three ward stones west of the holding camp. A repeated stone does not count twice.");
            else if (Active(player, QUEST_RESCUE))
                Tell(player, "Clear the guards around Mira, Dorn and Teren, then speak to each surveyor. Stay nearby "
                             "until they reach our camp.");
            else if (Active(player, QUEST_TRAIL))
                Tell(player, "Inspect all three ash-marked trail clues. Defeat six Twilight Scouts and "
                             "recover their orders.");
            else if (Active(player, QUEST_WAGON))
                Tell(player, "Inspect the abandoned wagon beside our camp.");
            else if (player->IsQuestRewarded(QUEST_RECRUIT))
                Tell(
                    player,
                    BrokenSealChapter2Available()
                        ? "Speak to Ortell here in camp at level 25 for Signed in Blood and your place inside the cult."
                        : "The expedition is preparing your next assignment. The cult's training calls for at least "
                          "level 25.");
            else
                Tell(player, "Check the expedition's quest offers. Maruut's camp is on the eastern approach to the "
                             "Charred Vale.");
        }
        return true;
    }
};

class npc_bs_c01_captive : public CreatureScript
{
public:
    npc_bs_c01_captive() : CreatureScript("npc_bs_c01_captive") {}
    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_bs_c01_captiveAI(creature);
    }
    bool OnGossipHello(Player* p, Creature* c) override
    {
        if (!CanInteract(p, c))
            return true;
        ClearGossipMenuFor(p);
        if (Active(p, QUEST_RESCUE))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Stand up. I will escort you to the expedition camp.",
                             GOSSIP_SENDER_MAIN, ACTION_ESCORT);
        SendGossipMenuFor(p, c->GetEntry(), c->GetGUID());
        return true;
    }
    bool OnGossipSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action) override
    {
        CloseGossipMenuFor(p);
        if (sender == GOSSIP_SENDER_MAIN && action == ACTION_ESCORT)
            if (auto* ai = dynamic_cast<npc_bs_c01_captiveAI*>(c->AI()))
                ai->Begin(p);
        return true;
    }
};

class npc_bs_c01_recruit : public CreatureScript
{
public:
    npc_bs_c01_recruit() : CreatureScript("npc_bs_c01_recruit") {}
    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_bs_c01_recruitAI(creature);
    }
};

class npc_bs_c01_observation : public CreatureScript
{
public:
    npc_bs_c01_observation() : CreatureScript("npc_bs_c01_observation") {}
    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_bs_c01_observationAI(creature);
    }
};

// Keep Chapter 1's native SmartAI spells while recognizing a later personal cult disguise.
struct npc_bs_c01_cultAI : SmartAI
{
    explicit npc_bs_c01_cultAI(Creature* creature) : SmartAI(creature) {}
    bool CanAIAttack(Unit const* unit) const override
    {
        return !BrokenSealChapter2AvoidCombat(unit) && SmartAI::CanAIAttack(unit);
    }
};

class npc_bs_c01_cult : public CreatureScript
{
public:
    npc_bs_c01_cult() : CreatureScript("npc_bs_c01_cult") {}
    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_bs_c01_cultAI(creature);
    }
};

class bs_c01_player : public PlayerScript
{
public:
    bs_c01_player() : PlayerScript("bs_c01_player", {PLAYERHOOK_ON_LOGOUT, PLAYERHOOK_ON_QUEST_ABANDON}) {}

    void OnPlayerLogout(Player* player) override
    {
        CleanPersonalActors(player);
    }

    void OnPlayerQuestAbandon(Player* player, std::uint32_t quest) override
    {
        if (quest >= QUEST_COMMISSION_A && quest <= QUEST_RECRUIT)
            CleanPersonalActors(player);
    }
};
} // namespace BrokenSeal::Chapter1

void AddBrokenSealChapter1Scripts()
{
    using namespace BrokenSeal::Chapter1;
    new npc_bs_c01_contact();
    new npc_bs_c01_captive();
    new npc_bs_c01_recruit();
    new npc_bs_c01_observation();
    new go_bs_c01_interaction();
    new item_bs_c01_tracing_kit();
    new npc_bs_c01_cult();
    new bs_c01_player();
}
