---
tags: [reference, original-game, combat, weapons, vfx, decompiled]
status: reference
updated: 2026-10-16
---
# Original Game — Combat Feel (native code)

> **Reference only, never canon.** This describes *Storm the Train* (2016), not our
> game. Our proposals based on it are in [[Hit Feedback]].

## Sources and method
- **`lib/x86/libMainApp.so`** (the game's compiled C++). It was decompiled on 2026-10-16
  with **Ghidra 11.4** (headless) into C-like pseudocode.
  - The binary is stripped but keeps **8,631 exported C++ symbols** (`Weapon::Fire`,
    `Enemy::HandleDamageAnim`…), so functions have their real names.
  - Constants were read straight from the file.
  - **Addresses below are Ghidra's**: the image is based at +0x10000, so `nm` shows
    `Weapon::Fire` at 0x162150 and Ghidra at 0x172150.
- **`classes.dex` and `resources.arsc`**, decompiled with **jadx 1.5.3**. Only 22 of the
  3,951 classes are the game's own (`com.gamesfaction.*`). They're platform glue: IAP, ads,
  Play Games, sharing and HTTP. There's **no gameplay on the Java side**.
- **`res/`** is stock Android and Play Services resources (icons, sign-in buttons). It
  holds nothing useful.
- **Confidence:** **[code]** means read from decompiled code or data. **[inferred]**
  means a reasonable reading that hasn't been checked in the running game.
- **Units:** the original works in pixels on a 1024 × 768 screen. **15 px ≈ 1 stud**,
  the conversion used across the vault.

## Firing
- **Hitscan shots have no angular spread [code].** `Weapon::FireRay` casts one ray along
  the given angle with no random offset.
- **Agent guns have no auto-aim [code].** They fire along the facing, which is always
  the move direction. `WeaponManager::FindTargetAngle`/`FindClosestTargetAngle` are only
  called by the spin attack's start angle, the turret, freeze and melee drones, and the
  Teleport boss. *(Corrected 2026-10-16. An earlier version of this note said the shot
  angle came from auto-aim.)*
- **Fire-rate jitter [code].** After each shot, `Weapon::Fire` resets the fire timer to
  a random value in ±30% of the interval, but only for weapons slower than 0.2 s. So:
  - the pistol (0.35 s), shotgun (0.45 s), rockets (0.5 s) and sticky bombs fire with an
    uneven, organic rhythm,
  - the rifle (0.175 s), uzi, dual weapons and minigun fire perfectly steadily.
- **The shotgun isn't a pellet spread [code].** `SHOTGUN_n` is one long-range ray (12 →
  14 damage). Its record also points at a second weapon fired with it, `SHOTGUN_CLOSE_n`:
  - 16 → 21 damage, range 180 px (12 studs), and a **push force of 800**,
  - flag bit 2 set, the beam path, so it probably hits **everything** in that short
    range [inferred].

  It's "a shot plus a point-blank blast".
- **Projectiles** (`Ballistic::Init`):
  - no angular spread,
  - an optional **speed variance**: the horizontal speed is scaled by a random 1 ± v,
  - each projectile can start a particle trail effect.
- **Lobbed projectiles** (sticky bombs, thrown weapons; `Weapon::FireBallistic`)
  **[code]**:
  - horizontal speed = facing × 1.6 × max(100, distance to target × 0.45),
  - vertical speed = |horizontal| × 0.9, about a 42° launch,
  - plus 20% of the thrower's own velocity.

  So throws land near the target, and moving throwers throw further.
- **Recoil [code].** `Weapon::PreFire` pushes the shooter by the weapon's recoil force.
  Only the **railgun** uses it (−250, a kick backwards).
- **Camera shake on firing [code].** Each weapon can name a shake type, used on fire for
  hitscan weapons and on impact for projectiles. Rockets, plasma and sticky bombs use
  **type 2**. See "Camera shake" below.
- **Muzzle flashes [code].** Each weapon names a muzzle effect, spawned at the muzzle
  along the shot angle:

  | Effect | Used by |
  |---|---|
  | `Muzzle_flash_1` | Rifle, Pistol, Minigun |
  | `MuzzleFlash_2` | Uzi |
  | `MuzzleShotgun` | Shotgun |
  | `MuzzleDualUzi` | Dual Rifles, Dual Pistols, Dual Uzi |
  | `LightningGun`, `RayGun`, `FlameThrower` | Beam weapons; each also has a `…Block` (hit a shield) and a `…Gib` effect |

  The sprites include `fx_muzzle_flash_1/2`, `fx_tracer_fire_1`, `fx_shrapnel_1`,
  `fx_radial_dust_1/2`, `fx_smoke_*` and `fx_flash_bang_1`.

## Hits on enemies
- **Every hit knocks the target back horizontally, away from the shooter [code].**
  `Weapon::DealDamage` calls `ApplyForce(±force, 0)`, and `Enemy::ApplyForce` divides it
  by **`ENEMY_WEIGHT`**. Per-weapon force (studs/s at weight 1):

  | Weapon | Force | ≈ studs/s |
  |---|---|---|
  | Pistol | 0 | 0 |
  | Rifle, Dual Rifles | 24 | 1.6 |
  | Uzi | 40 | 2.7 |
  | Minigun | 120 | 8 |
  | Shotgun (ray) | 150 | 10 |
  | Rocket Launcher, Plasma Cannon, Dual Pistols | 250 | 17 |
  | Sticky Bomb | 500 | 33 |
  | **Shotgun close blast** | **800** | **53** |

  Weights run from 1 (lights) through 2 (mids) to 2.8 (bosses). So a bullet stream
  nudges, and the point-blank shotgun launches a light.
- **Hit-react (flinch) rules** (`Enemy::HandleDamageAnim`) **[code]**:
  - **Gun hits play `DAMAGE_GUN`**, but only if the enemy isn't mid-attack and isn't on
    its flinch cooldown.
  - **After a flinch, it can't flinch again** for a random 0.8–1.2 × **`ENEMY_DAMAGE_TIMER`**.
    That Lua field is the **flinch cooldown**, not an attack timer as previously guessed.
    Light ninjas use 0.75 s; the exploding minion uses 0.05 s.
  - **Beam hits play `DAMAGE_BEAM`** for min(beam interval × 1.2, 0.3 s).
  - **Fire hits switch the enemy into its burning behaviour** (lights flee).
  - Dead, frozen or already-reacting enemies don't flinch.
- **The hit effect** comes from the enemy's `EE_DEFAULT_HIT`: `BloodSplat`,
  `GreenBloodSplat`, `SkeletonHit`, `EFFECT_ROBOT_HIT_V1` (sparks) or `Shield_hit_1`.
- **Score is paid per point of damage, not per kill [code]**
  (`Enemy::ReduceHealthByDamage`):
  - each hit adds damage ÷ max HP × the enemy's score value,
  - damage is clamped to the remaining HP, so overkill gives nothing.
- **Mayhem is paid per point of damage too [code]:**
  - **+0.035 per damage dealt** (× the weapon's Mayhem multiplier, 1 for all weapons),
  - **plus 0.035 × the enemy's max HP on the kill** (`Enemy::HandleDeath`), so a kill
    yields about 0.07 × max HP in total: a 25-HP light gives about 1.75, a 160-HP mid
    about 11,
  - × the Mayhem booster, × the agent's Mayhem modifier,
  - **× 0.2 while a mech or gadget is active** (`GameMain::AddMayhem`), so you can't
    chain gadgets,
  - capped at 100, with a sound when it fills.
- **Gibs** (`GibManager::AddGibs`) **[code]**:
  - **at most 50 gibs** exist at once, and the oldest are removed,
  - they spawn 30–50 px above the body,
  - sideways velocity comes from a range on the killing weapon, away from the shooter,
  - upward velocity is 5–13 × the gib's `force`, with a slight random spin.

## Hits on the player
- **0.3 s of invulnerability after each hit [code]** (`Character::HandleDamage`: the timer
  becomes max(timer, 0.3)). Hits during it are ignored, unless the weapon is an
  instant-kill.
- **Damage taken** = the hit × the health booster × the agent's resilience, then
  **halved** while a second timer is running [inferred: probably the forcefield or a
  revive grace].
- **Effects and reactions:**
  - each hit spawns `PlayerDamage` on the body and `BloodSplat` at the impact point,
  - crossing a health-state threshold rebuilds the costume visuals (the torn-armour gag)
    and plays a "hurt" speech line,
  - while dying, hits play twitch animations.

## Combo
`ComboCounter` **[code; `ClearCounters` assumed to reset the timer]**:
- kills go into **10 buckets of 0.1 s** (a rolling 1 s window),
- the **first combo level needs 2 kills within 1 s**,
- **each later level needs 1 more kill within 1 s of the last level-up**,
- **after 1 s without one, it drops back to level 1**,
- the maximum level is 25.

The original's combo window is therefore about **1 s**. Ours is 2.5 s, decided
deliberately ([[Score and Combo]]).

## Camera shake
`CameraController::Shake(type)` **[code]**: a random amplitude and duration per type.

| Type | Amplitude px (≈ studs) | Duration s | Used by |
|---|---|---|---|
| 1 | 25–35 (1.7–2.3) | 0.4–0.8 | Big hits (mech, boss, CDW events) |
| 2 | 10–12 (0.7–0.8) | 0.3–0.6 | Rockets, plasma and sticky bombs (impact) |
| 3 | 18–22 (1.2–1.5) | 0.8–1.3 | Events (boss, mech) |
| 4 | 20–30 (1.3–2) | 1.0–1.1 | Events |
| 5 | 20–30 (1.3–2) | 1.0–1.5 | Events |

Which event uses types 1, 3, 4 and 5 isn't decoded. They're called from `BossEvent`,
`CDWEvent`, `CDW::TakeVelocityDamage` and the three mechs' `Update`.

## Drones
- **The turret drone recoils:** each shot kicks the drone 40 px back along the firing
  angle (`TurretDrone::Fire`).

## Java side and the resource table (platform glue)
- **Backend:**
  - `backend.gamesfaction.com`, `http://%s:8301/v1/connect?version=…&bundle=…&country=…&platform=…`,
  - the remotely tuned keys are `offers.interstitialDelay`, `offers.timeDelay`,
    `offers.offerGems` and `offers.recruitGems`,
  - so ad pacing and promotional gem rewards were tuned from the server, not shipped in
    the app.
- **IAP config keys:** `iap.gems.item`, `iap.coins.item`, `iap.coinDoubler.{id,title,desc,enabled}`
  and `iap.allCharacters.enabled`. The SKUs and prices came from the server or the store,
  not the app. `REVIVE_ADS` is the ad-revive flag.
- **Ads:** rewarded videos through Unity Ads, Vungle and Heyzap mediation, plus
  interstitials.
- **Play Games:** one leaderboard (`leaderboard_high_score`) and **9 achievements, each in
  3 tiers (I–III)**: Good Student, Skippy, Mutiny, Massacre, Completist, Globe Trotter,
  Metamorph, Seasoned and Techie. Only the names and IDs are stored; the thresholds are
  in `AchievementManager` (not decoded).

## Weapon record fields (extends [[Original Game - APK Balance Audit]])
New 124-byte record offsets **[code]**:

| Offset | Meaning |
|---|---|
| +0x20 | flags (bit 2 = beam, bit 8 = rail, bit 4 = instant kill, bit 0x10 = fire) |
| +0x24, +0x28 | muzzle offset |
| +0x2c | gives Mayhem (byte) |
| +0x30 | **push force** |
| +0x34 | **recoil** |
| +0x38 | Mayhem multiplier |
| +0x3c | **camera-shake type** |
| +0x40 | **muzzle effect ID** |
| +0x50 | fire sound (−1 = none) |
| +0x5c | projectile definition (0 = hitscan) |
| +0x6c | secondary weapon definition (the shotgun → `SHOTGUN_CLOSE_n`) |

Related: [[Original Game]] · [[Original Game - Enemies and Spawning]] · [[Hit Feedback]] · [[Score and Combo]] · [[Gadgets and Mayhem]]
