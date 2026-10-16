---
tags: [reference, original-game, decompiled, enemies, ai, bosses]
status: reference
updated: 2026-10-16
---
# Original Game - Enemy AI (Native Code)

> **Reference only, never canon.** This describes *Storm the Train* (2016), not our game.
> It was decompiled from `lib/x86/libMainApp.so` with Ghidra 11.4 on 2026-10-16. An
> analysis agent wrote it, and Claude spot-checked the key claims against the code.
> **[code]** means read from decompiled code or data; **[inferred]** means a reading
> that hasn't been checked in the running game. Addresses are Ghidra's (ELF VA + 0x10000).
> Start with [[Original Game - Combat Feel (Native Code)]]. The proposals for our game are
> in [[Hit Feedback]].

Reference only. This describes the 2016 original, not our game. It extends
"Original Game - Enemies and Spawning" and "Combat Feel (Native Code)" and doesn't repeat them.

- **[code]** means read from the Ghidra pseudocode, the `.so` constants or the Lua data.
  **[inferred]** means my interpretation.
- Addresses are Ghidra's.
- Units: px on a 1024×768 screen, with 15 px ≈ 1 stud. Box2D runs at 100 px per metre.
- Enemy gravity is 9.8 m/s² × gravity scale 2, which is 1960 px/s² (131 st/s²). During boss
  leaps the scale is 3: 2940 px/s² (196 st/s², the same as Roblox's default gravity).
  Source: the `CaPhysics2D` constructor and `Enemy::InitPhysicsBody @ f7000`. **[code]**

## 1. The base AI state machine

**States** (`Enemy::RunAIState @ f95a0` dispatches through the vtable) **[code]**:

| # | State | # | State |
|---|---|---|---|
| 0 | Move (the chase/approach brain) | 6 | Celebrate (the player is dead) |
| 1 | ChangeCarriage | 7 | Dead (corpse) |
| 2 | Flee | 8 | Damage (flinch) |
| 3 | Patrol | 9 | LeapAttack |
| 4 | Idle | 10 | FleeOnFire |
| 5 | Attack | | |

- Flee and Idle are "sticky". `SetAIState @ f7700` refuses to leave them unless the enemy is
  dead. **[code]**
- **Idle makes the enemy invulnerable.** `TakeDamage @ f74b0` ignores hits while in state 4.
  Bosses wait in Idle during their intro, and thrown minions stay in it until they land. **[code]**
- **Spawn randomisation.** Each spawn rolls HP and move speed at ×0.9–1.1. **[code]** (`Init @ fb880`)

**Target acquisition** (`SelectTarget @ f7570`, retried every **0.25 s** while the enemy has
no target) **[code]**:
- There is a single target: the player. There's no target scoring.
- An enemy only acquires the player if **the player is in front of it** (on its facing side)
  **or it has already taken damage** (HP < max).
- It also needs a clear Box2D ray from its own mid-height to the player.
- So enemies walking away from you don't notice you until you shoot them. That's a built-in
  backstab/sneak rule. **[inferred design intent]**

**"Blind distance"** (`IsTargetVisible @ fa580`) **[code]**:
- If the player is jumping, or is above the enemy's mid-height on the same floor, the enemy
  only "sees" them when they're further away horizontally than its blind distance.
- Bosses use `ENEMY_BLIND_DISTANCE` × 0.8–1.2, which is 320–480 px (21–32 st).
- Everyone else uses 250 × WEIGHT × 0.5–1.5, so lights get 125–375 px (8–25 st).
- An enemy that loses sight keeps walking in its current direction. **That's why jumping over
  enemies works:** they walk on past you. **[inferred]**

**Move logic, in priority order** (`Enemy::Move @ fcb40`) **[code]**:
1. **No carriage under it** (it fell into a gap): `RecoverTrain`. It moves at 1.5× speed
   toward the closest train and jumps at 450 px/s.
2. **Forcefield.** If the player's forcefield is up, the enemy stops at a random 10–400 px
   (0.7–27 st), set per enemy, and stands facing the player (`HandleTarget @ f9bf0`;
   Player+0x58 is `ActivateForcefield`).
3. **Attack.** It enters Attack when `IsValidAttackLocation @ fb110` is true. That needs all
   of these:
   - the player is visible,
   - the enemy isn't airborne,
   - it's on the same floor height as the player,
   - it's facing the player,
   - a weapon is in its [min, max] range and off cooldown.
4. **Spacing (keep attack distance).** If the player is closer than the weapon's **minimum
   range**, the enemy walks backwards: it swaps its movement direction while keeping its
   facing. This only happens if it has room on the carriage (`HasSpaceToTurn`).
   - Light melee therefore settles between 30 and 55 px (2–3.7 st).
   - Mid melee settles between 30 and 65 px (2–4.3 st).
5. **Turning.** If the player is behind it, it turns instantly. Exception: shield enemies,
   see §2.
6. **Gaps and level changes.**
   - When the next carriage's floor is a different height, the enemy walks to that
     carriage's **jump pad** (`Carriage::GetJumpPad`) and enters ChangeCarriage. Then
     `JumpBetweenCarriages @ fc5c0` jumps it at **(height difference × 3.4 + 500) px/s**.
   - **It picks the next carriage's roof or interior floor to match the player's**
     (`UpdateNextCarriageHeight @ fca00`).
7. **Leaping between trains.** If the way ahead leads off the train and the player is on
   another carriage, the enemy uses `TrainLeap @ fbed0`: 2× run speed, jumping at
   **900 / WEIGHT px/s**. That's about a 207 px (14 st) arc for lights, and much flatter for
   heavier enemies.

**There's no crowd-spacing logic** **[code + inferred]**:
- `EnemyManager::Update @ 101ca0` only sums spawn cost.
- The enemy fixture's collision mask (0x8728/0x87a8) doesn't include its own category (2), so
  enemies overlap freely.
- The only spread comes from the ±10% speed roll and the random forcefield stop distance.

**Patrol** (`Patrol @ fd280`) **[code]**:
- Only the hostage-event key holder uses it (`ForcePatrol` is called from `HostageEvent::SpawnEnemy`).
- It walks to a random point at 10–30% or 70–90% of the carriage, waits 0.6–3 s, turns, and
  repeats.
- It switches to Move as soon as it acquires the player (the facing rule above applies).

**Flee states** **[code]**:
- **Flee** runs away from the player at **3.5× speed**. It's used by `EnemyManager::FleeAll`
  when a boss fight starts, and the enemy despawns once off-screen.
- **FleeOnFire** runs at 2× speed with the `ON_FIRE` animation.

**Celebrate** **[code]**: when the player is dead, enemies play `CELEBRATE_A` on the roof or
`CELEBRATE_B` inside.

## 2. Archetypes

### Agile spin-jump (`AgileEnemy::Move @ aed10`, `Enemy::SpinJump @ fd3e0`)
- **Interval.** A random **0.5–1.5 × `AGILE_SPINJUMPTIME`**: 2.8 s gives 1.4–4.2 s, and the
  minion's 1.5 s gives 0.75–2.25 s. **[code]**
  - It's only counted while the enemy is in Move with the player visible.
  - It's re-rolled after every landing.
  - A spin also fires if the enemy reaches the train edge chasing the player. **[code]**
- **Arc** **[code; arc maths inferred]**:
  - The jump is **660–710 px/s up** on the roof, or 400–500 px/s inside a carriage.
  - Horizontal speed is **2.5× run speed** (ninja_2: 400 px/s, 27 st/s).
  - On the roof that's an apex of about 111–129 px (7.4–8.6 st), about 0.7 s in the air, and
    about 280 px (19 st) of travel. So it clears the player.
- **Damage:** no weapon is attached to the spin. It's a **reposition over the player, then
  melee from behind**. **[code]**
- **Flinch escape.** `AgileEnemy::Damage @ af260` gives a 1/7 chance per 0.1 s to spin out of
  a flinch. **[code]**
- While spinning it can't flinch and can't be set on fire. **[code]**

### Berserker charge (`BerserkerEnemy::BerserkAttack @ b36a0`, `Init @ b39d0`, `Damage @ b3ce0`)
- **`BERSERK_HEALTH` is an *enrage trigger*, not a stagger threshold** **[code]**:
  - At spawn, the trigger is set to current HP − `BERSERK_HEALTH` × 0.9–1.1.
  - When HP falls to that value, he charges.
  - After each charge, the trigger is reset to current HP − 27–33.
  - So a 160-HP mid charges **every time he takes about 30 damage**, which is 4–5 times
    over his life.
- **Range and direction** **[code]**:
  - Every enemy uses `BERSERK_DIST` = 512 px (34 st) as the **length of the charge**.
  - It isn't a trigger range.
  - The charge is aimed at the player when it starts.
- **Wind-up:** he stands still for the length of the `BEHAVIOUR` animation. The Lua comment
  reads "this plays to indicate the start of the run". The animation length isn't in the code.
- **Charge speed: 2.5× move speed** **[code]**:
  - **400 px/s (26.7 st/s)** for a 160-speed mid,
  - **625 px/s (41.7 st/s)** for a 250-speed boss.
- **The charge ends** after 512 px, when he's blocked or stops, or at a barrier. **[code]**
- **The hitbox** is a separate damage body. `BERSERK_OFFSET`/`SIZE` define it **[code]**:
  - mids: 60×17 px (4×1.1 st) at (15, 25),
  - bosses: 90×20 or 90×45 px.
- **Hits** **[code]**:
  - The charge uses `MEDIUM_BERSERK` (6 damage, push 500 = 33 st/s) or `BOSS_BERSERK`
    (8 damage, push 800 = 53 st/s).
  - It **hits at most once per charge**: the body disables itself on contact (`Update @ b3a70`).
- **During the wind-up and charge he can't flinch and can't be set on fire.**
  - Freezing disables the hitbox.
  - Chainsaw-type hits (weapon flag 0x40) suppress the trigger for 2 × that weapon's cooldown.
  - There is no stagger-to-cancel. **[code]**
- **Recovery:** none. When the charge ends he switches archetype back and returns to Move.
  **[code]**

### Shield (`ShieldEnemy::*`, `Shield::*`)
- **The shield is a physical Box2D box glued to the `weapon_shield_r_hand` locator**
  (`UpdateShieldPos @ 154070`). **[code]**
  - Its size is `SHIELD_SIZE_W×H` (ninja_7: 10×64 px, 0.7×4.3 st) at `SHIELD_OFFSET` 16.
  - There's no angular "arc". It **blocks whatever it physically covers**, and it follows the
    animation.
- **The shield drops during flinches.** While the enemy is in the Damage state the shield is
  set inactive (`Damage @ 1545f0`). **[code]**
  - Each 0.1 s there's a 1/5 chance he recovers early. He then braces for 0.2–0.5 s with the
    shield up.
- **Turn delay.** With his shield up and a target, he must pause **0.2–0.5 s before turning
  around** (`SwapMovmentDirection @ 154580`). **[code]** So jumping over him gives a free
  window at his back.
- **Shield damage** = hit damage × a booster modifier (`Shield::TakeDamage @ 153bd0`). **[code]**
- **Break** **[code]**:
  - The shield is removed and spawns gibs of `SHIELD_GIB_TYPE`.
  - He switches to his no-shield archetype (or archetype pair).
  - **Move speed rises ×1.6**: 180 → 288 px/s (19 st/s). He "panics".
- The shield boss (`ShieldBoss`) is the same apart from the boss flag. **[code]**

### Teleport (`TeleportEnemy::Move @ 15edb0`, `EndTeleport @ 15eb70`, `GetBehindPlayerPos @ 15e990`)
**[code]**
- **Timer:** a random value in `TELEPORT_INTERVAL_MIN–MAX` (3–6 s). It only counts down while
  he has a target. The first teleport comes after **half** of that (`Init`).
- **Vanish:** physics and model off, the 0x26 effect and a sound. He's intangible for
  `TELEPORT_TIME` (0.8 s).
- **Reappear:** **150 px (10 st) past the player, on the opposite side** from where he was.
  He faces the player, and the spot is re-rolled if it's outside a barrier.
- **Punish window:** he stands still for `TELEPORT_RECOVER_TIME` (0.3–0.4 s).
- He can't flinch during the teleport cycle.

### Coward (`CowardEnemy::Move @ d54b0`) **[code]**
- **While its weapon is reloading, it walks away** from a player in front of it.
- When the weapon is ready it turns back and approaches until the player is inside the
  weapon's band:
  - `FIREWORK`: 120–350 px (8–23 st).
- **Fire pattern:**
  - **one shot per cooldown**: 4 s ± 30%, so 2.8–5.2 s,
  - 0.6 s into the throw animation,
  - then it waits for the animation to end.
- It's a kite → shoot → retreat loop.

### Suicide (`SuicideEnemy::*`) **[code]**
- **Approach blast:**
  - It walks up and detonates `SUICIDE` within 0–50 px (3.3 st).
  - The blast does 4 damage, pushes at 600 (40 st/s), uses camera-shake type 2, and **always
    gibs**.
- **Leap trigger:** when the next carriage is **lower** and the player is on it, the robot
  does `SuicideLeap @ 15d0a0`:
  - it jumps at **1.5 × |dx| + 200 px/s**, at 2× speed, playing `BEHAVIOUR`,
  - and **explodes on landing**.
- **While leaping** it's immune to everything except suicide blasts.
- **Chains are guaranteed.** Any `SUICIDE` blast first sets the victim's HP to 1
  (`TakeDamage @ 15d310`). The victim dies, and its own death weapon then explodes.
- The blast's area isn't certain. The weapon has no AOE radius, so it's probably a 50 px
  ray or contact. **[inferred]**

### Hover (`HoverEnemy::Update @ 12ab80`) **[code]**
- **It never "falls".** Its downward speed is capped at max(1, 2.2 × its height above the
  floor) px/s, so it glides down gently and floats across gaps.
- **Turning while airborne:** while it's more than 5 px up, it turns back once the player is
  behind it and further away than 7 × its height.
- **Dodge:** when hit on the roof there's a 1/4 chance per 0.1 s that it **hops up at
  700 px/s** out of the flinch.

### Frenzy (`FrenzyEnemy::*`) **[code]**
- **Trigger:** permanent once HP < `FRENZY_HEALTH`. The enemy then:
  - gets the frenzy effect,
  - sets its speed to `FRENZY_SPEED`,
  - switches archetype,
  - stops flinching and stops reacting to fire,
  - takes knockback ×0.8.
- **No shipped enemy uses `FRENZY_ENEMY`.** It's dead content.

### Undead revive (`UndeadEnemy::Init @ 16b040`, `Dead @ 16b0c0`, `Enemy::HandleDeath @ fc150`) **[code]**
- **The revive is rolled once, at spawn** (`UNDEAD_REVIVE_PROBABILITY`).
- **Every death first decides corpse vs gib.** The enemy leaves a corpse only if rand(0–99) ≥
  the killing weapon's gib %:
  - player guns: 50 %,
  - shotgun blast: 75 %,
  - explosions and suicide blasts: 100 %.
  Bosses, death-weapon carriers and spinning enemies always gib.
- **Reviving:**
  - a corpse lies for `UNDEAD_DEAD_TIME` × 0.8–1.2 s, plays `REVIVE`, and comes back at
    **full max HP**,
  - **only once** (the always-gib flag is then set).
- **No revive** after gibbing, a corpse-smash, `ForceFlee`, or for boss-summoned minions
  (`ForceNoRevive`).

## 3. Telegraphs and attack timing

The attack sequence (`Enemy::Attack @ fc690`) **[code]**:
1. Face the player.
2. Choose a weapon. **The ranged secondary is preferred** if it's in range and ready.
3. If the current archetype doesn't match the weapon, play **`SWAP_WEAPON_A` → switch
   archetype → `SWAP_WEAPON_B`**. That's a visible "draws the gun / sheathes the sword" tell.
4. Play `ATTACK` and fire the weapon **`animFireDelay`** (weapon record +0x14) seconds in.
5. Wait for the animation to end, then go back to Move.

The weapon's `fireDelay` (+0x10, 0.2 s on mid ranged weapons) only adds a pre-wait **when the
player is in a vehicle**. The disassembly checks it the other way round from what you'd expect,
which looks like a bug. **[code]**

| Weapon | Hit lands after… | Cooldown (±30% jitter if > 0.2 s) |
|---|---|---|
| LIGHT/MEDIUM_MELEE | **0 s** (first frame of the swing) | 0: re-swings as soon as the animation ends |
| ORIENTAL / HORROR / FUTURE_BOSS_MELEE | 0.25 / 0.3 / 0.5 s | 0 |
| LIGHT_FIREBALL, FIREWORK, SKULL, LIGHT_BEAM | 0.6 s | **4 s** (2.8–5.2) |
| MEDIUM_STAKE / MEDIUM_BEAM / MEDIUM_FIREBALL | 0.5 / 0.5 / 0.6 s | 4 s |
| NINJA_BOMB (10–400 px) | 0.5 s | 4 s |
| FUTURE_BOSS_MEGAGUN (90–400 px) | 0.6 s | 3.8 s |
| BOSS_STAKE | 0.25 s | 0.5 s |

- **The first ranged shot comes 4 s after spawning.** `Init` resets the secondary weapon's
  reload. **[code]**
- **Melee has no wind-up in code.** Its cadence is the attack animation's length, and the
  player's 0.3 s of i-frames limits it further. **[code]**

**Flinch** (extends Combat Feel) **[code]**:
- **Bosses never flinch.** `HandleDamageAnim @ f9fa0` exits for `IsBoss()`.
- That makes the beam → leap path (`ENEMY_BEAM_LEAP_*`, `Enemy::Damage` → `CanLeapAttack`)
  **unreachable for bosses**. It's effectively unused, so the Shield boss never leaps.

## 4. Bosses

**McGraw-type: `BerserkerBoss`** (ninja_8, future_9) **[code]**
- **Charge on a timer** (`ResetBerserkTimer @ b2e10`):
  - every 4.8–7.2 s, and **50% of the time doubled** to 9.6–14.4 s,
  - the timer only counts while he has a target,
  - it also fires on each 90–110 HP of damage taken after the first charge,
  - the charge plays `BOSS_SOUND_ATTACK`.
- **Leap** (`Move @ b3070`):
  - every 4–6 s, if the player is **more than 300 px (20 st)** away,
  - he jumps at up to 1300 px/s with gravity ×3 (an arc of about 0.9 s and 290 px),
  - at 1.8–2.5× run speed,
  - and lands into `LEAP_ATTACK`, which fires `BOSS_LEAP_ATTACK` **on the landing frame**:
    8 damage, 30–120 px (2–8 st), push 400, shake 3.
- **Cross-cooldowns:**
  - after a charge, the leap waits ≥ 2 s,
  - after a leap, the charge waits ≥ 3 s,
  - after a megagun shot, the charge waits ≥ 2.4 s,
  - charges and leaps also push the megagun reload back to ≥ 40% of its cooldown.
- **HP phase:** **below 15% HP the charge timer is capped at 2.5 s** (an enrage). That's the
  only HP phase. **[code]**
- **Flinch:** he never flinches. While in the Damage state, he cancels straight into an
  attack if he can.

**Vampire lord: `TeleportBoss`** (`Move @ 15e140`) **[code]**
- **Teleporting:** he teleports like a mid (4–7 s).
- **Hovering:** every `HOVER_INTERVAL` (5–8 s; the first comes at half):
  1. He rises at 400 px/s to **150 px (10 st)** above the floor and plays the attack sound.
  2. He hovers for **2.4 s**, tilting up to 20°.
  3. After 0.4 s he throws **up to 3 stakes** (cooldown 0.5 s, 0.25 s each into the
     animation). They form a **fan**: the first is aimed at the player +6°, and each next one
     is 4° lower.
  4. Then he drops.
- **Stakes are only thrown from the hover** (`CanAttack @ 15e610`).

**Skeleton king: `SpawnBoss`** (`Update @ 158940`, `Move @ 158b30`) **[code]**
- **At every lost third of HP (66% and 33%)**:
  1. He turns **invulnerable**.
  2. Five pre-spawn effects flicker over about 0.6 s.
  3. He **bursts into 6–8 slot-9 minions**. They're launched ±300–900 px/s sideways and
     600–1200 up, spinning, and can't revive.
  4. **He vanishes until every one of them is dead.**
  5. He reforms over 1.2 s: bones are pulled in, the sound plays at 0.5 s, and he ends with
     an explosion.
- Leap: every 4–6 s if the player is more than 300 px away.

**Future mech: `FutureSpawnBoss`** (`Move @ 108740`) **[code]**
- **Throws minions** every 3–7 s:
  - it plays `BEHAVIOUR` and throws **3–4 mini-robots**, one per throw cycle, each 0.3 s
    into it,
  - each robot spawns 40 px in front and is launched at 400–900 px/s forward and 800–1500 up,
  - then it plays `TAUNT` and a sound for about 1 s.
- **Leap:** every 4.2–9.8 s at range, leading the target 1.5× when the player is jumping.
- **Cross-cooldowns** as above: ≥ 2.1 s or ≥ 1.5 s, and a 1/4 chance of ×1.5.

**Shield boss: `ShieldBoss`.** In practice it's a 250-HP-shield `ShieldEnemy` with
`NINJA_BOMB`. **[code]**

**How `BossEvent` runs a fight** (`Init @ b5190`, `Trigger @ b5620`, `Update @ b5a00`) **[code]**
- **Arena:**
  - about **1000 px (67 st)** of carriage type 6, with floor heights within 30 px of each
    other, inserted into the train,
  - followed by a gap car,
  - a **left barrier** (25 px) and a **right barrier** lock the arena,
  - a "BOSS" off-screen indicator and a key message are shown.
- **Difficulty tier = floor(score / 40,000)**:

  | Tier | Bosses | Adds (`BOSS_EXTRA` stage) **[inferred: that group]** | Reward × |
  |---|---|---|---|
  | 0 | 1 | none | 0.25 |
  | 1 | 1 | 1 | 0.40 |
  | 2 | 1 | 2 | 0.55 |
  | 3 | 2 | none | 0.70 |
  | 4 | 2 | 1 | 0.85 |
  | ≥ 5 | 2 | 2 | 1.0 |

  - Bosses spawn 600 px into the arena plus 150 px per boss, 275 px (18 st) apart.
  - They wait in Idle, which makes them invulnerable.
- **Trigger:**
  1. **Every enemy present flees** and spawning pauses.
  2. A **2 s camera cutscene** plays.
  3. Boss 1 taunts: a 1.5 s speech bubble, the `TAUNT` animation and its taunt sound.
  4. Boss 2 taunts 1 s later.
  5. Then health bars appear and the bosses are forced onto the player.
- **Adds:**
  - one wave every `WAVE_TIME` (the first at half),
  - each wave is rand(`START_MIN`..`MAX`) enemies, capped by `CAP_START` minus the cost
    already alive,
  - they spawn just **off-screen left or right**, 50 px out plus 25–50 px per extra add.
  - Which spawn-node fields these are is **[inferred]** from their offsets (+8, +0xc, +0x18).
- **Win:**
  1. The player says a line and a pulse effect sweeps the arena.
  2. **The player gets 500 × the multiplier in coins and 20,000 × the multiplier in score**.
     The base 500 is from the `LevelEvent` constructor.
  3. Camera shake type 4.
  4. The barrier opens and spawning resumes.

## 5. Taunts and speech **[code]**
- `Enemy::GetTaunt` → `EnemySpeech::GetSpeech` picks a random line from a per-theme pool:
  - ninja ×3, vampire ×2, skeleton ×2, robot ×3 (`BOSS_*_TAUNT_n`).
- **Its only caller is `BossEvent::BossTaunt`**, so boss lines are spoken **only at the intro
  cutscene**.
- Boss sounds during the fight:
  - the "attack" sound plays at the start of a charge or hover and when the skeleton king
    reforms,
  - the mech plays `TAUNT` after each throw volley.
- **Regular enemies never speak.** Other speech comes from events: hostage "HELP" and "FREE",
  tutorial lines, and the player's own lines.

## 6. Other details that sell the feel **[code]**
- **Knockback decays.** It falls exponentially (3/s) and snaps to 0 below 50 px/s
  (`HandlePhysicsPosition @ fac40`). That gives a quick shove, then a slide to a stop.
- **Retreat with a bad hand.** Mixed melee/ranged enemies visibly swap weapons (a swap
  animation) when the range changes. That's an honest tell.
- **Thrown minions** arrive spinning and invulnerable until they land, then lock onto the
  player.
- **Boss-fight start clears the stage.** Lights flee at 3.5× speed instead of popping out.
- **Corpses persist.** A corpse stays until it's gibbed, which feeds key-holder smashing and
  undead revives.

## Most useful for our game
- **Big Bart (Charger):** in the original, the charge is **triggered by taking about 30
  damage**. It runs at **2.5× walk speed: 26.7 st/s for a 10.7 st/s walker** for 34 st, and
  hits once.
  - Our design note says no charge speed was recovered, and set Bart to 10.7 st/s on that
    basis. **The real value is 2.5×.** Worth flagging before the Studio change to 10.7.
  - The original has no wind-up stagger. Our stagger is a deliberate addition.
- **McGraw:** timer charges every 4.8–7.2 s (50% doubled). A leap every 4–6 s when the
  player is more than 20 st away, landing into an 8 st hit. Cross-cooldowns of 2–3 s, and an
  **enrage below 15% HP (charge at least every 2.5 s)**. He never flinches.
- **Ma Rattler (summoner):** the original has both patterns we want:
  - the skeleton king's **burst into 6–8 minions at 66% and 33%**, invulnerable until they're
    dead,
  - the mech's **volley of 3–4 thrown minions every 3–7 s**.
- **Saloon Door Sam:**
  - make the doors a real collider on the hands,
  - **drop the guard while he flinches**,
  - give him a **0.2–0.5 s turn delay** so jumping over him is rewarded,
  - **×1.6 speed after the doors break**.
- **Rodeo Kid:** a spin every 0.5–1.5 × 2.8 s while chasing, at 2.5× speed, about 8 st high
  and about 19 st long. The spin does no damage. It has a 1/7-per-0.1 s escape from flinches.
- **Six-Shooter / Dynamite Dan:**
  - shots land 0.5–0.6 s into the animation,
  - 4 s ± 30% between shots,
  - no shot in the first 4 s after spawning,
  - Dan backs off while reloading and re-engages at 8–23 st.
- **Perception rules:**
  - enemies only notice you in front of them or after being hit,
  - they lose sight of you while you jump over them,
  - they match your roof or interior level,
  - they back off inside the minimum range.
  These cost little and make the AI readable.
- **Boss arena:** a barrier-locked ~67 st arena. Lights flee, and a 2 s intro taunt plays
  while the boss is invulnerable. Score-tiered adds and 1–2 bosses fit our co-op scaling.

## Couldn't determine
- **Animation durations** (`BEHAVIOUR` wind-up, attack swings, `TAUNT`). They're in the `.cm`
  model files, not the code, so the charger's wind-up and melee cadence in seconds are unknown.
- The easing curves of `CaTween` types 8 and 0xb, used for boss leap power vs distance.
- The exact **suicide blast area** (flag 0x4000 semantics, ray vs radius).
- **Projectile speeds** for enemy ballistics. The ballistic definitions weren't decoded.
- Whether the `fireDelay` inversion is intended. Also which spawn node `BossEvent+0x6c`
  points at; it's assumed to be the `BOSS_EXTRA` stages.
- **Enemy-vs-enemy non-collision** is inferred from the filter bits, not tested.
- Whether `LevelEvent`'s 500-coin base is changed per event elsewhere.

Related: [[Original Game]] · [[Original Game - Combat Feel (Native Code)]] · [[Original Game - Enemies and Spawning]] · [[Hit Feedback]]
