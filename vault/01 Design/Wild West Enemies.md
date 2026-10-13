---
tags: [design, feature, enemies, theme, wild-west]
status: planned
updated: 2026-10-13
---
# Wild West Enemies — the Rattler Gang

> **Status: planned.** This is the roster for the first-playable theme, which the
> developer chose in the [[Game Design Document]]. The developer accepted it on
> 2026-10-13. Names are placeholders until the naming pass. The numbers are **first
> guesses**: they were drawn from the original's stat bands
> ([[Original Game - Enemies and Spawning]]), which the GDD now treats as loose
> reference only. Tune them fresh in playtests.

## Summary
The **Rattler Gang** (**[decided]** a placeholder name, chosen for real in the naming
pass with the agents and hub train; see [[Title Ideas]]) are cartoon outlaws who have hijacked a freight train. They fill
the 10 standard enemy slots that every theme uses (see the GDD):
- slots 0–3 are light grunts,
- slots 4–6 are mids, who also hold keys and carry blueprints,
- slots 7–8 are bosses,
- slot 9 is the boss minion.

Every enemy has one clear gimmick that reads from the side view and fits the comedy
tone.

## Player experience
- Lights come in crowds and go down in a few shots. They teach you to move, jump and
  shoot.
- Each mid arrives **alone first**, as a mini-boss beat with lights paused. Its gimmick
  forces a different answer: jumping, breaking a shield, or interrupting a charge.
- Bosses are a showdown on a flatbed car, with taunts, a big telegraphed move and
  help arriving from the gang.
- **No gore.** Knocked-out bandits **ragdoll onto the carriage**, their hat popping off
  with cartoon stars circling, then fade out after a moment (GDD: ragdoll knock-outs
  that stay on the train). Shields and props break into wood or metal chunks.

## Behaviour archetypes
These are the reusable AI behaviours this roster needs. Later themes (Ninjas, Undead,
Robots) reuse the same archetypes with different models and numbers, so this list is
effectively the enemy AI scope.

| Archetype | Behaviour | Original equivalent |
|---|---|---|
| **Walker** | Walks up and attacks at melee range | `NORMAL_ENEMY` |
| **Shooter** | A Walker that stops at range to fire a telegraphed shot, and switches to melee up close | `NORMAL_ENEMY` with a secondary weapon |
| **Leaper** | Melee, plus a periodic flip over the player or across a gap | `AGILE_ENEMY` |
| **Lobber** | Keeps its distance and throws arcing explosives; explodes on death | `COWARD_ENEMY` with a death weapon |
| **Grappler** *(new)* | Ropes a player and yanks them toward itself | — |
| **Charger** | Approaches, winds up, then charges. Enough damage during the wind-up staggers it | `BERSERKER_ENEMY` |
| **Shielded** | A frontal shield with its own HP blocks shots until it breaks; ranged behind the shield, melee up close | `SHIELD_ENEMY` |
| **Summoner boss** | Calls in slot-9 minions during the fight | `SPAWN_BOSS` |
| **Charger boss** | Leap attack plus a berserk charge with a stagger threshold | `BERSERKER_BOSS` |

**[proposed]** We interpret the original's unclear `BERSERK_HEALTH` as a **stagger
threshold**: deal that much damage during the wind-up and the charge is cancelled. This
gives co-op squads a clear "focus fire!" moment.

## Roster

Speeds are in original px/s, converted to studs/s at 15 px = 1 stud. Hitboxes are
width × height in studs.

### Lights (slots 0–3)
| Slot | Name | Archetype | HP | Speed | Hitbox | Cost | Attack | Gimmick |
|---|---|---|---|---|---|---|---|---|
| 0 | **Bandana Bandit** | Walker | 25 | 140 (9.3) | 1.3 × 5 | 2 | Melee punch | The basic grunt and the most common enemy. Flees in panic when set on fire. |
| 1 | **Rodeo Kid** | Leaper | 30 | 160 (10.7) | 1.3 × 5 | 3 | Melee | Cartwheels over the player every ~2.8 s, so you have to turn around. |
| 2 | **Six-Shooter** | Shooter | 35 | 130 (8.7) | 1.3 × 5 | 3 | Revolver shot at chest height | Stops, raises the gun (0.5 s tell) and fires one bullet you can **jump over**. |
| 3 | **Dynamite Dan** | Lobber | 30 | 150 (10) | 1.3 × 5 | 3 | Lit dynamite in an arc, fuse ~1.5 s | Hangs back. **Explodes when knocked out, hurting nearby bandits too**, which is great for chain kills. |

### Mids (slots 4–6): key holders and blueprint carriers
All mids have 160 HP, cost 15, a freeze scalar of 0.6 and a hitbox of about 2.4 × 5.7.

| Slot | Name | Archetype | Speed | Attack | Gimmick |
|---|---|---|---|---|---|
| 4 | **Lasso Lucy** | Grappler + Leaper | 170 (11.3) | Medium melee, plus lasso | Every ~5 s she throws a lasso along the ground (0.6 s tell). If it catches a player, she reels them in for a beating. **Jump to dodge it.** A teammate can shoot the rope to free a caught player, and the caught player can mash Jump to break free: **[decided]** ~1.5 s in co-op, **~0.75 s solo**, where nobody can shoot the rope. |
| 5 | **Big Bart** | Charger | 160 (10.7) | Medium melee; the charge knocks you back | Swigs from a jug as a wind-up (1 s), then charges down the carriage. Deal **30 damage during the wind-up** to stagger him. The charge can knock players into the gap between cars. |
| 6 | **Saloon Door Sam** | Shielded | 180 (12) | Shotgun blast behind the door, melee up close | Carries a pair of saloon doors as a **90 HP wooden shield** that blocks frontal shots. Break the doors, or jump over and hit him from behind. Without the doors he panics. |

**Key holders:** in a hostage event, one mid carries the **jail-car key ring** on their
belt. Knock them out, spin-attack the dazed bandit to shake the keys loose, grab the
keys, and free the hostage. (The original made you smash the corpse. We change that to
"shake down a dazed bandit" to keep it gore-free.)

**Blueprint carriers:** any light or mid can spawn with **stolen blueprints sticking out of
their saddlebag**. Knock them out to drop the blueprints ("Finders keepers!").

### Bosses (slots 7–8)
Each boss train picks one of the two bosses at random. Bosses have a freeze scalar of 0.3,
a hitbox of about 2.5–3.3 × 9.5 studs, a cost of 40, and notice the player at 400 px
(about 27 studs).

| Slot | Name | Archetype | HP | Speed | Attacks |
|---|---|---|---|---|---|
| 7 | **"Mad Dog" McGraw**, the gang's top gun | Charger boss | 600 | 250 (16.7) when charging, 180 (12) when walking | **Fan the hammer**: a 6-shot spread you dodge by jumping over or moving between shots. **Leap attack**: jumps to a player's position and lands with a shockwave. **Berserk charge**: stomps and snorts as a wind-up, then charges. Deal 100 damage during the wind-up to stagger him, and he's open to extra damage for 2 s. |
| 8 | **Ma Rattler**, the gang's matriarch, in a rocking chair bolted to a handcar | Summoner boss | 650 | 140 (9.3) | **Gatling sweep**: a slow sweep of bullets at low height; jump it. **"Get 'em, boys!"**: rings the dinner bell to call in 2–3 Rattler Runts (slot 9), every ~10 s and at 66% and 33% HP. **Rolling pin throw**: an arcing thrown attack. |

**Proposed boss taunts:**
- McGraw: "THIS TRAIN AIN'T BIG ENOUGH FOR THE BOTH OF US!", "DRAW!", "I'M THE FASTEST GUN ON THE RAILS!"
- Ma Rattler: "GET 'EM, BOYS!", "NOBODY TOUCHES MY TRAIN!", "EAT YER VEGETABLES!" (shared with Nana Nitro in [[Launch Agents]], kept as a running gag)

### Minion (slot 9)
| Slot | Name | Archetype | HP | Speed | Cost | Notes |
|---|---|---|---|---|---|---|
| 9 | **Rattler Runt** | Walker | 20 | 225 (15) | 2 | Ma's tiny sons in oversized hats. Fast and weak, they swarm in groups of 2–3. They're only spawned by Ma Rattler. (The original's slot 9 was also used only by summoning bosses.) |

### Hostage
**Conductor Earl**, a tied-up train conductor in the jail car. He has 25 HP and can be hit
by enemy fire, so protect him. He shouts "HELP!" until freed, then "MUCH OBLIGED!"

## Rules & numbers
- **[decided] A knockout is final.** Knocked-out bandits ragdoll, stay down and fade
  out. They never get back up or climb back on. "Gets back up unless you finish it" stays the **Undead** theme's
  signature, so the themes play differently. (The Smasher Drone's finishing move
  matters most there; see [[Gadgets and Mayhem]].)
- **[proposed] Enemy damage.** These are the original's base values, applied to the
  decided **100 HP pool** and scaled by the active agent's toughness (see the GDD). The
  starter agent takes 0.52 of each hit, so a light punch costs it about 1.6 HP, and
  Dynamite about 5.
  - Light melee: 3.
  - Mid melee: 6.
  - Boss melee: 8.
  - Proposed starting values the original doesn't have:
    - Six-Shooter bullet: 5.
    - Dynamite: 10 in a ~4-stud radius.
    - Shotgun blast: 8.
    - McGraw's spread: 4 per bullet.
    - Gatling: 2 per bullet.
    - Leap shockwave: 12.
- **[proposed] Attack cooldowns:**
  - 0.75 s for light melee,
  - 1 s for mid melee,
  - 2.5–4 s between ranged shots for lights.
- **[proposed] Wave composition.** The spawn budget and caps follow the original's
  `SPAWN_GROUP_NORMAL` curve. The order lights are introduced in, one every 30–45 s, is:
  Bandana Bandit, then Rodeo Kid, then Six-Shooter, then Dynamite Dan. After that each
  mid is introduced alone, in the order Big Bart, Saloon Door Sam, Lasso Lucy (simplest
  answer first).
- **[proposed] Co-op scaling.** Multiply the spawn budget and alive-cap by 1.0 / 1.6 /
  2.2 / 2.8 for 1 / 2 / 3 / 4 players. Multiply boss HP by 1.0 / 1.5 / 2.0 / 2.5. These
  are guesses to tune in playtesting.
- **[proposed] Charge speeds.** Player speed is now decided at **18–33 studs/s** (see the
  GDD), so every agent outruns McGraw's 16.7 studs/s charge and Big Bart's 10.7 studs/s
  walk. Charges are meant to be **jumped, not outrun**, so raise them:
  - Big Bart's charge: about **36 studs/s** (540 px/s).
  - McGraw's berserk charge: about **40 studs/s** (600 px/s).
  Walking speeds stay as listed. Rattler Runts (15 studs/s) are slower than every agent,
  which is fine because they're a swarm, not a chase.

## Art & audio needs
See [[Art Direction]] (still empty). Each enemy needs:
- a readable silhouette and colour per slot: hat shape and bandana colour tell slots apart,
- a hit reaction, a ragdoll knockout (with the hat pop), and a celebrate pose for when a player goes down.

Shared needs:
- props: dynamite, lasso, saloon doors, key ring, saddlebag blueprints, rocking chair on
  a handcar, dinner bell,
- dust and wood-splinter effects (no blood),
- comedic voice barks and taunts.

## Open questions
- Is damage high enough? Against the starter agent, a single light grunt needs about 48 s
  to down a player alone. Threat comes from crowds and mids. Check this in the first
  playtest.

## Implementation notes
- **M1 Session 4 (2026-10-13):** the four lights and Big Bart are built as greybox templates
  in `ServerStorage.Assets.Enemies.WildWest`. They run in [[EnemyService]] (archetypes Walker,
  Leaper, Shooter, Lobber and Charger) and spawn from [[SpawnService]].
  - The numbers are this note's first guesses, stored as template attributes.
  - The stagger threshold is implemented as proposed: 30 damage during the 1 s wind-up.
  - The Grappler, Shielded and boss archetypes, the other mids, the bosses and the Runts
    come in M3.

Related: [[Game Design Document]] · [[Original Game - Enemies and Spawning]] · [[Home]]
