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

- **Enemies** (Session 4): Models tagged `Enemy` with a number attribute `Health` and a
  `Hitbox` part in collision group `Hitboxes`.
- **Collision group `Projectiles`** (query only): collides with `Default` and `Hitboxes`
  only. Shot rays use it with an Include filter of `workspace.Map` plus the live enemy
  hitboxes, so shots stop at train walls and enemies, and pass through players, bodies
  and ragdolls.
- Runtime-generated content: `Character.Weapon`, a clone of the weapon template welded
  to the HumanoidRootPart at `Constants.WEAPON_HOLD_OFFSET`.

## Public API
- `CombatService.damageEnemy(enemy: Model, amount: number)`: lowers `Health` (to a minimum
  of 0). It sends a hit spark, or a KO pop when Health reaches 0.
- `CombatService.damagePlayer(player: Player, raw: number)`: applies `raw × Toughness` to
  the Player attribute `Health`.
- `CombatService.setWeapon(player, name)`: equips the named template and sets the Player
  attribute `ActiveWeapon`.
- `CombatService.toggleWeapon(player)`: flips between the character's `PrimaryWeapon` and
  `SecondaryWeapon` attributes.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `SetInput` | client → server (unreliable) | `fire: boolean`, `aim: number` | `Guard.boolean`, `Guard.number(-1, 1)`. 30/s, burst 10. A bad payload is a strike |
| `RequestSpin` | client → server | none | 4/s, burst 2. Cooldown is ≥ 0.8 × `SPIN_COOLDOWN` (a strike otherwise). The player must be alive and airborne: no map geometry within hip height + 0.5 below the root |
| `Effects` | server → all clients (unreliable) | an array of up to `EFFECTS_BATCH_SIZE` (10) records per send, flushed every Heartbeat | — |

**Effect records** (`{ kind, ... }`):
- `T` tracer: x1, y1, x2, y2
- `R` rocket: id, x, y, vx, vy
- `X` explosion: id, x, y, radius
- `H` hit: x, y
- `S` spin: x, y, radius
- `K` knockout: x, y

## Data / state
- **Per player:** `{ fire, aim, nextShot, lastSpin }`.
- **Firing:** the cadence stays steady while the trigger is held (`nextShot +=
  FireInterval`), and the first shot after a pause fires immediately. A player with
  Health ≤ 0 can't fire.
- **Aim:** the facing (from the root's LookVector) is tilted by `aim × AIM_MAX_ANGLE` (30°).
  Shots start at the Muzzle, projected onto Z = 0.
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
- A `Downed` check comes with SquadService (Session 5). Until then, Health ≤ 0 already
  blocks firing and spinning.
