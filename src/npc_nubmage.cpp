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

/// Portal destination table --------------------------------------------------
struct NubmagePortalDest
{
    uint32 optionId;   // gossip_menu_option.OptionID
    uint32 mapId;
    float  x, y, z, o;
    const char* label; // for logging only
};

static const NubmagePortalDest portalDests[] =
{
    // Coordinates sourced from AzerothCore spell_target_position table.
    // OptionID 1 — Thunder Bluff  (spell 3566 — Teleport: Thunder Bluff)
    { 1, 1,    -962.97f,   282.91f, 111.68f, 4.02f, "Thunder Bluff" },
    // OptionID 2 — Undercity      (spell 3563 — Teleport: Undercity)
    { 2, 0,    1773.43f,    61.31f, -46.32f, 2.43f, "Undercity"     },
    // OptionID 3 — Silvermoon     (spell 32272 — Teleport: Silvermoon)
    { 3, 530, 10021.26f, -7014.27f,  49.72f, 4.01f, "Silvermoon"    },
};

static constexpr uint32 PORTAL_DEST_COUNT = sizeof(portalDests) / sizeof(portalDests[0]);

/// creature_text group IDs (must match nubmage.sql)
enum NubmageTextGroups
{
    TEXT_GROUP_AD       = 0, // advertising yells  (SmartAI)
    TEXT_GROUP_TRASH    = 1, // trash talk          (SmartAI)
    TEXT_GROUP_NO_GOLD  = 2, // no-gold yell        (C++)
    TEXT_GROUP_SUCCESS  = 3, // success yell        (C++)
};

/// ---------------------------------------------------------------------------
/// npc_nubmage — Portal Service gossip handler
/// ---------------------------------------------------------------------------
class npc_nubmage : public CreatureScript
{
public:
    npc_nubmage() : CreatureScript("npc_nubmage") { }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        if (!sConfigMgr->GetOption<bool>("ModCustomNPCs.Enable", true))
        {
            CloseGossipMenuFor(player);
            return true;
        }

        // Let the DB-defined gossip_menu + gossip_menu_option populate the menu.
        // Returning false tells the core to build from DB rows, which is what we want.
        return false;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action) override
    {
        ClearGossipMenuFor(player);

        // DB-backed gossip can arrive here either as the raw OptionID or as a
        // gossip list index depending on the core path. Resolve through
        // PlayerTalkClass first so stale/shifted menu rows do not misroute the
        // destination.
        uint32 selectedAction = action;
        if (player->PlayerTalkClass)
        {
            uint32 const menuAction = player->PlayerTalkClass->GetGossipOptionAction(action);
            if (menuAction != 0)
                selectedAction = menuAction;
        }

        // Walk the portal table to find the matching OptionID.
        for (uint32 i = 0; i < PORTAL_DEST_COUNT; ++i)
        {
            if (portalDests[i].optionId != selectedAction)
                continue;

            const NubmagePortalDest& dest = portalDests[i];

            // Gold was already deducted by the core via BoxMoney before we get
            // here, so if we arrive in OnGossipSelect the player already paid.
            // Yell success and teleport.
            creature->AI()->Talk(TEXT_GROUP_SUCCESS, player);
            player->TeleportTo(dest.mapId, dest.x, dest.y, dest.z, dest.o);

            CloseGossipMenuFor(player);
            return true;
        }

        // Unknown option — just close
        CloseGossipMenuFor(player);
        return true;
    }
};

void AddNubmageScripts()
{
    new npc_nubmage();
}
