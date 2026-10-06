# A level 20–80 campaign adapted from Cataclysm and MoP

Research and design proposal, 6 October 2026.

**Expanded inventory:** [The full quest and asset manifest](broken-seal/README.md)
now specifies 252 quest records, with a 251-quest path for either faction,
along with chapter-by-chapter NPC, enemy, item, object and prerequisite lists.

## Agreed direction

- Use stories from the new Cataclysm/MoP zones, relocated into Kalimdor,
  Eastern Kingdoms, Outland, and Northrend.
- Keep the original named cast where their appearances can be recreated.
- Use an unmodified 3.3.5a client: no new maps, model ports, or client patches.
- Build a continuous main-story route alongside normal leveling quests.

**Recommendation:** Use Deepholm's repair-and-alliance structure as the central
plot, Hyjal's cult infiltration to introduce the enemy, and Stoneplow's returning
allies structure for the final payoff. Include smaller character stories as
chapters with their own outcomes.

This is a proposal for an original connected campaign using faithful story and
gameplay adaptations. The source stories were not originally one campaign.
Their new connections, locations, and appearances are custom writing. No quest
content has been implemented or deployed.

## Source stories worth adapting

### Hyjal: infiltration of the Twilight's Hammer

**Relocate to:** Charred Vale and nearby Stonetalon camps, approximately 20–30.

**Original story:** Enter the cult under a false identity, pass its training,
gather intelligence, manipulate its recruits, deliver a graduation speech,
and rescue Jarod Shadowsong. The speech involves responding to the crowd's
emotions, rather than simply completing a conversation.
[Source training sequence](https://www.wowhead.com/cata/quest=25294/walking-the-dog),
[Graduation Speech, 25315](https://www.wowhead.com/cata/quest=25315/graduation-speech),
[Twilight Riot, 25531](https://www.wowhead.com/cata/quest=25531/twilight-riot).

**Preserve:** The undercover identity, absurd and cruel training, audience
interaction, discovery of a captive ally, and the escape. These make a better
opening than beginning with an already famous hero fighting an elemental lord.

**Cast:** Jarod and the humanoid instructors are good candidates for native-race
outfits. Use stock cultist, elemental, and captive models. Jarod's appearance
here and subsequent involvement belong to the custom continuity.

**Campaign connection:** The intelligence reveals purchases of relics from
several excavations. The player initially understands a local cult operation;
its larger purpose emerges over later chapters.

**Implementation:** An owned disguise state, quest-checked gossip responses,
training scenes, and an escort rescue. Recreate the speech through normal gossip
choices with crowd reactions. This preserves its decision mechanic without
requiring the original later-expansion action-bar spells.

### Krasarang: Sunwalker Dezco and Leza

**Relocate to:** A neutral Dawnchaser expedition camp in Dustwallow Marsh, 30–35.

**Original story:** A tauren expedition follows a vision of a peaceful land.
Dezco needs help for his pregnant, sick wife. The player's efforts save their
sons, but Leza dies; Dezco must continue caring for the living.
[Character and expedition](https://warcraft.wiki.gg/wiki/Sunwalker_Dezco),
[Life, 30131](https://www.wowhead.com/mop-classic/quest=30131/life),
[Blizzard's related character story](https://worldofwarcraft.blizzard.com/en-us/news/9647266/new-world-of-warcraft-short-story-bleeding-sun).

**Preserve:** The search for remedies, uncertainty surrounding the promised
destination, Leza's death, the twins, and Dezco's continuing responsibility.
Give the outcome space through a vigil and later conversations.

**Cast:** Dezco, Leza, and the tauren expedition can retain their names and roles
with native tauren appearances. A Sunwalker NPC can use paladin behavior without
adding a playable tauren-paladin combination. Distinct infant representations
need an asset check; use a carefully staged tent scene if stock assets cannot
depict them convincingly.

**Campaign connection:** Dezco becomes a recurring ally with a family and a
reason to protect settlements. His later help is earned in this chapter.
The expedition's destination and its reason for being in Dustwallow are rewritten.
For Alliance players, the neutral field camp provides a custom humanitarian
entry into an originally Horde story.

### Krasarang: Zhu's Watch and the spreading despair

**Relocate to:** A small custom settlement on reachable Dustwallow ground, 35–40.

**Original story:** Investigate an apathetic village, repeatedly help Yi-Mo,
use Ken-Ken's unusual treatment, and eventually expel the possessing entity.
The villagers acknowledge the player's help and promise assistance in return.
[Zhu's Watch sequence and payoff](https://warcraft.wiki.gg/wiki/Zhu%27s_Despair),
[Zhu's Despair, 30090](https://www.wowhead.com/quest=30090/zhus-despair).

**Preserve:** The progression from apparently mundane troubles to possession,
the personal relationship with Yi-Mo, the treatment interaction, and the village
recovering after the encounter. The people helped here should appear again.

**Recreation required:** Ken-Ken, the pandaren villagers, and sha visuals are
significant stock-client compromises. Recreate the healer and villagers using
native characters if suitable appearances cannot be made. Native shadow/void
creatures can represent a custom despair curse, but are not exact sha visuals.
Name that replacement explicitly in the adaptation manifest.

**Campaign connection:** This introduces the effect of a damaged ward on people,
not just monsters. The cult later exploits that vulnerability. Treat this as
a more heavily rewritten MoP chapter than Dezco's.

### Twilight Highlands: the Wildhammer wedding

**Relocate to:** A custom Wildhammer gathering outside Aerie Peak in the
Hinterlands, 40–45.

**Original story:** Help the divided Wildhammer families, rescue Fanny,
prepare her wedding to Keegan Firebeard, then discover that the officiant is
a faceless infiltrator. Defeating it helps unite the families.
[Find Fanny, 28378](https://www.wowhead.com/cata/quest=28378/find-fanny),
[wedding progression and encounter](https://warcraft.wiki.gg/wiki/Wild%2C_Wild%2C_Wildhammer_Wedding).

**Preserve:** The family disagreements, rescue, practical preparations,
ceremony, transformation, and the families joining the fight. Include Russell
Brower's supportive performance as an encounter mechanic.

**Cast:** Fanny, Keegan, the families, and the officiant can use native dwarven
appearances; a stock faceless creature provides the reveal. Exact tattoos and
costumes are an appearance audit, not a reason to require a port.

**Campaign connection:** The player sees how deeply the enemy can infiltrate
ordinary life. The Wildhammer contingent becomes another earned final ally.
The gathering site is neutral for campaign purposes; stock Aerie Peak guards
keep their normal faction behavior. Horde participation needs custom dialogue
that earns an invitation into this originally Alliance chapter.

### Deepholm: Flint and Stonefather Oremantle

**Relocate to:** Badlands excavations and a separate story area near Uldaman,
45–50.

**Original story:** Repair and assist Flint, help his people against stone
troggs, then rescue his father after Flint's attempt to do so becomes dangerous.
Their help contributes to recovering a piece of the World Pillar.
[Flint's story](https://warcraft.wiki.gg/wiki/Flint_Oremantle),
[Rescue the Stonefather... and Flint, 26836](https://www.wowhead.com/cata/quest=26836/rescue-the-stonefather-and-flint).

**Preserve:** Flint as a personality, repairing him, earning the earthen's trust,
his impulsive rescue attempt, the family reunion, and the gift freely offered
afterward. This gives the relic recovery a human-scale reason to matter.

**Cast:** Native earthen, troggs, golems, and elemental models can recreate the
cast. Keep Flint and Oremantle's names with documented older appearances.

**Campaign connection:** The recovered fragment belongs to a custom ward
network. The World Pillar remains a Deepholm object in canon; this proposal does
not relocate that literal structure to Uldaman. Preserve the rescue and
restoration story while rewriting the artifact's identity and scale.

### Deepholm: earning the elementals' cooperation and The Binding

**Relocate to:** Un'Goro for the first negotiations, then Grizzly Hills and
Storm Peaks for the late restoration chapter.

**Original structure:** Recover three fragments through different alliances,
overcome the stone lords' distrust, and defend the restoration ritual against
Lorthuna with the allies earned earlier.
[Deepholm quest structure](https://warcraft.wiki.gg/wiki/Deepholm_quests),
[The Binding, 26971](https://www.wowhead.com/cata/quest=26971/the-binding).

**Preserve:** Multiple ways of earning help, the uneasy alliance with elementals,
visible progress, the return of an established adversary, and the defended
ritual. Retain Maruut's sacrifice if the adaptation includes his role.

**Cast:** Native-race Earthen Ring NPCs, earth elementals, and humanoid cultists
are practical recreations. Therazane herself is a poor exact-appearance target
on a stock client; give her negotiating role to an explicitly recreated council
or emissary rather than passing off a different elemental as her exact model.

**Campaign connection:** This supplies the overarching objective and its late
climax. Lorthuna can retain her name and be established well before the ritual.
The new ward network, its links to Outland materials, and its Northrend terminus
are original plot connections.

### Kun-Lai / Townlong: Suna Silentstrike

**Relocate to:** A scout expedition confronting raiders in Nagrand, 65–70.

**Original story:** Help comrades under pressure, attempt to recover Suna's
husband Lin, discover his death, and follow Suna's grief into revenge and
possession. The last confrontation ends with forgiveness and her death.
[Suna's arc](https://warcraft.wiki.gg/wiki/Suna_Silentstrike),
[The Point of No Return, 30784](https://www.wowhead.com/quest=30784/the-point-of-no-return).

**Preserve:** Meeting the relationship before its loss, the argument over acting
too soon or waiting, the failed rescue, revenge, possession, and forgiveness.
Allow the chapter its tragic ending; make the subsequent support of surviving
comrades part of the campaign.

**Recreation required:** The pandaren cast, yaungol, and sha require major visual
substitutions. Recreate the scouts and raiders with native models and disclose
any changed racial identities. A local shadow influence replaces the literal
Sha of Hatred if this remains wholly outside Pandaria.

**Campaign connection:** The player now understands the same danger seen in
the earlier village at a personal level. This is a strong optional donor for
the Outland act, but one of the largest fidelity compromises. If the recreated
cast does not work visually, write a native Outland character chapter instead
of claiming an exact Suna recreation.

### Vashj'ir: the Naz'jar Battlemaiden's three visions

**Relocate to:** Borean Tundra's Riplash coast and appropriate nearby sea ruins,
70–75.

**Original story:** A recovered blade lets the player experience the recent
past as a naga battlemaiden, learning about the naga's campaign against the
kvaldir across three playable visions.
[Three-vision structure](https://warcraft.wiki.gg/wiki/Visions_of_Vashj%27ir_Past),
[first vision and investigation](https://warcraft.wiki.gg/wiki/Visions_of_the_Past%3A_The_Invasion_of_Vashj%27ir),
[later vision sequences](https://warcraft.wiki.gg/wiki/Shimmering_Expanse_quests).

**Preserve:** The blade as the focal object, playing the other side, the three
episodes, and applying the intelligence afterward. These are visions of recent
battles, not an unrelated War of the Ancients flashback.

**Cast:** Wrath already has naga, kvaldir, and native races suitable for the
wavespeakers. Recreate the battlemaiden using an existing naga appearance.
Controlled-creature movement and supported actions need a prototype. Reuse
native spell definitions and rewrite prompts around them.

**Campaign connection:** Her campaign exposes the route taken by the final
stolen ward component. Preserve the naga's own motives; the link to the ward
network is custom writing. The coast fits the original enemy pairing better
than a generic inland ruin.

### Valley / Krasarang: the Stoneplow convergence and defense

**Relocate to:** A custom expedition settlement near Cenarion Hold in Silithus.
Introduce it around 55–60 and return for the level-80 finale.

**Original structure:** Several otherwise separate local stories and training
branches converge. Earlier acquaintances arrive to defend Stoneplow; the
player applies training from the Hidden Master against a seemingly impossible
colossus, then receives the community's gratitude.
[Converging prerequisites](https://warcraft.wiki.gg/wiki/Savior_of_Stoneplow),
[defense sequence](https://warcraft.wiki.gg/wiki/Valley_of_the_Four_Winds_storyline),
[colossus objective, 30627](https://www.wowhead.com/mop-classic/quest=30627/the-savior-of-stoneplow).

**Preserve:** Earlier help produces real reinforcements, a taught mechanic pays
off in the finale, defenders almost retreat, and the player saves a place they
know. The people and aftermath deserve as much attention as the boss.

**Recreation required:** Replace the wall breach with a local hive/ward breach
and mantid attackers with native Silithid types. A supported large insect model
can represent the colossus. The source finale launches the player into the
creature to strike from inside; this is a separate feasibility question. If it
cannot be reproduced with stock assets and supported controls, use a learned
weak-point attack and record that mechanical change.

**Campaign connection:** Jarod's survivors, Dezco, the village delegation,
Wildhammer riders, Flint's earthen, and elemental allies return. Their new joint
defense is original writing using Stoneplow's structure. The army assembles on
the strength of those individual stories.

## Proposed route: The Broken Seal

Working title. The premise is a cult campaign to break a network of protective
wards and exploit the resulting elemental and shadow disturbances. A small
recurring expedition grows into a coalition through the player's actions.

| Levels | Location | Chapter and source | What moves the story forward |
|---|---|---|---|
| 20–25 | Stonetalon | Custom introduction; begin Hyjal infiltration | A mundane job uncovers disappearances and cult recruitment |
| 25–30 | Stonetalon / Charred Vale | Hyjal cult school and Jarod rescue | Intelligence identifies the relic trade and its intermediaries |
| 30–35 | Dustwallow | Krasarang's Dezco/Leza story | The expedition gains a lasting ally and a personal stake |
| 35–40 | Dustwallow | Recreated Zhu's Watch arc | A settlement recovers from the shadow effects of a damaged ward |
| 40–45 | Hinterlands | Wildhammer families and wedding | The infiltrator reveals the enemy's reach; families commit to help |
| 45–50 | Badlands / Uldaman vicinity | Flint and the Stonefather | Rescue earns a ward fragment and the earthen's trust |
| 50–55 | Un'Goro | Deepholm-inspired elemental diplomacy | The expedition learns how to repair the wards and wins reluctant help |
| 55–60 | Silithus | Introduce the settlement and begin its preparation | Establish people worth returning to; discover an Outland supply route |
| 60–65 | Zangarmarsh / Terokkar | Custom caravan and investigation bridge | Recover evidence of the materials and people sustaining the operation |
| 65–70 | Nagrand | Recreated Suna arc or a native character chapter | A costly rescue confronts the danger of revenge and shadow possession |
| 70–75 | Borean Tundra coast | Vashj'ir battlemaiden visions | Learn where the stolen component went and how to recover it |
| 75–77 | Grizzly Hills | Custom northern investigation | Identify the ward's final installation without requiring early flying |
| 77–79 | Storm Peaks | Deepholm-inspired The Binding | Reunite allies, confront Lorthuna, and restore the northern ward |
| 79–80 | Return to Silithus | Stoneplow-style siege and aftermath | Earlier allies defend the settlement and the player completes the campaign |

This is a narrative route, not a coordinate-validated itinerary. Ground access,
stock hostile levels, and faction guards need checking before spawns are chosen.
Storm Peaks starts at 77 to align more naturally with its terrain, enemies,
and Wrath's normal flying progression.

## Making it feel like one long campaign

Use a small recurring cast instead of replacing all quest givers at each
border. Maruut or another recreated Earthen Ring coordinator can maintain the
investigation; Jarod can develop the coalition's response; Dezco and Flint
contribute their own priorities and expertise.

Each chapter should end with a changed relationship or a concrete discovery.
Letters and debriefings connect the chapters and explain why the expedition
travels next. Teach the final weak-point/ritual mechanic well before level 80.
The settlement introduced at 55 should remember the player on their return.

Keep the cast's independent goals: a family needs care, a wedding needs saving,
an earthen father needs rescuing. These make the coalition believable. The
sources supply those local stories; the cult's operation supplies continuity.

The initial design estimate was **roughly 140–180 quests**. Expanding the full
training, earthen-warfront, council and vision branches produces **251 required
quests per character**, plus the other faction's alternative entry record.
The [expanded inventory](broken-seal/README.md) is now the concrete scope to
review. This remains a main-story route, not an independent leveling-XP guarantee.

Use completed chapter quests plus minimum levels to unlock the next chapter.
When a player finishes ahead of the level gate, give a clear lead to normal
quests and a reminder of where the expedition will meet next. High-level
players should be able to continue the story without additional grind.

Provide normal level-appropriate XP and gear, selected personal keepsakes, and
a final reward built from supported Wrath items or mount spells. Custom titles
or achievements are not automatically available merely because their IDs are
written into SQL. Avoid reputation/daily gates in the required leveling route.

Assume both factions can follow a shared expedition, with separate entry quests
and explicit invitations for the originally faction-specific stories. This is
a design assumption, not a request to modify normal faction relationships.
Dungeon visits can be optional branches; keep the required campaign finishable
through solo outdoor scenes with NPC support.

## Stock-client feasibility and next implementation step

The existing module supplies native-race outfits and a C++ registration point.
It can host the new quest templates, NPCs, dialogue, conditions, SmartAI, and
dedicated scene controllers. All gameplay still needs authoring; a later
database is reference material, not a ready-to-import campaign.

Use existing terrain and supported gameobjects to stage camps, ceremonies,
excavations, and defenses. Quest phases can control dynamic actors, but cannot
change static terrain into new zone geography. Crowds, disguises, possession,
and ritual scenes need ownership and recovery logic so simultaneous players,
death, abandonment, and logout do not corrupt another player's run.

There is one useful nuance to the earlier model limitation: Wrath contains the
**Pandaren Monk companion**, added before 3.3.5a; AzerothCore's local creature
template also contains entry 36911. A scaled version could be previewed for a
limited pandaren NPC approximation. It does not provide MoP's playable race,
customization, wardrobe, female variants, or complete actor animation set.
Do not assume it solves the MoP cast problem.
[Companion history](https://warcraft.wiki.gg/wiki/Pandaren_Monk).

The first concrete implementation should be a **20–30 playable chapter**:
the recruitment investigation, cult disguise/training, interactive graduation
speech, Jarod rescue, and departure letter. This validates quest progression,
native outfits, scene ownership, and recoverability before committing to the
whole campaign. Inventory and outline all later chapters in parallel with
content design, then implement them sequentially.

The best-preserved source cast is in the Hyjal, Wildhammer, Flint, Dezco, and
battlemaiden chapters. Zhu's Watch, Suna, and Stoneplow provide strong stories
but need more explicit reconstruction. Keep an adaptation manifest for each:
source quest/actor, preserved interaction, replacement asset, rewritten lore,
and acceptance criteria.

Research used the source references linked above, the current module's
[compatibility notes](../README.md#335a-compatibility), and read-only inspection
of local AzerothCore creature data. Several web references were available through
indexed excerpts. This is a design-level shortlist; exact outfits, spells,
quest prerequisites, placement, and complete scene behavior are not yet verified.
