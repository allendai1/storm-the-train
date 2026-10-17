---
tags: [reference, original-game, animation, assets, decoding]
status: reference
updated: 2026-10-17
---
# Original Game - Animations

> **Status: reference** (not canon). Decoded on 2026-10-17 from the original's `assets/`
> folder ([[Original Game]]). The decoder is in [[Original Animation Decoder]]. A private
> **viewer page** plays every clip with the original's own art:
> https://claude.ai/artifact/U5HJ6jGN2p2BAQMN7suQvW (only the owner can open it until it's
> shared).

## What the files hold
- **Characters are 2D cut-out puppets:** 9–11 bones (root, body, head, upper arms,
  forearms, hands, legs; enemies have no forearms), each carrying one flat sprite. Mason
  has extra bones for his chainsaw gears.
- **Animation is baked:** one timeline per character at **15 fps** (Graham: 466 frames).
  Each animated channel (a bone's X, Y or rotation) stores one value per frame.
  **Clips are named frame ranges** on that timeline.
- **The sprites** are in uncompressed texture atlases with a text index, three damage
  states per agent part (`_3` is full armour, `_1` the most damaged).
- **Enemy scripts** (`scripts/Enemies/*.lua`) map each state (IDLE, RUN, ATTACK, DAMAGE_GUN…)
  to clip names and give each enemy its textures and weapons.
- **Found in the files:** an unreleased agent, **the cowgirl ("Gail")**, with twin
  revolvers and a full animation set: the original's own Wild West gunslinger. Her
  revolver sprite is missing from the atlases (the viewer uses the standard revolver).

## Clip timings
Lengths at the file's 15 fps. The code can also scale playback speed (the run, for
example, may follow movement speed), so treat these as the authored lengths.

### Agents (the clip names the game uses)

| Clip | Graham → Max | Mason → Brick | Cowgirl (Wild West) |
|---|---|---|---|
| `IDLE` | 13 f · 0.87 s | 13 f · 0.87 s | 13 f · 0.87 s |
| `RUN` | 13 f · 0.87 s | 13 f · 0.87 s | 13 f · 0.87 s |
| `FIRE` | 5 f · 0.33 s | 5 f · 0.33 s | 5 f · 0.33 s |
| `IDLE_FIRE` | 13 f · 0.87 s | 13 f · 0.87 s | 13 f · 0.87 s |
| `JUMP` | 13 f · 0.87 s | 13 f · 0.87 s | 13 f · 0.87 s |
| `JUMP_FIRE` | 3 f · 0.20 s | 3 f · 0.20 s | 3 f · 0.20 s |
| `LAND` | 7 f · 0.47 s | 7 f · 0.47 s | 7 f · 0.47 s |
| `SPIN` | 6 f · 0.40 s | 6 f · 0.40 s | 6 f · 0.40 s |
| `DAMAGE` | 13 f · 0.87 s | 13 f · 0.87 s | 13 f · 0.87 s |
| `DEATH_A` | 5 f · 0.33 s | 5 f · 0.33 s | 5 f · 0.33 s |
| `DEATH_B` | 9 f · 0.60 s | 9 f · 0.60 s | 9 f · 0.60 s |
| `DEATH_TWITCH_A` | 8 f · 0.53 s | 8 f · 0.53 s | 8 f · 0.53 s |
| `DROP` | 17 f · 1.13 s | 17 f · 1.13 s | 17 f · 1.13 s |
| `EQUIP` | 25 f · 1.67 s | 25 f · 1.67 s | 25 f · 1.67 s |
| `NTE_RUN` | 13 f · 0.87 s | 13 f · 0.87 s | 13 f · 0.87 s |
| `NTE_JUMP` | 16 f · 1.07 s | 16 f · 1.07 s | 16 f · 1.07 s |
| `NTE_LAND` | 11 f · 0.73 s | 11 f · 0.73 s | 11 f · 0.73 s |
| `JE_HOVER` | 25 f · 1.67 s | 25 f · 1.67 s | 25 f · 1.67 s |
| `CHOPPER_IDLE` | 13 f · 0.87 s | 13 f · 0.87 s | 13 f · 0.87 s |
| `MECH_ENTER` | 6 f · 0.40 s | 6 f · 0.40 s | 6 f · 0.40 s |

Per-weapon versions exist for most of these (`FIRE_ROCKETLAUNCHER`, `RUN_MINIGUN`, `IDLE_FIRE_DUALPISTOLS`…), with the same lengths.

### Enemies: state → clip

| Original enemy (ours) | IDLE | RUN | ATTACK | DAMAGE_GUN (flinch) | Specials |
|---|---|---|---|---|---|
| ninja_1 (Bandana Bandit) | 13 f / 0.87 s | 13 f / 0.87 s | 3× 11 f / 0.73 s | 5 f / 0.33 s | CELEBRATE_A 13 f, DEATH_A 4 f |
| ninja_2 (Rodeo Kid) | 13 f / 0.87 s | 2× 13 f / 0.87 s | 3× 11 f / 0.73 s | 5 f / 0.33 s | SPIN 6 f, CELEBRATE_A 13 f, DEATH_A 4 f |
| horror_4 (Six-Shooter) | 13 f / 0.87 s | 13 f / 0.87 s | 3× 11 f / 0.73 s | 5 f / 0.33 s | CELEBRATE_A 13 f, DEATH_A 4 f |
| ninja_4 (Dynamite Dan) | 13 f / 0.87 s | 13 f / 0.87 s | 15 f / 1.00 s | 5 f / 0.33 s | CELEBRATE_A 13 f, DEATH_A 4 f |
| ninja_5 (Lasso Lucy) | 13 f / 0.87 s | 13 f / 0.87 s | 3× 8 f / 0.53 s | 5 f / 0.33 s | SPIN 6 f, CELEBRATE_A 13 f, DEATH_A 4 f |
| ninja_6 (Big Bart) | 13 f / 0.87 s | 13 f / 0.87 s | 3× 11 f / 0.73 s | 5 f / 0.33 s | BEHAVIOUR 13 f, CELEBRATE_A 13 f, DEATH_A 4 f |
| ninja_7 (Saloon Door Sam) | 13 f / 0.87 s | 13 f / 0.87 s | 3× 11 f / 0.73 s | 5 f / 0.33 s | CELEBRATE_A 13 f, DEATH_A 4 f |
| ninja_8 (McGraw) | 13 f / 0.87 s | 13 f / 0.87 s | 4× 9 f / 0.60 s | 5 f / 0.33 s | BEHAVIOUR 13 f, TAUNT 31 f, LEAP 13 f, LEAP_ATTACK 9 f, CELEBRATE_A 13 f, DEATH_A 4 f |
| horror_9 (Ma Rattler) | 13 f / 0.87 s | 13 f / 0.87 s | 2× 11 f / 0.73 s | 5 f / 0.33 s | TAUNT 23 f, LEAP 13 f, LEAP_ATTACK 9 f, CELEBRATE_A 13 f, DEATH_A 4 f |

## What this tells us
- **Every core agent clip is the same length on every agent:** the animators worked to
  one template. Idle, run, jump and damage are all 13-frame (0.87 s) loops; fire is 5
  frames (0.33 s); the spin is a 6-frame (0.4 s) turn; the landing 7 frames (0.47 s).
- **Firing is layered:** `FIRE` (0.33 s) is longer than the rifle's 0.175 s interval, and
  there are separate standing (`IDLE_FIRE`) and air (`JUMP_FIRE`) firing poses, so the
  upper body fires over whatever the legs are doing. That matches our planned shoot
  overlays ([[Feel and Look Asset Specs]] M8–M10).
- **Values that were unknown before** ([[Original Mechanics Match]] §7):
  - the berserker's wind-up (`BEHAVIOUR`) is **13 frames, 0.87 s** (our Big Bart's swig
    was a 1 s guess),
  - a light enemy's melee swing is **11 frames, 0.73 s**, which sets its attack rhythm,
    with 3 variations; McGraw's is 9 frames, 0.6 s,
  - the flinch (`DAMAGE_GUN`) is **5 frames, 0.33 s** (we guessed 0.15–0.25 s),
  - the lobber's throw is **15 frames, 1.0 s**, releasing at 0.6 s,
  - a boss taunt is **31 frames (2.1 s)**.
- **Enemies have 3 attack variations** and 2 deaths, so crowds don't move in lockstep.
- **Our own clip lengths** in [[Feel and Look Asset Specs]] are at 30 fps and mostly
  shorter (for example our run cycle is 8–10 frames, 0.27–0.33 s, against the original's
  0.87 s). Compare them in the viewer before animating.

## Using it
- **As reference:** open the viewer, step frame by frame with onion skin, and match key
  poses and timing in Blender ([[Blender to Roblox Animation]]).
- **Retargeting** (possible later): the clips only rotate bones in the screen plane, which
  is exactly what our side-on camera shows. A script could turn a clip's per-frame bone
  rotations into a Blender action on the R15 rig, as a starting block-out to polish.
- **The art itself is the original's:** use it as reference, not in our game.

Related: [[Original Game]] · [[Original Animation Decoder]] · [[Feel and Look Asset Specs]] · [[Original Mechanics Match]]
