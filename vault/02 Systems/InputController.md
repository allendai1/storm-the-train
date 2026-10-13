---
tags: [system, m1, input]
status: implemented
side: client
---
# InputController

## Purpose
Turns keyboard input into side-on movement ([[0005-side-on-movement-and-camera]]). Movement
modes are `Scriptable`, so nothing moves the character unless this controller does.

## Code
- Studio path: `StarterPlayer.StarterPlayerScripts.Client.Controllers.InputController`
  (`Modes = { "Run" }`)

## Expects in the place
- Nothing hand-built. Touch buttons come with `TouchControlsGui` (Session 5).
- Runtime-generated content: _none_

## Public API
None yet. Session 5's `TouchControlsController` will need a way to feed in the move axis
and jump presses.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `RequestSpin` | client → server | none | **Not sent yet.** Session 3 adds the `FireServer` call (marked in `jump()`) and CombatService's handler |

## Data / state
- Bound to RenderStep `SideOnInput` at `RenderPriority.Input`.
- **A/D or ←/→:** `Humanoid:Move(Vector3.new(x, 0, 0))` every frame. The character faces
  ±X from the last move direction, by setting the root CFrame when it's misaligned.
- **Space, W or ↑:**
  - on the ground: a normal jump (JumpHeight 8, measured rise 8.1),
  - in the air: a **spin**, once per airborne stretch and no faster than
    `SPIN_COOLDOWN` (0.6 s). It sets the upward velocity for a `SPIN_LIFT` of 4 studs
    (the measured jump plus spin rise was 10.8).
- It clears held keys when the window loses focus.

## Depends on
- `Shared.Constants`

## Notes
- No gamepad yet. Add `Thumbstick1`/`ButtonA` if console is in scope.
- Verified 2026-10-13 in a playtest: holding D for 0.5 s moved about 16.5 studs facing
  +X. The jump, the spin and the ignored third press all behaved as above.
