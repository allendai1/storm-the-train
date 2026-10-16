---
tags: [reference, original-game, decompiled, weapons, projectiles, status-effects, drones, mechs, gadgets]
status: reference
updated: 2026-10-16
---
# Original Game - Weapons and Gadgets (Native Code)

> **Reference only, never canon.** This describes *Storm the Train* (2016), not our game.
> It was decompiled from `lib/x86/libMainApp.so` with Ghidra 11.4 on 2026-10-16. An
> analysis agent wrote it, and Claude spot-checked the key claims against the code.
> **[code]** means read from decompiled code or data; **[inferred]** means a reading
> that hasn't been checked in the running game. Addresses are Ghidra's (ELF VA + 0x10000).
> Start with [[Original Game - Combat Feel (Native Code)]]. The proposals for our game are
> in [[Hit Feedback]].

> Reference only, never canon. This is source material for Train Mayhem. Tags: **[code]** means read from decompiled code or data. **[inferred]** means a reading that hasn't been checked in the running game. Addresses are Ghidra addresses (ELF VA + 0x10000). Units are px on 1024×768, with **15 px ≈ 1 stud**. Physics is Box2D at **100 px/m**, with a fixed **1/60 s** step and gravity **(0, 9.8) m/s² = 980 px/s² ≈ 65 studs/s²** (`CaPhysics2D::CaPhysics2D @ b9660`, `CaPhysics2D::Update @ b9960`) [code].
>
> This file extends the existing notes and doesn't repeat them: Combat Feel (lob formula, muzzle effects, knockback ÷ weight, shake types), Balance Audit, and Items and Economy (gadget durations per level, mech stats).

## 0. Corrections to existing notes
- **The ±30 % fire-interval jitter applies to enemy weapons, not the player's [code].** In `Weapon::Fire @ 172150` the jitter only runs when byte +0x2c of the weapon record is 0. That byte is 1 on every player gun, including the pistol, shotgun and rockets. It's 0 on enemy weapons (fireball, firework, skull, stakes, megagun…). So byte +0x2c is really a "player / held-trigger weapon" flag: `Weapon::SetFiring` uses it for hold-to-fire.
- **The lob launch angle isn't a flat 42° [code].** `Ballistic::Init @ af450` multiplies only the horizontal launch component by the projectile's gravity scale (+0x18). The result is atan(0.9 / gravScale): **31° for the ninja grenade and 24° for the sticky bomb**.
- **Weapon record +0x1c is the explosion radius (px), and +0x14 is the attack wind-up [code].**
  - `WeaponManager::WeaponManager @ 1736d0` stores (+0x1c)² at +0x74, which is what `Ballistic`, `Weapon::Fire` and `DealAOEDamage` test. The `aoe` column in the TSV is that square before init, which is why it reads 0.
  - +0x14 is returned by `Weapon::GetAnimFireDelay`; +0x10 is `GetFireDelay`. `Enemy::Attack @ fc690` waits fireDelay, then plays the attack animation, then fires after animFireDelay.
- **Rail hitscan is dead code [code].** No weapon has flag bit 0x8, so `Weapon::DealRailDamage` is never reached. The railgun fires piercing projectiles instead (§4).

## 1. Projectile table (`BallisticDefinition`, 29 records, `_INIT_185 @ ab2f0`)

**Field meanings [code]** (from `Ballistic::Init/Update/Contact`, `Weapon::FireBallistic @ 1713f0` and `WeaponManager` ctor):

| Off | Field | Behaviour |
|---|---|---|
| +0x00 | sprite | Texture is resolved into +0x58. |
| +0x04 | trail effect id | A particle effect that follows the projectile; 0 = none. |
| +0x08 | impact effect id | Spawned on death. |
| +0x0c | speed px/s | Straight shots: velocity = facing × speed, or (sin a, cos a) × speed when given an angle; aimed enemy shots use normalize(target − muzzle) × speed. 0 = lob. |
| +0x10 | max range px | Squared into +0x5c. `IsOutOfRange` despawns the projectile past this distance from its spawn point. |
| +0x14 | **fuse s** | −1 = none. When set, the sprite blinks between the record's colour at +0x48 (red) and white. The blink period is (fuse − age) × 0.2, with a floor of 0.02 s. The projectile explodes when age > fuse. With no fuse, the sprite rotates to face its velocity. |
| +0x18 | gravity scale | Lob only. It also scales the horizontal launch component. |
| +0x1c | spin | Angular velocity = spin × launch-x. |
| +0x20 | collider | 1 = box, 2 = circle; otherwise no body. +0x24 and +0x28 scale the sprite's width and height. |
| +0x2c | **lob** | Dynamic Box2D body with friction 0.2 and **restitution 0.4**; non-lob projectiles are sensors. |
| +0x2d | **pierce** | See §4. |
| +0x30 | speed variance | The horizontal speed is multiplied by a random 1 ± v. |
| +0x34 | **train-stick depth px** | On touching the train or another physics object, the projectile embeds this deep and then rides along with it. |
| +0x38 | **character/shield-stick depth px** | Same, on touching a character or a shield. |
| +0x40 | impact sound | −1 = none. |
| +0x44 | **priority** | The Defender drone prefers these during vehicle events. |

**Contact rules [code]:**
- A projectile without an explosion radius deals its damage directly to whatever it touches and dies.
- A projectile with a radius deals **no** direct damage. It dies, and `Update` detonates it (§2).
- **Anything that touches the train dies at once, unless it sticks.** So grenades explode on their first contact with a carriage. The fuse is only a mid-air timeout, and the 0.4 bounce only matters off non-train geometry [inferred].
- Weapon flag 0x80 (the anti-vehicle missiles and mines) also kills the projectile once it's more than 100 px behind the camera's left edge.

Below, *AOE* is the firing weapon's radius at +0x1c. Studs are in brackets.

| # | Sprite / trail | Used by | Speed px/s | Range px | Special |
|---|---|---|---|---|---|
| 0 | fireball / Fireball | MEDIUM_FIREBALL | 270 (18) | 1024 | circle; AOE 80 (5.3) |
| 1 | grenade / SmokeRocket | NINJA_BOMB | lob | — | **fuse 1.75 s**, grav ×1.5, spin; AOE 80 |
| 2 | rpg (lob) | *no weapon* | lob | — | fuse 2.0, grav ×1.8, sticks to train 1 px (unused) |
| 3 | ball_vehicle_projectile | SHRAPNEL_BLAST | 800 (53) | 2048 | box 0.6×0.2, sticks to train 4 px |
| 4 | (none) | spin attacks, DRONE_MELEE, BALL_BODY, mines | — | — | dummy; these are contact damage bodies |
| 5 | rpg / SmokeRocket | ROCKETLAUNCHER_1-10, AIRSTRIKE | 700 (47) | 1850 | AOE 60 (4) / airstrike 180 (12) |
| 6 | firework / Firework | FIREWORK | 300 (20) | 1024 | AOE 40 (2.7) |
| 7 | rpg | CHOPPER_WEAPON | 2500 (167) | 1850 | AOE 120 (8) |
| 8 | mayhem_shot / MayhemShot | DAMAGE_MECH_*, JETPACK | 800 (53) | 718 (48) | AOE 90 (6) |
| 9 | skull / FlamingSkull | SKULL | 300 (20) | 1024 | AOE 40 |
| 10 | heavy stake | BOSS_STAKE | 650 (43) | 1850 | **sticks 40 px into the train**; direct hit |
| 11 | spin_shot | DRONE_TURRET_1-5 | 1600 (107) | 1850 | **AOE 80** (turret shots explode) |
| 12 | (none) | DRONE_CORPSE | — | — | dummy |
| 13 | missile / AntiVehicle | ANTI_BALL/JETPACK_MISSILE | 300 (20) | 1850 | **priority**; AOE 80 |
| 14 | beam_1 / RobotBeam | MEDIUM_BEAM | 350 (23) | 1024 | AOE 80 |
| 15 | beam_2 / RobotBeam1 | LIGHT_BEAM | 270 (18) | 1024 | AOE 40 |
| 16 | medium stake | MEDIUM_STAKE | 450 (30) | 1850 | sticks 40 px; direct hit |
| 17 | missile_boss / MegaGun | FUTURE_BOSS_MEGAGUN | 600 (40) | 1850 | AOE 80 |
| 18 | lightning_ball / LightningBall | LIGHT_FIREBALL | 270 (18) | 1024 | AOE 40 |
| 19 | lightning_ball / FreezeDrone | DRONE_FREEZE_1-5 | 900 (60) | 1850 | **AOE 100 (6.7)**, impact ExplosionRadial |
| 20 | sticky_bomb / SmokeRocket | STICKYBOMB_1-10 | lob ±25 % | — | **fuse 1.3 s**, grav ×2; sticks to train 5 px, to enemies and shields 8 px; AOE 65 (4.3) |
| 21 | poison_dart / PoisonHit | POISON_1-10 | 750 (50) | 1850 | **AOE 100**: a splash that applies poison |
| 22–24 | lightning_ball / RailGunLow, Mid, High | railgun charge tiers | 900 (60) | 1024 | **pierce**, impact RailgunExplosion |
| 25 | mayhem_shot_defence | DEFENCE_MECH_SPIN | 800 | 718 | AOE 90 |
| 26 | mayhem_shot_heal | HEAL_MECH_* | 800 | 718 | AOE 90 |
| 27 | plasmaGun_shot / PlasmaCannon | PLASMA_CANNON_1-10 | 700 (47) | 1850 | AOE 60, PlasmaCannon_Explosion |
| 28 | sticky_rifle / StickyRifle | STICKYRIFLE_1-10 | 1000 (67) ±25 % | 700 (47) | straight; **fuse 0.5 s**; sticks 5/8 px; AOE 65 |

**Lob flight [inferred: the body has density 0, so Box2D gives it 1 kg].** The launch vector from `FireBallistic` is applied as a one-step force.
- Δv ≈ (1.6·b·g_s, 1.44·b) × 100/60 px/s, where b = max(100, 0.45 × distance to target) and g_s is the gravity scale.
- **Horizontal reach ≈ 0.013·b² px, whatever the gravity scale.** That's exact at about 380 px (25 studs). Nearer targets are overshot, with a minimum of about 130 px; farther ones fall short.
- **Flight time ≈ 0.0049·b / g_s s**, so about 0.44 s for a sticky bomb thrown at a target 400 px away.

## 2. Area damage (`WeaponManager::DealAOEDamage @ 175830`) [code]
- **The radius is weapon +0x1c, and there's no falloff.** Every target whose **bounding box** overlaps the circle (`IsSquareInCircle`) takes the full damage, so big enemies are caught from farther away. The blast needs **line of sight**: a ray from the centre that hits the train or a shield (mask 0x1008) first blocks it.
- **Knockback is radial**, along the unit vector from the centre to the target, scaled by the weapon's force, **with the vertical part × 1.3**. Then ÷ enemy weight, as already known. So explosions pop enemies up and out, whereas bullets push horizontally only.
- **Friendly fire is one-sided.**
  - A blast aimed at team 0 (the player) **also runs against team 1 (enemies)**: enemy explosives (ninja bombs, fireworks, skulls, beams, megagun) hurt other enemies.
  - Player explosions only hit enemies, plus shields (`Shield::TakeDamage` when the shield's segment crosses the circle), gibs (`GibManager::ApplyExplosion`) and pickups (`PickupManager::ApplyExplosion`). They never hurt the player.
- **Projectiles of opposite teams can't touch each other.**
  - Player projectiles collide with categories 0x900a: enemies, train, shields, sensors.
  - Enemy projectiles collide with 0x8609: player, train, 0x200, drones, sensors.
  - Neither mask contains the other team's projectile category, so **bullets never shoot bullets down**. Hitscan weapons only damage characters and shields.
- **Radii in use:**

  | Radius | Weapons |
  |---|---|
  | 40 (2.7) | fireworks, skulls, light beam |
  | 60 (4) | rockets, plasma |
  | 65 (4.3) | sticky weapons |
  | 80 (5.3) | ninja bomb, fireballs, turret drone, megagun, missiles, SUICIDE |
  | 90 (6) | mech shots |
  | 100 (6.7) | poison, freeze drone |
  | 180 (12) | airstrike |
  | 350 (23) | FORCEFIELD_AOE |
  | 512 (34) | REVIVE_AOE |
  | **800 (53)** | MECH_AOE |

## 3. Status effects (`EnemyDotData`, `Enemy::*Dot*`) [code]
**DoT record (16 B), pointed to by weapon +0x64:** {type, duration s, DPS, effect class}.

| Weapon | Type | Duration | DPS | Total / application |
|---|---|---|---|---|
| FLAMETHROWER 1→10 | 2 fire | 1.5 → 2.3 s | 29 → 51.9 | 43 → 119 |
| POISON 1→10 | 0 poison | **6 s** | 20 → 35 | 120 → 210 |
| DRONE_FREEZE 1→5 | 1 freeze | 1.0 → 1.18 s × FREEZE_SCALAR | 0 | — |

- **Damage is continuous, not ticked.** `EnemyDotData::Update @ 1011d0` calls `TakeDotDamage(dt × DPS)` every frame.
- **One DoT per type, refreshed rather than stacked.** `WeaponManager::IsAllowedMultipleOf` reads a table at 0x233bf0 that is all 0. `Enemy::ShouldAddDot @ f90e0` replaces an existing DoT of the same type only when its remaining time is less than the new base duration, and otherwise ignores the new one.
  - So a flamethrower held on a target keeps one burn topped up.
  - Poison darts keep resetting the 6 s timer, and their 100 px splash poisons whole groups.
  - At most 2 copies of a DoT's visual effect are shown per enemy.
- **Freeze is a full stop, not a slow.**
  - `Enemy::SetFrozen @ f8590` zeroes velocity and flags the body.
  - While frozen, `Enemy::Update` skips the AI, all timers, movement and facing.
  - `Enemy::ApplyForce` ignores knockback, and `HandleDamageAnim` skips flinches.
- **FREEZE_SCALAR** (`Enemy::GetFreezeTimeScalar` = EnemyData +0x44; 1.0 small / 0.6 mid / 0.3 boss) multiplies only the freeze **duration**: about 1 s on lights, 0.6 s on mids and 0.3 s on bosses.
- **Fleeing on fire.** Any fire DoT sets the enemy's burning flag (`ApplyDotEffects`).
  - Enemies whose data flag +0x48 is set (`SetAIStateOnFire`) switch to a flee state.
  - `Enemy::FleeOnFire @ fd050` runs them away from the player at **2× speed** and jumps them between carriages when needed.

## 4. Beam, chain, rail and charge weapons [code]
- **Beam (flag 0x2): `Weapon::DealBeamDamage @ 171910`.**
  - Each fire tick, a ray hits **every character along the line** for full damage.
  - It stops at the **train** (spawning the weapon's "Block" effect, +0x44) or at a **shield**, which takes the hit and blocks it.
  - The beam sprite is shortened to the stopping point.
  - **There's no chaining anywhere in the code**: "lightning" is a piercing line.

  | Weapon | Damage per tick | Tick | ≈ DPS per target | Range px |
  |---|---|---|---|---|
  | **Lightning Gun** | 4 → 7 | 0.1 s | 40 → 70 | 340 (23) |
  | **Heatray** (+ fire DoT, flee) | 1 → 2 | 0.15 s | 7 → 13 direct | 200 (13) |
  | **Gears of Gore** (chainsaw) | 3 → 6 | 0.05 s | 60 → 120 | 80 (5.3) |
  | Defence-mech saws | 5 | 0.05 s | 100 | 70 |

  The chainsaw and the defence-mech saws also attach a solid hexagonal blade body in front of the player (record +0x68: 15×16 px at offset 50, 58), jointed to the hand. That body shoves enemies physically [inferred].
- **Railgun (`ChargeWeapon`, charge record at weapon +0x60).**
  - **Hold to charge, release to fire.**
  - The charge time is **1.1 s at every level**.
  - **Damage = EaseInCubic(min, max, t/1.1)** = min + (max − min)·(t/1.1)³. Level 1 runs 15 → 170 and level 10 runs 26.25 → 298 (+1.5 min and +17 max per level, roughly).
  - **Tiers by charge fraction:** under 0.3 fires RailGunLow (#22), under 0.6 RailGunMid (#23), otherwise RailGunHigh (#24).
  - A charge fraction of 0.8 or more plays the "strong" sound.
  - **Recoil = EaseInCubic(0, −250, fraction).** A full charge kicks the shooter back about 17 studs/s.
  - Charging shows the RailGunCharge effect, then swaps to the tier's trail effect when full.
- **Piercing projectiles** (`Ballistic::Contact @ b0560`, the railgun balls).
  - The projectile carries its damage as a pool.
  - Each target hit takes min(pool, max(1, target HP)), and that amount is subtracted from the pool.
  - The ball dies when the pool is empty.
  - So one big shot kills a line of weak enemies, and the overkill keeps going. Shields drain the pool the same way.

## 5. Drones [code]
- **Duration** comes from item data (the per-level table is in Items and Economy). `Drone::HandleDuration` drains it in real time. It pauses while gadgets are paused (DroneManager +0x18).
  - **Healer and Corpse drones are charge-based** instead (below).
- **Slots and follow.** There are 6 slots: `DroneManager::GetAvailableDroneSlot` with the table at 0x232760.
  - Slot choices by type: Turret, Freeze and Healer use {0, 1, 2}; Melee {3, 4, 5}; Defender {5, 3, 4}; Corpse {3, 4, 2}.
  - That allows up to 3 drones of one type, and mixed types together.
  - `Drone::FollowPlayer @ d9e60` targets offsets from the player, mirrored with facing. Slot 0 sits directly above at +160 px (11 studs). The others sit 45–150 px (3–10 studs) behind, at +50 to +220 px (3–15 studs) up.
  - There's a ±dead-zone before a drone moves sideways, and a raycast keeps it out of carriage walls.
  - The spawn height is the player's y + 60 px, or the carriage roof + 60.

| Drone | Weapon / behaviour | Numbers |
|---|---|---|
| **Turret** (drone_1) | Targets the enemy needing the **smallest turn** from its current aim. There's no distance limit, but the target must be on screen (100 px margin) and in line of sight. It turns at **200°/s** and fires when within 1°. | DRONE_TURRET 11 → 14 damage, every **0.3 s**; 1600 px/s exploding shots (AOE 80) |
| **Freeze** | Same aiming as the turret. | One shot every **1.5 s**; 100 px AOE freeze (no damage) |
| **Melee** (drone_3) | Chases the **nearest** visible enemy in line of sight. Two 35×35 px damage bodies orbit ±25 px around it, spinning at 2π rad/s idle and **4π rad/s attacking**. The bodies are toggled every 0.05 s so contact damage re-triggers. | DRONE_MELEE 4 → 5 damage per contact, weapon interval 0.2 s |
| **Defender** (drone_2) | Moves up to 250 px toward the **nearest enemy projectile** on screen (`FindClosestBallistic` with `IsValidBallistic`). Its body is category 0x400 with **mask 0x40**, so it physically collides with enemy projectiles. Each one that touches it is destroyed (`Ballistic::Contact`, flag 0x400) and counts for the "block N projectiles" mission. | During vehicle and jetpack events it only takes projectiles within ±100 px of the player's height and ahead of the player, and it prefers priority missiles. **Each anti-vehicle missile or mine it blocks costs 3 s of duration** (`DefenderDrone::TakeDamage`). |
| **Healer** | Every **0.55 s** it fires a curving health orb worth **0.11 HP** and subtracts 0.55 from its duration. | The player has **10 HP** max (`GameControl::GameKickoff`), so this is 0.2 HP/s, or 2 % of max HP per second. Level 1 (15 s) heals 3 HP and level 10 (28.5 s) heals 5.7 HP. |
| **Corpse ("Smasher")** | Flies to the nearest corpse in line of sight (`EnemyManager::GetClosestCorpse`) and enables its DRONE_CORPSE body within 90 px. | Each corpse smashed releases health gibs worth **0.3 HP** and **costs 1 duration**, so "duration" 10 → 19 is a number of corpses: 3 → 5.7 HP |

## 6. Mechs [code]
- **Duration** comes from item data (15 → 26.7 s). `Mech::Update` counts it down unless it's paused or the mech is still entering. The mech's health bar shows remaining / total.
- **Entry** (`Player::GiveMechSuit`, `DamageMech::EnterMechSuit/Update`):
  - The player gets a **2.5 s forcefield**: invulnerable and input-locked.
  - The mech drops in, plays the PlayerInToMayhem effect and **camera shake type 1 at 0.8, 1.5 and 2.2 s**, then hands control back.
  - The enemy spawner switches to event state 4 for the whole time.
- **Exit:** the mech gibs, plays PlayerOutOfMayhem, and **fires the mech's extra weapon** (`ExitMechSuit` fires +0x414). That is most likely MECH_AOE: 200 damage in **800 px (53 studs), about the whole screen**, force 180 [inferred].
  - Exiting gives 0.2 s of invulnerability (`RemoveMechSuit`).
- **Damage to the mech drains time instead of health.**
  - Damage and Heal mechs lose **0.65 s per point of damage** × the armour-booster modifier (`DamageMech::HandleDamage @ d8370`).
  - An instant-kill weapon empties the timer (`Mech::HandleDamage`).
  - The **Defence mech** ("Melee Suit") has no such override, and its `ApplyForce` is empty, so it's **immune to knockback**.
- **Weapons:**

  | Mech | Gun | Spin (double jump, contact) | Mayhem / spin gun |
  |---|---|---|---|
  | Damage | DAMAGE_MECH_GUN 40 / 0.2 s | DAMAGE_MECH_SPIN 40 / 0.06 s | 40 / 0.05 s |
  | Heal | 20 / 0.2 s | 20 / 0.06 s | 20 / 0.05 s |
  | Defence | saws (§4) | DEFENCE_MECH_SPIN 60 / 0.06 s | — |

  - All mech shots are 800 px/s projectiles with AOE 90 and force 90.
  - **Spin guns** (flag 0x20) fire along the spin-attack angle. That angle is auto-aimed at the nearest target when the spin starts, and defaults to 135° or 225° (diagonally down and forward).
- **Heal mech:** on each kill it releases health worth **0.25 × seconds since the previous kill** (`HealMech::EnemyKilled`). That's 0.25 HP/s banked and paid out on kills.

## 7. Gadgets (`GadgetManager`) [code]
- **Air Strike** (`GadgetManager::Airstrike @ 10db30`):
  - **14 AIRSTRIKE rockets fired in the same frame**, all at **135°** (diagonally down and forward), at 700 px/s.
  - Each spawns 71–79 px further right and 26–34 px higher than the previous one. The first starts at camera-left − 612 px, 800 px up.
  - So they rain down as a sweeping diagonal curtain whose impacts arrive in sequence, with no timer: the stagger comes purely from geometry.
  - Each rocket deals **200** damage with a **180 px** (12 stud) radius, force 150 and shake 3.
  - Afterwards the air strike is locked for **2 s**.
- **Deploy price** (`GetDeployPrice`): drones and the air strike cost **2**, mechs cost **3**, in currency enum 1 (gems [inferred]).
- **Locked reasons** (`ResetLockedReasons`, `GetLockedReasons`):

  | Gadget | Bits checked | Meaning |
  |---|---|---|
  | Drones | 0x7 | player state, the same drone already queued or active, no free slot |
  | Mechs | 0x9d1 | player state, event 9, mech already active, events 2 and 3, Eagle start |
  | Air Strike | 0x1999 | player state, already queued or on its 2 s cooldown, events 9, 2, 3 and 10, Eagle start |

  Survival mode can add locks (`AddLockedReasons`, bit 0x200).
- **Forcefield** (`Player::ActivateForcefield`):
  - The player is invulnerable with input locked.
  - It adds a circle body of radius CHARACTER_FORCEFIELD_R (55 px) with category 8, the train's category. That means **enemy projectiles die on it as if it were the train**.
  - On deactivation it fires FORCEFIELD_AOE: 0 damage, **350 px radius, push 1250** (≈ 83 studs/s ÷ weight, radial, 1.3× vertical).
- **Revive** (`Player::Revive`):
  - Full health and **3 s of invulnerability**.
  - It fires REVIVE_AOE: 0 damage, **512 px radius, push 1550**.
  - Then `EnemyManager::FleeAll` makes every enemy flee.

## 8. Enemy projectiles [code]
**Telegraph = fireDelay + animFireDelay** (`Enemy::Attack`), with ±30 % interval jitter.

| Attack | Speed px/s (studs/s) | Arc | Wind-up s | Damage / radius | Notes |
|---|---|---|---|---|---|
| FIREWORK | 300 (20) | straight, aimed | 0 + 0.6 | 4 / 40 | enemy friendly fire |
| SKULL | 300 (20) | straight | 0 + 0.6 | 4 / 40 | |
| LIGHT_FIREBALL (lightning ball) | 270 (18) | straight | 0.2 + 0.6 | 4 / 40 | |
| MEDIUM_FIREBALL | 270 (18) | straight | 0.2 + 0.6 | 6 / 80 | |
| MEDIUM_STAKE | 450 (30) | straight | 0.2 + 0.5 | 6, direct | sticks in the train |
| BOSS_STAKE | 650 (43) | straight | 0 + 0.25, every 0.5 s | 6, direct | sticks |
| NINJA_BOMB | lob, grav ×1.5 | ≈31° arc | 0 + 0.5 | 8 / 80 | 1.75 s fuse; blows on touching the player or train |
| FUTURE_BOSS_MEGAGUN | 600 (40) | straight | 0 + 0.6, every 3.8 s | 8 / 80 | shake 3 |
| CHOPPER_WEAPON | 2500 (167) | straight | — | AOE 120 | |

- **Aimed, not homing.** The direction is fixed at launch toward the target's position (`FireBallistic`, aim branch), so **jumping or moving after the release dodges it**.
- **Blocking:** the forcefield, the Defender drone, and the train or carriage geometry stop enemy projectiles. Shields block player shots, not enemy ones.
- **They can't be shot down** (§2).
- **Explosive enemy shots damage other enemies.**

## Most useful for our game
- **Dynamite and other thrown enemy explosives** ([[Wild West Enemies]]): use a fuse-blink (period = remaining × 0.2 s, floor 0.02 s), about 0.5–0.8 s of wind-up, and an 80 px (≈5 stud) no-falloff radius with LOS through the train. Also let it **hurt other bandits**: that's the original's design and a cheap source of mayhem.
- **Explosion knockback:** radial with 1.3× vertical gives the "pop-up" feel. Bullets stay horizontal-only. For our gadget radii: 4 studs for rockets, 12 studs for an airstrike-class blast, and about 23 studs of non-damaging push for a shield burst.
- **Sticky charges:** stick to whatever they hit (5 px into the train, 8 into enemies), blow on a 1.3 s fuse (thrown) or 0.5 s (rifle), with a 4.3-stud radius.
- **Air-strike gadget:** a 14-shell diagonal curtain with geometric staggering. It needs no scheduler and reads clearly as a sweep. Then a short cooldown.
- **Drones for [[Gadgets and Mayhem]]:**
  - The turret's "least turn, 200°/s, fire within 1°" targeting is simple and looks smart.
  - The Defender as a **projectile-eating body** whose duration is the cost of blocking.
  - Healer and corpse drones as **charge budgets**, not timers.
- **Freeze as a hard stop scaled by a per-enemy resistance** (1 / 0.6 / 0.3). It's easy to read and keeps bosses in play. Burn should refresh, not stack, and panic-flee is free comedy.
- **Charge weapon for a [[Launch Agents]] kit:** an EaseInCubic damage curve over 1.1 s with 3 visual tiers, a piercing damage pool, and recoil that scales with charge.
- **Mech-style transforms:** damage drains the timer (0.65 s per hp) instead of health, a screen-wide exit blast, and a 2.5 s invulnerable entry with timed shakes.
- **Beam "lightning" as a piercing line** that stops at walls and shields; no chain logic is needed.

## Couldn't determine
- The exact lob speed in px/s: the 1 kg mass assumption hasn't been verified in the running game. The restitution-0.4 bounce only seems to matter off non-train geometry.
- Which weapon the mech exit fires (the string is hidden in the decompile; MECH_AOE is inferred). The Defence mech's damage handling. What DAMAGE_MECH vs SPIN_GUN timing looks like in play.
- The names of event types 2, 3, 9 and 10, and the deploy currency enum.
- The healer drone's pause condition (player vtable +0x44), and whether gib health projectiles split their amount.
- Whether the freeze drone's 0-damage AOE applies freeze to every enemy in range (likely, via TakeDamage → HandleDamage) [inferred].
- Some drone follow offsets for slots 3 and 4 decompiled asymmetrically.
- The airstrike's camera-left reference (+0x40) may be the camera centre instead.

Related: [[Original Game]] · [[Original Game - Combat Feel (Native Code)]] · [[Original Game - Enemies and Spawning]] · [[Hit Feedback]]
