---
tags: [decision, movement, camera, controls]
status: proposed
date: 2026-10-13
---
# 0005 — Side-on movement lock and camera

## Context
[[0003-2.5d-side-scroller]] locks gameplay to one axis along the train plus jumping,
and leaves the implementation open. Agents are R15 Humanoids ([[Art Direction]]).
Movement speeds are decided in the GDD: 18–33 studs/s per agent.

## Decision
- **Axes:**
  - World **X** runs along the train.
  - **Y** is up.
  - The gameplay plane is **Z = 0**. Every player, enemy, hitbox and projectile stays
    on it.
- **Plane lock:**
  - Each character's `HumanoidRootPart` gets a constraint that keeps Z at 0. Use a
    `PlaneConstraint` if it's available in the engine version (check in Studio).
    Otherwise use an `AlignPosition` on the Z axis only.
  - The server also snaps any Z drift above 0.5 studs.
- **Network ownership:** each client owns its own character, as Roblox does by
  default, so movement feels responsive. The server validates instead of simulating:
  - Z drift.
  - Horizontal speed, flagged above the agent's `Speed` × 1.25.
  - Teleport-sized jumps between server ticks.
  - It corrects or sets back offenders and logs them. It never trusts the client's
    position for hits ([[0006-humanoid-enemies-and-combat]]).
- **Controls:**
  - `StarterPlayer.DevComputerMovementMode` and `DevTouchMovementMode` are
    `Scriptable`. The client controller reads A/D or ←/→ on PC and the on-screen
    buttons on mobile, and calls `Humanoid:Move(Vector3.new(x, 0, 0))`.
  - `Humanoid.AutoRotate` is off. The client turns the character to face ±X from the
    last move direction.
  - The server sets `WalkSpeed` and `JumpHeight` from the agent's Attributes and
    `Shared.Constants`.
- **Double jump = spin attack:**
  - The client detects a second Jump press while airborne and sends `RequestSpin`.
  - The server checks it (airborne, cooldown, not downed), applies the spin's damage
    and a small upward boost, and replicates the effect.
- **Camera:**
  - The camera is `Scriptable` and side-on, looking along −Z at the plane from a fixed
    distance. Start with a narrow **FOV of about 40°**, to limit perspective distortion.
    Framing shows about **70 studs** of track ([[Art Direction]] §6).
  - It follows your own character's X smoothly and leads in the facing direction. Its
    height stays fixed near roof level, with gentle follow on jumps.
  - Each player has their own camera. Teammates off screen get edge-of-screen arrows in
    their player colour.
- **Falling into a gap** between cars: **[open]** the GDD doesn't say what happens.
  The proposal is that you reappear on the nearest roof after 1 s and take 15 raw
  damage. Big Bart's charge can knock players into gaps.

## Alternatives considered
- **A custom character controller with no Humanoid:** the most control, but it breaks
  Roblox animation and avatar tooling, and the decided ragdoll and Humanoid physics.
- **Server-owned characters:** cheat-proof movement, but input lag makes a fast action
  game feel bad.
- **A per-frame Z clamp only, without a constraint:** simpler, but it jitters under
  physics impulses such as knockback and charges.

## Consequences
- Characters behave like normal Roblox Humanoids apart from the Z lock. Animation and
  ragdoll work as standard.
- Because clients own their characters, movement cheats are only caught by server
  validation, and the thresholds need tuning.
- The camera, input and touch layout are entirely custom client controllers (see the
  [[Art Direction]] §10 mockups).

Related: [[0003-2.5d-side-scroller]] · [[0006-humanoid-enemies-and-combat]] · [[Home]]
