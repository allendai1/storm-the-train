---
tags: [reference, original-game, decompiled, player, movement, spin, health, revive, camera]
status: reference
updated: 2026-10-16
---
# Original Game - Player and Camera (Native Code)

> **Reference only, never canon.** This describes *Storm the Train* (2016), not our game.
> It was decompiled from `lib/x86/libMainApp.so` with Ghidra 11.4 on 2026-10-16. An
> analysis agent wrote it, and Claude spot-checked the key claims against the code.
> **[code]** means read from decompiled code or data; **[inferred]** means a reading
> that hasn't been checked in the running game. Addresses are Ghidra's (ELF VA + 0x10000).
> Start with [[Original Game - Combat Feel (Native Code)]]. The proposals for our game are
> in [[Hit Feedback]].

> Reference only. Ghidra addresses are used throughout (the image is based at +0x10000).
> Units: px on a 1024×768 screen. **15 px ≈ 1 stud.** Box2D works in metres at **100 px/m**
> (`DAT_00225360 = 100`), in a y-down world.
> CameraController wasn't in `decomp_all`, so I decompiled it separately into `S/decomp_C/`, along with
> `CaPhysics2D`, `Carriage::IsOutside` and `Barrier::*` (into `S/decomp_C2/`).
> This note extends "Combat Feel (Native Code)" and doesn't repeat it.

## 1. Movement

| Quantity | Original | Studs | Source |
|---|---|---|---|
| World gravity | 9.8 m/s² = 980 px/s² | 65 st/s² | `CaPhysics2D::CaPhysics2D @ b9660` (gravity vector (0, 0x411ccccd)) **[code]** |
| Agent gravity scale | 2.0 (Bob 2.2, one agent 1.8), giving **1960 px/s²** | **131 st/s²** | db.lua `CHARACTER_GRAVITY_SCALE`; `Character::ResetGravityScale @ c2750` (param +0x44 → body gravityScale) **[code]** |
| Run speed | default 425 px/s; Speed ability 275→500 in steps of 25 | 28.3; 18.3→33.3 | `PlayerCharacter::InitItemData @ 14b790` (fallback 0x43d48000 = 425) **[code]** |
| Acceleration | **none**: x velocity is set to ±speed every frame, on the ground and in the air | – | `Character::UpdateVel @ c17f0` **[code]** |
| Air control | **full**, the same instant velocity as on the ground | – | same **[code]** |
| First jump (on a roof or in the open) | vy += 9.1 m/s × JUMP_SCALE = **910 px/s**, giving an apex of **211 px** after 0.46 s and about 0.93 s of airtime | 60.7 st/s; **14 studs** high | `Character::Jump @ c2c00`, `DAT_002254c4 = -9.1` **[code]**; the height is derived |
| Bob (JUMP_SCALE 1.2, gravity 2.2) | 1092 px/s, 276 px apex | 18.4 studs | **[code+derived]** |
| Vertical speed clamp in Jump/ApplyForce | ±12 m/s = **1200 px/s** | 80 st/s | `DAT_0022549c/a0` **[code]** |
| Jump **inside a carriage** (under its roof) | vy = 4.5 m/s = **450 px/s** (a 52 px hop) **and the spin starts immediately** | 3.4 studs | `Jump`: branch on `+0x30c` = `Carriage::IsOutside` (y ≥ roof) **[code]** |

- **Double jump [code]** (`Character::Jump`): the second press only works outside, after a first
  jump, and while not already spinning.
  - **If still rising**, it adds 3 m/s (300 px/s, capped at 1200). Pressed straight after the first
    jump, that gives a ≈367 px (24.5-stud) arc.
  - **If at the apex or falling**, it sets vy to **400 px/s up**, a 41 px (2.7-stud) hop. A
    press at the apex totals ≈252 px (17 studs).
  - **It always starts the spin.** There's no third jump, because Jump returns early while spinning.
- **Coyote time / buffering [code]:**
  - There's **no jump buffer**: a press calls `Jump` directly (`Player::HandlePlayerInput @ 1491e0`).
  - There's no coyote *timer*, but the "jumped" flag (+0x2f8) is set only by `Jump`. Walking off
    a roof edge therefore leaves you a **full-strength jump in mid-air**, in effect unlimited
    coyote time. Walking off and then pressing jump twice gives jump plus spin.
- **Landing [code]** (`Character::HasLanded @ c2e90`): you land only while not moving up, when
  either foot (x ± half the bounding box) is within **10 px** of the carriage height. Landing
  clears the jump and ends the spin.
- **Direction input [code]** (`HandlePlayerInput`):
  - The last direction pressed wins. Releasing it falls back to the other direction if that's
    still held.
  - Facing flips instantly to the movement direction (`Character::UpdateVisual @ c2130`), so
    **you can't backpedal**.
- **Knockback on the player [code]** (`Character::ApplyForce @ c0590`, `UpdateVel`):
  - X force goes into a separate velocity term that **decays exponentially at 3/s** (a
    half-life of about 0.23 s) and snaps to 0 below 25 px/s (1.7 st/s). Y force is added
    directly and clamped to ±1200 px/s.
  - So knockback slides you, and your own input still steers on top of it.
- **Mayhem speed perk [code]** (`PlayerCharacter::Update @ 14bd20`): speed = base × lerp(1,
  `speed_mayhem`, Mayhem/100). The perk runs 1.1→2.0, so at level 10 a full meter doubles your speed.

## 2. The spin attack

- **Trigger [code]:** the second jump on a roof, or **any** jump inside a carriage.
  `SetSpinning` refuses while `+0x300` (spin-locked) is set, which TrainJump uses.
- **Duration and cooldown:** the spin **lasts until landing**, with no timer and no cooldown
  **[code]** (`Character::UpdatePos @ c3020` calls `SetSpinning(false)` on `HasLanded`). One spin
  per airtime.
- **Hit area [code, size unknown]:** a `DamageBody` enabled only while spinning (`Character::Reset
  @ c3370` creates it from the spin weapon; `SetSpinning @ c2b70` enables it).
  - Its shape is a box or circle fitted to a sprite on the character, scaled by the ballistic
    definition 0x2a3480. That definition is in BSS, so the size couldn't be read.
  - It hits **on contact** (`DamageBody::Contact @ d7890`).
- **Damage and knockback per level [code]** (CHAR_SPIN_ATTACK_n; the agent's `spinID` comes from
  ability 102):

  | Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
  |---|---|---|---|---|---|---|---|---|---|---|
  | Damage | 2 | 3 | 5 | 6 | 8 | 9 | 11 | 12 | 14 | 15 |
  | Force px/s (st/s) | 100 (6.7) | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 1000 (66.7) |

- **Knockback direction [code]:** `Contact` calls `ApplyForce(±F, +F)`, away from the body's x and
  **equally upward**. That's a 45° launch, divided by `ENEMY_WEIGHT`.
  - Normal guns push horizontally only, so the spin is the "pop them up" tool.
- **Theme bonuses apply [code]:** flag 0x800 (all player weapons, including the spin) multiplies the
  damage by the agent's `horror/future/oriental_dmg` (`Enemy::TakeDamage @ f74b0`).
- **Defensive value [code]:** there are **no i-frames** during the spin.
  - Each spin start **and** end sets a 0.2 s timer (`+0x32c`, `DAT_002254a4`), and damage taken
    during it is **halved** (`Character::HandleDamage @ c3f80`).
  - This closes the "second timer" question left open in the Combat Feel note.
- **Spinning suppresses your gun [code]** (`Character::SetFiring @ c2ad0`):
  - While spinning, the primary weapon is forced off. Your fire button is remembered and
    **shooting resumes automatically on landing**.
  - The secondary "spin gun" (`mayhemWepDef`) exists only on the mechs (`*_MECH_SPIN_GUN` in db.lua).
- **GetSpinAttackAngle / SetStartSpinAttackAngle @ c29d0 [code]:**
  - On fire-while-spinning, the start angle is set by `WeaponManager::FindTargetAngle`. That picks
    the visible enemy (on camera, 100 px margin) with line of sight, choosing the first enemy
    clockwise or counter-clockwise depending on facing. Angles run 0 = up, 90° = right.
  - If there's no target, or it's outside the facing half (more than 215° facing right, under
    145° facing left), it falls back to **135° (down-right) or 225° (down-left)**.
  - Each shot then rotates the angle **15°** (`Character::PreFire @ c1e30`, 0.2618 rad), making a
    sweeping spray.
  - This only matters for **mech spin guns**.
- **Corpse smashing [inferred]:** spin hits are ordinary contact damage; the rule that
  finishes downed undead (mission `MISSION_SPIN_GIB_CORPSES`) is in Enemy code.
- **The default spin level** without the ability is probably 4 [inferred]: the fallback
  `FindWeaponDef` string next to `CHAR_SPIN_ATTACK_%i` in rodata is `CHAR_SPIN_ATTACK_4`.

## 3. Firing input

- **Hold to fire [code]:** input 3 (press/release) maps to `Character::SetFiring`. There's no
  auto-fire for agents; `Player::SetForceFiring` is used only by `JetpackEvent`. Pressing fires
  immediately if the interval has elapsed (`Weapon::SetFiring @ 170a10`), then repeats on
  `Weapon::Update`'s timer.
- **No auto-aim for agent guns [code, from caller lists]:**
  - `FindTargetAngle` is called only by the spin angle and TeleportBoss.
  - `FindClosestTargetAngle` (callers: TurretDrone, FreezeDrone) is drones only.
  - Agent shots go straight along the facing direction (angle 0 → facing, `Weapon::Fire @ 172150`).
  - Vertical threats are dealt with by jumping and spinning, not by aiming.
- **Firing while running or jumping is allowed [code]** (`Character::UpdateAnim @ c1bc0`):
  - the run loop continues while firing,
  - there's a dedicated air-fire animation (6),
  - standing fire is anim 0xb.
- **Animation sync [code]:**
  - `Character::PreFire` flags a "pre-fire" anim and forces the rig's locators to evaluate that
    frame, so the muzzle position matches the pose.
  - `Weapon::GetAnimFireDelay` is used only by enemy leap attacks, and every player weapon's
    `fireDelay` is 0, so **there's no wind-up on player shots**.
- **Controls [code]:** four movable on-screen buttons (left, right, jump, fire;
  `ControlCustomization`). The swap is a swipe.

## 4. Health

- **One pool for the squad [code]:** `Player` owns the health (`+0x3c` max, `+0x40` current).
  Characters read and write it through `Player::GetHealth/SetHealth`. A normal run gets **10 HP**
  (`GameControl::GameKickoff`: `InitHealth(10.0)`); Survival gets ε (one hit).
- **Damage taken [code]** (`HandleDamage`) = hit × health-booster consumable × **resilience** ×
  0.5 (in the spin window) × theme-defence multiplier (`Character::TakeDamage @ c0080`, enemy weapon
  flag 0x1000).
  - Resilience comes from ability 100 (1.00 → 0.16, default 0.5).
  - So a light melee hit (3) costs 30% of the pool at resilience 1.0, or 7% at Bob's 0.24.
- **Costume (armour) states [code]** (`Player::CalcNewHealthState @ 1485c0`):
  - **2** above 2/3 HP, **1** from 1/3 to 2/3, **0** below 1/3.
  - Crossing a threshold rebuilds the visuals, plays a hurt line, and fires the character's
    `+0x348` weapon. That's an unidentified effect or AOE created in `Character::Init`; it might
    be a knockback burst [inferred].
- **Heal orbs (`HealthProjectile`) [code]:**
  - The "gib" type grants its health **instantly**, at spawn, while a green orb effect floats up
    for 3 s.
  - The "curve" type (healer drone) homes in on the player, from 300 to 1200 px/s over 1.2 s,
    and heals on arrival.
  - Amounts are **raw HP out of 10**.

  | Perk (ability) | Rule | Level 1 → 10 |
  |---|---|---|
  | `heal_time` (110) | While below full, an accumulator fills at the rate per second. Every 0.1 HP spawns a 0.1 HP orb. | 0.025 → 0.25 HP/s (**0.25 → 2.5 %/s**) |
  | `heal_kill` (111) | On a kill: amount = min(seconds since the last heal-kill × rate, **0.2 HP**). It spawns only if ≥ 0.1 HP, then the timer resets. | 0.05 → 0.5 /s, so **1–2 % per kill**, and rapid kills don't stack |
  | `heal_fullMayhem` (112) | The same accumulator, but only while Mayhem ≥ 100 | 0.05 → 0.5 HP/s (0.5 → 5 %/s) |
  | `mayhem_dmg` (114) | On taking damage: Mayhem += Δ(health fraction) × rate × 100 (not on instant kills) | 0.2 → 2.0 (losing 10 % gives +2 to +20 Mayhem) |

  Sources: `PlayerCharacter::Update @ 14bd20`, `::EnemyKilled @ 14b5d0`, `::HandleDamage @ 14bfa0`,
  `HealthProjectile::Init/IssueHealth` **[code]**.
- **Forcefield [code]** (`Player::ActivateForcefield @ 14a020`):
  - It's **not a pickup**. It's a protective bubble used by:
    - **gadget type 9**, for **2 s**, with a voice line (`Player::GadgetActivated`),
    - action-pause and menu moments (released after a 0.5 s linger),
    - mech entry and gadget intros.
  - While it's up: **input is locked**, the player is invulnerable, and a solid physics circle of
    `FORCEFIELD_R` (**55 px = 3.7 studs**; Mason 60) pushes bodies away.
  - When it ends, the player fires the Begin-created weapon at `+0x28`, almost certainly
    **FORCEFIELD_AOE** (force 1250 px/s = 83 st/s) [inferred mapping].
  - Swapping keeps the bubble and its effect.

## 5. Death and revive

- **The death sequence [code]** (`Character::StartDeathSequence @ c2e10`, `UpdateDeathSequence @ c3d60`):
  1. You stop, lose fire and spin, and play the death anim (4), then the down/twitch anim (3)
     once grounded.
  2. After **1 s**, the corpse is gibbable: further hits blow it apart.
  3. `Player::Update @ 14ac20` locks input. After **2.0 s** it opens the revive screen and
     disables gadgets.
- **Revive cost [code]** (`HealDisplay::GetReviveCost @ 1243e0`):
  - **2ⁿ gems × (1 − health fraction)**, where n is the number of revives so far, capped at 32.
    That gives **1, 2, 4, 8, 16, 32**.
  - An ad revive (`REVIVE_ADS`, mode 3) doesn't increase n.
  - A mid-run "heal" option (mode 1) costs min(150 × 2ⁿ, 20000) × the missing fraction, in an
    unknown currency, and *does* add the healed fraction to n.
- **The revive [code]** (`Player::Revive @ 14aa30`):
  1. The old body is **gibbed** if it isn't already (a comic explosion).
  2. You respawn at the same x on the current train's carriage floor. In a gap, you go to the
     top-centre of the closest carriage (`GetValidRevivePos @ 149ef0`).
  3. Full HP, **3 s of invulnerability**, and the camera `SnapX`es to you.
  4. **All enemies flee** (`EnemyManager::FleeAll`).
  5. The player fires its `+0x24` weapon. That's **REVIVE_AOE**, with force 1550 px/s =
     103 st/s and shake type 2 [inferred mapping].
  6. Gadgets and the top bar come back.
- **Other grace timers [code]:** leaving a vehicle 0.5 s, a jetpack 0.5 s, a mech 0.2 s.
  Cutscenes set the player invulnerable.
- **Falling off the train:** not resolved. `Player::ForceDeath @ 148c20` applies an instant-kill
  weapon at a random point ±10 px around you, but its callers are virtual and untraced.

## 6. Agent swapping

- **Input [code]:** a horizontal **swipe**. It has to cover more than **1.2 cm** within
  **0.5 s**. Swipes in both directions give the same result: they toggle between the 2 equipped
  agents (`GestureControl::Control @ 120a10`, `GameController::Delegate`).
- **Blocked when [code]** (`Player::SwapCharacter @ 14afb0`):
  - you're dead,
  - you're in a vehicle, jetpack or chopper,
  - you're entering a mech,
  - a gadget-manager state is active,
  - the feature hasn't been unlocked yet (the tutorial unlocks it),
  - you don't have 2 agents equipped.
- **No cooldown, no invulnerability and no swap attack** appear anywhere in the swap path
  **[code]**. It's instant, with a puff effect (0x60).
- **What carries over [code]** (`DuplicateCharacterState @ 148880`):
  - position, velocity, move direction and facing,
  - **jump and spin state**, so you can swap mid-air and mid-spin,
  - the held-fire state, visibility, the forcefield and the blueprint flag,
  - the shared HP.
  - **Each slot keeps its own current weapon**: a crate pickup stays with that agent.
  - Speed resets to the incoming agent's own speed.

## 7. Camera (`CameraController`, decompiled at `S/decomp_C/`)

- **X follow [code]** (`Update @ bad10`):
  - The target is player x + a **lead of 256 px (17 studs)** in the direction you're moving. When
    you stop, the lead drops to 0 and the camera recentres you.
  - Small target changes (≤ 1260 px/s × dt, i.e. 84 st/s) are followed **1:1**.
  - Bigger jumps (the lead flipping, locks) are added to an offset that eases back over
    **|Δ| / 110 px/s, clamped to 0.33–4 s**. A lead flip takes about 2.3 s.
  - Vehicle and jetpack modes: the lead is always forward and the following is rigid.
- **Y [code]:**
  - On 4:3 screens there's no vertical follow.
  - On screens wider than 1.4, `CalcAdjustedY @ bab60` uses base 246 − 0.5 × (player y − 200),
    clamped to at most **150 px (10 studs) up**.
  - Y is followed only when `FollowPlayerY` is on (jetpack, CDW, chopper and checkpoint events).
  - The Y tween threshold is 21 px.
- **Locks [code]:** `LockLeft/LockRight @ ba880/ba8e0` clamp the camera so a `Barrier` (the
  go/stop-sign train ends, event arenas) sits exactly at the screen edge. Unlocking eases out.
  `SnapX` is used on revive.
- **Zoom:** none. The scale is set once from the aspect ratio in the constructor **[code]**.
- **Background scroll [code]:** a parallax "train speed" of **900 px/s (60 st/s)**. It boosts to
  2700, ramping at 900 px/s² up and 450 px/s² down. The environment camera is that scroll plus
  0.5 × the camera x.
- **Cutscene pans [code]** (`CutsceneManager::StartCutscene/Update`):
  - The camera tracks to a point over **2.5 s** whatever the distance, holds, then tracks back.
  - Once the player is visible, a 0.4 s settle follows and the track speed is restored to 110.

## 8. The train leap (`TrainJump`)

The states run 1 → 10 **[code]** (`TrainJump::SetState @ 162380`, `Update @ 1628d0`).

| State | What happens |
|---|---|
| 1 Trigger | Cutscene pan to the jump point: carriage end − **80 px** (5.3 st), with the camera aimed 200 px higher and a 1 s hold. Indicator `EVENT_NTE_JUMP_INDI_ON` ("JUMP FROM HERE"). |
| 2–3 | Gadgets and the HUD bar are hidden; the indicator is removed. |
| 4 ReadyToRun | Only **right** is unlocked. The first move goes to state 5. |
| 5 Auto-run | Input locked, a forced run right with the sprint loop (anim 0x12). Speed **330 → 680 px/s** (22 → 45 st/s) at **+460 px/s²**, over about 0.76 s. A 20×100 px sensor sits **425 px (28 st) before** the jump point. |
| 6 | Entering the sensor unlocks **jump only**. |
| 7 | On jumping, the leap anim (0x13) plays, jump locks again and gadgets come back. |
| 8 | On landing, the **spin is locked for 0.2 s**. |
| 9 | Everything unlocks, a landing anim (0x14) plays, speed resets, and a **550 px/s (37 st/s)** forward push is applied [inferred: vtable +0x68 = ApplyForce]. |
| 10 | Once settled: train-jump mission and achievement credit, HUD back. |

- A left barrier 50 px from the train start stops you running back **[code]** (constructor).
- At 680 px/s with a 910 px/s jump, the flat-ground arc is about **630 px (42 studs)** before any
  fall [derived].

## Most useful for our game

- **Jump:** our `JUMP_HEIGHT` of 8 studs is low next to the original's **14** (Bob 18), which
  it reaches with **2× gravity (131 st/s²)** and a ~0.9 s airtime. Use high gravity plus a high
  jump velocity for the same snap ([[CharacterService]]).
- **Double jump = spin:** a second press while rising *adds* velocity; at or after the apex it
  *resets* to a small hop. Either way the spin starts and lasts until landing. One spin per
  airtime with no cooldown is easy to validate on the server ([[CombatService]]).
- **Spin as a pop-up:** knockback (±F, +F) with F = 6.7 × level st/s. Guns pause during the spin
  and resume on landing. Damage taken is halved for 0.2 s at spin start and end, with no full
  i-frames. On our 100 HP pool the damage table ×10 gives 20 → 150 [inferred].
- **Movement:** instant velocity with full air control. Player knockback is a separate term that
  decays at 3/s, so input still steers.
- **Camera:** the original leads about **17 studs** in the direction of movement, recentres when
  you stop, and eases a lead flip over about 2 s. It has no zoom and almost no vertical follow.
  Ours leads 8 studs by facing ([[CameraController]]): consider leading only while moving.
- **Revive:** 3 s of invulnerability, a radial push (103 st/s), **all enemies flee**, and a respawn
  on the carriage floor. Gem cost 1/2/4/…/32, ads don't escalate (matches our doubling rule).
  The 2 s before the revive screen is a good beat for our downed state.
- **Swap:** no cooldown in the original, and the full state carries over (mid-air, mid-spin, each
  agent keeps its own crate weapon). Keep the carry-over; our 1.5 s cooldown is a deliberate
  departure ([[Launch Agents]]).
- **Perks on 100 HP:** heal over time 0.25–2.5 HP/s; heal on kill 1–2 HP and **time-gated**
  (min(t × rate, cap)) so streaks don't stack; Mayhem speed lerps to ×mult at a full meter
  (respect the 33 st/s cap).
- **Scripted train leap** ([[Loop (M2)]]): forward-only, auto-run 22 → 45 st/s, jump unlocks
  about 28 studs before the take-off mark, a barrier behind the player, spin locked for 0.2 s
  after landing, then a 37 st/s forward push.

## Couldn't determine

- **The spin hitbox size and the AOE radii** (REVIVE_AOE and FORCEFIELD_AOE). Both depend on BSS
  ballistic and weapon definitions (0x2a3480 and +0x74) that are filled at runtime.
- **The REVIVE_AOE and FORCEFIELD_AOE mapping** to `Player +0x24/+0x28` is inferred from where
  they're fired, not from their name strings.
- **Falling off the train:** the death or teleport handling. `ForceDeath`'s callers are virtual.
- **The armour-break weapon** at `Character +0x348`: its identity and effect.
- **The heal-option currency** and how `HealDisplay` modes map to the UI buttons.
- **Whether `GameController` adds a swap cooldown in the UI.** None is in the swipe path. A swap
  button (if any) wasn't traced.
- **Player vtable slots +0x68/+0x74/+0x78** used by TrainJump. The 550 push is assumed to be
  ApplyForce.

Related: [[Original Game]] · [[Original Game - Combat Feel (Native Code)]] · [[Original Game - Enemies and Spawning]] · [[Hit Feedback]]
