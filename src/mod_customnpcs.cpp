/*
 * This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Affero General Public License as published by the
 * Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Config.h"
#include "Chat.h"
#include "ScriptedCreature.h"
#include "ScriptedGossip.h"

enum CustomNPCGossip
{
    CUSTOM_NPC_TEXT_ID       = 100000,
    CUSTOM_NPC_GOSSIP_HELLO = 1,
    CUSTOM_NPC_GOSSIP_OPT1  = 2,
};

class npc_custom_example : public CreatureScript
{
public:
    npc_custom_example() : CreatureScript("npc_custom_example") { }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        ClearGossipMenuFor(player);

        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Hello, adventurer!", GOSSIP_SENDER_MAIN, CUSTOM_NPC_GOSSIP_OPT1);

        SendGossipMenuFor(player, CUSTOM_NPC_TEXT_ID, creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        ClearGossipMenuFor(player);

        switch (action)
        {
            case CUSTOM_NPC_GOSSIP_OPT1:
                ChatHandler(player->GetSession()).PSendSysMessage("Welcome to the custom NPC!");
                CloseGossipMenuFor(player);
                break;
        }

        return true;
    }
};

class mod_customnpcs_worldscript : public WorldScript
{
public:
    mod_customnpcs_worldscript() : WorldScript("mod_customnpcs_worldscript") { }

    void OnBeforeConfigLoad(bool reload) override
    {
        if (!reload)
        {
            // Load conf settings on startup
        }
    }
};

// Register scripts — called from mod_customnpcs_loader.cpp
// Uncomment the lines below and add them to AddModCustomNPCsScripts() in the loader:
//   new npc_custom_example();
//   new mod_customnpcs_worldscript();
