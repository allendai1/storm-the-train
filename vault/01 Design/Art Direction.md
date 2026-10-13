---
tags: [design, art]
status: planned
updated: 2026-10-13
---
# Art Direction

> Consult before any 3D modeling, mesh/material generation, or asset insertion.
> Claude should not invent art direction — ask the user, and put proposals in `00 Inbox/`.
>
> **Status: planned.** The developer decided the core choices and accepted the full
> detailed direction below on 2026-10-13. Hex colours are starting swatches: check them in
> Studio with `screen_capture` under the real lighting, and ask before changing them
> materially. Still open: ShadowMap vs Future lighting (§8), which waits for a mobile
> test.

## Core choices
- **Smooth stylized toon.** Rounded, chunky meshes with simple materials and bold
  shapes, like a Saturday-morning cartoon in 3D. It suits the costume-gag comedy
  ([[Game Design Document]] → Tone) and reads clearly from the locked side-on camera
  ([[0003-2.5d-side-scroller]]). It needs real mesh work: Blender, or Studio mesh
  generation restyled to match.
- **Bright actors, calmer worlds.** Each theme's backdrop is softer and less saturated.
  Everything you interact with is fully saturated: agents, enemies, hazards,
  projectiles and pickups. That keeps "Chaos you can read" true.
- **Standard Roblox R15 proportions** for agents and enemies. Personality comes from
  **silhouette**: costumes, hats, capes, skates, oversized props and weapons.
- **R15-compatible rigs with a custom look.** Our own toon meshes sit on an
  R15-compatible skeleton. They work with Roblox's animation tools and library and
  with Humanoid physics (needed for the GDD's ragdoll knock-outs).

## 1. Readability rules (side-on camera)
These turn "Chaos you can read" into rules every asset has to pass.
- **Silhouette test.** Every agent, enemy, drone and pickup must be identifiable as a
  **flat black silhouette from the side**. Hats, props and weapons carry the
  identity, because bodies are standard R15.
- **Three depth bands**, from the camera's point of view:
  1. **Foreground** (between the camera and the train): rare, dark, low-detail
     silhouettes such as telegraph poles, rocks and cacti. They never cover the
     gameplay plane for more than a moment.
  2. **Gameplay plane** (the train and everything on it): the **brightest, most
     saturated, highest-contrast** band.
  3. **Background** (beyond the train): **lighter, desaturated and lower contrast**,
     getting paler with distance (atmospheric perspective via `Atmosphere`/fog).
- **Colour language** (consistent across all themes):

  | Meaning | Colour | Plus a shape cue (for colour-blind players) |
  |---|---|---|
  | **Danger / enemy attack telegraph** | Hot orange-red glow `#FF4A1C` | A "!" pop above the enemy and a wind-up pose |
  | **Enemy projectiles** | Orange-red `#FF5A2A` | A dark outline and a smoky trail |
  | **Player projectiles** | Warm white-yellow `#FFF2B3` | A clean, bright tracer with no outline |
  | **Coins** | Gold `#FFC83D` | Round and spinning |
  | **Gems** | Cyan-magenta `#3DE0FF` / `#E04DFF` | Faceted diamond |
  | **Blueprints** | Blueprint blue `#2F6FD6` with white lines | A rolled paper scroll |
  | **Healing** | Mint green `#5BE38A` | Plus-sign particles |

- **Player identification:** each player gets a colour for their ring, nameplate and
  HUD portrait frame. **P1 blue `#3D8BFF`, P2 green `#3DDC84`, P3 yellow `#FFD23D`,
  P4 pink `#FF6FD8`.** No red, because red means danger.

## 2. Theme palettes
**Wild West** (first playable). Calm world, bright actors:

| Role | Colour | Notes |
|---|---|---|
| Sky (top → horizon) | `#8EC3E6` → `#F6DDB4` | Warm, hazy afternoon |
| Distant mesas | `#D9A27C` | Desaturated terracotta that fades with distance |
| Desert floor | `#E8CBA2` | Pale sand |
| Scrub and cacti | `#A9B38A` | Muted sage |
| Freight cars | `#B04A33` red / `#7C5A3A` wood | The gameplay plane's main surfaces, a little brighter than the world |
| Iron and trim | `#3B3B42` | Wheels, couplings, roof edges |
| **Rattler Gang crew colour** | Bandana red `#D7322F` + snakeskin tan `#C9A15A` | Every bandit wears the red bandana, so "enemy" reads instantly |

**Later themes** (first-pass mood only, to define properly in M3):
- **Ninjas:** misty bamboo greens and ink-wash greys, with a crew colour of deep indigo
  and white.
- **Undead:** moonlit teal and purple fog, with a crew colour of sickly lime green.
- **Robots:** clean steel blue and white, with a crew colour of warning yellow and black.

Each crew colour must stay distinct from the four player colours and the danger
orange.

## 3. Agent signature colours
Each agent owns 1–2 saturated colours, used on their costume, HUD portrait and gadget
skins. They don't clash with the gang red or the player colours.

| Agent | Signature colours | Silhouette hook |
|---|---|---|
| Dash Daring | Navy tux `#1F2A44`, gold `#F2C14E` | Tux tails and a perfect hair swoop |
| Brick Broadsley | Royal purple `#6B3FA0`, gold | A huge cape and a wrestling mask, with a tiny briefcase |
| Turbo | Hot pink `#FF4FA3`, teal `#19C3B3` | Roller skates, a helmet, and a courier bag |
| Nana Nitro | Lavender cardigan `#B79BE0`, yarn orange `#FF8A3D` | Tiny frame with a **giant** knitting bag |
| Mimi the Mime | Black and white stripes, red-pink beret `#E8466B` | Beret and stripes, white gloves |
| Zorp | Lime alien `#7DDB3A`, tourist-shirt orange `#FF9F1C` | A big domed head (head scale up to ~1.15), a camera round his neck |

Mimi's beret is a pink-leaning red so it doesn't read as gang red.

## 4. Characters
- **Bodies:** standard R15 proportions (decided). A **head scale of up to about 1.15** is
  allowed where the gag needs it (Zorp), and so are oversized hands and props.
- **Faces:** big, simple, expressive. Large eyes, and eyebrows that sell emotion from
  the side. Use **face decals or textures swapped per state** (normal, hurt, downed,
  celebrating) rather than facial rigs.
- **Costume damage, 3 stages** (GDD → Key mechanics). Each stage swaps costume pieces:
  1. Full costume.
  2. Torn and scuffed, with a missing hat or sleeve, smudges and patches.
  3. **Comedy long johns.** The costume is mostly gone, leaving full-coverage red
     long johns (or an agent-appropriate equivalent: Zorp's "space pyjamas", Brick's
     singlet).

  This replaces the original's underwear stage with an all-ages, fully covered gag.
- **Enemies** follow the same rules. Lights are simpler, so crowds stay cheap. Mids and
  bosses get more detail and bigger props.

## 5. Animation feel
- **Snappy and exaggerated:** strong anticipation before every enemy attack (it doubles
  as the telegraph), quick actions, and an overshoot on landings.
- Squash and stretch is suggested in the poses, because R15 parts don't deform.
- **Knock-outs** are Humanoid ragdolls (GDD), started with an exaggerated impulse, a hat
  popping off and circling stars.
- Agents have an idle with personality (Dash checks his hair, Nana knits) and a
  swap-in pose.

## 6. Environments & the train
- **Scale check:** carriages are about 17 and 33 studs long (GDD). An R15 character is about
  5 studs tall. The camera shows about **70 studs** of track width, matching the
  original's screen.
- **Wild West train pieces:**
  - steam engine with a cowcatcher,
  - boxcar,
  - flatbed (boss arena),
  - cattle car,
  - jail car (hostage),
  - water tanker,
  - caboose.

  Roofs are the main walking surface. Interiors can be entered where the GDD allows.
- **Motion illusion:** the train stays put and the **world scrolls past** in layers
  (parallax), with wheel and rod animation, smoke and a slight sway. The background
  repeats in long seamless strips with occasional set-pieces such as a canyon, a bridge,
  a ghost town or a cactus field.
- **The hub train** (name to be chosen) has the Agency's look: navy and gold with
  polished brass, clearly "our side" next to the hostile trains.

## 7. Materials & textures
- Mostly **SmoothPlastic** with base colours. A few custom **MaterialVariants** cover
  wood, metal and fabric, with soft, low-contrast toon patterns rather than realistic
  detail.
- `SurfaceAppearance` is only for hero meshes (agents, bosses) and uses **hand-painted
  gradients**, not photo textures.
- Textures: **256–512 px** for most things and **1024 px max** for agents and bosses. Use
  texture atlases per theme.

## 8. Lighting & atmosphere
- **[open]** `Lighting.Technology = ShadowMap`, as a balance between looks and
  performance on mobile with crowds. Test **Future** on PC, and only use it if mobile
  holds frame rate.
- One strong key light (the sun) from slightly in front of the gameplay plane, so faces
  toward the camera are lit. A warm key and cool ambient for the Wild West.
- `Atmosphere` for distance fade. A little `Bloom`, and a gentle `ColorCorrection`
  boost to saturation and contrast. No heavy depth of field, which would hurt
  readability.

## 9. VFX
- **No blood, ever** (pillar "Silly, never mean"). Hits make white flash sparks.
  Knock-outs make dust puffs, stars and wood splinters.
- **Explosions** are big, round toon puffs: a bright orange-yellow core, then chunky grey
  smoke balls, with a screen-shake bump.
- Use **flipbook particles** for smoke and dust. Cap the particle rates, because 4 players
  plus a crowd add up.
- Comic-style text pops for "COMBO!", the multiplier tiers and big hits. Floating
  knockout numbers come from a template (see [[Score and Combo]]).

## 10. UI
- Chunky, rounded panels with thick borders and slight drop shadows, matching the toon
  style.
- **Fonts:** **Luckiest Guy** for titles, barks and combo pops, and **Builder Sans** for
  body text and numbers. Both are built into Roblox. Check the exact `Font` names in
  Studio.
- Scale-based layouts with `UIAspectRatioConstraint` (per `CLAUDE.md`). **Touch targets
  must be at least 48 px**, with the mobile layout designed first and then adapted to
  PC.
- HUD colours follow the colour language above. Player-colour frames show who's who.

## 11. Technical budgets (starting targets; verify in Studio on a mid-range phone)
| Asset | Triangles | Textures | Notes |
|---|---|---|---|
| Agent | ≤ 6k | 1 × 1024 | Plus costume-stage pieces, which swap rather than add up |
| Light enemy | ≤ 2.5k | 1 × 512 | Crowds of 15–30 |
| Mid enemy | ≤ 4k | 1 × 512 | |
| Boss | ≤ 10k | 1 × 1024 | |
| Drone / mech suit | ≤ 3k / ≤ 8k | 512 / 1024 | |
| Carriage | ≤ 8k | Theme atlas | Built from a few meshes, not hundreds of parts |
| Background strip | ≤ 20k per visible stretch | Theme atlas | Recycled as it scrolls |

- **On screen:** about 40 animated characters at most (4 agents plus a crowd plus a boss),
  plus at most about 12 ragdolls (GDD).
- **Particles:** at most about 500 alive at once on mobile.

## 12. Asset sourcing
- **Studio mesh/material generation** and **Creator Store** assets are fine as a starting
  point. They must be restyled to this palette and toon finish, and checked for
  embedded scripts (per `CLAUDE.md`).
- Record any reusable Blender method in `06 Techniques/`.

## 13. References to collect
Add images to `05 Assets/References/` and list them in [[References]]. The names below
are touchstones for the feel only; nothing is copied.
- **3D toon style:** Saturday-morning-cartoon 3D. Examples for chunky, rounded,
  readable toon shapes: the look of *The Incredibles* (retro spy-fi), *Kim Possible*,
  or *Spy Kids* for comedy agents.
- **Wild West tone:** cartoon westerns such as Looney Tunes desert chases and *Rango*'s
  palette. Real steam freight trains for shapes and parts.
- **Side-on 3D readability:** modern 2.5D side-scrollers with 3D models.
- **Roblox examples:** smooth-toon Roblox experiences that run well on mobile, to set
  the budget bar.

Related: [[Home]] · [[Status]] · [[Game Design Document]] · [[Launch Agents]] · [[Wild West Enemies]] · [[References]]
