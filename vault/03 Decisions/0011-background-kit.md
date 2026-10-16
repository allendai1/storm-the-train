---
tags: [decision, background, parallax, tooling]
status: proposed
date: 2026-10-16
---
# 0011 — Background Kit: standard slots, variant tiles and in-place editing

## Context
[[0009-static-trains-scrolling-world]] made the background a set of client-side scrolling
layers, each built from one hand-made `Tile`. That works for Wild West, but every new theme
would invent its own layers, depths and tile sizes, and nothing checks them. The templates
live in `ReplicatedStorage`, where you can't see them next to the train while building.
Each layer also repeats one tile exactly, and the copy counts were picked by eye (with
the built controller, Scrub's 4 copies are too few on wide phones). The developer asked
for a standard way to add each map's layers and tiles.

## Decision
- **Six standard slots** (Foreground, Track, Ground, Near, Mid, Far) with fixed Z bands
  and default tile lengths, defined once in `ReplicatedStorage.Shared.BackgroundKit` and
  documented in [[Background Kit]]. A layer declares its slot with a `Slot` attribute; its
  name stays free.
- **Variant tiles:** a layer may hold `Tile_<Name>` models with `Weight` (random) or
  `Every`/`Offset` (scheduled set-pieces). ParallaxController picks by tile index, from a
  scroll distance that never wraps, so a stretch of scenery is stable.
- **Copies are centred on the camera** (the built controller keeps more of them on the −X side, where scenery scrolls off, leaving the +X edge short),
  so the fewest copies cover both screen edges.
- **Copy counts come from maths**, not guesses: `BackgroundKit.minTiles` from the content's
  depth and the widest screen we support (21:9).
- **Edit in place with a Studio plugin:** the Background Kit plugin moves one theme into
  `Workspace.BackgroundStudio`, next to the train, with ghost copies, depth-band guides
  and seam posts, the game camera view, an "add selection to layer" tool, a validator and
  a part-settings fixer. **Done** moves it back to `ReplicatedStorage`.
- **Safety net:** `BackgroundStudioService` (server, every mode) moves a theme left open in
  `Workspace.BackgroundStudio` back for the running session, so a forgotten **Done** never
  breaks a playtest. The saved place is unchanged.
- The plugin builds its own panel UI in code: it's Studio tooling, not game UI, so the
  hand-built GUI rule ([[0002-build-in-place-script-behavior]]) doesn't apply to it.

## Alternatives considered
- **Keep templates in ReplicatedStorage and edit them blind** (or drag them out by hand):
  no seam or depth feedback, easy to leave things in the wrong place.
- **Author permanently in Workspace and have the server move the whole set at start:**
  simpler (no plugin needed to open or close), but every theme would clutter the place,
  overlapping at the same spot behind the train.
- **Per-layer scroll factors in code** instead of real depth: works, but loses the free,
  correct perspective and makes the camera maths per-layer guesswork.
- **Random variants per recycle (not by index):** scenery would change if the camera came
  back to the same stretch.

## Consequences
- Every theme gets the same structure and checks; new themes are a fill-in exercise.
- ParallaxController changes: it reads variants and keeps a never-wrapping scroll
  distance. The old single-`Tile` layers keep working unchanged.
- A plugin to install once per machine, kept in the place (e.g. `ServerStorage.Tools`) so
  it's versioned with Roblox's place history.
- One more server service (tiny, init-only).
- Triangle budgets still need checking in Blender; scripts can't read mesh triangle counts.

Related: [[Background Kit]] · [[Background Kit Code]] · [[ParallaxController]] · [[0009-static-trains-scrolling-world]]
