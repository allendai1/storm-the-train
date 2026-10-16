---
tags: [system, m1, train]
status: implemented
side: server
---
# TrainService

## Purpose
Builds the run's trains in Run mode: it clones carriage templates end to end along +X
([[0009-static-trains-scrolling-world]]). The first train starts at `Map.Run.TrainStart`;
each next one is built `LEAP_GAP` (10) ahead of the current train's front (M2 Session 9),
and a checkpoint "train" is the single `HubCheckpoint` carriage. Carriages are
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
- **`ServerStorage.Assets.Trains.HubCheckpoint`** (M2): a 60-stud navy-and-gold flatcar.
  - Its `Roof` deck (top Y 4.4) is tagged `WalkSurface`, and gold trim runs along it.
  - **Pods** sit behind the walkway at Z −3, out of the play plane: `MedbayPod`
    ("FREE FULL HEAL"), `BarracksPod` ("CHANGE SQUAD") and the closed `ArmoryPod`,
    `SurplusPod` and `MissionsPod` ("COMING SOON", `Closed = true`). Each has a SurfaceGui
    `Sign` facing the camera.
  - Attributes `Length` 60, `CarriageType` "HubCheckpoint", `Theme` "Agency"; tag
    `Carriage`.
  - There's no `EnemySpawn` and no `TrainGoal`.
- `Workspace.Map.Run.TrainStart`: an invisible marker part at (0, 3, 0). Move it to move
  the train.
- Runtime-generated content: `Workspace.Map.Run.Train` (Model) holds clones of the
  templates (`1_Caboose` … `7_Engine`, with Attribute `Index`). This is runtime spawning
  from templates, as allowed.

## Public API
- `TrainService.build()`: a fresh run. It destroys every train, builds a hostile one at
  `TrainStart` and sets `workspace.Theme`. PLAY AGAIN calls it.
- `TrainService.buildNext(kind: "Hostile" | "Checkpoint") -> Model`: builds the next train
  ahead and makes it current (`Map.Run.Train`). The old one becomes
  `Map.Run.PreviousTrain`.
- `TrainService.dropPrevious()`: destroys the train behind, once everyone has crossed.
- `TrainService.current()` and `TrainService.previous()`.
- `TrainService.getCarriages(): { Model }`: the carriages of the current train, caboose
  first.
- Each train Model carries the attributes `Kind`, `RearX` and `FrontX`.

## Remotes
None.

## Data / state
- **The car order is the `Layout` attribute on `ServerStorage.Assets.Carriages.WildWest`**
  (comma-separated template names, editable in Properties; added 2026-10-16):
  Caboose → Boxcar → Flatbed → CattleCar → Boxcar → WaterTanker → Engine. The module's
  `DEFAULT_LAYOUT` is the fallback. The gap is `Constants.CARRIAGE_GAP` (3). The train is 201 studs long.
- `workspace` Attribute `Theme` (`"WildWest"`) replicates to clients.

## Depends on
- `Shared.Constants`

## Notes
- Verified 2026-10-13 in a playtest: 7 carriages, pivots at X 0, 20, 56, 76, 112, 148
  and 168.
- 2026-10-13 (Session 4): the Caboose `Roof` was trimmed from 13 to 11 studs, flush with the
  cabin. Its 1-stud overhang blocked enemies (and players) jumping from the porches onto the
  roof.

- 2026-10-16: the [[Background Kit]] plugin's **Train** section (Edit train, Check train,
  Train done) opens these templates in `Workspace.TrainStudio` at `TrainStart` in `Layout`
  order, the checkpoint car after a leap gap, so they can be edited in place. Verified: the
  same X positions as a real run, the check is clean, Done puts them back at (0, 3, 0), and
  a playtest with the train left open still builds all 7 cars.
