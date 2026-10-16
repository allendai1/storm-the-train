---
tags: [system, m1, visuals]
status: implemented
side: client
---
# ParallaxController

## Purpose
Gives the static train its sense of motion ([[0009-static-trains-scrolling-world]]): it
scrolls the theme's background strips past it, on the client only. Nothing replicates, and
the server never moves scenery.

## Code
- Studio path: `StarterPlayer.StarterPlayerScripts.Client.Controllers.ParallaxController`
  (`Modes = { "Run" }`)

## Expects in the place
- `ReplicatedStorage.Assets.Backgrounds.<Theme>` (a Folder). Each child is a **layer
  Model** with:
  - Attributes `TileLength` (studs) and `Tiles` (how many copies to recycle; raise it if
    gaps show at the screen edges),
  - one `Tile` Model whose pivot sits at its left end, with its parts spanning X 0 to
    `TileLength`. All parts are anchored and have no collision, query, touch or shadows.
- **Wild West layers (greybox):**

  | Layer | TileLength | Tiles | Contents |
  |---|---|---|---|
  | Desert | 200 | 8 | Ground slab (Z +60 … −640) plus rocks and scrub |
  | Track | 30 | 5 | 10 ties and 2 rails under the train |
  | Scrub | 120 | 4 | Saguaros and bushes, Z −35 … −110 |
  | Mesas | 500 | 4 | Mesas and a butte, Z −380 … −520 |
  | Foreground | 140 | 2 | A telegraph pole at Z +22 |

- The `workspace` Attribute `Theme`, set by [[TrainService]].
- Runtime-generated content: `Workspace.Background` (a client-only Folder of tile clones).
  This is runtime recycling of hand-built templates.

## Public API
None.

## Remotes
None.

## Data / state
- Bound to RenderStep `Parallax` at `RenderPriority.Camera + 1`, so it runs after the
  camera.
- **Every layer moves at `Constants.TRAIN_SPEED` (50 studs/s) in −X.** The perspective
  camera makes far layers drift slower on screen, so there are no per-layer speeds.
- Tiles are recycled around the camera's X:
  `scroll = (t × speed) mod L`, `first = floor((camX + scroll) / L − n / 2)`.
- When `Theme` changes, it reloads the set.

## Depends on
- `Shared.Constants`, [[TrainService]] (for `Theme`)

## Notes
- **Planned: the [[Background Kit]]** ([[0011-background-kit]], proposed). Six standard
  slots with a `Slot` attribute, `Tile_<Name>` variants (`Weight`, or `Every` for
  set-pieces), and a scroll distance that never wraps, so tile index j always shows the
  same variant. Drafted as a replacement for this controller in [[Background Kit Code]] §2
  (not run yet). The kit's maths also shows **Scrub needs `Tiles` 5 and Foreground 3** on
  wide phones; see [[Background Kit]].
- The sky is `Lighting.Sky` plus Atmosphere, not a strip. The Wild West gradient
  (`#8EC3E6` → `#F6DDB4`) still needs setting by hand ([[Studio Setup Checklist]] §4).
- Not yet done: wheel and rod animation, smoke and camera sway (ADR 0009). It uses one
  `PivotTo` per tile per frame (about 23 tiles). Switch to `BulkMoveTo` if profiling says
  so.
- Verified 2026-10-13 in a playtest: 23 tiles, and a tile moved about 5 studs in 0.11 s.
