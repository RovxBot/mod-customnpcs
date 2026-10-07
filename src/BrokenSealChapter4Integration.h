#ifndef MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER4_INTEGRATION_H
#define MOD_CUSTOMNPCS_BROKEN_SEAL_CHAPTER4_INTEGRATION_H
#include <cstdint>
class Player;
class Creature;
std::uint32_t BrokenSealChapter4Gossip(Player* player, Creature* creature);
bool BrokenSealChapter4Select(Player* player, Creature* creature, std::uint32_t sender, std::uint32_t action);
#endif
