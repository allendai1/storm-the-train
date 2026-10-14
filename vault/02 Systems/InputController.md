---
tags: [system, m1, input]
status: implemented
side: client
---
# InputController

## Purpose
Turns keyboard and mouse input into side-on movement and the combat input state ([[0005-side-on-movement-and-camera]]). Movement
modes are `Scriptable`, so nothing moves the character unless this controller does.

## Code
- Studio path: `StarterPlayer.StarterPlayerScripts.Client.Controllers.InputController`
  (`Modes = { "Run" }`)

## Expects in the place
- Nothing hand-built. The touch buttons live in `TouchControlsGui` and are wired by
  TouchControlsController ([[HudController]]).
- Runtime-generated content: _none_

## Public API
- `InputController.setTouchAxis(x)`, `setTouchFire(on)` and `setInteract(on)`: touch
  button state.
- `InputController.jump()`: a jump, or a spin when airborne.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `SetInput` | client → server (unreliable) | `fire` | See [[CombatService]] |
| `RequestSpin` | client → server | none | See [[CombatService]] |

## Data / state
- Bound to RenderStep `SideOnInput` at `RenderPriority.Input`.
- **A/D or ←/→:** `Humanoid:Move(Vector3.new(x, 0, 0))` every frame. The character faces
  ±X from the last move direction, by setting the root CFrame when it's misaligned.
- **Space, W or ↑:**
  - on the ground: a normal jump (JumpHeight 8, measured rise 8.1),
  - in the air: a **spin**, once per airborne stretch and no faster than
    `SPIN_COOLDOWN` (0.6 s). It sets the upward velocity for a `SPIN_LIFT` of 4 studs
    (the measured jump plus spin rise was 10.8).
- **Left mouse button held:** fire. There's no aiming (the mouse position is ignored);
  shots go along the facing (2026-10-13).
- **SetInput is sent:**
  - on a trigger change,
  - and resent every `INPUT_RESEND_INTERVAL` (0.5 s), because the remote is unreliable
    and a lost release must recover.
- `RequestSpin` is sent with each spin.
- It clears held keys and the trigger when the window loses focus.

## Depends on
- `Shared.Constants`

## Notes
- No gamepad yet. Add `Thumbstick1`/`ButtonA` if console is in scope.
- Verified 2026-10-13 in a playtest: holding D for 0.5 s moved about 16.5 studs facing
  +X. The jump, the spin and the ignored third press all behaved as above. In Session 3,
  a mouse hold fired both weapons and a release stopped them.
- Session 5 (2026-10-13):
  - **Interact** is `E`, held. It resends `RequestInteract` every `INTERACT_SEND_INTERVAL`
    (0.3 s) for revives ([[SquadService]]).
  - While `Downed` or `BledOut`, movement and jumping stop.
  - The touch axis adds to the keys, and touch fire ORs with the mouse.
- **M2 Session 10 (2026-10-14): the keys now match the GDD controls table.** Space jumps
  (W/↑ no longer jump). **W / ↑ held = Interact** (revive, and opening the Barracks via
  SquadController). **Q / E = swap** (`RequestSwap` −1/+1). New
  `InputController.swap(direction)` for the touch SWAP button. The revive prompt now reads
  "HOLD W".
