#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER3_INTEGRATION_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER3_INTEGRATION_H

#include <cstdint>
class Player;
class Creature;

// Keep the shared Chapter 2 Dezco; append Chapter 3 actions and select its appropriate greeting.
std::uint32_t BrokenSealChapter3Gossip(Player* player, Creature* creature);
bool BrokenSealChapter3Select(Player* player, Creature* creature, std::uint32_t sender, std::uint32_t action);

#endif
