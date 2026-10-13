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
- `SpawnService.begin()`: plays the timeline, yielding until it ends or `stop()` is
  called. Each call gets a new run id; an older timeline stops at its next step.
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
- [[RunStateService]] starts it at ALL ABOARD (Session 5). It no longer starts itself.
- Phase timing runs on the clock: if every player is down, waves spawn nothing but the
  phases still advance.
- "Never on screen" isn't enforced. The camera is about 70 studs wide, so a spawn 20
  studs away can be visible. Tune this in the Session 6 playtest (a bigger minimum
  distance, or spawning only off screen).
- Verified 2026-10-13: a full run from bandits to `TimelineDone`, with no errors; the
  Six-Shooter, Rodeo Kid and Bart joined in their phases.
