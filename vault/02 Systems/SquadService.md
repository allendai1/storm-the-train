---
tags: [system, m1, co-op, revive]
status: implemented
side: server
---
# SquadService

## Purpose
Co-op survival ([[First Playable (M1)]] → Co-op, downed and revive):
- downed at 0 HP and bleeding out,
- teammate revives through a held Interact,
- interrupting a revive when the reviver takes damage,
- bleeding out into spectating,
- wipe detection.

It also gives each player a HUD colour slot.

## Code
- Studio path: `ServerScriptService.Server.Services.SquadService` (`Modes = { "Run" }`)

## Expects in the place
- Remotes `RequestInteract` and `Announce`.

## Public API
- `SquadService.isUp(player) -> boolean`: Health > 0 and not `Downed` or `BledOut`.
- `SquadService.allDown() -> boolean`: nobody in the server is up (the wipe check).
- `SquadService.reset(player)`: clears the downed state and sets `Revives = 0` (PLAY AGAIN).

## Remotes
| Name | Direction | Payload | Server validation |
|------|-----------|---------|-------------------|
| `RequestInteract` | client → server | none | 4/s, burst 4. The reviver must be up. The **server** picks the nearest `Downed` teammate within `REVIVE_RANGE` (5) |
| `Announce` | server → all clients | "(NAME) IS DOWN!" | — |

## Data / state
- **Player attributes:**
  - `Downed`, `BleedOutEndsAt` (server time), `ReviveProgress` (0–1) and `BledOut`,
  - `Revives`,
  - `PlayerSlot` (1–4, the lowest free on join; the index into
    `Constants.PLAYER_COLORS`).
- **Downed:** when the `Health` attribute reaches 0:
  - `Downed = true`, and `BleedOutEndsAt = now + REVIVE_BLEED_OUT` (15 s),
  - `Humanoid.PlatformStand = true`, so the body lies down,
  - an announcement.

  Enemies and firing already ignore Health 0. [[InputController]] stops moving and jumping
  while down.
- **Revive:**
  - The client resends `RequestInteract` every `INTERACT_SEND_INTERVAL` (0.3 s) while
    Interact is held.
  - A revive restarts if:
    - the target changes,
    - there's a gap of more than `REVIVE_REQUEST_GAP` (0.6 s) between requests, or
    - the reviver's Health has dropped since the revive started.
  - After `REVIVE_HOLD` (2 s), the target gets Health `PLAYER_MAX_HEALTH ×
    REVIVE_HEALTH_FRACTION` (40) and stands back up, and the reviver gets `Revives + 1`.
- **Bleed out:** at `BleedOutEndsAt` a downed player becomes `BledOut` (out until PLAY
  AGAIN, still lying down). [[CameraController]] then follows the nearest up teammate.
- Ticks every `RUN_CHECK_INTERVAL` (0.25 s). Unreleased revives time out and their
  progress resets.

## Depends on
- [[Guard]], `Shared.Constants`

## Notes
- Verified 2026-10-13 (one player): Health 0 → `Downed`, PlatformStand, and an immediate
  wipe, because nobody was up.
- **Not verified:** a revive, a revive interrupted by damage, bleeding out, and
  spectating. They need 2+ players (Session 6 multi-client test).
- A downed player in a gap is still recovered to a roof by [[CharacterService]] (which
  checks the Humanoid's own Health, never touched). The fall damage does nothing at
  0 HP. Check how this looks in co-op.

## Combat Polish (2026-10-16)
- **Revive grace:** when a revive completes, the target gets `REVIVE_GRACE` (3 s) of
  invulnerability (`CombatFeel.grantInvulnerability`). Live enemies within
  `REVIVE_PUSH_RADIUS` (10) are shoved sideways at 40 studs/s with no lift
  (`CombatService.knockback`), so they stay on the train.
- **Not verified:** it needs 2 players.
