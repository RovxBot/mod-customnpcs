# Cataclysm and MoP quest adaptation shortlist

Researched 5 October 2026 for `mod-customnpcs` and AzerothCore 3.3.5a.

**Scope update, 6 October:** The requested direction is now stories from the
new Cataclysm/MoP zones relocated into the Wrath world, connected into a level
20–80 campaign, with no client ports and normal quests supplying additional XP.
See [the revised campaign proposal](level-20-80-campaign-proposal.md). The
shortlist below records the earlier interpretation and is not the current plan.

**Start with Maximillian of Northshire.** For a longer character story, consider
Fiona's Caravan once its visual assets are available. For a substantial MoP
project, choose the Dalaran chapter of Landfall before the warlock green-fire
chain. Both MoP candidates make unusually good use of locations already in Wrath.

These are implementation recommendations, not existing features of this module.
The fidelity and effort judgments below are engineering assessments. No quest
content was installed, and no scenes have been tested in game.

## What “faithful” means here

Preserve the named characters, story order, original locations where usable,
player interactions, dramatic payoff, and the purpose of the reward. Adjust
combat numbers and progression to Wrath. Record every change to geography,
appearance, acquisition, or mechanics; those changes determine how close the
adaptation is to the original.

There are two useful targets:

- **Faithful story and gameplay adaptation:** native Wrath assets can stand in
  for later cosmetics, with the substitutions disclosed.
- **Faithful visual recreation:** also supply the missing models, scenery,
  spell visuals, and animations through a compatible client patch.

The current module provides NPC outfits, SQL content, SmartAI examples, and a
C++ script registration point. It does not provide a later-expansion quest
runtime, Pandaria maps, modern worgen, or MoP scenarios. Its flight-map patch
demonstrates a client-patch workflow, but contains no quest assets.
See [the compatibility notes](../README.md#335a-compatibility),
[appearance limits](custom-npc-appearances.md#behavior-and-client-limits), and
[script loader](../src/mod_customnpcs_loader.cpp).

## Ranked shortlist

| Priority | Quest line | Expansion / audience | Why it earns a place | Main constraint | Relative effort |
|---|---|---|---|---|---|
| 1 | Maximillian of Northshire | Cata; both factions | Compact comedy, a persistent companion, memorable mounted finale | Recreate the chase and temporary action bar | Medium |
| 2 | Welcome to the Machine → Kingslayer Orkus | Cata; Horde | Comedy develops into an earned sacrifice | Changed Hillsbrad scenery; Ivar's later worgen model | Medium–high |
| 3 | Fiona's Caravan | Cata; both factions | Strong companion development and a traveling quest hub | Fiona, cart/harness, and finale location assets | High |
| 4 | Rhea / The Egg Lives On | Cata; both factions | Excellent emotional payoff and a meaningful keepsake | Deathwing, goblin guise, and post-Shattering Badlands locations | High |
| 5 | The Purge of Dalaran, both perspectives | MoP 5.1; faction branches | Major political story in existing Wrath geography | Isolated city state and Pandaria campaign bookends | High |
| 6 | Green fire / Pursuing the Black Harvest | MoP 5.2; warlocks | Investigation followed by a demanding class challenge | Solo instance behavior, MoP abilities, and the actual green-fire reward | Very high |

The first four are Cataclysm additions even where a current database page lists
them under MoP Classic. That distinction matters when identifying their original
content and dependencies.

## 1. Maximillian of Northshire — best first implementation

**Premise:** Become the squire of a well-meaning knight who insists Un'Goro's
dinosaurs are dragons. His attempts at chivalry culminate in an ill-advised
attack on the Devilsaur Queen and an escape on his horse, Pimento.
The finale turns his discarded equipment into ammunition.
[Original finale and player interaction](https://www.wowhead.com/quest=24707/the-ballad-of-maximillian).

**Scope:** Five quests. The opening unlocks two parallel tasks, then the hot
springs sequence and the finale:

| Source quest | Title |
|---|---|
| 24703 | An Important Lesson |
| 24704 | The Evil Dragons of Un'Goro Crater |
| 24705 | Town Dwellers Were Made to be Saved; the inspected 5.4.8 dump calls it Damsels Were Made to be Saved |
| 24706 | The Spirits of Golakka Hot Springs |
| 24707 | The Ballad of Maximillian |

This is the Cataclysm Un'Goro story, not his later Legion paladin campaign.
[Branch order](https://warcraft.wiki.gg/wiki/Un%27Goro_Crater_storyline),
[rescue quest](https://www.wowhead.com/cata/quest=24705/town-dwellers-were-made-to-be-saved).

**Preserve:** His following behavior, mistaken identifications, rescue scenes,
prayers to hostile steam elementals, the failed charge, the chase, and the
graduation from squire. The humor depends on witnessing the consequences of his
actions. A series of ordinary kill quests would lose much of its appeal.

**Build with this mod:** Dress a human NPC using the existing outfit system;
use native dinosaurs, elementals, horses, and supported goblin NPC appearances.
Add a C++ companion controller for dialogue and scene ownership. Use Wrath's
vehicle infrastructure for the chase, with a checked route and working throw
abilities. Audit the available vehicle seats and spell data before deciding
whether the action bar can use native spells or needs added client data.

**Fidelity:** The strongest candidate for a faithful story/gameplay adaptation
without a terrain port. The source human display is missing from the checked
Wrath DBC, but the outfit framework can reconstruct a human knight. The source
Devilsaur Queen display, 5305, is present. Exact clothing and the chase controls
still need validation. Wrath-level quest gear can retain the finale's theme of
receiving his remaining equipment.

## 2. Welcome to the Machine → Kingslayer Orkus — best short emotional arc

**Premise:** First act as a quest giver to Dumass, Orkus, and Johnny Awesome.
Later rescue the boastful Orkus, heal his frost wyrm Kasha, and accompany him
to Purgation Isle. The boast becomes real courage when he buys time for your
escape with Alliance battle plans.
[Opening](https://www.wowhead.com/quest=28096/welcome-to-the-machine),
[finale](https://www.wowhead.com/mop-classic/quest=28400/heroes-of-the-horde).

**Scope:** Seven selected quests, plus an optional connector. This extracts a
character arc from the larger Hillsbrad storyline:

`28096 Welcome to the Machine` →
`28345 *Gurgle* HELP! *Gurgle*` →
`28348 Stormpike Rendezvous` →
`28354 Kasha Will Fly Again` →
`28375 The Road to Purgation` →
`28397 They Will Never Expect This...` →
`28400 Heroes of the Horde!`.

The original connector is `28344 Can You Smell What the Lok'tar is Cooking?`.
The connection between the opening and the later arc must be deliberately
authored; this is not a claim that these seven quests are one uninterrupted
database chain. [Orkus versions and progression](https://www.wowhead.com/npc=47443/kingslayer-orkus).

**Preserve:** All three adventurers in the opening, Orkus's embarrassment in
shallow water, his affection for Kasha, his decision to distract the enemies,
Kasha returning for him, his death during the flight, and Cromush's recognition.
Do not invent a happy ending or award Kasha as a mount: neither is the original
payoff. [Character arc](https://warcraft.wiki.gg/wiki/Orkus).

**Build with this mod:** The outfit system suits Orkus especially well because
his warrior appearance draws on Wrath-era gear. Native frost-wyrm displays
29794 and 27066 are present. Script the actors, controlled flight, extraction,
and ending. Ensure the player can obtain the plans even though an NPC kills
their carrier; loot ownership is part of the implementation, not an incidental
detail.

**Fidelity:** Strong character fidelity on existing coast/island terrain.
Wrath Southshore is still an inhabited town, so it needs an isolated story state;
phasing NPCs does not turn its buildings into Cataclysm ruins. Ivar Bloodfang's
source display is also absent. A legacy worgen is an approximation; exact visuals
need a model port and potentially scenery work. The opening alone is a useful
small prototype, but does not deliver Orkus's complete story.

## 3. Fiona's Caravan — best longer companion campaign

**Premise:** Travel through the Eastern Plaguelands with Fiona and aspiring
paladins Gidwin Goldbraids and Tarenar Sunstrike. Recruit companions along the
road; the developing friendship pays off when the caravan rallies to rescue
Gidwin from Baroness Anastari.
[Story structure](https://warcraft.wiki.gg/wiki/Eastern_Plaguelands_storyline),
[rescue scene](https://warcraft.wiki.gg/wiki/Gidwin%27s_Fate_Revealed).

**Scope:** A multi-hub campaign. Start with the two missing companions,
`27367 Gidwin Goldbraids` and the matching Tarenar branch, proceed through
`27373 Onward, to Light's Hope Chapel`, and retain the road stops, recruitment,
disappearance/search sequence, and `27526 Gidwin's Fate Revealed`.
Treat Pamela/Darrowshire and other local branches separately when deciding the
full quest inventory; some material already exists in Wrath.

**Preserve:** Moving the hub with the group, conversations while traveling,
optional recruits and their contributions, the two paladins' relationship,
and the group rescue. Stationing all three characters permanently at Light's
Hope Chapel would remove the campaign's defining structure.

**Build with this mod:** Dress the dwarf and blood elf companions using native
races and gear. Add a caravan controller with route checkpoints, roster state,
quest prerequisites, and recoverable travel segments. Wrath roads and major
landmarks provide a useful starting point, but the original rescue building and
each stop require a geometry audit. Use a separate quest actor for Anastari so
the event does not change her Stratholme encounter.

**Fidelity:** Conditional on client assets. The checked Wrath DBC lacks Fiona's
34450 display, cart 33315, and harness 33314. A human Fiona and a generic wagon
would be an acknowledged adaptation. Prioritize a compatible worgen/cart port
if the goal is a recognizable visual recreation. Original Cata quest levels
also need adjustment to Wrath's higher-level Eastern Plaguelands population.

## 4. Rhea / The Egg Lives On — best dramatic story, with asset work

**Premise:** Help Rheastrasza research a way to purify a black dragon egg,
then protect the result from the black dragonflight. Deathwing's intervention
and Blam's subsequent revelation give the chain its emotional conclusion.
[Rhea's role](https://warcraft.wiki.gg/wiki/Rheastrasza),
[closing quest](https://www.wowhead.com/quest=27859/the-egg-lives-on).

**Scope:** A substantial Badlands arc with shared research quests and differing
Alliance/Horde middle sections. Reference anchors include:

- `27764 A Strange Request`, `27765 First Sample: Wild Eggs`,
  `27766 Second Sample: Whelps`, `27770 Lifting the Veil`,
  `27771 Third Sample: Implanted Eggs`, and `27769 Rhea Revealed`.
- Blam's research/excavation portion and the relevant faction's companions.
- Alliance `27832 The Hidden Clutch` / Horde `27897 The Hidden Clutch`;
  `27858` / `27898 Rheastrasza's Gift`; shared `27930 Devastation` and
  `27859 The Egg Lives On`.

These are anchors for a complete inventory, not permission to omit the middle
research and companion quests. Keep the faction branches distinct.

**Preserve:** Rhea's disguise/reveal, Nyxondra and the experiments, the successful
purification, the effort to keep it hidden, the sacrifice, and the revelation
that the purified black egg survived. The rewarded red whelp is Rhea's child;
it is not Wrathion. Preserve Rhea's Last Egg as a trinket that summons a combat
whelp. Turning it into a battle pet changes the reward and adds a subsystem
absent from Wrath. [Original item behavior](https://www.wowhead.com/item=63194/rheas-last-egg).

**Build with this mod:** Native dragon and whelp models support much of the
cast. The source Rheastrasza display 24737 and Nyxondra displays 8574/21616
exist in the checked Wrath DBC. Use explicit quest scene controllers and a
scripted item summon with Wrath-appropriate stats and cooldown behavior.

**Fidelity:** Exact Rhea's goblin guise and Deathwing need later assets. New
Kargath, Fuselight, and the post-Shattering landscape are not supplied by this
module. Reusing old Kargath and adjusting camps can preserve the narrative,
but must be described as geographical adaptation. This becomes an excellent
second-stage project once a Badlands asset/placement audit is available.

## 5. The Purge of Dalaran — best MoP story adaptation

**Premise:** Experience the rupture between the Kirin Tor and Sunreavers after
the Divine Bell theft. The Alliance branch follows Jaina and Vereesa's purge;
the Horde branch follows Rommath's effort to extract the Sunreavers and Aethas.
[Faction quest sequences](https://warcraft.wiki.gg/wiki/Purge_of_Dalaran),
[Alliance entry](https://www.wowhead.com/mop-classic/quest=32416/jainas-resolution),
[Horde entry](https://www.wowhead.com/quest=32402/the-situation-in-dalaran).

**Scope:** The Dalaran chapter of the 5.1 Landfall campaign, not the entire
Operation: Shieldwall/Dominance Offensive progression.

| Branch | Reference sequence |
|---|---|
| Alliance | 32414 Darnassus Attacked? → 32460 Tracking the Thieves → 32416 Jaina's Resolution → five local objectives: 32417 Sewer Cleaning, 32418 Unfair Trade, 32419 Nowhere to Hide, 32420 Cashing Out, 32421 Nowhere to Run → 32423 What Had To Be Done |
| Horde | 32402 The Situation In Dalaran → 32403 It Starts in the Sewers → 32404 Violence in the Arena → 32405 Hand of the Silver Covenant → 32406 A Tactical Assault → local objectives including 32408 The Silver Covenant's Stronghold, 32409 The Kirin Tor's True Colors, 32410 Krasus' Landing → The Remaining Sunreavers → 32412 One Last Grasp → 32413 A Return to Krasarang |

**Preserve:** Faction-specific objectives, civilian/prisoner distinctions,
rescue and suppression mechanics, the important confrontations, and the
consequences for relations between the factions. Follow the original quest
instructions and dialogue rather than adding an interpretation of who was
right. The outcome and its political cost are the reason to build this chapter.

**Build with this mod:** Use Dalaran and its sewers on Wrath's Northrend map,
with quest-specific actors, conditions, temporary hostility, and an exclusive
story phase. Human, blood elf, high-elf NPC, and dragonhawk assets provide a
strong base. Script rescue/teleport items and the major dialogue sequences.
Prevent normal city services and guards from interfering. A shared phase is
not automatically a private scene; overlapping runs need owned actors or a
bounded allocation of scene phases.

**Fidelity:** The city chapter is promising without a Pandaria terrain port.
The full arc has external dependencies: the Divine Bell setup and reputation
gating belong to Landfall, while the original closing report/return occurs in
Krasarang. Supply those locations for full fidelity, or disclose an adaptation
that gives the setup and closing dialogue through a custom framing sequence.
Do not claim that a Dalaran-only build reproduces all of Landfall, or award its
full campaign mount for this one chapter.

## 6. Green fire / Pursuing the Black Harvest — best ambitious class project

**Premise:** Investigate a forbidden tome, follow Jubeka's soulstones through
Outland, and infiltrate Black Temple to discover what happened to the Black
Harvest. The confrontation with Kanrethad rewards mastery of the class with
fel-green fire. Blizzard introduced the solo adventure and color-changing
reward in patch 5.2.
[Blizzard's patch announcement](https://worldofwarcraft.blizzard.com/en-us/news/8226552/patch-52-ptr-and-patch-notes-february-25).

**Scope:** The released chain uses `32295 An Unusual Tome`, the appropriate
`Reader for the Dead Tongue` variant, faction variants `32309/32310 A Tale of
Six Masters`, `32317 Seeking the Soulstones`, `32324 Seek the Signal`, and
`32325 Infiltrating the Black Temple`. The last quest contains a staged solo
adventure, rather than an ordinary dungeon clear.
[Chain](https://warcraft.wiki.gg/wiki/Green_fire_quest_chain),
[Outland investigation](https://www.wowhead.com/mop-classic/quest=32317/seeking-the-soulstones),
[scenario stages](https://warcraft.wiki.gg/wiki/Pursuing_the_Black_Harvest).

**Preserve:** The investigation and memory scenes, infiltration, Akama,
the temple's staged encounters, and Kanrethad's class-mechanic challenge.
Retain controlling the pit lord, its interrupt/dispel utility, the different
demon waves, and Jubeka's intervention. Tune the encounter for Wrath warlocks
while preserving those decisions. [Original encounter mechanics](https://warcraft.wiki.gg/wiki/Kanrethad_Ebonlocke_%28tactics%29).

**Build with this mod:** The capitals, Outland zones, and Black Temple geometry
already exist. Add a persistent solo scene controller using that geometry,
with an explicit strategy for coexistence with the normal Black Temple raid
and its instance script/lockouts. The reused location does not provide MoP's
scenario system. Wrath has Enslave Demon and Banish, but lacks abilities such
as Demonic Gateway; adapt those encounter dependencies deliberately. Later
NPC/pet spell definitions and action-bar presentation also need auditing.

**Fidelity:** Two major requirements make this a later project. The original
tome acquisition uses Isle of Thunder content, so moving acquisition to
Outland or a trainer is a disclosed change. The green-fire unlock also needs
an actual cosmetic implementation with compatible client spell data and
per-character unlock state. A global spell-visual replacement would recolor
other warlocks too. A title or item alone would omit the defining reward.
Prototype the reward and pit-lord controls before committing to the full chain.

## Other candidates and why they are behind these six

- **The Day that Deathwing Came** (`27713`, `27714`, `27715`): excellent three-part
  comedy involving playable tall tales. It requires transformations, scaling,
  unusual action bars, and Deathwing appearances; the Scar also changes the
  landscape. Consider it alongside Rhea after the Badlands asset work.
  [Quest reference](https://www.wowhead.com/mop-classic/quest=27713/the-day-that-deathwing-came),
  [gnome episode](https://www.wowhead.com/quest=27714/the-day-that-deathwing-came-the-real-story).
- **Savior of Stoneplow:** excellent convergence of earlier companions and
  local story branches, but Pandaria terrain and much of the cast are absent.
  It belongs in a Pandaria-port project; relocating it to a Wrath village would
  be a much looser adaptation.
  [Story and prerequisites](https://warcraft.wiki.gg/wiki/Valley_of_the_Four_Winds_storyline).
- **Pamela / Darrowshire alone:** worthwhile content, but already has a
  pre-Cataclysm version in Wrath. Evaluate the new Fiona connections as part of
  the caravan campaign instead of presenting the old chain as a new Cata port.
  [Cataclysm connection](https://warcraft.wiki.gg/wiki/Pamela_Redpath).

## Practical implementation order

1. Build all five Maximillian quests, including a playable chase. Verify solo
   and simultaneous players, abandonment, death, logout, and scene recovery.
2. Build Welcome to the Machine and then the Orkus arc if the accepted Hillsbrad
   scenery/worgen fidelity is sufficient. Otherwise, begin the asset work for
   Fiona's Caravan.
3. Prove Dalaran isolation and one rescue objective before expanding to both
   Purge branches. Decide how its Pandaria bookends will be represented.
4. Expand to Rhea or Fiona once the relevant visual/location requirements are
   met. Prototype green fire and pit-lord control separately before the full
   Black Harvest project.

For each project, translate the later database into AzerothCore's current quest
schema and conditions; do not import a 5.4.8 quest table directly. Allocate
collision-checked custom IDs and keep a mapping to the original quest IDs above.
Use base SQL and matching update SQL as this module already does. Ordinary
objectives and dialogue can use SmartAI; complex travel, parallel actors,
recovery, and combat stages justify dedicated C++ scripts.

Wrath phasing controls visibility of dynamic objects. It does not replace ADT
terrain or static map buildings. Adding a later display/spell number to SQL
also does not add its client assets. Those distinctions are particularly
important for Southshore, Badlands, Fiona, and the green-fire reward.

If the server retains Wrath-era chronology, a Bronze Dragonflight vision or
time-travel entrance is a reasonable **custom** wrapper for later events.
Alternatively, advance the server's story chronology explicitly. Either choice
is separate from keeping the inner quest story faithful.

## Research basis and remaining verification

The shortlist combines quest objectives and story references linked alongside
each entry with inspection of this repository's README, appearance guide,
loader, and SQL conventions. Some web pages were available only as search-index
excerpts; this is a researched shortlist, not an exhaustive transcription or
verified quest implementation.

The existing local research cache also supplied a
[SkyFire 5.4.8 release snapshot](https://github.com/ProjectSkyfire/SkyFire_548/releases/tag/24.001)
for source quest IDs, titles, branches, and NPC displays. Selected displays were
checked against the cached Wrath `CreatureDisplayInfo.dbc` used by the earlier
NPC work. The snapshot contains incomplete dependencies and NYI content; it is
supporting metadata, not evidence that the quests are scripted correctly.
Later spell records, rewards, vehicle seats, exact outfits, source coordinates,
collision/pathing, and complete quest prerequisites remain implementation audits.

Difficulty labels describe relative work, not delivery-time estimates. None of
the recommendations require increasing the client level cap beyond 80, but
combat tuning, reward scaling, and unsupported expansion systems need deliberate
conversion.
