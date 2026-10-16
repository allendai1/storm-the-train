---
tags: [system, m1, enemies, spawning]
status: implemented
side: server
---
# SpawnService

## Purpose
Plays the M1 **spawn timeline** ([[First Playable (M1)]] → Spawn timeline):
- budget waves of lights, scaled by party size,
- **solo mids** that pause the lights until they're knocked out,
- the **blueprint thief** at 60 s,
- then "REACH THE ENGINE!".

[[EnemyService]] does the actual spawning and the AI.

## Code
- Studio path: `ServerScriptService.Server.Services.SpawnService` (`Modes = { "Run" }`)
- Data: `ReplicatedStorage.Shared.Config.SpawnTimeline`, a data-only ModuleScript:
  `BlueprintThiefAt`, `BlueprintThief` and `Phases`.
  - A **wave phase** has `Duration`, `Pool`, `Interval`, `WaveCost {min, max}`, `Cap` and
    an optional `Extra`: one more enemy halfway through, which is how Bart recurs in the
    ramp.
  - A **solo phase** is `{ Solo = "BigBart" }`.

## Expects in the place
- Attachments tagged `EnemySpawn` in the carriage templates ([[TrainService]]): 2–3 per
  carriage.
- Remote `Announce`.

## Public API
- `SpawnService.begin(trainNumber, thief)`: plays **one train's** timeline, yielding until
  it ends or `stop()` is called. Each call gets a new run id; an older timeline stops at its
  next step.
  - Train 1 plays `Phases` (the M1 table).
  - Every later train plays `Plateau` (60 s, lights, Bart as `Extra` halfway through),
    with its `Cap` × min(`CapRampMax` 2, 1 + `CapRampPerTrain` 0.1 × (n − 1)) and its
    `Interval` × (1 − `IntervalRampPerTrain` 0.05 × (n − 1)), floored at `IntervalMin` 2 s.
  - A Thief train spawns `ThiefTrainThieves` (2) blueprint thieves, spread evenly through
    the timed phases, each with **BLUEPRINT THIEF!**. Non-thief trains have none (M2's
    leg layout; the M1 60 s thief is gone).
- `SpawnService.stop()`: ends the current timeline and sets `TimelineDone = false` (wipe,
  PLAY AGAIN).

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `Announce` | server → all clients | `text: string` ("REACH THE ENGINE!") | — |

## Data / state
- **A wave:**
  - its budget is `random(WaveCost) × COOP_SCALE[players]`,
  - the room left is `Cap × COOP_SCALE[players] − EnemyService.aliveCost()`,
  - it picks random pool members that fit both until neither fits, or no spawn point is
    free.
- **Spawn point:**
  - an `EnemySpawn` attachment on any carriage within one carriage of a living player
    (each player's nearest carriage ± 1),
  - at least `ENEMY_SPAWN_MIN_DISTANCE` (20) along X from every living player.
- **Solo:** it retries every second until the spawn succeeds, then waits for the knockout.
- **The blueprint thief** (a Bandana Bandit with `CarriesBlueprint`) is due once 60 s of
  run time have passed, and retried until it spawns.
- **When the timeline ends:** workspace attribute `TimelineDone = true` (false while
  running), and `Announce` fires.

## Depends on
- [[EnemyService]], [[TrainService]] (`getCarriages`), `Shared.Constants`
  (`COOP_SCALE`, `ENEMY_SPAWN_MIN_DISTANCE`)

## Notes
- [[RunStateService]] starts it at each train (M2 Session 9). Combat time pauses during
  leaps and checkpoints, because no timeline runs then.
- Phase timing runs on the clock: if every player is down, waves spawn nothing but the
  phases still advance.
- "Never on screen" isn't enforced. The camera is about 70 studs wide, so a spawn 20
  studs away can be visible. Tune this in the Session 6 playtest (a bigger minimum
  distance, or spawning only off screen).
- Verified 2026-10-13: a full run from bandits to `TimelineDone`, with no errors; the
  Six-Shooter, Rodeo Kid and Bart joined in their phases.

## Combat Polish (2026-10-16)
- **Placement:** `Server.Util.SpawnPlacement.choose`.
  - It picks the nearest point that's off-screen ahead of the squad's front. The edge is
    35 + 17 + 3 = 55 studs, which allows for the camera lead.
  - It picks one behind the squad on a 1-in-3 roll while the squad isn't advancing (4 studs
    in 3 s, sampled every 0.25 s by a tracker made in each `begin()`).
  - Candidates are the `EnemySpawn` points within **two** carriages of a player.
  - `ENEMY_SPAWN_MIN_DISTANCE` was removed.
- **Waves:** the names are picked first. Then one point is chosen, and
  `SpawnPlacement.spread` spaces the wave 3–10 studs apart, away from the squad. A spread
  position not over a `WalkSurface` ends the wave (`ponytail:` marked; snap to the nearest
  roof if waves feel thin).
- Player X positions include downed players (only `BledOut` ones are left out).
- **Verified 2026-10-16:** with the player at X −16, waves appeared at X 48 (64 studs away,
  off-screen) and walked in; a second enemy in a wave spawned at X 58.
