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
  - Attributes `TileLength` (studs), `Tiles` (copies kept around the camera) and `Slot`
    (Foreground, Track, Ground, Near, Mid or Far; [[Background Kit]]),
  - one `Tile` Model whose pivot sits at its left end, with its parts spanning X 0 to
    `TileLength`, plus optional `Tile_<Name>` variants (`Weight`, or `Every` + `Offset`
    for set-pieces). All parts are anchored and have no collision, query, touch or shadows.
- **Wild West layers (greybox):**

  | Layer | Slot | TileLength | Tiles | Contents |
  |---|---|---|---|---|
  | Desert | Ground | 200 | 8 | Ground slab (Z +60 … −640, `Continuous`) plus rocks and scrub |
  | Track | Track | 30 | 5 | 10 ties and 2 rails (`Continuous`) under the train |
  | Scrub | Near | 120 | 4 | Saguaros and bushes, Z −35 … −110 |
  | Mesas | Far | 500 | 4 | Mesas and a butte, Z −380 … −520 |
  | Foreground | Foreground | 140 | 2 | A telegraph pole at Z +22 |

  The kit's minimum copy counts are 7, 4, 4, 3 and 2, so every layer has enough.

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
- `travel` (total distance scrolled) never wraps, so tile index j always shows the same
  variant. Copies are **centred on the camera**:
  `first = floor((camX + travel) / L − n / 2 + 0.5)`, and copy j sits at `j × L − travel`.
- Copies are pooled per variant (unused ones have `Parent = nil`), and every part moves in
  **one `BulkMoveTo` per frame**, from offsets cached per copy. Each template keeps its pivot
  Y, Z and rotation; only X is set.
- When `Theme` changes, it reloads the set, ignoring a load a newer change has overtaken.

## Depends on
- `Shared.Constants`, `Shared.BackgroundKit` (slots, `readLayer`, `pickVariant`),
  [[TrainService]] (for `Theme`)

## Notes
- **Replaced with the [[Background Kit]] version on 2026-10-16** ([[Background Kit Code]] §2).
  Nothing was lost from the old one: it used `WaitForChild` for `Shared` (kept) and put
  every tile at Y 0, Z 0 (all Wild West pivots are at the origin, so they look the same).
- **[[Background Kit]] safety net:** `Server.Services.BackgroundStudioService` (no
  `Modes`) puts a theme left open in `Workspace.BackgroundStudio`, and carriage templates
  left open in `Workspace.TrainStudio`, back where the game reads them for that playtest.
- The sky is `Lighting.Sky` plus Atmosphere, not a strip. The Wild West gradient
  (`#8EC3E6` → `#F6DDB4`) still needs setting by hand ([[Studio Setup Checklist]] §4).
- Not yet done: wheel and rod animation, smoke and camera sway (ADR 0009).
- Verified 2026-10-13 in a playtest: 23 tiles, and a tile moved about 5 studs in 0.11 s.

- Verified 2026-10-16 (Background Kit version): 23 copies, about 50 studs/s, no errors. A
  `Weight` variant showed up in play, the same tile index gave the same pick, and
  `Every = 4` landed on every 4th tile. The open-theme safety net worked. **Not checked:**
  the screen edges at a wide-phone size in the device emulator.
