---
tags: [system, m1, vfx]
status: implemented
side: client
---
# EffectsController

## Purpose
Draws the server's batched `Effects` records ([[CombatService]]): tracers, rockets,
explosions, hit sparks, spin rings and KO pops. Everything is client-only and cosmetic.

## Code
- Studio path: `StarterPlayer.StarterPlayerScripts.Client.Controllers.EffectsController`
  (`Modes = { "Run" }`)

## Expects in the place
- Templates in `ReplicatedStorage.Assets.Effects`. Colours follow [[Art Direction]] §1:
  player shots are `#FFF2B3`, hits are white, and explosions have a `#FFC24A` core with
  grey smoke.

  | Template | What it is |
  |---|---|
  | `Tracer` | A neon bar, stretched between the two points |
  | `Rocket` | A neon capsule |
  | `ExplosionCore`, `ExplosionSmoke` | Balls |
  | `HitSpark` | A white neon ball |
  | `SpinRing` | A neon disc (cylinder) facing the camera |
  | `KnockoutPop` | An invisible anchor with a BillboardGui `Label` reading "KO!" in Luckiest Guy |
  | `EnemyBullet` | A neon `#FF5A2A` capsule (enemy projectile colour) |
  | `Dynamite` | A red `#C8322A` cylinder |
  | `Alert` | A copy of `KnockoutPop` reading "!" in telegraph orange `#FF4A1C` |

- Runtime-generated content: `Workspace.Effects` (a client-only folder) holds template
  clones that are tweened and then destroyed. Code only animates their size, transparency
  and position, which is allowed for effects.

## Public API
- `EffectsController.spark(position: Vector3, size: number)`: a white flash. PickupController
  uses it.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `Effects` | server → client (unreliable) | an array of records, see [[CombatService]] | — (from the server) |

## Data / state
- **Tracer:** fades over 0.08 s.
- **Rocket:** moved locally by its velocity until its `X` record arrives, or for 3 s if
  that record is lost.
- **Explosion:**
  - the core grows to 2 × radius over 0.35 s,
  - the smoke grows to 2.6 × radius over 0.8 s,
  - it calls `CameraController.shake(EXPLOSION_SHAKE)`.
- **Hit:** a 1.6-stud spark.
- **Spin:** the ring grows to the spin radius over 0.25 s.
- **KO pop:** rises 3 studs and fades over 0.8 s.
- **Enemy projectiles** (`R` with a template): drawn like rockets, with gravity for
  dynamite. Removed by `P` or `X`, or after 3 s.
- **Alert:** a "!" 4 studs above the enemy that fades over 0.6 s.
- **Knockback** (`N`): if the userId is this player's, it sets the HumanoidRootPart's
  velocity. That's the one non-cosmetic record: the client owns its character's physics,
  so the server can't push it. It's on the unreliable remote, so a knockback can be lost.

## Depends on
- [[CameraController]] (`shake`), `Shared.Constants`

## Notes
- **Not yet done:**
  - flipbook particles (dust, stars, splinters) and the knockout hat-pop ([[Art Direction]]
    §9),
  - a particle cap,
  - a score number on the KO pop instead of "KO!" (M2, [[Score and Combo]]).
- Verified 2026-10-13: a playtest screen capture showed a rocket in flight and explosion
  smoke on the target, and the console was clean.

## Combat Polish (2026-10-16)
- **`M` record** (x, y, dirX, template) calls `FeelEffects.muzzleFlash`. The flash templates
  are `ReplicatedStorage.Assets.Effects.MuzzleFlashRifle`, `MuzzleFlashScattergun` and
  `MuzzleFlashRocket` (greybox Neon blocks), and each lives for `MUZZLE_FLASH_TIME`.
- **`R` record:** an optional 9th value `explodesAt` (server time) comes on landed dynamite
  and calls `FeelEffects.fuseBlink`. Every `R` makes a new clone, so a repeated record
  can't double-blink one.
- `Client.Controllers.FeelEffects` is a new module with no `init`/`start`. It blinks the
  `FuseSpark` (a Neon ball welded to the tip of the `Dynamite` effect template).
- **Verified 2026-10-16:** 53 flashes in a burst, none left behind; dynamite fuses blinked.
