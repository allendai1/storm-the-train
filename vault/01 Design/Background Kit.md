---
tags: [design, background, parallax, map, pipeline, standard, slice]
status: planned
updated: 2026-10-16
---
# Background Kit — the standard for every theme's scenery

> **Status: planned.** The developer asked on 2026-10-16 for a standard way to build each
> map's background layers and tiles. This note is that standard. The code (a shared
> module, a ParallaxController upgrade, a safety-net service and a **Studio plugin**) is
> drafted in [[Background Kit Code]] and **hasn't run in Studio yet**. The architecture
> choice is [[0011-background-kit]] (proposed). How the scrolling works is explained in
> [[ParallaxController]] and [[0009-static-trains-scrolling-world]].

## The idea in one paragraph
Every theme's background is built from the **same six layer slots**, at the **same depth
bands**, with the **same rules** for tiles. You build each layer's one `Tile` by hand, right
next to the train in the place, while ghost copies show you the repeats and seams. A
plugin drops props into the right layer at the right depth, shows the real game camera
view, checks everything, and fixes the boring part settings. Adding a theme becomes:
**New theme → build six tiles → Validate → Done → save.**

## The six slots
Z is measured from the play plane (Z 0); the camera sits at +Z. Every theme uses these
bands, so the parallax looks the same from map to map and the tooling can check depth.

| Slot | Z band | Default tile | Min copies* | On-screen speed (16:9) | What goes here |
|---|---|---|---|---|---|
| **Foreground** | +12 → +24 (in front) | 140 | 3 | 1.8× → 1.3× the track | Rare, dark, simple shapes: poles, rocks, posts. Never covers the action for long |
| **Track** | −4 → +4, **max 3 high** | 30 | 5 | 1× (the "real" speed) | Ties, rails, ballast. Anything taller shows above the couplers between cars |
| **Ground** | +60 → −640 | 200 | 8 | 1× near you → 0.08× far | The floor slab (it must reach in front of the camera) plus low scatter |
| **Near** | −20 → −120 | 120 | 5 | 0.7× → 0.3× | Readable props: cacti, fences, bushes, signs, crates |
| **Mid** | −140 → −320 | 240 | 5 | 0.28× → 0.14× | Big landmarks and set-pieces: towns, water towers, canyon walls |
| **Far** | −350 → −600 | 500 | 5 | 0.13× → 0.08× | The skyline: mesas, mountains, city silhouettes |

\*For content reaching the band's far edge on the widest screens we plan for (21:9). The
validator works out the real minimum from what you actually built, so a layer whose
content stops short of its far edge may need fewer.

The sky isn't a slot: it's `Lighting.Sky` plus Atmosphere, and it doesn't move.

**Triangle budget** (everything of that slot on screen at once, adding up to the 20k
background budget in [[Art Direction]] §11): Foreground 1k, Track 2k, Ground 4k, Near 5k,
Mid 3k, Far 5k. Studio can't count a mesh's triangles from a script, so read the counts in
Blender; the validator reports part counts as a guide.

## What a theme looks like in the place
```
ReplicatedStorage.Assets.Backgrounds
└── <Theme>                      Folder, PascalCase (WildWest, Ninjas…)
    ├── <Layer>                  Model, any clear name (Scrub, Mesas…)
    │     Attributes: Slot ("Near"), TileLength (120), Tiles (5)
    │   ├── Tile                 Model: the default chunk. Pivot at its LEFT end, unrotated
    │   │   ├── Saguaro          props, grouped and named
    │   │   └── FenceRun         Attribute Continuous = true (runs the full 0 → TileLength)
    │   └── Tile_CactusField     optional variant (Weight 0.5) or set-piece (Every 6)
    └── …one layer per slot
```

### Layer Model (the contract the code reads)
| Attribute | Type | Meaning |
|---|---|---|
| `Slot` | string | `Foreground`, `Track`, `Ground`, `Near`, `Mid` or `Far`. The tooling checks the depth band from it. The layer's **name** is free (keep Wild West's `Scrub`, `Mesas`…) |
| `TileLength` | number | Length of one tile in studs. Every variant in the layer uses the same length |
| `Tiles` | number | Copies kept in play. The validator says the minimum |

### Tiles and variants
- **`Tile`** is required: the default chunk.
- **`Tile_<Name>`** models are optional variants, so a layer doesn't repeat exactly:
  - `Weight` (number, default 1): how often it's picked at random, relative to the others
    (`Tile` counts as weight 1 unless you give it one).
  - **Set-pieces:** `Every` (whole number ≥ 2) + optional `Offset` makes it appear on
    exactly every Nth tile instead of at random, e.g. a ghost town every 8th Mid tile.
- The pick depends only on the tile's position along the run, so **a stretch of scenery
  stays the same if the camera comes back to it.**
- Variants sit to the left of the train while you edit, labelled.

### Tile rules
1. **Pivot at the left end, unrotated.** Content runs from X 0 to `TileLength` along +X.
   Only X is changed at runtime; the tile's Y and Z stay exactly where you built them.
2. **Nothing crosses the ends.** Whatever touches the right edge meets the left edge of
   the next copy. Objects that should run edge to edge (rails, fences, wires, the ground
   slab) get **`Continuous = true`**, and the validator checks they span exactly 0 →
   `TileLength`, with no gap at the seam.
3. **Stay inside your slot's Z band.**
4. **Stagger depth inside a band.** Props at different Z inside the band slide past each
   other on screen, which sells the depth ([[Background Kit#Making it look good]]).
5. **Background part settings:** anchored; `CanCollide`, `CanQuery`, `CanTouch` and
   `CastShadow` off. The plugin's **Fix part settings** does this in one click.
6. **No scripts** inside tiles.
7. **Named, grouped props** (no default `Part`/`Model` names), reusable props as Models.
8. **The look follows [[Art Direction]]:** paler, desaturated and lower contrast with
   distance; only the gameplay plane is fully saturated.

## Making it look good
- **Vary within the tile** so the repeat is hard to spot: clumps and gaps, not even
  spacing. The Near layer repeats every few seconds, so it benefits most from 2–4 variants.
- **Stagger depth:** e.g. cacti at Z −30, −55 and −90 in the Near band. Things at
  different depths drift past each other.
- **Silhouettes against the next layer back:** Far reads as a skyline shape, Mid as
  landmarks, Near as props.
- **Foreground sparingly:** one dark object every tile or two; it moves fastest and can
  hide the action.
- **The ground must reach in front of the camera** (to about Z +20 on a 16:9 screen) or
  the bottom of the screen shows sky colour.

## Building a new theme (the workflow)
1. **Install the plugin once** ([[Background Kit Code]] §4) and make sure
   `ReplicatedStorage.Shared.BackgroundKit` exists.
2. In the **Background Kit** panel, type the theme name (e.g. `Ninjas`) and press
   **New theme**. It creates the six standard layers with empty tiles, the right
   `Slot`, `TileLength` and `Tiles`, and opens it next to the train.
3. **Build props anywhere** (Blender imports, Creator Store assets after the script scan,
   or parts). Select them and press the layer's button (**Near**, **Far**…). The plugin:
   - parents them into that layer's `Tile`,
   - moves them into the slot's Z band if they're outside it,
   - wraps their X into the tile (drop a prop over a ghost copy and it lands at the same
     spot in the real tile),
   - applies the background part settings,
   - warns if a prop crosses the tile's end.
4. **Look through the game camera** (**Game camera**) and pan along X. The ghosts show the
   repeats. **Refresh ghosts** after editing.
5. **Variants and set-pieces:** duplicate `Tile`, rename it `Tile_<Name>`, change its
   contents, and give it `Weight` or `Every`.
6. **Validate**, fix what it reports (errors first), then **Done**: the theme goes back to
   `ReplicatedStorage.Assets.Backgrounds`. **Save the place.**
7. Playtest with the theme set (`workspace.Theme`), on a phone too if possible.

Editing an existing theme is the same from step 3: type its name and press **Edit**.
Forgot to press **Done** before Play? The safety-net service moves it back for the session
(the saved place stays as you left it).

## What the validator checks
- **Errors:** missing `TileLength`, `Tiles` or `Tile`; an unknown `Slot`; **`Tiles` below
  the minimum** for how deep the content goes (scenery would pop in at the screen edge on
  wide phones); scripts inside tiles.
- **Warnings:** no `Slot`; props crossing a tile's end; `Continuous` props that don't span
  the tile; props outside their slot's Z band; Track props taller than 3 studs; parts not
  anchored or still colliding, blocking shots or casting shadows; rotated tile pivots; bad
  `Weight`/`Every` values.
- **Info:** empty tiles, default names, `Tiles` that could be lower, and part counts per
  tile and on screen.

## Wild West: moving to the standard
The greybox already follows most of this. The changes ([[Background Kit Code]] §5):

| Layer | `Slot` | Notes |
|---|---|---|
| Foreground | Foreground | **`Tiles` 2 → 3.** With 2 copies, the leading copy can run out right at the camera; only a lone pole in the middle of the tile hides it |
| Track | Track | Mark the rails `Continuous` |
| Desert | Ground | Mark the ground slab `Continuous` |
| Scrub | Near | **`Tiles` 4 → 5.** On wide phones the camera is closer, so the far edge of the scrub band needs about 131 studs of cover and 4 copies guarantee only 120 |
| Mesas | Far | Fine at 4 (content stops at Z −520) |

Then **Validate**, and fix what it finds. The Mid slot is empty for now; the ghost town
and canyon set-pieces ([[Feel and Look Asset Specs]] §3.4) go there.

## Not covered yet
- **Theme changes mid-run** still swap the whole set instantly. When a second theme exists
  (M3), add a transition: a tunnel, a fade, or swapping behind a big foreground object.
- **Wheel, rod and smoke animation** and **camera sway** are separate F4/F5 items.
- **Triangle counts** can't be read by a script; check them in Blender.

## Open questions
1. Are the six slots and their Z bands right? (Mid is new; the rest match the greybox.)
2. Should 21:9 be the widest screen we guarantee? It decides the minimum copies.
3. Accept [[0011-background-kit]] (edit next to the train with a plugin, and the safety
   net that moves a theme back at runtime)?

Related: [[ParallaxController]] · [[0009-static-trains-scrolling-world]] · [[Art Direction]] · [[Feel and Look (Slice)]] · [[Feel and Look Asset Specs]] · [[Background Kit Code]]
