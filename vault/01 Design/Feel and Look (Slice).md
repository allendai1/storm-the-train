---
tags: [design, milestone, slice, feel, art, polish, spec, checklist]
status: planned
updated: 2026-10-16
---
# Feel and Look — the vertical slice

> **Status: planned. [decided 2026-10-16] This is the next milestone,** ahead of the rest
> of M2 (Sessions 7 saving, 12 hub, 13 full-loop playtest), M3 content and M4 meta. The
> developer's reasoning: *a great-feeling map, models and character feel come before
> economy or events, which won't matter if the game doesn't look and feel smooth.*
> Sessions 7 and 12 are already drafted ([[Session 7 PlayerDataService Code]],
> [[Session 12 Hub Code]]) and wait. The economy and event decisions made on 2026-10-16
> stay in their notes, untouched.

## Goal
**One Wild West train, Max Mayhem and the 5 built enemies (4 lights and Big Bart), at
roughly launch quality,** in look, animation, sound and feel. It should play well on a
phone and in 2–4 player co-op. Brick stays playable but isn't polished in this slice.

**Done means:**
- a new player plays one train solo and with friends,
- it reads clearly side-on,
- it holds the frame-rate budget on a mid-range phone,
- the developer says it feels great.

## Asset pipeline
**[decided 2026-10-16]** Models are made by **the developer in Blender**, sourced from the
**Creator Store or bought** (restyled and checked for embedded scripts), or built as
**refined Roblox parts and unions**, whichever fits each asset. Everything follows
[[Art Direction]]. Reusable Blender methods go in [[Techniques]]. The specs (sizes, parts,
what scripts depend on) are in [[Feel and Look Asset Specs]].

## Steps
### F1 — Look target
*Mostly cloud-able.*
- [ ] **A reference board** in [[References]], per [[Art Direction]] §13. The developer saves
  the chosen images into `05 Assets/References/`.
- [ ] **A one-page style sheet** (in [[References]]): shapes, finish, palette per layer,
  lighting mood, readability.
- [ ] **Lighting test plan:** ShadowMap vs Future on PC and a phone (the open item in Art
  Direction §8), plus the Atmosphere, ColorCorrection and Bloom starting values.

### F2 — The original's mechanics
**[changed 2026-10-16]** F2 is now [[Original Mechanics Match]] (§12's change list): the
original's movement, spin, swap, aim, score, Mayhem, enemies and health scale. The
[[Combat Polish Code]] helpers are used where they still fit. The run-structure parts (a
boss every train, the checkpoint, the leap) put McGraw and the TrainJump in the slice if
that's confirmed (§11).
- [ ] The parts of [[Combat Polish]] that still apply, with the original's numbers:
  - the flinch with a cooldown, muzzle flashes, enemy attack jitter and telegraph rules,
  - perception, off-screen spawning, Dan's lobbed dynamite,
  - 0.3 s i-frames, the spin pop-up, revive grace, the camera lead, explosion pop-up.
- [ ] **Big Bart as the original's berserker:** charges after every ~30 damage at 26.7
  studs/s for 34 studs, no stagger ([[Original Mechanics Match]] §7.3).

### F3 — Max's feel
- [ ] **A real animation set for Max** ([[Feel and Look Asset Specs]]): idle with
  personality, run, jump, spin, shooting while standing, running and airborne, hit-react,
  downed, revive, celebrate, swap-in.
- [ ] **A movement and jump tuning pass** (the M1 Session 6 tuning item): speeds, jump,
  gravity, air control, the coyote time and jump buffer if they feel needed.
- [ ] **Mobile controls feel:** button sizes and placement, the "a finger sliding off a
  button sticks" issue from [[Status]].
- [ ] **Hit feedback on Max:** the hurt face, a flash, and the costume damage stages if
  they're in reach (Art Direction §4).

### F4 — The map
- [ ] **The Wild West train kit at final quality:** engine, coal tender, boxcar, cattle car,
  flatcar, caboose and the gap pieces. The tags, attributes and sizes the scripts read are
  kept ([[TrainService]]).
- [ ] **Desert parallax layers** at final quality ([[ParallaxController]]), plus the sky and
  set-pieces (canyon, bridge, ghost town, cactus field). Build them with the
  [[Background Kit]] (the standard slots, the plugin and its validator); set the Wild West
  layers' `Slot` attributes first.
- [ ] **Lighting:** the decided technology, Atmosphere, ColorCorrection and Bloom (the
  [[Studio Setup Checklist]] §4 items).

### F5 — Characters and enemies
- [ ] **Max's toon model** (R15, the hitbox kept), with face decals per state.
- [ ] **The 4 lights and Big Bart:** toon models with readable side-on silhouettes, a hat
  per slot, and the bandana colour.
- [ ] **Knockouts:** the ragdoll impulse, a **hat popping off** and **circling stars**.
- [ ] **A VFX pass:** dust on landing and running, smoke, sparks, explosions, the charge dust,
  the fuse sparkle, the spin trail, the coin sparkle (Art Direction §9).

### F6 — Sound
- [ ] Gunshots per weapon, hits, footsteps, jump, landing and spin, knockouts, enemy barks
  (text bubbles plus voiced grunts, decided), coins, the leap, the checkpoint, the UI, and
  a Wild West music loop.

### F7 — Prove it
- [ ] **Phone test:** frame rate and readability on a mid-range phone, against the Art
  Direction §11 budgets.
- [ ] **A 2–4 player playtest** (the rest of M1 Session 6): verify the unverified co-op
  items in [[Status]] along the way.
- [ ] **A tuning pass,** recording what changed and why. Repeat until it feels great.

## After the slice
Resume [[Loop (M2)]] (Session 7 saving, Session 12 hub, Session 13 playtest), then M3
content and M4 meta, as in the [[Game Design Document]].

Related: [[Combat Polish]] · [[Art Direction]] · [[First Playable (M1)]] · [[Loop (M2)]] · [[Game Design Document]] · [[Status]]
