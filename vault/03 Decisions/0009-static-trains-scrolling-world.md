---
tags: [decision, trains, world, performance]
status: accepted
date: 2026-10-13
---
# 0009 — Static trains, scrolling world, carriage templates

## Context
"The train never stops" (GDD pillar 3). Physically moving trains at speed would mean
moving platforms under Humanoids, network jitter and physics instability.
[[Art Direction]] §6 already proposes that the train stays put while the world scrolls.

## Decision
- **The train is static and the world scrolls.** Carriages are **anchored**, near the
  world origin, along +X. The sense of motion is **client-only**:
  - parallax background strips moved on `RenderStepped`, which costs nothing to
    replicate,
  - wheel and rod animation,
  - smoke,
  - a slight camera sway.

  The server never moves the scenery.
- **Carriage templates** live in `ServerStorage.Assets.Carriages.<Theme>.<Type>`. For
  the Wild West, the types are Engine, Boxcar, Flatbed, CattleCar, JailCar,
  WaterTanker and Caboose. Each template has:
  - its `PrimaryPart` at the **rear coupling** (its left end),
  - Attributes `Length`, `CarriageType` and `Theme`,
  - the tag `Carriage`,
  - a `Roof` walk surface tagged `WalkSurface`,
  - **Attachments** tagged `EnemySpawn` (and `HostageSpawn`, `BossArena` where
    relevant).
- **Assembling a train:** `TrainService` builds each hostile train from 6–8 templates,
  placed end to end along +X with a fixed jumpable gap (Attribute `CarriageGap` in
  `Shared.Constants`, about 3 studs).
  - Event trains include their key car: a JailCar for a hostage train, a Flatbed arena
    for a boss train.
- **Next-train leap:** the next train is built further along +X, after a larger gap
  (about 10 studs, a "leap"). The old train is destroyed once every living player is
  across. X keeps growing over a run. That's fine for realistic run lengths (about 200
  studs per train, so roughly 10,000 studs after 50 trains). Add a world-recentre step
  only if precision problems show up.
- **Checkpoints:** the hub train's checkpoint version (template
  `ServerStorage.Assets.Trains.HubCheckpoint`, with the pods from the GDD) is placed
  ahead like a normal next train. Hub mode uses the full hand-built `Map.Hub`
  ([[0004-single-place-hub-and-run-modes]]).
- **Theme change:** clients swap the background strip set when the `Theme` attribute
  on the run changes.

## Alternatives considered
- **Physically moving trains:** "real", but Humanoids riding fast moving platforms is
  a known source of jitter and desync on Roblox.
- **A treadmill** (resetting the train's position each loop): no X growth, but every
  entity's position has to be rewritten. That's more complex for little gain.

## Consequences
- Physics stays stable: the gameplay surfaces never move.
- The motion illusion depends entirely on client visuals. Every client has to animate
  the background, so budget its parts and triangles ([[Art Direction]] §11).
- The carriage templates are the main hand-built assets for M1. Their Attributes and
  tags are the contract `TrainService` reads.

Related: [[0006-humanoid-enemies-and-combat]] · [[Art Direction]] · [[Home]]
