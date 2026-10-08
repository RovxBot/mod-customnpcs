# Chapter 2: installation and gameplay

Chapter 2, **Inside the Twilight**, implements 23 quests for levels **25–30** using native 3.3.5a content.

[Source gameplay and travel review](source-review.md) records the checked source objectives, current distances, native-client substitutions and remaining acceptance work. Its October 8 controls supersede the earlier marker-based layouts.

## Installation

Apply the current [Chapter 2 base SQL](../../data/sql/db-world/base/broken_seal_chapter2.sql) after the appearance schema and earlier chapters. Reapplication preserves surviving spawn GUIDs, quest IDs/history and spawn appearance overrides. Ownership and dependency failures are intentional; do not import with `mysql --force`.

Existing Chapter 1/2 realms receive the core correction through `2026_10_08_00_broken_seal_source_gameplay.sql`. For installed Chapters 3/4, reapply their current base SQL in chapter order before restarting the rebuilt worldserver. Do not install an optional chapter merely to run the correction.

Enable the module and `ModCustomNPCs.BrokenSeal.Chapter2.Enable`. The ordinary world phase remains unchanged. A rebuilt/restarted binary is required for the new AI; SQL and appearance reloads are insufficient.

## Quests and controls

| Entry | Quest | Current action |
|---:|---|---|
| 900200 | Signed in Blood | Speak to a Twilight Recruit at the road checkpoint, lure him into cover, and use the blackjack to take his papers. |
| 900201 | Your New Identity | Present the altered papers to Condenna and pass the identity check. |
| 900202 | Trial By Fire | Defeat 8 trial fire elementals while the disguise is active. |
| 900203 | In Bloom | Gather 5 Flame Blossoms from the proving grounds. Avoid Smolderos. |
| 900204 | Waste of Flesh | Use the Frostgale Crystal to extinguish the flames on four immolated supplicants. |
| 900205 | Twilight Training | Report completion of all three admission trials and meet the two instructors. |
| 900206 | Physical Training: Forced Labor | Use the Twilight Pick to break 5 Darkwhisper Lodestones in the training gorge. |
| 900207 | Agility Training: Run Like Hell! | Stay alive and keep away from the Blazing Trainer for one minute inside the training grounds. |
| 900208 | Mental Training: Speaking the Truth to Power | Answer 10 orb questions correctly near Mylva; each offered question allows five seconds. |
| 900209 | Spiritual Training: Mercy is for the Weak | Defeat 5 failed supplicants in the cults lethal promotion trial. |
| 900210 | Walking the Dog | Use the Fiery Leash to summon the hound, then feed it 5 pieces of meat looted from Spinescale Basilisks. |
| 900211 | A Champion's Collar | Defeat the Spinescale Matriarch and bring its spiked hide to Devoran to make the hounds collar. |
| 900212 | Grudge Match | Defeat Butcher with your collared hound, then defeat Gromm'ko with the hound nearby. |
| 900213 | Gather the Intelligence | Recover the Twilight Communique from the recruiting compound and the Battleplans from the ritual compound. |
| 900214 | Seeds of Discord | Distract Karr'gonn and kill Azennios at the eastern rendezvous; recover the sacrificial key. |
| 900215 | The Greater of Two Evils | Use the ascendancy talisman to assume a fire-elemental form and defeat Garnoth. |
| 900216 | Twilight Territory | Defeat 10 Horrorguards at the northwestern trial ground while disguised. |
| 900217 | Speech Writing for Dummies | Kill Okrog as he leaves the ritual compound, then return to Ortell for the speech notes. |
| 900218 | Head of the Class | Speak to Mylva at the training compound to claim the speaking slot. |
| 900219 | Graduation Speech | Match 10 crowd moods with Inspire, Incite or Pander, then speak to Jarod at the altar. |
| 900220 | Twilight Riot | Use the sacrificial key to free Jarod, then accompany him to the expedition refuge. |
| 900221 | The Buyers Behind the Banner | Return to the quiet camp cache and recover the relic buyers' ledger. |
| 900222 | A Letter Through the Marsh | Deliver Jarod's introduction to Dezco at the neutral Dustwallow field camp. |

## Contacts and sequence

Reward Chapter 1's commander observation **900107**, reach level 25 and return to Ortell for Signed in Blood. The retired 900108 remains only for older quest logs. A recruit appears at the eastern road checkpoint for the quest holder; conversation lures him into the hollow, where the blackjack works after arrival.

Forged papers apply cover before Condenna is approached. The three admission quests remain an ALL join. The later physical, hound and intelligence branches also remain required before the advanced trials and ceremony. Mylva, Devoran, Condenna and Cargall remain in their compact compound.

Ortell's intelligence, assassination and speech reports use the native Outhouse Hideout west of the trainers. It is a questgiving shelter, not a drop-box credit. The camp version of Ortell is hidden from a player while he is operating from the hideout, and returns for the completed rescue.

Azennios and Karr'gonn are at the eastern rendezvous. Karr'gonn walks away after the false order; Azennios supplies the sacrificial key. Okrog walks the separate watch-road encounter. Neither is called by a box/book. The key is deposited with the assassination hand-in and reissued for the rescue after the ceremony.

The one-minute agility trial uses a slower pursuing Blazing Trainer. Stay alive, disguised, inside a 90-metre training radius and on foot; fighting contact with the pursuer is expected. Five lodestones require the supplied pick. Five hound meals consume actual basilisk meat; the leash works from the field during feeding.

The ascendant duel uses two supplied quest foci: a melee strike that removes five percent of Garnoth's maximum health with a 1.5-second recharge, and a shield that reduces his damage by 95 percent for ten seconds with a six-second recharge. Foci require the active owned duel and fire form. They are removed when the attempt ends.

Ten timed yes/no successes and ten crowd-mood responses remain saved in native counters. Stale menus cannot answer later prompts. Wrong or late orb answers damage the owner; an unsuccessful ceremony attempt keeps previous correct responses. A visible crowd reaction and Ortell's arrival connect the ceremony to the rescue.

Jarod's bound actor is hidden for the rescuing player while the private escort runs and after saved rescue credit/history. The party leaves by the escape route; there are no mandatory invented enforcer waves. The buyer ledger is at Azennios's separate post, so follow-up work does not return to the captive altar.

## Recovery and multiplayer

Contacts and the hideout replace active supplies and renew cover. The key is reissued only after the recorded Azennios defeat or deposited key. Correct answers, kills and meals survive retries. Full bags preserve those credits; retrieve a unique tool stored in the bank rather than creating another copy.

Private encounters use player ownership for commands, damage and credit. Fire and Horrorguard trials call one opponent at a time and give no farming XP/loot. Ordinary field enemies retain XP, coins and normal incidental loot. Death, logout, abandonment, map/phase changes, configuration disable or leaving an encounter ends it and removes temporary forms.

NPC visibility follows per-player quest progress without changing phase masks. GM mode bypasses those visibility checks; use GM mode off for player acceptance tests.

## Verification and client acceptance

The source review lists exact offline checks and the required client acceptance scenarios. No full worldserver build, realm deployment or stock-client playthrough is claimed. Terrain/navigation checks do not verify collision with newly spawned models or final clothing/weapon presentation.

```bash
python3 tools/generate_broken_seal_chapter2.py --check
python3 -m unittest discover -s tests -p 'test_broken_seal*.py'
python3 tools/render_broken_seal_source_review.py --check
```
