# Broken Seal: source gameplay and travel review

Researched **2026-10-08**. All 56 implemented quest records in Chapters 1-4; one prologue compatibility record is no longer offered. Chapters 5-14 remain design-only.

User chose source order: cult training and infiltration remain before Jarod's rescue.

Quest objectives, progression, player notes and source coordinates were compared with manifests and runtime code. Local distances are horizontal world units; they are straight-line lower bounds, not walking distances or claims of exact source-zone scale.

The original prologue contains authored investigations. Commander Jarod Shadowsong (25597) is a retail handoff to Ortell; the campaign lookout is an authored first reconnaissance, not a claim that retail has a spyglass objective.

## Corrected interactions

- The extra Name on the Papers trip is retired for new players. Existing holders settle it with Ortell; Signed in Blood follows the rewarded commander observation.
- The prologue trail stays away from Jarod's compound. The six scouts occupy the route to the separate roadside prisoners; the defended ward sites remain spread across the Vale.
- The recruit is lured through conversation. Labor uses a pick and five ore deposits; agility is a one-minute chase; hound feeding consumes meat hunted from basilisks.
- Ortell's repeated intelligence reports use a real native outhouse outside the training camp. The separate documents remain in their camps. Azennios and Okrog are encountered at distinct world locations without a cache or book acting as a summon button.
- The ascendant duel grants the source's strike and shield powers through quest-item foci. The ceremony draws the crowd's reaction and brings Ortell to the altar; the deposited key releases Jarod, who leaves by a direct escort.
- Dawnchaser poison evidence comes from five blades. A named enemy carries the excavation orders; the pool is a native pond with four guardians and Na Lek's healing aid. Nala, Kang and Dezco start their scenes directly.
- Yi-Mo is found before he is brought home. Ken-Ken requests the three-component remedy, then eighteen fangs and pigment; the eight patient treatments and ordered despair finale remain.

Rescued captives and captive Jarod use native per-player creature visibility keyed to saved quest progress. The ordinary world phase is unchanged. GM visibility deliberately remains unrestricted; test the player experience with GM mode off.

## Native-client substitutions

- No client patch or asset ports. Phase masks remain unchanged; private encounters and native per-player NPC visibility use saved quest progress.
- Later action bars become native gossip or supplied quest-item foci; the pick, chase, feeding, combat, timed answers and ascendant effects remain real actions.
- Quilen guardians use native earth elementals; Na Lek uses a native water elemental. Neutral raider scouts replace faction assassination.
- The current village uses a native fishing hamper for fish, native hives and shadow elementals for the recipe. Yi-Mo's later rolling controls become a private escort.
- The recovered key is linked to Azennios and deposited with the intel branch. Graduation still supplies the distraction; escape uses a native escort in place of the source phase transition.

## Existing realm upgrade

1. Rebuild the module. Apply `2026_10_08_00_broken_seal_source_gameplay.sql` to an installed Chapter 1/2 world database.
2. If Chapter 3 is installed, reapply `data/sql/db-world/base/broken_seal_chapter3.sql`. If Chapter 4 is installed, reapply its current base SQL afterward. These are updates to owned content; do not install optional chapters merely to run the correction.
3. Restart with the rebuilt binary after the SQL is ready. For a Chapter 1-only realm, reapply the current Chapter 1 base instead of the combined update. Fresh installs use the documented chapter order and current base SQL.

Quest IDs and rewarded history are retained. Changed active objectives receive the revised requirements; existing counter progress is kept, but old item supplies may no longer fit the new task. Recover tools at the contacts, and abandon/reaccept a changed active quest if its saved completion state or client cache does not match the new objectives. Do not reset unrelated quests or characters.

The earlier `05` route update remains available for its first revision. The new dated update is required when that earlier name is already marked applied. SQL import alone does not install the changed AI.

## Quest-by-quest evidence and travel

The distance column gives the shortest and longest objective-point distance from the giver. It excludes cross-map handoffs and does not measure Detour walking-path length. A local investigation or handoff can be short; a named opponent or exploration objective must have a physical subject and a coherent route.

| Quest | Source mechanic and evidence | Correction / retained adaptation | Objective distance |
|---|---|---|---|
| 900100: An Unusual Commission | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 1271–1271 m |
| 900101: An Unusual Commission | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 556–556 m |
| 900102: Travelers Who Never Arrived | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 6–6 m |
| 900103: Follow the Ash | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 16–171 m |
| 900104: Bring Them Home | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 152–157 m |
| 900105: A Stone That Should Be Quiet | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 395–551 m |
| 900106: The Same Hand | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 3–3 m |
| 900107: A Captive Commander | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/Commander_Jarod_Shadowsong) | The source quest is a handoff to Ortell. This campaign's first reconnaissance is authored and occurs before any required visit inside Jarod's camp. | 268–268 m |
| 900108: The Name on the Papers (retired) | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 0–0 m |
| 900200: Signed in Blood | [Talk to a recruit, lure him away, then use a blackjack to obtain his signed papers.](https://www.wowhead.com/cata/quest=25274/signed-in-blood) | The old crate substituted for the recruit conversation. | 140–162 m |
| 900201: Your New Identity | [Ortell supplies forged papers; presenting them to Condenna admits the player to the cult.](https://warcraft.wiki.gg/wiki/Your_New_Identity) | Carry the identity into the camp; disguise must be applied before the hostile contact can be used. | 473–473 m |
| 900202: Trial By Fire | [Defeat eight Fiery Instructors in the proving grounds.](https://www.wowhead.com/cata/quest=25223/trial-by-fire) | Count eight is retained; private successive opponents preserve the agreed small-camp population. | 0–0 m |
| 900203: In Bloom | [Gather five blossoms while avoiding Smolderos in the proving fields.](https://warcraft.wiki.gg/wiki/In_Bloom) | The implemented count was eight. | 139–173 m |
| 900204: Waste of Flesh | [Extinguish four burning supplicants with a supplied crystal before they die.](https://warcraft.wiki.gg/wiki/Waste_of_Flesh) | There were only three targets; a fourth distinct saved objective is restored. | 0–0 m |
| 900205: Twilight Training | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/Twilight_Training) | Retain the authored native-client adaptation; do not claim a literal source objective or geometry. | 10–13 m |
| 900206: Physical Training: Forced Labor | [Use a supplied pick to break five lodestone deposits; no ore delivery is required.](https://warcraft.wiki.gg/wiki/Physical_Training%3A_Forced_Labor) | The implementation instead shuttled loads between props about sixteen metres apart. | 39–61 m |
| 900207: Agility Training: Run Like Hell! | [Survive a one-minute pursuit by the Blazing Trainer without leaving the training grounds.](https://warcraft.wiki.gg/wiki/Agility_Training%3A_Run_Like_Hell%21) | The implementation was a four-flag checkpoint circuit without a pursuing trainer. | 0–0 m |
| 900208: Mental Training: Speaking the Truth to Power | [Answer ten yes/no questions before five-second deadlines; wrong or missing answers hurt.](https://warcraft.wiki.gg/wiki/Mental_Training%3A_Speaking_the_Truth_to_Power) | The native gossip controls are retained, and the missing penalty is restored. | 0–0 m |
| 900209: Spiritual Training: Mercy is for the Weak | [Kill five Failed Supplicants; source progression requires this branch.](https://warcraft.wiki.gg/wiki/Spiritual_Training%3A_Mercy_is_for_the_Weak) | The five-kill goal and required branch are retained. | 52–56 m |
| 900210: Walking the Dog | [Summon the hound with a leash, loot basilisk meat and feed five pieces to it.](https://warcraft.wiki.gg/wiki/Walking_the_Dog) | Three nearby feeding-station credits supplied meals without hunting or consuming meat. | 141–188 m |
| 900211: A Champion's Collar | [Kill the Spinescale Matriarch for the spiked hide used in the next match.](https://warcraft.wiki.gg/wiki/A_Champion%27s_Collar) | The actual named enemy and hide loot are retained. | 315–315 m |
| 900212: Grudge Match | [Challenge Gromm'ko, have the hound defeat Butcher, then face the angry ogre.](https://warcraft.wiki.gg/wiki/Grudge_Match) | The two-stage pet-and-owner fight is retained; supported gossip commands replace later action controls. | 0–0 m |
| 900213: Gather the Intelligence | [Obtain a communique and battleplans from separate enemy locations; hand in at Ortell's outhouse.](https://warcraft.wiki.gg/wiki/Gather_the_Intelligence) | The extra drop-box credit and expedition round trip are removed. The two locations remain separate. | 42–310 m |
| 900214: Seeds of Discord | [Mislead Karr'gonn, then kill Azennios at the Seat of the Chosen.](https://warcraft.wiki.gg/wiki/Seeds_of_Discord) | A named rendezvous replaces the scene-start cache. The key is a documented rescue adaptation. | 263–263 m |
| 900215: The Greater of Two Evils | [Ascend near Garnoth and use a five-percent-health strike and a ten-second, 95-percent shield.](https://warcraft.wiki.gg/wiki/The_Greater_of_Two_Evils) | The earlier form was cosmetic and normal combat replaced the ascendant powers. Native quest foci now supply both powers. | 160–160 m |
| 900216: Twilight Territory | [Kill ten Horrorguards near the Gates of Sothann.](https://warcraft.wiki.gg/wiki/Twilight_Territory) | The calling tablet/brazier is removed. Private successive opponents remain the native-client population substitute. | 256–256 m |
| 900217: Speech Writing for Dummies | [Intercept and kill Okrog as he leaves the Seat of the Chosen; Ortell supplies the speech preparation.](https://warcraft.wiki.gg/wiki/Speech_Writing_for_Dummies) | The speaking book had been an arbitrary enemy-summon button at Jarod's altar. | 163–163 m |
| 900218: Head of the Class | [Report to Mylva and claim the speaking slot after dealing with Okrog.](https://warcraft.wiki.gg/wiki/Head_of_the_Class) | An extra same-contact gossip credit is removed; the actual handoff remains. | Contact / handoff |
| 900219: Graduation Speech | [Read the crowd's mood and deliver ten responses at a podium; the crowd riots and Ortell approaches Jarod.](https://warcraft.wiki.gg/wiki/Graduation_Speech) | The podium and mood responses remain. The ceremony has a visible crowd response and Ortell, with key release as the documented native retelling. | 257–259 m |
| 900220: Twilight Riot | [After the distraction and release, meet Jarod outside the hostile camp.](https://warcraft.wiki.gg/wiki/Twilight_Riot) | The separate guard summon and three mandatory enforcer waves were invented. Escape now uses the deposited key and a straightforward escort. | 0–0 m |
| 900221: The Buyers Behind the Banner | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 392–392 m |
| 900222: A Letter Through the Marsh | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 7042–7042 m |
| 900300: Search Party | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/Search_Party) | Retain the authored native-client adaptation; do not claim a literal source objective or geometry. | 232–232 m |
| 900301: Poisoned! | [Collect five poisoned blades so Dezco can identify the poison reported by Chezin.](https://warcraft.wiki.gg/wiki/Poisoned%21) | Treating Leza at a tent had replaced evidence collection. Blade collection is restored. | 227–279 m |
| 900302: Skitterer Stew | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/Skitterer_Stew) | Retain the authored native-client adaptation; do not claim a literal source objective or geometry. | 8–151 m |
| 900303: Blind Them! | [Kill the opposing faction's scout before it reports the expedition.](https://warcraft.wiki.gg/wiki/Blind_Them%21_%28Horde%29) | The neutral campaign uses a hostile raider outrider, rather than faction murder or three supply-box clicks. | 245–245 m |
| 900304: Threat from the Marsh Ruins | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/Threat_from_Dojan) | Retain the authored native-client adaptation; do not claim a literal source objective or geometry. | 221–269 m |
| 900305: Herbal Remedies | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/Herbal_Remedies) | Retain the authored native-client adaptation; do not claim a literal source objective or geometry. | 10–220 m |
| 900306: The Relic Raiders' Agenda | [Recover orders from the raider leadership and learn why the ruins are being excavated.](https://warcraft.wiki.gg/wiki/The_Mogu_Agenda) | A cache, rune-device click and extra gossip had replaced confronting the leader. A native raider dominator carries the orders. | 276–276 m |
| 900307: The Pools of Youth | [Help Na Lek at the pool, fight four awakened guardians with healing aid, then obtain purified water.](https://warcraft.wiki.gg/wiki/The_Pools_of_Youth) | A dry-ground runestone instantly supplied water. A native pond and guardian encounter replace it. | 280–280 m |
| 900308: Life | [The Dawnchaser birth and loss story leaves both sons alive and Leza dead.](https://warcraft.wiki.gg/wiki/Life) | The ordered private family scene remains; Nala starts it, and the tent becomes shelter rather than a control. | 13–13 m |
| 900309: A Quiet Vigil | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 12–12 m |
| 900310: For the Living | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 0–16 m |
| 900311: Leave a Place Better | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 586–586 m |
| 900400: Ken-Ken | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/Ken-Ken) | Retain the authored native-client adaptation; do not claim a literal source objective or geometry. | 47–47 m |
| 900401: What's Eating the Village? | [Source cast and arc order are retained; current objective-level substitutions are described by the implementation and chapter guide.](https://warcraft.wiki.gg/wiki/What%27s_Eating_Zhu%27s_Watch%3F) | Retain the authored native-client adaptation; do not claim a literal source objective or geometry. | 9–12 m |
| 900402: Finding Yi-Mo | [First find Yi-Mo outside the village and speak to him.](https://warcraft.wiki.gg/wiki/Finding_Yi-Mo) | A pack started an escort before the follow-up quest. The first quest now finds the person. | Contact / handoff |
| 900403: Cheer Up, Yi-Mo | [Bring the unwilling Yi-Mo home; the source uses repeated rolling/kicking controls.](https://www.wowhead.com/mop-classic/quest=30082/cheer-up-yi-mo) | The supported substitution is a private guided walk with predators. It belongs to the follow-up, not the finding quest. | 0–87 m |
| 900404: Materia Medica | [Gather four honeycomb pieces, four mudfish and four salty cores for the initial remedy.](https://warcraft.wiki.gg/wiki/Materia_Medica) | Eight generic herb clicks and another hearth click had replaced the three-ingredient recipe. | 44–126 m |
| 900405: Why So Serious? | [Gather eighteen panther fangs and a pigment jar to prepare the mask.](https://warcraft.wiki.gg/wiki/Why_So_Serious%3F) | Three instant mask tests had replaced gathering the mask materials. | 71–129 m |
| 900406: Apply Directly to the Forehead | [Use the mask on eight wardens and defeat the manifestations released from them.](https://warcraft.wiki.gg/wiki/Apply_Directly_to_the_Forehead) | The eight distinct native patients and owned enemies remain. | 0–0 m |
| 900407: The Well Beneath the Ward | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 81–81 m |
| 900408: Zhu's Despair | [Defeat eight essences and exorcise Yi-Mo near the well, with Ken-Ken's help.](https://warcraft.wiki.gg/wiki/Zhu%27s_Despair) | The ordered fight is retained, with the party appearing at the actual well rather than requiring a scene-start prop. | 88–88 m |
| 900409: Hands Back to Work | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 32–60 m |
| 900410: When You Need Us | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | 0–56 m |
| 900411: The Families in the Hills | Original campaign connective quest; it has no original retail objective to reproduce. | Keep a physical interaction and meaningful handoff; retire unnecessary travel and scene starters. | Contact / handoff |

## Offline verification recorded

49 campaign Python tests passed. Chapter 1–4 standalone C++ checks and all four runtime syntax checks passed against the current core headers. Native audits checked 55 textured fallbacks, 62 grounded quest-prop placements, all current Chapter 2–4 ground points and navigation routes, the three shared surveyor escort connections and the preserved native quest areas.

Current Chapter 1–4 and full-hub SQL imported/reimported on both creature.id1 and legacy creature.id schemas. The October 8 Chapter 1/2 upgrade applied twice to the prior installed polish/quality revision, preserving 154 native NPCs, 155 native objects and quest links, surviving captive/ward GUIDs and a captive appearance override. Retired markers, the native concealed questgiver, source supplies and occupied-ID rejection were checked.

## Acceptance checks

Offline checks cover generated content, branch gates, native item/actor/object IDs, prop grounding and footprint relief, navigation, core syntax and disposable SQL fixtures. They do not establish client rendering, collision with newly spawned scenery, line of sight through stock models or successful live quest play.

In the client, verify the recruit conversation and blackjack arrival; all five lodestone uses; a full chase with combat, death and boundary interruption; five real hound meals; the two ascendant cooldowns, target restriction and shield expiry; field-contact hand-ins; the crowd response, key recovery and Jarod escape; the water encounter with full bags; and Yi-Mo's stage-specific location. Test two players with different progress/disguise states, and native quests/patrols around all encounter sites.

The remaining client acceptance work is explicit: this review and the offline checks are not a deployment or playthrough claim.
