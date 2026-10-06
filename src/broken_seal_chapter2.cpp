/*
 * Copyright (C) mod-customNPCs contributors.
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#include "BrokenSealChapter2.h"
#include "BrokenSealChapter2Integration.h"
#include "BrokenSealChapter3Integration.h"
#include "Chat.h"
#include "Config.h"
#include "Creature.h"
#include "GameObject.h"
#include "Group.h"
#include "Item.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "Random.h"
#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"
#include "Spell.h"
#include "SpellAuras.h"
#include "TemporarySummon.h"

#include <algorithm>
#include <chrono>
#include <list>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

namespace BrokenSeal::Chapter2
{
using namespace std::chrono_literals;
constexpr std::uint32_t Sender = 202;
enum Data : std::uint32_t
{
    DATA_PARENT = 1,
    DATA_ROLE,
    DATA_KILLED,
    DATA_DISTRACT,
    DATA_SAVED,
    DATA_COMMAND
};
enum Mode : std::uint32_t
{
    NONE,
    RECRUIT,
    SUPPLICANTS,
    COURSE,
    MENTAL,
    DOG,
    GRUDGE,
    DISCORD,
    GARNOTH,
    OKROG,
    RESTRAINT,
    SPEECH,
    RIOT
};
enum Event : std::uint32_t
{
    CHECK = 1,
    TIMEOUT,
    PROMPT,
    ANSWER_TIMEOUT,
    NEXT_WAVE,
    COMBAT_CAST,
    POUNCE_READY
};
enum Action : std::uint32_t
{
    RECOVER = 1,
    DISGUISE,
    IDENTITY,
    INTRO_MYLVA,
    INTRO_DEVORAN,
    START_SUPPLICANTS,
    START_GRUDGE,
    FINAL_INSTRUCTION,
    SUMMON_JAROD,
    START_RESTRAINT,
    START_RIOT,
    QUESTION = 50,
    DISTRACT_GUARD,
    HOUND_ATTACK,
    HOUND_POUNCE,
    HOUND_RETURN,
    HOUND_FEED,
    CANCEL_TRIAL,
};

struct PlayerState : DataMap::Base
{
    bool carrying = false;
    std::uint32_t phase = 0;
    bool disguise = false;
    bool fireForm = false;
    std::unordered_map<ObjectGuid, std::uint32_t> flowers;
};
constexpr char StateKey[] = "mod-customnpcs.broken-seal.chapter2";
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
           sObjectMgr->GetQuestTemplate(QUEST_SIGNED);
}

bool Active(Player const* p, std::uint32_t q)
{
    return p && p->GetQuestStatus(q) == QUEST_STATUS_INCOMPLETE;
}
bool Held(Player const* p, std::uint32_t q)
{
    return p && (p->GetQuestStatus(q) == QUEST_STATUS_INCOMPLETE || p->GetQuestStatus(q) == QUEST_STATUS_COMPLETE);
}

void Tell(Player* p, std::string_view message)
{
    ChatHandler(p->GetSession()).SendSysMessage(message);
}

bool SameWorld(Player const* p, WorldObject const* object)
{
    return p && object && p->IsInWorld() && object->IsInWorld() && p->FindMap() == object->FindMap() &&
           (p->GetPhaseMask() & object->GetPhaseMask());
}

bool Interact(Player const* p, WorldObject const* object, bool combat = false)
{
    return Enabled() && SameWorld(p, object) && p->IsAlive() && (combat || !p->IsInCombat()) &&
           p->IsWithinDistInMap(object, 7.0f);
}

bool InVale(Player const* p)
{
    return p && p->GetMapId() == 1 &&
           p->GetDistance(Locations::condenna.x, Locations::condenna.y, Locations::condenna.z) < 550.0f;
}

bool CoverAllowed(Player const* p)
{
    return p && p->IsQuestRewarded(QUEST_SIGNED) && !p->IsQuestRewarded(QUEST_RIOT);
}

bool Covered(Player const* p)
{
    return p && p->HasAura(SPELL_DISGUISE);
}

bool Give(Player* p, std::uint32_t item)
{
    return p->HasItemCount(item, 1, true) || p->AddItem(item, 1);
}

void Credit(Player* p, std::uint32_t quest, std::uint32_t credit, std::uint32_t maximum = 1)
{
    if (Enabled() && Active(p, quest) && p->GetReqKillOrCastCurrentCount(quest, credit) < maximum)
        p->KilledMonsterCredit(credit);
}

bool HasCredit(Player* p, std::uint32_t q, std::uint32_t credit, std::uint32_t count = 1)
{
    return p->GetReqKillOrCastCurrentCount(q, credit) >= count;
}

bool Owned(Creature const* c, Player const* p)
{
    TempSummon const* summon = c->ToTempSummon();
    return summon && summon->GetSummonerGUID() == p->GetGUID();
}

Creature* FindOwned(Player* p, std::uint32_t entry)
{
    std::list<Creature*> list;
    p->GetCreatureListWithEntryInGrid(list, entry, 600.0f);
    for (Creature* c : list)
        if (c->IsAlive() && Owned(c, p))
            return c;
    return nullptr;
}

Creature* Summon(Player* p, std::uint32_t entry, Point const& point, std::uint32_t duration = 300000)
{
    return p->SummonCreature(entry, Position(point.x, point.y, point.z, point.orientation), TEMPSUMMON_TIMED_DESPAWN,
                             duration, 0, nullptr, true);
}

void ClearForms(Player* p)
{
    PlayerState* state = p->CustomData.Get<PlayerState>(StateKey);
    if (!state)
        return;
    if (state->disguise)
        p->RemoveAurasDueToSpell(SPELL_DISGUISE);
    if (state->fireForm)
        p->RemoveAurasDueToSpell(SPELL_FIRE_FORM);
    state->disguise = false;
    state->fireForm = false;
    state->carrying = false;
}

void Cleanup(Player* p)
{
    if (p->IsInWorld())
        for (std::uint32_t entry : PersonalEntries)
        {
            std::list<Creature*> list;
            p->GetCreatureListWithEntryInGrid(list, entry, 600.0f);
            for (Creature* c : list)
                if (Owned(c, p))
                    c->DespawnOrUnsummon();
        }
    ClearForms(p);
    p->CustomData.Erase(StateKey);
}

void ApplyCover(Player* p)
{
    if (!Enabled() || !CoverAllowed(p) || !InVale(p) || !p->IsAlive() || p->IsInCombat())
        return;
    if (Aura* aura = p->AddAura(SPELL_DISGUISE, p))
    {
        aura->SetMaxDuration(600000);
        aura->SetDuration(600000);
        State(p).disguise = true;
        Tell(p, "Your papers and cult robes pass a casual inspection. Smolderos sees through the disguise.");
    }
}

void Recover(Player* p)
{
    for (QuestSupply const& supply : Supplies)
        if (Held(p, supply.quest))
            for (std::uint32_t item : supply.items)
                if (item && (item != ITEM_NOTES || HasCredit(p, QUEST_WRITING, CREDIT_OKROG)))
                    Give(p, item);
    if (CoverAllowed(p))
        Give(p, ITEM_IDENTITY);
}

std::uint32_t QuestFor(Mode mode)
{
    switch (mode)
    {
    case RECRUIT:
        return QUEST_SIGNED;
    case SUPPLICANTS:
        return QUEST_WASTE;
    case COURSE:
        return QUEST_AGILITY;
    case MENTAL:
        return QUEST_MENTAL;
    case DOG:
        return QUEST_DOG;
    case GRUDGE:
        return QUEST_GRUDGE;
    case DISCORD:
        return QUEST_DISCORD;
    case GARNOTH:
        return QUEST_GREATER;
    case OKROG:
        return QUEST_WRITING;
    case RESTRAINT:
    case RIOT:
        return QUEST_RIOT;
    case SPEECH:
        return QUEST_SPEECH;
    default:
        return 0;
    }
}

bool CombatTrial(Mode m)
{
    return m == GRUDGE || m == DISCORD || m == GARNOTH || m == OKROG || m == RESTRAINT || m == RIOT;
}

struct npc_bs_c02_sceneAI;
void Start(Player* p, Mode mode, Point const& location);

struct npc_bs_c02_actorAI : ScriptedAI
{
    explicit npc_bs_c02_actorAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid parent;
    EventMap events;
    std::uint32_t role = 0;
    bool arrived = false;

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
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
    void SetData(std::uint32_t type, std::uint32_t value) override
    {
        if (type == DATA_ROLE)
            role = value;
    }
    std::uint32_t GetData(std::uint32_t type) const override { return type == DATA_ROLE ? role : arrived; }
    bool CanAIAttack(Unit const* target) const override
    {
        Creature const* c = target ? target->ToCreature() : nullptr;
        return me->GetEntry() == NPC_HOUND && c && c->ToTempSummon() && c->ToTempSummon()->GetSummonerGUID() == owner &&
               c->AI()->GetGUID(DATA_PARENT) == parent;
    }
    void AttackStart(Unit* target) override
    {
        if (!CanAIAttack(target))
            return;
        me->SetReactState(REACT_DEFENSIVE);
        ScriptedAI::AttackStart(target);
    }
    void DamageTaken(Unit* attacker, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        if (!attacker || !CanAIAttack(attacker))
            damage = 0;
        else
            me->SetReactState(REACT_DEFENSIVE);
    }
    void MovementInform(std::uint32_t type, std::uint32_t) override
    {
        if (type == POINT_MOTION_TYPE)
            arrived = true;
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == CHECK)
        {
            Player* p = ObjectAccessor::GetPlayer(*me, owner);
            if (!p || !Enabled() || !p->IsAlive() || !SameWorld(p, me) || me->GetDistance(p) > 100.0f ||
                (!parent.IsEmpty() && !ObjectAccessor::GetCreature(*me, parent)))
            {
                me->DespawnOrUnsummon();
                return;
            }
            events.ScheduleEvent(CHECK, 1000ms);
        }
        if (UpdateVictim())
            DoMeleeAttackIfReady();
    }
};

struct npc_bs_c02_enemyAI : ScriptedAI
{
    explicit npc_bs_c02_enemyAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    ObjectGuid parent;
    EventMap events;
    std::uint32_t role = 0;

    void Reset() override
    {
        me->SetReactState(me->ToTempSummon() ? REACT_PASSIVE : REACT_AGGRESSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 1000ms);
        events.ScheduleEvent(COMBAT_CAST, 6000ms);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        if (summoner->ToPlayer())
            owner = summoner->GetGUID();
        me->SetReactState(REACT_PASSIVE);
        me->setActive(true);
        if (me->GetEntry() == NPC_KARRGONN)
        {
            me->SetFaction(35);
            me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);
        }
    }
    void SetGUID(ObjectGuid const& guid, std::int32_t type) override
    {
        if (type == DATA_PARENT)
            parent = guid;
    }
    ObjectGuid GetGUID(std::int32_t type) const override { return type == DATA_PARENT ? parent : owner; }
    void SetData(std::uint32_t type, std::uint32_t value) override
    {
        if (type == DATA_ROLE)
            role = value;
    }
    bool CanAIAttack(Unit const* unit) const override
    {
        if (!Enabled())
            return false;
        if (owner.IsEmpty())
        {
            // These guards belong only to this chapter; no stock factions are changed.
            return (me->GetEntry() != NPC_GUARD && me->GetEntry() != NPC_SCOUT) || !BrokenSealChapter2AvoidCombat(unit);
        }
        if (Player const* p = unit->GetCharmerOrOwnerPlayerOrPlayerItself())
            return p->GetGUID() == owner;
        Creature const* c = unit->ToCreature();
        return c && c->GetEntry() == NPC_HOUND && c->ToTempSummon() && c->ToTempSummon()->GetSummonerGUID() == owner;
    }
    void AttackStart(Unit* target) override
    {
        if (!target || !CanAIAttack(target) || me->HasUnitFlag(UNIT_FLAG_NON_ATTACKABLE))
            return;
        me->SetReactState(REACT_DEFENSIVE);
        ScriptedAI::AttackStart(target);
    }
    void DamageTaken(Unit* attacker, std::uint32_t& damage, DamageEffectType, SpellSchoolMask) override
    {
        if (!Enabled() || (!owner.IsEmpty() && (!attacker || !CanAIAttack(attacker))))
            damage = 0;
        else if (!owner.IsEmpty())
            me->SetReactState(REACT_DEFENSIVE);
    }
    void JustDied(Unit* killer) override
    {
        if (!owner.IsEmpty())
        {
            if (Creature* focus = ObjectAccessor::GetCreature(*me, parent))
                focus->AI()->SetData(DATA_KILLED, role);
            me->DespawnOrUnsummon(2000ms);
            return;
        }
        Player* p = me->GetLootRecipient();
        if (!p && killer)
            p = killer->GetCharmerOrOwnerPlayerOrPlayerItself();
        if (!p || !Enabled())
            return;
        auto grant = [this](Player* member)
        {
            if (!member || !member->IsAlive() || !SameWorld(member, me) || !member->IsAtGroupRewardDistance(me))
                return;
            if (me->GetEntry() == NPC_FIRE && Covered(member))
                Credit(member, QUEST_FIRE, CREDIT_FIRE, 8);
            else if (me->GetEntry() == NPC_FAILED && Covered(member))
                Credit(member, QUEST_MERCY, CREDIT_MERCY, 5);
            else if (me->GetEntry() == NPC_HORRORGUARD)
                Credit(member, QUEST_TERRITORY, CREDIT_TERRITORY, 10);
        };
        if (Group* group = p->GetGroup())
            for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
                grant(ref->GetSource());
        else
            grant(p);
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        while (std::uint32_t event = events.ExecuteEvent())
        {
            if (event == CHECK)
            {
                if (!owner.IsEmpty())
                {
                    Player* p = ObjectAccessor::GetPlayer(*me, owner);
                    if (!p || !Enabled() || !p->IsAlive() || !SameWorld(p, me) || me->GetDistance(p) > 100.0f ||
                        !ObjectAccessor::GetCreature(*me, parent))
                    {
                        me->DespawnOrUnsummon();
                        return;
                    }
                }
                events.ScheduleEvent(CHECK, 1000ms);
            }
            else if (event == COMBAT_CAST)
            {
                if (me->GetVictim())
                    DoCastVictim(me->GetEntry() == NPC_FIRE ? SPELL_FIREBALL : SPELL_STRIKE);
                events.ScheduleEvent(COMBAT_CAST, 7000ms);
            }
        }
        if (Enabled() && UpdateVictim())
            DoMeleeAttackIfReady();
    }
};

struct npc_bs_c02_sceneAI : ScriptedAI
{
    explicit npc_bs_c02_sceneAI(Creature* c) : ScriptedAI(c) {}
    ObjectGuid owner;
    EventMap events;
    Mode mode = NONE;
    std::vector<ObjectGuid> children;
    ObjectGuid hound;
    ObjectGuid opponent;
    ObjectGuid jarod;
    AnswerOffer offer;
    std::uint32_t question = 0;
    std::uint32_t courseStep = 0;
    std::uint32_t escapeStep = 0;
    std::uint32_t kills = 0;
    std::uint32_t wave = 0;
    bool distracted = false;
    bool petRound = false;
    bool houndEngaged = false;
    bool pounceReady = true;
    std::uint32_t offeredAt = 0;
    std::uint32_t startedAt = 0;
    bool moving = false;
    bool waveActive = false;
    bool stopped = false;

    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 500ms);
        events.ScheduleEvent(TIMEOUT, 300000ms);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        if (summoner->ToPlayer())
            owner = summoner->GetGUID();
        me->setActive(true);
    }
    std::uint32_t GetData(std::uint32_t type) const override { return type == DATA_ROLE ? mode : courseStep; }
    Creature* Resolve(ObjectGuid const& guid) { return ObjectAccessor::GetCreature(*me, guid); }
    Player* Owner() { return ObjectAccessor::GetPlayer(*me, owner); }

    Creature* Child(std::uint32_t entry, Point const& point, std::uint32_t role)
    {
        Player* p = Owner();
        if (!p)
            return nullptr;
        if (Creature* c = Summon(p, entry, point, mode == RIOT ? 485000 : 305000))
        {
            c->AI()->SetGUID(me->GetGUID(), DATA_PARENT);
            c->AI()->SetData(DATA_ROLE, role);
            children.push_back(c->GetGUID());
            return c;
        }
        Stop("The trial could not prepare its actors. Use the starting contact to retry.");
        return nullptr;
    }

    void Stop(std::string_view reason = {})
    {
        if (stopped)
            return;
        stopped = true;
        offer.Cancel();
        events.Reset();
        if (Player* p = Owner())
        {
            if (!reason.empty())
                Tell(p, reason);
            if (mode == GARNOTH)
            {
                p->RemoveAurasDueToSpell(SPELL_FIRE_FORM);
                State(p).fireForm = false;
            }
            CloseGossipMenuFor(p);
        }
        for (ObjectGuid const& guid : children)
            if (Creature* c = Resolve(guid))
                c->DespawnOrUnsummon(1000ms);
        me->DespawnOrUnsummon(1000ms);
    }

    bool Safe(Player* p)
    {
        WorldObject* anchor = me;
        if (mode == RIOT)
            if (Creature* c = Resolve(jarod))
                anchor = c;
        TrialSafety s{Enabled(),
                      Active(p, QuestFor(mode)),
                      p && p->IsAlive(),
                      SameWorld(p, me),
                      p && p->IsInCombat(),
                      p && p->IsMounted(),
                      p && (p->IsFlying() || p->IsInFlight()),
                      p ? anchor->GetDistance(p) : 999.0f};
        bool requiresCover = mode != RECRUIT && mode != RESTRAINT && mode != RIOT;
        if (requiresCover && !Covered(p))
            return false;
        if (mode == GARNOTH && p && (!p->HasAura(SPELL_FIRE_FORM) || p->GetDisplayId() != FireDisplay))
            return false;
        return CanContinue(s, CombatTrial(mode),
                           mode == COURSE                     ? 95.0f
                           : mode == MENTAL || mode == SPEECH ? 8.0f
                                                              : 90.0f);
    }

    void Begin(Mode value)
    {
        mode = value;
        startedAt = getMSTime();
        Player* p = Owner();
        if (!p)
            return;
        if (mode == RECRUIT)
        {
            if (Creature* c = Child(NPC_RECRUIT, Locations::recruit_start, 1))
            {
                c->SetWalk(true);
                c->GetMotionMaster()->MovePoint(1, Locations::recruit_hide.x, Locations::recruit_hide.y,
                                                Locations::recruit_hide.z);
                Tell(p,
                     "The recruit follows your false summons into cover. Wait for him there, then use the blackjack.");
            }
        }
        else if (mode == SUPPLICANTS)
        {
            std::array<std::uint32_t, 3> entries = {NPC_SUPPLICANT_A, NPC_SUPPLICANT_B, NPC_SUPPLICANT_C};
            std::array<std::uint32_t, 3> credits = {CREDIT_SUPPLICANT_A, CREDIT_SUPPLICANT_B, CREDIT_SUPPLICANT_C};
            std::array<Point, 3> points = {Locations::supplicant_a, Locations::supplicant_b, Locations::supplicant_c};
            for (std::size_t i = 0; i < 3; ++i)
                if (!HasCredit(p, QUEST_WASTE, credits[i]))
                    if (Creature* c = Child(entries[i], points[i], i))
                    {
                        if (Aura* aura = c->AddAura(SPELL_BURNING, c))
                        {
                            aura->SetMaxDuration(45000);
                            aura->SetDuration(45000);
                        }
                        c->HandleEmoteCommand(EMOTE_ONESHOT_WOUND);
                    }
            events.RescheduleEvent(TIMEOUT, 45000ms);
            Tell(p, "The three supplicants are burning. Bind each living recruit within forty-five seconds.");
        }
        else if (mode == COURSE)
        {
            events.RescheduleEvent(TIMEOUT, 60000ms);
            Tell(p, "The course is open for sixty seconds. Pass A, B, C and D on foot, in that order.");
        }
        else if (mode == MENTAL || mode == SPEECH)
        {
            if (mode == SPEECH)
            {
                Child(NPC_OGRE, Locations::crowd_a, 1);
                Child(NPC_OGRE, Locations::crowd_b, 2);
                Child(NPC_RECRUIT, Locations::crowd_c, 3);
            }
            events.ScheduleEvent(PROMPT, 1000ms);
        }
        else if (mode == DOG || mode == GRUDGE)
        {
            if (Creature* c = Child(NPC_HOUND, Locations::hound, 1))
            {
                hound = c->GetGUID();
                c->RemoveUnitFlag(UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_IMMUNE_TO_NPC);
                c->SetWalk(false);
                c->GetMotionMaster()->MoveFollow(p, 2.0f, 1.0f);
            }
            if (mode == GRUDGE)
            {
                if (Creature* c = Child(NPC_GROMMKO, Locations::dog_a, 1))
                {
                    opponent = c->GetGUID();
                    c->SetUnitFlag(UNIT_FLAG_NON_ATTACKABLE);
                }
                if (Creature* c = Child(NPC_BUTCHER, Locations::dog_a, 2))
                {
                    opponent = c->GetGUID();
                    petRound = true;
                }
                Tell(p, "Butcher waits at station A. Command your hound to defeat the raptor; Gromm'ko follows it.");
            }
        }
        else if (mode == DISCORD)
        {
            Child(NPC_KARRGONN, Locations::karrgonn, 0);
            if (Creature* c = Child(NPC_AZENNIOS, Locations::azennios, 1))
            {
                opponent = c->GetGUID();
                c->SetUnitFlag(UNIT_FLAG_NON_ATTACKABLE);
            }
            Tell(p, "Send Karr'gonn away with a false order before confronting Azennios. You will have one minute.");
        }
        else if (mode == GARNOTH || mode == OKROG || mode == RESTRAINT)
        {
            std::uint32_t entry = mode == GARNOTH ? NPC_GARNOTH : mode == OKROG ? NPC_OKROG : NPC_RESTRAINT;
            Point const& location = mode == GARNOTH ? Locations::garnoth_foe
                                    : mode == OKROG ? Locations::okrog
                                                    : Locations::restraint;
            if (Creature* c = Child(entry, location, 1))
            {
                opponent = c->GetGUID();
                c->AI()->AttackStart(p);
            }
        }
        else if (mode == RIOT)
        {
            if (Creature* c = Child(NPC_JAROD_FREE, Locations::prison, 1))
            {
                jarod = c->GetGUID();
                c->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
                c->SetWalk(true);
            }
            p->RemoveAurasDueToSpell(SPELL_DISGUISE);
            State(p).disguise = false;
            events.RescheduleEvent(TIMEOUT, 480000ms);
            MoveEscape();
        }
    }

    void Menu(Player* p)
    {
        if (!Owned(me, p) || !Interact(p, me) || !Safe(p))
            return;
        ClearGossipMenuFor(p);
        if (offer.Pending())
        {
            std::uint32_t ticket = offer.Ticket();
            if (mode == MENTAL)
            {
                static constexpr std::array<char const*, 10> questions = {"Does water freeze in sufficient cold?",
                                                                          "Can a stone breathe?",
                                                                          "Do wolves eat meat?",
                                                                          "Is snow warmer than a forge?",
                                                                          "Does a blade cut?",
                                                                          "Can fish live without water?",
                                                                          "Does rain fall from clouds?",
                                                                          "Does a corpse have a heartbeat?",
                                                                          "Can a flame burn cloth?",
                                                                          "Is daylight the same as darkness?"};
                Tell(p, questions[question]);
                AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Yes", Sender, ticket * 8);
                AddGossipItemFor(p, GOSSIP_ICON_CHAT, "No", Sender, ticket * 8 + 1);
            }
            else
            {
                static constexpr std::array<char const*, 3> moods = {
                    "The audience looks hesitant and afraid. Give them courage.",
                    "The audience is furious. Turn their anger against each other.",
                    "The audience cheers for the cult. Tell them what they want to hear."};
                Tell(p, moods[question]);
                AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Inspire!", Sender, ticket * 8);
                AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Incite!", Sender, ticket * 8 + 1);
                AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Pander!", Sender, ticket * 8 + 2);
            }
        }
        else
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Wait for the next prompt.", Sender, QUESTION);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "End this attempt.", Sender, CANCEL_TRIAL);
        SendGossipMenuFor(p, me->GetEntry(), me->GetGUID());
    }

    void Prompt()
    {
        Player* p = Owner();
        if (!p || !Safe(p))
            return;
        question = mode == MENTAL ? urand(0, 9) : urand(0, 2);
        std::uint32_t expected = mode == MENTAL ? question % 2 : question;
        offeredAt = getMSTime();
        offer.Open(urand(1000, 10000000), expected, mode == MENTAL ? 5000 : 10000);
        events.RescheduleEvent(ANSWER_TIMEOUT, mode == MENTAL ? 5000ms : 10000ms);
        Menu(p);
    }

    void Answer(Player* p, std::uint32_t action)
    {
        if (!Owned(me, p) || !Interact(p, me) || !Safe(p) || stopped)
            return;
        if (action == CANCEL_TRIAL)
        {
            Stop("You step away. Use the orb or podium to retry.");
            return;
        }
        if (action == QUESTION)
        {
            Menu(p);
            return;
        }
        AnswerOffer::Result result = offer.Answer(action / 8, action % 8, getMSTimeDiff(offeredAt, getMSTime()));
        if (result == AnswerOffer::Stale)
            return;
        events.CancelEvent(ANSWER_TIMEOUT);
        CloseGossipMenuFor(p);
        if (result == AnswerOffer::Wrong || result == AnswerOffer::Expired)
        {
            Stop("That response did not pass the trial. Your earlier correct responses are recorded; try again.");
            return;
        }
        std::uint32_t quest = QuestFor(mode);
        std::uint32_t credit = mode == MENTAL ? CREDIT_MENTAL : CREDIT_SPEECH;
        Credit(p, quest, credit, 10);
        if (HasCredit(p, quest, credit, 10))
        {
            Stop(mode == SPEECH ? "The crowd turns inward. Approach Jarod at the altar."
                                : "The orb accepts ten answers. Return to Mylva.");
            return;
        }
        events.ScheduleEvent(PROMPT, mode == MENTAL ? 1000ms : 9000ms);
    }

    void Checkpoint(Player* p, std::uint32_t index)
    {
        if (mode != COURSE || !Safe(p) || index != courseStep || index >= Course.size())
            return;
        if (getMSTimeDiff(startedAt, getMSTime()) >= 60000)
        {
            Stop("The course timer has expired. Start a new attempt.");
            return;
        }
        ++courseStep;
        if (courseStep == Course.size())
        {
            Credit(p, QUEST_AGILITY, CREDIT_COURSE);
            Stop("The course is complete. Return to Mylva.");
        }
        else
            Tell(p, "Checkpoint accepted. Continue to the next lettered marker.");
    }

    void Knockout(Player* p, Creature* recruit)
    {
        if (mode != RECRUIT || !Safe(p) || !Owned(recruit, p) || !Interact(p, recruit) ||
            !recruit->AI()->GetData(DATA_COMMAND) ||
            recruit->GetDistance(Locations::recruit_hide.x, Locations::recruit_hide.y, Locations::recruit_hide.z) >
                3.0f)
            return;
        if (Give(p, ITEM_PAPERS))
        {
            recruit->AddAura(SPELL_BLACKJACK, recruit);
            Credit(p, QUEST_SIGNED, CREDIT_KNOCKOUT);
            Stop("The recruit is unconscious. His papers will let Ortell prepare your cover.");
        }
    }

    void Bind(Player* p, Creature* recruit)
    {
        if (mode != SUPPLICANTS || !Safe(p) || getMSTimeDiff(startedAt, getMSTime()) >= 45000 || !Owned(recruit, p) ||
            !Interact(p, recruit) || !recruit->IsAlive())
            return;
        std::array<std::uint32_t, 3> credits = {CREDIT_SUPPLICANT_A, CREDIT_SUPPLICANT_B, CREDIT_SUPPLICANT_C};
        std::uint32_t index = recruit->AI()->GetData(DATA_ROLE);
        if (index >= credits.size())
            return;
        Credit(p, QUEST_WASTE, credits[index]);
        recruit->RemoveAurasDueToSpell(SPELL_BURNING);
        recruit->Whisper("The pain has stopped... I can breathe.", LANG_UNIVERSAL, p);
        recruit->DespawnOrUnsummon(1000ms);
    }

    void HoundCommand(Player* p, std::uint32_t action)
    {
        Creature* c = Resolve(hound);
        if (!c || !c->IsAlive() || !Safe(p) || !Interact(p, c, true))
            return;
        if (mode == DOG && action == HOUND_FEED)
        {
            std::array<std::uint32_t, 3> credits = {CREDIT_DOG_A, CREDIT_DOG_B, CREDIT_DOG_C};
            for (std::size_t i = 0; i < DogStations.size(); ++i)
                if (!HasCredit(p, QUEST_DOG, credits[i]))
                {
                    Point const& point = DogStations[i];
                    if (c->GetDistance(point.x, point.y, point.z) <= 7.0f &&
                        p->GetDistance(point.x, point.y, point.z) <= 7.0f)
                    {
                        c->HandleEmoteCommand(EMOTE_ONESHOT_EAT_NO_SHEATHE);
                        Credit(p, QUEST_DOG, credits[i]);
                        Tell(p, "The hound accepts its meal. Continue to the next station.");
                    }
                    return;
                }
        }
        else if (mode == GRUDGE)
        {
            Creature* foe = Resolve(opponent);
            if (!foe || !foe->IsAlive() || foe->GetDistance(p) > 30.0f)
                return;
            if (action == HOUND_ATTACK)
            {
                c->AI()->AttackStart(foe);
                houndEngaged = true;
                foe->AI()->AttackStart(c);
            }
            else if (action == HOUND_POUNCE && pounceReady && c->GetVictim() == foe && c->IsWithinMeleeRange(foe))
            {
                pounceReady = false;
                c->CastSpell(foe, SPELL_STRIKE, false);
                events.ScheduleEvent(POUNCE_READY, 5000ms);
            }
            else if (action == HOUND_RETURN)
            {
                c->AttackStop();
                c->GetMotionMaster()->MoveFollow(p, 2.0f, 1.0f);
            }
        }
    }

    void MoveEscape()
    {
        if (Creature* c = Resolve(jarod))
        {
            Point const& point = EscapeRoute[escapeStep];
            moving = true;
            c->GetMotionMaster()->MovePoint(escapeStep + 1, point.x, point.y, point.z);
        }
        else
            Stop("Jarod is missing. Return to the restraints to restart the escape.");
    }

    void SpawnWave()
    {
        Player* p = Owner();
        if (!p)
            return;
        Point point = EscapeRoute[escapeStep];
        // Use the verified ground point for each spawn; actors spread naturally when they engage.
        kills = 0;
        waveActive = true;
        for (std::uint32_t i = 0; i < 2; ++i)
            if (Creature* c = Child(NPC_ENFORCER, point, 10 + wave * 2 + i))
                c->AI()->AttackStart(p);
        Tell(p, "Two enforcers block the escape. Defeat them before Jarod moves on.");
    }

    void SetData(std::uint32_t type, std::uint32_t value) override
    {
        Player* p = Owner();
        if (!p || stopped || !Safe(p))
            return;
        if (type == DATA_DISTRACT && mode == DISCORD && !distracted)
        {
            distracted = true;
            events.RescheduleEvent(TIMEOUT, 60000ms);
            for (ObjectGuid const& guid : children)
                if (Creature* c = Resolve(guid))
                    if (c->GetEntry() == NPC_KARRGONN)
                        c->DespawnOrUnsummon();
            if (Creature* c = Resolve(opponent))
            {
                c->RemoveUnitFlag(UNIT_FLAG_NON_ATTACKABLE);
                c->AI()->AttackStart(p);
            }
        }
        else if (type == DATA_KILLED)
        {
            if (mode == RIOT && value >= 10 + wave * 2 && value < 12 + wave * 2 && waveActive)
            {
                ++kills;
                if (kills == 2)
                {
                    waveActive = false;
                    ++wave;
                    ++escapeStep;
                    MoveEscape();
                }
                return;
            }
            if (mode == GRUDGE && petRound && value == 2)
            {
                Creature* dog = Resolve(hound);
                if (!houndEngaged || !dog || !dog->IsAlive())
                {
                    Stop("Your hound must take part in the raptor match. Call it with the leash and retry.");
                    return;
                }
                petRound = false;
                for (ObjectGuid const& guid : children)
                    if (Creature* c = Resolve(guid))
                        if (c->GetEntry() == NPC_GROMMKO)
                        {
                            opponent = c->GetGUID();
                            c->RemoveUnitFlag(UNIT_FLAG_NON_ATTACKABLE);
                            c->AI()->AttackStart(p);
                            Tell(p, "Butcher falls. Gromm'ko attacks; keep your hound beside you.");
                        }
                return;
            }
            if (value != 1 || (mode == GRUDGE && petRound))
                return;
            if (mode == GRUDGE)
            {
                Creature* c = Resolve(hound);
                if (!c || !c->IsAlive() || c->GetDistance(p) > 30.0f)
                {
                    Stop("The match needs a living hound beside you. Use the leash to retry.");
                    return;
                }
                Credit(p, QUEST_GRUDGE, CREDIT_GRUDGE);
            }
            else if (mode == DISCORD && distracted)
                Credit(p, QUEST_DISCORD, CREDIT_DISCORD);
            else if (mode == GARNOTH && p->HasAura(SPELL_FIRE_FORM))
                Credit(p, QUEST_GREATER, CREDIT_GARNOTH);
            else if (mode == OKROG)
            {
                Credit(p, QUEST_WRITING, CREDIT_OKROG);
                Give(p, ITEM_NOTES);
            }
            else if (mode == RESTRAINT)
            {
                Give(p, ITEM_KEY);
                Tell(p,
                     "Recover the key, then use Jarod's Restraints. Challenge the guard again if your bags were full.");
            }
            Stop();
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
                Stop("This attempt has ended. Return to its starting contact when ready.");
                return;
            }
            if (event == TIMEOUT || event == ANSWER_TIMEOUT)
            {
                if (mode == SUPPLICANTS)
                    for (ObjectGuid const& guid : children)
                        if (Creature* c = Resolve(guid))
                            if (c->IsAlive())
                                Unit::Kill(c, c, false);
                Stop("Time has expired. Your completed objectives remain recorded; start a new attempt.");
                return;
            }
            if (event == PROMPT)
                Prompt();
            else if (event == POUNCE_READY)
                pounceReady = true;
            else if (event == CHECK)
            {
                if (mode == RIOT)
                {
                    Creature* c = Resolve(jarod);
                    if (!c)
                    {
                        Stop("Return to Jarod's restraints to restart the escape.");
                        return;
                    }
                    if (!waveActive)
                    {
                        if (p->IsInCombat())
                        {
                            c->GetMotionMaster()->MoveIdle();
                            moving = false;
                        }
                        else
                        {
                            Point const& point = EscapeRoute[escapeStep];
                            if (c->GetDistance(point.x, point.y, point.z) <= 3.0f)
                            {
                                moving = false;
                                if (escapeStep == EscapeRoute.size() - 1)
                                {
                                    if (p->GetDistance(c) <= 12.0f && wave == 3)
                                    {
                                        Credit(p, QUEST_RIOT, CREDIT_RIOT);
                                        Stop("Jarod reaches Ortell's refuge. Report back to the handler.");
                                        return;
                                    }
                                }
                                else
                                    SpawnWave();
                            }
                            else if (!moving)
                                MoveEscape();
                        }
                    }
                }
                events.ScheduleEvent(CHECK, 500ms);
            }
        }
    }
};

npc_bs_c02_sceneAI* Focus(Player* p)
{
    for (std::uint32_t entry : {NPC_SCENE, NPC_ORB, NPC_CROWD})
        if (Creature* c = FindOwned(p, entry))
        {
            auto* ai = dynamic_cast<npc_bs_c02_sceneAI*>(c->AI());
            if (ai && !ai->stopped)
                return ai;
        }
    return nullptr;
}

void Start(Player* p, Mode mode, Point const& location)
{
    if (!Enabled() || !Active(p, QuestFor(mode)) || !p->IsAlive() || p->IsInCombat() || p->IsMounted() || p->IsFlying())
        return;
    State(p);
    if (Focus(p))
    {
        Tell(p, "You already have a trial running. Finish it or let it end before starting another.");
        return;
    }
    if (mode != RECRUIT && mode != RIOT && mode != RESTRAINT && !Covered(p))
    {
        Tell(p, "Renew your cover with Condenna, Ortell or your altered papers before this trial.");
        return;
    }
    std::uint32_t entry = mode == MENTAL ? NPC_ORB : mode == SPEECH ? NPC_CROWD : NPC_SCENE;
    if (Creature* c = Summon(p, entry, location, mode == RIOT ? 485000 : 305000))
        if (auto* ai = dynamic_cast<npc_bs_c02_sceneAI*>(c->AI()))
            ai->Begin(mode);
}

bool IsCampContact(std::uint32_t entry)
{
    return entry == NPC_ORTELL || entry == NPC_CONDENNA || entry == NPC_CARGALL || entry == NPC_MYLVA ||
           entry == NPC_DEVORAN || entry == NPC_JAROD_FREE || entry == NPC_DEZCO;
}

void ContactMenu(Player* p, Creature* c)
{
    if (!Interact(p, c))
        return;
    std::uint32_t entry = c->GetEntry();
    if (!IsCampContact(entry) && entry != NPC_PRISONER)
        return;
    if (entry == NPC_JAROD_FREE && !Owned(c, p))
        return;
    if (entry == NPC_ORTELL || entry == NPC_CONDENNA)
    {
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Replace my active quest supplies.", Sender, RECOVER);
        if (CoverAllowed(p))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Renew my papers and cult disguise.", Sender, DISGUISE);
    }
    if (entry == NPC_CONDENNA && Active(p, QUEST_IDENTITY))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Present the altered recruitment papers.", Sender, IDENTITY);
    if (entry == NPC_CARGALL && Active(p, QUEST_WASTE))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Begin the supplicant preservation trial.", Sender, START_SUPPLICANTS);
    if (entry == NPC_MYLVA || entry == NPC_DEVORAN)
    {
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Replace my active training supplies.", Sender, RECOVER);
        if (Active(p, QUEST_TRAINING))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Introduce me to your training.", Sender,
                             entry == NPC_MYLVA ? INTRO_MYLVA : INTRO_DEVORAN);
    }
    if (entry == NPC_DEVORAN && Active(p, QUEST_GRUDGE))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Prepare my collar and supervised match.", Sender, START_GRUDGE);
    if (entry == NPC_ORTELL)
    {
        if (Active(p, QUEST_HEAD))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Give me the final instruction for the speaking slot.", Sender,
                             FINAL_INSTRUCTION);
        if (p->IsQuestRewarded(QUEST_RIOT))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Ask Jarod to join us at the refuge.", Sender, SUMMON_JAROD);
    }
    if (entry == NPC_PRISONER && Held(p, QUEST_RIOT))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Challenge your restraint guard.", Sender, START_RESTRAINT);
    if (entry == NPC_JAROD_FREE && Held(p, QUEST_LETTER))
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Replace my letter to Dezco.", Sender, RECOVER);
}

bool ContactSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action)
{
    if (sender != Sender)
        return false;
    if (!Interact(p, c) || (!IsCampContact(c->GetEntry()) && c->GetEntry() != NPC_PRISONER))
        return true;
    if (c->GetEntry() == NPC_JAROD_FREE && !Owned(c, p))
        return true;
    ClearGossipMenuFor(p);
    CloseGossipMenuFor(p);
    std::uint32_t entry = c->GetEntry();
    if (action == RECOVER)
        Recover(p);
    else if (action == DISGUISE && (entry == NPC_ORTELL || entry == NPC_CONDENNA))
    {
        Recover(p);
        ApplyCover(p);
    }
    else if (action == IDENTITY && entry == NPC_CONDENNA && Active(p, QUEST_IDENTITY) &&
             p->HasItemCount(ITEM_IDENTITY, 1))
    {
        ApplyCover(p);
        if (Covered(p))
        {
            Credit(p, QUEST_IDENTITY, CREDIT_IDENTITY);
            c->Whisper("Your sponsor has signed. Take your place among the recruits.", LANG_UNIVERSAL, p);
        }
    }
    else if (action == INTRO_MYLVA && entry == NPC_MYLVA)
        Credit(p, QUEST_TRAINING, CREDIT_MYLVA);
    else if (action == INTRO_DEVORAN && entry == NPC_DEVORAN)
        Credit(p, QUEST_TRAINING, CREDIT_DEVORAN);
    else if (action == START_SUPPLICANTS && entry == NPC_CARGALL && p->HasItemCount(ITEM_GEM, 1))
        Start(p, SUPPLICANTS, Locations::cargall);
    else if (action == START_GRUDGE && entry == NPC_DEVORAN && Active(p, QUEST_GRUDGE))
    {
        Recover(p);
        if (p->HasItemCount(ITEM_LEASH, 1) && p->HasItemCount(ITEM_COLLAR, 1))
            Start(p, GRUDGE, Locations::devoran);
    }
    else if (action == FINAL_INSTRUCTION && entry == NPC_ORTELL && Active(p, QUEST_HEAD))
    {
        c->Whisper("Keep the cult listening. When its eyes leave the altar, reach Jarod. He will decide when to move.",
                   LANG_UNIVERSAL, p);
        Credit(p, QUEST_HEAD, CREDIT_HEAD);
    }
    else if (action == SUMMON_JAROD && entry == NPC_ORTELL && p->IsQuestRewarded(QUEST_RIOT))
    {
        if (!FindOwned(p, NPC_JAROD_FREE))
            Summon(p, NPC_JAROD_FREE, Locations::refuge, 600000);
    }
    else if (action == START_RESTRAINT && entry == NPC_PRISONER)
        Start(p, RESTRAINT, Locations::prison);
    return true;
}

struct npc_bs_c02_contactAI : ScriptedAI
{
    explicit npc_bs_c02_contactAI(Creature* c) : ScriptedAI(c) {}
    EventMap events;
    ObjectGuid owner;
    void Reset() override
    {
        me->SetReactState(REACT_PASSIVE);
        events.Reset();
        events.ScheduleEvent(CHECK, 2000ms);
    }
    void IsSummonedBy(WorldObject* summoner) override
    {
        if (summoner->ToPlayer())
            owner = summoner->GetGUID();
        me->setActive(true);
    }
    void UpdateAI(std::uint32_t diff) override
    {
        events.Update(diff);
        if (events.ExecuteEvent() == CHECK)
        {
            if (!owner.IsEmpty())
            {
                Player* p = ObjectAccessor::GetPlayer(*me, owner);
                if (!p || !p->IsAlive() || !SameWorld(p, me) || me->GetDistance(p) > 100.0f || !Enabled() ||
                    (!parent.IsEmpty() && !ObjectAccessor::GetCreature(*me, parent)))
                {
                    me->DespawnOrUnsummon();
                    return;
                }
            }
            if (Enabled() && (owner.IsEmpty() || parent.IsEmpty()))
                me->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
            else
                me->RemoveNpcFlag(UNIT_NPC_FLAG_GOSSIP | UNIT_NPC_FLAG_QUESTGIVER);
            events.ScheduleEvent(CHECK, 2000ms);
        }
    }
    ObjectGuid parent;
    void SetGUID(ObjectGuid const& guid, std::int32_t type) override
    {
        if (type == DATA_PARENT)
            parent = guid;
    }
    ObjectGuid GetGUID(std::int32_t type) const override { return type == DATA_PARENT ? parent : owner; }
};

class npc_bs_c02_contact : public CreatureScript
{
  public:
    npc_bs_c02_contact() : CreatureScript("npc_bs_c02_contact") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c02_contactAI(c); }
    bool OnGossipHello(Player* p, Creature* c) override
    {
        if (!Interact(p, c) || (c->GetEntry() == NPC_JAROD_FREE && !Owned(c, p)))
            return true;
        ClearGossipMenuFor(p);
        p->PrepareQuestMenu(c->GetGUID());
        ContactMenu(p, c);
        SendGossipMenuFor(p, BrokenSealChapter3Gossip(p, c), c->GetGUID());
        return true;
    }
    bool OnGossipSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action) override
    {
        if (BrokenSealChapter3Select(p, c, sender, action))
            return true;
        ContactSelect(p, c, sender, action);
        return true;
    }
};

class npc_bs_c02_actor : public CreatureScript
{
  public:
    npc_bs_c02_actor() : CreatureScript("npc_bs_c02_actor") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c02_actorAI(c); }
    bool OnGossipHello(Player* p, Creature* c) override
    {
        if (!Interact(p, c, true) || !Owned(c, p) || c->GetEntry() != NPC_HOUND)
            return true;
        ClearGossipMenuFor(p);
        if (Held(p, QUEST_DOG))
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Feed at the next station.", Sender, HOUND_FEED);
        if (Held(p, QUEST_GRUDGE))
        {
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Attack the opponent.", Sender, HOUND_ATTACK);
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Pounce on the opponent.", Sender, HOUND_POUNCE);
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Return to me.", Sender, HOUND_RETURN);
        }
        SendGossipMenuFor(p, c->GetEntry(), c->GetGUID());
        return true;
    }
    bool OnGossipSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action) override
    {
        if (sender == Sender && Interact(p, c, true) && Owned(c, p) && c->GetEntry() == NPC_HOUND)
            if (Creature* focus = ObjectAccessor::GetCreature(*c, c->AI()->GetGUID(DATA_PARENT)))
                if (auto* ai = dynamic_cast<npc_bs_c02_sceneAI*>(focus->AI()))
                    ai->HoundCommand(p, action);
        CloseGossipMenuFor(p);
        return true;
    }
};

class npc_bs_c02_enemy : public CreatureScript
{
  public:
    npc_bs_c02_enemy() : CreatureScript("npc_bs_c02_enemy") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c02_enemyAI(c); }
    bool OnGossipHello(Player* p, Creature* c) override
    {
        if (c->GetEntry() != NPC_KARRGONN || !Owned(c, p) || !Interact(p, c))
            return true;
        ClearGossipMenuFor(p);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT,
                         "A rival has challenged your command. The instructor demands you at once.", Sender,
                         DISTRACT_GUARD);
        SendGossipMenuFor(p, NPC_CONDENNA, c->GetGUID());
        return true;
    }
    bool OnGossipSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action) override
    {
        if (sender == Sender && action == DISTRACT_GUARD && c->GetEntry() == NPC_KARRGONN && Owned(c, p) &&
            Interact(p, c))
            if (Creature* focus = ObjectAccessor::GetCreature(*c, c->AI()->GetGUID(DATA_PARENT)))
                focus->AI()->SetData(DATA_DISTRACT, 1);
        CloseGossipMenuFor(p);
        return true;
    }
};

class npc_bs_c02_scene : public CreatureScript
{
  public:
    npc_bs_c02_scene() : CreatureScript("npc_bs_c02_scene") {}
    CreatureAI* GetAI(Creature* c) const override { return new npc_bs_c02_sceneAI(c); }
    bool OnGossipHello(Player* p, Creature* c) override
    {
        if (auto* ai = dynamic_cast<npc_bs_c02_sceneAI*>(c->AI()))
            ai->Menu(p);
        return true;
    }
    bool OnGossipSelect(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action) override
    {
        if (sender == Sender)
            if (auto* ai = dynamic_cast<npc_bs_c02_sceneAI*>(c->AI()))
                ai->Answer(p, action);
        return true;
    }
};

class go_bs_c02_interaction : public GameObjectScript
{
  public:
    go_bs_c02_interaction() : GameObjectScript("go_bs_c02_interaction") {}
    bool OnGossipHello(Player* p, GameObject* go) override
    {
        if (!Interact(p, go))
            return true;
        std::uint32_t entry = go->GetEntry();
        if (entry == GO_RENDEZVOUS && p->HasItemCount(ITEM_BLACKJACK, 1))
            Start(p, RECRUIT, Locations::recruit_start);
        else if (entry == GO_FLOWER && Active(p, QUEST_BLOOM) && Covered(p) && !p->IsMounted())
        {
            auto& flowers = State(p).flowers;
            auto it = flowers.find(go->GetGUID());
            if (it != flowers.end() && getMSTimeDiff(it->second, getMSTime()) < 60000)
                Tell(p, "This patch needs a minute to regrow for you. Look for another blossom patch.");
            else if (p->AddItem(ITEM_BLOSSOMS, 1))
                flowers[go->GetGUID()] = getMSTime();
        }
        else if (entry == GO_STONES && Active(p, QUEST_LABOR) && !p->IsMounted() && !p->IsFlying())
        {
            State(p).carrying = true;
            Tell(p, "You lift one training load. Carry it on foot to the delivery station south of Mylva.");
        }
        else if (entry == GO_DELIVERY &&
                 CanDeliver(State(p).carrying, Active(p, QUEST_LABOR), !p->IsMounted() && !p->IsFlying(), true))
        {
            State(p).carrying = false;
            Credit(p, QUEST_LABOR, CREDIT_LOADS, 5);
            Tell(p, "Load delivered. Return to the stone pile for the next one.");
        }
        else if (entry == GO_COURSE_START)
            Start(p, COURSE, Locations::course_start);
        else if (entry >= GO_CHECK_A && entry <= GO_CHECK_D)
        {
            if (npc_bs_c02_sceneAI* ai = Focus(p))
                ai->Checkpoint(p, entry - GO_CHECK_A);
        }
        else if (entry == GO_COMMUNIQUE && Active(p, QUEST_INTELLIGENCE) && Covered(p))
            Give(p, ITEM_COMMUNIQUE);
        else if (entry == GO_PLANS && Active(p, QUEST_INTELLIGENCE) && Covered(p))
            Give(p, ITEM_PLANS);
        else if (entry == GO_DROP && Active(p, QUEST_INTELLIGENCE) && p->HasItemCount(ITEM_COMMUNIQUE, 1) &&
                 p->HasItemCount(ITEM_PLANS, 1))
            Credit(p, QUEST_INTELLIGENCE, CREDIT_DROP);
        else if (entry == GO_DISCORD)
            Start(p, DISCORD, Locations::discord);
        else if (entry == GO_OKROG)
            Start(p, OKROG, Locations::okrog);
        else if (entry == GO_GARNOTH)
            Tell(p, "Use the ascendancy talisman beside this marker to take Garnoth's trial.");
        else if (entry == GO_PODIUM)
        {
            if (!HasCredit(p, QUEST_SPEECH, CREDIT_SPEECH, 10))
                Start(p, SPEECH, {p->GetPositionX(), p->GetPositionY(), p->GetPositionZ(), p->GetOrientation()});
            else
                Tell(p, "The speech is recorded. Speak to Jarod at the prisoner altar.");
        }
        else if (entry == GO_PRISON && Active(p, QUEST_RIOT) && p->HasItemCount(ITEM_KEY, 1))
            Start(p, RIOT, Locations::prison);
        else if (entry == GO_BUYERS && Active(p, QUEST_BUYERS))
            Give(p, ITEM_LEDGER);
        return true;
    }
};

class item_bs_c02_tool : public ItemScript
{
  public:
    item_bs_c02_tool() : ItemScript("item_bs_c02_tool") {}
    bool OnUse(Player* p, Item* item, SpellCastTargets const& targets) override
    {
        p->SendEquipError(EQUIP_ERR_OK, item, nullptr);
        if (!Enabled() || !p->IsAlive() || !InVale(p))
            return true;
        std::uint32_t entry = item->GetEntry();
        if (entry == ITEM_BLACKJACK || entry == ITEM_GEM)
        {
            Creature* c = targets.GetUnitTarget() ? targets.GetUnitTarget()->ToCreature() : nullptr;
            if (c && Owned(c, p))
                if (Creature* focus = ObjectAccessor::GetCreature(*c, c->AI()->GetGUID(DATA_PARENT)))
                    if (auto* ai = dynamic_cast<npc_bs_c02_sceneAI*>(focus->AI()))
                    {
                        if (entry == ITEM_BLACKJACK && c->GetEntry() == NPC_RECRUIT)
                            ai->Knockout(p, c);
                        else if (entry == ITEM_GEM && c->GetEntry() >= NPC_SUPPLICANT_A &&
                                 c->GetEntry() <= NPC_SUPPLICANT_C)
                            ai->Bind(p, c);
                    }
        }
        else if (entry == ITEM_IDENTITY)
            ApplyCover(p);
        else if (entry == ITEM_ORB &&
                 p->GetDistance(Locations::mylva.x, Locations::mylva.y, Locations::mylva.z) <= 10.0f)
        {
            Point point{p->GetPositionX(), p->GetPositionY(), p->GetPositionZ(), p->GetOrientation()};
            Start(p, MENTAL, point);
        }
        else if (entry == ITEM_LEASH &&
                 p->GetDistance(Locations::devoran.x, Locations::devoran.y, Locations::devoran.z) <= 12.0f)
        {
            if (Active(p, QUEST_GRUDGE) && p->HasItemCount(ITEM_COLLAR, 1))
                Start(p, GRUDGE, Locations::devoran);
            else
                Start(p, DOG, Locations::devoran);
        }
        else if (entry == ITEM_TALISMAN && Active(p, QUEST_GREATER) && !p->IsInCombat() &&
                 p->GetDistance(Locations::garnoth.x, Locations::garnoth.y, Locations::garnoth.z) <= 8.0f && !Focus(p))
        {
            p->RemoveAurasByType(SPELL_AURA_MOD_SHAPESHIFT);
            if (Aura* aura = p->AddAura(SPELL_FIRE_FORM, p))
            {
                aura->SetMaxDuration(300000);
                aura->SetDuration(300000);
                State(p).fireForm = true;
                Start(p, GARNOTH, Locations::garnoth);
                if (!Focus(p))
                {
                    p->RemoveAurasDueToSpell(SPELL_FIRE_FORM);
                    State(p).fireForm = false;
                }
            }
        }
        return true;
    }
};

class bs_c02_player : public PlayerScript
{
  public:
    bs_c02_player()
        : PlayerScript("bs_c02_player",
                       {PLAYERHOOK_ON_LOGIN, PLAYERHOOK_ON_LOGOUT, PLAYERHOOK_ON_QUEST_ABANDON, PLAYERHOOK_ON_UPDATE})
    {
    }
    void OnPlayerLogin(Player* p) override
    {
        // Recover cosmetic auras saved during an unexpected server stop, only for campaign participants.
        if (p->IsQuestRewarded(QUEST_C01_END))
        {
            p->RemoveAurasDueToSpell(SPELL_DISGUISE);
            p->RemoveAurasDueToSpell(SPELL_FIRE_FORM);
        }
    }
    void OnPlayerLogout(Player* p) override { Cleanup(p); }
    void OnPlayerQuestAbandon(Player* p, std::uint32_t quest) override
    {
        if (quest >= QUEST_SIGNED && quest <= QUEST_LETTER)
            Cleanup(p);
    }
    void OnPlayerUpdate(Player* p, std::uint32_t) override
    {
        PlayerState* state = p->CustomData.Get<PlayerState>(StateKey);
        if (!state)
            return;
        if (!Enabled() || !p->IsAlive() || !InVale(p) || state->phase != p->GetPhaseMask())
        {
            Cleanup(p);
            return;
        }
        if (state->carrying && (!Active(p, QUEST_LABOR) || p->IsInCombat() || p->IsMounted() || p->IsFlying()))
            state->carrying = false;
        if (state->disguise && !CoverAllowed(p))
        {
            p->RemoveAurasDueToSpell(SPELL_DISGUISE);
            state->disguise = false;
        }
        if (state->fireForm && !Active(p, QUEST_GREATER))
        {
            p->RemoveAurasDueToSpell(SPELL_FIRE_FORM);
            state->fireForm = false;
        }
    }
};
} // namespace BrokenSeal::Chapter2

bool BrokenSealChapter2Available()
{
    return BrokenSeal::Chapter2::Enabled();
}
bool BrokenSealChapter2AvoidCombat(Unit const* unit)
{
    using namespace BrokenSeal::Chapter2;
    Player const* p = unit ? unit->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
    if (!p && unit)
        if (Creature const* c = unit->ToCreature())
            if (TempSummon const* summon = c->ToTempSummon())
                p = ObjectAccessor::GetPlayer(*unit, summon->GetSummonerGUID());
    return Enabled() && CoverAllowed(p) && Covered(p) && InVale(p);
}
void BrokenSealChapter2Gossip(Player* p, Creature* c)
{
    BrokenSeal::Chapter2::ContactMenu(p, c);
}
bool BrokenSealChapter2Select(Player* p, Creature* c, std::uint32_t sender, std::uint32_t action)
{
    return BrokenSeal::Chapter2::ContactSelect(p, c, sender, action);
}
bool BrokenSealChapter2Altar(Player* p, Creature* c)
{
    using namespace BrokenSeal::Chapter2;
    if (c->GetEntry() != NPC_PRISONER || !Interact(p, c))
        return false;
    if (Active(p, QUEST_SPEECH) && HasCredit(p, QUEST_SPEECH, CREDIT_SPEECH, 10))
        Credit(p, QUEST_SPEECH, CREDIT_ALTAR);
    return Held(p, QUEST_SPEECH) || Held(p, QUEST_RIOT);
}

void AddBrokenSealChapter2Scripts()
{
    using namespace BrokenSeal::Chapter2;
    new npc_bs_c02_contact();
    new npc_bs_c02_actor();
    new npc_bs_c02_enemy();
    new npc_bs_c02_scene();
    new go_bs_c02_interaction();
    new item_bs_c02_tool();
    new bs_c02_player();
}
