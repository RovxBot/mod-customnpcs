/*
 * Copyright (C) 2026 mod-customNPCs contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * Uses the WotLK mirror-image protocol, as demonstrated by Rochet2's Dress NPCs:
 * https://rochet2.github.io/Dress-NPCs.html
 */

#include "CustomNpcAppearanceMgr.h"
#include "Config.h"
#include "Creature.h"
#include "DatabaseEnv.h"
#include "DBCStores.h"
#include "ItemTemplate.h"
#include "Log.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include "Opcodes.h"
#include "Player.h"
#include "WorldPacket.h"
#include "WorldSession.h"

namespace CustomNpcs
{
namespace
{
std::uint32_t ItemDisplay(std::uint32_t entry)
{
    if (ItemTemplate const* item = sObjectMgr->GetItemTemplate(entry))
        return item->DisplayInfoID;
    if (ItemEntry const* item = sItemStore.LookupEntry(entry))
        return item->DisplayInfoID;
    return 0;
}

bool HasAppearanceAura(Creature const* creature)
{
    return creature->HasCloneCasterAura() || creature->HasAuraType(SPELL_AURA_TRANSFORM) ||
        creature->HasAuraType(SPELL_AURA_MOD_SHAPESHIFT);
}
}

AppearanceMgr& AppearanceMgr::Instance()
{
    static AppearanceMgr instance;
    return instance;
}

bool AppearanceMgr::Validate(Outfit& outfit, std::string& error) const
{
    ChrRacesEntry const* race = sChrRacesStore.LookupEntry(outfit.race);
    if (!outfit.id || !IsPlayableRace(outfit.race) || !race || outfit.gender > 1 ||
        !IsPlayerClass(outfit.playerClass) || !sChrClassesStore.LookupEntry(outfit.playerClass))
    {
        error = "Use a nonzero outfit ID, a WotLK player race, gender 0/1, and a WotLK player class.";
        return false;
    }

    outfit.display = outfit.gender ? race->model_f : race->model_m;
    if (!outfit.display || !sCreatureDisplayInfoStore.LookupEntry(outfit.display))
    {
        error = "The race/gender base model is missing from the server DBCs.";
        return false;
    }

    for (std::size_t slot = 0; slot < ArmorSlotCount; ++slot)
    {
        if (!ResolveArmor(outfit.armor[slot], outfit.armorDisplays[slot], ItemDisplay,
            [](std::uint32_t display) { return sItemDisplayInfoStore.LookupEntry(display) != nullptr; }))
        {
            error = std::string("Invalid item entry or item display ID in ") + ArmorColumns[slot] + ".";
            return false;
        }
    }

    for (std::uint32_t entry : outfit.weapons)
    {
        if (entry && !sItemStore.LookupEntry(entry))
        {
            error = "Weapons must be item entries present in Item.dbc (or zero to hide them).";
            return false;
        }
    }

    return true;
}

void AppearanceMgr::Reload()
{
    auto catalog = std::make_shared<OutfitCatalog>();
    catalog->enabled = sConfigMgr->GetOption<bool>("ModCustomNPCs.Enable", true) &&
        sConfigMgr->GetOption<bool>("ModCustomNPCs.Appearance.Enable", true);

    if (catalog->enabled)
    {
        if (QueryResult rows = WorldDatabase.Query(
            "SELECT outfit_id, race, gender, class, skin, face, hair, hair_color, facial_hair, guild_id, "
            "head, shoulders, shirt, chest, waist, legs, feet, wrists, hands, back, tabard, "
            "mainhand, offhand, ranged FROM mod_customnpcs_outfit"))
        {
            do
            {
                Field* fields = rows->Fetch();
                auto outfit = std::make_shared<Outfit>();
                outfit->id = fields[0].Get<uint32>();
                outfit->race = fields[1].Get<uint8>();
                outfit->gender = fields[2].Get<uint8>();
                outfit->playerClass = fields[3].Get<uint8>();
                outfit->skin = fields[4].Get<uint8>();
                outfit->face = fields[5].Get<uint8>();
                outfit->hair = fields[6].Get<uint8>();
                outfit->hairColor = fields[7].Get<uint8>();
                outfit->facialHair = fields[8].Get<uint8>();
                outfit->guild = fields[9].Get<uint32>();
                for (std::size_t slot = 0; slot < ArmorSlotCount; ++slot)
                    outfit->armor[slot] = fields[10 + slot].Get<int32>();
                for (std::size_t slot = 0; slot < outfit->weapons.size(); ++slot)
                    outfit->weapons[slot] = fields[21 + slot].Get<uint32>();

                std::string error;
                if (!Validate(*outfit, error))
                {
                    LOG_ERROR("module.customnpcs", "Ignoring outfit {}: {}", outfit->id, error);
                    continue;
                }
                catalog->outfits.emplace(outfit->id, outfit);
            } while (rows->NextRow());
        }

        if (QueryResult rows = WorldDatabase.Query("SELECT creature_entry, outfit_id FROM mod_customnpcs_outfit_entry"))
        {
            do
            {
                Field* fields = rows->Fetch();
                uint32 entry = fields[0].Get<uint32>();
                uint32 outfit = fields[1].Get<uint32>();
                if (!sObjectMgr->GetCreatureTemplate(entry) || (outfit && !catalog->outfits.count(outfit)))
                {
                    LOG_ERROR("module.customnpcs", "Ignoring outfit assignment for NPC {}: invalid entry/outfit {}.",
                        entry, outfit);
                    continue;
                }
                catalog->entries.emplace(entry, outfit);
            } while (rows->NextRow());
        }

        if (QueryResult rows = WorldDatabase.Query("SELECT spawn_guid, outfit_id FROM mod_customnpcs_outfit_spawn"))
        {
            do
            {
                Field* fields = rows->Fetch();
                uint32 spawn = fields[0].Get<uint32>();
                uint32 outfit = fields[1].Get<uint32>();
                if (!spawn || !sObjectMgr->GetCreatureData(spawn) || (outfit && !catalog->outfits.count(outfit)))
                {
                    LOG_ERROR("module.customnpcs", "Ignoring outfit assignment for spawn {}: invalid spawn/outfit {}.",
                        spawn, outfit);
                    continue;
                }
                catalog->spawns.emplace(spawn, outfit);
            } while (rows->NextRow());
        }
    }

    LOG_INFO("module.customnpcs", "Loaded {} outfits, {} entry assignments and {} spawn overrides (enabled: {}).",
        catalog->outfits.size(), catalog->entries.size(), catalog->spawns.size(), catalog->enabled);
    _catalog.store(std::move(catalog));
}

std::shared_ptr<Outfit const> AppearanceMgr::GetOutfit(std::uint32_t id) const
{
    auto catalog = _catalog.load();
    auto const itr = catalog->outfits.find(id);
    return itr != catalog->outfits.end() ? itr->second : nullptr;
}

std::shared_ptr<Outfit const> AppearanceMgr::GetOutfitFor(Creature const* creature) const
{
    return _catalog.load()->Find(creature->GetEntry(), creature->GetSpawnId());
}

AppearanceMgr::CreatureKey AppearanceMgr::Key(Creature const* creature)
{
    return { creature->GetMapId(), creature->GetInstanceId(), creature->GetGUID() };
}

void AppearanceMgr::Apply(Creature* creature, Outfit const& outfit, AppliedAppearance const& appearance)
{
    creature->SetDisplayId(outfit.display, appearance.originalScale);
    // SetDisplayId recalculates these from the model; cosmetic outfits must not change melee reach.
    creature->SetFloatValue(UNIT_FIELD_BOUNDINGRADIUS, appearance.originalBoundingRadius);
    creature->SetFloatValue(UNIT_FIELD_COMBATREACH, appearance.originalCombatReach);
    creature->SetNativeDisplayId(outfit.display);
    creature->SetByteValue(UNIT_FIELD_BYTES_0, 2, outfit.gender);
    creature->SetUnitFlag2(UNIT_FLAG2_MIRROR_IMAGE);
    for (std::size_t slot = 0; slot < outfit.weapons.size(); ++slot)
        creature->SetVirtualItem(slot, outfit.weapons[slot]);
    if (outfit.weapons[0] || outfit.weapons[1])
        creature->SetSheath(SHEATH_STATE_MELEE);
}

void AppearanceMgr::Restore(Creature* creature, AppliedAppearance const& appearance)
{
    creature->SetNativeDisplayId(appearance.originalNativeDisplay);
    if (creature->GetDisplayId() == appearance.outfit->display)
    {
        creature->SetDisplayId(appearance.originalDisplay, appearance.originalScale);
        creature->SetFloatValue(UNIT_FIELD_BOUNDINGRADIUS, appearance.originalBoundingRadius);
        creature->SetFloatValue(UNIT_FIELD_COMBATREACH, appearance.originalCombatReach);
        creature->SetByteValue(UNIT_FIELD_BYTES_0, 2, appearance.originalGender);
    }
    if (!appearance.originalMirrorFlag && !creature->HasCloneCasterAura())
        creature->RemoveUnitFlag2(UNIT_FLAG2_MIRROR_IMAGE);
    for (std::size_t slot = 0; slot < appearance.originalWeapons.size(); ++slot)
        creature->SetVirtualItem(slot, appearance.originalWeapons[slot]);
}

void AppearanceMgr::Update(Creature* creature)
{
    if (creature->IsPet())
        return;
    auto outfit = GetOutfitFor(creature);
    CreatureKey const key = Key(creature);
    AppliedAppearance previous;
    bool tracked = false;
    {
        std::lock_guard<std::mutex> guard(_appliedMutex);
        if (auto const itr = _applied.find(key); itr != _applied.end())
        {
            previous = itr->second;
            tracked = true;
        }
    }
    if (!outfit && !tracked)
        return;

    bool refresh = false;
    if (tracked && previous.entry != creature->GetEntry())
    {
        // UpdateEntry already installed the new template's model and equipment.
        if (!creature->HasCloneCasterAura() &&
            !(creature->GetCreatureTemplate()->unit_flags2 & UNIT_FLAG2_MIRROR_IMAGE))
            creature->RemoveUnitFlag2(UNIT_FLAG2_MIRROR_IMAGE);
        Remove(creature);
        tracked = false;
        refresh = true;
    }

    if (!outfit)
    {
        if (tracked)
        {
            Restore(creature, previous);
            Remove(creature);
            refresh = true;
        }
    }
    else if (HasAppearanceAura(creature) || (tracked && creature->GetDisplayId() != previous.outfit->display &&
        !creature->GetCreatureTemplate()->GetModelWithDisplayId(creature->GetDisplayId()) &&
        creature->GetDisplayId() != previous.originalDisplay))
    {
        // Preserve spell/script morphs and let real clone requests reach the core.
        if (tracked && !previous.suspended)
        {
            if (!previous.originalMirrorFlag && !creature->HasCloneCasterAura())
                creature->RemoveUnitFlag2(UNIT_FLAG2_MIRROR_IMAGE);
            previous.suspended = true;
            std::lock_guard<std::mutex> guard(_appliedMutex);
            _applied[key] = previous;
        }
    }
    else
    {
        if (!tracked)
        {
            previous.entry = creature->GetEntry();
            previous.originalDisplay = creature->GetDisplayId();
            previous.originalNativeDisplay = creature->GetNativeDisplayId();
            previous.originalScale = creature->GetObjectScale();
            previous.originalBoundingRadius = creature->GetFloatValue(UNIT_FIELD_BOUNDINGRADIUS);
            previous.originalCombatReach = creature->GetFloatValue(UNIT_FIELD_COMBATREACH);
            previous.originalGender = creature->getGender();
            previous.originalMirrorFlag = creature->HasUnitFlag2(UNIT_FLAG2_MIRROR_IMAGE);
            for (std::size_t slot = 0; slot < previous.originalWeapons.size(); ++slot)
                previous.originalWeapons[slot] = creature->GetVirtualItemId(slot);
        }
        bool const changed = !tracked || previous.outfit != outfit || previous.suspended ||
            creature->GetDisplayId() != outfit->display;
        if (changed)
        {
            Apply(creature, *outfit, previous);
            previous.outfit = outfit;
            previous.suspended = false;
            {
                std::lock_guard<std::mutex> guard(_appliedMutex);
                _applied[key] = previous;
            }
            refresh = true;
        }
        else if (!creature->HasUnitFlag2(UNIT_FLAG2_MIRROR_IMAGE))
            Apply(creature, *outfit, previous); // Respawn may reset flags and equipment.
    }

    if (refresh && creature->IsInWorld())
    {
        // Recreate the client object to invalidate cached armor even when race/gender is unchanged.
        creature->DestroyForVisiblePlayers();
        creature->UpdateObjectVisibility();
    }
}

void AppearanceMgr::Remove(Creature const* creature)
{
    std::lock_guard<std::mutex> guard(_appliedMutex);
    _applied.erase(Key(creature));
}

void AppearanceMgr::Detach(Creature* creature)
{
    AppliedAppearance previous;
    {
        std::lock_guard<std::mutex> guard(_appliedMutex);
        auto const itr = _applied.find(Key(creature));
        if (itr == _applied.end())
            return;
        previous = itr->second;
        _applied.erase(itr);
    }
    // RemoveFromWorld may be followed by AddToWorld on the same object.
    // Restore before forgetting its original look so a re-add cannot capture the outfit as the fallback.
    if (previous.entry == creature->GetEntry())
        Restore(creature, previous);
}

bool AppearanceMgr::SendMirrorImage(WorldSession* session, ObjectGuid guid) const
{
    if (!session || !session->GetPlayer() || !session->GetPlayer()->IsInWorld())
        return false;
    Player* player = session->GetPlayer();
    Unit* unit = ObjectAccessor::GetUnit(*player, guid);
    Creature* creature = unit ? unit->ToCreature() : nullptr;
    if (!creature || !player->HaveAtClient(guid) || HasAppearanceAura(creature))
        return false;
    auto outfit = GetOutfitFor(creature);
    if (!outfit || creature->GetDisplayId() != outfit->display || !creature->HasUnitFlag2(UNIT_FLAG2_MIRROR_IMAGE))
        return false;

    WorldPacket response(SMSG_MIRRORIMAGE_DATA, 68);
    WriteMirrorImageData(response, guid, *outfit);
    session->SendPacket(&response);
    return true;
}
}
