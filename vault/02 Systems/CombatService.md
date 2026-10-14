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
| `RequestSpin` | client → server | none | 4/s, burst 2. Cooldown is ≥ 0.8 × `SPIN_COOLDOWN` (a strike otherwise). The player must be alive and airborne: no map geometry within hip height + 0.5 below the root |
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
- **Per player:** `{ fire, nextShot, lastSpin }`.
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
