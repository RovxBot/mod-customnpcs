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

#include <algorithm>
#include <limits>
#include <string>

/// Portal destination table --------------------------------------------------
struct NubmagePortalDest
{
    uint32 optionId;   // gossip_menu_option.OptionID
    uint32 spellId;
    const char* label; // for logging only
};

static const NubmagePortalDest portalDests[] =
{
    // OptionID 1 — Thunder Bluff  (spell 3566 — Teleport: Thunder Bluff)
    { 1, 3566, "Thunder Bluff" },
    // OptionID 2 — Undercity      (spell 3563 — Teleport: Undercity)
    { 2, 3563, "Undercity"     },
    // OptionID 3 — Silvermoon     (spell 32272 — Teleport: Silvermoon)
    { 3, 32272, "Silvermoon"    },
};

static constexpr uint32 PORTAL_DEST_COUNT = sizeof(portalDests) / sizeof(portalDests[0]);
static constexpr uint32 NUBMAGE_GOSSIP_TEXT_ID = 4000000;
static constexpr uint32 COPPER_PER_GOLD = 10000;
static constexpr uint32 MAX_PORTAL_COST = std::numeric_limits<int32>::max();

static uint32 GetPortalCost()
{
    uint32 const maxGold = MAX_PORTAL_COST / COPPER_PER_GOLD;
    uint32 const priceGold = sConfigMgr->GetOption<uint32>("ModCustomNPCs.Nubmage.PortalPriceGold", 10);

    return std::min(priceGold, maxGold) * COPPER_PER_GOLD;
}

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

        // DB gossip options only supply OptionType to CreatureScript::OnGossipSelect,
        // which is identical for all three portal rows. Build the menu here so each
        // choice has a distinct action ID when it reaches the select handler.
        uint32 const cost = GetPortalCost();
        std::string const priceLabel = std::to_string(cost / COPPER_PER_GOLD) + "g";
        std::string const confirmation = "This portal costs " + priceLabel + ".";

        for (NubmagePortalDest const& dest : portalDests)
        {
            AddGossipItemFor(player, GOSSIP_ICON_CHAT,
                "Portal to " + std::string(dest.label) + " [" + priceLabel + "]",
                GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + dest.optionId,
                confirmation, cost, false);
        }

        SendGossipMenuFor(player, NUBMAGE_GOSSIP_TEXT_ID, creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action) override
    {
        ClearGossipMenuFor(player);

        if (sender != GOSSIP_SENDER_MAIN || action <= GOSSIP_ACTION_INFO_DEF)
        {
            CloseGossipMenuFor(player);
            return true;
        }

        uint32 const selectedOptionId = action - GOSSIP_ACTION_INFO_DEF;

        // Walk the portal table to find the matching OptionID.
        for (uint32 i = 0; i < PORTAL_DEST_COUNT; ++i)
        {
            if (portalDests[i].optionId != selectedOptionId)
                continue;

            const NubmagePortalDest& dest = portalDests[i];
            uint32 const cost = GetPortalCost();

            // A script that handles gossip selection prevents the core's default
            // money deduction, so charge here after verifying the current price.
            if (!player->HasEnoughMoney(cost))
            {
                creature->AI()->Talk(TEXT_GROUP_NO_GOLD, player);
                CloseGossipMenuFor(player);
                return true;
            }

            player->ModifyMoney(-static_cast<int32>(cost));

            // Use the real teleport spells so AzerothCore resolves the landing
            // point through spell_target_position instead of duplicating coords.
            creature->AI()->Talk(TEXT_GROUP_SUCCESS, player);
            player->CastSpell(player, dest.spellId, true);

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
