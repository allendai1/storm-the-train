---
tags: [design, original-game, mechanics, loop, economy, spec, combat, enemies]
status: planned
updated: 2026-10-16
---
# Original Mechanics Match

> **Status: planned. [decided 2026-10-16]** The spec for [[0012-match-the-original]]:
> Train Mayhem plays like *Storm the Train* wherever it can, **keeping co-op**, **final
> knockouts** and **no ads**. **This note wins over any older note it conflicts with**
> (the older notes carry a banner pointing here). Values come from the decompile notes in
> [[Original Game]] (compiled 2026-10-16); the area-by-area comparison is
> [[Differences from the Original]].
>
> **Tags:**
> - **[orig]** is the original's value, converted (15 px = 1 stud).
> - **[co-op]** is our change so it works with 1–4 players.
> - **[ours]** is a value the vault doesn't have for the original, so we chose it; tune it.
> - **[keep]** is our existing rule, kept on purpose.

## 0. The scale rule
- **Our 100 HP = the original's 10 HP.** So **every original value that hurts or heals a
  player is ×10**: enemy damage, explosions on players, heals, health pickups, the mech
  timer drain per point. Light melee is 30, mid melee 60, boss melee 70–100.
- **Damage to enemies is not scaled**: enemy HP is already on the original's scale
  (lights 18–45, mids 160, bosses 550–700).
- Speeds and distances convert at 15 px = 1 stud. Gravity is the original's 2× world
  gravity: **130.7 studs/s²** for agents and enemies.

## 1. The run
### 1.1 Shape [orig]
- A run starts **on the hub train** (the original's Eagle start), then leaps to train 1.
- **Every hostile train** is laid out as:
  `span | event | span | … | span | BOSS | span | CHECKPOINT`.
  - **Events per train:** train 1 has 0–1 deck events; from train 3 on, 1–2 (the number of
    events ramps from 1–2 to 2–3 including the boss, finished by train 3).
  - **Span between events:** 400 studs on train 1, falling to 350 by train 3.
- **Every train ends with a boss**, then a **checkpoint** (the hub train pulls alongside),
  then the leap to the next train. **No legs**: the old 3-train legs are gone.

### 1.2 Train assembly [orig]
- Carriages are 16.7 or 33.3 studs (ours: 17 and 33 [keep]); the engine is **50 studs**.
- Built procedurally in **appearance runs** of 133–167 studs, each looking different from
  the last. Run lengths: coaches 2–3, tall freight 2–3, flatbeds 1–2. Allowed next:
  coach → coach or flatbed; tall → tall, flat, engine or tender; flatbed → anything.
- Every train ends with **3 coal tenders and the engine** (about 100 studs, with an engine
  coin shape). This settles the coal tender question in [[Feel and Look Asset Specs]] Q2:
  a `Tender` template is needed.
- The next train starts **31.7 studs** after the old one's end, with a **100-stud landing
  zone** of low coaches and flatbeds.
- [ours] Our current kit maps to the height classes: Boxcar and CattleCar are tall
  freight, Caboose a coach, Flatbed a flatbed, WaterTanker a tender. The gap between cars
  stays `CARRIAGE_GAP` 3 [keep].

### 1.3 The event deck [orig]
- A **shuffled deck** of events, dealt without repeats until empty, then reshuffled.
  Missions can push their event to the front (`PushEventFirst`).
- The deck is the original's: **Hostage, Jetpack, Rolling Ball (CDW) and Survival**
  ([decided 2026-10-16]; the vehicle events are designed in §8.3–8.4). Until the vehicles
  are built, the deck holds Hostage and Survival.
- **Events unlock through missions** [orig]: an event only enters the deck once the
  mission that introduces it is done (kill a boss, rescue a hostage, ride the ball, kill 100
  with the jetpack, survival). That's the original's way of teaching events one at a time.
  [co-op] The deck uses the **host's** unlocks (the party leader on the queue pad).
- **The Thief train goes.** Blueprint thieves come from a play-time timer instead (§9.4).
- **Event tier = floor(score ÷ 40,000).** It sets boss count, adds, survival waves and
  vehicle targets. [co-op] Use the **average score per player** (squad score ÷ players),
  so a big party doesn't race up the tiers.

### 1.4 The boss, every train [orig]
- **Arena:** about **67 studs** of level carriages (adjacent floors within 2 studs), then a
  gap car. Barriers lock both ends; a "BOSS" indicator.
- **Start:** everyone flees and spawning pauses → a **2 s** camera cutscene → boss 1 taunts
  (1.5 s bubble), boss 2 a second later → health bars appear. Bosses waiting in Idle are
  invulnerable.
- **By tier:**

  | Tier | Squad average score | Bosses | Adds |
  |---|---|---|---|
  | 0 | 0 | 1 | none |
  | 1 | 40k | 1 | stage 1: a wave every 10 s, cost 2–3, cap 4, lights 0–1 |
  | 2 | 80k | 1 | stage 2: every 8 s, cost 3–5, cap 6, lights 0–3 |
  | 3 | 120k | **2** | none |
  | 4 | 160k | 2 | stage 1 |
  | ≥ 5 | 200k | 2 | stage 2 |

- **Win:** each player gets **500 × f coins and 20,000 × f score**, f = 0.25 + 0.15 × tier
  (max 1). The barrier opens and spawning resumes.
- Which boss: one of the theme's two at random (two different ones at tier 3+) [ours].
- [co-op] Boss HP keeps our party scaling (×1.0 / 1.5 / 2.0 / 2.5 for 1–4 players, as in
  [[Wild West Enemies]]) [keep].

### 1.5 The checkpoint, every train [orig]
In order:
1. The train ends; the squad **leaps to the hub train** (§2).
2. **Blueprints are banked.**
3. **Boosters are cleared.**
4. The **hub pods**: HEALTH (paid heal, §9.2), BARRACKS, VAULT (the Armory), MISSIONS,
   SURPLUS, CHALLENGES.
5. The **booster menu**.
6. [co-op] The **continue or cash-out vote** [keep]: no timer, a tie continues, 90 s AFK
   counts as continue.
7. **Leap to the next train**, and the **theme changes** to a random unlocked theme other
   than the current one (missions can force one). Only Wild West exists for now.

- **The free full heal is gone.** Downed and spectating players [co-op] still come back at
  the checkpoint, at full health [keep].

### 1.6 How a run ends
- [co-op] A **squad wipe** or a **cash-out** [keep]. Coins and score are kept; carried
  blueprints are lost on a wipe.

## 2. The train leap (TrainJump) [orig]
After the train's engine, and again from the hub train to the next train:
1. A **cutscene pan** to the jump point (the carriage end − 5.3 studs), held 1 s, with a
   "JUMP FROM HERE" marker. Gadgets and the HUD bar hide.
2. **Auto-run:** input locked; speed ramps **22 → 45.3 studs/s at +30.7 studs/s²** (about
   0.76 s).
3. **28.3 studs before the jump point**, a sensor unlocks **jump only**.
4. On the jump: the leap animation; jump re-locks; gadgets return.
5. On landing: **spin locked for 0.2 s**, then everything unlocks with a **36.7 studs/s
   forward push**.
- A barrier 3.3 studs from the train start stops you running back.
- [co-op] Every up player runs the sequence together; downed players are carried across
  [keep]. Each player's own auto-run is checked by the server's movement validation.
- The old personal gap-coin arc goes; coins over the gap come from the coin-shape rules
  (§9.1, class 4 "step down / gap").

## 3. The player
### 3.1 Health and damage taken [orig]
- **100 HP per player** [co-op] (the original's shared 10 HP pool, ×10).
- **Damage taken** = hit × health booster × **resilience** × **0.5 during a spin window**
  × theme defence.
- **Resilience** is our `Toughness` (the same 0.16–1.00 ladder; Max 0.52, Brick 0.28).
- **0.3 s of invulnerability after every hit** (except instant kills).
- **Heal perks** (×10): heal over time 0.25 → 2.5 HP/s; heal on kill up to 2 HP; heal at
  full Mayhem 0.5 → 5 HP/s.
- **Armour states** at 2/3 and 1/3 health (the costume damage stages in [[Art Direction]]).

### 3.2 Movement [orig]
- **No acceleration:** velocity is set to ±speed every frame. **Full air control.**
- **The last direction pressed wins**, and facing flips with it (no backpedalling).
- **Jump: 14.1 studs**, take-off 60.7 studs/s, gravity 130.7 studs/s², about 0.93 s in the
  air. Vertical speed clamped to ±80 studs/s.
- **Double jump** (outside, once, not while spinning):
  - **still rising:** adds 20 studs/s (capped at 80), so pressing early reaches about 24.5
    studs,
  - **at the apex or falling:** sets 26.7 studs/s up, a 2.7-stud hop,
  - **it always starts the spin.**
- **No jump buffer. Walking off a roof keeps your jump** (you can jump, then spin, in
  mid-air).
- **Knockback on players:** the sideways part decays at 3/s (snaps to 0 below 1.7
  studs/s); your input still steers.
- **Falling into a gap:** the original's rule isn't known; **keep ours** (back on the
  nearest roof after 1 s, 15 damage) [keep].

### 3.3 The spin [orig]
- Starts with the double jump. **Lasts until you land.** No cooldown; once per airtime.
- **Hits by contact** while spinning, damage and force by **spin level**:

  | Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
  |---|---|---|---|---|---|---|---|---|---|---|
  | Damage | 2 | 3 | 5 | 6 | 8 | 9 | 11 | 12 | 14 | 15 |
  | Force (studs/s) | 6.7 | 13.3 | 20 | 26.7 | 33.3 | 40 | 46.7 | 53.3 | 60 | 66.7 |

  The push is **45° up and away** (equal sideways and upward), ÷ enemy weight. Max is
  level 4, Brick 6 [keep].
- **Your gun stops while spinning** and resumes on landing if fire is held.
- **No invulnerability**, but for **0.2 s after the spin starts and 0.2 s after it ends**,
  damage taken is halved.
- [ours] The hit area isn't in the vault: use the character's `SpinRadius` (Max 5, Brick 6).
- **Inside a carriage, every jump is a low hop that spins at once** (§3.7).

### 3.4 Swapping [orig]
- **Instant, no cooldown, no invulnerability.** Works mid-air and mid-spin, keeping
  position, velocity, jump and spin state, held fire, and the health. Each agent keeps its
  own crate weapon. Speed becomes the new agent's.
- Blocked when dead or downed, in a mech or vehicle, or while a gadget is being placed.
- **A squad is 2 agents** [orig, decided 2026-10-16]: a swap **toggles between them**. Q, E,
  the swap button and a swipe either way all toggle. You need 2 agents equipped to swap.

### 3.7 Carriage interiors [orig, decided 2026-10-16]
- **Closed coaches can be entered.** Press **Interact** (W/↑, or the ENTER button on
  touch, as in the original) at a door to go between the roof and the inside.
- **Inside:** the floor is the deck; a jump is a **low hop (30 studs/s, about 3.4 studs)
  and the spin starts immediately**. Shots and melee don't cross between the inside and the
  roof (the roof blocks them).
- **Enemies match your level:** when one moves to the next carriage it picks that
  carriage's roof or interior floor to match the player it's chasing. Spin-jumpers jump
  lower inside (27–33 studs/s up).
- **Seeing inside** [ours]: when your character is inside, the camera-side wall of that
  coach fades on your screen only; teammates on the roof see a dimmed silhouette of you.
- **Templates** [ours]: a `ClosedCoach` (33 studs) with an interior floor tagged
  `WalkSurface` and attribute `Level = "Interior"`, `CarriageDoor` parts at both ends,
  interior `EnemySpawn` attachments, and room for coins (coin shape class 0, "two-height
  coach") and the weapons coach's crates. The original also has coaches with crates on
  the roof and a weapons coach.
- **Missions** can use it ("die inside a carriage" and so on).

### 3.5 Death and revive
- [co-op] **Downed** at 0 HP, bleed out over 15 s, **teammate revive** (hold 2 s, back at
  40%), spectating until the next checkpoint [keep].
- **Gem revive** [orig]: **2ⁿ gems × the missing health fraction** (1, 2, 4, 8, 16, then 32
  forever), n counting your revives (and heals, §9.2). **The first death with no progress
  is free.** No revives in survival or challenges.
- **A gem revive** [orig]: full health, **3 s invulnerable**, a radial push (34 studs,
  103 studs/s, no damage), and **every enemy flees** (3.5× speed, then despawns
  off-screen).
- **A teammate revive** [co-op]: the 3 s invulnerability and the push, but enemies don't
  flee (so a party can't chain flees).
- [co-op] The whole-squad-down 10 s gem-revive window stays [keep].

### 3.6 Camera [orig]
- Leads **17.1 studs in the direction you're moving**, 0 when you stop; a lead flip eases
  over about 2.3 s. Big jumps ease over 0.33–4 s.
- Little vertical follow (up to 10 studs on wide screens); none on 4:3. No zoom.
- Background scroll 60 studs/s (boosting to 180 at events) [orig]; ours is 50 today: set
  `TRAIN_SPEED` 60.

## 4. Aim and weapons [orig]
### 4.1 Firing
- **No aim, no auto-aim.** Shots go along your facing. Remove every `AutoAimAngle`.
- Hold to fire; steady interval; no wind-up; no spread on any weapon.
- **Every bullet hit knocks the enemy back sideways**, by the weapon's force ÷ the enemy's
  `Weight` (lights 1, tough lights 1.4–2, mids 2, bosses 2.8). Frozen enemies don't move.
- **Explosions:** radial push with the upward part ×1.3, no falloff, full damage to
  everything overlapping, blocked by the train, and your own explosions never hurt you.

### 4.2 Weapon stats
Each of our weapons takes the stats of its original archetype ([[Launch Agents]] names
them). Damage is level 1 → 10.

| Ours | Original | Damage | Interval | Delivery | Push (studs/s) |
|---|---|---|---|---|---|
| Service Rifle | Rifle | 12 → 21 | 0.175 | Hitscan | 1.6 |
| Pocket Rocket | Rocket Launcher | 13 → 19 | 0.5 → 0.42 | Rocket 46.7 studs/s, range 123, **one blast of 4 studs** | 16.7 radial |
| Scattergun | Shotgun | **ray 12 → 14** plus a **close blast 16 → 21** that hits everything within 12 studs | 0.45 → 0.32 | Ray + piercing blast | ray 10, **blast 53.3** |
| Crowd Pleaser | Minigun | 6 → 11 | 0.07 | Hitscan | 8 |
| Twin Zippers | Dual Uzi | 4 → 7 | 0.075 | Hitscan | ours: 2.7 |
| Spark Plug | Lightning Gun | 4 → 7 a tick | 0.1 | **A straight piercing line, 22.7 studs; no chaining** | — |
| Invisible Bow | Rail Gun | **15 → 170 over a 1.1 s charge** (EaseInCubic; L10 26 → 298) | charge | Piercing shot, 60 studs/s, range 68, damage pool | recoil up to 16.7 |
| others | their archetype | per [[Original Game - Weapons and Gadgets (Native Code)]] | | | |

- The Scattergun's 5-pellet fan and the bow's fixed 70 are replaced.
- [ours] Hitscan ranges aren't in the vault: keep ours (rifle 45, minigun 40, ray 45).
- The Pocket Rocket's direct-hit-plus-splash (26) becomes one 13-damage blast.

### 4.3 Weapon crates [orig]
- **By distance:** one every **205–273 studs** ahead of the camera.
- Each pays **coins** = rand(b, b + 10), b = min(100, 10 + run minutes ÷ 10 × 90): 10–20 at
  the start, 100–110 after 10 minutes.
- Each gives a **random weapon** (`GiveRandomWeapon`). [ours] The pool isn't in the vault:
  any weapon of any owned agent other than the one you hold, kept by that agent until
  the next crate.
- [co-op] Crates are **personal** (each player sees and opens their own) [keep].
- The fixed crate spots and the mid-knockout drop go.

## 5. Score and combo [orig]
- **Points = value × 20 × combo level × mode × score booster**, paid **per point of
  damage**: damage ÷ the enemy's max HP × its score value (overkill pays nothing), plus a
  **kill** payment.
- [ours] The per-enemy score value isn't in the vault: **value = the enemy's `SpawnCost`**
  (light 2–3, mid 15, boss 40), paid once spread over its HP and once more on the kill. A
  light is worth about 100 points, a mid 600, a boss 1,600, before the combo.
- **Mode scalars:** in a mech ×0.2; Jetpack ×0.5; CDW ×0.05.
- **Events:** f × 20,000 (§1.4); survival +100 × wave. **No score for clears, leaps,
  distance or revives.** The old flat bonuses go.
- **Combo:** kills only. 2 kills within 1 s start level 1 → each kill within 1 s of the
  last level-up adds a level → 1 s without one drops back to level 1. **Up to level 25**;
  the level is the multiplier.
- [co-op] Each player scores their own damage and has their own combo; there are no
  assists (damage already shares the credit).
- **Run-end coins from score go** (the original pays none).
- [keep] The three co-op leaderboards stay (squad score, furthest train, individual).

## 6. Mayhem and gadgets [orig]
### 6.1 Mayhem
- **+0.035 per point of damage dealt, + 0.035 × the enemy's max HP on the kill** (a light
  ≈1.75, a mid ≈11), × the Mayhem booster × the agent's Mayhem rate.
- **× 0.2 while your gadget or mech is active.** Cap 100.
- Perks: Mayhem from damage taken (Brick's); speed rising with Mayhem (up to ×2).
- **A full meter gives a free gadget:** you pick one of your agent's gadgets (the
  original's "grab it now"; ours offers the agent's 3) and the meter empties.

### 6.2 Paid deploys
- **Drones and the Air Strike 2 gems, mechs 3**, at any time. The doubling price and the
  once-per-train limit go.

### 6.3 Drones
- **Up to 6 per player** [co-op], **one of each type** at a time ("DRONE ALREADY ACTIVE").
- Duration L1 → L10:

  | Drone | Duration | Behaviour |
  |---|---|---|
  | Turret | 30 → 57 s | Targets **the smallest turn** from its aim (on screen, line of sight), turns 200°/s, fires within 1°: **11 → 14 damage every 0.3 s**, shots 107 studs/s that **explode (5.3 studs)** |
  | Melee | 30 → 56 s | Chases the nearest enemy; two orbiting fists, **4 → 5 per contact**, every 0.2 s |
  | Defender | 51 → 87 s | Darts up to 16.7 studs to **destroy enemy projectiles**; a blocked missile or mine costs 3 s |
  | Healer | 15 → 28.5 s | A homing orb of **1.1 HP every 0.55 s** (2 HP/s), **owner only** |
  | Freeze | 36 → 63 s | One shot every 1.5 s, **6.7-stud blast**: a hard stop for **1.0 → 1.18 s × the enemy's freeze scalar** (light 1, mid 0.6, boss 0.3) |
  | Smasher | 10 → 19 charges | See below |

- **Smasher, adapted to final knockouts:** it flies to the nearest **knocked-out ragdoll
  before it fades** and smashes it for **3 HP** to its owner, one charge each (the
  original smashes corpses for 0.3 of its 10 HP).

### 6.4 Mechs
| Mech (ours) | Original | Speed | Gun | Spin |
|---|---|---|---|---|
| Heavyweight | Damage Mech | 33.3 | 40 every 0.2 s | 40 contact |
| Rocking Chair Mech | Melee Suit | 23.3 | saws 5 every 0.05 s, 4.7 studs | 60 contact; immune to knockback |
| Saucer | Heal Suit | 30 | 20 every 0.2 s | 20 contact; each kill heals 0.25 × seconds since the last, ×10 |

- **Entry:** a **2.5 s forcefield** (invulnerable, input locked).
- **Duration 15 → 26.7 s**, and **damage drains it: 0.065 s per HP** (the original's 0.65 s
  per point, on our scale). The Melee Suit doesn't drain.
- **Exit:** a blast of **200 damage over 53 studs** (the whole screen) with a 12 studs/s
  push, then 0.2 s invulnerable.
- **Score and Mayhem ×0.2** while inside.
- The armour bar, the entry stomp and the eject ring go.

### 6.5 Air Strike
- **14 rockets at once**, diagonally down and forward (135°), each 4.7–5.3 studs further on:
  **200 damage each in 12 studs**, 10 studs/s push. A **2 s forcefield** while you call it,
  then **locked for 2 s**. One level.
- The countdown, the marker, the boss halving and the one-per-party rule go. [co-op] Each
  player can call their own.

## 7. Enemies [orig]
### 7.1 Every enemy
- **HP and speed ×0.9–1.1** at spawn. Gravity 130.7 studs/s².
- **Perception:** notices a player who is **in front of it, or after being hit**, with a
  clear line from its middle. A player who is **jumping or above it** is only seen beyond
  its **blind distance** (others: 8.3–25 studs × weight; bosses 21–32), so you can jump
  over enemies. Re-checks every 0.25 s. [co-op] Its target is the nearest player it
  notices.
- **Attacks** need: the player visible, grounded, the same floor height, facing them, in
  range, off cooldown. **Too close:** it backs away (light melee settles 2–3.7 studs, mid
  2–4.3).
- **Ranged telegraph:** the shot leaves **0.5–0.6 s into the attack animation**, every
  **4 s ± 30%** (2.8–5.2 s), and never in the first **4 s** after spawning. Shots are aimed,
  not homing.
- **Animation timings** [orig, decoded 2026-10-17, [[Original Game - Animations]]], at
  15 fps: idle, run and jump loops 0.87 s; a light's melee swing **0.73 s** (3 variations),
  McGraw's 0.6 s; the flinch **0.33 s**; the berserker wind-up **0.87 s**; the lobber's
  throw 1.0 s (release at 0.6 s); a boss taunt 2.1 s.
- **Melee lands on the first frame** and re-swings when the animation ends (the player's
  0.3 s i-frames limit it).
- **Flinch:** on a gun hit, not mid-attack, then a cooldown of 0.8–1.2 ×
  `FlinchCooldown` (lights and mids 0.75 s [ours for the unset default]). **Bosses never
  flinch.** Frozen enemies don't flinch.
- **Knockback decays** at 3/s. **Enemies overlap freely** (no crowd spacing).
- **Fell into a gap:** it **climbs back** (1.5× speed toward the train, then a 30 studs/s
  jump). **Knocking a living enemy off the train no longer counts as a knockout.**
- **Enemies leap between trains** after the squad (2× speed, jump 60 ÷ weight).
- **Fleeing:** everyone flees at the boss start and on a gem revive (3.5×, then despawns);
  lights marked `FleeOnFire` flee when burning (2×).
- **Celebrates** when a player goes down.
- **Enemy explosives hurt other enemies.**
- **Knockouts stay final** [keep]: ragdolls fade after 3 s, no gore.

### 7.2 Spawning
- **Placement:** just **3.3 studs past the leading screen edge**, if the train goes on 13.3
  studs beyond it. **Behind** only on a 1-in-3 roll, and only when the squad isn't moving
  forward. Extra enemies in a wave sit a further 2.7–10 studs out. A forced lone mid
  always spawns ahead. **Despawn** 34 studs beyond either edge. [co-op] Edges are the
  frontmost and rearmost up players' screens.
- **One spawn timeline per run**, frozen during the boss and survival. The original's
  `SPAWN_GROUP_NORMAL` table (in [[Original Game - Run Structure and Meta (Native Code)]] and
  [[Original Game - Enemies and Spawning]]) drives it: lights only for about 2 minutes,
  then each mid introduced alone, ramps and long plateaus up to a cap of 60.
- **Budget rules:** waves are bought from a budget; the timer only counts while there's room
  under the cap; **children claim alive cost first and the root takes the rest**, so
  lights naturally wait while a mid is alive (the emergent stall replaces our scripted
  solo-mid beat).
- [co-op] Budgets and caps × the party scale (1.0 / 1.6 / 2.2 / 2.8) [keep].

### 7.3 The Wild West roster mapped to the original's archetypes
Damage to players is ×10.

| Slot | Ours | Original | HP / speed | Behaviour |
|---|---|---|---|---|
| 0 | Bandana Bandit | ninja_1 (melee grunt) | 25 / 9.3 | Light melee **30** |
| 1 | Rodeo Kid | ninja_2 (agile) | 30 / 10.7 | **Spin-jump** every 1.4–4.2 s: 2.5× speed, 7.4–8.6 studs high, about 18.7 long, **no damage**; melee from behind. 1-in-7 per 0.1 s to escape a flinch |
| 2 | Six-Shooter | ranged light (LIGHT_FIREBALL) | 35 / 8.7 | Bullet **40**, 18 studs/s, fired 0.6 s into the draw, every 4 s ± 30% |
| 3 | Dynamite Dan | ninja_4 (coward) | 30 / 10 | **Backs away while reloading**; throws when you're 8–23 studs away (0.6 s into the throw, every 4 s ± 30%); the dynamite **explodes on first contact**, **40** in 2.7 studs, and hurts bandits; explodes when knocked out |
| 4 | Lasso Lucy | ninja_5 (agile mid) | 160 / 11.3, weight 1.6 | Agile mid: spin-jumps, mid melee **60**. **Her lasso is deferred** until the first agent is built (decided 2026-10-16) |
| 5 | Big Bart | ninja_6 (berserker) | 160 / 10.7, weight 2 | **Charges after every ~30 damage taken** (27–33): aims, then **34 studs at 26.7 studs/s**, hits once for **60** with a 33 studs/s push. **Can't be staggered, flinched or burned** while charging; no recovery. The jug swig is the wind-up animation (**0.87 s**, the original's `BEHAVIOUR` clip) |
| 6 | Saloon Door Sam | ninja_7 (shield) | 160 / 12, weight 2 | The doors are a **90 HP physical shield** on his hand; they **drop while he flinches**; he takes **0.2–0.5 s to turn**; when they break, **speed ×1.6** |
| 7 | "Mad Dog" McGraw | BerserkerBoss (ninja_8) | 600 / 16.7, weight 2.5 | Charges every 4.8–7.2 s (half the time 9.6–14.4) and every 90–110 damage; leaps every 4–6 s beyond 20 studs (lands for **80**); cross-cooldowns; **below 15% the charge comes at least every 2.5 s**. Boss melee **70**, charge **80**. **No stagger** |
| 8 | Ma Rattler | SpawnBoss (horror_9) | 600 / 16.7 | At **66% and 33%**: bursts into **6–8 Runts**, vanishes until they're all knocked out, then reforms. Leaps every 4–6 s beyond 20 studs |
| 9 | Rattler Runt | boss minion | 20 / 15 | Light melee 30 |

- Our proposed shots (shotgun blast 8, McGraw's spread 4 per bullet) become ×10 (80, 40).
- Bart's stagger, the regular Runt calls and our Lucy/Sam extras are replaced.

## 8. Events [orig]
### 8.1 Hostage
- **2 pressure pads** on two prison carriages. Twice, a **key holder** (a mid) patrols.
- [adapted] Knocked out, it **drops a locked key box** (no corpse): **spin or shoot it to
  SMASH it**, and the key flies out (13.3 sideways, 26.7 up, spinning; pick it up after
  0.5 s). Carry it to a pad.
- After 2 keys the hostage (Conductor Earl [keep]) is free. Reward f as for the boss.

### 8.2 Survival
- A 83-stud arena. **Waves = min(8, tier + 3)**, a 2.5 s break between waves, **+100 × wave
  score**, a crate after each cleared wave, gadgets locked.
- **One hit downs you.** [co-op] Teammates can still revive you; if everyone is down,
  it's a wipe.
- Reward f = waves × 0.125.

### 8.3 Vehicle events: what they share [orig, co-op adapted]
- **Planned for M3** (after the slice). Their obstacle **patterns** are the original's
  15-lane grids (`assets/Patterns/*.tga`, 50 files: CDW obstacle and missile levels 0–2,
  jetpack obstacle levels 1–4 and missile levels 1–5). The files are in the extracted APK
  outside this repo; decode them with `tools/tga.py` ([[Original Game - Text, Engine and Assets]]
  §4.3) into Roblox level chunks. Cell colours: yellow coin, blue mine, azure ground mine,
  red missile row, green/magenta/cyan gems or crates [inferred legend].
- [ours] **Grid scale:** one cell ≈ 3.4 studs (the original's 768-pixel screen ÷ 15 lanes).
- **One tap does everything:** "TAP ANYWHERE TO JUMP" (ball) or "TO BOOST" (jetpack). Fire
  is automatic in the jetpack.
- **Missiles** come in on a lane after a **warning bar**, at 20 studs/s; a Defender can
  block them (each block costs it 3 s).
- **Enemies** spawn ahead to keep a target alive cost (the original's `EventSpawner`):
  only types already met this run, no second mid while one is alive, spacing 66.7 studs
  shrinking toward 26.7 (ball) or 46.7 (jetpack) over 300 studs.
- **Gadgets and swapping are locked** while riding ("JETPACK ACTIVE", "BALL ACTIVE").
- **Camera:** always leads forward, follows rigidly, and follows height.
- **Finish line** at the target distance, then you hop off onto the next span with 0.5 s
  of invulnerability.
- **Targets grow with score**: +50 m (167 studs) per 20,000 points (1 m = 3.33 studs).
- [co-op] **Everyone rides their own vehicle** side by side on the same lane grid (vehicles
  pass through each other). Each player's coins, mines and missiles are their own.
- [co-op] **A destroyed vehicle downs you**; your bleed-out pauses until the finish line,
  where anyone who finished revives you automatically at 40%. If every vehicle is
  destroyed, it's a squad wipe (with the 10 s gem-revive window).

### 8.4 The two vehicles
| | Rolling Ball (the original's CDW, "Cylindrical Death Weapon") | Jetpack |
|---|---|---|
| What you do | Roll along the train roofs at speed, **tap to jump** mines and missiles; the ball **rolls over enemies** | **Fly** above the train, **tap to boost** up against gravity, guns fire automatically |
| Target | min(1,200, 400 + 50 per 20k score) m = 1,333 → 4,000 studs | min(800, 300 + 50 per 20k) m = 1,000 → 2,667 studs |
| Speed | 46.7 studs/s, rising to 50 / 51.7 / 53.3 / 55 / 56.7 after 150 / 350 / 700 / 1,000 / 1,500 m | [ours] the same table |
| Vehicle health | [ours] 100, or 200 with its upgrade (the original's isn't in the vault; the jetpack's is) | **100, or 200 with its upgrade** (×10); a hit over 75 gives 1 s of invulnerability |
| Hurting enemies | Rolling into them; [ours] 20 damage, knocks lights aside | Your agent's primary weapon, auto-firing |
| Score | ×0.05 while riding | ×0.5 while riding |
| Reward f | min(1, m ÷ 2,000) for coins and score | coins min(1, m ÷ 1,200); score min(1, m ÷ 2,000) |
| Unlocks with | the mission "ride the ball 400 m" | the mission "kill 100 with the jetpack" |
| Wild West look | (proposal) a runaway **whiskey barrel** | (proposal) a **steam-powered rocket pack** |

- The coins and gems placed by the patterns count toward the gem counter (§9.1).
- Mine damage isn't in the vault: [ours] 50.

## 9. Economy [orig]
### 9.1 Coins and gems
- **Coins are worth 1** (× the coin booster). They come in **coin shapes** placed every
  **51–85 studs**, fitted to the train: on two-height coaches, in a line 9 studs above flat
  runs, up steps, down steps and over gaps, and over the engine. [co-op] Personal [keep].
- **Gems among the coins:** a counter of placed coins (shapes, crates, events); past a random
  point up to 400, the next coin is a **gem**. About **1 gem per 400 coins**.
- **Crate coins** (§4.3) and **event coins** (§1.4).
- **The magnet booster:** 24-stud radius, pull 0 → 60 studs/s over 1.2 s, lingers 5 s.
- Enemy coin drops, the gap-coin arc and the run-end score coins **go**.

### 9.2 Healing and revives
- **The HEALTH pod** at the checkpoint: **min(150 × 2ⁿ, 20,000) coins × the missing
  health fraction**, refilling to full. **n is shared with gem revives** (each heal adds
  the fraction healed). [co-op] Each player pays for themselves; n is per player per run.
- Gem revives: §3.5.

### 9.3 Boosters
| Booster | Effect | Price |
|---|---|---|
| Score | ×2 / ×3 | 1 / 2 gems |
| Mayhem | ×2 / ×3 | 500 / 800 coins |
| Coins | ×2 / ×3 | 4 / 6 gems |
| Damage | ×1.25 / ×1.5 / ×2 | 400 coins / 2 gems / 4 gems |
| Health (damage taken) | ×0.67 / ×0.5 | 2 / 4 gems |
| Gems | ×2 / ×3 | 800 / 1,600 coins |
| Magnet | on | 4 gems |

- **Up to 3 equipped**; one per category; different categories multiply.
- **A random offer of distinct types** at the checkpoint's booster menu ([ours] 4 offered;
  the original's count isn't in the vault).
- **Cleared at every checkpoint** (one train).
- The party caps go; every booster only affects its owner anyway.

### 9.4 Blueprints and upgrades
- **Upgrades:** 10 levels, L2–L10 1,000 → 14,000 coins (51,400 per item), each needing a
  blueprint unlock [keep, already the original's].
- **The catch-up roll** decides which item a blueprint unlocks [keep].
- **Blueprint thieves:** a timer on **total play time**, every **min(1,200 s, 80 s +
  n^1.28)** (n ≈ blueprints held + owned − 1). A light or mid in the blueprint variant
  carries it. [co-op] Each player has their own timer; their thief's blueprint goes to
  them, whoever knocks it out.
- Banked at every checkpoint; lost on a wipe [keep].

### 9.5 Missions
- **A fixed, ordered list** (the original's has 69), **3 active**, rewards **1–6 gems**.
  **Skip: 1,000 coins**, no reroll. When the list runs out, it repeats at a higher tier.
- Missions can **unlock and push events** (kill a boss, rescue a hostage, survival) and
  **force a theme** ("reach the Ninjas train").
- [ours] Only the first 12 entries are in the vault; write our list from the original's
  templates, in its order and pacing.
- The free daily reroll and 5-gem skip go.

### 9.6 Daily challenge
- One per UTC day: a **5-step chain per agent** (survival waves, CDW and jetpack metres),
  rewards **300 / 600 / 1,200 / 2,400 coins, then 20 gems** and a discount on a new agent.
- [ours] Until vehicles exist, every step is survival; discount 25% (not in the vault).

### 9.7 Surplus
- **3 offers** (cheap, mid, premium bands), only **blueprint-locked levels**, priced in gems:
  **coin cost ÷ 400, ×1.2** if locked. **Refreshes every 10 minutes.**
- The 8-hour timer and the own-agents-only rule go.

### 9.8 Agents, purchases and ads
- **One free agent (Max)**; others **80 / 100 / 150 gems**. [ours] The tutorial grants
  enough gems to recruit a second (the original did this; its amount isn't certain), so
  Brick becomes the first recruit rather than a free gift.
- **Robux:** coin packs, gem packs and an all-agents bundle. The gems → coins Exchange, the
  login streak and the Coin Bonus pass go.
- **No ads** [keep]: ad revives and ad offers are dropped, not replaced.
- [keep] Free private servers.

## 10. What stays ours
- Co-op (§3.5, §1.5 vote, personal pickups, party scaling), the hub train you walk around,
  queue pads and reserved servers.
- Final, gore-free knockouts; no ads.
- The static train with the scrolling world, 2.5D, PC and mobile, server authority.
- Theme content: the Cowboys, the agents and their names, the art direction, the tone.

## 11. Decisions and open questions
**Decided 2026-10-16:**
1. **A squad is 2 agents** (§3.4), as in the original's code.
2. **Lasso Lucy's lasso is deferred** until the first agent is built.
3. **Enterable carriages: yes** (§3.7). Planned after the slice, with the closed-coach
   template.
4. **Jetpack and Rolling Ball: yes**, designed in §8.3–8.4, planned for M3.
5. **The slice includes McGraw, the boss arena, the checkpoint and the TrainJump leap**
   ([[Feel and Look (Slice)]]).

**Still open:** the [ours] values throughout (tune in playtests), and the Wild West looks
for the two vehicles (proposals in §8.4).

## 12. Studio change list (for the local session)
> **Progress (2026-10-16, local session):** items **0, 1, 3 and 4 are built**, and item 2
> except "no acceleration" and the player knockback decay (the Humanoid is near-instant
> already). Knockback ÷ `Weight` from item 5 is in too (in `CombatService.knockback`). See
> [[AgentService]], [[CharacterService]], [[CombatService]], [[InputController]],
> [[EnemyService]]. Not play-checked yet: the half-damage spin windows, Weight on Bart.
0. **Squad of 2:** [[AgentService]] (squad slots, swap toggle), the Barracks squad select
   and the HUD squad strip ([[HudController]]).
Ordered roughly by how much it changes the feel. Each item names the system note to update
once it's built.
1. **Health scale:** enemy damage ×10 (all enemy weapons, explosions on players); the 0.3 s
   i-frames ([[CombatService]], [[EnemyService]]).
2. **Movement:** gravity 130.7, jump 14.1 studs (take-off 60.7), no acceleration, the
   double-jump rule, keep-jump-after-walking-off, no backpedal ([[CharacterService]],
   [[InputController]]).
3. **Spin:** until landing, contact hits by level, 45° push ÷ weight, gun paused, the 0.2 s
   half-damage windows; remove the cooldown and the burst ([[CombatService]]).
4. **Swap:** remove the 1.5 s cooldown; allow mid-air and mid-spin ([[CharacterService]]).
5. **Aim:** remove auto-aim; bullet knockback ÷ `Weight` on every hit; the weapon stat
   changes (§4.2) ([[CombatService]]).
6. **Score and combo** (§5) ([[ScoreService]], [[HudController]]).
7. **Mayhem per damage**, ×0.2 while active, the free gadget ([[GadgetService]]).
8. **Enemies:** perception, telegraph timing, flinch, gap recovery, leaping between trains,
   fleeing, friendly-fire explosives; the roster changes in §7.3, **Bart without the
   stagger** ([[EnemyService]]).
9. **Spawning:** one timeline per run on the original's table; off-screen placement;
   claim-cost stalls ([[SpawnService]]).
10. **Run structure:** procedural trains with tenders and a 50-stud engine; the event deck;
    the boss arena every train; the checkpoint every train; the TrainJump leap
    ([[TrainService]], [[RunStateService]]).
11. **Crates by distance with coins and a random weapon; coin shapes; gems among coins**
    ([[PickupService]]).
12. **Gadgets:** drone limits and behaviours, mech forcefield and timer drain, the Air
    Strike volley ([[GadgetService]]).
13. **The paid heal pod; boosters, missions, Surplus, challenges** (M4 systems; update the
    Session 7 and 12 drafts).
14. **After the slice:** closed coaches with interiors (§3.7), then the vehicle events
    (§8.3–8.4) with the decoded patterns.
- [[Combat Polish Code]] overlaps items 1, 3, 5, 7, 8 and 9: use its helpers where they
  match this note (flinch, perception, spawn placement, lob, i-frames, camera lead) and
  drop the parts this note replaces (the stagger, our spin variant, jitter on melee).

Related: [[0012-match-the-original]] · [[Differences from the Original]] · [[Original Game]] · [[Game Design Document]] · [[Wild West Enemies]] · [[Combat Polish]]
