---
tags: [system, m1, camera]
status: implemented
side: client
---
# CameraController

## Purpose
The side-on Scriptable camera ([[0005-side-on-movement-and-camera]]). It looks along −Z at
the gameplay plane and keeps about `CAMERA_WIDTH_STUDS` (70) of track in view at any aspect
ratio.

## Code
- Studio path: `StarterPlayer.StarterPlayerScripts.Client.Controllers.CameraController`
  (`Modes = { "Run" }`)

## Expects in the place
- Nothing. Runtime-generated content: _none_

## Public API
None.

## Remotes
None.

## Data / state
- Bound to RenderStep `SideOnCamera` at `RenderPriority.Camera`. It re-asserts
  `CameraType = Scriptable` and `FieldOfView = CAMERA_FOV` (40) every frame.
- **Distance:** `(70 / 2) / (tan(FOV / 2) × aspect)`. That's about 54 studs at 16:9 and
  about 44 on a 2.16:1 phone.
- **Follow:**
  - X = the root's X + `CAMERA_LEAD` (8) in the facing direction (read from the root's
    LookVector),
  - Y = `CAMERA_HEIGHT` (13) + `CAMERA_Y_FOLLOW` (0.35) × (root Y − 13),
  - smoothed with `1 − exp(−CAMERA_SMOOTH × dt)` (`CAMERA_SMOOTH` = 6).

## Depends on
- `Shared.Constants`

## Notes
- Still to come:
  - spectating a teammate while downed (Session 5),
  - edge-of-screen teammate arrows,
  - a slight camera sway for the motion illusion (ADR 0009).
- Verified 2026-10-13 in a playtest: Scriptable, FOV 40, Z ≈ 48 in the Studio viewport,
  and it follows with the lead. The screen capture showed the train side-on.
