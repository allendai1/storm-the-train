---
tags: [system, m1, enemies, ai]
status: implemented
side: server
---
# EnemyService

## Purpose
Spawns, runs and knocks out the Cowboys ([[Wild West Enemies]],
[[0006-humanoid-enemies-and-combat]]). It owns:
- the enemy AI: one decision loop for every enemy, with no per-enemy scripts,
- enemy bullets and dynamite (data-only projectiles),
- knockouts: ragdolls, drops and Dan's blast.

[[SpawnService]] decides *what* spawns and *where*. [[CombatService]] deals the player's
damage to enemies.

## Code
- Studio path: `ServerScriptService.Server.Services.EnemyService` (`Modes = { "Run" }`)

## Expects in the place
- **Templates** in `ServerStorage.Assets.Enemies.WildWest`: `BandanaBandit`, `RodeoKid`,
  `SixShooter`, `DynamiteDan` and `BigBart`.
  - Each is the Dash R15 rig, reskinned: hat, red bandana `#D7322F` and a slot shirt colour.
    Props: a revolver, a stick of dynamite, and Bart's jug. Bart is scaled to 1.15.
  - Tagged `Enemy`.
  - The body parts are in collision group `Enemies`, and the `Hitbox` is in `Hitboxes`.
  - **The rig's `BallSocketConstraint`s are disabled.** The joints are
    `AnimationConstraint`s (the new avatar joints).
  - Humanoid: `BreakJointsOnDeath` and `RequiresNeck` are off; the name and health bar are
    hidden.
  - An `Animations` folder holds `Walk` and `Idle` Animation instances: the default R15
    ids, which you can swap by hand.
- **Attributes** on each template are the tunables; edit them in the Properties panel.
  - Everyone has `Slot`, `Archetype`, `MaxHealth`, `Speed`, `SpawnCost`, `Damage`,
    `AttackInterval`, `HitboxWidth`, `HitboxHeight` and `FreezeScalar`. Spawning resizes
    the `Hitbox` from the two hitbox attributes.
  - **Leaper** (Rodeo Kid): `LeapInterval` 2.8, `LeapTrigger` 8, `LeapTime` 1.1.
  - **Shooter** (Six-Shooter): `ShotDamage` 5, `ShotSpeed` 40, `ShotRange` 35, `TellTime`
    0.5, `ShotIntervalMin` 2.5, `ShotIntervalMax` 4.
  - **Lobber** (Dynamite Dan): `Damage` 10 is the dynamite, `ExplosionRadius` 4, `Fuse`
    1.5, `ThrowIntervalMin` 2.5, `ThrowIntervalMax` 4, `KeepDistance` 15, `ThrowRange` 25.
  - **Charger** (Big Bart): `ChargeSpeed` 36, `StaggerDamage` 30, `WindUp` 1,
    `ChargeDistance` 30, `ChargeInterval` 5, `ChargeTrigger` 20, `StaggerTime` 1.5,
    `Knockback` 45.
  - For the other archetypes, `Damage` is the melee hit.
- `ServerStorage.Assets.Enemies.Props.Saddlebag`: the blueprint thief's bag. Its pivot is
  the LowerTorso, and it's welded on at spawn.
- Effect templates `EnemyBullet`, `Dynamite` and `Alert` in `ReplicatedStorage.Assets.Effects`
  ([[EffectsController]]).
- Runtime-generated content: `Workspace.Enemies`, a runtime container for spawned clones.

## Public API
- `EnemyService.spawn(name, position, carriesBlueprint?) -> Model?`: stands the template on
  `position` (an `EnemySpawn` point), facing the nearest player. It sets `Health =
  MaxHealth` and server network ownership, and adds the plane lock
  (`CharacterService.lockToPlane`).
- `EnemyService.aliveCost() -> number`: the total `SpawnCost` of live enemies.
- `EnemyService.cost(name) -> number`: a template's `SpawnCost`.
- `EnemyService.clear()`: removes every enemy, ragdoll and enemy projectile (PLAY AGAIN).

## Remotes
None of its own. It sends `Effects` records through `CombatService.effect`: `R` with a
template and gravity, `P`, `A`, `N` and `X` (see [[CombatService]]).

## Data / state
- **AI tick at `ENEMY_AI_HZ` (12):** each enemy targets the nearest living player and
  returns a walk direction (−1, 0 or 1) for `Humanoid:Move`.
  - **Walker:** walks up and melees within `ENEMY_MELEE_REACH` (1.5 studs between hitbox
    edges, height difference ≤ `ENEMY_ATTACK_DY`), every `AttackInterval`.
  - **Leaper:** a Walker. Within `LeapTrigger` it jumps and keeps going for `LeapTime`, so
    it lands behind the player.
  - **Shooter:** a Walker. In range but not in reach, it stops, shows "!" and faces the
    player for `TellTime`, then fires one bullet at `ENEMY_SHOT_HEIGHT` (1) above its root:
    chest height, so it can be jumped.
  - **Lobber:** holds `KeepDistance` ± 3 (it backs away if you come close). It throws
    dynamite in an arc that reaches you in `DYNAMITE_THROW_TIME` (0.9 s) at
    `DYNAMITE_GRAVITY` (60). The dynamite sits where it lands and explodes at `Fuse`.
  - **Charger:**
    - When it's ready, within `ChargeTrigger` and not in reach, it **winds up**: "!" and
      standing still for `WindUp`.
    - If it takes ≥ `StaggerDamage` during the wind-up, it **staggers** for `StaggerTime`
      and the charge is cancelled.
    - Otherwise it **charges** at `ChargeSpeed` for `ChargeDistance`. The hit test is
      swept over the X it covered since the last tick, so it can't skip a player. Each
      player is hit once, for `Damage` plus a knockback `N` record.
    - **A charge stops at a gap or wall** instead of jumping; at 36 studs/s a jump flung
      Bart off the train.
- **Movement:** a downward probe `ENEMY_PROBE_AHEAD` (1.5) ahead (no floor → jump) and a
  knee-height probe `ENEMY_WALL_PROBE` (3) ahead (wall → jump). The early wall jump clears
  roof edges.
- **Projectiles** step every Heartbeat.
  - Bullets raycast against `Map` plus the living players' hitboxes, in collision group
    `Projectiles`.
  - Dynamite raycasts against `Map`. On landing it re-sends `R` with zero velocity.
- **Knockout** (`Health` ≤ 0):
  1. the blueprint drops (`PickupService.dropBlueprint`) if `CarriesBlueprint` is set,
  2. mids (slots 4–6) drop a crate (`PickupService.dropCrate`),
  3. the body ragdolls,
  4. Lobbers explode, hurting players **and** enemies (chain knockouts).
- **Ragdoll:**
  - the hitbox is removed and the animations stop,
  - every `AnimationConstraint` except `Root` is disabled, and the ball sockets are
    enabled. `Root` stays, so the plane lock keeps the torso on Z = 0,
  - the parts go to `Ragdolls`, and the Humanoid goes to `Physics` (state machine off),
  - an impulse `RAGDOLL_IMPULSE` pushes the body away from the nearest player,
  - after 0.1 s, network ownership goes to that player. It has to wait for the physics
    step that splits the body into assemblies; owning the single pre-split assembly
    didn't carry over.
  - At most `RAGDOLL_MAX` (12) are kept. Each fades in 4 steps after `RAGDOLL_FADE` (3 s),
    and the oldest goes first when over the cap.
- **Off the train:** feet below `ENEMY_FALL_FEET_Y` (3; decks are at Y 4) → removed, with
  no ragdoll. Measuring the feet rather than the root works for any rig size: Bart's
  root stayed above `GAP_FALL_Y` while he stood in a gap.

## Depends on
- [[CombatService]] (`effect`, `newProjectileId`, `distanceTo`, `damagePlayer`,
  `damageEnemy`), [[CharacterService]] (`lockToPlane`), [[PickupService]] (drops),
  `Shared.Constants`

## Notes
- Verified 2026-10-13 in playtests (one player standing on the staging platform):
  - bandits spawned, walked, jumped gaps and meleed (raw 3 × toughness 0.52 = 1.56),
  - Six-Shooter bullets (raw 5) and dynamite (raw 10) hit, and the client drew
    `EnemyBullet`, `Alert`, `Dynamite` and explosions,
  - Bart wound up, charged, stopped at the platform edge and went back to melee.
    Knockback moved Dash. 31 damage during a wind-up stopped the charge (stagger),
  - a knockout ragdolled (hitbox gone, group `Ragdolls`, player-owned) and was gone by
    3.8 s,
  - Bart's knockout dropped a crate spot, and the thief's dropped a blueprint that was
    collected,
  - the console was clean.
- **Not verified:**
  - the Rodeo Kid leap, by eye,
  - Dan's blast hurting other enemies (none were in range),
  - bullets being jumpable (needs a person to play),
  - the perf budget (Session 6).
- `Humanoid:GetState()` reads `FallingDown` on a ragdoll even though that state is
  disabled. The body still went limp; check this by eye in Session 6.
- Telegraphs are only the "!" pop. Wind-up poses and animations are art work for later.
- The Lobber's thrown dynamite doesn't hurt enemies, only its knockout blast does
  (an interpretation of the spec).
- Ragdolls fade on the server: 4 transparency steps replicated. Move that to the clients if
  the Session 6 budget check flags it.
- **Fixed 2026-10-14:** Big Bart's Humanoid had `AutomaticScalingEnabled` on with
  BodyHeightScale 1.15 (left by `ScaleTo`). That re-scaled the already-scaled rig at spawn,
  so his hitbox was about 2.8 × 7.5 in play. It's now off, and a spawned clone keeps
  2.4 × 6.5.
