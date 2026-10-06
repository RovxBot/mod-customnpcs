#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER2_INTEGRATION_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER2_INTEGRATION_H

#include <cstdint>
class Player;
class Creature;
class Unit;

// Shared Chapter 1 contacts keep their script and appearance. Chapter 2 adds its own menu actions.
bool BrokenSealChapter2Available();
bool BrokenSealChapter2AvoidCombat(Unit const* unit);
void BrokenSealChapter2Gossip(Player* player, Creature* creature);
bool BrokenSealChapter2Select(Player* player, Creature* creature, std::uint32_t sender, std::uint32_t action);
bool BrokenSealChapter2Altar(Player* player, Creature* creature);

#endif
