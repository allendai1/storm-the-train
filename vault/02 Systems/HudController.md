---
tags: [system, m1, ui, hud]
status: implemented
side: client
---
# HudController (+ TouchControlsController, RunEndController)

## Purpose
The M1 UI controllers. Each one drives a hand-built ScreenGui in `StarterGui` and only
sets text, visibility, bar fills and player colours. The layout and look live in the GUIs
(`CLAUDE.md` → Build it in the place).

## Code
- `StarterPlayer.StarterPlayerScripts.Client.Controllers.HudController`
- `…Controllers.TouchControlsController`
- `…Controllers.RunEndController`

## Expects in the place
All three GUIs have `ResetOnSpawn = false`. They use Scale sizes with
`UIAspectRatioConstraint`, Luckiest Guy for titles, and Builder Sans Bold for body text.
They follow [[Art Direction]] §10.

The Figma mockups couldn't be read this session (the Starter plan's tool-call limit), so
the layout follows the written §10 description. Check the GUIs against Figma by hand.

- **`StarterGui.HudGui`**
  - `PlayerPanel` (top-left): `Portrait` (whose UIStroke is the player colour, with an
    `Initial` label), `NameLabel`, `HealthBar.Fill` and `HealthBar.HealthText`, and
    `WeaponLabel`.
  - `Teammates` (a UIListLayout): `Template` card with `NameLabel`, `Status` ("DOWN!" or
    "OUT") and `HealthBar.Fill`.
  - `TrainProgress` (top-centre): `Title` "TRAIN 1 · CABOOSE → ENGINE", and `Track.Marker`.
  - `BlueprintCounter.Label` (top-right).
  - `Banner`: the centre announcement.
  - `LobbyPanel`: `Status` and `ReadyButton`.
  - `DownedPanel`: `Title`, `Hint` and `ReviveBar.Fill`.
  - `RevivePrompt`: `Label` and `Progress.Fill`. It's a screen-space prompt, not a
    billboard.
- **`StarterGui.TouchControlsGui`:** round buttons `LeftButton`, `RightButton`,
  `ShootButton`, `JumpButton` and `ContextButton` ("REVIVE", hidden). They have a
  `UISizeConstraint` minimum of 56 px, so they're always over the 48 pt target.
- **`StarterGui.RunEndGui`** (`Enabled = false`, `DisplayOrder` 10): `Panel` with
  `Title`, `TimeLabel`, a `Header` row, and `Rows` (UIListLayout) holding `Template` with
  `NameLabel`, `KnockoutsLabel`, `RevivesLabel` and `BlueprintsLabel`. Then
  `PlayAgainButton` and `WaitingLabel`. Toggle `Enabled` in Studio to edit it.
- Runtime-generated content: clones of the teammate card and result row templates.

## Public API
- `HudController.reviveTarget() -> Player?`: the downed teammate in `REVIVE_RANGE`. It's
  for display only (the prompt and the touch context button); the server picks the real
  target.

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `RequestReady` | client → server | none: READY in the lobby, PLAY AGAIN in results | see [[RunStateService]] |
| `Announce` | server → client | `text` → `Banner` for `ANNOUNCE_TIME` (2.5 s) | — |
| `RunEnded` | server → client | `Types.RunResult` → RunEndGui | — |

## Data / state
- **HudController** updates everything every Heartbeat from replicated state:
  - Player attributes `Health`, `ActiveWeapon` ("ServiceRifle" shows as "SERVICE RIFLE"),
    `Blueprints`, `PlayerSlot` (`Constants.PLAYER_COLORS`), `Ready`, `Downed`, `BledOut`,
    `BleedOutEndsAt` and `ReviveProgress`,
  - workspace attributes `RunState` and `StartsAt`.
  - The **lobby panel** shows only in `Lobby`. It reads "READY UP! r/n · Ns", or
    "STARTING IN N" once everyone's ready.
  - The **downed panel** shows only in `InTrain`.
  - The **train progress marker** is the player's X between the caboose's rear and the
    engine's front.
- **TouchControlsController:** the GUI is enabled only if `UserInputService.TouchEnabled`.
  The holds feed `InputController.setTouchAxis`, `setTouchFire` and `setInteract`, and
  JUMP calls `InputController.jump`. The context button is visible while `reviveTarget()`
  is set.
- **RunEndController:** shows the panel on `RunEnded`. PLAY AGAIN sends `RequestReady`,
  `WaitingLabel` shows "WAITING FOR SQUAD r/n", and the screen hides when `RunState`
  leaves `Results`.

## Depends on
- [[InputController]] (touch API), [[RunStateService]], [[SquadService]], `Shared.Constants`,
  `Shared.Types`

## Notes
- Verified 2026-10-13 in a playtest:
  - the HUD showed health dropping under hits, the active weapon and the progress marker,
  - the lobby panel hid in-run,
  - the touch GUI was off on desktop,
  - READY and PLAY AGAIN clicked through the real buttons,
  - RunEndGui filled its row (name, 1 KO).
- **Not verified:**
  - the touch controls on a device or in the emulator,
  - the teammate cards and the revive prompt (they need 2+ players).
- A finger sliding off a touch button might not release it. Track touches globally if
  playtests show stuck input.
- The active weapon is text, not an icon. Icons come with art.
- **Still to come:** the Mayhem ring and gadget fan (M2), and score, combo and currencies
  (M2).
