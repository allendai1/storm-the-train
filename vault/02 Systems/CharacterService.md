---
tags: [system, m1, movement, security]
status: implemented
side: server
---
# CharacterService

## Purpose
Sets up each player's character for side-on play ([[0005-side-on-movement-and-camera]]) and
validates movement on the server. Clients own their characters. The server never trusts
their position; it only checks and corrects it.

## Code
- Studio path: `ServerScriptService.Server.Services.CharacterService` (`Modes = { "Run" }`)

## Expects in the place
- `Workspace.Map.Run.Staging.StagingSpawn` (SpawnLocation). It's set as every player's
  `RespawnLocation`.
- Tag `WalkSurface` on roofs and the staging `Platform`. Gap-fall recovery picks the
  nearest one in `workspace`; tagged templates in ServerStorage are ignored.
- Collision group `Players` (from M0).
- Runtime-generated content: a `PlaneLockAnchor` Attachment on `workspace.Terrain`, and a
  `PlaneLock` (PlaneConstraint) plus a `PlaneLockAttachment` on each `HumanoidRootPart`.
  These are functional physics, with nothing to hand-edit.

## Public API
None yet. It runs on its own from `start()`.

## Remotes
None. `RequestSpin` is handled by CombatService in Session 3.

## Data / state
- On spawn it sets `UseJumpPower = false`, `JumpHeight = Constants.JUMP_HEIGHT` (8),
  `WalkSpeed = Constants.FALLBACK_AGENT_SPEED` (28.3) and `AutoRotate = false`, and puts
  every character part in the `Players` collision group.
- **Plane lock:** `PlaneConstraint`. Its plane normal is Attachment0's primary axis, so
  the anchor's `Axis` is (0, 0, 1) at Z = `PLANE_Z`.
- **Every `MOVE_CHECK_INTERVAL` (0.25 s):**
  - **Gap fall:** root Y below `GAP_FALL_Y` (5) for `GAP_FALL_DELAY` (1 s) moves the player
    to the nearest point on a `WalkSurface`, `GAP_FALL_EDGE_MARGIN` (2) in from its end and
    `GAP_FALL_DROP_HEIGHT` (4) above it.
  - **Z drift** above `PLANE_Z_TOLERANCE` (0.5) snaps back to the plane.
  - **Speed/teleport:** X movement above `WalkSpeed × SPEED_TOLERANCE × dt + MOVE_SLACK`
    gets `Guard.strike(player, "move:speed")` and a set-back to the last valid position.

## Depends on
- [[Guard]], `Shared.Constants`

## Notes
- **Session 3:**
  - swap in the Dash Daring agent rig and read `Speed`/`Toughness` from its Attributes
    instead of `FALLBACK_AGENT_SPEED`,
  - apply `GAP_FALL_DAMAGE` (15 raw × toughness) on recovery,
  - the agent template carries the `Hitbox` part, so this service doesn't add one.
- Vertical movement isn't validated yet (jump and spin lift are client-side). Add an
  upward-teleport check if fly hacks show up.
- `GAP_FALL_Y` is an absolute height that assumes `TrainStart` Y = 3. Update it if the
  train moves vertically.
- A character that first spawns on the template's default `Workspace.SpawnLocation`
  (under the caboose) recovers onto a roof after 1 s.
- Verified 2026-10-13 in a playtest:
  - stats and the plane lock were applied,
  - a drop into the staging–caboose gap recovered to the staging edge (X −5) after about
    1.4 s,
  - a 40-stud client teleport was set back within 0.4 s,
  - a 3-stud Z push returned to Z 0.
