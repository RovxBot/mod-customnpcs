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

class mod_customnpcs_worldscript : public WorldScript
{
public:
    mod_customnpcs_worldscript() : WorldScript("mod_customnpcs_worldscript") { }

    void OnBeforeConfigLoad(bool reload) override
    {
        if (!reload)
        {
            // First load — nothing extra needed yet.
            // Config values are read on demand via sConfigMgr->GetOption().
        }
    }
};

class mod_customnpcs_playerscript : public PlayerScript
{
public:
    mod_customnpcs_playerscript() : PlayerScript("mod_customnpcs_playerscript") { }

    void OnPlayerLogin(Player* player) override
    {
        if (sConfigMgr->GetOption<bool>("ModCustomNPCs.Enable", true) &&
            sConfigMgr->GetOption<bool>("ModCustomNPCs.Announce", true))
        {
            ChatHandler(player->GetSession()).PSendSysMessage(
                "|cff4CFF00[mod-customNPCs]|r Module loaded.");
        }
    }
};

void AddModCustomNPCsWorldScripts()
{
    new mod_customnpcs_worldscript();
    new mod_customnpcs_playerscript();
}
