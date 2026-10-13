---
tags: [design, art]
status: in-progress
updated: 2026-10-13
---
# Art Direction

> Consult before any 3D modeling, mesh/material generation, or asset insertion.
> Claude should not invent art direction — ask the user, and put proposals in `00 Inbox/`.
>
> **Status: in progress.** The four core choices below were **decided** by the developer on
> 2026-10-13. Everything else, including palettes, readability rules, budgets, UI and
> VFX, is still a proposal in [[Art Direction Proposal]]. It moves into this note once
> accepted.

## Visual style
- **[decided] Smooth stylized toon.** Rounded, chunky meshes with simple materials and
  bold shapes, like a Saturday-morning cartoon in 3D. It suits the costume-gag comedy
  ([[Game Design Document]] → Tone) and reads clearly from the locked side-on camera
  ([[0003-2.5d-side-scroller]]). It needs real mesh work: Blender, or Studio mesh
  generation restyled to match.

## Color palette
- **[decided] Bright actors, calmer worlds.** Each theme's backdrop is softer and less
  saturated (a dusty desert, a misty bamboo forest…). Everything you interact with is
  fully saturated: agents, enemies, hazards, projectiles and pickups. That keeps
  "Chaos you can read" true.

| Role | Color | Notes |
|------|-------|-------|
| _See [[Art Direction Proposal]]_ | | Theme, agent and player palettes are proposed there |

## Shapes & proportions
- **[decided] Standard Roblox R15 proportions** for agents and enemies. Personality comes
  from **silhouette**: costumes, hats, capes, skates, oversized props and weapons, not
  from exaggerated bodies.

## Rigs
- **[decided] R15-compatible rigs with a custom look.** Our own toon meshes sit on an
  R15-compatible skeleton. They work with Roblox's animation tools and library and with
  Humanoid physics, which the ragdoll knock-outs in the GDD rely on, while still looking
  like our own characters rather than player avatars.

## Materials & textures
- _Proposed in [[Art Direction Proposal]]._

## Lighting & atmosphere
- _Proposed in [[Art Direction Proposal]]._

## Technical budgets
- _Proposed in [[Art Direction Proposal]]._

## Key subjects
- **Train:** _proposed_
- **Characters:** standard R15 proportions with a custom toon look (decided). See
  [[Launch Agents]] and [[Wild West Enemies]] for the cast.
- **Environment:** calmer, softer backdrops behind a saturated gameplay plane
  (decided).

## References
Images live in `05 Assets/References/`. Embed with `![[filename.png]]`.
None yet. [[Art Direction Proposal]] lists what to collect.

Related: [[Home]] · [[Status]] · [[Art Direction Proposal]] · [[Game Design Document]]
