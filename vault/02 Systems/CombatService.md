---
tags: [system, m1, combat, security]
status: implemented
side: server
---
# CombatService

## Purpose
Server-authoritative combat ([[0006-humanoid-enemies-and-combat]], [[0007-networking-and-remotes]]).
- Clients only send input state; this service fires each weapon at its own interval.
- Shots hit-test against `Hitbox` parts: hitscan rays, and rockets simulated as data.
- It runs the spin attack.
- Damage goes into `Health` **attributes**, never `Humanoid.Health`.
- Visuals go out batched on `Effects`.

It doesn't handle knockouts (EnemyService, Session 4) or downed players (SquadService,
Session 5). Both react to `Health` reaching 0.

## Code
- Studio path: `ServerScriptService.Server.Services.CombatService` (`Modes = { "Run" }`)

## Expects in the place
- **Weapon templates** in `ReplicatedStorage.Assets.Weapons`. Each is a Model whose
  `PrimaryPart` is `Handle` (the grip, which is also the pivot). Its parts are pre-welded
  to the Handle, and the barrel points along −Z, with a `Muzzle` Attachment at the tip.

  | Weapon | Damage | FireInterval | Range | Other attributes |
  |---|---|---|---|---|
  | `ServiceRifle` | 12 | 0.175 | 45 | `AutoAimAngle` 6 |
  | `PocketRocket` | 13 | 0.5 | 60 *(first guess)* | `ProjectileSpeed` 70, `SplashRadius` 4, `SplashDamage` 13 |

- **Enemies** ([[EnemyService]]): Models tagged `Enemy` with a number attribute `Health` and a
  `Hitbox` part in collision group `Hitboxes`.
- **Collision group `Projectiles`** (query only): collides with `Default` and `Hitboxes`
  only. Shot rays use it with an Include filter of `workspace.Map` plus the live enemy
  hitboxes, so shots stop at train walls and enemies, and pass through players, bodies
  and ragdolls.
- Runtime-generated content: `Character.Weapon`, a clone of the weapon template welded
  to the HumanoidRootPart at `Constants.WEAPON_HOLD_OFFSET`.

## Public API
- `CombatService.damageEnemy(enemy: Model, amount: number, by: Player?)`: lowers `Health`
  (to a minimum of 0). It sends a hit spark, or a KO pop when Health reaches 0. A knockout
  adds 1 to `by`'s Player attribute `Knockouts` (run results). Rifle, rocket (direct and
  splash) and spin damage pass the shooter.
- `CombatService.damagePlayer(player: Player, raw: number)`: applies `raw × Toughness` to
  the Player attribute `Health`.
- `CombatService.setWeapon(player, name)`: equips the named template and sets the Player
  attribute `ActiveWeapon`.
- `CombatService.toggleWeapon(player)`: flips between the character's `PrimaryWeapon` and
  `SecondaryWeapon` attributes.
- `CombatService.onKnockout(fn(info))`: info is `{ enemy, by, source ("Weapon" | "Spin" |
  "Gadget" | "Hazard"), damagers, at }`. Used by [[ScoreService]] and [[PickupService]]
  (coins). Damagers are tracked per enemy and cleared on knockout or `Destroying`.
- `CombatService.onPlayerDamaged(fn(player, raw))`: called for every hit on a living
  player.
- A knockout with a player behind it no longer sends the plain `K` record:
  [[ScoreService]] sends `K` with the points instead.
- `CombatService.effect(kind, ...)`: queues an effect record for the next batch. [[EnemyService]]
  uses it for its projectiles, alerts and knockback.
- `CombatService.newProjectileId() -> number`: the shared id counter. Player rockets and enemy
  projectiles share one id space on the client.
- `CombatService.distanceTo(hitbox, point) -> number`: the distance on the plane from a point
  to the closest point of an axis-aligned hitbox.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `SetInput` | client → server (unreliable) | `fire: boolean` | `Guard.boolean`. 30/s, burst 10. A bad payload is a strike |
| `RequestSpin` | client → server | none | 4/s, burst 2. **Once per airtime** (`spunInAir`, cleared when the player next stands on the map; a repeat is ignored, no strike). No cooldown. The player must be alive and airborne: no map geometry within hip height + 0.5 below the root |
| `Effects` | server → all clients (unreliable) | an array of up to `EFFECTS_BATCH_SIZE` (10) records per send, flushed every Heartbeat | — |

**Effect records** (`{ kind, ... }`):
- `T` tracer: x1, y1, x2, y2
- `R` rocket: id, x, y, vx, vy
- `X` explosion: id, x, y, radius
- `H` hit: x, y
- `S` spin: x, y, radius
- `K` knockout: x, y
- Added by [[EnemyService]]:
  - `R` with two extra fields, `template` and `gravity`, for an enemy projectile. Re-sending
    `R` with the same id corrects it (landed dynamite).
  - `P` projectile gone: id
  - `A` alert "!": x, y
  - `N` knockback: userId, vx, vy

## Data / state
- **Per player:** `{ fire, heldSince, nextShot, spinning, spunInAir, spinStarted, spinEndedAt, spinHits }`.
- **Firing:** the cadence stays steady while the trigger is held (`nextShot +=
  FireInterval`), and the first shot after a pause fires immediately. A player with
  Health ≤ 0 can't fire.
- **Direction:** there's no player aim. Shots go straight along the facing (±X, from the
  root's LookVector), starting at the Muzzle projected onto Z = 0. Mouse aim was removed
  2026-10-13; verified with the mouse held high, where the steepest tracer was 2° (auto-aim).
  - The **rifle's auto-aim** bends the shot toward the live enemy with the smallest angle
    inside `AutoAimAngle` and in range.
- **Rockets** are data (`position`, `velocity`, `travelled`), stepped every Heartbeat with
  one raycast per step. They explode on a hit, or at `Range`.
  - A direct hit takes `Damage`. Everything within `SplashRadius` of the blast takes
    `SplashDamage`, measured to the closest point of each hitbox, so the direct target
    takes both (26).
- **Spin:** `SPIN_DAMAGE` (6) to every enemy hitbox within `SPIN_RADIUS` (5) of the root.
  The lift is applied on the client ([[InputController]]).

## Depends on
- [[Guard]], `Shared.Constants`, `Shared.Types` (`WeaponStats`)

## Notes
- Verified 2026-10-13 in a playtest against a temporary dummy enemy:
  - a 1.6 s rocket hold did 104 damage (4 rockets × 26),
  - a 2 s rifle hold made 14 hits (168),
  - nothing fired after release,
  - the spin did 6,
  - gap-fall `damagePlayer(15)` cost 7.8 HP at toughness 0.52.
- Should the direct target take the splash on top of the direct damage? The spec says
  "13 direct + 13 splash", and this reads it as yes. Tune in Session 6.
- No lag compensation (ADR 0006). The airborne check for the spin could reject a spin made
  right after take-off under lag. Watch for this in multi-client tests.
- Downed players have Health 0, which already blocks firing and spinning ([[SquadService]]).
- **M2 Session 10 (2026-10-14):**
  - **Weapon template attributes** add `Pellets`, `Spread`, `CloseDamage`, `CloseRange` and
    `SpinUp` (`Types.WeaponStats`).
  - **Scattergun:** 5 straight pellets spread evenly over 10°, with no auto-aim. 12 damage
    each, or 16 within 6 studs; range 14; every 0.45 s. Verified: 5 tracers per shot,
    about 0.45 s apart.
  - **Crowd Pleaser:** it only fires after the trigger has been held for `SpinUp` (0.6 s).
    `heldSince` is set when `SetInput` goes from false to true. Then 6 damage every 0.07 s,
    range 40, auto-aim 4°. Verified: first shot 0.68 s after the press, 0.070 s apart.
  - **Spin** uses the character's `SpinDamage` and `SpinRadius` (Dash 6/5, Brick 9/6), with
    `Constants` as the fallback.
  - `setWeapon` also records `Weapon_<AgentId>`, so each agent remembers its weapon across
    swaps.
  - Firing is skipped while the Player attribute `InMech` is set (Session 11).

## Combat Polish (2026-10-16)
Built from [[Combat Polish Code]] §7 and adapted to the live script. It uses
`Server.Util.CombatFeel`, `EnemyFlinch` and `EnemyPerception`.
- **Perception:** `damageEnemy(enemy, n, player)` calls `EnemyPerception.noteHit`, so a hit
  enemy turns towards whoever hurt it.
- **Flinch:** gun hits (the rifle hitscan, and each Scattergun pellet) call
  `EnemyFlinch.onGunHit` after the damage. Splash and spin damage don't.
- **Muzzle flash:** a new effect record `M` (x, y, dirX, template), one per shot (not per
  pellet). The template comes from the weapon's `MuzzleFlash` attribute.
- **Rocket splash push:** enemies that survive the splash get
  `knockback(CombatFeel.explosionVelocity(...))`. The push is the weapon's `ExplosionPush`
  (Pocket Rocket 17), or `EXPLOSION_PUSH`. `Types.WeaponStats` gained `ExplosionPush`.
- **i-frames:** `damagePlayer` returns early while `CombatFeel.isInvulnerable(player)`. After
  damage it grants `PLAYER_IFRAMES` (0.3 s). The state is the player attribute
  `InvulnerableUntil` (server time), which revive grace uses too.
- **The spin lasts until landing:**
  - a `RequestSpin` while already spinning is ignored (no strike),
  - every Heartbeat, `stepSpins` hits each enemy within `SpinRadius` once (`spinHits`),
  - the spin ends on landing, on death, or after `SPIN_MAX_TIME` (2.5 s, a hover cap),
  - **once per airtime, no cooldown** (2026-10-16, [[Original Mechanics Match]] §3.3):
    `spunInAir` blocks a second spin until the player stands on the map again,
  - **half damage** for `SPIN_GUARD_WINDOW` (0.2 s) after a spin starts and after it ends
    (`damagePlayer`, after the damage filter; no i-frames from spinning),
  - knockback is `CombatFeel.spinVelocity` by the character's `SpinLevel` (Max 4,
    Brick 6), unless `SpinKnockback` (the mech's body slam) is set. **Every
    `CombatService.knockback` push is divided by the enemy template's `Weight`**
    (2026-10-16; lights 1, Bart 2; `Weight` is an attribute on every Wild West template),
  - the gun pauses while spinning, and `nextShot = max(nextShot, now)` on landing,
  - the player attribute `Spinning` is set for the client (F3's pose).
- `StunnedUntil` is in `os.clock()` time. `EnemyFlinch` compares it with `os.clock()` (the
  draft compared it with server time, which would never match).
- **Verified 2026-10-16:**
  - two hits in one frame land once, and the next lands after 0.3 s,
  - rifle hits flinch Bandits once each,
  - muzzle flashes appear and are cleaned up,
  - a grounded spin is refused, an airborne one ends on landing, and a mid-spin request
    is ignored.

  **Not checked:** the spin hitting and popping enemies, the rocket splash push, the
  Scattergun flash.
