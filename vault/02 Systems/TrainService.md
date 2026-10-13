---
tags: [system, m1, train]
status: implemented
side: server
---
# TrainService

## Purpose
Builds the hostile train in Run mode: it clones carriage templates end to end along +X,
starting at `Map.Run.TrainStart` ([[0009-static-trains-scrolling-world]]). Carriages are
anchored and never move. The sense of motion comes from [[ParallaxController]] on each
client.

## Code
- Studio path: `ServerScriptService.Server.Services.TrainService` (`Modes = { "Run" }`)

## Expects in the place
- Templates: `ServerStorage.Assets.Carriages.WildWest.{Caboose, Boxcar, Flatbed, CattleCar,
  WaterTanker, Engine}`. Each one is a greybox Model with:
  - its `PrimaryPart` = `RearCoupling` at local X 0 (the rear end, Y 3),
  - Attributes `Length`, `CarriageType` and `Theme`, and the tag `Carriage`,
  - a `Roof` tagged `WalkSurface`, with `EnemySpawn` Attachments on it (2–3 per car) and
    a `WeaponCrateSpot` Attachment on the Boxcar and CattleCar,
  - on the Engine, the cab `Roof` is also tagged `TrainGoal`, and `BoilerWalk` is a second
    `WalkSurface`.
- Heights (greybox): rail top Y 1, deck top Y 4. Roof tops: caboose 10.6 (cupola 13.6),
  boxcar and cattle car 11, flatbed 4.4, tanker 11.9, engine cab 12.1, boiler walk 11.15.
  The highest step from a deck to a roof is about 7.6 studs, under the 8-stud jump.
- `Workspace.Map.Run.TrainStart`: an invisible marker part at (0, 3, 0). Move it to move
  the train.
- Runtime-generated content: `Workspace.Map.Run.Train` (Model) holds clones of the
  templates (`1_Caboose` … `7_Engine`, with Attribute `Index`). This is runtime spawning
  from templates, as allowed.

## Public API
- `TrainService.build()`: destroys any existing `Train` and builds a fresh one. It sets
  `workspace.Theme`. Session 5's PLAY AGAIN calls it.
- `TrainService.getCarriages(): { Model }`: the carriages of the current train, caboose
  first.

## Remotes
None.

## Data / state
- `LAYOUT` (in the module): Caboose → Boxcar → Flatbed → CattleCar → Boxcar → WaterTanker
  → Engine. The gap is `Constants.CARRIAGE_GAP` (3). The train is 201 studs long.
- `workspace` Attribute `Theme` (`"WildWest"`) replicates to clients.

## Depends on
- `Shared.Constants`

## Notes
- Verified 2026-10-13 in a playtest: 7 carriages, pivots at X 0, 20, 56, 76, 112, 148
  and 168.
