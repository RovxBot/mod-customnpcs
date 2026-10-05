/*
 * Copyright (C) 2026 mod-customNPCs contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

#include "CustomNpcAppearanceMgr.h"
#include "AllCreatureScript.h"
#include "Chat.h"
#include "CommandScript.h"
#include "Config.h"
#include "Creature.h"
#include "DatabaseEnv.h"
#include "Item.h"
#include "ItemTemplate.h"
#include "Opcodes.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "ServerScript.h"
#include "WorldPacket.h"
#include "WorldScript.h"
#include "WorldSession.h"

#include <limits>
#include <string>

using namespace Acore::ChatCommands;
using CustomNpcs::AppearanceMgr;
using CustomNpcs::Outfit;

namespace
{
bool Fail(ChatHandler* handler, std::string const& message)
{
    handler->SendSysMessage(message);
    handler->SetSentErrorMessage(true);
    return false;
}

bool Enabled(ChatHandler* handler)
{
    if (sConfigMgr->GetOption<bool>("ModCustomNPCs.Enable", true) &&
        sConfigMgr->GetOption<bool>("ModCustomNPCs.Appearance.Enable", true))
        return true;
    return Fail(handler, "Custom NPC appearances are disabled in mod_customnpcs.conf.");
}

Creature* Selected(ChatHandler* handler, bool requireSpawn)
{
    Creature* creature = handler->getSelectedCreature();
    if (!creature || creature->IsPet() || (requireSpawn && !creature->GetSpawnId()))
    {
        Fail(handler, requireSpawn ? "Select a saved NPC spawn (not a pet or temporary summon)." :
            "Select an NPC (not a pet).");
        return nullptr;
    }
    return creature;
}

bool SaveOutfit(ChatHandler* handler, Outfit outfit)
{
    std::string error;
    if (!AppearanceMgr::Instance().Validate(outfit, error))
        return Fail(handler, error);

    // All arguments are numeric. Modules cannot extend the core's prepared-statement enum.
    // Synchronous writes ensure the following reload observes the saved record.
    WorldDatabase.DirectExecute(
        "INSERT INTO mod_customnpcs_outfit (outfit_id, race, gender, class, skin, face, hair, hair_color, "
        "facial_hair, guild_id, head, shoulders, shirt, chest, waist, legs, feet, wrists, hands, back, tabard, "
        "mainhand, offhand, ranged) VALUES "
        "({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}) "
        "ON DUPLICATE KEY UPDATE race=VALUES(race), gender=VALUES(gender), class=VALUES(class), "
        "skin=VALUES(skin), face=VALUES(face), hair=VALUES(hair), hair_color=VALUES(hair_color), "
        "facial_hair=VALUES(facial_hair), guild_id=VALUES(guild_id), head=VALUES(head), shoulders=VALUES(shoulders), "
        "shirt=VALUES(shirt), chest=VALUES(chest), waist=VALUES(waist), legs=VALUES(legs), feet=VALUES(feet), "
        "wrists=VALUES(wrists), hands=VALUES(hands), back=VALUES(back), tabard=VALUES(tabard), "
        "mainhand=VALUES(mainhand), offhand=VALUES(offhand), ranged=VALUES(ranged)",
        outfit.id, outfit.race, outfit.gender, outfit.playerClass, outfit.skin, outfit.face, outfit.hair,
        outfit.hairColor, outfit.facialHair, outfit.guild,
        outfit.armor[0], outfit.armor[1], outfit.armor[2], outfit.armor[3], outfit.armor[4], outfit.armor[5],
        outfit.armor[6], outfit.armor[7], outfit.armor[8], outfit.armor[9], outfit.armor[10],
        outfit.weapons[0], outfit.weapons[1], outfit.weapons[2]);
    AppearanceMgr::Instance().Reload();
    auto saved = AppearanceMgr::Instance().GetOutfit(outfit.id);
    if (!saved || saved->race != outfit.race || saved->gender != outfit.gender ||
        saved->playerClass != outfit.playerClass || saved->skin != outfit.skin || saved->face != outfit.face ||
        saved->hair != outfit.hair || saved->hairColor != outfit.hairColor || saved->facialHair != outfit.facialHair ||
        saved->guild != outfit.guild || saved->armor != outfit.armor || saved->weapons != outfit.weapons)
        return Fail(handler, "Could not save the outfit. Check the worldserver SQL log and install the outfit schema.");

    handler->PSendSysMessage("Saved outfit {}. Assigned NPCs refresh on their next update.", outfit.id);
    return true;
}

class CustomNpcAppearanceWorldScript : public WorldScript
{
public:
    CustomNpcAppearanceWorldScript() : WorldScript("mod_customnpcs_appearance_world") { }

    void OnBeforeWorldInitialized() override
    {
        AppearanceMgr::Instance().Reload();
    }

    void OnAfterConfigLoad(bool reload) override
    {
        if (reload)
            AppearanceMgr::Instance().Reload();
    }
};

class CustomNpcAppearanceCreatureScript : public AllCreatureScript
{
public:
    CustomNpcAppearanceCreatureScript() : AllCreatureScript("mod_customnpcs_appearance_creature") { }

    void OnCreatureAddWorld(Creature* creature) override
    {
        AppearanceMgr::Instance().Update(creature);
    }

    void OnAllCreatureUpdate(Creature* creature, uint32 /*diff*/) override
    {
        AppearanceMgr::Instance().Update(creature);
    }

    void OnCreatureRemoveWorld(Creature* creature) override
    {
        AppearanceMgr::Instance().Detach(creature);
    }
};

class CustomNpcAppearanceServerScript : public ServerScript
{
public:
    CustomNpcAppearanceServerScript() : ServerScript("mod_customnpcs_appearance_packets",
        { SERVERHOOK_CAN_PACKET_RECEIVE }) { }

    bool CanPacketReceive(WorldSession* session, WorldPacket const& packet) override
    {
        if (packet.GetOpcode() != CMSG_GET_MIRRORIMAGE_DATA || packet.size() < sizeof(uint64))
            return true;

        WorldPacket copy(packet); // Preserve the shared packet's read position for the core.
        copy.rpos(0);
        ObjectGuid guid;
        copy >> guid;
        return !AppearanceMgr::Instance().SendMirrorImage(session, guid);
    }
};

class CustomNpcAppearanceCommands : public CommandScript
{
public:
    CustomNpcAppearanceCommands() : CommandScript("mod_customnpcs_appearance_commands") { }

    ChatCommandTable GetCommands() const override
    {
        static ChatCommandTable outfitCommands =
        {
            { "create",     Create,     SEC_ADMINISTRATOR, Console::Yes },
            { "capture",    Capture,    SEC_ADMINISTRATOR, Console::No },
            { "set",        Set,        SEC_ADMINISTRATOR, Console::Yes },
            { "apply",      Apply,      SEC_ADMINISTRATOR, Console::No },
            { "spawn",      Spawn,      SEC_ADMINISTRATOR, Console::No },
            { "clear",      Clear,      SEC_ADMINISTRATOR, Console::No },
            { "clearspawn", ClearSpawn, SEC_ADMINISTRATOR, Console::No },
            { "info",       Info,       SEC_ADMINISTRATOR, Console::No },
            { "reload",     Reload,     SEC_ADMINISTRATOR, Console::Yes }
        };
        static ChatCommandTable customNpcCommands = { { "outfit", outfitCommands } };
        static ChatCommandTable commands = { { "customnpc", customNpcCommands } };
        return commands;
    }

private:
    static bool Create(ChatHandler* handler, uint32 id, uint32 race, uint32 gender)
    {
        if (!Enabled(handler))
            return false;
        if (!id || !CustomNpcs::IsPlayableRace(race) || gender > 1)
            return Fail(handler, "Usage: .customnpc outfit create <nonzero ID> <WotLK race ID> <gender: 0/1>");
        if (WorldDatabase.Query("SELECT outfit_id FROM mod_customnpcs_outfit WHERE outfit_id = {}", id))
            return Fail(handler, "That outfit ID already exists. Use set or capture to edit it.");
        Outfit outfit;
        outfit.id = id;
        outfit.race = static_cast<uint8>(race);
        outfit.gender = static_cast<uint8>(gender);
        return SaveOutfit(handler, outfit);
    }

    static bool Capture(ChatHandler* handler, uint32 id)
    {
        if (!Enabled(handler))
            return false;
        Player* player = handler->GetSession()->GetPlayer();
        Outfit outfit;
        outfit.id = id;
        outfit.race = player->getRace();
        outfit.gender = player->getGender();
        outfit.playerClass = player->getClass();
        outfit.skin = player->GetByteValue(PLAYER_BYTES, 0);
        outfit.face = player->GetByteValue(PLAYER_BYTES, 1);
        outfit.hair = player->GetByteValue(PLAYER_BYTES, 2);
        outfit.hairColor = player->GetByteValue(PLAYER_BYTES, 3);
        outfit.facialHair = player->GetByteValue(PLAYER_BYTES_2, 0);
        outfit.guild = player->GetGuildId();
        constexpr std::array<uint8, CustomNpcs::ArmorSlotCount> slots =
        {
            EQUIPMENT_SLOT_HEAD, EQUIPMENT_SLOT_SHOULDERS, EQUIPMENT_SLOT_BODY, EQUIPMENT_SLOT_CHEST,
            EQUIPMENT_SLOT_WAIST, EQUIPMENT_SLOT_LEGS, EQUIPMENT_SLOT_FEET, EQUIPMENT_SLOT_WRISTS,
            EQUIPMENT_SLOT_HANDS, EQUIPMENT_SLOT_BACK, EQUIPMENT_SLOT_TABARD
        };
        for (std::size_t slot = 0; slot < slots.size(); ++slot)
        {
            if ((slot == CustomNpcs::Head && player->HasPlayerFlag(PLAYER_FLAGS_HIDE_HELM)) ||
                (slot == CustomNpcs::Back && player->HasPlayerFlag(PLAYER_FLAGS_HIDE_CLOAK)))
                continue;
            if (Item const* item = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slots[slot]))
            {
                uint32 display = item->GetTemplate()->DisplayInfoID;
                // Capture the appearance exposed by transmog modules as well as ordinary equipment.
                sScriptMgr->OnGlobalMirrorImageDisplayItem(item, display);
                if (display > static_cast<uint32>(std::numeric_limits<int32>::max()))
                    return Fail(handler, "An equipped armor display cannot be stored as a signed outfit value.");
                outfit.armor[slot] = -static_cast<int32>(display);
            }
        }
        constexpr std::array<uint8, 3> weaponSlots =
            { EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND, EQUIPMENT_SLOT_RANGED };
        for (std::size_t slot = 0; slot < weaponSlots.size(); ++slot)
            if (Item const* item = player->GetItemByPos(INVENTORY_SLOT_BAG_0, weaponSlots[slot]))
                outfit.weapons[slot] = item->GetEntry();
        return SaveOutfit(handler, outfit);
    }

    static bool Set(ChatHandler* handler, uint32 id, std::string field, int32 value)
    {
        if (!Enabled(handler))
            return false;
        auto existing = AppearanceMgr::Instance().GetOutfit(id);
        if (!existing)
            return Fail(handler, "Unknown or invalid outfit ID. Create it first or inspect the SQL log.");
        Outfit outfit = *existing;
        for (std::size_t slot = 0; slot < CustomNpcs::ArmorSlotCount; ++slot)
        {
            if (field == CustomNpcs::ArmorColumns[slot])
            {
                outfit.armor[slot] = value;
                return SaveOutfit(handler, outfit);
            }
        }
        if (value < 0)
            return Fail(handler, "Only armor slots accept negative display IDs.");
        if (field == "mainhand")
            outfit.weapons[0] = value;
        else if (field == "offhand")
            outfit.weapons[1] = value;
        else if (field == "ranged")
            outfit.weapons[2] = value;
        else if (field == "guild_id")
            outfit.guild = value;
        else
        {
            if (value > 255)
                return Fail(handler, "Race, gender, class, and customization values must fit in one byte (0-255).");
            if (field == "race")
                outfit.race = value;
            else if (field == "gender")
                outfit.gender = value;
            else if (field == "class")
                outfit.playerClass = value;
            else if (field == "skin")
                outfit.skin = value;
            else if (field == "face")
                outfit.face = value;
            else if (field == "hair")
                outfit.hair = value;
            else if (field == "hair_color")
                outfit.hairColor = value;
            else if (field == "facial_hair")
                outfit.facialHair = value;
            else
                return Fail(handler, "Unknown outfit field. See docs/custom-npc-appearances.md for supported fields.");
        }
        return SaveOutfit(handler, outfit);
    }

    static bool Assign(ChatHandler* handler, uint32 id, bool spawnOnly)
    {
        if (!Enabled(handler))
            return false;
        if ((!id && !spawnOnly) || (id && !AppearanceMgr::Instance().GetOutfit(id)))
            return Fail(handler, "Unknown outfit ID. Use spawn 0 to keep one spawn's original appearance.");
        Creature* creature = Selected(handler, spawnOnly);
        if (!creature)
            return false;

        if (spawnOnly)
        {
            WorldDatabase.DirectExecute(
                "INSERT INTO mod_customnpcs_outfit_spawn (spawn_guid, outfit_id) VALUES ({}, {}) "
                "ON DUPLICATE KEY UPDATE outfit_id = VALUES(outfit_id)", creature->GetSpawnId(), id);
        }
        else
        {
            WorldDatabase.DirectExecute(
                "INSERT INTO mod_customnpcs_outfit_entry (creature_entry, outfit_id) VALUES ({}, {}) "
                "ON DUPLICATE KEY UPDATE outfit_id = VALUES(outfit_id)", creature->GetEntry(), id);
        }
        QueryResult saved = spawnOnly ? WorldDatabase.Query(
            "SELECT outfit_id FROM mod_customnpcs_outfit_spawn WHERE spawn_guid = {}", creature->GetSpawnId()) :
            WorldDatabase.Query("SELECT outfit_id FROM mod_customnpcs_outfit_entry WHERE creature_entry = {}",
                creature->GetEntry());
        if (!saved || saved->Fetch()[0].Get<uint32>() != id)
            return Fail(handler, "Could not save the assignment. Check the worldserver SQL log.");
        AppearanceMgr::Instance().Reload();
        handler->PSendSysMessage("Assigned outfit {} to {} {}. Spawn overrides take priority over entry assignments.",
            id, spawnOnly ? "spawn" : "NPC entry", spawnOnly ? creature->GetSpawnId() : creature->GetEntry());
        return true;
    }

    static bool Apply(ChatHandler* handler, uint32 id)
    {
        return Assign(handler, id, false);
    }

    static bool Spawn(ChatHandler* handler, uint32 id)
    {
        return Assign(handler, id, true);
    }

    static bool ClearAssignment(ChatHandler* handler, bool spawnOnly)
    {
        Creature* creature = Selected(handler, spawnOnly);
        if (!creature)
            return false;
        if (spawnOnly)
            WorldDatabase.DirectExecute("DELETE FROM mod_customnpcs_outfit_spawn WHERE spawn_guid = {}",
                creature->GetSpawnId());
        else
            WorldDatabase.DirectExecute("DELETE FROM mod_customnpcs_outfit_entry WHERE creature_entry = {}",
                creature->GetEntry());
        QueryResult remaining = spawnOnly ? WorldDatabase.Query(
            "SELECT outfit_id FROM mod_customnpcs_outfit_spawn WHERE spawn_guid = {}", creature->GetSpawnId()) :
            WorldDatabase.Query("SELECT outfit_id FROM mod_customnpcs_outfit_entry WHERE creature_entry = {}",
                creature->GetEntry());
        if (remaining)
            return Fail(handler, "Could not remove the assignment. Check the worldserver SQL log.");
        AppearanceMgr::Instance().Reload();
        handler->SendSysMessage("Removed assignment. The remaining assignment or original look applies next update.");
        return true;
    }

    static bool Clear(ChatHandler* handler)
    {
        return ClearAssignment(handler, false);
    }

    static bool ClearSpawn(ChatHandler* handler)
    {
        return ClearAssignment(handler, true);
    }

    static bool Info(ChatHandler* handler)
    {
        Creature* creature = Selected(handler, false);
        if (!creature)
            return false;
        auto outfit = AppearanceMgr::Instance().GetOutfitFor(creature);
        handler->PSendSysMessage("NPC entry {} / spawn {} / current display {} / assigned outfit {}.",
            creature->GetEntry(), creature->GetSpawnId(), creature->GetDisplayId(), outfit ? outfit->id : 0);
        if (outfit)
            handler->PSendSysMessage("Race {} / gender {} / class {} / skin {} / face {} / hair {} / "
                "color {} / facial hair {}.",
                outfit->race, outfit->gender, outfit->playerClass, outfit->skin, outfit->face, outfit->hair,
                outfit->hairColor, outfit->facialHair);
        return true;
    }

    static bool Reload(ChatHandler* handler)
    {
        AppearanceMgr::Instance().Reload();
        handler->SendSysMessage("Custom NPC outfits reloaded. Loaded NPCs refresh on their next update.");
        return true;
    }
};
}

void AddModCustomNPCsAppearanceScripts()
{
    new CustomNpcAppearanceWorldScript();
    new CustomNpcAppearanceCreatureScript();
    new CustomNpcAppearanceServerScript();
    new CustomNpcAppearanceCommands();
}
