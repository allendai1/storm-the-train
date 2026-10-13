---
tags: [system, m1, movement, security]
status: implemented
side: server
---
# CharacterService

## Purpose
**Spawns each player as their agent rig** and sets up the character for side-on play
([[0005-side-on-movement-and-camera]]). It also validates movement on the server. Clients own their characters. The server never trusts
their position; it only checks and corrects it.

## Code
- Studio path: `ServerScriptService.Server.Services.CharacterService` (`Modes = { "Run" }`)

## Expects in the place
- **Agent template** `ReplicatedStorage.Assets.Agents.DashDaring`:
  - an R15 rig made with `CreateHumanoidModelFromDescription`, so it includes the `Animate`
    script,
  - a greybox costume: navy tux, white shirt front, gold bow tie, hair swoop and tux tails,
  - Attributes `Speed` 28.3, `Toughness` 0.52, `SpinLevel` 4,
    `PrimaryWeapon = "ServiceRifle"` and `SecondaryWeapon = "PocketRocket"`, and the tag
    `Agent`,
  - an invisible **`Hitbox`** part (1.3 × 5.5 × 2) welded to the root, in collision group
    `Hitboxes`.
- `Workspace.Map.Run.Staging.StagingSpawn` (SpawnLocation). Only its position is used:
  agents spawn on top of it, facing +X.
- Tag `WalkSurface` on roofs and the staging `Platform`. Gap-fall recovery picks the
  nearest one in `workspace`; tagged templates in ServerStorage are ignored.
- Collision group `Players` (from M0).
- Runtime-generated content: a `PlaneLockAnchor` Attachment on `workspace.Terrain`, and a
  `PlaneLock` (PlaneConstraint) plus a `PlaneLockAttachment` on each `HumanoidRootPart`.
  These are functional physics, with nothing to hand-edit.

## Public API
- `CharacterService.spawn(player)`: clones the agent, sets `player.Character`, parents it
  to `workspace` and destroys the old character. It runs on join; Session 5's PLAY AGAIN
  will call it too.
- `init()` sets `Players.CharacterAutoLoads = false` at runtime, so Run mode never loads
  default avatars. Hub mode (M2) will need its own spawning.

## Remotes
None. `RequestSpin` is handled by CombatService in Session 3.

## Data / state
- **On spawn:**
  - it sets `UseJumpPower = false`, `JumpHeight = Constants.JUMP_HEIGHT` (8),
    `WalkSpeed` = the rig's `Speed`, and `AutoRotate = false`,
  - it moves every `Default`-group character part into `Players`, leaving the `Hitbox` in
    `Hitboxes`,
  - it sets the Player attributes `ActiveAgent`, `Toughness` and `Health` = 100,
  - it equips the `PrimaryWeapon` through [[CombatService]].
- **Plane lock:** `PlaneConstraint`. Its plane normal is Attachment0's primary axis, so
  the anchor's `Axis` is (0, 0, 1) at Z = `PLANE_Z`.
- **Every `MOVE_CHECK_INTERVAL` (0.25 s):**
  - **Gap fall:** root Y below `GAP_FALL_Y` (5) for `GAP_FALL_DELAY` (1 s) moves the player
    to the nearest point on a `WalkSurface`, `GAP_FALL_EDGE_MARGIN` (2) in from its end and
    `GAP_FALL_DROP_HEIGHT` (4) above it. It then applies `GAP_FALL_DAMAGE` (15 raw) through
    `CombatService.damagePlayer`.
  - **Z drift** above `PLANE_Z_TOLERANCE` (0.5) snaps back to the plane.
  - **Speed/teleport:** X movement above `WalkSpeed × SPEED_TOLERANCE × dt + MOVE_SLACK`
    gets `Guard.strike(player, "move:speed")` and a set-back to the last valid position.

## Depends on
- [[Guard]], [[CombatService]], `Shared.Constants`

## Notes
- Session 3 (2026-10-13): agent spawning, stats from attributes, and gap-fall damage were
  verified. The rig spawned client-owned and animated, and a gap fall cost 7.8 HP.
- Vertical movement isn't validated yet (jump and spin lift are client-side). Add an
  upward-teleport check if fly hacks show up.
- `GAP_FALL_Y` is an absolute height that assumes `TrainStart` Y = 3. Update it if the
  train moves vertically.
- Verified 2026-10-13 in a playtest:
  - stats and the plane lock were applied,
  - a drop into the staging–caboose gap recovered to the staging edge (X −5) after about
    1.4 s,
  - a 40-stud client teleport was set back within 0.4 s,
  - a 3-stud Z push returned to Z 0.
